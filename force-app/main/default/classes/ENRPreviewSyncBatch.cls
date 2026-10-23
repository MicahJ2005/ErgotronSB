/**
 * ENRPreviewSyncBatch
 *
 * Hourly batch to sync Note_Preview__c on Enhanced_Note_Reporting__c records
 * for any ContentNote saved in the last 2 hours.
 *
 * Scoped to ContentVersion so that LastModifiedDate is Salesforce's authoritative
 * save timestamp, independent of whether our sync logic ever ran. For each
 * ContentVersion in scope, the batch:
 *   - Updates Note_Preview__c on existing non-deleted ENR records
 *   - Creates new ENR records for any (note x parent) pair with no existing record,
 *     acting as a backfill if the ContentDocumentLink trigger was ever missed
 *
 * Scheduled via ENRPreviewSyncScheduler (Setup > Apex Classes > Schedule Apex),
 * or via Execute Anonymous:
 *   System.schedule('ENR Preview Sync - Hourly', '0 0 * * * ?',
 *                   new ENRPreviewSyncScheduler());
 */
public class ENRPreviewSyncBatch implements Database.Batchable<SObject> {

    private static final Set<String> SUPPORTED_OBJECTS = new Set<String>{
        'Contact', 'Lead', 'Opportunity'
    };

    public Database.QueryLocator start(Database.BatchableContext ctx) {
        DateTime twoHoursAgo = System.now().addHours(-2);
        return Database.getQueryLocator([
            SELECT Id, ContentDocumentId, TextPreview, LastModifiedDate
            FROM   ContentVersion
            WHERE  LastModifiedDate >= :twoHoursAgo
            AND    IsLatest          = true
            AND    FileType          = 'SNOTE'
        ]);
    }

    public void execute(Database.BatchableContext ctx, List<ContentVersion> scope) {
        Map<Id, ContentVersion> versionByDocId = new Map<Id, ContentVersion>();
        Set<String> docIdStrings = new Set<String>();
        for (ContentVersion cv : scope) {
            versionByDocId.put(cv.ContentDocumentId, cv);
            docIdStrings.add(String.valueOf(cv.ContentDocumentId));
        }

        // Query ALL existing ENR records (including soft-deleted) to detect gaps
        // and prevent duplicates. Key: "ContentDocumentId|LinkedEntityId"
        Map<String, Enhanced_Note_Reporting__c> existingByKey = new Map<String, Enhanced_Note_Reporting__c>();
        for (Enhanced_Note_Reporting__c enr : [
            SELECT Id, Content_Document_ID__c, Related_Record_ID__c, Is_Note_Deleted__c
            FROM   Enhanced_Note_Reporting__c
            WHERE  Content_Document_ID__c IN :docIdStrings
        ]) {
            existingByKey.put(
                enr.Content_Document_ID__c + '|' + enr.Related_Record_ID__c, enr
            );
        }

        // ContentDocumentLinks tell us which parent records each note is linked to
        List<ContentDocumentLink> relevantCDLs = new List<ContentDocumentLink>();
        for (ContentDocumentLink cdl : [
            SELECT ContentDocumentId, LinkedEntityId
            FROM   ContentDocumentLink
            WHERE  ContentDocumentId IN :versionByDocId.keySet()
        ]) {
            String sObjType = cdl.LinkedEntityId.getSObjectType().getDescribe().getName();
            if (SUPPORTED_OBJECTS.contains(sObjType)) {
                relevantCDLs.add(cdl);
            }
        }

        // ContentNote.CreatedDate is needed when building new ENR records
        Map<Id, ContentNote> noteMap = new Map<Id, ContentNote>([
            SELECT Id, CreatedDate
            FROM   ContentNote
            WHERE  Id IN :versionByDocId.keySet()
        ]);

        List<Enhanced_Note_Reporting__c> toUpdate = new List<Enhanced_Note_Reporting__c>();
        List<Enhanced_Note_Reporting__c> toInsert = new List<Enhanced_Note_Reporting__c>();

        for (ContentDocumentLink cdl : relevantCDLs) {
            ContentVersion cv = versionByDocId.get(cdl.ContentDocumentId);
            if (cv == null || cv.TextPreview == null) { continue; }

            String docIdStr    = String.valueOf(cdl.ContentDocumentId);
            String parentIdStr = String.valueOf(cdl.LinkedEntityId);
            String key         = docIdStr + '|' + parentIdStr;
            String sObjType    = cdl.LinkedEntityId.getSObjectType().getDescribe().getName();

            Enhanced_Note_Reporting__c enr = existingByKey.get(key);

            if (enr != null) {
                if (enr.Is_Note_Deleted__c) { continue; } // soft-deleted — leave it alone
                enr.Note_Preview__c            = cv.TextPreview;
                enr.Note_Last_Modified_Date__c = cv.LastModifiedDate;
                enr.Last_Sync_Date__c          = System.now();
                toUpdate.add(enr);
            } else {
                // No ENR for this (note x parent) pair — create one
                ContentNote note = noteMap.get(cdl.ContentDocumentId);
                Enhanced_Note_Reporting__c newEnr = new Enhanced_Note_Reporting__c(
                    Content_Document_ID__c     = docIdStr,
                    Enhanced_Note_ID__c        = docIdStr,
                    Note_Preview__c            = cv.TextPreview,
                    Note_Created_Date__c       = note != null ? note.CreatedDate : null,
                    Note_Last_Modified_Date__c = cv.LastModifiedDate,
                    Is_Note_Deleted__c         = false,
                    Last_Sync_Date__c          = System.now(),
                    Related_Object_Name__c     = sObjType,
                    Related_Record_ID__c       = parentIdStr
                );
                if (sObjType == 'Contact') {
                    newEnr.Contact__c     = cdl.LinkedEntityId;
                } else if (sObjType == 'Lead') {
                    newEnr.Lead__c        = cdl.LinkedEntityId;
                } else if (sObjType == 'Opportunity') {
                    newEnr.Opportunity__c = cdl.LinkedEntityId;
                }
                toInsert.add(newEnr);
            }
        }

        if (!toUpdate.isEmpty()) { update toUpdate; }
        if (!toInsert.isEmpty()) { insert toInsert; }
    }

    public void finish(Database.BatchableContext ctx) { }
}