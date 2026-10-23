/*
	Trigger for ServiceContract object.
		
	MOD DATE		Who						Description
	20180523		Andy Boettcher			Initial Release
*/

trigger ServiceContract on ServiceContract (after insert, after update, after delete)  { 

	Set<Id> setScopedAccounts = new Set<Id>();
        
	if(Trigger.isDelete) {
        for(ServiceContract objSC : trigger.old) {
            setScopedAccounts.add(objSC.AccountId);
        }
    }
    
    if(trigger.isInsert) {
        for(ServiceContract objSC : trigger.new) {
            setScopedAccounts.add(objSC.AccountId);
        }
    }
    
    if(trigger.isUpdate) {
		for(ServiceContract objSC : trigger.old) {
            setScopedAccounts.add(objSC.AccountId);
        }
        
        for(ServiceContract objSC : trigger.new) {
            setScopedAccounts.add(objSC.AccountId);
        }
    }
    
    // Create zero-based Account list first
    Map<Id, Account> mapAccounts = new Map<Id, Account>([SELECT Id, Number_Of_Service_Contracts__c FROM Account WHERE Id IN :setScopedAccounts]);
    for(Account objAcct : mapAccounts.values()) {
        mapAccounts.get(objAcct.Id).Number_Of_Service_Contracts__c = 0;
    }  
    
    // Perform query and populate with positive values
	if(!mapAccounts.isEmpty()) { 
		List<AggregateResult> lstSC = [SELECT AccountId, COUNT(Id) RecCount FROM ServiceContract WHERE AccountId IN :mapAccounts.keyset() GROUP BY AccountId];
		for(AggregateResult objAR : lstSC) {
			mapAccounts.get((Id)objAR.get('AccountId')).Number_Of_Service_Contracts__c = (Integer)objAR.get('RecCount');
		}
        
        update mapAccounts.values();
        
        // Fire Async Apex to update the Contract Date
		AccountMethods.computeAccountLatestContractDate(mapAccounts.keyset());
        
	}   

}