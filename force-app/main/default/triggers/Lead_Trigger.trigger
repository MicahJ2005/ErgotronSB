/*
 * Lead trigger automation:
 * - Before insert/update: updates the Lead owner language code and regional mapping.
 * - After update: handles converted-lead opportunity updates and synchronizes related
 *   Lead Product currency when the Lead currency or Territory Account Manager changes.
 * - Before delete: removes related Lead Product records.
	
	MOD DATE		Who						Description
	2/28/2014		Chris Noe				Initial Release
	11/19/2014		Chris Noe 				Added before delete logic to clean up Lead_Product__c records
	1/27/2015 		Chris Noe 				Added after update logic to populate Partner and Contact roles on converted opportunities.
	2/24/2015 		Chris Noe 				Added before insert, before update logic to update Owner_Language_Code__c value.
	9/29/2026	Esau Sanchez	Retired after-insert Oracle territory assignment callout; endpoint is no longer available.
*/

trigger Lead_Trigger on Lead (after insert, before delete, after update, before insert, before update) {
	

	//Before Delete Logic
	if(trigger.isBefore && trigger.isDelete){
		//Call method cleanupLeadProducts on the Lead_Utility.cls to cleanup any related Lead_Product__c records. This is required because the Lead object cannot be
		//the master object for a custom object and therefor cascade deletes are not applied to related Lead_Product__c records.
		Lead_Utility.cleanupLeadProducts(trigger.old);
	} 

	//After Update Logic
	if(trigger.isUpdate && trigger.isAfter) {
		List<Lead> listLeadsConverted = new List<Lead>();
		List<Id> listLeadIdsCurrency = new List<Id>();

		for(Lead oLead :trigger.new){
			//Check to see if the lead is being converted and if it is being converted into an opportunity.
			if(oLead.IsConverted && !trigger.oldmap.get(oLead.id).IsConverted && oLead.ConvertedOpportunityId!=null){
				listLeadsConverted.add(oLead);
			}

			//Check to see if currency or Territory Account Manager changed on the lead
			if(oLead.CurrencyIsoCode!=trigger.oldmap.get(oLead.Id).CurrencyIsoCode || oLead.Territory_Account_Manager__c!=trigger.oldmap.get(oLead.Id).Territory_Account_Manager__c){
				listLeadIdsCurrency.add(oLead.Id);
			}
		}

		if(!listLeadsConverted.isEmpty()) {
			//Call utility method to add Contact Role and Partner Role to converted Opportunity
			Lead_Utility.leadConvertOpportunityPartnerContactUpdate(listLeadsConverted);

			// Check to see if a Converted Lead Exists and pull over the chosen SUO Product to a $0 OpptyLine Item
			Opportunity_Utility.pullConvertedLeadProduct(listLeadsConverted);
		}

		if(!listLeadIdsCurrency.isEmpty()) {
			//Call utility method to update related Lead_Product__c currency values
			Lead_Utility.updateLeadProductCurrency(listLeadIdsCurrency);
		}
	}

	//Before Insert, Before Update Logic
	if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
		//Call utility method updateOwnerLanguageCode to update the Lead.Owner_Language_Code__c value on each lead.
		Lead_Utility.updateOwnerLanguageCode(trigger.new);
		
		if (!Lead_Utility.HasRun) {
			Lead_Utility.updateRegionalMapping(trigger.new, trigger.oldMap);
			Lead_Utility.HasRun = true;
		}
	}
}