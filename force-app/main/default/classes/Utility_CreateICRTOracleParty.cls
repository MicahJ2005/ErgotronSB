public class Utility_CreateICRTOracleParty  {
/**
*   {Purpose}	-	Sending ICRT Create Customer to Oracle
*
*   {Contact}   -	support@demandchainsystems.com
*
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date    	Name             		Description
*   20190130	Andy Boettcher DCS		Created
*	20200130	Esau Sanchez			Added US and Canada filter to the county designation
*	20200721	Sophia Murphy DCS		Added LIMIT to postal codes query
*   =============================================================================
*/

	@InvocableMethod(label='Create Oracle Party via ICRT' description='Submits this Site to Oracle to create P/C/S, true if successful, false if failed.')
	//@InvocableMethod
	public static List<String> flowCreateParty(List<Id> lstSiteIds) {

		List<String> lstReturn = new List<String>();

		Account objSiteICRT = [SELECT 
									Id, 
									Name, 
									ParentId, 
									ShippingStreet, 
									ShippingCity, 
									ShippingStateCode, 
									ShippingPostalCode, 
									ShippingCountryCode, 
									BillingStreet, 
									BillingCity, 
									BillingStateCode, 
									BillingPostalCode, 
									BillingCountryCode, 
									Oracle_SiteShipToUseId__c, 
									Oracle_SiteBillToUseId__c, 
									Oracle_Site_Id__c,
									County__c,
                               		Region__c
								FROM 
									Account 
								WHERE 
									Id IN :lstSiteIds
								LIMIT 1
		];

		// Per Carol - substitite out whatever county is in the record with the POSTAL CODES table
        // 20200130 es US Canada filter added
        System.debug('BillingCountry: ' + objSiteICRT.BillingCountryCode);
        IF(objSiteICRT.BillingCountryCode == 'US' || objSiteICRT.BillingCountryCode == 'CA'){
            List<Postal_Code__c> lstPostalCode = [SELECT Id, County__c, City__c FROM Postal_Code__c WHERE From_Postal_Code__c <= :objSiteICRT.BillingPostalCode AND To_Postal_Code__c >= :objSiteICRT.BillingPostalCode LIMIT 100000];			
            if(!lstPostalCode.isEmpty()) {
                // Rules - loop through the postal code list and look for the county first, if the county is found in the range, keep it.  If not, take the first in the list.
                Boolean bolFoundCounty = false;
                for(Postal_Code__c objPC : lstPostalCode) {
                    if(objSiteICRT.County__c == objPC.County__c) {
                        bolFoundCounty = true;
                    }
                }
                if(!bolFoundCounty) {
                    objSiteICRT.County__c = lstPostalCode[0].County__c;
                }
            }
        } //end IF
        
        lstReturn.add(Utility_CreateICRTOracleParty.sendICRTCreateParty(JSON.serialize(objSiteICRT)));
        return lstReturn;

	}

	// @Future(Callout=true)
	public static String sendICRTCreateParty(String strJSONSiteAccount) {

		String strReturn = '';

		// This method will send an ICRT message with an instance of UtilityMethods.oracleNewCustomer
		// and the process the results.

		// Instanciate ICRT Wrapper
		UtilityMethods.oracleNewCustomer clsNewCust = new UtilityMethods.oracleNewCustomer();
		
		// Set Account.Site info
		Account objSite = (Account)JSON.deserializeStrict(strJSONSiteAccount, Account.class);

		clsNewCust.CUST_SOURCE = 'SALESFORCE';
		clsNewCust.BILLTO_ADDRESS1 = objSite.BillingStreet;
		clsNewCust.BILLTO_ADDRESS2 = '';
		clsNewCust.BILLTO_ADDRESS3 = '';
		clsNewCust.BILLTO_ADDRESS4 = '';
		clsNewCust.BILLTO_CITY = objSite.BillingCity;
		clsNewCust.BILLTO_STATE = objSite.BillingStateCode;
		clsNewCust.BILLTO_COUNTY = objSite.County__c;
		clsNewCust.BILLTO_POSTAL_CODE = objSite.BillingPostalCode;
		clsNewCust.BILLTO_COUNTRY = objSite.BillingCountryCode;
		clsNewCust.BILLTO_ADDRESS_INFO_REF = objSite.Id;
		clsNewCust.BILL_TO_SITE_ID = objSite.Oracle_SiteBillToUseId__c;

		clsNewCust.SHIPTO_ADDRESS1 = objSite.BillingStreet;
		clsNewCust.SHIPTO_ADDRESS2 = '';
		clsNewCust.SHIPTO_ADDRESS3 = '';
		clsNewCust.SHIPTO_ADDRESS4 = '';
		clsNewCust.SHIPTO_CITY = objSite.BillingCity;
		clsNewCust.SHIPTO_STATE = objSite.BillingStateCode;
		clsNewCust.SHIPTO_COUNTY = objSite.County__c;
		clsNewCust.SHIPTO_POSTAL_CODE = objSite.BillingPostalCode;
		clsNewCust.SHIPTO_COUNTRY = objSite.BillingCountryCode;
		clsNewCust.SHIPTO_ADDRESS_INFO_REF = objSite.Id;
		clsNewCust.SHIP_TO_SITE_ID = objSite.Oracle_SiteShipToUseId__c;
     	clsNewCust.SHIPTO_REGION = objSite.Region__c;
		
		// Get Account.Customer Info
		Account objCustomer = [SELECT Id, Name, ParentId, Oracle_Customer_Account_Id__c FROM Account WHERE Id = :objSite.ParentId];
		clsNewCust.BILLTO_CUSTOMER_ID = objCustomer.Oracle_Customer_Account_Id__c;
		clsNewCust.BILLTO_CUSTOMER_INFO_REF = objCustomer.Id;
		clsNewCust.BILLTO_CUSTOMER_NAME = objCustomer.Name;

		clsNewCust.SHIPTO_CUSTOMER_ID = objCustomer.Oracle_Customer_Account_Id__c;
		clsNewCust.SHIPTO_CUSTOMER_INFO_REF = objCustomer.Id;
		clsNewCust.SHIPTO_CUSTOMER_NAME = objCustomer.Name;

		// Get Account.Party Info
		Account objParty = [SELECT Id, Name, Oracle_Party_Id__c FROM Account WHERE Id = :objCustomer.ParentId];
		clsNewCust.BILLTO_PARTY_NAME = objParty.Name;
		clsNewCust.BILLTO_PARTY_ID = objParty.Oracle_Party_Id__c;
		clsNewCust.BILLTO_PARTY_INFO_REF = objParty.Id;

		clsNewCust.SHIPTO_PARTY_NAME = objParty.Name;
		clsNewCust.SHIPTO_PARTY_ID = objParty.Oracle_Party_Id__c;
		clsNewCust.SHIPTO_PARTY_INFO_REF = objParty.Id;

		// Create JSON Envelope
		Informatica_CallOut__mdt ic = [SELECT Id, MasterLabel, Callout_URL__c FROM Informatica_CallOut__mdt WHERE MasterLabel = 'ICRT CreateCustomer' LIMIT 1];
		String strEndpoint = ic.Callout_URL__c;

		// Finalize Body
		UtilityMethods.oracleNewCustomerWrapper clsNewCustWrapper = new UtilityMethods.oracleNewCustomerWrapper();
		clsNewCustWrapper.customers.add(clsNewCust);
		System.debug(JSON.serialize(clsNewCustWrapper));
         
        HttpRequest objRequest = new HttpRequest();
        objRequest.setEndpoint(strEndpoint);
        objRequest.setMethod('POST');
        objRequest.setTimeout(60000);
        objRequest.setHeader('Content-Type', 'application/json');
        objRequest.setBody(JSON.serialize(clsNewCustWrapper));

		Http objHttp = new Http();
		HttpResponse objResponse = objHttp.send(objRequest);

        System.Debug('REQUEST: ' + objRequest);
        System.Debug('RESPONSE BODY: ' + objResponse.getBody());
        System.Debug('RESPONSE STATUS: ' + objResponse.getStatus());
        System.Debug('RESPONSE STATUS_CODE: ' + objResponse.getStatusCode());

		String strJSONResp = objResponse.getBody();

		// SUCCESS!  UPDATE!  (200 OK code and not an empty result)
		if(objResponse.getStatusCode() == 200 && strJSONResp.length() > 2) {
			
			HelperOracleOrderReturn hoor = new HelperOracleOrderReturn();
			hoor = HelperOracleOrderReturn.parse(strJSONResp);
			System.debug('hoor.Return_cust_results.BILLTO_ADDRESS_INFO_REF : ' + hoor.Return_cust_results.BILLTO_ADDRESS_INFO_REF);
			System.debug('hoor.BILL_TO_SITE_ID : ' + hoor.Return_cust_results.BILL_TO_SITE_ID);
			System.debug('hoor.BILL_TO_USE_ID : ' + hoor.Return_cust_results.BILL_TO_USE_ID);
			System.debug('hoor.SHIP_TO_USE_ID : ' + hoor.Return_cust_results.SHIP_TO_USE_ID);
			System.debug('hoor.SHIPTO_ADDRESS_INFO_REF : ' + hoor.Return_cust_results.SHIPTO_ADDRESS_INFO_REF);
			System.debug('hoor.SHIPTO_CUSTOMER_INFO_REF : ' + hoor.Return_cust_results.SHIPTO_CUSTOMER_INFO_REF);
			System.debug('hoor.SHIPTO_CUSTOMER_ID : ' + hoor.Return_cust_results.SHIPTO_CUSTOMER_ID);
			System.debug('hoor.SHIPTO_PARTY_INFO_REF : ' + hoor.Return_cust_results.SHIPTO_PARTY_INFO_REF);
			System.debug('hoor.SHIPTO_PARTY_ID : ' + hoor.Return_cust_results.SHIPTO_PARTY_ID);
			System.debug('hoor.PROCESS_MESSAGE : ' + hoor.Return_cust_results.PROCESS_MESSAGE);

			// Get Customer Account Info and commit Oracle Ids back to Salesforce P/C/S
			List<Account> lstUpdateAcct = new List<Account>();
			lstUpdateAcct.add(new Account(
								Id=hoor.Return_cust_results.SHIPTO_ADDRESS_INFO_REF, 
								Oracle_SiteBillToUseId__c=hoor.Return_cust_results.BILL_TO_USE_ID, 
								Oracle_SiteShipToUseId__c=hoor.Return_cust_results.SHIP_TO_USE_ID,
								Oracle_Site_Id__c=hoor.Return_cust_results.BILL_TO_SITE_ID
								
			));

			lstUpdateAcct.add(new Account(
								Id=hoor.Return_cust_results.SHIPTO_CUSTOMER_INFO_REF, 
								Oracle_Customer_Account_Id__c = hoor.Return_cust_results.SHIPTO_CUSTOMER_ID
			));

			lstUpdateAcct.add(new Account(
								Id=hoor.Return_cust_results.SHIPTO_PARTY_INFO_REF, 
								Oracle_Party_Id__c = hoor.Return_cust_results.SHIPTO_PARTY_ID
			));

			update lstUpdateAcct;

			strReturn = hoor.Return_cust_results.PROCESS_MESSAGE;

			// Try and parse out any errors for "friendly" viewing
			if(strReturn.contains('has multiple parents')) {
				strReturn = 'COUNTY ERROR!  Contact the Customer Data Administrator, the specified city has multiple counties in Oracle and cannot be processed at this time.  ' + strReturn;
			}

			if(strReturn.contains('unique constraint')) {
				strReturn = 'RESUBMISSION ERROR!  Contact the Customer Data Administrator, this Site has already been submitted to Oracle and cannot be resubmitted.  If you are seeing this error, there has been an error in the Oracle/Salesforce integration that requires an administrator to intervene.  ' + strReturn;
			}



		} else {
			// ERROR CONDITION!  (500 ERROR or empty return body)
			//hClsCreateCustomerError clsError = (hClsCreateCustomerError)JSON.deserialize(strJSONResp, hClsCreateCustomerError.class);

			System.debug('ORACLE CREATE CUSTOMER ICRT ERROR!!!');
			System.debug(strJSONResp);
			//System.debug(clsError.code);
			//System.debug(clsError.message);

			strReturn = strJSONResp;
		}

		return strReturn;


	}
/*
	public class hClsCreateCustomerError {
		public String code {get;set;}
		public hClsCreateCustomerErrorDetail detail {get;set;}
		public String message {get;set;}
	}

	public class hClsCreateCustomerErrorDetail {
		public String reason {get;set;}
		public String code {get;set;}
		public String details {get;set;}
	}
*/
}