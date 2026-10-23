public with sharing class AssetTriggerMethods {
    public static void CalculateWarrantyEndDate(List<Asset> lstAsset, Map<Id, Asset> mapOldAsset) {
        List<Asset> lstUpdateAsset = new List<Asset>();
        String BHid = [SELECT Id FROM BusinessHours WHERE Name = 'WarrantyBH'].Id;
        for(Asset a: lstAsset){
            if((mapOldAsset == null && a.Warranty_Start_Date__c != null && a.Warranty_Terms_in_Months__c != null) 
               || (a.Warranty_Start_Date__c != null && a.Warranty_Terms_in_Months__c != null 
                && (mapOldAsset.get(a.Id).Warranty_Start_Date__c != a.Warranty_Start_Date__c 
                    || mapOldAsset.get(a.Id).Warranty_Terms_in_Months__c != a.Warranty_Terms_in_Months__c))){
                Date calcEDate = a.Warranty_Start_Date__c;
                Integer i = Integer.valueOf(a.Warranty_Terms_in_Months__c);
                calcEDate = calcEDate.addMonths(i);
                calcEDate = calcEDate.addDays(-1);
                Asset newrec = new Asset();
                    newrec.Id = a.Id;
                    newrec.Warranty_End_Date__c = calcEDate;
                lstUpdateAsset.add(newrec);
            }
        }
        if(lstUpdateAsset.size()>0){
            update lstUpdateAsset;
        }
    }
    @future (callout=true)
    public static void PopulateAssetData(Set<Id> setAssetIds) {
        List<Asset> lstUpdateAsset = new List<Asset>();
        Set<String> setWO = new Set<String>();
        Map<String,Asset> mapXref = new Map<String, Asset>();
        Map<Id,Informatica_CallOuts.WO_Data> mapData = new Map<Id,Informatica_CallOuts.WO_Data>();
        Set<String> setProdName = new Set<String>();
        Map<String, Product2> mapProd = new Map<String, Product2>();

        for(Asset a: [SELECT Id, SerialNumber, Work_Order__c, GetWOData__c, Account.Name FROM Asset WHERE Id in :setAssetIds]){
            if(a.GetWOData__c){
                if(!String.isBlank(a.Work_Order__c)){
                    setWO.add(a.Work_Order__c);
                    mapXref.put(a.Work_Order__c, a);
                } else {
                    // Add Serial number
                    setWO.add(a.SerialNumber);
                    mapXref.put(a.SerialNumber, a);
                }
            }
        }
        if(setWO.size()>0){
            for(String wonum: setWO){
                Informatica_CallOuts.WO_Data woData = new Informatica_CallOuts.WO_Data();
                Date shipdate;
                String won = wonum.deleteWhitespace();
                if(won.containsAny('-')){
                    won = won.substring(0, won.indexOf('-'));
                }
                woData = Informatica_CallOuts.WOCalloutProcess(won);
                mapData.put(mapXref.get(wonum).Id, woData);

				System.debug('WODATA = ' + JSON.serialize(woData));

                setProdName.add(woData.woresult[0].ASSEMBLY_ITEM);
            }
            for(Product2 prod:[SELECT Id, ProductCode, Name, Default_Warranty_Terms__c FROM Product2 WHERE ProductCode in :setProdName]){
                mapProd.put(prod.ProductCode, prod);
            }
            for(String wo: setWO){
                Date woShip;
                Informatica_CallOuts.WO_Data wData = new Informatica_CallOuts.WO_Data();
                Decimal intTerms = 60;
                wData = mapData.get(mapXref.get(wo).Id);
                String sDate = wData.woresult[0].DATE_COMPLETED;
                String sYear = sDate.substring(0,4);
                String sMonth = sDate.substring(5,7);
                String sDay = sDate.substring(8,10);
                Date shipdate = Date.newInstance(Integer.valueOf(sYear), Integer.valueOf(sMonth), Integer.valueOf(sDay));
                if(mapProd.get(wData.woresult[0].ASSEMBLY_ITEM).Default_Warranty_Terms__c != null){
                    intTerms = mapProd.get(wData.woresult[0].ASSEMBLY_ITEM).Default_Warranty_Terms__c;
                }
                Asset newrec = new Asset();
                    newrec.Id = mapXref.get(wo).Id;
                    newrec.Product2Id = mapProd.get(wData.woresult[0].ASSEMBLY_ITEM).Id;
                    newrec.InstallDate = shipdate;
                    newrec.Shipped_Date__c = shipdate;
                    newrec.Build_Date__c = shipdate;
                    newrec.GetWOData__c = false;
					newrec.Build_Warehouse__c = wData.woresult[0].ORGANIZATION_CODE;
                    newrec.Status = 'Installed';
                    newrec.Warranty_Start_Date__c = shipdate.addMonths(3);
                    newrec.Warranty_Terms_in_Months__c = intTerms;
                	newrec.Warranty_End_Date__c = newRec.Warranty_Start_Date__c.addMonths(Integer.valueOf(newRec.Warranty_Terms_in_Months__c));
                    // Commented out 20180425 Andy and Esau - this doesn't need to be happening
                	// newrec.Name = mapProd.get(wData.woresult[0].ASSEMBLY_ITEM).Name + ' - ' + wo;
                lstUpdateAsset.add(newrec);
            }
        }
        if(lstUpdateAsset.size()>0){
            update lstUpdateAsset;
        }
    }
}