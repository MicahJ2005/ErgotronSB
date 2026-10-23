public with sharing class ServiceContractLineMethods {
	public static void AddEntitlements(Map<Id,ContractLineItem> mapCLI) {
		Set<Id> setProd = new Set<Id>();
		Set<Id> setCLIIds = new Set<Id>();
		Set<String> setIds = new Set<String>();
		List<ContractLineItem> lstCLI = new List<ContractLineItem>();
		List<ContractLineItem> lstUpdateCLI = new List<ContractLineItem>();
		List<Entitlement> lstInsEnt = new List<Entitlement>();
		Map<Id, Product_Entitlement__c> mapPE = new Map<Id, Product_Entitlement__c>();
		Id PMRtID = Schema.SObjectType.Entitlement.getRecordTypeInfosByName().get('Entitlement').getRecordTypeId();
		Id RtID = Schema.SObjectType.Entitlement.getRecordTypeInfosByName().get('Global Entitlement').getRecordTypeId(); 
		
		lstCLI = [SELECT Id ,PricebookEntry.Product2Id ,ServiceContract.AccountId ,StartDate ,EndDate ,Status ,AssetId ,ServiceContract.Id
										FROM ContractLineItem 
										WHERE Id in :mapCLI.keyset()
											AND Entitlement_Processed__c = false];
		for(ContractLineItem cli:lstCLI){
			setCLIIds.add(cli.Id);
			if(cli.PricebookEntry.Product2Id != null){
				setProd.add(cli.PricebookEntry.Product2Id);
			}
		}
		if(setProd.size()>0){
			for(Product_Entitlement__c pe: [SELECT Id ,Name	,Number_of_Incidents__c	,Entitlement_Process_ID__c ,Product__c
												FROM Product_Entitlement__c
												WHERE Product__c in: setProd]){
				mapPE.put(pe.Id, pe);
				for(ContractLineItem cl: lstCLI){
					String strName;
					if(cl.PricebookEntry.Product2Id == pe.Product__c){
						strName = pe.Product__c + '-' + pe.Id;
						setIds.add(strName);
					}
				}
			}
			for(ContractLineItem li: lstCLI){
				for(String s: setIds){
					String strProd = li.PricebookEntry.Product2Id;
					if(s.startsWith(strProd)){
						String peID = s.substring(s.indexOf('-')+1,s.length());
						if(mapPE.get(peID) != null){
							ContractLineItem c = new ContractLineItem();
								c.Id = li.Id;
								c.Entitlement_Processed__c = true;
							lstUpdateCLI.add(c);

							Entitlement e = new Entitlement();
								e.AccountId = li.ServiceContract.AccountId;
								e.AssetId = li.AssetId;
								e.EndDate = li.EndDate;
								e.Name = mapPE.get(peID).Name;
								e.ServiceContractId = li.ServiceContract.Id;
								e.StartDate = li.StartDate;
								if(String.isBlank(mapPE.get(peID).Entitlement_Process_ID__c)){
									e.IsPerIncident = true;
									e.CasesPerEntitlement = Integer.valueOf(mapPE.get(peID).Number_of_Incidents__c);
									e.RemainingCases = Integer.valueOf(mapPE.get(peID).Number_of_Incidents__c);
									e.PM_Entitlement__c = true;
									e.Type = 'PM Entitlement';
									e.RecordTypeId = PMRtID;
								}
								else{
									e.SlaProcessId = mapPE.get(peID).Entitlement_Process_ID__c;
									e.RecordTypeId = RtID;
								}
							lstInsEnt.add(e);
						}
					}
				}
			}
		}
		if(lstInsEnt.size()>0){
			insert lstInsEnt;
		}
		if(lstUpdateCLI.size()>0){
			update lstUpdateCLI;
		}
	}
}