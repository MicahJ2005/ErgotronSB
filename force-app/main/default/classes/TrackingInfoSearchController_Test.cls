/**
*   {Purpose}  -	Unit Test Coverage for TrackingInfoSearchController
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
*   20160809  	Andy Boettcher DCS		Created
*   =============================================================================
*/
@isTest
private class TrackingInfoSearchController_Test {
	
	//Test data setup method
    @testSetup static void testDataSetup() {

    	//Create Account for testing
    	Account oAccount = Test_Environment_Utility.createInsertAccountUS();
    	Account oCustomerAccount = Test_Environment_Utility.createInsertAccountUS();

        //Create Order for testing
    	Order__c oOrder = new Order__c(
    		Name='123456', 
    		Customer__c=oAccount.Id, 
    		Customer_Account_New__c=oCustomerAccount.Id
    	);
    	insert oOrder;

        //Create order line for testing.
    	Order_Line_Item__c oOrderLineItem = new Order_Line_Item__c(
    		Name='1.1', 
    		Order__c=oOrder.Id, 
    		Actual_Shipment_Date__c=Date.newInstance(2015,1,1), 
    		CurrencyIsoCode='USD',
    		Line_Id__c = '9876'
    	);
    	insert oOrderLineItem;

    	// Create Tracking Item
    	Order_Tracking_Number__c oOrderTN = new Order_Tracking_Number__c(
    		Tracking_Unique_ID__c = '122344353574',
    		Tracking_Number__c = 'ABC123',
    		Carrier_Code__c = 'FEDEX',
    		Line_Id__c = '9876',
    		Quantity__c = 10,
    		Order_Number__c = '123456'
    	);
    	insert oOrderTN;
	}

	@isTest static void testAutoPopulate() {
		
		Order__c objOrder = [SELECT Id, Name FROM Order__c LIMIT 1];

		PageReference prTest = Page.TrackingInfoSearch;
		prTest.getParameters().put('id', objOrder.Id);
		Test.setCurrentPage(prTest);

		TrackingInfoSearchController clsTracking = new TrackingInfoSearchController(new ApexPages.StandardController(objOrder));
		clsTracking.doSearch();

		System.Assert(clsTracking.lstResults.size() > 0, 'List did not populate with results');

	}
	
}