@isTest
private class Case_Trigger_Test {
    @TestSetup
    private static void setupTestData() {
        Case_Email_Blacklist__c objCEB = new Case_Email_Blacklist__c();
        objCEB.Name = 'ergotron.com';
        objCEB.Blocked_Reason__c = 'Manual Entry';
        insert objCEB;

        //Insert product
        Product2 oNewProduct = new Product2(
            Name = 'TEST',
            ProductCode = 'TEST',
            Costing_Inventory__c = 'F',
            Item_Type__c = 'E-FG',
            Inventory_Item_Status_Code__c = 'MASTER',
            isActive = true,
            MSRP_EMEA_APAC_USD__c = 10,
            MSRP_EMEA_EUR__c = 10,
            MSRP_EMEA_GBP__c = 10,
            MSRP_US_STANDARD_USD__c = 10,
            Oracle_Part_Number__c = '2342432',
            QuantityInstallmentPeriod = 'Monthly',
            QuantityScheduleType = 'Divide',
            CanUseQuantitySchedule = true
        );

        insert oNewProduct;

        ccrz__E_Cart__c cart = new ccrz__E_Cart__c();
        cart.ccrz__CartStatus__c = 'Open';
        cart.ccrz__ActiveCart__c = true;
        cart.ccrz__BuyerCompanyName__c = 'testCompany';
        insert cart;
    }

    @isTest //Testing Case_Trigger Validation - Cannot close case if the CC Cart is open
    private static void caseNoCart() {
        //Case without cart - successful close

        Product2 prod = [SELECT id FROM product2 WHERE name = 'TEST' LIMIT 1];
        Case c = new Case(ProductId = prod.id, Resolution_Code__c = 'Resolved', Resolution_Summary__c = 'Ready to Close', Subject = 'Good Case to close');
        insert c;
        System.debug('Case ready to be closed inserted');
        c.status = 'Closed';
        update c;
        system.assertEquals('Closed', c.status, 'Case was NOT successfully closed');
        System.debug('Case status after update: ' + c.status);
    }
    //*
    @isTest //Testing Case_Trigger Validation - Cannot close case if the CC Cart is open
    private static void caseOpenCart() {
        // Case with open cart - should not allow case close

        Product2 prod = [SELECT id FROM product2 WHERE name = 'TEST' LIMIT 1];
        ccrz__E_Cart__c cart = [SELECT id FROM ccrz__E_Cart__c WHERE ccrz__BuyerCompanyName__c = 'testCompany' LIMIT 1];

        Case c = new Case(CC_CartId__c = cart.id, ProductId = prod.id, Resolution_Code__c = 'Resolved', Resolution_Summary__c = 'Ready to Close', Subject = 'Good Case to close');

        insert c;
        System.debug('Case ready to be closed inserted');

        c.status = 'Closed';

        try {
            update c;
        } catch (Exception e) {
            System.debug('An error happened, as predicted!');
        }

        //system.assertEquals(expected, actual);
    }
    //*/

    //*
    @isTest //Testing Case_Trigger Validation - Cannot close case if the CC Cart is open
    private static void caseClosedCart() {
        // Case with Closed cart - should allow case close

        Product2 prod = [SELECT id FROM product2 WHERE name = 'TEST' LIMIT 1];
        ccrz__E_Cart__c cart = [SELECT id FROM ccrz__E_Cart__c WHERE ccrz__BuyerCompanyName__c = 'testCompany' LIMIT 1];
        cart.ccrz__CartStatus__c = 'Closed';
        update cart;

        Case c = new Case(CC_CartId__c = cart.id, ProductId = prod.id, Resolution_Code__c = 'Resolved', Resolution_Summary__c = 'Ready to Close', Subject = 'Good Case to close');

        insert c;
        System.debug('Case ready to be closed inserted');

        c.status = 'Closed';
        update c;
        system.assertEquals('Closed', c.status, 'Case was NOT successfully closed');
        System.debug('Case status after update: ' + c.status);
    }
    //*/

    @isTest
    private static void testSuccessfulEmailNoContact() {
        Case objCase = new Case(SuppliedEmail = 'goodperson@gmail.com', SuppliedName = 'Good Person', Subject = 'Good Case');

        insert objCase;
    }

    @isTest
    private static void caseCountTest() {
        Account a = new Account();
        a.name = 'test account';
        insert a;

        Case c = new Case(Status = 'New', Origin = 'Phone', Description = 'test', AccountId = a.id);

        Test.startTest();
        insert c;
        Test.stopTest();

        Account result = [SELECT ID, Open_Cases__c FROM ACCOUNT WHERE ID = :a.Id];

        Assert.areEqual(1, result.Open_Cases__c, 'Should have been 1 open case.');
    }

    @isTest
    public static void serviceAppointment_Test_Update(){
        Profile someProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(profileId = someProfile.Id,LastName = 'last',Email = 'puser000@amamama.com',Username = 'puser000@amamama.com' 
                          + System.currentTimeMillis(), CompanyName = 'TEST', Title = 'title', Alias = 'alias', 
                          TimeZoneSidKey = 'America/Los_Angeles',EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', 		User_Region__c = 'Americas' );
        insert u;
        Account a = new Account(Name = 'Test Company', Type = 'Current');
        insert a;
        Contact con = new Contact();
        con.AccountId = a.ID;
        con.FirstName = 'test';
        con.LastName = 'test';
        con.email = 'test@test.com';
    
        insert con;
        Case caseObj = new Case(Status = 'New', Subject = 'Test', Field_Tech__c = u.Id, ContactId = con.Id,
                                ETA__c = Date.newInstance(2022, 04, 12), Instructions__c = 'Instructions__c', Accountid = a.id );
        insert caseObj;
        Asset ast = new Asset(Name = '1234', AccountId = a.Id, ContactId = con.id);
        insert ast;   
        WorkOrder wo =new WorkOrder(Work_Order_Type__c = 'Standard', Subject = 'cart not powering on with error code 605', 
                                    Issue_as_Stated_by_Customer__c = 'Issue', AssetId = ast.id, CaseId = caseObj.Id,
                                    OwnerId = caseObj.Field_Tech__c, status = 'New' );
        insert wo;
        
        ServiceAppointment sa1 = new ServiceAppointment(ParentRecordId = a.id,  Status = 'None', EarliestStartTime = system.now(), DueDate = system.now()+ 7);

        List<Case> c1 = [Select id, ContactId, Status, Field_Tech__c, ETA__c, Instructions__c, Accountid, Account_Name__c, Tracking_Number_s__c
                         from Case where Subject = 'Test'];
        List<ServiceAppointment> sa2 = new List<ServiceAppointment>();
        List<Case> c2 = new List <Case>();
        for(Case c:c1){
            case co = new case();
            co.id = c.id;
            co.status = 'Tech Visit';
            c2.add(co);
        }
        
        Test.startTest();
        update c2;
       Test.stopTest();
      
    }


    @isTest
    public static void serviceAppointment_Test(){
        Profile someProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(profileId = someProfile.Id,LastName = 'last',Email = 'puser000@amamama.com',Username = 'puser000@amamama.com' 
                          + System.currentTimeMillis(), CompanyName = 'TEST', Title = 'title', Alias = 'alias', 
                          TimeZoneSidKey = 'America/Los_Angeles',EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', 		User_Region__c = 'Americas' );
        insert u;
        Account a = new Account(Name = 'Test Company', Type = 'Current');
        insert a;
        Contact con = new Contact();
        con.AccountId = a.ID;
        con.FirstName = 'test';
        con.LastName = 'test';
        con.email = 'test@test.com';
    
        insert con;
        Case caseObj = new Case(Status = 'New', Subject = 'Test', Field_Tech__c = u.Id, ContactId = con.Id,
                                ETA__c = Date.newInstance(2022, 04, 12), Instructions__c = 'Instructions__c', Accountid = a.id );
        insert caseObj;
        Asset ast = new Asset(Name = '1234', AccountId = a.Id, ContactId = con.id);
        insert ast;   
        WorkOrder wo =new WorkOrder(Work_Order_Type__c = 'Standard', Subject = 'cart not powering on with error code 605', 
                                    Issue_as_Stated_by_Customer__c = 'Issue', AssetId = ast.id, CaseId = caseObj.Id,
                                    OwnerId = caseObj.Field_Tech__c, status = 'New' );
        insert wo;
        
        ServiceAppointment sa1 = new ServiceAppointment(ParentRecordId = a.id,  Status = 'None', EarliestStartTime = system.now(), DueDate = system.now()+ 7);

        List<Case> c1 = [Select id, ContactId, Status, Field_Tech__c, ETA__c, Instructions__c, Accountid, Account_Name__c, Tracking_Number_s__c
                         from Case where Subject = 'Test'];
        List<ServiceAppointment> sa2 = new List<ServiceAppointment>();
        List<Case> c2 = new List <Case>();
        for(Case c:c1){
            case co = new case();
            co.id = c.id;
            co.status = 'Tech Visit';
            c2.add(co);
        }
        // update c2;
        List<Case> c3 = [Select id, Status, Field_Tech__c from Case where id =: c2[0].id];
        system.debug(c3[0].status);
        
        system.assertEquals(c3.size(), 1);
        system.AssertEquals(sa2.size(), 0);
        List<WorkOrder> newList = [Select id, CaseId, Status, AssetId from Workorder where Subject = 'cart not powering on with error code 605' ];
        Map<Id, List<WorkOrder>> caseIdAndWOListMap = new Map<Id, List<WorkOrder>>();
        caseIdAndWOListMap.put(newList[0].caseid, newList);
        CaseService.createServiceAppointments(c1);
    }
        

    @isTest
    public static void populateWODataTest(){

        Product2 product = new Product2(Name = 'Test Product', ProductCode = '696-831-099-00', Default_Warranty_Terms__c = 60);
        insert product;

        Profile someProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(profileId = someProfile.Id,LastName = 'last',Email = 'puser000@amamama.com',Username = 'puser000@amamama.com' 
                          + System.currentTimeMillis(), CompanyName = 'TEST', Title = 'title', Alias = 'alias', 
                          TimeZoneSidKey = 'America/Los_Angeles',EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', 		User_Region__c = 'Americas' );
        insert u;
        Account a = new Account(Name = 'Test Company', Type = 'Current');
        insert a;
        Contact con = new Contact();
        con.AccountId = a.ID;
        con.FirstName = 'test';
        con.LastName = 'test';
        con.email = 'test@test.com';
        insert con;

        Case caseObj = new Case(Status = 'New', Subject = 'Test', Field_Tech__c = u.Id, ContactId = con.Id,
                                ETA__c = Date.newInstance(2022, 04, 12), Instructions__c = 'Instructions__c', Accountid = a.id );
        insert caseObj;
        Asset ast = new Asset(Name = '1234', AccountId = a.Id, ContactId = con.id);
        insert ast;   
        WorkOrder wo =new WorkOrder(Work_Order_Type__c = 'Standard', Subject = 'cart not powering on with error code 605', 
                                    Issue_as_Stated_by_Customer__c = 'Issue', AssetId = ast.id, CaseId = caseObj.Id,
                                    OwnerId = caseObj.Field_Tech__c, status = 'New' );
        insert wo;

        //Set up mock web service response since web service callouts are not allowed from test classes
        SingleHTTPRequestMock_Test oResponse = new SingleHTTPRequestMock_Test(200,
            'OK',
            '{"woresult":[{"CURRENT_REV":"--A","ENG_PART_TYPE":"SUBASSY+HDWR","INVENTORY_ITEM_ID":"2562","ORGANIZATION_CODE":"US1","DESCRIPTION":"KIT,END CAP PVT COVER,APG","ITEM_CREATION_DATE":"2004-07-16T03:13:47Z","WO_ITEM_REVISION":"--A","WO_NUMBER":"12345","WIP_ENTITY_ID":"156388","REV_A_IMPLEMENT_DATE":"2003-05-17T05:00:00Z","ASSEMBLY_ITEM":"696-831-099-00","DATE_COMPLETED":"2005-01-04T18:06:50Z"}]}', null);
        Test.setMock(HttpCalloutMock.class, oResponse); 

        Test.startTest();
        CaseObj.Oracle_Work_Order__c = wo.Id;
        CaseObj.GetWOData__c = true;
        update CaseObj;
        Test.stopTest();
    }
        
}