/*
	Class used by the Apex Component OpportunityPartner.component to retrieve the Distributor and Reseller Opportunity Partner records for an opportunity.
	This utility class also handles operations performed on the Opportunity_Partner__c object.

	MOD DATE		Who						Description
	12/08/2014		Chris Noe				Initial Release
	6/29/2015       Chris Noe               Updates for the new Opportunity_Partner__c object - FB-00653.
	6/30/2015 		Chris Noe 				Added method updateOpportunityDiscountClass.
	10/11/2017		DCS - MCS 				Removal Customer_Account__c
*/

public without sharing class Opportunity_Partner_Utility {
	public String sOpportunityId='';				//set by the OpportunityPartner.component
	public List<Opportunity_Partner__c> listPartners = new List<Opportunity_Partner__c>();

	public void setsOpportunityId(String sOpptyId) {
		sOpportunityId = sOpptyId;
	}

	public String getsOpportunityId() {
		return sOpportunityId;
	}

	public List<Opportunity_Partner__c> getlistPartners() {
		if(sOpportunityId!='' && sOpportunityId!=NULL) {
			return [select Partner_Account__r.Name, Partner_Role__c, Partner_Account__r.Oracle_Party_Number__c, Partner_Account__r.BillingCity, Partner_Account__r.BillingState, Partner_Account__r.BillingCountry 
					from Opportunity_Partner__c 
					where Opportunity__c=:sOpportunityId and (Partner_Role__c='Distributor' or Partner_Role__c='Reseller') order by Partner_Role__c desc];	
		}
		else {
			return null;
		}
	}

	public static void updateOpportunityDiscountClass(List<Opportunity_Partner__c> listOpptyPartners) {
		//This method updates the Discount_Class__c on the related opportunity when the Opportunity_Partner__c.Partner_Role__c value is 'Distributor'

		//Method variables
		List<Opportunity> listOpptyUpdates = new List<Opportunity>();
		Set<Id> setDistributorAccountIds = new Set<Id>();
		Map<Id,String> mapDiscountClasses = new Map<Id,String>();
		Set<Id> setOpptyIds = new Set<Id>();
		Set<String> setDiscountClasses = new Set<String>{'BROADLINE US DISCOUNT','BROADLINE APAC USD','BROADLINE EMEA','EMEA DIRECT DEALER'};

		//Loop through each Opportunity_Partner__c record passed into the method.  For each record with a Partner_Role__c value of 'Distributor', add the Partner_Account__c
		//id to the set which will be used to query for the Discount Class associated with the distributor.
		for(Opportunity_Partner__c oOpptyPartner :listOpptyPartners) {
			if(oOpptyPartner.Partner_Role__c=='Distributor'){
				setDistributorAccountIds.add(oOpptyPartner.Partner_Account__c);
			}
		}		

		//Query the Customer_Account__c object and get the Discount_Class__c for each account in setDistributorAccountIds.
		for(Account oCustomerAccount :[select Id, Discount_Class__c from Account where Id in :setDistributorAccountIds and Discount_Class__c in :setDiscountClasses]){
			mapDiscountClasses.put(oCustomerAccount.Id,oCustomerAccount.Discount_Class__c);
		}

		//Loop through each Opportunty_Partner__c record and set the Discount_Class__c on the related opportunity based on the discount classes retrieved above.
		for(Opportunity_Partner__c oOpptyPartner :listOpptyPartners) {
			if(oOpptyPartner.Partner_Role__c=='Distributor'){
				//Verify that the opportunity id does not already exist in the set.  We don't want duplicate ids in the listOpptyUpdates.
				if(!setOpptyIds.contains(oOpptyPartner.Opportunity__c)){
					//Verify that the mapDiscountClasses contains a value for the Partner_Account__c on the current Opportunity_Partner__c record
					if(mapDiscountClasses.containsKey(oOpptyPartner.Partner_Account__c)){
						//Add the opportunity id to setOpptyIds to prevent duplicate ids in listOpptyUpdates
						setOpptyIds.add(oOpptyPartner.Opportunity__c);

						//Add the opporutnity and discount class to the list of opportunities to be updated
						listOpptyUpdates.add(new Opportunity(Id=oOpptyPartner.Opportunity__c,Discount_Class__c=mapDiscountClasses.get(oOpptyPartner.Partner_Account__c)));
					}					
				}
			}
		}

		if(!listOpptyPartners.isEmpty()) {
			update listOpptyUpdates;
		}
	}
}