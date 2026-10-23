trigger ApprovedSpecialPricing_Trigger on Approved_Special_Pricing__c (after insert, after update)  { 
    if(BypassTriggers.bypass()){
        return;
    }

    Set<Id> setSPRIds = new Set<Id>();
    for(Approved_Special_Pricing__c objSPR : Trigger.new) {
        setSPRIds.add(objSPR.Opportunity__c);
    }

    List<Opportunity> lstLinkedOpps = [SELECT Id, Related_SPR_parent__c FROM Opportunity WHERE Related_SPR_parent__c IN :setSPRIds];

    if(!lstLinkedOpps.isEmpty() && !System.isFuture() && !System.isBatch()) {
        Opportunity_Utility.populateSPRRebatesOnSDOs(JSON.serialize(lstLinkedOpps));
    }

}