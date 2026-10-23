@isTest
private class Integration_Id_Trigger_Test {
	
	static testmethod void testAfterDelete() {
		//Generate Integration_Id__c record for test.
		Integration_Id__c oIntegrationId = Test_Environment_Utility.createInsertIntegrationId();

		//Delete the newly created Integration_Id__c to execute trigger.
		delete oIntegrationId;

		//Assert that trigger executed and 500 new records were generated
		system.assertEquals(500,[select Id from Integration_Id__c].size());
	}
}