/**
 * @description       : Utility class to handle operations performed on the Contact object.
 * @author            : willh@demandchain.com
 * @group             : 
 * @last modified on  : 04-15-2021
 * @last modified by  : willh@demandchain.com
 * Modifications Log 
 * Ver   Date         Author                  Modification
 * 1.0	 12-16-2014   Chris Noe				  Initial Version
 * 2.0   04-14-2021   willh@demandchain.com   
**/


public without sharing class Contact_Utility {

	public static boolean HasRun = false;
	
	public static void updateLeadPartnerAccount(Map<Id,Contact> mapContacts) {
		//This method will query for Leads where Lead.Partner_Contact__c contains the contact(s) passed to the method and updates the Lead.Partner_Account__c
		//value on the Lead.  This is required when a change to the Account associated with the Contact is made so that the Lead.Partner_Account__c value matches
		//the Account that the Partner_Contact__c is now assigned to.

		//Method variables
		List<Lead> listLeadUpdates = new List<Lead>();

		//Query for all Leads where Partner_Contact__c equals the contacts passed in the map to this method.  Update the Partner_Account__c
		//value to the Account that is now associated with the Contact.
		for(Lead oLead :[select Id, Partner_Account__c, Partner_Contact__c from Lead where Partner_Contact__c in :mapContacts.keySet()]) {
			Lead oLeadUpdate = new Lead();
			oLeadUpdate.Id = oLead.Id;
			oLeadUpdate.Partner_Account__c = mapContacts.get(oLead.Partner_Contact__c).AccountId;
			listLeadUpdates.add(oLeadUpdate);
		} 

		//Update leads
		if(!listLeadUpdates.isEmpty()) {
			update listLeadUpdates;
		}
	}

	/**
	* @description 
	* @author willh@demandchain.com | 04-14-2021 
	* @param List<Contact> contactList 
	* @param Map<ID Contact> ContactMap 
	**/
	public static void updateRegionalMapping(List<Contact> newContactList, Map<ID, Contact> oldContactMap) {
	//Since this is coming from a before trigger; this whole method is wrapped in a try/catch
    //	we don't want anything to prevent this contact from being imported.
    //	Required fields are handled via the UI; and we need to ensure that other integrations
    //	can still get contacts put in without this method hanging them up.
        try {
            Map<String, List<Contact>> countryCodeToContactMap = new Map<String, List<Contact>>();
            For(Contact theContact: newContactList) {
                String oldCountryCode = '';
                
                if(oldContactMap != null) {
                    Contact oldContact = oldContactMap.get(theContact.ID);
                    if(oldContact != null) {
                        oldCountryCode = oldContact.MailingCountryCode;
                    }        
                }
                
                if (theContact.MailingCountryCode != null || theContact.MailingCountryCode != oldCountryCode) {
                    if (countryCodeToContactMap.get(theContact.MailingCountryCode) != null) {
                        countryCodeToContactMap.get(theContact.MailingCountryCode).add(theContact);
                    } else {
                        List<Contact> tempContactList = new List<Contact>();
                        tempContactList.add(theContact);
                        countryCodeToContactMap.put(theContact.MailingCountryCode,tempContactList );
                    }
                }
            }
    
            if(!countryCodeToContactMap.values().isEmpty()){
                for(Region_Mapping__c theRegionalMapping :
                    [Select
                        Id,
                        Country__c,
                        Region__c,
                        Sub_Region__c
                     From
                        Region_Mapping__c
                     Where
                        Country__c in :countryCodeToContactMap.keySet()]){
                    for(Contact theContact : countryCodeToContactMap.get(theRegionalMapping.Country__c)){
                        theContact.Region__c = theRegionalMapping.Region__c;
                        theContact.Sub_Region__c = theRegionalMapping.Sub_Region__c;
                    }
                }
            }
        } catch (Exception e) {}
    }
}