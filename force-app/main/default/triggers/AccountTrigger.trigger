trigger AccountTrigger on Account (before insert, after insert, before update, after update) {

	// Set SNAP as 3rd Party Default Service Provider for Sites only ON BEFORE INSERT
	if(Trigger.isBefore && Trigger.isInsert) {
		
		List<Customer_Service_Flow_Variables__c> lstCVar = [SELECT Id, Default_3rd_Party_Service_Provider_Acct__c FROM Customer_Service_Flow_Variables__c WHERE Name = 'Current' LIMIT 1];

		if(!lstCVar.isEmpty()) {
			for(Account objAcct : Trigger.new) {
				if(objAcct.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId()) {
					objAcct.X3rd_Party_Service_Provider__c = lstCVar[0].Default_3rd_Party_Service_Provider_Acct__c;
				}
			}
		}
	}

	// Handle Address Logic
	if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){

		List<Id> lstAccount = new List<Id>();

		for(Account oAccount :trigger.new){
			lstAccount.add(oAccount.Id);
		}

		if(!lstAccount.isEmpty()) {
			AccountTriggerHelper.AccountOracleAddress();
		}
        
	}
	if(Trigger.isAfter && !System.isBatch() && !System.isFuture() && !System.isQueueable()){
		AccountMethods.processBillingInfo(Trigger.new);
	}
}