/*
	Test class for Seed_Approval_Message_Controller.cls.

	MOD DATE		Who						Description
	4/14/2014		Chris Noe				Initial Release
	6/24/2014		Chris Noe				Updated to use Test_Environment_Utility methods for creating data
*/

@isTest
private class Seed_Approval_Message_Controller_Test {
	
	static testmethod void testApprovalMessageDisplay() {
		//Create account for test
		Account oAccount = Test_Environment_Utility.createInsertAccountUS();
        //Create contact for testing
        Contact oContact = Test_Environment_Utility.createInsertContact(oAccount);
        //Create product for test
        Product2 oProduct = Test_Environment_Utility.createInsertProduct();
        oProduct.Seed_Unit_Eligible_Hospital__c=true;
        update oProduct;
        
        //Create opportunity for test
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccount, 'Test', Date.today());
		
		//Create seed unit order for test
		Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Hospital', oAccount, oContact);
		
		//Create seed unit product for test
		Seed_Unit_Product__c oSeedUnitProduct = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProduct, 1);
		
		Test.startTest();
			PageReference oPageRef = Page.SeedApprovalMessage;
            Test.setCurrentPage(oPageRef); 
			//Invoke the standard and extension controllers with seed unit order created above
			ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
			oPageRef.getParameters().put('id',String.valueOf(oSeedUnitOrder.Id));
			Seed_Approval_Message_Controller oExtController = new Seed_Approval_Message_Controller(oStdController);
			
			//Assertion statement for eligible products flag		
			system.assertEquals(false, oExtController.bContainsNotEligibleProducts);
			
			//Update the Seed_Unit_Location_Type__c field to make the selected product ineligible
			oSeedUnitOrder.Seed_Unit_Location_Type__c='Education';
			update oSeedUnitOrder;
			
			//Invoke the standard and extension controllers with seed unit order updated above
			ApexPages.StandardController oStdControllerUpdate = new ApexPages.StandardController(oSeedUnitOrder);
			Seed_Approval_Message_Controller oExtControllerUpdate = new Seed_Approval_Message_Controller(oStdControllerUpdate);
			
			//Assertion statement for eligible products flag		
			system.assertEquals(true, oExtControllerUpdate.bContainsNotEligibleProducts);	
		Test.stopTest();	
	}
}