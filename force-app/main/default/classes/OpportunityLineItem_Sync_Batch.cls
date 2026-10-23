/*
	Batch class that synchronizes Approved_Special_Pricing__c with OpportunityLineItem.  This batch class calls the OpportunityLineItem_Utility.syncApprovedPricing
	which performs the synchronization between Approved_Special_Pricing__c and OpportunityLineItem.  This batch class is called from an execute anonymous script as
	needed when updates need to occur to synchronize the products.

	MOD DATE		Who						Description
	03/17/2015		Chris Noe				Initial Release
*/

global class OpportunityLineItem_Sync_Batch implements Database.Batchable<sObject>, Database.Stateful{
	//Class variables
	String sQuery;
	
	global OpportunityLineItem_Sync_Batch() {
		//Build the batch query string to get opportunities for sync.
		sQuery = 'select Id from Opportunity where SPR_Number__c!=null and HasOpportunityLineItem=true';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(sQuery);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		//Method variables
		List<Opportunity> listOpportunityScope = new List<Opportunity>();

		//Build list of opportuntities to sync
		for(Sobject s : scope) {
			listOpportunityScope.add((Opportunity)s);
		}

		//Loop through each opportunity returned in and call utility method to sync.
		for(Opportunity oOpportunity : listOpportunityScope){
			OpportunityLineItem_Utility.syncApprovedPricing(oOpportunity.Id);
		}

	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
}