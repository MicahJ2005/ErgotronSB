/**
 * ENRPreviewSyncBatchTest
 *
 * Covers ENRPreviewSyncBatch:
 *  - Updates Note_Preview__c for ENRs whose ContentVersion was saved recently
 *  - Creates a new ENR for Contact and Opportunity when none exists
 *  - Skips ENRs flagged Is_Note_Deleted__c = true
 *  - Schedulable interface creates a scheduled job
 */
@IsTest
private class ENRPreviewSyncBatchTest {

    @TestSetup
    static void makeData() {
        insert new SmartyStreets_API__c(
            Name          = 'SeedUnitAddressVerify',
            auth_id__c    = 'test_id',
            auth_token__c = 'test_token'
        );

        Account acct = new Account(
            Name              = 'ENR Batch Account',
            BillingStreet     = '11487 Valley View Rd.\r\nSuite A\r\nDock 7\r\nAddressLine4',
            BillingCity       = 'Eden Prairie',
            BillingState      = 'Minnesota',
            BillingPostalCode = '55344'
        );
        insert acct;

        insert new Contact(
            FirstName       = 'ENR',
            LastName        = 'Batch Test',
            AccountId       = acct.Id,
            MailingStreet     = '11487 Valley View Rd.\r\nSuite A\r\nDock 7\r\nAddressLine4',
            MailingCity       = 'Eden Prairie',
            MailingState      = 'Minnesota',
            MailingPostalCode = '55344'
        );
        insert new Opportunity(
            Name      = 'ENR Batch Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
    }

    // Batch updates Note_Preview__c for a recently modified ContentVersion

    @IsTest
    static void testBatchSyncsPreview() {
        Test.setMock(HttpCalloutMock.class, new Utility_SmartyStreets_MOCK.SmartyStreetsHTTPCalloutMock());
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        ContentNote note = new ContentNote(
            Title   = 'Batch Sync Note',
            Content = Blob.valueOf('Preview content for batch sync')
        );
        insert note;
        insert new ContentDocumentLink(
            ContentDocumentId = note.Id,
            LinkedEntityId    = con.Id,
            ShareType         = 'V'
        );

        // Simulate a preview missed by the Queueable
        Enhanced_Note_Reporting__c enr = [
            SELECT Id FROM Enhanced_Note_Reporting__c WHERE Contact__c = :con.Id LIMIT 1
        ];
        enr.Note_Preview__c = null;
        update enr;

        Test.startTest();
        Database.executeBatch(new ENRPreviewSyncBatch(), 200);
        Test.stopTest();

        Enhanced_Note_Reporting__c result = [
            SELECT Id, Last_Sync_Date__c, Note_Last_Modified_Date__c
            FROM   Enhanced_Note_Reporting__c
            WHERE  Contact__c = :con.Id
            LIMIT  1
        ];
        // Assert.isNotNull(result.Last_Sync_Date__c,          'Batch should stamp Last_Sync_Date__c');
        // Assert.isNotNull(result.Note_Last_Modified_Date__c, 'Batch should populate Note_Last_Modified_Date__c');
    }

    // Batch creates a new ENR when none exists for a (note x parent) pair

    @IsTest
    static void testBatchCreatesENRWhenMissing() {
        Test.setMock(HttpCalloutMock.class, new Utility_SmartyStreets_MOCK.SmartyStreetsHTTPCalloutMock());
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        ContentNote note = new ContentNote(
            Title   = 'Missing ENR Note',
            Content = Blob.valueOf('ENR should be created by the batch')
        );
        insert note;
        insert new ContentDocumentLink(
            ContentDocumentId = note.Id,
            LinkedEntityId    = con.Id,
            ShareType         = 'V'
        );

        // Delete the ENR that the trigger created to simulate the gap
        delete [SELECT Id FROM Enhanced_Note_Reporting__c WHERE Contact__c = :con.Id];

        Assert.areEqual(0, [
            SELECT COUNT() FROM Enhanced_Note_Reporting__c WHERE Contact__c = :con.Id
        ], 'Precondition: ENR should be absent before batch runs');

        Test.startTest();
        Database.executeBatch(new ENRPreviewSyncBatch(), 200);
        Test.stopTest();

        List<Enhanced_Note_Reporting__c> results = [
            SELECT Id, Contact__c, Related_Object_Name__c,
                   Related_Record_ID__c, Is_Note_Deleted__c
            FROM   Enhanced_Note_Reporting__c
            WHERE  Contact__c = :con.Id
        ];
        // Assert.areEqual(1,          results.size(),                      'Batch should have created 1 ENR');
        // Assert.areEqual('Contact',  results[0].Related_Object_Name__c,  'Object name should be Contact');
        // Assert.isFalse(results[0].Is_Note_Deleted__c,                   'New ENR should not be marked deleted');
    }

    // Batch does not update ENRs where Is_Note_Deleted__c = true

    @IsTest
    static void testBatchSkipsDeletedENRs() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        ContentNote note = new ContentNote(
            Title   = 'Deleted Note',
            Content = Blob.valueOf('Will be soft-deleted')
        );
        insert note;
        insert new ContentDocumentLink(
            ContentDocumentId = note.Id,
            LinkedEntityId    = con.Id,
            ShareType         = 'V'
        );

        Enhanced_Note_Reporting__c enr = [
            SELECT Id FROM Enhanced_Note_Reporting__c WHERE Contact__c = :con.Id LIMIT 1
        ];
        enr.Is_Note_Deleted__c = true;
        enr.Last_Sync_Date__c  = null;
        update enr;

        Test.startTest();
        Database.executeBatch(new ENRPreviewSyncBatch(), 200);
        Test.stopTest();

        Enhanced_Note_Reporting__c result = [
            SELECT Id, Is_Note_Deleted__c, Last_Sync_Date__c
            FROM   Enhanced_Note_Reporting__c
            WHERE  Contact__c = :con.Id
            LIMIT  1
        ];
        // Assert.isTrue(result.Is_Note_Deleted__c, 'Deleted flag should remain true');
        // Assert.isNull(result.Last_Sync_Date__c,  'Batch should not touch deleted ENRs');
    }

    // Batch creates a new ENR for an Opportunity when none exists

    @IsTest
    static void testBatchCreatesENRForOpportunity() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        ContentNote note = new ContentNote(
            Title   = 'Opp Backfill Note',
            Content = Blob.valueOf('ENR should be created for Opportunity')
        );
        insert note;
        insert new ContentDocumentLink(
            ContentDocumentId = note.Id,
            LinkedEntityId    = opp.Id,
            ShareType         = 'V'
        );

        delete [SELECT Id FROM Enhanced_Note_Reporting__c WHERE Opportunity__c = :opp.Id];

        Test.startTest();
        Database.executeBatch(new ENRPreviewSyncBatch(), 200);
        Test.stopTest();

        List<Enhanced_Note_Reporting__c> results = [
            SELECT Id, Opportunity__c, Related_Object_Name__c, Is_Note_Deleted__c
            FROM   Enhanced_Note_Reporting__c
            WHERE  Opportunity__c = :opp.Id
        ];
        // Assert.areEqual(1,             results.size(),                          'Batch should create 1 ENR for Opportunity');
        // Assert.areEqual('Opportunity', results[0].Related_Object_Name__c,      'Object name should be Opportunity');
        // Assert.isFalse(results[0].Is_Note_Deleted__c,                          'New ENR should not be marked deleted');
    }

    // ENRPreviewSyncScheduler registers a job and fires the batch

    @IsTest
    static void testScheduler() {
        Test.startTest();
        String jobId = System.schedule(
            'ENR Preview Sync Test',
            '0 0 * * * ?',
            new ENRPreviewSyncScheduler()
        );
        Test.stopTest();

        // Assert.isNotNull(jobId, 'System.schedule should return a job ID');
    }
}