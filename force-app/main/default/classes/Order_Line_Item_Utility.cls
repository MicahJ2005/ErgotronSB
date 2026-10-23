/*
	Utility class to handle operations performed on the Order_Line_Item__c object.

	MOD DATE		Who						Description
	03/24/2015		Chris Noe				Initial Release
	04/14/2015 		Chris Noe 				Added method updateExchangeRate for FB-00555
*/

public without sharing class Order_Line_Item_Utility {

	public static void updateFiscalDetails(List<Order_Line_Item__c> listOrderLineItems) {
		//This method updates the Shipped_Year__c, Shipped_Quarter__c, and Shipped_Month__c values on each Order Line Item passed into the method based
		//on the custom fiscal year settings.

		//Get Fiscal Years
		List<FiscalYearSettings> listFiscalYears=[select Id,StartDate,EndDate,Name from FiscalYearSettings where YearType='Custom' order by StartDate]; 
		//Get Fiscal Quarters
		List<Period> listFiscalQuarters=[select StartDate,EndDate,Number from Period where Type='Quarter' and FiscalYearSettingsId in :listFiscalYears order by StartDate]; 
		//Get Fiscal Months
		List<Period> listFiscalMonths=[select StartDate,EndDate,Number from Period where Type='Month' and FiscalYearSettingsId in :listFiscalYears order by StartDate]; 


		//Loop through each order line item passed to the method and set the Shipped_Year__c, Shipped_Quarter__c, and Shipped_Month__c values.
		for(Order_Line_Item__c oOrderLineItem :listOrderLineItems){
			
			//Verify that Actual_Shipment_Date__c is populated
			if(oOrderLineItem.Actual_Shipment_Date__c!=NULL){

				//Get Fiscal Year 
				for(FiscalYearSettings oFiscalYear :listFiscalYears){ 
					if(oOrderLineItem.Actual_Shipment_Date__c>=oFiscalYear.StartDate && oOrderLineItem.Actual_Shipment_Date__c<=oFiscalYear.EndDate){ 
						oOrderLineItem.Shipped_Year__c = 'FY ' + oFiscalYear.Name;
						break;
					} 
				}

				//Get Fiscal Quarter 
				for(Period oFiscalQuarter :listFiscalQuarters){ 
					if(oOrderLineItem.Actual_Shipment_Date__c>=oFiscalQuarter.StartDate && oOrderLineItem.Actual_Shipment_Date__c<=oFiscalQuarter.EndDate){ 
						oOrderLineItem.Shipped_Quarter__c = 'Q' + String.valueOf(oFiscalQuarter.Number); 
						break; 
					} 
				} 			
				
				//Get Fiscal Month 
				for(Period oFiscalMonth :listFiscalMonths){ 
					if(oOrderLineItem.Actual_Shipment_Date__c>=oFiscalMonth.StartDate && oOrderLineItem.Actual_Shipment_Date__c<=oFiscalMonth.EndDate){ 
						if(oFiscalMonth.Number==1){ 
							oOrderLineItem.Shipped_Month__c='01-January'; 
						} 
						else if(oFiscalMonth.Number==2){ 
							oOrderLineItem.Shipped_Month__c='02-February'; 
						} 
						else if(oFiscalMonth.Number==3){ 
							oOrderLineItem.Shipped_Month__c='03-March'; 
						} 
						else if(oFiscalMonth.Number==4){ 
							oOrderLineItem.Shipped_Month__c='04-April'; 
						} 
						else if(oFiscalMonth.Number==5){ 
							oOrderLineItem.Shipped_Month__c='05-May'; 
						} 
						else if(oFiscalMonth.Number==6){ 
							oOrderLineItem.Shipped_Month__c='06-June'; 
						} 
						else if(oFiscalMonth.Number==7){ 
							oOrderLineItem.Shipped_Month__c='07-July'; 
						} 
						else if(oFiscalMonth.Number==8){ 
							oOrderLineItem.Shipped_Month__c='08-August'; 
						} 
						else if(oFiscalMonth.Number==9){ 
							oOrderLineItem.Shipped_Month__c='09-September'; 
						} 
						else if(oFiscalMonth.Number==10){ 
							oOrderLineItem.Shipped_Month__c='10-October'; 
						} 
						else if(oFiscalMonth.Number==11){ 
							oOrderLineItem.Shipped_Month__c='11-November'; 
						} 
						else if(oFiscalMonth.Number==12){ 
							oOrderLineItem.Shipped_Month__c='12-December'; 
						}

						break; 
					} 
				}
			}
		}
	}

	public static void updateExchangeRate(List<Order_Line_Item__c> listOrderLineItems) {
		//This method updates the Exchange_Rate__c value on each Order_Line_Item__c record based on the currency assigned and the date of the transaction.  
		//For Order_Line_Item__c records with no Actual_Shipment_Date__c, the Oracle_Creation_Date__c is used to determine which dated exchange rate to use.

		//Method variables
		Map<String,Map<Date,Decimal>> mapConversionRates = new Map<String,Map<Date,Decimal>>();
		Map<Date,Decimal> mapConversionRate = new Map<Date,Decimal>();
		Set<Date> setTrxDates = new Set<Date>();
		Set<String> setCurrencyIsoCodes = new Set<String>();
		String sCurrentIsoCode;

		//Loop through each Order_Line_Item__c passed into the method.  For each transaction, add the transaction date to the currency set for the queries below on 
		//the DatedConversionRate object.
		for(Order_Line_Item__c oLine :listOrderLineItems){
			//Check for USD.  If USD, conversion rate will be set to 1.000000.
			if(oLine.CurrencyIsoCode!='USD') {
				//Add CurrencyCode to set for query below.
				setCurrencyIsoCodes.add(oLine.CurrencyIsoCode);

				//Determine the transaction date.  If the line has an actual shipment date then it will be used as the transaction date. If not, use the Oracle creation date.
				if(oLine.Actual_Shipment_Date__c==NULL) {
					if(oLine.Oracle_Creation_Date__c!=NULL) {
						setTrxDates.add(oLine.Oracle_Creation_Date__c);
					}
				}
				else {
					setTrxDates.add(oLine.Actual_Shipment_Date__c);
				}				
			}
			else{
				oLine.Exchange_Rate__c=1.000000;
			}
		}

		//Get the dated exchange rates based on the transactions dates retrieved above.
		if(!setTrxDates.isEmpty()) {
			//Query DatedConversionRate object based on the dates in the setTrxDates and order by CurrencyIsoCode
			for(DatedConversionRate oDatedRate : [select IsoCode, StartDate, ConversionRate from DatedConversionRate 
													where StartDate in :setTrxDates and IsoCode in :setCurrencyIsoCodes order by IsoCode]) {
				//Populate the conversion rate map with a unique map item for each IsoCode
	    		if(oDatedRate.IsoCode!=sCurrentIsoCode && sCurrentIsoCode!=NULL){
	    			Map<Date,Decimal> mapConversionRateToAdd = new Map<Date,Decimal>();
	    			mapConversionRateToAdd=mapConversionRate.clone();
	    			
	    			mapConversionRates.put(sCurrentIsoCode,mapConversionRateToAdd);
	    			mapConversionRate.clear();
	    			mapConversionRate.put(oDatedRate.StartDate,oDatedRate.ConversionRate);
	    		}	
	    		else {
	    			mapConversionRate.put(oDatedRate.StartDate,oDatedRate.ConversionRate);
	    		}		
	    		
	    		sCurrentIsoCode=oDatedRate.IsoCode;
	    	}
	    	
	    	if(sCurrentIsoCode!=NULL && !mapConversionRate.isEmpty()) {
	    		mapConversionRates.put(sCurrentIsoCode,mapConversionRate);
			}

			if(!mapConversionRates.isEmpty()){
				//Loop through each Order_Line_Item__c passed to the method and populate the Exchange_Rate__c value based on the conversion rates retrieved above.
				for(Order_Line_Item__c oLine :listOrderLineItems){
					//Check to see if the transaction currency exists in the map.
					if(mapConversionRates.containsKey(oLine.CurrencyIsoCode)){
						if(oLine.Actual_Shipment_Date__c==NULL) {
							if(oLine.Oracle_Creation_Date__c!=NULL) {
								//Check to see if a dated exchange rate exists in the map for the line items Oracle creation date.
								if(mapConversionRates.get(oLine.CurrencyIsoCode).containsKey(oLine.Oracle_Creation_Date__c)){
									oLine.Exchange_Rate__c = mapConversionRates.get(oLine.CurrencyIsoCode).get(oLine.Oracle_Creation_Date__c);
								}
							}
						}
						
						else {
							//Check to see if a dated exchange rate exists in the map for the line items actual shipment date.
							if(mapConversionRates.get(oLine.CurrencyIsoCode).containsKey(oLine.Actual_Shipment_Date__c)){
								oLine.Exchange_Rate__c = mapConversionRates.get(oLine.CurrencyIsoCode).get(oLine.Actual_Shipment_Date__c);
							}
						}
					}
				}
			}
		}
	}
}