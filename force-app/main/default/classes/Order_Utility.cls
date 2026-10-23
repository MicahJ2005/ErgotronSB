/*
	Utility class to handle operations performed on the Order__c object.

	MOD DATE		Who						Description
	03/24/2015		Chris Noe				Initial Release
	04/07/2015		Chris Noe 				Added method Order_Utility.updateShipToAccountDetails
	10/11/2017      DCS - MCS               Removal Customer_Account__c
	10/08/2018		Esau Sanchez			Method:updateShipToAccountDetails - change field updated from Ship_To_Org_id__c to Ship_To_Party__c
*/

public without sharing class Order_Utility {

	public static void updateFiscalDetails(List<Order__c> listOrders) {
		//This method updates the Booked_Year__c, Booked_Quarter__c, and Booked_Month__c values on each Order passed into the method based
		//on the custom fiscal year settings.

		//Get Fiscal Years
		List<FiscalYearSettings> listFiscalYears=[select Id,StartDate,EndDate,Name from FiscalYearSettings where YearType='Custom' order by StartDate]; 
		//Get Fiscal Quarters
		List<Period> listFiscalQuarters=[select StartDate,EndDate,Number from Period where Type='Quarter' and FiscalYearSettingsId in :listFiscalYears order by StartDate]; 
		//Get Fiscal Months
		List<Period> listFiscalMonths=[select StartDate,EndDate,Number from Period where Type='Month' and FiscalYearSettingsId in :listFiscalYears order by StartDate]; 


		//Loop through each order passed to the method and set the Booked_Year__c, Booked_Quarter__c, and Booked_Month__c values.
		for(Order__c oOrder :listOrders){
			
			//Verify that Booked_Date__c is populated
			if(oOrder.Booked_Date__c!=NULL){

				//Get Fiscal Year 
				for(FiscalYearSettings oFiscalYear :listFiscalYears){ 
					if(oOrder.Booked_Date__c>=oFiscalYear.StartDate && oOrder.Booked_Date__c<=oFiscalYear.EndDate){ 
						oOrder.Booked_Year__c = 'FY ' + oFiscalYear.Name;
						break;
					} 
				}

				//Get Fiscal Quarter 
				for(Period oFiscalQuarter :listFiscalQuarters){ 
					if(oOrder.Booked_Date__c>=oFiscalQuarter.StartDate && oOrder.Booked_Date__c<=oFiscalQuarter.EndDate){ 
						oOrder.Booked_Quarter__c = 'Q' + String.valueOf(oFiscalQuarter.Number); 
						break; 
					} 
				} 			
				
				//Get Fiscal Month 
				for(Period oFiscalMonth :listFiscalMonths){ 
					if(oOrder.Booked_Date__c>=oFiscalMonth.StartDate && oOrder.Booked_Date__c<=oFiscalMonth.EndDate){ 
						if(oFiscalMonth.Number==1){ 
							oOrder.Booked_Month__c='01-January'; 
						} 
						else if(oFiscalMonth.Number==2){ 
							oOrder.Booked_Month__c='02-February'; 
						} 
						else if(oFiscalMonth.Number==3){ 
							oOrder.Booked_Month__c='03-March'; 
						} 
						else if(oFiscalMonth.Number==4){ 
							oOrder.Booked_Month__c='04-April'; 
						} 
						else if(oFiscalMonth.Number==5){ 
							oOrder.Booked_Month__c='05-May'; 
						} 
						else if(oFiscalMonth.Number==6){ 
							oOrder.Booked_Month__c='06-June'; 
						} 
						else if(oFiscalMonth.Number==7){ 
							oOrder.Booked_Month__c='07-July'; 
						} 
						else if(oFiscalMonth.Number==8){ 
							oOrder.Booked_Month__c='08-August'; 
						} 
						else if(oFiscalMonth.Number==9){ 
							oOrder.Booked_Month__c='09-September'; 
						} 
						else if(oFiscalMonth.Number==10){ 
							oOrder.Booked_Month__c='10-October'; 
						} 
						else if(oFiscalMonth.Number==11){ 
							oOrder.Booked_Month__c='11-November'; 
						} 
						else if(oFiscalMonth.Number==12){ 
							oOrder.Booked_Month__c='12-December'; 
						}

						break; 
					} 
				}
			}
		}
	}
    
    public static void updateShipToAccountDetails(List<Order__c> lstOrders) {
        // This method takes the values inserted/updated by Informatica, finds the Sites related, and updates the appropriate lookups.

        Set<String> setBTSUIDs = new Set<String>();
        Set<String> setSTSUIDs = new Set<String>();
        
        for(Order__c objOrder : lstOrders) {
            if(String.isNotEmpty(objOrder.Integration_BTSUID__c)) {
                setBTSUIDs.add(objOrder.Integration_BTSUID__c);
            }
            
            if(String.isNotEmpty(objOrder.Integration_STSUID__c)) {
                setSTSUIDs.add(objOrder.Integration_STSUID__c);
            }
        }
        
		Map<String, Id> mapBTSUIDs = new Map<String, Id>();
        Map<String, Id> mapSTSUIDs = new Map<String, Id>();
        
        for(Account objAcct : [SELECT Id, Oracle_SiteBillToUseId__c FROM Account WHERE Oracle_SiteBillToUseId__c IN :setBTSUIDs]) {
            mapBTSUIDs.put(objAcct.Oracle_SiteBillToUseId__c, objAcct.Id);
        }
        
        for(Account objAcct : [SELECT Id, Oracle_SiteShipToUseId__c FROM Account WHERE Oracle_SiteShipToUseId__c IN :setSTSUIDs]) {
            mapSTSUIDs.put(objAcct.Oracle_SiteShipToUseId__c, objAcct.Id);
        }
        
        // APPLY!
        for(Order__c objOrder : lstOrders) {
            if(String.isNotEmpty(objOrder.Integration_BTSUID__c)) {
                objOrder.Customer__c = mapBTSUIDs.get(objOrder.Integration_BTSUID__c);
                objOrder.Integration_BTSUID__c = null;
            }
            
            if(String.isNotEmpty(objOrder.Integration_STSUID__c)) {
                objOrder.Ship_To_Party__c = mapSTSUIDs.get(objOrder.Integration_STSUID__c);
                objOrder.Integration_STSUID__c = null;
            }
        }
    }

	//public static void updateShipToAccountDetails(List<Order__c> listOrders) {
		////This method populates the Ship_To_Customer_Account__c and Ship_To_Party__c values on each Order__c record passed to the method where the Ship_To_Customer_Account_Number__c
		////is populated and matches to a Customer_Account__c record in Salesforce.  This logic is handled via a trigger as opposed to through the Informatica integration jobs because
		////some Ship_To_Customer_Account_Number__c values may be blank for orders that were cancelled.

		////Method variables
		//Set<String> setCustomerNumbers = new Set<String>();
		//Map<String, Account> mapCustomerAccounts = new Map<String, Account>();

		////Loop through each order passed into the method and add the Ship_To_Customer_Account_Number__c to the set for query
		//for(Order__c oOrder :listOrders) {
		//	if(oOrder.Ship_To_Customer_Account_Number__c!=NULL) {
		//		setCustomerNumbers.add(oOrder.Ship_To_Customer_Account_Number__c);
		//	}
		//}

		////Query for Customer_Account__c records
		//if(!setCustomerNumbers.isEmpty()){
		//	for(Account oCustomerAccount :[select Id, Account_Number__c from Account where Account_Number__c in :setCustomerNumbers]){
		//		if(!mapCustomerAccounts.containsKey(oCustomerAccount.Account_Number__c)){
		//			mapCustomerAccounts.put(oCustomerAccount.Account_Number__c,oCustomerAccount);
		//		}
		//	}
		//}

		////Loop through each order passed to the method and set the Ship_To_Customer_Account__c and Ship_To_Party__c values for all Accounts found in the query above.
		//for(Order__c oOrder :listOrders) {
		//	if(mapCustomerAccounts.containsKey(oOrder.Ship_To_Customer_Account_Number__c)){
		//		oOrder.Ship_To_Customer_Account_new__c = mapCustomerAccounts.get(oOrder.Ship_To_Customer_Account_Number__c).Id;
		//		oOrder.Ship_To_Party__c = mapCustomerAccounts.get(oOrder.Ship_To_Customer_Account_Number__c).Id;
		//	}
		//}
	//}	
}