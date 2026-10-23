/*
	Test class for OpportunityLineItem_Utility.cls.

	MOD DATE		Who						Description
	04/27/2015		Chris Noe				Initial Release
    05/08/2015      Chris Noe               Added test method testProductScheduleUpdate.
*/

@isTest
private class OpportunityLineItem_Utility_Test {
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

		//We need a cc_acct_group created...
        ccrz__E_AccountGroup__c cAG = new ccrz__E_AccountGroup__c ();
        cAG.Name = 'Replacement Parts';
		insert cAG;
		
		//Create non Standard Pricebook for testing
    	Pricebook2 oNonStandardPricebook = Test_Environment_Utility.generatePricebooks(1, true).get(0);

    	//Crate non standard pricebook entries
    	List<PricebookEntry> listNonStdPricebookEntries = Test_Environment_Utility.generatePricebookEntries(mapStandardProductPrices, oNonStandardPricebook.Id, true);

		//Create opportunities for testing
		Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oNewAccount, 'Prospecting', Date.today());
        oOpportunity.Partner_Loyalty__c='4';
        oOpportunity.Gov_Ed_Checkbox__c=true;
        oOpportunity.Pricebook2Id = oNonStandardPricebook.Id;
		oOpportunity.SPR_Number__c = 'NA';
		update oOpportunity;
		Opportunity oOpportunityEMEA = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity-EMEA', oNewAccount, 'Prospecting', Date.today());
		oOpportunityEMEA.Pricebook2Id = oNonStandardPricebook.Id;
		oOpportunityEMEA.SPR_Number__c = 'EMEA';
		update oOpportunityEMEA;
		Opportunity oOpportunityAPAC = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity-APAC', oNewAccount, 'Prospecting', Date.today());
		oOpportunityAPAC.Pricebook2Id = oNonStandardPricebook.Id;
		oOpportunityAPAC.SPR_Number__c = 'APAC';
		update oOpportunityAPAC;

    	//Add product lines to the opportunities
    	List<OpportunityLineItem> listOpptyLineItems = new List<OpportunityLineItem>();

    	listOpptyLineItems.add(new OpportunityLineItem (
													OpportunityId=oOpportunity.Id,
													PricebookEntryId=listNonStdPricebookEntries[0].Id,
													Quantity=100,
													UnitPrice=100,
													Target_End_User_Price__c=100,
													Estimated_Distribution_Margin__c=5,
													Estimated_Reseller_Margin__c=10));

    	listOpptyLineItems.add(new OpportunityLineItem (
													OpportunityId=oOpportunityEMEA.Id,
													PricebookEntryId=listNonStdPricebookEntries[0].Id,
													Quantity=100,
													UnitPrice=100,
													Target_End_User_Price__c=100,
													Estimated_Distribution_Margin__c=5,
													Estimated_Reseller_Margin__c=10));

    	listOpptyLineItems.add(new OpportunityLineItem (
													OpportunityId=oOpportunityAPAC.Id,
													PricebookEntryId=listNonStdPricebookEntries[0].Id,
													Quantity=100,
													UnitPrice=100,
													Target_End_User_Price__c=100,
													Estimated_Distribution_Margin__c=5,
													Estimated_Reseller_Margin__c=10));

    	insert listOpptyLineItems;

    	//Create Approved_Special_Pricing__c records for testing
    	List<Approved_Special_Pricing__c> listASP = new List<Approved_Special_Pricing__c>();

    	for(PricebookEntry oPBE :[select UnitPrice, Product2.Id, ProductCode from PricebookEntry where Pricebook2Id=:oNonStandardPricebook.Id]) {
    		
    		//Add approved line items below MSRP
    		listASP.add(new Approved_Special_Pricing__c(
    										SPR_Line_Id__c=oPBE.Id + 'NA',
    										Opportunity__c=oOpportunity.Id,
    										Item_Description__c=oPBE.Product2.Id,
    										Quantity__c=10,
    										Target_Distribution_Price__c=60,
    										Item_Number__c=oPBE.ProductCode,
    										Rebate_Amount__c=10));

    		listASP.add(new Approved_Special_Pricing__c(
    										SPR_Line_Id__c=oPBE.Id + 'EMEA',
    										Opportunity__c=oOpportunityEMEA.Id,
    										Item_Description__c=oPBE.Product2.Id,
    										Quantity__c=10,
    										Target_Distribution_Price__c=60,
    										Item_Number__c=oPBE.ProductCode,
    										Rebate_Amount__c=10));

    		listASP.add(new Approved_Special_Pricing__c(
    										SPR_Line_Id__c=oPBE.Id + 'APAC',
    										Opportunity__c=oOpportunityAPAC.Id,
    										Item_Description__c=oPBE.Product2.Id,
    										Quantity__c=10,
    										Target_Distribution_Price__c=6000,
    										Item_Number__c=oPBE.ProductCode,
    										Rebate_Amount__c=10));
    	}

    	insert listASP;

    	//Create Custom Setting values for testing
    	Default_Margin_Percentage__c oDMP = new Default_Margin_Percentage__c(
    												Default_Distribution_Margin_APAC__c=5,
    												Default_Distribution_Margin_EMEA__c=5,
    												Default_Distribution_Margin_NA__c=5,
    												Default_Reseller_Margin_APAC__c=15,
    												Default_Reseller_Margin_EMEA__c=15,
    												Default_Reseller_Margin_NA__c=15,
                                                    Deal_Reg_Distribution_Margin_APAC__c=5,
                                                    Deal_Reg_Distribution_Margin_EMEA__c=5,
                                                    Deal_Reg_Distribution_Margin_NA__c=5,
                                                    Deal_Reg_Reseller_Margin_APAC__c=15,
                                                    Deal_Reg_Reseller_Margin_EMEA__c=15,
                                                    Deal_Reg_Reseller_Margin_NA__c=15);

    	insert oDMP;
	}

    static testmethod void testSyncBatchJob() {
		Test.startTest();
			String sJob = Database.executeBatch(new OpportunityLineItem_Sync_Batch(), 3);
		Test.stopTest();

		list<AsyncApexJob> listAsyncJob = [select Id from AsyncApexJob where Id=:sJob];
		system.assert(listAsyncJob.size()>0);
	}

    static testmethod void testProductScheduleUpdate() {
        //Verify that 1 Product_Schedule__c record exists for each OpportunityLineItemSchedule record
        Map<String,Product_Schedule__c> mapProductSchedules = new Map<String,Product_Schedule__c>();
        for(Product_Schedule__c oProductSchedule :[select Id, Name, Opportunity__c, Item_Description__c, Opportunity_Line_Item_Id__c, Opportunity_Line_Item_Schedule_Id__c, Scheduled_Date__c,
                                                    Scheduled_Quantity__c, Scheduled_Revenue__c from Product_Schedule__c]) {
            mapProductSchedules.put(oProductSchedule.Opportunity_Line_Item_Schedule_Id__c,oProductSchedule);
        }

        //Loop throught each OpportunityLineItemSchedule record and assert values on the related Product_Schedule__c records
        for(OpportunityLineItemSchedule oLineSchedule :[select Id, OpportunityLineItem.ProductCode, OpportunityLineItem.Product2Id, Quantity, ScheduleDate, OpportunityLineItem.UnitPrice,
                                                            OpportunityLineItem.OpportunityId, OpportunityLineItemId, CurrencyIsoCode from OpportunityLineItemSchedule
                                                            where Type='Quantity']) {
            system.assertEquals(true,mapProductSchedules.containsKey(oLineSchedule.Id));
            system.assertEquals(oLineSchedule.OpportunityLineItem.ProductCode,mapProductSchedules.get(oLineSchedule.Id).Name);
            system.assertEquals(oLineSchedule.OpportunityLineItem.OpportunityId,mapProductSchedules.get(oLineSchedule.Id).Opportunity__c);
            system.assertEquals(oLineSchedule.OpportunityLineItem.Product2Id,mapProductSchedules.get(oLineSchedule.Id).Item_Description__c);
            system.assertEquals(oLineSchedule.OpportunityLineItemId,mapProductSchedules.get(oLineSchedule.Id).Opportunity_Line_Item_Id__c);
            system.assertEquals(oLineSchedule.Id,mapProductSchedules.get(oLineSchedule.Id).Opportunity_Line_Item_Schedule_Id__c);
            system.assertEquals(oLineSchedule.ScheduleDate,mapProductSchedules.get(oLineSchedule.Id).Scheduled_Date__c);
            system.assertEquals(oLineSchedule.Quantity,mapProductSchedules.get(oLineSchedule.Id).Scheduled_Quantity__c);
            system.assertEquals(oLineSchedule.Quantity * oLineSchedule.OpportunityLineItem.UnitPrice,mapProductSchedules.get(oLineSchedule.Id).Scheduled_Revenue__c);
        }

        //Delete all OpportunityLineItem records and assert 0 Product_Schedule__c records.
        delete [select Id from OpportunityLineItem];

        system.assertEquals(true,[select Id from Product_Schedule__c].isEmpty());
    }        
}