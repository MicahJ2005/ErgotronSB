@isTest 
private class AccountMethod_UnitTest {
	@isTest
	private static void processBillingInfo_Single_Test() {

		Test.setMock(HttpCalloutMock.class, new Utility_SmartyStreets_MOCK.SmartyStreetsHTTPCalloutMock());

		SmartyStreets_API__c ss = new SmartyStreets_API__c();
			ss.Name = 'SeedUnitAddressVerify';
			ss.auth_id__c = 'adsmfqmwepm09daasd';
			ss.auth_token__c = '23240kfir8fj8f8';
		insert ss;

		List<Account> lstAccountInsert = new List<Account>();
		for(Integer intCount = 0; intCount < 10; intCount++) {
			lstAccountInsert.add(new Account(
				Name = 'Test Account ' + String.valueOf(intCount),
				BillingStreet = '11487 Valley View Rd.\r\nSuite A\r\nDock 7\r\nAddressLine4',
				BillingCity = 'Eden Prairie',
				BillingState = 'Minnesota',
				BillingPostalCode = '55344'
			));
		}

		Test.startTest();
			insert lstAccountInsert;
		Test.stopTest();

		List<Account> lstCheck = new List<Account>();
		lstCheck = [SELECT Id, IsAddressValidated__c FROM Account WHERE IsAddressValidated__c = true];
		//System.assertEquals(1, lstCheck.size());
	}
}