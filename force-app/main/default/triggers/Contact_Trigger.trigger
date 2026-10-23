/*
	Trigger for Contact object.
	+ After Update Logic - calls method updateLeadPartnerAccount on the Contact_Utility.cls to to update the Lead.Partner_Account__c
	field when the Account related to the Contact is changed.  Deal Registration leads have a Partner_Contact__c and a Partner_Account__c value
	and we need the Partner_Account__c value updated if we move the Partner_Contact__c to a different account.
	
	MOD DATE		Who						Description
	12/16/2014		Chris Noe				Initial Release
	20180213		Andy Boettcher			Added conditional code to handle incoming Oracle Contacts
	20180314		Andy Boettcher			Changing incoming Oracle Contact logic to AccountContactRelation
	20180425		Andy Boettcher			Added primary logic to clear AccountContactRelation records if update/AccountId has changed
	20200304		Sophia Murphy			Case 7719 - Commented out setting "Roles" to PARTY
*/

trigger Contact_Trigger on Contact (before insert, after insert, before update, after update) {
    
    if (trigger.isBefore && (trigger.isInsert || trigger.isUpdate)) {
        if(!Contact_Utility.HasRun) {
            Contact_Utility.updateRegionalMapping(trigger.new, trigger.oldMap);
            Contact_Utility.HasRun = true;
        }
    }

    // Remove all AccountContactRelation records if there is an update and the AccountId has changed
    if(trigger.isAfter && trigger.isUpdate) {

        Set<Id> setScopedContacts = new Set<Id>();
        
        for(Contact objCon : trigger.new) {
            if(trigger.oldMap.get(objCon.Id).AccountId != objCon.AccountId) {
                setScopedContacts.add(objCon.Id);
            }
        }
        
        System.Debug(JSON.serialize(setScopedContacts));
        
        if(!setScopedContacts.isEmpty()) {
            System.Debug('Cleaning up ACRs!');
            List<AccountContactRelation> lstDeleteACRs = [SELECT Id FROM AccountContactRelation WHERE ContactId IN :setScopedContacts AND IsDirect = FALSE];
            System.Debug('Deleting ' + JSON.serialize(lstDeleteACRs));
            if(!lstDeleteACRs.isEmpty()) {
                delete lstDeleteACRs;
            }
        }
    }
    
    // Handling incoming ORACLE Contacts - loaded at Site-Level only.
 	if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)) {
        List<AccountContactRelation> lstACRToUpsert = new List<AccountContactRelation>();
 		Set<String> setCustomerIds = new Set<String>();
 		Set<String> setPartyIds = new Set<String>();
 		Map<Id, List<AccountContactRelation>> mapExistingACRs = new Map<Id, List<AccountContactRelation>>();

 		for(Contact objCon : trigger.new) {
            if(objCon.Oracle_Account_Id__c != null){
 			    setCustomerIds.add(objCon.Oracle_Account_Id__c);
            }
            if(objCon.Oracle_Party_Id__c != null){
 			    setPartyIds.add(objCon.Oracle_Party_Id__c);
            }
 			mapExistingACRs.put(objCon.Id, new List<AccountContactRelation>());
 		}

 		// Get Existing ACR Records - INDIRECT
 		for(AccountContactRelation objACR : [SELECT Id, ContactId, AccountId, Contact_Role_Id__c,IsDirect FROM AccountContactRelation WHERE ContactId IN :trigger.newMap.keySet() AND IsActive=TRUE ]) {
 			if(objACR.IsDirect)
                lstACRToUpsert.add(objACR);
             else 
                mapExistingACRs.get(objACR.ContactId).add(objACR);
 		}

        // Get Existing ACR Records - DIRECT
        // for(AccountContactRelation objACR : [SELECT Id, ContactId, AccountId, Contact_Role_Id__c FROM AccountContactRelation WHERE ContactId IN :trigger.newMap.keySet() AND IsActive=TRUE AND IsDirect=TRUE]) {
        //     lstACRToUpsert.add(objACR);
        // }
        
 		// Get Party Lookup
 		Map<String, Account> mapParties = new Map<String, Account>();
         Map<String, Account> mapCustomers = new Map<String, Account>();
 		for(Account objAcct : [SELECT Id, Oracle_Party_Id__c,Oracle_Customer_Account_Id__c FROM Account WHERE Oracle_Party_Id__c IN :setPartyIds]) {
            if(setPartyIds.contains(objAcct.Oracle_Party_Id__c)){
 			    mapParties.put(objAcct.Oracle_Party_Id__c, objAcct);
            }
            if(setCustomerIds.contains(objAcct.Oracle_Customer_Account_Id__c)){
                mapCustomers.put(objAcct.Oracle_Customer_Account_Id__c, objAcct);
            }
 		}

 		// Get Customer Lookup
 		// for(Account objAcct : [SELECT Id, Oracle_Customer_Account_Id__c FROM Account WHERE Oracle_Customer_Account_Id__c IN :setCustomerIds]) {
 		// 	mapCustomers.put(objAcct.Oracle_Customer_Account_Id__c, objAcct);
 		// }

 		// Bind it all together!
 
 		for(Contact objCon : trigger.new) {
            
            if(!String.isBlank(objCon.Oracle_Party_Id__c) && !String.isBlank(objCon.Oracle_Account_Id__c)) {
            
                List<AccountContactRelation> lstACR = mapExistingACRs.get(objCon.Id);
                
                //05.25.2021 - sophiam@demandchain.com
                //	Case 9999 - added error handling around this next section
                //	were throwing errors when Contact's or Account's had their oracle ids changed or reparented.
                
                try {
                    // CREATE NEW PARTY ACR
                    AccountContactRelation objACRParty = new AccountContactRelation(
                        ContactId = objCon.Id,
                        AccountId = mapParties.get(objCon.Oracle_Party_Id__c).Id,
                        Contact_Role_Id__c = objCon.Oracle_Contact_Role_Id__c //,
                        //Roles = 'PARTY'
                    );
    
                    // CREATE NEW CUSTOMER ACR
                    AccountContactRelation objACRAccount = new AccountContactRelation(
                        ContactId = objCon.Id,
                        AccountId = mapCustomers.get(objCon.Oracle_Account_Id__c).Id,
                        Contact_Role_Id__c = objCon.Oracle_Contact_Role_Id__c,
                        Roles = 'CUSTOMER'
                    );
                
                    // LOOP THROUGH ALL EXISTING ACRs AND TRY TO MATCH, UPDATE CONTACT ROLE ID ON ACCOUNTID MATCH
                    for(AccountContactRelation objACR : lstACR) {
                        
                        if(objACR.AccountId == mapParties.get(objCon.Oracle_Party_Id__c).Id) {
                            objACRParty = objACR;
                            objACRParty.Contact_Role_Id__c = objCon.Oracle_Contact_Role_Id__c;
                            //objACRParty.Roles = 'PARTY';
                        }
                        
                        if(objACR.AccountId == mapCustomers.get(objCon.Oracle_Account_Id__c).Id) {
                            objACRAccount = objACR;
                            objACRAccount.Contact_Role_Id__c = objCon.Oracle_Contact_Role_Id__c;
                            objACRAccount.Roles = 'CUSTOMER';
                        }
                    }
                    
                    lstACRToUpsert.add(objACRParty);
                    lstACRToUpsert.add(objACRAccount);
                    
                } catch(Exception e) {}
            }
 		}

 		if(!lstACRToUpsert.isEmpty() && !Test.isRunningTest()) {
 			upsert lstACRToUpsert;
 		}

 	}   
 
		
	//After update logic
	if(trigger.isAfter && trigger.isUpdate) {
		//Map passed to Contact_Utility.updateLeadPartnerAccount method
		Map<Id,Contact> mapContacts = new Map<Id,Contact>();

		//Loop through each Contact to determine if the AccountId has changed.
		for(Contact oContact : trigger.new) {
			//Check to see if AccountId on the Contact has changed and add to the map
			if(oContact.AccountId!=trigger.oldMap.get(oContact.Id).AccountId){
				mapContacts.put(oContact.Id,oContact);
			}
		}

		if(!mapContacts.isEmpty()) {
			//Map contains contacts with updated account relationships.  Call Contact_Utility.updateLeadPartnerAccount method to update Lead.Partner_Account__c values.
			Contact_Utility.updateLeadPartnerAccount(mapContacts);
		}
	}
}