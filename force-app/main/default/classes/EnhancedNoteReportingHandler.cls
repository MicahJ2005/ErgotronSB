/**
 * EnhancedNoteReportingHandler
 *
 * Central handler for maintaining Enhanced_Note_Reporting__c records
 * in sync with Salesforce Enhanced Notes (ContentNote + ContentDocumentLink).
 *
 * Architecture notes:
 *  - One ENR record is created per (ContentNote × parent record) pair.
 *    A single note linked to 3 parent records produces 3 ENR records.
 *  - Only Contact, Lead, and Opportunity parents are supported.
 *    Links to other object types are silently ignored.
 *  - Note_Preview__c is populated from ContentNote.TextPreview (255 chars).
 *    If full note body is required, replace with a Content Blob decode —
 *    be aware of governor limits on large note volumes.
 */
public with sharing class EnhancedNoteReportingHandler {

    // SObject API names that should produce ENR records
    private static final Set<String> SUPPORTED_OBJECTS = new Set<String>{
        'Contact', 'Lead', 'Opportunity'
    };

    // ─────────────────────────────────────────────────────────────
    // CREATE — triggered by ContentDocumentLink after insert
    // ─────────────────────────────────────────────────────────────

    /**
     * Called from ContentDocumentLinkENRTrigger (after insert).
     * Creates one Enhanced_Note_Reporting__c record for each CDL
     * that links a ContentNote to a supported parent object.
     */
    public static void handleCDLInsert(List<ContentDocumentLink> newCDLs) {

        // Filter to supported parent objects only
        List<ContentDocumentLink> relevantCDLs = new List<ContentDocumentLink>();
        for (ContentDocumentLink cdl : newCDLs) {
            String sObjType = cdl.LinkedEntityId.getSObjectType().getDescribe().getName();
            if (SUPPORTED_OBJECTS.contains(sObjType)) {
                relevantCDLs.add(cdl);
            }
        }
        if (relevantCDLs.isEmpty()) { return; }

        // Collect ContentDocument IDs so we can confirm they are ContentNotes
        Set<Id> contentDocIds = new Set<Id>();
        for (ContentDocumentLink cdl : relevantCDLs) {
            contentDocIds.add(cdl.ContentDocumentId);
        }

        // Query only ContentNote records (files/attachments are excluded)
        Map<Id, ContentNote> noteMap = new Map<Id, ContentNote>([
            SELECT Id, Title, TextPreview, CreatedDate, LastModifiedDate,
                   CreatedById, LastModifiedById
            FROM   ContentNote
            WHERE  Id IN :contentDocIds
        ]);

        // Build ENR records — Note_Preview__c left null here; the Queueable populates it
        // after the transaction commits once Salesforce has generated TextPreview
        List<Enhanced_Note_Reporting__c> toInsert = new List<Enhanced_Note_Reporting__c>();
        Set<Id> insertedDocIds = new Set<Id>();
        for (ContentDocumentLink cdl : relevantCDLs) {
            ContentNote note = noteMap.get(cdl.ContentDocumentId);
            if (note == null) { continue; } // Not a ContentNote — skip
            toInsert.add(buildENR(note, cdl));
            insertedDocIds.add(cdl.ContentDocumentId);
        }

        if (!toInsert.isEmpty()) {
            insert toInsert;
            System.enqueueJob(new ENRPreviewSyncQueueable(insertedDocIds));
        }
    }

    // ─────────────────────────────────────────────────────────────
    // CONTENT SAVED — triggered by ContentVersion after insert
    // ─────────────────────────────────────────────────────────────

    /**
     * Called from ContentVersionENRTrigger (after insert).
     * Each time a note body is saved, Salesforce inserts a new ContentVersion.
     * ContentDocument after-update does not reliably fire for body changes,
     * so this is the authoritative hook for syncing Note_Preview__c.
     */
    public static void handleVersionInsert(List<ContentVersion> newVersions) {
        Set<Id> contentDocIds = new Set<Id>();
        for (ContentVersion cv : newVersions) {
            if (cv.FileType == 'SNOTE' && cv.ContentDocumentId != null) {
                contentDocIds.add(cv.ContentDocumentId);
            }
        }
        if (!contentDocIds.isEmpty()) {
            System.enqueueJob(new ENRPreviewSyncQueueable(contentDocIds));
        }
    }

    // ─────────────────────────────────────────────────────────────
    // UPDATE — triggered by ContentDocument after update (metadata changes)
    // ─────────────────────────────────────────────────────────────

    /**
     * Called from ContentNoteENRTrigger (after update).
     * Handles metadata-only changes to ContentDocument (e.g. title renames).
     * Note body changes are handled by handleVersionInsert instead.
     */
    public static void handleNoteUpdate(
        List<ContentDocument> newDocs,
        Map<Id, ContentDocument> oldMap
    ) {
        // Only process notes where the modified date actually changed
        List<ContentDocument> changedDocs = new List<ContentDocument>();
        for (ContentDocument doc : newDocs) {
            ContentDocument oldDoc = oldMap.get(doc.Id);
            if (doc.LastModifiedDate != oldDoc.LastModifiedDate) {
                changedDocs.add(doc);
            }
        }
        if (changedDocs.isEmpty()) { return; }

        Set<Id> changedIds = new Map<Id, ContentDocument>(changedDocs).keySet();

        // Use ContentVersion.TextPreview — more reliably populated than ContentNote.TextPreview in trigger context
        Map<Id, ContentVersion> versionMap = new Map<Id, ContentVersion>();
        for (ContentVersion cv : [
            SELECT Id, ContentDocumentId, TextPreview
            FROM   ContentVersion
            WHERE  ContentDocumentId IN :changedIds
            AND    IsLatest = true
            AND    FileType = 'SNOTE'
        ]) {
            versionMap.put(cv.ContentDocumentId, cv);
        }

        Set<String> noteIds = toStringSet(changedDocs);
        Map<String, ContentDocument> docById = new Map<String, ContentDocument>();
        for (ContentDocument d : changedDocs) {
            docById.put(String.valueOf(d.Id), d);
        }

        // A note can be linked to multiple parents → multiple ENR records
        List<Enhanced_Note_Reporting__c> toUpdate = new List<Enhanced_Note_Reporting__c>();
        for (Enhanced_Note_Reporting__c enr : [
            SELECT Id, Content_Document_ID__c
            FROM   Enhanced_Note_Reporting__c
            WHERE  Content_Document_ID__c IN :noteIds
        ]) {
            ContentDocument doc = docById.get(enr.Content_Document_ID__c);
            if (doc == null) { continue; }
            ContentVersion cv = versionMap.get(doc.Id);
            system.debug('ENR Update - ContentVersion: ' + cv.TextPreview);
            enr.Note_Preview__c            = cv != null ? cv.TextPreview : null;
            enr.Note_Last_Modified_Date__c = doc.LastModifiedDate;
            enr.Last_Sync_Date__c          = System.now();
            toUpdate.add(enr);
        }

        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }

    // ─────────────────────────────────────────────────────────────
    // SOFT-DELETE — triggered by ContentNote after delete
    // ─────────────────────────────────────────────────────────────

    /**
     * Called from ContentNoteENRTrigger (after delete).
     * Marks related ENR records with Is_Note_Deleted__c = true so
     * reporting surfaces can filter / indicate deleted notes without
     * losing the parent-record row in the report.
     */
    public static void handleNoteDelete(List<ContentDocument> deletedDocs) {
        Set<String> noteIds = toStringSet(deletedDocs);

        List<Enhanced_Note_Reporting__c> toUpdate = [
            SELECT Id, Is_Note_Deleted__c, Last_Sync_Date__c
            FROM   Enhanced_Note_Reporting__c
            WHERE  Content_Document_ID__c IN :noteIds
        ];

        for (Enhanced_Note_Reporting__c enr : toUpdate) {
            enr.Is_Note_Deleted__c = true;
            enr.Last_Sync_Date__c  = System.now();
        }

        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }

    // ─────────────────────────────────────────────────────────────
    // UNDELETE — triggered by ContentNote after undelete
    // ─────────────────────────────────────────────────────────────

    /**
     * Called from ContentNoteENRTrigger (after undelete).
     * Restores ENR records: clears Is_Note_Deleted__c and re-syncs
     * current note data in case it was modified before undelete.
     */
    public static void handleNoteUndelete(List<ContentDocument> undeletedDocs) {
        Set<String> noteIds = toStringSet(undeletedDocs);

        // Reload note data from ContentVersion — more reliably populated than ContentNote.TextPreview
        Map<Id, ContentVersion> versionMap = new Map<Id, ContentVersion>();
        for (ContentVersion cv : [
            SELECT Id, ContentDocumentId, TextPreview, LastModifiedDate
            FROM   ContentVersion
            WHERE  ContentDocumentId IN :noteIds
            AND    IsLatest = true
            AND    FileType = 'SNOTE'
        ]) {
            versionMap.put(cv.ContentDocumentId, cv);
        }

        List<Enhanced_Note_Reporting__c> toUpdate = [
            SELECT Id, Content_Document_ID__c, Is_Note_Deleted__c,
                   Note_Preview__c, Note_Last_Modified_Date__c, Last_Sync_Date__c
            FROM   Enhanced_Note_Reporting__c
            WHERE  Content_Document_ID__c IN :noteIds
        ];

        for (Enhanced_Note_Reporting__c enr : toUpdate) {
            ContentVersion cv = versionMap.get(Id.valueOf(enr.Content_Document_ID__c));
            enr.Is_Note_Deleted__c = false;
            enr.Last_Sync_Date__c  = System.now();
            if (cv != null) {
                enr.Note_Preview__c            = cv.TextPreview;
                enr.Note_Last_Modified_Date__c = cv.LastModifiedDate;
            }
        }

        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }

    // ─────────────────────────────────────────────────────────────
    // HARD-DELETE — triggered by ContentDocumentLink after delete
    // ─────────────────────────────────────────────────────────────

    /**
     * Called from ContentDocumentLinkENRTrigger (after delete).
     * Permanently removes the ENR record when a note is unlinked
     * from a specific parent record (rather than the note itself deleted).
     *
     * Matches on BOTH Content_Document_ID__c AND Related_Record_ID__c so
     * that deleting a link on one parent does not affect ENR records
     * for other parents sharing the same note.
     */
    public static void handleCDLDelete(List<ContentDocumentLink> oldCDLs) {
        Set<String> contentDocIds  = new Set<String>();
        Set<String> linkedEntityIds = new Set<String>();

        for (ContentDocumentLink cdl : oldCDLs) {
            contentDocIds.add(String.valueOf(cdl.ContentDocumentId));
            linkedEntityIds.add(String.valueOf(cdl.LinkedEntityId));
        }

        List<Enhanced_Note_Reporting__c> toDelete = [
            SELECT Id
            FROM   Enhanced_Note_Reporting__c
            WHERE  Content_Document_ID__c IN :contentDocIds
            AND    Related_Record_ID__c    IN :linkedEntityIds
        ];

        if (!toDelete.isEmpty()) {
            delete toDelete;
        }
    }

    // ─────────────────────────────────────────────────────────────
    // PRIVATE HELPERS
    // ─────────────────────────────────────────────────────────────

    /**
     * Constructs a new Enhanced_Note_Reporting__c from a ContentNote
     * and its ContentDocumentLink. Sets the appropriate lookup field
     * (Contact__c, Lead__c, or Opportunity__c) based on parent type.
     */
    private static Enhanced_Note_Reporting__c buildENR(
        ContentNote note,
        ContentDocumentLink cdl
    ) {
        String sObjType = cdl.LinkedEntityId.getSObjectType().getDescribe().getName();

        Enhanced_Note_Reporting__c enr = new Enhanced_Note_Reporting__c(
            Content_Document_ID__c     = String.valueOf(cdl.ContentDocumentId),
            Enhanced_Note_ID__c        = String.valueOf(note.Id),
            Note_Preview__c            = note.TextPreview,
            Note_Created_Date__c       = note.CreatedDate,
            Note_Last_Modified_Date__c = note.LastModifiedDate,
            Is_Note_Deleted__c         = false,
            Last_Sync_Date__c          = System.now(),
            Related_Object_Name__c     = sObjType,
            Related_Record_ID__c       = String.valueOf(cdl.LinkedEntityId)
        );

        // Populate the typed lookup field for the parent object
        if (sObjType == 'Contact') {
            enr.Contact__c     = cdl.LinkedEntityId;
        } else if (sObjType == 'Lead') {
            enr.Lead__c        = cdl.LinkedEntityId;
        } else if (sObjType == 'Opportunity') {
            enr.Opportunity__c = cdl.LinkedEntityId;
        }

        return enr;
    }

    /**
     * Converts a list of ContentDocument records to a Set<String> of Id strings,
     * suitable for SOQL IN filters on String fields (Content_Document_ID__c).
     */
    private static Set<String> toStringSet(List<ContentDocument> docs) {
        Set<String> ids = new Set<String>();
        for (ContentDocument d : docs) {
            ids.add(String.valueOf(d.Id));
        }
        return ids;
    }
}