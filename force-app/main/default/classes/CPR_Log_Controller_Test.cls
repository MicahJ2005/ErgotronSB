/**
*   {Purpose}  -	Test Coverage for CPR_Log_Controller
*
*	{Code Covered}	- CPR_Log_Controller
*
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 612-424-0032                  
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date    	Name             		Description
*   20160830  	Matt Smelser DCS		Created
*   =============================================================================
*/
@isTest
private class CPR_Log_Controller_Test {
	@isTest static void CPR_Log_Test() {
		//Create End User Account for testing
    	Account oAccountEndUser = Test_Environment_Utility.createInsertAccountUS();
    	oAccountEndUser.Name='End User';
    	update oAccountEndUser;

    	//Create Contact for testing
    	Contact oContact = Test_Environment_Utility.createInsertContact(oAccountEndUser);
		
		//Create Products for testing
    	Product2 oProductService = Test_Environment_Utility.createInsertProduct();
    	oProductService.Item_Type__c='E-SERVICE';
    	oProductService.Name='SERVICE';
    	update oProductService;

    	Product2 oProductFG = Test_Environment_Utility.createInsertProduct();
    	oProductFG.Name='FG';
    	update oProductFG;

    	Custom_Product__c cp = new Custom_Product__c();
			cp.Date_Requested__c = System.today();
			cp.Customer__c = oAccountEndUser.Id;
			cp.Prototype_Product_Part_Number__c = oProductService.Id;
			cp.Product_Specs__c = 'Test Product Spec';
			cp.Reason_for_special_Product__c = 'Test Special Products';
			cp.TAM__c = 'test';
			cp.Manufacturer__c = oAccountEndUser.Id;
			cp.Minimum_Order_Quantity__c = 2;
			cp.MSRP__c = 1200;
			cp.Image__c = 'test';
			cp.Include_in_Rep_Document__c = true;
		Insert cp;

		Custom_Product__c cp2 = new Custom_Product__c();
			cp2.Date_Requested__c = System.today();
			cp2.Customer__c = oAccountEndUser.Id;
			cp2.Prototype_Product_Part_Number__c = oProductService.Id;
			cp2.Product_Specs__c = 'Test Product Spec';
			cp2.Reason_for_special_Product__c = 'Test Special Products';
			cp2.TAM__c = 'test';
			cp2.Manufacturer__c = oAccountEndUser.Id;
			cp2.Minimum_Order_Quantity__c = 2;
			cp2.MSRP__c = 1200;
			cp2.Image__c = 'test';
			cp2.Include_in_Rep_Document__c = true;
		Insert cp2;

		Test.startTest();
			List<Custom_Product__c> lstcp = new List<Custom_Product__c>();
			CPR_Log_Controller con = new CPR_Log_Controller();
			lstcp = con.lstcpr;
			System.assertEquals(lstcp.size(),2 );
			lstcp.clear();
			con.CPid = cp.Id;
			lstcp = con.lstcpr;
			System.assertEquals(lstcp.size(),1 );
		Test.stopTest();
	}
}