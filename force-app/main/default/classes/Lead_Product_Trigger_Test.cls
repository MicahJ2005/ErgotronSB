/*
    Test class for the Lead_Product_Trigger.trigger.

    MOD DATE        Who                     Description
    02/05/2014      Chris Noe               Initial Release 
*/

@IsTest
private class Lead_Product_Trigger_Test {

    static testmethod void testLeadProductRollupLogic() {
		//Method variables
		List<Lead_Product__c> listLeadProducts = new List<Lead_Product__c>();

		//Create web service details record record by lead assignment callout
		Web_Service_Details__c oWebService = Test_Environment_Utility.createInsertWebServiceDetails('Territory Lookup');

    	//Create product for test
    	Product2 oProduct = Test_Environment_Utility.createInsertProduct();
    	oProduct.Item_Type__c='E-FG';
    	oProduct.Inventory_Item_Status_Code__c='MASTER';
    	oProduct.IsActive=true;
    	oProduct.MSRP_EMEA_APAC_USD__c=10;
    	oProduct.MSRP_EMEA_EUR__c=10;
    	oProduct.MSRP_EMEA_GBP__c=10;
    	oProduct.MSRP_US_STANDARD_USD__c=10;
    	oProduct.ProductCode='TEST';
    	update oProduct;

		Lead oLead = new Lead(LastName='Test',Company='Test',Status='Registration Submitted');
		insert oLead;
		Lead_Product__c oLeadProduct1 = new Lead_Product__c(Lead__c=oLead.Id, Product__c=oProduct.Id, Quantity__c=10);
		listLeadProducts.add(oLeadProduct1);
		Lead_Product__c oLeadProduct2 = new Lead_Product__c(Lead__c=oLead.Id, Product__c=oProduct.Id, Quantity__c=10);
		listLeadProducts.add(oLeadProduct2);
		insert listLeadProducts;
		delete oLeadProduct1;
	}
}