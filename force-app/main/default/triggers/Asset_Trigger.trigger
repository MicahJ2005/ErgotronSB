trigger Asset_Trigger on Asset (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        AssetTriggerMethods.CalculateWarrantyEndDate(trigger.new, trigger.oldMap);
        if(!System.isFuture() && !System.isBatch()){
            AssetTriggerMethods.PopulateAssetData(trigger.newMap.keySet());
        }
    }
    
    //Update Xively Record if Asset contains CCU Board Serial Number
    
    Set<Id> setAssetsInScope = new Set<Id>();
    
    if(trigger.isAfter && trigger.isInsert){
        for(Asset objAsset : Trigger.new) {
            if(objAsset.CCU_Board__c != null) {
                setAssetsInScope.add(objAsset.Id);
            }
        }
    }
    if (trigger.isUpdate) {
        for(Asset objAsset : Trigger.new) {
            Asset oldObjAsset = Trigger.oldMap.get(objAsset.Id);
            if (oldObjAsset.CCU_Board__c != objAsset.CCU_Board__c && objAsset.CCU_Board__c != null){
                setAssetsInScope.add(objAsset.Id);
            }
        }
    }
    if(!setAssetsInScope.isEmpty()) {
        KinnexCallouts.doKinnexCallout(setAssetsInScope);
    }
}