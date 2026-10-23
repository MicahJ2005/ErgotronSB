public with sharing class AccountMethods  {
/**
*   {Purpose}  	- Account Trigger Logic Class
*
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 952.223.5604                
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date    	Name             				Description
*   20180414  	Andy Boettcher DCS				Added Header and Documented Class
*	20180906	Andy Boettcher DCS				Added computeAccountLatestContractDate
* 	20191101	Sophia Murphy (Demand Chain) 	Only include Accounts from US or Canada in SmartyStreets
*   =============================================================================
*/

	@Future
	public static void computeAccountLatestContractDate(Set<Id> accountIds) {
		
		List<Account> lstAccountsToUpdate = new List<Account>();
		Map<Id, Date> mapServiceAccountEndDates = new Map<Id, Date>();
        
        // Set all dates to be NULL first
        for(Id objId : accountIds) {
            mapServiceAccountEndDates.put(objId, NULL);
        }
        
        // Issue Aggregate query and update Map with valid Dates
		for(AggregateResult objAR : [SELECT AccountId, MAX(EndDate) MaxEndDate FROM ServiceContract WHERE AccountId IN :accountIds GROUP BY AccountId]) {
			mapServiceAccountEndDates.put((Id)objAR.get('AccountId'), (Date)objAR.get('MaxEndDate'));
		}

		for(Id objId : mapServiceAccountEndDates.keySet()) {
			lstAccountsToUpdate.add(new Account(Id=objId,Service_Contract_Valid_Date__c=mapServiceAccountEndDates.get(objId)));
		}

		if(!lstAccountsToUpdate.isEmpty()) {
			update lstAccountsToUpdate;
		}
				
	}

	/*************************************************
	This method scans the incoming triggered Addresses and sends them to the SmartyStreets API processor
	/*************************************************/	
	public static void processBillingInfo(List<Account> lstAcct){
		Set<Id> setAcctIds = new Set<Id>();
		list<Account> accToProcess = new list<Account>();
		Map<String, Id> mapRT = UtilityMethods.MAP_RECORDTYPES('Account');
		String idAccountParty = mapRT.get('Party');
		String idAccountCustomer = mapRT.get('Customer_Organization');
		String idAccountSite = mapRT.get('Site');

		for(Account objAcct: lstAcct){
			
			// Only include those Accounts that are NOT previously sent over by Oracle and have Billing Address populated.
			if(!objAcct.IsAddressValidated__c && String.isNotBlank(objAcct.BillingStreet) && !System.isQueueable()) {
                
                //11.01.2019 - Sophia Murphy (Demand Chain)
                //Also - only include Accounts from US or Canada
                if(objAcct.BillingCountry == 'United States' || objAcct.BillingCountry == 'Canada') {
                    // Party Record Type
                    if(objAcct.RecordTypeId == idAccountParty && String.isBlank(objAcct.Oracle_Party_Id__c)) {
                        //setAcctIds.add(objAcct.Id);
						accToProcess.add(objAcct);
                    }
    
                    // Customer-Account Record Type
                    if(objAcct.RecordTypeId == idAccountSite && String.isBlank(objAcct.Oracle_Site_Id__c)) {
                        //setAcctIds.add(objAcct.Id);
						accToProcess.add(objAcct);
                    }
               } //END: if(objAcct.BillingCountry == 'United States' || objAcct.BillingCountry == 'Canada')
			}
		}

		// Send the filtered list to the SmartyStreets processor.
		updateBillingInfo(accToProcess);
	}

	/*************************************************
	This method receives Accounts that need to have addresses verified by SmartyStreets.
	/*************************************************/	
	public static void updateBillingInfo(list<Account> setAcctIds){

		System.debug('AccountMethods.updateBillingInfo START - ' + JSON.serialize(setAcctIds));

		List<Account> lstAcct = new List<Account>();
		List<Account> lstUpdateAcct = new List<Account>();
		List<SmartyStreets_Validation_Request> lstSmartyRequest = new List<SmartyStreets_Validation_Request>();
		List<SmartyStreets_Validation_Response> lstResponses = new List<SmartyStreets_Validation_Response>();

		// Iterate through Accounts and create SmartyStreets request envelope
		// if(!setAcctIds.isEmpty()){

			// lstAcct = [SELECT Id
			// 				,BillingCity
			// 				,BillingStreet
			// 				,BillingState
			// 				,BillingCountry
			// 				,BillingPostalCode
			// 			FROM Account WHERE Id in :setAcctIds];

			for(Account a: setAcctIds){

				// Handle Multi-Line Address 1
				String strStreet = a.BillingStreet;
				String strAdditionalStreet = '';
				try {
					List<String> lstStreet = a.BillingStreet.split('\r\n');
					strStreet = lstStreet[0];
					for(Integer i = 0;i<lstStreet.size();i++) {
						
						System.Debug('ADDITIONAL STREET = ' + lstStreet[i]);
						
						if(i>0) {
							strAdditionalStreet = strAdditionalStreet + lstStreet[i];
						}
					}
				} catch(Exception ex) {
					System.Debug('AccountMethods.updateBillingInfo - ATTEMPT TO SPLIT BILLINGSTREET FAILED, FALLING BACK TO JUST BILLINGSTREET');
				}
				

				SmartyStreets_Validation_Request request = new SmartyStreets_Validation_Request();
					request.street = strStreet;
					request.street2 = strAdditionalStreet;
					request.city = a.BillingCity;
					request.state = a.BillingState;
					request.zipcode = a.BillingPostalCode;
					request.input_id = a.Id;
					request.urbanization = '';
					request.secondary = '';
					request.lastline = '';
					request.candidates = 10;
					request.callback = '';
					request.addressee = '';

					System.Debug('REQUEST INSTANCE = ' + JSON.serialize(request));

					lstSmartyRequest.add(request);
			}

			if(!lstSmartyRequest.isEmpty()){
				Queueable_SmartyStreets qc = new Queueable_SmartyStreets(lstSmartyRequest);
				Id jobId = System.enqueueJob(qc);
				System.debug(JSON.serialize(lstSmartyRequest));
				System.debug('SmartyStreets Validating ' + lstSmartyRequest.size() + ' addresses - Queueable APEX JobID: ' + jobId);
			}
		// }
	}
}