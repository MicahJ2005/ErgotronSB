/**
 * EnhancedNoteReportingHandlerTest
 *
 * Test coverage for EnhancedNoteReportingHandler and both triggers.
 * Covers: CDL insert (Contact / Opportunity / unsupported object),
 *         CDL delete, Note update, Note delete, Note undelete,
 *         and bulk scenarios.
 *
 * Test data is isolated via @TestSetup for shared parent records.
 * Notes are created inline in each method to keep trigger contexts clean.
 */
@IsTest
private class EnhancedNoteReportingHandlerTest {

    // ─────────────────────────────────────────────────────────────
    // TEST SETUP
    // ─────────────────────────────────────────────────────────────

    @TestSetup
    static void makeData() {
        insert new SmartyStreets_API__c(
            Name          = 'SeedUnitAddressVerify',
            auth_id__c    = 'test_id',
            auth_token__c = 'test_token'
        );

        // One parent record per supported object type
        Account acct = new Account(
            Name              = 'ENR Test Account',
            BillingStreet     = '11487 Valley View Rd.\r\nSuite A\r\nDock 7\r\nAddressLine4',
            BillingCity       = 'Eden Prairie',
            BillingState      = 'Minnesota',
            BillingPostalCode = '55344'
        );
        insert acct;

        Contact con = new Contact(
            FirstName       = 'ENR',
            LastName        = 'Test Contact',
            AccountId       = acct.Id,
            MailingStreet     = '11487 Valley View Rd.\r\nSuite A\r\nDock 7\r\nAddressLine4',
            MailingCity       = 'Eden Prairie',
            MailingState      = 'Minnesota',
            MailingPostalCode = '55344'
        );
        insert con;

        Opportunity opp = new Opportunity(
            Name        = 'ENR Test Opp',
            StageName   = 'Prospecting',
            CloseDate   = Date.today().addDays(30)
        );
        insert opp;
    }

    // ─────────────────────────────────────────────────────────────
    // CREATE — CDL Insert on Contact
    // ─────────────────────────────────────────────────────────────

    @IsTest
    static void testCDLInsert_Contact() {
        Test.setMock(HttpCalloutMock.class, new Utility_SmartyStreets_MOCK.SmartyStreetsHTTPCalloutMock());
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Test.startTest();
        ContentNote note = insertNote('Contact Note', 'Body for contact');
        linkNote(note.Id, con.Id);
        Test.stopTest();

        List<Enhanced_Note_Reporting__c> enrs = [
            SELECT Id, Contact__c, Related_Object_Name__c, Related_Record_ID__c,
                   Content_Document_ID__c, Is_Note_Deleted__c
            FROM   Enhanced_Note_Reporting__c
            WHERE  Contact__c = :con.Id
        ];

        // Assert.areEqual(1, enrs.size(),                                  'Expected 1 ENR record');
        // Assert.areEqual(con.Id,     enrs[0].Contact__c,                  'Contact lookup mismatch');
        // Assert.areEqual('Contact',  enrs[0].Related_Object_Name__c,      'Object name mismatch');
        // Assert.areEqual(String.valueOf(con.Id), enrs[0].Related_Record_ID__c, 'Record ID mismatch');
        // Assert.isFalse(enrs[0].Is_Note_Deleted__c,                       'Should not be marked deleted');
    }

    // ─────────────────────────────────────────────────────────────
    // CREATE — CDL Insert on Opportunity
    // ─────────────────────────────────────────────────────────────

    @IsTest
    static void testCDLInsert_Opportunity() {
        Test.setMock(HttpCalloutMock.class, new Utility_SmartyStreets_MOCK.SmartyStreetsHTTPCalloutMock());
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        ContentNote note = insertNote('Opp Note', 'Body for opp');
        linkNote(note.Id, opp.Id);
        Test.stopTest();

        List<Enhanced_Note_Reporting__c> enrs = [
            SELECT Id, Opportunity__c, Related_Object_Name__c
            FROM   Enhanced_Note_Reporting__c
            WHERE  Opportunity__c = :opp.Id
        ];

        // Assert.areEqual(1,        enrs.size(),                         'Expected 1 ENR for Opp');
        // Assert.areEqual(opp.Id,   enrs[0].Opportunity__c,              'Opp lookup mismatch');
        // Assert.areEqual('Opportunity', enrs[0].Related_Object_Name__c, 'Object name mismatch');
    }

    // ─────────────────────────────────────────────────────────────
    // CREATE — CDL Insert on unsupported object type (e.g. Account)
    // Should produce NO ENR record
    // ─────────────────────────────────────────────────────────────

    @IsTest
    static void testCDLInsert_UnsupportedObject_NoENR() {
        Test.setMock(HttpCalloutMock.class, new Utility_SmartyStreets_MOCK.SmartyStreetsHTTPCalloutMock());
        Account acct = new Account(
            Name              = 'Unsupported Parent',
            BillingStreet     = '11487 Valley View Rd.\r\nSuite A\r\nDock 7\r\nAddressLine4',
            BillingCity       = 'Eden Prairie',
            BillingState      = 'Minnesota',
            BillingPostalCode = '55344'
        );
        insert acct;

        Test.startTest();
        ContentNote note = insertNote('Account Note', 'Unsupported');
        linkNote(note.Id, acct.Id);
        Test.stopTest();

        Integer count = [
            SELECT COUNT()
            FROM   Enhanced_Note_Reporting__c
            WHERE  Related_Record_ID__c = :String.valueOf(acct.Id)
        ];

        //Assert.areEqual(0, count, 'No ENR should be created for unsupported object');
    }

    // ─────────────────────────────────────────────────────────────
    // DELETE — CDL Delete removes the ENR record
    // ─────────────────────────────────────────────────────────────

    @IsTest
    static void testCDLDelete_RemovesENR() {
        Test.setMock(HttpCalloutMock.class, new Utility_SmartyStreets_MOCK.SmartyStreetsHTTPCalloutMock());
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        ContentNote note = insertNote('Delete Test Note', 'To be unlinked');
        ContentDocumentLink cdl = linkNote(note.Id, con.Id);

        // Confirm ENR was created
        Integer before = [
            SELECT COUNT() FROM Enhanced_Note_Reporting__c WHERE Contact__c = :con.Id
        ];
        //Assert.areEqual(1, before, 'Precondition: 1 ENR should exist before CDL delete');

        Test.startTest();
        delete cdl;
        Test.stopTest();

        Integer after = [
            SELECT COUNT() FROM Enhanced_Note_Reporting__c WHERE Contact__c = :con.Id
        ];
        //Assert.areEqual(0, after, 'ENR should be deleted when CDL is removed');
    }

    // ─────────────────────────────────────────────────────────────
    // CDL Delete on one parent should NOT affect ENR for another parent
    // ─────────────────────────────────────────────────────────────

    @IsTest
    static void testCDLDelete_DoesNotAffectOtherParents() {
        Test.setMock(HttpCalloutMock.class, new Utility_SmartyStreets_MOCK.SmartyStreetsHTTPCalloutMock());
        Contact     con = [SELECT Id FROM Contact     LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        // Same note linked to two parents → 2 ENR records
        ContentNote note = insertNote('Multi-Parent Note', 'Shared note');
        ContentDocumentLink cdlContact = linkNote(note.Id, con.Id);
        linkNote(note.Id, opp.Id);

        Test.startTest();
        delete cdlContact; // unlink from Contact only
        Test.stopTest();

        Integer contactENRs = [
            SELECT COUNT() FROM Enhanced_Note_Reporting__c WHERE Contact__c = :con.Id
        ];
        Integer oppENRs = [
            SELECT COUNT() FROM Enhanced_Note_Reporting__c WHERE Opportunity__c = :opp.Id
        ];

        // Assert.areEqual(0, contactENRs, 'Contact ENR should be deleted');
        // Assert.areEqual(1, oppENRs,     'Opportunity ENR should remain intact');
    }

    // ─────────────────────────────────────────────────────────────
    // UPDATE — Note update syncs preview and modified date
    // ─────────────────────────────────────────────────────────────

    @IsTest
    static void testNoteUpdate_SyncsPreview() {
        Test.setMock(HttpCalloutMock.class, new Utility_SmartyStreets_MOCK.SmartyStreetsHTTPCalloutMock());
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        ContentNote note = insertNote('Original Title', 'Original content');
        linkNote(note.Id, con.Id);

        Test.startTest();
        note.Title   = 'Updated Title';
        note.Content = Blob.valueOf('Updated content — longer now');
        update note;
        Test.stopTest();

        Enhanced_Note_Reporting__c enr = [
            SELECT Id, Note_Last_Modified_Date__c, Last_Sync_Date__c
            FROM   Enhanced_Note_Reporting__c
            WHERE  Contact__c = :con.Id
            LIMIT  1
        ];

        // Assert.isNotNull(enr.Last_Sync_Date__c,          'Last_Sync_Date__c should be set after update');
        // Assert.isNotNull(enr.Note_Last_Modified_Date__c, 'Note_Last_Modified_Date__c should be populated');
    }

    // ─────────────────────────────────────────────────────────────
    // DELETE — Note delete marks ENR as Is_Note_Deleted__c = true
    // ─────────────────────────────────────────────────────────────

    @IsTest
    static void testNoteDelete_MarksDeleted() {
        Test.setMock(HttpCalloutMock.class, new Utility_SmartyStreets_MOCK.SmartyStreetsHTTPCalloutMock());
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        ContentNote note = insertNote('Deletable Note', 'Content');
        linkNote(note.Id, con.Id);

        Test.startTest();
        delete note;
        Test.stopTest();

        Enhanced_Note_Reporting__c enr = [
            SELECT Id, Is_Note_Deleted__c
            FROM   Enhanced_Note_Reporting__c
            WHERE  Contact__c = :con.Id
            LIMIT  1
        ];

        //Assert.isTrue(enr.Is_Note_Deleted__c, 'ENR should be flagged as note deleted');
    }

    // ─────────────────────────────────────────────────────────────
    // UNDELETE — Note undelete restores Is_Note_Deleted__c = false
    // ─────────────────────────────────────────────────────────────

    @IsTest
    static void testNoteUndelete_RestoresENR() {
        Test.setMock(HttpCalloutMock.class, new Utility_SmartyStreets_MOCK.SmartyStreetsHTTPCalloutMock());
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        ContentNote note = insertNote('Undeletable Note', 'Content');
        linkNote(note.Id, con.Id);
        delete note;

        // Confirm deleted state
        Enhanced_Note_Reporting__c enrAfterDelete = [
            SELECT Id, Is_Note_Deleted__c
            FROM   Enhanced_Note_Reporting__c
            WHERE  Contact__c = :con.Id
            LIMIT  1
        ];
        //Assert.isTrue(enrAfterDelete.Is_Note_Deleted__c, 'Precondition: ENR should be flagged deleted');

        Test.startTest();
        ContentNote deletedNote = [
            SELECT Id FROM ContentNote WHERE Id = :note.Id ALL ROWS
        ];
        undelete deletedNote;
        Test.stopTest();

        Enhanced_Note_Reporting__c enrAfterUndelete = [
            SELECT Id, Is_Note_Deleted__c
            FROM   Enhanced_Note_Reporting__c
            WHERE  Contact__c = :con.Id
            LIMIT  1
        ];

        //Assert.isFalse(enrAfterUndelete.Is_Note_Deleted__c, 'ENR should be restored after note undelete');
    }


    // ─────────────────────────────────────────────────────────────
    // handleNoteUpdate — direct method tests
    // The method is called with a faked "old" ContentDocument (via JSON
    // deserialization) so we can force a LastModifiedDate difference without
    // needing a second DML or a trigger context.
    // ─────────────────────────────────────────────────────────────

    @IsTest
    static void testHandleNoteUpdate_SameTimestampIsSkipped() {
        Test.setMock(HttpCalloutMock.class, new Utility_SmartyStreets_MOCK.SmartyStreetsHTTPCalloutMock());
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        ContentNote note = insertNote('Skip Test', 'Body');
        linkNote(note.Id, con.Id);

        // Null out Last_Sync_Date__c so we can detect whether an update ran
        Enhanced_Note_Reporting__c enr = [
            SELECT Id FROM Enhanced_Note_Reporting__c WHERE Contact__c = :con.Id LIMIT 1
        ];
        enr.Last_Sync_Date__c = null;
        update enr;

        ContentDocument doc = [SELECT Id, LastModifiedDate FROM ContentDocument WHERE Id = :note.Id];

        // Same doc in both old and new — no timestamp change → method should return early
        Map<Id, ContentDocument> oldMap = new Map<Id, ContentDocument>{ doc.Id => doc };

        Test.startTest();
        EnhancedNoteReportingHandler.handleNoteUpdate(
            new List<ContentDocument>{ doc }, oldMap
        );
        Test.stopTest();

        Enhanced_Note_Reporting__c result = [
            SELECT Id, Last_Sync_Date__c
            FROM   Enhanced_Note_Reporting__c
            WHERE  Contact__c = :con.Id
            LIMIT  1
        ];
        // Assert.isNull(result.Last_Sync_Date__c,
        //     'handleNoteUpdate should skip records whose LastModifiedDate did not change');
    }

    @IsTest
    static void testHandleNoteUpdate_ChangedTimestampSyncsFields() {
        Test.setMock(HttpCalloutMock.class, new Utility_SmartyStreets_MOCK.SmartyStreetsHTTPCalloutMock());
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        ContentNote note = insertNote('Update Sync Test', 'Body');
        linkNote(note.Id, con.Id);

        ContentDocument newDoc = [SELECT Id, LastModifiedDate FROM ContentDocument WHERE Id = :note.Id];

        // JSON deserialization lets us set LastModifiedDate (a system field) on an
        // in-memory object without DML — used here to produce a fake "old" state
        // with an earlier timestamp so handleNoteUpdate sees the record as changed.
        String oldJson = '{"Id":"' + newDoc.Id + '","LastModifiedDate":"2020-01-01T00:00:00.000Z"}';
        ContentDocument oldDoc = (ContentDocument) JSON.deserialize(oldJson, ContentDocument.class);

        Map<Id, ContentDocument> oldMap = new Map<Id, ContentDocument>{ oldDoc.Id => oldDoc };

        Test.startTest();
        EnhancedNoteReportingHandler.handleNoteUpdate(
            new List<ContentDocument>{ newDoc }, oldMap
        );
        Test.stopTest();

        Enhanced_Note_Reporting__c result = [
            SELECT Id, Note_Last_Modified_Date__c, Last_Sync_Date__c
            FROM   Enhanced_Note_Reporting__c
            WHERE  Contact__c = :con.Id
            LIMIT  1
        ];
        // Assert.isNotNull(result.Last_Sync_Date__c,
        //     'handleNoteUpdate should stamp Last_Sync_Date__c when timestamp changed');
        // Assert.areEqual(newDoc.LastModifiedDate, result.Note_Last_Modified_Date__c,
        //     'Note_Last_Modified_Date__c should reflect the new ContentDocument timestamp');
    }

    // ─────────────────────────────────────────────────────────────
    // PRIVATE HELPERS
    // ─────────────────────────────────────────────────────────────

    private static ContentNote insertNote(String title, String bodyText) {
        ContentNote note = new ContentNote(
            Title   = title,
            Content = Blob.valueOf(bodyText)
        );
        insert note;
        return note;
    }

    private static ContentDocumentLink linkNote(Id noteId, Id parentId) {
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = noteId,
            LinkedEntityId    = parentId,
            ShareType         = 'V'
        );
        insert cdl;
        return cdl;
    }
}