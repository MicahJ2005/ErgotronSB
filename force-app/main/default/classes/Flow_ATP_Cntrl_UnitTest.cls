@IsTest
private class Flow_ATP_Cntrl_UnitTest {
	@testSetup
	static void Test_Data_Setup() {

		//Create custom setting details
    	Set<String> setOrderTypes = new Set<String>{'RETURN','MAINTENANCE','TRF'};
    	Set<String> setReturnReasons = new Set<String>{'BAD','DEFECT','PACKAGING'};
    	List<Oracle_Order_Type__c> listOrderTypes = Test_Environment_Utility.createInsertOrderTypes(setOrderTypes);
    	List<Oracle_Return_Reason__c> listReturnReasons = Test_Environment_Utility.createInsertReturnReasons(setReturnReasons);

		SmartyStreets_API__c ss = new SmartyStreets_API__c();
			ss.Name = 'SeedUnitAddressVerify';
			ss.auth_id__c = 'adsmfqmwepm09daasd';
			ss.auth_token__c = '23240kfir8fj8f8';
		insert ss;

		List<Product2> lstProdInsert = new List<Product2>();
		Id rtSite = Schema.SObjectType.Account.RecordTypeInfosByName.get('Site').RecordTypeId;
		Id rtCustomer = Schema.SObjectType.Account.RecordTypeInfosByName.get('Customer - Organization').RecordTypeId;
		Id rtParty = Schema.SObjectType.Account.RecordTypeInfosByName.get('Party').RecordTypeId;
        
        Account acctP = new Account();
            acctP.Name='TEST123Party';
            acctP.RecordTypeId = rtParty;
        insert acctP;
        Account acctC = new Account();
        	acctC.Name='TEST123Customer';
        	acctC.RecordTypeId = rtCustomer;
        	acctC.ParentId = acctP.Id;
        insert acctC;
        Account acctS = new Account();
        	acctS.Name='TEST123Site';
            acctS.BillingStreet='100 JUMP STREET';
            acctS.BillingCity='Boston';
            acctS.BillingState='Massachusetts';
            acctS.BillingPostalCode='02201';
            acctS.BillingCountry='United States';
            acctS.BillingCountryCode='US';
            acctS.Customer_Account_Id__c='ERGO123456';
            acctS.Oracle_Party_Number__c = 'o12345678';
            acctS.Oracle_Party_Status__c = 'A';
            acctS.Discount_Class__c='BROADLINE US DISCOUNT';
            acctS.Account_Number__c='ERGO123456';
        	acctS.RecordTypeId = rtSite;
        	acctS.ParentId = acctC.Id;
        insert acctS;

        Contact cont = new Contact();
        	cont.FirstName = 'Test';
        	cont.LastName = 'Last';
        	cont.Email = 'testlast@test.com';
        	cont.Phone = '555.555.5555';
            cont.AccountId = acctS.Id;
        insert cont;

        Product2 newCaseProd = new Product2();
            newCaseProd.Name = 'ServicePart';
            newCaseProd.ProductCode = '655-148-053-00';
            newCaseProd.Labor_Part__c = false;
        insert newCaseProd;

        Case c = new Case();
        	c.AccountId = acctS.Id;
        	c.ContactId = cont.Id;
        	c.Status = 'New';
        	c.Subject = 'Test Subject';
            c.ProductId = newCaseProd.Id;
            c.Build_Warehouse__c = 'DO1';
        insert c;

        for(Integer i=0; i<10; i++){
			Product2 newRec = new Product2();
				newRec.Name = 'TestPart'+i;
				newRec.ProductCode = 'test123test'+i;
			lstProdInsert.add(newRec);
		}
		Product2 newService = new Product2();
				newService.Name = 'ServicePart';
				newService.ProductCode = 'Srvc123Srvc';
				newService.Labor_Part__c = true;
		lstProdInsert.add(newService);
		insert lstProdInsert;

        Sales_Order__c so = new Sales_Order__c();
        	so.Bill_To_Customer__c = acctC.Id;
        	so.Ship_To_Contact__c = cont.Id;
        	so.Ship_To_Customer__c = acctS.Id;
        	so.Service_Request__c = c.Id;
        	so.Order_Type__c = 'TRF';
        	so.Customer_PO_Number__c = 'Test 123';
        insert so;
	}

	static testmethod void getATPData_Test() {
		Test.setMock(HttpCalloutMock.class, new Test_MOCK_ServiceCalls.generalCalloutMock());
		Flow_ATP_Controller.getATPData('BADPARTDATA');
		Flow_ATP_Controller.getATPData('655-148-053-00');
	}
	static testmethod void getOracleReturnReason_Test(){
		Test.setMock(HttpCalloutMock.class, new Test_MOCK_ServiceCalls.generalCalloutMock());
		List<Oracle_Return_Reason__c> lstORR = new List<Oracle_Return_Reason__c>();
		lstORR = Flow_ATP_Controller.getOracleReturnReason();
	}
	static testmethod void productNameLookup_Test(){
		Test.setMock(HttpCalloutMock.class, new Test_MOCK_ServiceCalls.generalCalloutMock());
		List<Product2> lstProdReturn = new List<Product2>();
		lstProdReturn = Flow_ATP_Controller.productNameLookup('TestPart');
	}
/*	static testmethod void productNameLookupInBOM_Test(){
		Test.setMock(HttpCalloutMock.class, new Test_MOCK_ServiceCalls.generalCalloutMock());
        List<Product2> retlst = new List<Product2>();
        Case c = [SELECT Id FROM Case WHERE ProductId != Null LIMIT 1];
        String pname = 'standoff';
        String caseId = c.Id;
        retlst = Flow_ATP_Controller.productNameLookupInBOM(pname, caseId);
	} */
	static testmethod void createhelperClassPartData_Test(){
		Test.setMock(HttpCalloutMock.class, new Test_MOCK_ServiceCalls.generalCalloutMock());
		Flow_ATP_Controller.createhelperClassPartData('test123test1', '1', 'US1', '');
	}
	static testmethod void completeSOprocess_Test(){

		Test.setMock(HttpCalloutMock.class, new Test_MOCK_ServiceCalls.generalCalloutMock());
		String strLstParts;
		String caseId;
		String orderId;
		Sales_Order__c so = new Sales_Order__c();
		List<HelperATPData> lstParts = new List<HelperATPData>();
		lstParts.add(Flow_ATP_Controller.createhelperClassPartData('test123test1', '1', 'US1', ''));
		lstParts.add(Flow_ATP_Controller.createhelperClassPartData('test123test1', '-1', 'US1', 'Because'));
		lstParts.add(Flow_ATP_Controller.createhelperClassPartData('Srvc123Srvc', '1', 'US1', ''));
		strLstParts = JSON.serializePretty(lstParts);

		so = [SELECT Id, Service_Request__c FROM Sales_Order__c LIMIT 1];
		caseId = so.Service_Request__c;
		orderId = so.Id;

		// Flow_ATP_Controller.completeSOprocess(orderId, strLstParts,caseId);
	}
	static testmethod void warehouseLookup_Test(){
		Test.setMock(HttpCalloutMock.class, new Test_MOCK_ServiceCalls.generalCalloutMock());
		Flow_ATP_Controller.warehouseLookup();
	}

	static testMethod void generalUtilityTests() {

		Case objCase = [SELECT Id, AccountId, RecordTypeId, Status, Resolution_Code__c, Resolution_Summary__c FROM Case LIMIT 1];
		Account objAccount = [SELECT Id, RecordTypeId FROM Account WHERE Id = :objCase.AccountId];

		Flow_ATP_Controller.getCaseDetails(objCase.Id);

		Flow_ATP_Controller.getTestCaseBusinessLogic(objCase.Id);

		objCase.Status = 'Closed';
		objCase.Resolution_Summary__c = 'testing!';
		objCase.Resolution_Code__c = 'Resolved';
		update objCase;
		Flow_ATP_Controller.getTestCaseBusinessLogic(objCase.Id);

		objAccount.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Party').RecordTypeId;
		update objAccount;
		Flow_ATP_Controller.getTestCaseBusinessLogic(objCase.Id);

		Flow_ATP_Controller.productNameLookup('ServicePart');

		Flow_ATP_Controller.getOrderSelections(objCase.Id);

		Flow_ATP_Controller.getMoreAccounts('dummyacctname');

		Flow_ATP_Controller.getShipToContacts(objAccount.Id);
	}

	static testMethod void testCreateOrder() {
		
		Case objCase = [SELECT Id FROM Case LIMIT 1];
		Account objAccount = [SELECT Id FROM Account WHERE Name = 'TEST123Site' LIMIT 1];
		Contact objContact = [SELECT Id FROM Contact WHERE AccountId = :objAccount.Id LIMIT 1];

		List<HelperATPData> lstParts = new List<HelperATPData>();
		lstParts.add(Flow_ATP_Controller.createhelperClassPartData('test123test1', '1', 'US1', ''));
		lstParts.add(Flow_ATP_Controller.createhelperClassPartData('test123test1', '-1', 'US1', 'Because'));
		lstParts.add(Flow_ATP_Controller.createhelperClassPartData('Srvc123Srvc', '1', 'US1', ''));

		Flow_ATP_Controller.createOrder(JSON.serializePretty(lstParts), '1234567890', objAccount.Id, objAccount.Id, 'notes', 'TRF', objCase.Id, objContact.Id);

	}

	static testmethod void testPartNumbers() {

		Test.setMock(HttpCalloutMock.class, new Test_MOCK_ServiceCalls.generalCalloutMock());
		Flow_ATP_Controller.getPartNumbers('BRACKET, LAPTOP STAND-OFF, LIGHT GREY', '509-407-053-00', '');

	}
}