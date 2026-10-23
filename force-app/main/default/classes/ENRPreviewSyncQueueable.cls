/**
 * ENRPreviewSyncQueueable
 *
 * Best-effort sync of Note_Preview__c after a ContentNote is created or saved.
 * Runs after the triggering transaction commits, giving Salesforce a moment to
 * generate ContentVersion.TextPreview. If TextPreview is still null at execution
 * time, the record is skipped — ENRPreviewSyncBatch (scheduled hourly) acts as
 * the reliable safety net and will catch it on its next run.
 *
 * The previous retry-with-delay approach was removed because:
 *  - Rapid auto-saves produce many Queueables that pile up in the Flex Queue
 *  - On retry exhaustion, null was incorrectly written to Note_Preview__c
 *  - The hourly batch makes multi-attempt Queueable chains unnecessary
 */
public class ENRPreviewSyncQueueable implements Queueable {

    private Set<Id> contentDocIds;

    public ENRPreviewSyncQueueable(Set<Id> contentDocIds) {
        this.contentDocIds = contentDocIds;
    }

    public void execute(QueueableContext ctx) {
        Map<Id, ContentVersion> versionByDocId = new Map<Id, ContentVersion>();
        for (ContentVersion cv : [
            SELECT Id, ContentDocumentId, TextPreview, LastModifiedDate
            FROM   ContentVersion
            WHERE  ContentDocumentId IN :contentDocIds
            AND    IsLatest = true
            AND    FileType = 'SNOTE'
        ]) {
            versionByDocId.put(cv.ContentDocumentId, cv);
        }
        if (versionByDocId.isEmpty()) { return; }

        Set<String> docIdStrings = new Set<String>();
        for (Id docId : contentDocIds) {
            docIdStrings.add(String.valueOf(docId));
        }

        List<Enhanced_Note_Reporting__c> toUpdate = new List<Enhanced_Note_Reporting__c>();
        for (Enhanced_Note_Reporting__c enr : [
            SELECT Id, Content_Document_ID__c
            FROM   Enhanced_Note_Reporting__c
            WHERE  Content_Document_ID__c IN :docIdStrings
        ]) {
            ContentVersion cv = versionByDocId.get(Id.valueOf(enr.Content_Document_ID__c));
            if (cv == null || cv.TextPreview == null) { continue; } // batch will catch it
            enr.Note_Preview__c            = cv.TextPreview;
            enr.Note_Last_Modified_Date__c = cv.LastModifiedDate;
            enr.Last_Sync_Date__c          = System.now();
            toUpdate.add(enr);
        }

        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }
}