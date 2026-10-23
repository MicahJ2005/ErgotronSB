/*
	Test class for Seed_Product_Override.cls.

	MOD DATE		Who						Description
	4/11/2014		Chris Noe				Initial Release
	6/24/2014		Chris Noe				Updated to use Test_Environment_Utility methods for creating data
*/

@isTest
private class Seed_Product_Override_Test {
	
	static testmethod void testViewRedirect() {
		//Create account for test
		Account oAccount = Test_Environment_Utility.createInsertAccountUS();
        
        //Create contact for testing
        Contact oContact = Test_Environment_Utility.createInsertContact(oAccount);

        //Create product for test
        Product2 oProduct = Test_Environment_Utility.createInsertProduct();
        
        //Create opportunity for test
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccount, 'Test', Date.today());
		
		//Create seed unit order for test
		Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Enterprise', oAccount, oContact);
		
		//Create seed unit product for test
		Seed_Unit_Product__c oSeedUnitProduct = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProduct, 1);
		
		Test.startTest();
			PageReference oPageRef = Page.overrideSeedUnitProductView;
			Test.setCurrentPage(oPageRef);

			ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitProduct);
			oPageRef.getParameters().put('id',String.valueOf(oSeedUnitProduct.Id));
			Seed_Product_Override oExtController = new Seed_Product_Override(oStdController);
			
			PageReference oReturnPageRef = oExtController.RedirectSeedUnitOrder();
			
			system.assertEquals('/' + oSeedUnitOrder.Id, oReturnPageRef.getUrl());	
		Test.stopTest();
	}
}