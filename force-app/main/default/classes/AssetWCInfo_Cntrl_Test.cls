@isTest 
private class AssetWCInfo_Cntrl_Test {

	@testSetup
	static void Test_Data_Setup() {

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

		Asset objAsset = Test_Environment_Utility.createInsertInstalledProductOracle('12345678', acctS, newCaseProd);
		Asset objAssetChild = Test_Environment_Utility.createInsertInstalledProductOracle('12345678', acctS, newCaseProd);
		objAssetChild.ParentId = objAsset.Id;
		update objAssetChild;

        Case objCase = new Case();
        	objCase.AccountId = acctS.Id;
        	objCase.ContactId = cont.Id;
        	objCase.Status = 'New';
        	objCase.Subject = 'Test Subject';
            objCase.ProductId = newCaseProd.Id;
            objCase.Build_Warehouse__c = 'DO1';
			objCase.AssetId = objAsset.Id;
        insert objCase;
	}

	static testmethod void getWOWarrantyInformation() {
		Test.setMock(HttpCalloutMock.class, new Test_MOCK_ServiceCalls.generalCalloutMock());

		Case objCase = [SELECT Id FROM Case LIMIT 1];

		AssetWCInfo_Cntrl.getWorkOrderWarrantyInformation(null, objCase.Id);
		AssetWCInfo_Cntrl.getWorkOrderWarrantyInformation('12345678', null);
		AssetWCInfo_Cntrl.getWorkOrderWarrantyInformation('1234567-8', objCase.Id);

		Asset objAsset = [SELECT Id FROM Asset WHERE ParentId = NULL LIMIT 1];

		AssetWCInfo_Cntrl.getChildrenAsset(objAsset.Id);
	}
}