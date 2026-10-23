/* 
Test class: AccountTriggerHelperTest
10.21.2021	Sophia Murphy (Demand Chain)
			DC Case 10680: Fixed issue with addresses setting and resetting
08.09.2023	Esau Sanchez: Logic changed to consider party and site record types.
 */
public with sharing class AccountTriggerHelper {

	public static Void AccountOracleAddress() {
		List<String> addressLines = new List<String>();
		Integer lineCounter = 0;
        Map<String, List<Account>> countryCodeToAccountMap = new Map<String, List<Account>>();

		for (Account acct : (list<Account>)trigger.new) {
			// This section will parse out the Billing Address and split it into the Oracle Address fields for any NON-ORACLE-SOURCED Site
			if ( (	(acct.Oracle_Site_Id__c == null && acct.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId()) || 
					(acct.Oracle_Site_Id__c == null && acct.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('Party').getRecordTypeId()) ) && 
					acct.BillingStreet != null) {

				addressLines = acct.BillingStreet.split('\r\n');

				// Safety check if there are no hard returns in the address
				if(addressLines.isEmpty()) {
					addressLines.add(acct.BillingStreet);
				}

				System.debug('DC: addressLines: ' + addressLines);

				String line1 = addressLines[0];
				String line2 = '';
				if(addressLines.size() > 1 && addressLines[1] != null) {
					line2 = addressLines[1];
				}
				String line3 = '';
				if(addressLines.size() > 2 && addressLines[2] != null) {
					line3 = addressLines[2];
				}
				String line4 = '';
				if(addressLines.size() > 3 && addressLines[3] != null) {
					line4 = addressLines[3];
				}

				if(acct.Oracle_Address_1__c != line1) {
					acct.Oracle_Address_1__c = line1;
				}
				if(acct.Oracle_Address_2__c != line2) {
					acct.Oracle_Address_2__c = line2;
				}
				if(acct.Oracle_Address_3__c != line3) {
					acct.Oracle_Address_3__c = line3;
				}
				if(acct.Oracle_Address_4__c != line4) {
					acct.Oracle_Address_4__c = line4;
				}

				/**
				acct.Oracle_Address_1__c = '';
				acct.Oracle_Address_2__c = '';
				acct.Oracle_Address_3__c = '';
				acct.Oracle_Address_4__c = '';
		        for (String addrLine : addressLines) {
		            // Take Lines and populate Oracle_Address_1/2/3/4
		            if (lineCounter == 0 && !String.isBlank(addrLine)){
		                acct.Oracle_Address_1__c = addrLine;
		            }else if (lineCounter == 1 && !String.isBlank(addrLine)){
		                acct.Oracle_Address_2__c = addrLine;
		            }else if (lineCounter == 2 && !String.isBlank(addrLine)){
		                acct.Oracle_Address_3__c = addrLine;
		            }else if (lineCounter >= 3 && !String.isBlank(addrLine)){
		                acct.Oracle_Address_4__c += addrLine + ' ';
		            }
		            // Increment Line Counter
		            lineCounter++;
		        }
				*/
	       		// Set City/State/Country/Postal from Billing______ component fields
	        	acct.Oracle_City__c = acct.BillingCity;
	        	acct.Oracle_Country__c = acct.BillingCountryCode;
	        	acct.Oracle_State__c = acct.BillingStateCode;
	        	acct.Oracle_Postal_Code__c = acct.BillingPostalCode;
				 
			}

			// For ORACLE-SOURCED sites, copy Oracle Address information to Account.BillingAddress
			if(acct.Oracle_Site_Id__c != null || acct.Oracle_Party_Id__c != null)  {
				// Concatenate Oracle_Address_1/2/3/4 to BillingStreet
				acct.BillingStreet = acct.Oracle_Address_1__c;
                acct.BillingStreet += getStreet(acct.Oracle_Address_2__c);
                acct.BillingStreet += getStreet(acct.Oracle_Address_3__c);
                acct.BillingStreet += getStreet(acct.Oracle_Address_4__c);
	        	acct.BillingCity = acct.Oracle_City__c;
	        	acct.BillingCountryCode = acct.Oracle_Country__c;
	        	acct.BillingStateCode = acct.Oracle_State__c;
	        	acct.BillingPostalCode = acct.Oracle_Postal_Code__c;
			}

            //DC Case SR-1094 - Updating Region / Sub Region based on Country Code.
            if(
                !String.isEmpty(acct.BillingCountryCode) &&
                (Trigger.isInsert || ((Account)Trigger.oldMap.get(acct.Id)).BillingCountryCode != acct.BillingCountryCode)){
                List<Account> accounts = countryCodeToAccountMap.get(acct.BillingCountryCode);
                if(accounts == null){
                    accounts = new List<Account>();
                    countryCodeToAccountMap.put(acct.BillingCountryCode, accounts);
                }
                accounts.add(acct);
            }
	    }

        if(!countryCodeToAccountMap.values().isEmpty()){
            for(Region_Mapping__c rm :
                [Select
                    Id,
                    Country__c,
                    Region__c,
                    Sub_Region__c
                 From
                    Region_Mapping__c
                 Where
                    Country__c in :countryCodeToAccountMap.keySet()]){
                for(Account acct : countryCodeToAccountMap.get(rm.Country__c)){
                    acct.Region__c = rm.Region__c;
                    acct.Sub_Region__c = rm.Sub_Region__c;
                }
            }
        }
	}

    private static String getStreet(String street){
		//First - we are looking for new lines in the SF to Oracle addresses - 
		// so we should be putting new lines in here. 
        //return String.isEmpty(street) ? '' : ' ' + street;
		return String.isEmpty(street) ? '' : '\r\n' + street;
    }
}