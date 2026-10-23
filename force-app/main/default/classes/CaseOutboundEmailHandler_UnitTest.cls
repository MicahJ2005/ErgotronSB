@isTest 
private class CaseOutboundEmailHandler_UnitTest {
	
	@TestSetup
	private static void setupTestData() {
		
		Case_Email_Blacklist__c objCEB = new Case_Email_Blacklist__c();
		objCEB.Name = 'ergotron.com';
		objCEB.Blocked_Reason__c = 'Manual Entry';
		insert objCEB;

	}

	@isTest
	private static void testSuccessfulEmailNoContact() {
		
		Case objCase = new Case(
			SuppliedEmail = 'goodperson@gmail.com',
			SuppliedName = 'Good Person',
			Subject = 'Good Case'
		);

		insert objCase;

	}
}