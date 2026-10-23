/*
	Utility class to handle operations performed on the OpportunityLineItem object.

	MOD DATE		Who						Description
	03/17/2015		Chris Noe				Initial Release
	04/28/2015 		Chris Noe 				Added calculateDiscounts method.
	05/08/2015 		Chris Noe 				Added updateProductSchedules method.
*/

public without sharing class OpportunityLineItem_Utility {
	
	public static void syncApprovedPricing(Id idOpptyId) {
		//This method synchronizes the OpportunityLineItem records on an opportunity with the Approved_Special_Pricing__c records.  This method is used in the batch
		//conversion class for the new Target_End_User_Price__c field.

		//Method variables
		Map<String,Approved_Special_Pricing__c> mapApprovedPricing = new Map<String,Approved_Special_Pricing__c>();
		Map<String,PricebookEntry> mapPriceBookEntry = new Map<String,PricebookEntry>();
		Map<String,OpportunityLineItem> mapOpptyLineItem = new Map<String,OpportunityLineItem>();
		List<OpportunityLineItem> listExistingOpptyLines = new List<OpportunityLineItem>();
		List<OpportunityLineItem> listNewOpptyLines = new List<OpportunityLineItem>();
		List<OpportunityLineItemSchedule> listOpptyLineItemSchedules = new List<OpportunityLineItemSchedule>();
		Set<String> setApprovedItemsProcessed = new Set<String>();
		String sRecordTypeNA = 'Ergotron Forecast Opportunity';
		String sRecordTypeEMEA = 'Ergotron Forecast Opportunity-EMEA';
		String sRecordTypeAPAC = 'Ergotron Forecast Opportunity-APAC';
		Decimal dDefaultResellerMargin;		//Default reseller margin % based on geography and will be retrieved from a custom setting
		Decimal dDefaultDistributionMargin;	//Default distribution margin % based on geography and will be retrieved from a custom setting

		//Get Opportunity
		Opportunity oOppty = [select Id, Pricebook2Id, CloseDate, RecordType.Name from Opportunity where Id = :idOpptyId];

		//Retrieve custom settings for default reseller and distribution margin percentages
		Default_Margin_Percentage__c oDefaultMarginSettings = Default_Margin_Percentage__c.getInstance();

		//Set default margin percentage based on opportunity record type.
		if(oOppty.RecordType.Name==sRecordTypeNA){
			dDefaultResellerMargin=oDefaultMarginSettings.Default_Reseller_Margin_NA__c;
			dDefaultDistributionMargin=oDefaultMarginSettings.Default_Distribution_Margin_NA__c;
		}

		else if(oOppty.RecordType.Name==sRecordTypeEMEA){
			dDefaultResellerMargin=oDefaultMarginSettings.Default_Reseller_Margin_EMEA__c;
			dDefaultDistributionMargin=oDefaultMarginSettings.Default_Distribution_Margin_EMEA__c;
		}
		
		else if(oOppty.RecordType.Name==sRecordTypeAPAC){
			dDefaultResellerMargin=oDefaultMarginSettings.Default_Reseller_Margin_APAC__c;
			dDefaultDistributionMargin=oDefaultMarginSettings.Default_Distribution_Margin_APAC__c;
		}

		//Get PricebookEntry records for pricebook selected on opportunity
		for(PricebookEntry oPBE :[select Id, ProductCode, UnitPrice from PricebookEntry where Pricebook2Id = :oOppty.Pricebook2Id and IsActive=true]){
			mapPriceBookEntry.put(oPBE.ProductCode,oPBE);
		}

		//Get opportunity line item records for opportunity
		for(OpportunityLineItem oOpptyLine :[select Id, ProductCode, Item_Type__c from OpportunityLineItem where OpportunityId = :oOppty.Id]){
			mapOpptyLineItem.put(oOpptyLine.ProductCode,oOpptyLine);
		}

		for(Approved_Special_Pricing__c oApprovedPricing :[select Item_Number__c, Rebate_Total__c, Target_Distribution_Price__c, Quantity__c from Approved_Special_Pricing__c where Opportunity__c = :oOppty.Id]){
			//Verify that product sku does not exist multiple times and that the current product exists in the price book
			if(!setApprovedItemsProcessed.contains(oApprovedPricing.Item_Number__c) && mapPriceBookEntry.containsKey(oApprovedPricing.Item_Number__c)){
				if(mapOpptyLineItem.containsKey(oApprovedPricing.Item_Number__c)) {
					OpportunityLineItem oUpdateOpptyLine = new OpportunityLineItem();
					oUpdateOpptyLine.Id=mapOpptyLineItem.get(oApprovedPricing.Item_Number__c).Id;

					//Calculate Target Reseller Price based on default distribution margin for the geography/record type
					Decimal dTargetResellerPrice = oApprovedPricing.Target_Distribution_Price__c / (1 - (dDefaultDistributionMargin/100));
					//Calculate Target End User Price based on default reseller margin for the geography/record type
					Decimal dEndUserTargetPrice = dTargetResellerPrice / (1 - (dDefaultResellerMargin/100));

					//Verify that the calculated end user target price does not exceed the list price in the pricebook
					if(dEndUserTargetPrice<=mapPriceBookEntry.get(oApprovedPricing.Item_Number__c).UnitPrice) {
						//Target end user price is less than MSRP.  Set target end user price to calculated target end user price
						oUpdateOpptyLine.Target_End_User_Price__c=dEndUserTargetPrice;
					}
					else{
						//Target end user price exceeds MSRP.  Set target end user price to list price
						oUpdateOpptyLine.Target_End_User_Price__c=mapPriceBookEntry.get(oApprovedPricing.Item_Number__c).UnitPrice;
					}
					
					oUpdateOpptyLine.Sync_Complete__c=true;
					oUpdateOpptyLine.Estimated_Distribution_Margin__c=dDefaultDistributionMargin;
					oUpdateOpptyLine.Estimated_Reseller_Margin__c=dDefaultResellerMargin;
					listExistingOpptyLines.add(oUpdateOpptyLine);
				}
				else {
					//Product does not exist and needs to be added to this opportunity
					OpportunityLineItem oNewOpptyLine = new OpportunityLineItem();
					oNewOpptyLine.OpportunityId=oOppty.Id;
					oNewOpptyLine.PricebookEntryId=mapPriceBookEntry.get(oApprovedPricing.Item_Number__c).Id;
					
					//Calculate Target Reseller Price based on default distribution margin for the geography/record type
					Decimal dTargetResellerPrice = oApprovedPricing.Target_Distribution_Price__c / (1 - (dDefaultDistributionMargin/100));
					//Calculate Target End User Price based on default reseller margin for the geography/record type
					Decimal dEndUserTargetPrice = dTargetResellerPrice / (1 - (dDefaultResellerMargin/100));

					//Verify that the calculated end user target price does not exceed the list price in the pricebook
					if(dEndUserTargetPrice<=mapPriceBookEntry.get(oApprovedPricing.Item_Number__c).UnitPrice) {
						//Target end user price is less than MSRP.  Set target end user price and sales price to calculated target end user price
						oNewOpptyLine.UnitPrice=dEndUserTargetPrice;
						oNewOpptyLine.Target_End_User_Price__c=dEndUserTargetPrice;
					}
					else{
						//Target end user price exceeds MSRP.  Set target end user price to list price
						oNewOpptyLine.UnitPrice=mapPriceBookEntry.get(oApprovedPricing.Item_Number__c).UnitPrice;
						oNewOpptyLine.Target_End_User_Price__c=mapPriceBookEntry.get(oApprovedPricing.Item_Number__c).UnitPrice;
					}
					
					oNewOpptyLine.Quantity=oApprovedPricing.Quantity__c;
					oNewOpptyLine.Sync_Complete__c=true;
					oNewOpptyLine.Estimated_Distribution_Margin__c=dDefaultDistributionMargin;
					oNewOpptyLine.Estimated_Reseller_Margin__c=dDefaultResellerMargin;
					listNewOpptyLines.add(oNewOpptyLine);
				}				
			}

			setApprovedItemsProcessed.add(oApprovedPricing.Item_Number__c);
		}

		//Update existing opportunity line item records
		if(!listExistingOpptyLines.isEmpty()){
			update listExistingOpptyLines;
		}
		
		//Insert new opportunity line item records
		if(!listNewOpptyLines.isEmpty()){
			insert listNewOpptyLines;

			//Create OpportunityLineItemSchedule quantity records based on the OpportunityLineItem records inserted above.
			//Verify that scheduling is enabled in the org
			Schema.DescribeSObjectResult oDescribe = Product2.SObjectType.getDescribe();
			if(oDescribe.fields.getMap().containsKey('CanUseQuantitySchedule')) {
				//Create OpportunityLineItemSchedule for each OpportunityLineItem
				for(OpportunityLineItem oOpptyLineItem :[select CurrencyIsoCode, Id, Quantity, Opportunity.CloseDate from OpportunityLineItem where Id in :listNewOpptyLines]) {
					OpportunityLineItemSchedule oOpptyLineItemSchedule = new OpportunityLineItemSchedule();
					oOpptyLineItemSchedule.OpportunityLineItemId = oOpptyLineItem.Id;
					oOpptyLineItemSchedule.Quantity = oOpptyLineItem.Quantity;
					oOpptyLineItemSchedule.ScheduleDate = oOppty.CloseDate;
					oOpptyLineItemSchedule.Type = 'Quantity';

					listOpptyLineItemSchedules.add(oOpptyLineItemSchedule);
				}

				if(!listOpptyLineItemSchedules.isEmpty()){
					insert listOpptyLineItemSchedules;
				}
			}
		}
	}

	public static void calculateDiscountsRebatesPricing(List<OpportunityLineItem> listOpptyLines) {
		//Calculates the Cash Discount, Gov/Ed Discount, Partner Loyalty Discount, and VIR Discount for each opportunity line item.
		//Calculates Target_Rebate_Amount__c based on user inputs
		//Calculates Target_End_User_Price__c based on distribution and reseller margins if Discount__c or Opportunity_Discount__c is specified

		//Method variables
		Decimal dEstimatedDistributionMargin;
		Decimal dEstimatedResellerMargin;
		Decimal dTargetRebateAmount;
		Decimal dTargetEndUserPrice;

		for(OpportunityLineItem oOpptyLine :listOpptyLines) {

			//Calculate Target_Rebate_Amount__c value based on the following:
			/*
				1.) Check for product level rebate amount - If Rebate_Amount__c is populated at the product level, then use that as the Target_Rebate_Amount__c.
				2.) Check for product level discount % - If Discount__c is populated at the product level, multiply Product_Discount__c * MSRP__c to calculate the Target_Rebate_Amount__c.
				3.) Check for opportunity level discount - If Opportunity_Discount__c is populated at the opportunity level, multiply Opportunity_Discount__c * MSRP__c 
				to calculate the Target_Rebate_Amount__c.
				4.) Use Target End User Price - If none of the above criteria are met, use Target_End_User_Price__c and estimated reseller/distributor margin to calculate
				Target_Rebate_Amount__c.
			*/
			
			dEstimatedDistributionMargin=oOpptyLine.Estimated_Distribution_Margin__c/100;
			dEstimatedResellerMargin=oOpptyLine.Estimated_Reseller_Margin__c/100;

			if(oOpptyLine.Rebate_Amount__c!=NULL){
				//Calculate Target_Rebate_Amount__c based on OpportunityLineItem Rebate_Amount__c value;
				if(oOpptyLine.Rebate_Amount__c>0.0) {
					dTargetRebateAmount=oOpptyLine.Rebate_Amount__c;
					oOpptyLine.Target_Rebate_Amount__c=dTargetRebateAmount;

					//Update the Target_End_User_Price__c since we are calculating the Target_Rebate_Amount__c based on an opportunity product level rebate amount
					dTargetEndUserPrice=((oOpptyLine.Distribution_List_Price__c-dTargetRebateAmount)/(1-dEstimatedDistributionMargin))/(1-dEstimatedResellerMargin);
					oOpptyLine.Target_End_User_Price__c=dTargetEndUserPrice.setScale(2,RoundingMode.HALF_UP);					
				}

				else{
					//Set Target_Rebate_Amount__c to 0 and Target_End_User_Price__c to MSRP
					oOpptyLine.Target_Rebate_Amount__c=0.0;
					oOpptyLine.Target_End_User_Price__c=oOpptyLine.MSRP__c;
				}

			}
			else if(oOpptyLine.Product_Discount__c!=NULL){
				//Calculate Target_Rebate_Amount__c based on OpportunityLineItem Product_Discount__c value;
				if(oOpptyLine.Product_Discount__c>0.0) {
					dTargetRebateAmount=oOpptyLine.MSRP__c*(oOpptyLine.Product_Discount__c/100);
					oOpptyLine.Target_Rebate_Amount__c=dTargetRebateAmount.setScale(2,RoundingMode.HALF_UP);

					//Update the Target_End_User_Price__c since we are calculating the Target_Rebate_Amount__c based on an opportunity product level discount
					dTargetEndUserPrice=((oOpptyLine.Distribution_List_Price__c-dTargetRebateAmount)/(1-dEstimatedDistributionMargin))/(1-dEstimatedResellerMargin);
					oOpptyLine.Target_End_User_Price__c=dTargetEndUserPrice.setScale(2,RoundingMode.HALF_UP);					
				}

				else{
					//Set Target_Rebate_Amount__c to 0 and Target_End_User_Price__c to MSRP
					oOpptyLine.Target_Rebate_Amount__c=0.0;
					oOpptyLine.Target_End_User_Price__c=oOpptyLine.MSRP__c;
				}

			}
			else if(oOpptyLine.Opportunity_Discount__c!=NULL){
				//Calculate Target_Rebate_Amount__c based on Opportunity_Discount__c value;
				if(oOpptyLine.Opportunity_Discount__c>0.0){
					dTargetRebateAmount=oOpptyLine.MSRP__c*(oOpptyLine.Opportunity_Discount__c/100);
					oOpptyLine.Target_Rebate_Amount__c=dTargetRebateAmount.setScale(2,RoundingMode.HALF_UP);

					//Update the Target_End_User_Price__c since we are calculating the Target_Rebate_Amount__c based on an opportunity level discount
					dTargetEndUserPrice=((oOpptyLine.Distribution_List_Price__c-dTargetRebateAmount)/(1-dEstimatedDistributionMargin))/(1-dEstimatedResellerMargin);
					oOpptyLine.Target_End_User_Price__c=dTargetEndUserPrice.setScale(2,RoundingMode.HALF_UP);					
				}

				else{
					//Set Target_Rebate_Amount__c to 0 and Target_End_User_Price__c to MSRP
					oOpptyLine.Target_Rebate_Amount__c=0.0;
					oOpptyLine.Target_End_User_Price__c=oOpptyLine.MSRP__c;
				}

			}
			else {
				//Calculate Target_Rebate_Amount__c based on Target_End_User_Price__c entered by user.
				if(oOpptyLine.Target_Distribution_Price__c<oOpptyLine.Distribution_List_Price__c) {
					oOpptyLine.Target_Rebate_Amount__c=oOpptyLine.Distribution_List_Price__c-oOpptyLine.Target_Distribution_Price__c;
				}
				else {
					oOpptyLine.Target_Rebate_Amount__c=0;
				}
			}

			//Set Cash Discount to .75% of Distribution List Price
			oOpptyLine.Cash_Discount__c = oOpptyLine.Distribution_List_Price__c * 0.0075;

			//Set VIR Discount to 5% of Distribution List Price
			oOpptyLine.VIR_Discount__c = oOpptyLine.Distribution_List_Price__c * 0.05;

			//Set Gov/Ed Discount to 2% of MSRP if Gov/Ed is checked
			if(oOpptyLine.Gov_Ed__c) {
				oOpptyLine.Gov_Ed_Discount__c = oOpptyLine.MSRP__c * 0.02;
			}
			else{
				oOpptyLine.Gov_Ed_Discount__c = 0;	
			}

			//Set Partner Loyalty Discount if Partner Loyalty % > 0
			if(oOpptyLine.Partner_Loyalty__c>0){
				oOpptyLine.Partner_Loyalty_Discount__c = (oOpptyLine.Partner_Loyalty__c / 100) * oOpptyLine.Distribution_List_Price__c;
			}
			else{
				oOpptyLine.Partner_Loyalty_Discount__c = 0;
			}
		}
	}

	public static void updateProductSchedules(Set<Id> setOpptyLineIds) {
		//This method removes all Product_Schedule__c records from the opportunity and recreates them based on the latest quantity schedule associated with each 
		//opportunity line item.  This logic was built because there is no way to provide accurate revenue reporting based on only a quantity schedule (as of Spring '15').
		
		//Method variables
		List<Product_Schedule__c> listNewProductSchedule = new List<Product_Schedule__c>();

		//Delete existing Product_Schedule__c records for the OpportunityLineItem records being updated
		System.debug('Deleting Product_Schedule__c Records');
        delete [select Id from Product_Schedule__c where Opportunity_Line_Item_Id__c in :setOpptyLineIds];

		//Loop through all of the existing OpportunityLineItemSchedule records for the OpportunityLineItem records being updated and create new Product_Schedule__c records

		for(OpportunityLineItemSchedule oLineItemSchedule :[select Id, 
                                                            OpportunityLineItem.ProductCode, 
                                                            OpportunityLineItem.Product2Id,
                                                            OpportunityLineItem.Product2.Broadline_US_Discount__c,
                                                            OpportunityLineItem.Product2.Broadline_APAC_Discount__c, 
                                                            OpportunityLineItem.Product2.Broadline_EMEA_Discount__c, 
                                                            Quantity, 
                                                            ScheduleDate, 
                                                            OpportunityLineItem.UnitPrice,
                                                            OpportunityLineItem.ListPrice,
                                                            OpportunityLineItem.Target_Rebate_Amount__c,
                                                            OpportunityLineItem.Target_Distribution_Price__c,
															OpportunityLineItem.OpportunityId,
                                                            OpportunityLineItem.Opportunity.Discount_Class__c,
                                                            OpportunityLineItemId, 
                                                            CurrencyIsoCode, 
                                                            OpportunityLineItem.Exclude_From_Pipeline__c
															from OpportunityLineItemSchedule
															where OpportunityLineItemId in :setOpptyLineIds and Type='Quantity']) {
			system.debug('Recreating Product_Schedule__c from OpportunityLineItemSchedule');
			Product_Schedule__c oNewProductSchedule = new Product_Schedule__c();
			oNewProductSchedule.Name=oLineItemSchedule.OpportunityLineItem.ProductCode;
			oNewProductSchedule.Item_Description__c=oLineItemSchedule.OpportunityLineItem.Product2Id;
			oNewProductSchedule.Scheduled_Quantity__c=oLineItemSchedule.Quantity;
			oNewProductSchedule.Scheduled_Revenue__c=oLineItemSchedule.Quantity * oLineItemSchedule.OpportunityLineItem.UnitPrice;
			oNewProductSchedule.Scheduled_Net_Revenue__c=oLineItemSchedule.Quantity * oLineItemSchedule.OpportunityLineItem.Target_Distribution_Price__c;
			oNewProductSchedule.Scheduled_Date__c=oLineItemSchedule.ScheduleDate;
			oNewProductSchedule.Opportunity__c=oLineItemSchedule.OpportunityLineItem.OpportunityId;
			oNewProductSchedule.Opportunity_Line_Item_Id__c=oLineItemSchedule.OpportunityLineItemId;
			oNewProductSchedule.Opportunity_Line_Item_Schedule_Id__c=oLineItemSchedule.Id;
			oNewProductSchedule.CurrencyIsoCode=oLineItemSchedule.CurrencyIsoCode;
			oNewProductSchedule.Exclude_From_Pipeline__c=oLineItemSchedule.OpportunityLineItem.Exclude_From_Pipeline__c;
                                                                
            //The following lines are used for the calculation of the Net Amount field which is used for revenue reporting.
            oNewProductSchedule.Rebate_Amount__c=oLineItemSchedule.OpportunityLineItem.Target_Rebate_Amount__c;
            //Setting the value of the Satandard Distribution Cost for the Product Schedule record.
            switch on oLineItemSchedule.OpportunityLineItem.Opportunity.Discount_Class__c {
                when 'BROADLINE US DISCOUNT'{oNewProductSchedule.Standard_Distribution_Cost__c = 
                    oLineItemSchedule.OpportunityLineItem.ListPrice*(1-oLineItemSchedule.OpportunityLineItem.Product2.Broadline_US_Discount__c/100);}
                when 'BROADLINE APAC USD'{oNewProductSchedule.Standard_Distribution_Cost__c = 
                    oLineItemSchedule.OpportunityLineItem.ListPrice*(1-oLineItemSchedule.OpportunityLineItem.Product2.Broadline_APAC_Discount__c/100);}
                when 'BROADLINE EMEA'{oNewProductSchedule.Standard_Distribution_Cost__c = 
                    oLineItemSchedule.OpportunityLineItem.ListPrice*(1-oLineItemSchedule.OpportunityLineItem.Product2.Broadline_EMEA_Discount__c/100);}
                when else {oNewProductSchedule.Standard_Distribution_Cost__c = oLineItemSchedule.OpportunityLineItem.ListPrice;}
            }
            
            

			listNewProductSchedule.add(oNewProductSchedule);
		}

		if(!listNewProductSchedule.isEmpty()){
			insert listNewProductSchedule;
		}
	}
}