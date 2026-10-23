public with sharing class EnhancedNoteMigrationBatch
    implements Database.Batchable<SObject>, Database.Stateful {

    public Integer recordsProcessed = 0;
    public Integer recordsFailed = 0;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id,
                   Target_Record_Id__c,
                   Note_Title__c,
                   Note_Content__c,
                   Processing_Status__c
            FROM Enhanced_Note_Migration_Staging__c
            WHERE Processing_Status__c = 'Pending'
        ]);
    }

    public void execute(
        Database.BatchableContext bc,
        List<Enhanced_Note_Migration_Staging__c> stagingRecords
    ) {
        if (stagingRecords.isEmpty()) {
            return;
        }

        List<ContentNote> notesToInsert = new List<ContentNote>();

        Map<Integer, Enhanced_Note_Migration_Staging__c> indexToStageMap =
            new Map<Integer, Enhanced_Note_Migration_Staging__c>();

        Integer idx = 0;

        for (Enhanced_Note_Migration_Staging__c stage : stagingRecords) {
            ContentNote note = new ContentNote(
                Title = stage.Note_Title__c,
                Content = Blob.valueOf(
                    String.isBlank(stage.Note_Content__c)
                        ? ''
                        : stage.Note_Content__c
                )
            );

            notesToInsert.add(note);
            indexToStageMap.put(idx, stage);

            idx++;
        }

        Database.SaveResult[] noteResults =
            Database.insert(notesToInsert, false);

        List<ContentDocumentLink> linksToInsert =
            new List<ContentDocumentLink>();

        List<Enhanced_Note_Migration_Staging__c> stagingUpdates =
            new List<Enhanced_Note_Migration_Staging__c>();

        for (Integer i = 0; i < noteResults.size(); i++) {
            Enhanced_Note_Migration_Staging__c stage =
                indexToStageMap.get(i);

            if (noteResults[i].isSuccess()) {
                stage.Enhanced_Note_Id__c =
                    String.valueOf(noteResults[i].getId());
            } else {
                stage.Processing_Status__c = 'Error';

                String errorMsg = '';

                for (Database.Error err : noteResults[i].getErrors()) {
                    errorMsg += err.getMessage() + ' ';
                }

                stage.Processing_Error__c =
                    errorMsg.left(Math.min(errorMsg.length(), 255));

                recordsFailed++;
                stagingUpdates.add(stage);
            }
        }

        for (Integer i = 0; i < noteResults.size(); i++) {
            if (!noteResults[i].isSuccess()) {
                continue;
            }

            Enhanced_Note_Migration_Staging__c stage =
                indexToStageMap.get(i);

            linksToInsert.add(
                new ContentDocumentLink(
                    ContentDocumentId = noteResults[i].getId(),
                    LinkedEntityId = stage.Target_Record_Id__c,
                    ShareType = 'V',
                    Visibility = 'AllUsers'
                )
            );
        }

        Database.SaveResult[] linkResults =
            Database.insert(linksToInsert, false);

        Integer linkIndex = 0;

        for (Integer i = 0; i < noteResults.size(); i++) {
            if (!noteResults[i].isSuccess()) {
                continue;
            }

            Enhanced_Note_Migration_Staging__c stage =
                indexToStageMap.get(i);

            if (linkResults[linkIndex].isSuccess()) {
                stage.Processing_Status__c = 'Processed';
                stage.Processing_Error__c = null;

                recordsProcessed++;
            } else {
                stage.Processing_Status__c = 'Error';

                String errorMsg = '';

                for (Database.Error err : linkResults[linkIndex].getErrors()) {
                    errorMsg += err.getMessage() + ' ';
                }

                stage.Processing_Error__c =
                    errorMsg.left(Math.min(errorMsg.length(), 255));

                recordsFailed++;
            }

            stagingUpdates.add(stage);
            linkIndex++;
        }

        if (!stagingUpdates.isEmpty()) {
            Database.update(stagingUpdates, false);
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Enhanced Note Migration Batch Complete');
        System.debug('Records Processed: ' + recordsProcessed);
        System.debug('Records Failed: ' + recordsFailed);
    }
}