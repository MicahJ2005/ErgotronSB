trigger ContractLineItem_Trigger on ContractLineItem (before insert,before update,before delete,after insert,after update,after delete,after undelete) {
	
	// Add Entitlements
	if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
		ServiceContractLineMethods.AddEntitlements(trigger.newMap);
	}

	// Move Contract End Date to Asset if assigned
	if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
		Map<Id, Date> mapAssetsToUpdate = new Map<Id, Date>();
		for(ContractLineItem objCLI : Trigger.new) {
			if(String.isNotBlank(String.valueOf(objCLI.EndDate)) && String.isNotBlank(objCLI.AssetId)) {
				mapAssetsToUpdate.put(objCLI.AssetId, objCLI.EndDate);
			}
		}

		List<Asset> lstAssetsToUpdate = new List<Asset>();
		for(Id objId : mapAssetsToUpdate.keySet()) {
			lstAssetsToUpdate.add(new Asset(Id=objId, Latest_Service_Contract_Date__c=mapAssetsToUpdate.get(objId)));
		}

		if(!lstAssetsToUpdate.isEmpty()) {
			update lstAssetsToUpdate;
		}
	}

	// Fire Last Contract Date data copy up to Account
	if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
		Set<Id> setSCIds = new Set<Id>();
		for(ContractLineItem objCLI : Trigger.new) {
			setSCIds.add(objCLI.ServiceContractId);
		}

		Set<Id> setAccountIds = new Set<Id>();
		for(ServiceContract objSC : [SELECT Id, AccountId FROM ServiceContract WHERE Id IN :setSCIds]) {
			setAccountIds.add(objSC.AccountId);
		}

		if(!setAccountIds.isEmpty()) {
			AccountMethods.computeAccountLatestContractDate(setAccountIds);
		}
	}
}