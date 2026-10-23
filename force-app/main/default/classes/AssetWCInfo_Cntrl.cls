global without sharing class AssetWCInfo_Cntrl {
	
	@AuraEnabled
    public static Asset getWorkOrderWarrantyInformation(String workOrderNumber, String caseId) {
        System.Debug('WORKORDER PULL OF WARRANTY INFO - ' + workOrderNumber + ', CaseId = ' + caseId);
        
		Asset objReturn = new Asset();
		String assetId = '';

		// If caseId sent, grab WO# from Case
		if(String.isBlank(workOrderNumber) && !String.isBlank(caseId)) {
			Case objCase = [SELECT Id, AssetId, Oracle_Work_Order__c FROM Case WHERE Id = :caseId LIMIT 1];
			workOrderNumber = objCase.Oracle_Work_Order__c;
			assetId = String.valueOf(objCase.AssetId);
		}

		// If Asset Found, return that
		if(!String.isBlank(assetId)) {
			System.debug('RETURNING ASSET FROM WO METHOD');
			return AssetWCInfo_Cntrl.getParentAsset(assetId);
		}

        // Informatica ICRT Warranty Callout
        String strWONumberClean = workOrderNumber.deleteWhitespace();
        if(strWONumberClean.containsAny('-')){
            strWONumberClean = strWONumberClean.substring(0, strWONumberClean.indexOf('-'));
        }

		// Return if no inputs found
		if(String.isBlank(strWONumberClean)) {
			return objReturn;
		}

        Informatica_CallOuts.WO_Data wData = new Informatica_CallOuts.WO_Data();
        wData = Informatica_CallOuts.WOCalloutProcess(strWONumberClean);
        
        System.Debug('wData for ' + strWONumberClean + ' RETURNED = ' + wData);
        
        if(wData.woresult != null) {
        
            Decimal intTerms = 60;
            String sDate = wData.woresult[0].DATE_COMPLETED;
            String sYear = sDate.substring(0,4);
            String sMonth = sDate.substring(5,7);
            String sDay = sDate.substring(8,10);
            Date shipdate = Date.newInstance(Integer.valueOf(sYear), Integer.valueOf(sMonth), Integer.valueOf(sDay));
            String prodName = wData.woresult[0].ASSEMBLY_ITEM;
            List<Product2> lstProducts = [SELECT Id, ProductCode, Name, Default_Warranty_Terms__c FROM Product2 WHERE ProductCode = :prodName];
            
            if(!lstProducts.isEmpty()) {
                objReturn.Product2Id = lstProducts[0].Id;
                if(lstProducts[0].Default_Warranty_Terms__c != NULL) {
                    intTerms = lstProducts[0].Default_Warranty_Terms__c;
                }
            }
            
            objReturn.Name = 'Non-Asset Warranty Info';
            objReturn.InstallDate = shipdate;
            objReturn.Shipped_Date__c = shipdate;
            objReturn.Build_Date__c = shipdate;
            objReturn.Status = 'Installed';
            objReturn.Warranty_Start_Date__c = shipdate.addMonths(3);
            objReturn.Warranty_End_Date__c = objReturn.Warranty_Start_Date__c.addMonths(Integer.valueOf(intTerms));
            objReturn.Warranty_Terms_in_Months__c = intTerms;
            
            System.Debug('RETURNING ' + JSON.serialize(objReturn));
            
        }

        return objReturn;
        
    }
    
    @AuraEnabled
    public static Asset getParentAsset(String assetId){
        Asset objReturn = new Asset();
        List<Asset> lstAssets = [SELECT 
                	Id, 
                	Name, 
                	Warranty_Start_Date__c, 
                	Warranty_End_Date__c, 
                	Warranty_Terms_in_Months__c,
                    Battery_Serial_Number__c,
                    Power_Module_Serial_Number__c,         
                	(SELECT 
                     	Id, 
                     	Active_Contract__c, 
                     	EndDate, 
                     	StartDate, 
                     	Contract_Type__c 
                     FROM ContractLineItems 
                     WHERE Active_Contract__c = true)
                FROM Asset 
                WHERE 
                    Id = :assetId
					AND Warranty_Start_Date__c != null
        ];
        
        if(!lstAssets.isEmpty()) {
            objReturn = lstAssets[0];
        }
        
        System.Debug('RETURNING ASSET - ' + JSON.serialize(objReturn));
        
        return objReturn;
    }
    @AuraEnabled
    public static List<Asset> getChildrenAsset(String assetId){

        List<Asset> lstAssets = new List<Asset>();
        if(!String.isBlank(assetId)) {
            lstAssets = [SELECT 
                    	Id, 
                    	Name, 
                    	Warranty_Start_Date__c, 
                    	Warranty_End_Date__c, 
                    	Warranty_Terms_in_Months__c,
                    	(SELECT 
                         	Id, 
                         	Active_Contract__c, 
                         	EndDate, 
                         	StartDate, 
                         	Contract_Type__c 
                         FROM ContractLineItems 
                         WHERE Active_Contract__c = true)
                    FROM 
                         Asset 
                    WHERE 
                         ParentId = :assetId
                         AND Warranty_Start_Date__c != null
            ];
        }

        return lstAssets;
    }
}