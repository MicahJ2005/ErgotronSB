//20200304		Sophia Murphy			Case 7719 - Commented out setting "Roles" to PARTY
trigger AccountContactRelation_Trigger on AccountContactRelation (before insert, before update) {
	Map<Id, String> mapContactIdToRoleId = new Map<Id, String>();
	for(AccountContactRelation objACR : trigger.new) {
		mapContactIdToRoleId.put(objACR.ContactId, null);
	}

	for(Contact objCon : [SELECT Id, Oracle_Contact_Role_Id__c FROM Contact WHERE Id IN :mapContactIdToRoleId.keySet()]) {
		mapContactIdToRoleId.put(objCon.Id, objCon.Oracle_Contact_Role_Id__c);
	}

    for(AccountContactRelation objACR : trigger.new) {
        
    	if(objACR.IsDirect) {
            //objACR.Roles = 'SITE';
        }

        if(String.isBlank(String.valueOf(objACR.Contact_Role_Id__c))) {
        	objACR.Contact_Role_Id__c = mapContactIdToRoleId.get(objACR.ContactId);
        }
    }
}