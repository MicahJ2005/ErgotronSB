/*
	Trigger for Opportunity_Partner__c object.
	+ After Insert/Update Logic - Sets the Discount_Class__c value on the related opportunity when the Partner_Role__c value is 'Distributor'.
	
	MOD DATE		Who						Description
	06/30/2015		Chris Noe				Initial Release
*/

trigger Opportunity_Partner_Trigger on Opportunity_Partner__c (after insert, after update, after delete) {
	
	if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
		//Call utility method Opportunity_Partner_Utility.updateOpportunityDiscountClass to update the Discount_Class__c value on the related
		//opporutnity record when the Opportunity_Partner__c.Partner_Role__c value is 'Distributor'.

		Opportunity_Partner_Utility.updateOpportunityDiscountClass(trigger.new);
	}

	// Fire Big Deal Reporting
	if(GlobalVariables.bolFireBigDealReporting) {
		Set<Id> setOpportunityIds = new Set<Id>();
		if(trigger.isDelete) {
			for(Opportunity_Partner__c objOPP : trigger.old) {
				setOpportunityIds.add(objOPP.Opportunity__c);
			}
		} else {
			for(Opportunity_Partner__c objOPP : trigger.new) {
				setOpportunityIds.add(objOPP.Opportunity__c);
			}
		}
		Opportunity_Utility.pullBigDealReportingFields(setOpportunityIds);
	}

}