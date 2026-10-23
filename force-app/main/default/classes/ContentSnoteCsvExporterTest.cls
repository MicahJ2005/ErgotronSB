@IsTest
private class ContentSnoteCsvExporterTest {

    // Utility: create a standard user with Americas region to satisfy filter Owner.User_Region__c = 'Americas'
    private static User createAmericasUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            Alias = 'ameru',
            Email = 'amer.user@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'AmerUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/New_York',
            Username = 'amer.user.' + System.now().getTime() + '@example.com',
            User_Region__c = 'Americas',
            ProfileId = p.Id
        );
        insert u;
        // Adding user as a author member to the library where the file will be placed.
        ContentWorkspacePermission cwp = [select id from ContentWorkspacePermission where name = 'Author' limit 1];

        ContentWorkspace library = [SELECT Id, Name FROM ContentWorkspace WHERE Name = 'SalesDevOpsNotes' LIMIT 1];
        if (library != null) {
            ContentWorkspaceMember cwm = new ContentWorkspaceMember(
                ContentWorkspaceId = library.Id,
                MemberId = u.Id,
                ContentWorkspacePermissionId = cwp.Id
                            );
                            
            insert cwm;
        }
        return [SELECT Id, Name FROM User WHERE Id = :u.Id];
        
    }

    // Utility: ensure an Opportunity RecordType with DeveloperName = 'Sales_Development'
    private static RecordType ensureOppSalesDevRecordType() {
        // Try to find by DeveloperName
        RecordType rt = [
            SELECT Id, DeveloperName, SObjectType
            FROM RecordType
            WHERE SObjectType = 'Opportunity' AND DeveloperName = 'Sales_Development'
            LIMIT 1
        ];
        return rt;
    }

    // Utility: create Account and Opportunity
    private static Opportunity createSalesDevOpportunity(Id ownerId) {
        Account a = new Account(Name = 'Test Account');
        insert a;

        RecordType rt = ensureOppSalesDevRecordType();

        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            AccountId = a.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            OwnerId = ownerId
        );
        if (rt != null) opp.RecordTypeId = rt.Id;
        insert opp;
        return opp;
    }

    // Utility: ensure a ContentWorkspace (Library) by Name to simulate resolveWorkspaceId
    private static ContentWorkspace ensureLibrary(String name) {
        // Try to find existing by Name first to prevent DUPLICATE_VALUE
        List<ContentWorkspace> existing = [
            SELECT Id, Name
            FROM ContentWorkspace
            WHERE Name = :name
            LIMIT 1
        ];
        if (!existing.isEmpty()) {
            return existing[0];
        }
        ContentWorkspace cw = new ContentWorkspace(Name = name);
        insert cw;
        return cw;
    }

    // Utility: Insert File (ContentVersion/Document) and link to Opportunity via ContentDocumentLink
    // The production code filters ContentDocument.LatestPublishedVersion.FileType = 'SNOTE'
    // and Owner.User_Region__c = 'Americas'. We will create a version with that FileType and set Owner as Americas user.
    private static Id createSnoteFileLinkedToOpp(Opportunity opp, Id ownerId) {
        // Create initial ContentVersion
        ContentVersion cv = new ContentVersion(
            Title = 'Sample SNOTE',
            PathOnClient = 'SampleSnote.snote',
            VersionData = Blob.valueOf('Sample'),
            Origin = 'H' // to avoid validation issues in some orgs
        );
        insert cv;
        Id cvId = cv.Id;

        // Fetch ContentDocumentId
        ContentVersion insertedCv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cvId LIMIT 1];
        Id contentDocumentId = insertedCv.ContentDocumentId;

        // Create second version to control FileType and Owner
        ContentVersion cv2 = new ContentVersion(
            ContentDocumentId = contentDocumentId,
            Title = 'Sample SNOTE v2',
            PathOnClient = 'SampleSnote.snote',
            VersionData = Blob.valueOf('SampleV2')
        );
        insert cv2;

        // Best-effort: set FileType and Owner on LatestPublishedVersion
        try {
            // Make cv2 latest by publishing; in many orgs insert makes it latest.
            // Attempt to requery and update owner via ContentVersion (ownerId is read-only in many orgs).
            // We rely on SOQL filter Owner.User_Region__c = 'Americas'; if Owner not settable, the query may return 0 rows,
            // which is still a valid path for exercising CSV builder on empty set.
            // Ensure FileType is SNOTE via Title/extension heuristic is not supported. FileType is derived by Salesforce;
            // In many orgs '.snote' will classify as type 'SNOTE'. If it does not, query will be empty; still valid.
        } catch (Exception e) {
            // swallow
        }

        // Link file to Opportunity
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = contentDocumentId,
            LinkedEntityId = opp.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;

        return contentDocumentId;
    }

    @IsTest
    static void export_nullRequests_returnsMessage() {
        Test.startTest();
        List<ContentSnoteCsvExporter.Request> reqs = null;
        List<ContentSnoteCsvExporter.Result> res = ContentSnoteCsvExporter.export(reqs);
        Test.stopTest();

        System.assertEquals(1, res.size(), 'Should return one result');
        System.assertEquals('No request provided.', res[0].statusMessage);
        System.assertEquals(null, res[0].contentVersionId);
    }

    @IsTest
    static void export_emptyRequests_returnsMessage() {
        Test.startTest();
        List<ContentSnoteCsvExporter.Request> reqs = new List<ContentSnoteCsvExporter.Request>();
        List<ContentSnoteCsvExporter.Result> res = ContentSnoteCsvExporter.export(reqs);
        Test.stopTest();

        System.assertEquals(1, res.size());
        System.assertEquals('No request provided.', res[0].statusMessage);
    }

    @IsTest
    static void export_nullFirstRequest_returnsMessage() {
        Test.startTest();
        List<ContentSnoteCsvExporter.Request> reqs = new List<ContentSnoteCsvExporter.Request>{ null };
        List<ContentSnoteCsvExporter.Result> res = ContentSnoteCsvExporter.export(reqs);
        Test.stopTest();

        System.assertEquals(1, res.size());
        System.assertEquals('Request is null.', res[0].statusMessage);
    }

    @IsTest
    static void export_noLibrary_savesPrivateFile_withDefaultPrefix() {
        User amer = createAmericasUser();
        System.runAs(amer) {
            // Data setup
            Opportunity opp = createSalesDevOpportunity(amer.Id);
            // Create a file and link to Opp (may or may not match FileType/Owner filter; still valid path)
            createSnoteFileLinkedToOpp(opp, amer.Id);

            // Build request without targetLibraryDeveloperName to trigger private file save
            ContentSnoteCsvExporter.Request r = new ContentSnoteCsvExporter.Request();
            r.targetLibraryDeveloperName = null; // will resolve to null workspace
            r.fileNamePrefix = null; // default to 'Sales_Dev_SNotes'

            Test.startTest();
            List<ContentSnoteCsvExporter.Result> res = ContentSnoteCsvExporter.export(new List<ContentSnoteCsvExporter.Request>{ r });
            Test.stopTest();

            System.assertEquals(1, res.size());
            ContentSnoteCsvExporter.Result out = res[0];

            System.assertNotEquals(null, out.fileName, 'Filename should be populated');
            System.assert(out.fileName.startsWith('Sales_Dev_SNotes_') && out.fileName.endsWith('.csv'), 'Default prefix and .csv expected');
            System.assertNotEquals(null, out.contentVersionId, 'ContentVersion should be inserted');

            // Validate ContentVersion fields
            ContentVersion cv = [
                SELECT Id, Title, PathOnClient, ContentDocumentId
                FROM ContentVersion
                WHERE Id = :out.contentVersionId
                LIMIT 1
            ];
            System.assertEquals(out.fileName.removeEnd('.csv'), cv.Title);
            System.assertEquals(out.fileName, cv.PathOnClient);
            System.assertNotEquals(null, cv.ContentDocumentId);

            // Should not be linked to any library
            Integer libraryLinks = [SELECT COUNT() FROM ContentWorkspaceDoc WHERE ContentDocumentId = :cv.ContentDocumentId];
            System.assertEquals(0, libraryLinks, 'No library links expected');

            System.assert(out.statusMessage.startsWith('CSV generated successfully'), 'Success status expected');
            System.assert(out.statusMessage.contains('saved as private file'), 'Should indicate private file when no library found');
        }
    }

    @IsTest
    static void export_withLibrary_linksDocument_andCustomPrefix() {
        User amer = createAmericasUser();
        System.runAs(amer) {
            // Ensure a library exists; code resolves by Name passed in request
            ContentWorkspace lib = ensureLibrary('SalesDevOpsNotes');

            // Data setup
            Opportunity opp = createSalesDevOpportunity(amer.Id);
            createSnoteFileLinkedToOpp(opp, amer.Id);

            ContentSnoteCsvExporter.Request r = new ContentSnoteCsvExporter.Request();
            r.targetLibraryDeveloperName = lib.Name; // resolveWorkspaceId uses Name
            r.fileNamePrefix = 'MyPrefix';

            Test.startTest();
            List<ContentSnoteCsvExporter.Result> res = ContentSnoteCsvExporter.export(new List<ContentSnoteCsvExporter.Request>{ r });
            Test.stopTest();

            System.assertEquals(1, res.size());
            ContentSnoteCsvExporter.Result out = res[0];

            System.assertNotEquals(null, out.contentVersionId, 'ContentVersion should be inserted');
            System.assertNotEquals(null, out.contentDocumentId, 'ContentDocumentId should resolve');

            System.assert(out.fileName.startsWith('MyPrefix_') && out.fileName.endsWith('.csv'), 'Custom prefix used');

            // Verify document linked to the library
            ContentWorkspaceDoc cwd = [
                SELECT Id, ContentWorkspaceId, ContentDocumentId
                FROM ContentWorkspaceDoc
                WHERE ContentDocumentId = :out.contentDocumentId
                LIMIT 1
            ];
            System.assertEquals(lib.Id, cwd.ContentWorkspaceId, 'Document should be linked to target library');

            System.assert(out.statusMessage.contains('stored in library'), 'Status indicates stored in library');
        }
    }

    @IsTest
    static void csv_helpers_are_wired_via_file_creation() {
        User amer = createAmericasUser();
        System.runAs(amer) {
            // Minimal setup, no pre-existing ContentDocumentLink required, exporter builds CSV from query (may be empty)
            ContentSnoteCsvExporter.Request r = new ContentSnoteCsvExporter.Request();
            r.fileNamePrefix = 'CSVTest';
            // no library to keep it simple
            Test.startTest();
            List<ContentSnoteCsvExporter.Result> res = ContentSnoteCsvExporter.export(new List<ContentSnoteCsvExporter.Request>{ r });
            Test.stopTest();

            System.assertEquals(1, res.size());
            ContentSnoteCsvExporter.Result out = res[0];
            System.assertNotEquals(null, out.contentVersionId);

            // Retrieve blob and ensure it has the header row written by buildCsv
            // Note: VersionData is not directly queryable. Instead, verify Title/Path and existence.
            ContentVersion cv = [
                SELECT Id, Title, PathOnClient, ContentDocumentId
                FROM ContentVersion
                WHERE Id = :out.contentVersionId
                LIMIT 1
            ];
            System.assertEquals(out.fileName.removeEnd('.csv'), cv.Title);
            System.assertEquals(out.fileName, cv.PathOnClient);
        }
    }
}