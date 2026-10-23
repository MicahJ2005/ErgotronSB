/**
*   {Purpose}  �  TODO:  Provide Purpose
*
*	{Code Covered}	- Note the triggers/classes that this test covers
*
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 612-424-0032                  
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date    	Name             		Description
*   YYYYMMDD  	FN LN DCS				Created
*	20171011	Matt Smelser DCS		Removed Customer_Account__c
*   =============================================================================
*/
@isTest
private class Sales_ORder_SRAttachController_Test {
	
	//Test data setup method
    @testSetup
    static void testDataSetup() {
    	
    	//Create Accounts for testing
	    Account oAccount = Test_Environment_Utility.createInsertAccountUS();

	    //Create Contact for testing
	    Contact oContact = Test_Environment_Utility.createInsertContact(oAccount);

	    //Create Customer_Account__c for testing
	    //Customer_Account__c oCustomerAccount = Test_Environment_Utility.createInsertCustomerAccount(oAccount);

	    //Create Case for testing
	    Case oCase = Test_Environment_Utility.createInsertCase(oAccount,oContact, null, null);
    }

	@isTest static void testController() {
		
		Sales_Order__c soSO = new Sales_Order__c();
		soSo.Service_Request__c = [SELECT Id FROM Case LIMIT 1].Id;
		insert soSO;

		Sales_Order_SRAttachController clsSOSR = new Sales_Order_SRAttachController(new ApexPages.standardController(soSO));
		clsSOSR.prSR();


	}
	
}