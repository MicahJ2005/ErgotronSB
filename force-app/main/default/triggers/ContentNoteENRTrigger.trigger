/**
 * ContentNoteENRTrigger
 *
 * Fires when a ContentDocument (Enhanced Note) is updated, deleted, or undeleted.
 * Filters to FileType = 'SNOTE' so only ContentNote records are processed.
 * - Update  → syncs preview text and modified date on related ENR records
 * - Delete  → marks related ENR records as Is_Note_Deleted__c = true
 * - Undelete → restores related ENR records (Is_Note_Deleted__c = false)
 *
 * Note: ContentNote does not support triggers directly; ContentDocument is used
 * as the surrogate. ContentNote insert is handled via ContentDocumentLink (after insert).
 */
trigger ContentNoteENRTrigger on ContentDocument (after update, after delete, after undelete) {
    if (Trigger.isAfter) {
        List<ContentDocument> notes    = new List<ContentDocument>();
        Map<Id, ContentDocument> oldMap = new Map<Id, ContentDocument>();

        List<ContentDocument> source = Trigger.isDelete ? Trigger.old : Trigger.new;
        for (ContentDocument cd : source) {
            if (cd.FileType == 'SNOTE') {
                notes.add(cd);
                if (Trigger.isUpdate) {
                    oldMap.put(cd.Id, Trigger.oldMap.get(cd.Id));
                }
            }
        }
        if (notes.isEmpty()) { return; }

        if (Trigger.isUpdate) {
            EnhancedNoteReportingHandler.handleNoteUpdate(notes, oldMap);
        } else if (Trigger.isDelete) {
            EnhancedNoteReportingHandler.handleNoteDelete(notes);
        } else if (Trigger.isUndelete) {
            EnhancedNoteReportingHandler.handleNoteUndelete(notes);
        }
    }
}