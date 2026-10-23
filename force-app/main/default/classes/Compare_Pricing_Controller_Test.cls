/*
	Test class for Compare_Pricing_Controller.cls.

	MOD DATE		Who						Description
	06/04/2015		Chris Noe				Initial Release
*/

@isTest
private class Compare_Pricing_Controller_Test {
    //Test data setup method
    @testSetup
    static void testDataSetup() {
		//Create Account for testing
		Account oNewAccount = Test_Environment_Utility.createInsertAccountUS();

		//Create Products for testing
    	List<Product2> listProducts = Test_Environment_Utility.generateFGProducts(6, true);

    	//Generate standard prices
    	Map<Id, Decimal> mapStandardProductPrices = Test_Environment_Utility.generateProductPrices(listProducts, 100);
    	List<PricebookEntry> listStdPricebookEntries = Test_Environment_Utility.generatePricebookEntries(mapStandardProductPrices, Test.getStandardPricebookId(), true);

    	//Create non Standard Pricebook for testing
    	Pricebook2 oNonStandardPricebook = Test_Environment_Utility.generatePricebooks(1, true).get(0);

    	//Crate non standard pricebook entries
    	List<PricebookEntry> listNonStdPricebookEntries = Test_Environment_Utility.generatePricebookEntries(mapStandardProductPrices, oNonStandardPricebook.Id, true);
        listNonStdPricebookEntries = [select Id, Product2Id, ProductCode from PricebookEntry where Id in :listNonStdPricebookEntries];

		//Create Opportunity for testing
		Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oNewAccount, 'Prospecting', Date.today());

    	//Add line items to the opportunities
    	List<OpportunityLineItem> listOpptyLineItems = new List<OpportunityLineItem>();

    	listOpptyLineItems.add(new OpportunityLineItem (
													OpportunityId=oOpportunity.Id,
													PricebookEntryId=listNonStdPricebookEntries[0].Id,
													Quantity=100,
													UnitPrice=100,
													Target_End_User_Price__c=100,
                                                    Rebate_Amount__c=20,
													Estimated_Distribution_Margin__c=5,
													Estimated_Reseller_Margin__c=10));

        listOpptyLineItems.add(new OpportunityLineItem (
                                                    OpportunityId=oOpportunity.Id,
                                                    PricebookEntryId=listNonStdPricebookEntries[2].Id,
                                                    Quantity=100,
                                                    UnitPrice=100,
                                                    Target_End_User_Price__c=100,
                                                    Rebate_Amount__c=20,
                                                    Estimated_Distribution_Margin__c=5,
                                                    Estimated_Reseller_Margin__c=10));

        listOpptyLineItems.add(new OpportunityLineItem (
                                                    OpportunityId=oOpportunity.Id,
                                                    PricebookEntryId=listNonStdPricebookEntries[4].Id,
                                                    Quantity=100,
                                                    UnitPrice=100,
                                                    Target_End_User_Price__c=100,
                                                    Rebate_Amount__c=20,
                                                    Estimated_Distribution_Margin__c=5,
                                                    Estimated_Reseller_Margin__c=10));                                                 

    	insert listOpptyLineItems;

    	//Create Approved_Special_Pricing__c records for testing
    	List<Approved_Special_Pricing__c> listASP = new List<Approved_Special_Pricing__c>();
    		
		//Add approved line items below MSRP
        listASP.add(new Approved_Special_Pricing__c(
                                        SPR_Line_Id__c=listNonStdPricebookEntries[1].Id + 'NA',
                                        Opportunity__c=oOpportunity.Id,
                                        Item_Description__c=listNonStdPricebookEntries[1].Product2Id,
                                        Quantity__c=10,
                                        Target_Distribution_Price__c=60,
                                        Item_Number__c=listNonStdPricebookEntries[1].ProductCode,
                                        Rebate_Amount__c=10));

        listASP.add(new Approved_Special_Pricing__c(
                                        SPR_Line_Id__c=listNonStdPricebookEntries[3].Id + 'NA',
                                        Opportunity__c=oOpportunity.Id,
                                        Item_Description__c=listNonStdPricebookEntries[3].Product2Id,
                                        Quantity__c=10,
                                        Target_Distribution_Price__c=60,
                                        Item_Number__c=listNonStdPricebookEntries[3].ProductCode,
                                        Rebate_Amount__c=10));

        listASP.add(new Approved_Special_Pricing__c(
                                        SPR_Line_Id__c=listNonStdPricebookEntries[5].Id + 'NA',
                                        Opportunity__c=oOpportunity.Id,
                                        Item_Description__c=listNonStdPricebookEntries[5].Product2Id,
                                        Quantity__c=10,
                                        Target_Distribution_Price__c=60,
                                        Item_Number__c=listNonStdPricebookEntries[5].ProductCode,
                                        Rebate_Amount__c=10));

		listASP.add(new Approved_Special_Pricing__c(
										SPR_Line_Id__c=listNonStdPricebookEntries[4].Id + 'NA',
										Opportunity__c=oOpportunity.Id,
										Item_Description__c=listNonStdPricebookEntries[4].Product2Id,
										Quantity__c=10,
										Target_Distribution_Price__c=60,
										Item_Number__c=listNonStdPricebookEntries[4].ProductCode,
										Rebate_Amount__c=10));

    	insert listASP;
    }

    static testmethod void testCntrl() {
		//Tests the Compare_Pricing_Controller constructor, inner class, and return methods

		//Retrieve the Opportunity record.
		Opportunity oOpportunity = [select Id, Pricebook2Id, CloseDate from Opportunity];

        //Set page reference
        PageReference oPageRef = Page.ComparePricing;
        Test.setCurrentPage(oPageRef); 
        //Invoke the standard and extension controllers with Opportunity record retrieved above
        ApexPages.StandardController oStdController = new ApexPages.StandardController(oOpportunity);
        oPageRef.getParameters().put('id',String.valueOf(oOpportunity.Id));
        Compare_Pricing_Controller oExtController = new Compare_Pricing_Controller(oStdController);

        //Assert list size of 6
        system.assertEquals(6,oExtController.listProducts.size());

        //Retrieve an Approved_Special_Pricing__c record that is not currently an OpportunityLineItem on the opportunity
        Approved_Special_Pricing__c oApprovedPricing = [select Id, Item_Description__c from Approved_Special_Pricing__c 
                            where Item_Description__c not in(select Product2Id from OpportunityLineItem) limit 1];

        //Set the Approved_Special_Pricing__c value on the controller extension
        oExtController.sApprovedPartId=oApprovedPricing.Id;

        //Call the addToSalesforce method
        system.assertEquals('/apex/comparepricing?id=' + oOpportunity.Id,oExtController.addToSalesforce().getURL());

        //Assert that Approved_Special_Pricing__c item exists as an OpportunityLineItem
        system.assertEquals(oApprovedPricing.Item_Description__c,[select Product2Id from OpportunityLineItem where Product2Id=:oApprovedPricing.Item_Description__c].Product2Id);

        //Return to opportunity
        system.assertEquals('/' + oOpportunity.Id, oExtController.returnToOpportunity().getURL());
    }
}