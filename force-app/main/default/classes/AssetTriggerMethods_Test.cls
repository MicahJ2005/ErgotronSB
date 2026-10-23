@isTest 
private class AssetTriggerMethods_Test {

	@TestSetup
	private static void setupTestData() {
		Test_Environment_Utility.createWarrantyBHBusinessHours();
		Test_Environment_Utility.createInsertAccountUS('95175382');

		Product2 objProduct = new Product2(
			ProductCode = '696-831-099-00',
			Name = 'KIT,END CAP PVT COVER,APG',
			Default_Warranty_Terms__c = 60
		);
		insert objProduct;
        
        Web_Service_Details__c objWSD = new Web_Service_Details__c(
            Name = 'Xively JWT',
            Endpoint__c = 'https://id.xively.com/api/v1/auth/login-user',
            Username__c = 'ergotronwebdev@gmail.com',
            Password__c = '&hhasdk38AS7gfa',
            Account_ID__c = '184af8cb-03b6-4f0f-b6d3-85dc22f6def8',
            Description_Where_Used__c = 'description',
            Exception_Email__c = 'exception@example.com'
        );
        insert objWSD;
	}

	@isTest
	private static void testPopulateAssetData() {
		Test.setMock(HttpCalloutMock.class, new Test_MOCK_ServiceCalls.generalCalloutMock());

		Account objAccount = [SELECT Id FROM Account LIMIT 1];

		Asset objAsset = new Asset(
			AccountId=objAccount.Id,
			SerialNumber='12345',
			Name='12345',
			GetWOData__c = true,
            CCU_board__c = 'boardNumber'
		);

		insert objAsset;

		objAsset.Warranty_Start_Date__c = System.today();
		objAsset.Warranty_Terms_in_Months__c = 60;

		update objAsset;
	}
}