trigger caseCount on Case(after insert, after update, after delete) {
    //Getting the ProcessSwitches custom setting value that is relevant to our running user
    if(BypassTriggers.bypass()){
        return;
    }

    List<Case> lstCase = new List<Case>();

    if (Trigger.isDelete) {
        lstCase = [SELECT Id, AccountId FROM Case WHERE Id IN :Trigger.oldMap.keyset()];
    } else {
        lstCase = [SELECT id, AccountId FROM Case WHERE id IN :Trigger.newmap.keyset()];
    }

    set<Id> sAccId = new Set<Id>();
    for (Case cs : lstCase) {
        if (cs.AccountId != null) {
            sAccId.add(cs.AccountId);
        }
    }
    if (sAccId != null && sAccId.size() > 0) {
        List<Account> lstAccount = [SELECT id, Open_Cases__c, (SELECT id FROM Cases WHERE IsClosed = FALSE) FROM Account WHERE id IN :sAccId];
        if (lstAccount.size() > 0) {
            for (Account acc : lstAccount) {
                acc.Open_Cases__c = acc.Cases.size();
            }

            update lstAccount;
        }
    }
}