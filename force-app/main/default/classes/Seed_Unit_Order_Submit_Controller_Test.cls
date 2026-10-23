/*
	Test class for Seed_Unit_Order_Submit_Controller.cls

	MOD DATE		Who						Description
	4/23/2014		Chris Noe				Initial Release
*/
@isTest
private class Seed_Unit_Order_Submit_Controller_Test {

    static testMethod void submitSeedUnitOrderTest() {
        //Test method for Seed_Unit_Order_Submit_Controller.submitSeedUnitOrder method
        
        //Create account for testing
        Account oAccount = Test_Environment_Utility.createInsertAccountUS();
        //Create contact for testing
        Contact oContact = Test_Environment_Utility.createInsertContact(oAccount);
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccount, 'Seeding', Date.today());
        //Create seed unit order for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Hospital', oAccount, oContact);
        //Create product for testing
        Product2 oProduct = Test_Environment_Utility.createInsertProduct();
		//Create customer account for testing
		Customer_Account__c oCustomerAccount = Test_Environment_Utility.createInsertCustomerAccount(oAccount);
		
        Test.startTest();
			/*BEGIN SUBMIT TEST: MISSING PRODUCTS*/
			
			//Invoke the standard and extension controllers with seed unit order created above
			ApexPages.StandardController oStdControllerNoProducts = new ApexPages.StandardController(oSeedUnitOrder);
			Seed_Unit_Order_Submit_Controller oExtControllerNoProducts = new Seed_Unit_Order_Submit_Controller(oStdControllerNoProducts);
        	
        	PageReference oTestPageRefNoProducts = oExtControllerNoProducts.submitSeedUnitOrder();
        	
        	//Assert page reference returned for submit - Missing Products
    		System.assertEquals('/apex/seedunitordersummary?id=' + oSeedUnitOrder.Id,oTestPageRefNoProducts.getUrl()); 
    		
    		/*BEGIN SUBMIT TEST: MISSING SHIP TO*/
    		
        	//Create seed unit product for testing
        	Seed_Unit_Product__c oSeedUnitProduct = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProduct, 5);    		    	

			//Query Seed_Unit_Order__c record again to get updated fields
			oSeedUnitOrder = [select Id, Total_Quantity__c, Seed_Unit_Order_Submitted__c, Ineligible_Product_Justification_Long__c, Ship_To_Address1__c, Ship_To_Org_Id__c, Seed_Unit_Approval_Status__c
							from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];   
							
			//Invoke the standard and extension controllers with seed unit order created above
			ApexPages.StandardController oStdControllerNoShipTo = new ApexPages.StandardController(oSeedUnitOrder);
			Seed_Unit_Order_Submit_Controller oExtControllerNoShipTo = new Seed_Unit_Order_Submit_Controller(oStdControllerNoShipTo);
        	
        	PageReference oTestPageRefNoShipTo = oExtControllerNoShipTo.submitSeedUnitOrder();
        	
        	//Assert page reference returned for submit - Missing Ship To
    		System.assertEquals('/apex/seedunitselectshipto?id=' + oSeedUnitOrder.Id,oTestPageRefNoShipTo.getUrl());
    		//Assert boolean flags
    		System.assertEquals(true,oExtControllerNoShipTo.bApprovalRequired);
    		System.assertEquals(true,oExtControllerNoShipTo.bMissingShipToLocation);
    		
    		/*BEGIN SUBMIT TEST: INELIGIBLE PRODUCT, NO JUSTIFICATION*/
    		
    		//Update seed unit order with ship to location
    		oSeedUnitOrder.Ship_To_Org_Id__c = '1000';
    		update oSeedUnitOrder;
    		
			//Query Seed_Unit_Order__c record again to get updated fields
			oSeedUnitOrder = [select Id, Total_Quantity__c, Seed_Unit_Order_Submitted__c, Ineligible_Product_Justification_Long__c, Ship_To_Address1__c, Ship_To_Org_Id__c, Seed_Unit_Approval_Status__c
							from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];   
							
			//Invoke the standard and extension controllers with seed unit order created above
			ApexPages.StandardController oStdControllerProductNotEligible = new ApexPages.StandardController(oSeedUnitOrder);
			Seed_Unit_Order_Submit_Controller oExtControllerProductNotEligible = new Seed_Unit_Order_Submit_Controller(oStdControllerProductNotEligible);
        	
        	PageReference oTestPageRefProductNotEligible = oExtControllerProductNotEligible.submitSeedUnitOrder();
        	
        	//Assert page reference returned for submit - product not eligible, justification required
    		System.assertEquals('/apex/seedproductjustification?id=' + oSeedUnitOrder.Id,oTestPageRefProductNotEligible.getUrl());    	
    		//Assert boolean flags
    		System.assertEquals(true,oExtControllerProductNotEligible.bApprovalRequired);
    		System.assertEquals(false,oExtControllerProductNotEligible.bMissingShipToLocation);
    		
    		/*BEGIN SUBMIT TEST: ALL REQUIRED FIELDS POPULATED*/		
    		
    		//Update seed unit order with a justification
    		oSeedUnitOrder.Ineligible_Product_Justification_Long__c = 'I hereby justify';
    		update oSeedUnitOrder;
    		
			//Query Seed_Unit_Order__c record again to get updated fields
			oSeedUnitOrder = [select Id, Total_Quantity__c, Seed_Unit_Order_Submitted__c, Ineligible_Product_Justification_Long__c, Ship_To_Address1__c, Ship_To_Org_Id__c, Seed_Unit_Approval_Status__c
							from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];   
							
			//Invoke the standard and extension controllers with seed unit order created above
			ApexPages.StandardController oStdControllerSubmitOk = new ApexPages.StandardController(oSeedUnitOrder);
			Seed_Unit_Order_Submit_Controller oExtControllerSubmitOk = new Seed_Unit_Order_Submit_Controller(oStdControllerSubmitOk);
        	
        	PageReference oTestPageRefSubmitOk = oExtControllerSubmitOk.submitSeedUnitOrder();
        	
        	//Assert page reference returned for submit with all required fields populated
    		System.assertEquals('/apex/seedunitorderconfirmation?id=' + oSeedUnitOrder.Id,oTestPageRefSubmitOk.getUrl());       							     
    		//Assert boolean flags
    		System.assertEquals(true,oExtControllerSubmitOk.bApprovalRequired);
    		System.assertEquals(false,oExtControllerSubmitOk.bMissingShipToLocation);
    		        
    		/*BEGIN SUBMIT TEST: ALREADY SUBMITTED*/		
    		
    		//Update seed unit order submitted flag
    		oSeedUnitOrder.Seed_Unit_Order_Submitted__c=true;
    		update oSeedUnitOrder;
    		
			//Query Seed_Unit_Order__c record again to get updated fields
			oSeedUnitOrder = [select Id, Total_Quantity__c, Seed_Unit_Order_Submitted__c, Ineligible_Product_Justification_Long__c, Ship_To_Address1__c, Ship_To_Org_Id__c, Seed_Unit_Approval_Status__c
							from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];   
							
			//Invoke the standard and extension controllers with seed unit order created above
			ApexPages.StandardController oStdControllerAlreadySubmitted = new ApexPages.StandardController(oSeedUnitOrder);
			Seed_Unit_Order_Submit_Controller oExtControllerAlreadySubmitted = new Seed_Unit_Order_Submit_Controller(oStdControllerAlreadySubmitted);
        	
        	PageReference oTestPageRefAlreadySubmitted = oExtControllerAlreadySubmitted.submitSeedUnitOrder();
        	
        	//Assert page reference returned for already submitted
    		System.assertEquals('/apex/seedunitordersummary?id=' + oSeedUnitOrder.Id,oTestPageRefAlreadySubmitted.getUrl());    
    		//Assert boolean flags
    		System.assertEquals(true,oExtControllerAlreadySubmitted.bApprovalRequired);
    		System.assertEquals(false,oExtControllerAlreadySubmitted.bMissingShipToLocation);
    		    		
    		/*BEGIN SUBMIT TEST: PRODUCT ELIGIBLE*/		
    		
    		//Update seed unit order submitted flag
    		oProduct.Seed_Unit_Eligible_Hospital__c=true;
    		update oProduct;
    		
			//Query Seed_Unit_Order__c record again to get updated fields
			oSeedUnitOrder = [select Id, Total_Quantity__c, Seed_Unit_Order_Submitted__c, Ineligible_Product_Justification_Long__c, Ship_To_Address1__c, Ship_To_Org_Id__c, Seed_Unit_Approval_Status__c
							from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];   
							
			//Invoke the standard and extension controllers with seed unit order created above
			ApexPages.StandardController oStdControllerProductEligible = new ApexPages.StandardController(oSeedUnitOrder);
			Seed_Unit_Order_Submit_Controller oExtControllerProductEligible = new Seed_Unit_Order_Submit_Controller(oStdControllerProductEligible);
        	
        	PageReference oTestPageRefProductEligible = oExtControllerProductEligible.submitSeedUnitOrder();
        	
        	//Assert page reference returned for product eligible
    		System.assertEquals('/apex/seedunitordersummary?id=' + oSeedUnitOrder.Id,oTestPageRefProductEligible.getUrl()); 
    		//Assert boolean flags
    		System.assertEquals(false,oExtControllerProductEligible.bApprovalRequired);
    		System.assertEquals(false,oExtControllerProductEligible.bMissingShipToLocation); 		    		     
        Test.stopTest();        
    }
}