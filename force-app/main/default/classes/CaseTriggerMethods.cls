public with sharing class CaseTriggerMethods {
	public static void CloseOpenEntitlements(List<Case> lstCase, Map<Id, Case> oldCases) {
		List<CaseMilestone> lstUpdateCM = new List<CaseMilestone>();
		Set<Id> setCaseIds = new Set<Id>();
		Map<Id, String> mapCaseStatus = new Map<Id, String>();
		for(Case c: lstCase){
            if(oldCases != null){
                if(oldCases.get(c.Id).Status != c.Status){
                    mapCaseStatus.put(c.Id, oldCases.get(c.Id).Status);
                    setCaseIds.add(c.Id);
                }
            }
        }
        if(setCaseIds.size()>0){
	        for(CaseMilestone cm:[SELECT Id, CompletionDate, Case.Status, MilestoneType.Name FROM CaseMilestone WHERE CaseId in :setCaseIds AND CompletionDate = null]){
	            System.debug('cm: ' + cm);
	            CaseMilestone newCM = new CaseMilestone();
	            if(mapCaseStatus.get(cm.CaseId) == cm.MilestoneType.Name){
	                    newCM.Id = cm.Id;
	                    newCM.CompletionDate = System.now();
	                lstUpdateCM.add(newCM);
	            }
	        }
	        if(lstUpdateCM.size()>0){
	            update lstUpdateCM;
	        }
        }
	}
	@future (callout=true)
	public static void PopulateWOData(Set<Id> setCaseIds){
		List<Case> lstUpdateCase = new List<Case>();
        Set<String> setWO = new Set<String>();
        Map<String,Case> mapXref = new Map<String, Case>();
        Map<Id,Informatica_CallOuts.WO_Data> mapData = new Map<Id,Informatica_CallOuts.WO_Data>();
        Set<String> setProdName = new Set<String>();
        Map<String, Product2> mapProd = new Map<String, Product2>();

        for(Case c: [SELECT Id, Oracle_Work_Order__c, GetWOData__c FROM Case WHERE Id in :setCaseIds]){
            if(c.GetWOData__c){
                if(!String.isBlank(c.Oracle_Work_Order__c)){
                    setWO.add(c.Oracle_Work_Order__c);
                    mapXref.put(c.Oracle_Work_Order__c, c);
                }
            }
        }
        if(setWO.size()>0){
            for(String wonum: setWO){
				try {
					Informatica_CallOuts.WO_Data woData = new Informatica_CallOuts.WO_Data();
					Date shipdate;
					String won = wonum.deleteWhitespace();
					if(won.containsAny('-')){
						won = won.substring(0, won.indexOf('-'));
					}
					System.debug('won: ' + won);
					woData = Informatica_CallOuts.WOCalloutProcess(won);
					System.debug('woData: ' + woData);
					mapData.put(mapXref.get(wonum).Id, woData);
					if(woData != null) {
						if(woData.woresult[0].ASSEMBLY_ITEM != null){
							setProdName.add(woData.woresult[0].ASSEMBLY_ITEM);
						}
					}
				} catch(Exception ex) {
					System.debug('CaseTriggerMethods.PopulateWOData ERROR - ' + ex.getMessage());
				}
            }
            if(setProdName.size()>0){
                for(Product2 prod:[SELECT Id, ProductCode, Name, Default_Warranty_Terms__c FROM Product2 WHERE ProductCode in :setProdName]){
                    mapProd.put(prod.ProductCode, prod);
                }
                System.Debug('mapProd: ' + mapProd);
                for(String wo: setWO){
                    Date woShip;
                    Informatica_CallOuts.WO_Data wData = new Informatica_CallOuts.WO_Data();
                    Decimal intTerms = 12;
                    wData = mapData.get(mapXref.get(wo).Id);
                    String sDate = wData.woresult[0].DATE_COMPLETED;
                    String sYear = sDate.substring(0,4);
                    String sMonth = sDate.substring(5,7);
                    String sDay = sDate.substring(8,10);
                    Date shipdate = Date.newInstance(Integer.valueOf(sYear), Integer.valueOf(sMonth), Integer.valueOf(sDay));
                    if(mapProd.get(wData.woresult[0].ASSEMBLY_ITEM).Default_Warranty_Terms__c != null){
                        intTerms = mapProd.get(wData.woresult[0].ASSEMBLY_ITEM).Default_Warranty_Terms__c;
                    }
                    Case newrec = new Case();
                        newrec.Id = mapXref.get(wo).Id;
                        newrec.ProductId = mapProd.get(wData.woresult[0].ASSEMBLY_ITEM).Id;
                        newrec.GetWOData__c = false;
                        newrec.Build_Warehouse__c = wData.woresult[0].ORGANIZATION_CODE;
                        newrec.Build_Date__c = date.valueOf(wData.woresult[0].DATE_COMPLETED);
                    lstUpdateCase.add(newrec);
                }
            }
        }
        if(lstUpdateCase.size()>0){
            update lstUpdateCase;
        }
    }

    /**
     * @description : Enovate Merge.  Creates Service Appointments based on the Cases that have the Status change
     *
     * @author Matthew J Lennington -- (Demand Chain)
     * @date 2025-01-07
     *
    */
    public static void createServiceAppointments(List<Case> newList, Map<Id, Case> oldMap) {                
        List<Case> newCaseList = new List <Case>();
        for(Case caseObj : newList) {
            if(caseObj.Status == 'Tech Visit' && oldMap.get(caseObj.Id).Status != caseObj.Status){
                newCaseList.add(caseObj);
            }             
        }        
        if(!newCaseList.isEmpty()) {
            CaseService.createServiceAppointments(newCaseList);           
        }        
    }
}