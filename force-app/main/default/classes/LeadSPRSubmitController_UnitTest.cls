/**
*   {Purpose}  -	Provide coverage for LeadSPRSubmitController
*
*	{Code Covered}	- Full Class Coverage
*
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 612-424-0032                  
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date    	Name             		Description
*   20160712  	Andy Boettcher DCS		Created
*   =============================================================================
*/
@isTest
private class LeadSPRSubmitController_UnitTest {
	
	@isTest static void testControllerExtension() {

		Web_Service_Details__c oWebServiceLead = Test_Environment_Utility.createInsertWebServiceDetails('Territory Lookup');		
		
		//Create Lead for test
		Lead oLead = new Lead();
		oLead.Company='Test';
		oLead.FirstName='Test';
		oLead.LastName='Test';
		oLead.Ergotron_Vertical_Market__c='Enterprise';
		oLead.Street='Test';
		oLead.City='Test';
		oLead.StateCode='MN';
		oLead.PostalCode='55121';
		oLead.CountryCode='US';
		oLead.Territory_Account_Manager__c=UserInfo.getUserId();
		insert oLead;

		// Create Product
		Product2 oProduct = new Product2();
		oProduct.Name = 'Test Product';
		oProduct.ProductCode = 'ABC123';
		oProduct.Item_Type__c = 'E-FG';
		oProduct.Inventory_Item_Status_Code__c = 'MASTER';
		oProduct.IsActive = true;
		oProduct.MSRP_US_STANDARD_USD__c = 100;
		oProduct.Costing_Inventory__c = 'F';
		insert oProduct;

		List<Lead_Product__c> lstInsertProducts = new List<Lead_Product__c>();
		for(Integer i=0;i<100;i++) {
			lstInsertProducts.add(new Lead_Product__c(Product__c=oProduct.Id, Lead__c=oLead.Id));
		}

		insert lstInsertProducts;

		test.startTest();

		PageReference oPageRef = Page.LeadSPRSubmit;
		Test.setCurrentPage(oPageRef);

		ApexPages.StandardController oSC = new ApexPages.StandardController(oLead);
		oPageRef.getParameters().put('id', String.valueOf(oLead.Id));
		LeadSPRSubmitController clsSubmit = new LeadSPRSubmitController(oSC);

		clsSubmit.prepForOracle();

		test.stopTest();

	}
	
}