/*
	Trigger for Opportunity object.
	+ Before Insert Logic - calls method setOpportunityPriceBook on the Opportunity_Utility.cls to set the pricebook for the opportunity
	based on the opportunity record type selected.
	+ After Insert Logic - calls method populateDefaultDistributionPartners on the Opportunity_Utility.cls to populate the default distributors
	based on the Account.CountryCode value.
	+ Before Delete Logic - Prevents the deletion of opportunities that have seed unit orders associated with them.
	
	MOD DATE		Who						Description
	2/10/2014		Chris Noe				Initial Release
	5/20/2014		Chris Noe				Added after insert logic to set default distributors
	4/20/2015 		Chris Noe 				Added before delete logic to prevent deletion of Opportunities that have seed unit orders associated with them.
	4/20/2015 		Matthew Lennington 		Added Bypass. 	EOM-757

*/

trigger Opportunity_Trigger on Opportunity (before insert, after insert, before delete, after update, before update) {

    if(BypassTriggers.bypass()){
        return;
    }
	
	//Before Insert Logic
	if(trigger.isBefore && trigger.isInsert){
		//Call method setOpportunityPriceBook on the Opportunity_Utility.cls to set the pricebook for the opportunity based on the opportunity record type selected.
		Opportunity_Utility.setOpportunityPriceBook(trigger.new);
	}
	
	//After Insert Logic
    if(trigger.isAfter && trigger.isInsert){
        //Call method populateDefaultDistributionPartners on the Opportunity_Utility.cls to add default distributors to Ergotron Forecast Opportunities
        //except when the opportunity is marked as a clone by the superclone app and the is_cloned__c field.
        List<Opportunity> setOpptys = new List<Opportunity>();
        for (Opportunity oppty : trigger.new){
            if (oppty.Is_Cloned__c == false){
                setOpptys.add(oppty);
            }
        }
        if (!setOpptys.isEmpty()){
            Opportunity_Utility.populateDefaultDistributionPartners(setOpptys);
        }
        
		// call method to recalculate rebates if the SPR/SDO field is filled in
		List<Opportunity> lstRebateOpps = new List<Opportunity>();
		for(Opportunity objOpp : Trigger.new) {
			if(!String.isBlank(objOpp.Related_SPR_parent__c)) {
				lstRebateOpps.add(objOpp);
			}
		}

		if(!lstRebateOpps.isEmpty()) {
			Opportunity_Utility.populateSPRRebatesOnSDOs(JSON.serialize(lstRebateOpps));
		}
	}
/* ::: No need to checkSeedOrders - The Seed_Unit_Order__c object is not used anymore. :::
	//Before Delete Logic
	if(trigger.isBefore && trigger.isDelete){
		//Call method checkSeedOrders to prevent the deletion of opportunities that contain seed unit orders.
		Opportunity_Utility.checkSeedOrders(trigger.old);
	}
 */

	//After Update Logic
	if(trigger.isAfter && trigger.isUpdate){
		//Call utility method to update line items if changes to Gov_Ed_Checkbox__c or Partner_Loyalty__c where made.
		Opportunity_Utility.recalculateLineDiscounts(trigger.new,trigger.oldMap);

		// call method to recalculate rebates if the SPR/SDO field has been CHANGED
		List<Opportunity> lstRebateOpps = new List<Opportunity>();
		for(Opportunity objOpp : Trigger.new) {
			if(objOpp.Related_SPR_parent__c != Trigger.oldMap.get(objOpp.Id).Related_SPR_parent__c) {
				lstRebateOpps.add(objOpp);
			}
		}

		if(!lstRebateOpps.isEmpty() && !System.isFuture() && !System.isBatch()) {
			Opportunity_Utility.populateSPRRebatesOnSDOs(JSON.serialize(lstRebateOpps));
		}

	}

	// before Update
	if(trigger.isBefore && trigger.isUpdate) {
		if(!System.isFuture() && !System.isBatch()) {
			Opportunity_Utility.populateSPRRebatesOnSDOs(JSON.serialize(trigger.new));
		}
	} 
}