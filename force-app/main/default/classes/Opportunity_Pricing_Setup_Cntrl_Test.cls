/*
	Test class for Opportunity_Pricing_Setup_Controller.cls.

	MOD DATE		Who						Description
	04/27/2015		Chris Noe				Initial Release
*/

@isTest
private class Opportunity_Pricing_Setup_Cntrl_Test {
    //Test data setup method
    @testSetup
    static void testDataSetup() {

		//Create Account for testing
		Account oNewAccount = Test_Environment_Utility.createInsertAccountUS();

		//Create opportunity for testing
		Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oNewAccount, 'Prospecting', Date.today());

		//Create Products for testing
    	Product2 oProductService = Test_Environment_Utility.createInsertProduct();
    	Map<Id,Decimal> mapProductPrices = new Map<Id,Decimal>();
    	mapProductPrices.put(oProductService.Id,500);

    	//Create Pricebook for testing
    	Pricebook2 oNonStandardPricebook = Test_Environment_Utility.generatePricebooks(1, true).get(0);

    	//Create standard pricebook entry
    	Test_Environment_Utility.generatePricebookEntries(mapProductPrices, Test.getStandardPricebookId(), true);

    	//Crate non standard pricebook entry
    	PricebookEntry oPricebookEntry = Test_Environment_Utility.generatePricebookEntries(mapProductPrices, oNonStandardPricebook.Id, true).get(0);

    	//Add product to opportunity
    	OpportunityLineItem oLine = new OpportunityLineItem();
		oLine.OpportunityId=oOpportunity.Id;
		oLine.PricebookEntryId=oPricebookEntry.Id;
		oLine.Quantity=100;
		oLine.UnitPrice=500;
		oLine.Target_End_User_Price__c=400;
		oLine.Estimated_Distribution_Margin__c=5;
		oLine.Estimated_Reseller_Margin__c=10;

    	insert oLine;
	}

    static testmethod void testCntrl() {
        GlobalVariables.bolFireBigDealReporting = false;
		//Tests the Opportunity_Pricing_Setup_Controller constructor, save, and return methods

		//Retrieve the Opportunity record.
		Opportunity oOpportunity = [select Id, RecordType.DeveloperName, Opportunity_Discount__c from Opportunity limit 1];

        //Set page reference
        PageReference oPageRef = Page.OpportunityPricingSetup;
        Test.setCurrentPage(oPageRef); 
        //Invoke the standard and extension controllers with Opportunity record retrieved above
        ApexPages.StandardController oStdController = new ApexPages.StandardController(oOpportunity);
        oPageRef.getParameters().put('id',String.valueOf(oOpportunity.Id));
        Opportunity_Pricing_Setup_Controller oExtController = new Opportunity_Pricing_Setup_Controller(oStdController);

    	//Update Target_End_User_Price__c on the line item and update
    	oExtController.listOpptyLines[0].Target_End_User_Price__c = 350;
    	system.assertEquals('/apex/opportunitypricingsetup?id=' + oOpportunity.Id, oExtController.saveUpdates().getURL());

        //Set Rebate_Amount__c
        oExtController.listOpptyLines[0].Target_End_User_Price__c = NULL;
        oExtController.listOpptyLines[0].Rebate_Amount__c = 10;
        system.assertEquals('/apex/opportunitypricingsetup?id=' + oOpportunity.Id, oExtController.saveUpdates().getURL());

        //Set Rebate_Amount__c to 0
        oExtController.listOpptyLines[0].Rebate_Amount__c = 0;
        system.assertEquals('/apex/opportunitypricingsetup?id=' + oOpportunity.Id, oExtController.saveUpdates().getURL());

        //Set Product_Discount__c
        oExtController.listOpptyLines[0].Rebate_Amount__c = NULL;
        oExtController.listOpptyLines[0].Product_Discount__c = 5.0;
        system.assertEquals('/apex/opportunitypricingsetup?id=' + oOpportunity.Id, oExtController.saveUpdates().getURL());

        //Set Product_Discount__c to 0
        oExtController.listOpptyLines[0].Product_Discount__c = 0.0;
        system.assertEquals('/apex/opportunitypricingsetup?id=' + oOpportunity.Id, oExtController.saveUpdates().getURL());

        //Set Opportunity_Discount__c
        oExtController.listOpptyLines[0].Product_Discount__c = NULL;
        oExtController.oOpportunity.Opportunity_Discount__c=5.0;
        system.assertEquals('/apex/opportunitypricingsetup?id=' + oOpportunity.Id, oExtController.saveUpdates().getURL());

        //Set Opportunity_Discount__c to 0
        oExtController.oOpportunity.Opportunity_Discount__c=0.0;
        system.assertEquals('/apex/opportunitypricingsetup?id=' + oOpportunity.Id, oExtController.saveUpdates().getURL());

        //Set all discounts to null.  Assert error
        oExtController.listOpptyLines[0].Target_End_User_Price__c = NULL;
        oExtController.listOpptyLines[0].Rebate_Amount__c = NULL;
        oExtController.listOpptyLines[0].Product_Discount__c = NULL;
        oExtController.oOpportunity.Opportunity_Discount__c= NULL;
        //Assert return of null page
        system.assertEquals(null,oExtController.saveUpdates());
        //Assert page messages
        Boolean bFoundMessage=false;
        for(ApexPages.Message oMessage :ApexPages.getMessages()) {
            if(!String.isEmpty(oMessage.getDetail())) {
                bFoundMessage=true;
            }
        }   
        system.assert(bFoundMessage);

        //Update Target_End_User_Price__c on the line item and update
        oExtController.listOpptyLines[0].Target_End_User_Price__c = 350;
        system.assertEquals('/apex/opportunitypricingsetup?id=' + oOpportunity.Id, oExtController.saveUpdates().getURL());

    	//Return to the opportunity
    	system.assertEquals('/' + oOpportunity.Id, oExtController.returnToOppty().getURL());

        //Delete the opportunity and then attempt to save the record (exception test)
        delete oOpportunity;

        //Assert return of null page
        system.assertEquals(null,oExtController.saveUpdates());
        //Assert page messages
        bFoundMessage=false;
        for(ApexPages.Message oMessage :ApexPages.getMessages()) {
            if(!String.isEmpty(oMessage.getDetail())) {
                bFoundMessage=true;
            }
        }   
        system.assert(bFoundMessage);
    }
}