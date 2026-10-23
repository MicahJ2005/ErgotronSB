/*
	Trigger for OpportunityLineItem object.
	+ Before Insert/Update Logic - Calculates discounts on OpportunityLineItem records.

	+ After Insert/Update/Delete Logic - Calls utility method updateProductSchedules which removes all Product_Schedule__c records from the opportunity and 
	recreates them based on the latest quantity schedule associated with each opportunity line item.  This logic was built because there is no way
	to provide accurate revenue reporting based on only a quantity schedule (as of Spring '15').
	
	MOD DATE		Who						Description
	04/28/2015		Chris Noe				Initial Release
	05/07/2015 		Chris Noe 				Added call to utility method updateProductSchedules.
*/

trigger OpportunityLineItem_Trigger on OpportunityLineItem (before insert, before update, after insert, after update, after delete) {

    if(BypassTriggers.bypass()){
        return;
    }
	//Before Insert/Update Logic - Calculate line item discounts, rebates, and target pricing.  This is done via trigger logic as opposed to workflow or 
	//formulas because other workflow field updates depend on these values being set when they are triggered.
	if(GlobalVariables.bFireOpptyLineBeforeTrigger && trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
		//Call utility method to set line item discounts
		OpportunityLineItem_Utility.calculateDiscountsRebatesPricing(trigger.new);
	}

	if(GlobalVariables.bFireOpptyLineAfterTrigger && trigger.isAfter && (trigger.isInsert || trigger.isUpdate || trigger.isDelete)){
        
		//Call utility method to synchronize the Product_Schedule__c records with the current OpportunityLineItemSchedule.
		if(trigger.isDelete) {
			OpportunityLineItem_Utility.updateProductSchedules(trigger.oldMap.keySet());
		}

		else {
/*
            // Edited 20180107 Brandon, Esau, and Andy - stop new SDO opps from auto-creating Product Schedules
            
            // Get all Opportunity Ids from triggered OLIs
            Set<Id> setOppIds = new Set<Id>();
            for(OpportunityLineItem objOLI : trigger.new) {
                setOppIds.add(objOLI.OpportunityId);
            }
            
            // Pull all Opps in scope that are NOT SDO Opps
            Id idSDORT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales Development').getRecordTypeId();
            Map<Id, Opportunity> mapOpps = new Map<Id, Opportunity>([SELECT Id, RecordTypeId FROM Opportunity WHERE Id IN :setOppIds AND RecordTypeId != :idSDORT]);
            
            // Spin through all OLIs and only pass those that are non-SDO OLIs
            Set<Id> setScopeOLIs = new Set<Id>();
            for(OpportunityLineItem objOLI : trigger.new) {
                if(mapOpps.containsKey(objOLI.OpportunityId)) {
                    setScopeOLIs.add(objOLI.Id);
                }
            }
       */     
			OpportunityLineItem_Utility.updateProductSchedules(trigger.newMap.keySet());
			//OpportunityLineItem_Utility.updateProductSchedules(setScopeOLIs);
		}
	}

	// Fire Big Deal Reporting
	if(GlobalVariables.bolFireBigDealReporting) {
		Set<Id> setOpportunityIds = new Set<Id>();
		if(trigger.isDelete) {
			for(OpportunityLineItem objOLI : trigger.old) {
				setOpportunityIds.add(objOLI.OpportunityId);
			}
		} else {
			for(OpportunityLineItem objOLI : trigger.new) {
				setOpportunityIds.add(objOLI.OpportunityId);
			}
		}
		Opportunity_Utility.pullBigDealReportingFields(setOpportunityIds);
	}

	// Recalculate rebates across the opportunity if lines are added
	if(Trigger.isInsert && Trigger.isAfter) {
		Set<Id> setOppIds = new Set<Id>();
		for(OpportunityLineItem objOLI : Trigger.new)  {
			setOppIds.add(objOLI.OpportunityId);
		}

		List<Opportunity> lstOpps = [SELECT Id, Related_SPR_parent__c FROM Opportunity WHERE Id IN :setOppIds];
		if(!lstOpps.isEmpty() && !UtilityMethods.G_bolStopSPRRecursion && !System.isFuture() && !System.isBatch()) {
			Opportunity_Utility.populateSPRRebatesOnSDOs(JSON.serialize(lstOpps));
		}
	}

}