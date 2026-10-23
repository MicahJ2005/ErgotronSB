/*
    Controller class for the Case ATP Lightning Component

    MOD DATE        Who                     Description
    20180620		Andy Boettcher			Added Header
	20200129		Esau Sanchez			Commented productNameLookupInBOM method 
*/

public without sharing class Flow_ATP_Controller {
    @AuraEnabled 
    public static List<OrderComponentWrapperClass> getATPData(String partNumber){
        Set<String> setWarehouses = new Set<String>();
        setWarehouses = warehouseLookup();
        List<OrderComponentWrapperClass> lstATPData = new List<OrderComponentWrapperClass>();
        Informatica_CallOuts.ATP_Data lstatp = new Informatica_CallOuts.ATP_Data();
        lstatp = Informatica_CallOuts.ATPCalloutProcess(partNumber);
        System.debug('lstatp: ' + lstatp);

        for(Informatica_CallOuts.atpresult atp : lstatp.atpresult){
            //if(setWarehouses.contains(atp.ORGANIZATION_CODE) && Integer.valueOf(ATP.NETOH) > 0){ // Commented out per Carol 20180523
			if(setWarehouses.contains(atp.ORGANIZATION_CODE)){
                OrderComponentWrapperClass hATP = new OrderComponentWrapperClass();
                    hATP.itemDesc = atp.ITEM_DESCRIPTION;
                    hATP.itemNum = atp.ITEM_NUMBER;
                    hATP.netOH = atp.QTY_AVAIL;
                    hATP.orgCode = atp.ORGANIZATION_CODE;
                    hATP.salesQty = atp.SALES_QTY;
                    hATP.supplyQty = atp.SUPPLY_QTY;
                    hATP.supplyQtyBYW = atp.SUPPLY_QTY_BYW;
                    hATP.supplyQtyDate = atp.SUPPLY_QTY_DATE;
					hATP.bolHasQty = true;
                lstATPData.add(hATP);
            }
        }

		if(lstATPData.isEmpty()) {
			OrderComponentWrapperClass hATP = new OrderComponentWrapperClass();
                    hATP.itemDesc = 'No Parts Available via ATP';
					hATP.netOH = 'No Parts Available via ATP';
                    hATP.itemNum = partNumber;
                    hATP.orgCode = 'US1';
                    hATP.salesQty = 'N/A';
                    hATP.supplyQty = 'N/A';
                    hATP.supplyQtyBYW = 'N/A';
                    hATP.supplyQtyDate = 'N/A';
					hATP.bolHasQty = true;
                lstATPData.add(hATP);
		}

        return lstATPData;
    }
    @AuraEnabled
    public static List<Oracle_Return_Reason__c> getOracleReturnReason(){
        return  [SELECT Id
                        ,Description__c 
                        ,Lookup_Code__c
                        ,Meaning__c
                    FROM Oracle_Return_Reason__c 
                    WHERE Enabled_Flag__c = true];
        
    }
    
    @AuraEnabled public static Case getCaseDetails(String strCaseId) {
        return [
            SELECT
            	Id,
            	CaseNumber
           	FROM
            	Case
            WHERE
            	Id = :strCaseId
            LIMIT
            	1
        ];
    }

	@AuraEnabled public static List<OrderBusinessLogicCheck> getTestCaseBusinessLogic(String strCaseId) {

		List<OrderBusinessLogicCheck> lstReturn = new List<OrderBusinessLogicCheck>();

		Case objCase = [SELECT Id, Account.RecordTypeId, AccountId, IsClosed FROM Case WHERE Id = :strCaseId LIMIT 1];
		List<Account> lstSite = [SELECT Id, Oracle_Address_1__c, BillingCountryCode, Region__c, County__c FROM Account WHERE Id = :objCase.AccountId LIMIT 1];
		
		if(objCase.Account.RecordTypeId != Schema.SObjectType.Account.RecordTypeInfosByName.get('Site').RecordTypeId) {
			lstReturn.add(new OrderBusinessLogicCheck(false, '1000', 'The Account attached to this Case is not a SITE Account'));
		}

		if(objCase.IsClosed) {
			lstReturn.add(new OrderBusinessLogicCheck(false, '1003', 'This Case is Closed and cannot have a Sales Order created against it.  Re-open the Case or create a new one.'));
		}

		if(!lstSite.isEmpty()) {
			if(lstSite[0].BillingCountryCode == 'US' && String.isBlank(lstSite[0].County__c)) {
				lstReturn.add(new OrderBusinessLogicCheck(false, '1001', 'The Account attached to this Case does not have a validated Address (County is missing).  Please go to the Account (Site) attached to this Case and validate the address.'));
			}

			if(String.isBlank(lstSite[0].Oracle_Address_1__c)) {
				lstReturn.add(new OrderBusinessLogicCheck(false, '1002', 'The Account attached to this Case does not have an address specified (Address Line 1 is blank).'));
			}
		}

		


		return lstReturn;

	}
/*
	@AuraEnabled public static Opportunity getOppDetails(String strOpportunityId) {
		return [
			SELECT
				Id,
				Name,
				AccountId
			FROM
				Opportunity
			WHERE
				Id = :strOpportunityId
			LIMIT
				1
		];
	}
*/
    @AuraEnabled
    public static List<Product2> productNameLookup(String partName){
        List<Product2> lstProd = new List<Product2>();
        String strSOQL;
        strSOQL = 'SELECT Id, Name, ProductCode FROM Product2 WHERE Name Like \'%' + partName + '%\' AND Inventory_Item_Status_Code__c = \'MASTER\' AND IsActive = true ORDER BY Name ASC LIMIT 200';
        System.debug('strSOQL: ' + strSOQL);
        lstProd = Database.query(strSOQL);
        return lstProd;
    }
/*    @AuraEnabled
    public static List<Product2> productNameLookupInBOM(String partName, String caseId){
        Set<String> setString = new Set<String>();
        String assetPNum;
        String whouse;
        Case c = [SELECT Id, AssetId, Product.ProductCode, Build_Warehouse__c FROM Case WHERE Id = :caseId];
            assetPNum = c.Product.ProductCode;
            whouse = c.Build_Warehouse__c;
        if(String.isBlank(whouse)){
            whouse = 'DO1';
        }
        setString = getPartNumbers(partName, assetPNum, whouse);
        List<Product2> lstProd = new List<Product2>();
        String strSOQL;
        strSOQL = 'SELECT Id, Name, ProductCode FROM Product2 WHERE Inventory_Item_Status_Code__c = \'MASTER\' AND IsActive = true AND ProductCode in :setString ORDER BY Name ASC LIMIT 200';
        System.debug('strSOQL: ' + strSOQL);
        lstProd = Database.query(strSOQL);
        System.debug('lstProd: ' + lstProd.size());
        return lstProd;
    }
    */
    @AuraEnabled
    public static HelperATPData createhelperClassPartData(String strPartNum, String strPQty, String strPWarehouse, String retName){
        Product2 prod = [SELECT Id, Name FROM Product2 WHERE ProductCode = :strPartNum LIMIT 1];
        HelperATPData hpd = new HelperATPData();
            hpd.strPartNumber = strPartNum;
            hpd.strPartQty = strPQty;
            hpd.strPartWarehouse = strPWarehouse;
            hpd.strProdId = prod.Id;
            hpd.strProdName = prod.Name;
            hpd.strRetName = retName;
        return hpd;
    }
	@AuraEnabled
	public static String createOrder(String strParts, String POnum, String BillToId, String ShipToId, String Notes, String OrderType, String caseId, String shipToContactId){
		String retMessage;
		List<HelperATPData> lstParts = new List<HelperATPData>();
        List<Sales_Order_Line__c> lstSOL = new List<Sales_Order_Line__c>();
		Oracle_Order_Type__c oot = Oracle_Order_Type__c.getValues(OrderType);
        lstParts = (List<HelperATPData>) System.JSON.deserialize(strParts, List<HelperATPData>.class);
		Case c = [SELECT Id, ContactId, next_day_business__c, SDO__c FROM Case WHERE Id =:caseId];
		Map<Id, Account> mapAcct = new Map<Id, Account>([SELECT Id
																,Name
																,BillingStreet
																,Oracle_Address_1__c
																,Oracle_Address_2__c
																,Oracle_Address_3__c
																,Oracle_Address_4__c
																,Oracle_City__c
																,Oracle_Country__c
																,Oracle_Party_Id__c
																,Oracle_Postal_Code__c
																,Oracle_SiteShipToUseId__c
																,Oracle_State__c
														FROM Account 
														WHERE Id =: BillToId 
															OR Id =: ShipToId]);
        
		Sales_Order__c so = new Sales_Order__c();
			so.Bill_To_Customer__c = BillToId;
			so.Customer_PO_Number__c = POnum;
			so.Notes__c = Notes;
			so.Order_Type__c = OrderType;
			so.Service_Request__c  = caseId;
			so.Ship_To_Address1_Oracle__c = mapAcct.get(ShipToId).Oracle_Address_1__c;
			so.Ship_To_Address2_Oracle__c = mapAcct.get(ShipToId).Oracle_Address_2__c;
			so.Ship_To_Address3_Oracle__c = mapAcct.get(ShipToId).Oracle_Address_3__c;
			so.Ship_To_Address4_Oracle__c = mapAcct.get(ShipToId).Oracle_Address_4__c;
			so.Ship_To_City_State_Zip_Country_Oracle__c = mapAcct.get(ShipToId).Oracle_City__c + ',' + mapAcct.get(ShipToId).Oracle_State__c + ',' + mapAcct.get(ShipToId).Oracle_Postal_Code__c + ',' + mapAcct.get(ShipToId).Oracle_Country__c;
			so.Ship_To_Customer__c = ShipToId;
			so.Ship_To_Org_Id__c = mapAcct.get(ShipToId).Oracle_SiteShipToUseId__c;
			//so.Ship_To_Contact__c = c.ContactId;
			so.Ship_To_Contact__c = shipToContactId;
			so.Order_Type_Id__c = oot.Order_Type_Id__c;
        	so.Next_Day_Business__c = c.next_day_business__c;
        	so.Opportunity__c = c.SDO__c;
		insert so;
		for(HelperATPData hp: lstParts){
            Sales_Order_Line__c sol = new Sales_Order_Line__c();
                sol.Part_Number__c = hp.strProdId;
                sol.Quantity__c = Decimal.valueOf(hp.strPartQty);
                sol.Sales_Order__c = so.Id;
                sol.Case__c = caseId;
                sol.Warehouse__c = hp.strPartWarehouse;
                sol.Return_Reason_Code__c = hp.strRetName;
            lstSOL.add(sol);
        }      
        if(lstSOL.size()>0){
            try{
                insert lstSOL;
				   ICRT_TransmitOrder.singleIdToSubmitOrderToICRT(so.Id);
                retMessage = 'Order was created and Submitted';
            } catch (Exception e){
                retMessage = 'Sorry there was an issue creating your order. ERROR: ' + e.getMessage();
            }
        }
        return retMessage;
	}
/*   
  Below code has been commented out due to Ergotron not ready for the orders to be seperated by code.
  @AuraEnabled
	public static String completeSOprocess (String orderId, String strParts, String caseId){
		System.debug('strParts: ' + strParts);
        System.debug('orderId: ' + orderId);
        System.debug('caseId: ' + caseId);
        String retMessage;
		Set<String> setWarehouse = new Set<String>();
		Set<String> setPartIds = new Set<String>();
        Set<String> setRetIds = new Set<String>();
		Sales_Order__c soCloned = new Sales_Order__c();
        Sales_Order__c soRet = new Sales_Order__c();
		Sales_Order__c soOrig = new Sales_Order__c();
        Boolean boolServ = false;
		List<Sales_Order_Line__c> lstSOL = new List<Sales_Order_Line__c>();
		List<HelperATPData> lstParts = new List<HelperATPData>();
        List<HelperATPData> lstRetParts = new List<HelperATPData>();
        List<HelperATPData> lstPosParts = new List<HelperATPData>();
		Map<String, Sales_Order__c> mapSO = new Map<String, Sales_Order__c>();
		String strSOQL;
        Boolean boolRemoveOrig = true;
		lstParts = (List<HelperATPData>) System.JSON.deserialize(strParts, List<HelperATPData>.class);


		strSOQL = UtilityMethods.getCreatableFieldsSOQL('Sales_Order__c');
		strSOQL += ' WHERE Id = :orderId';
		System.debug('strSOQL: ' + strSOQL);
		soOrig = Database.query(strSOQL);
		soCloned = soOrig.clone(false,false,false,false);
        soRet = soOrig.clone(false,false,false,false);
        System.debug('lstParts: ' + lstParts);
		for(HelperATPData hpd: lstParts){
            String strPartNum = hpd.strPartQty;
            if(!strPartNum.contains('-')){
                System.debug('hpd: ' + hpd);
			    setPartIds.add(hpd.strProdId);
                lstPosParts.add(hpd);
             }
            if(strPartNum.contains('-')){
                System.debug('should be - hpd: ' + hpd);
                setRetIds.add(hpd.strProdId);
                lstRetParts.add(hpd);
             }
		}
        System.debug('setPartIds: ' + setPartIds);
        System.debug('setRetIds: ' + setRetIds);
		Map<Id,Product2> mapProd = new Map<Id,Product2>([SELECT Id,Name, ProductCode, Labor_Part__c FROM Product2 WHERE Id in :setPartIds]);
        Map<Id,Product2> mapRet = new Map<Id,Product2>([SELECT Id,Name, ProductCode, Labor_Part__c FROM Product2 WHERE Id in :setRetIds]);
			for(HelperATPData hp: lstPosParts){
                System.debug('hp.strProdId: ' + hp.strProdId);
                System.debug('mapProd.containsKey(hp.strProdId): ' + mapProd.containsKey(hp.strProdId));
                System.debug('mapProd.get(hp.strProdId).Labor_Part__cd: ' + mapProd.get(hp.strProdId).Labor_Part__c);
                if(mapProd.containsKey(hp.strProdId)){
    				if(!mapProd.get(hp.strProdId).Labor_Part__c){
    					Sales_Order_Line__c sol = new Sales_Order_Line__c();
    						sol.Part_Number__c = hp.strProdId;
    						sol.Quantity__c = Decimal.valueOf(hp.strPartQty);
    						sol.Sales_Order__c = orderId;
    						sol.Case__c = soOrig.Service_Request__c;
                            sol.Warehouse__c = hp.strPartWarehouse;
    					lstSOL.add(sol);
                        boolRemoveOrig = false;
    				}
                    else{
                        boolServ = true;
                    }
                }
            }
            if(boolServ){
                soCloned.Order_Type__c = 'SERVICE';
                insert soCloned;
                for(HelperATPData hp: lstPosParts){
                    System.debug('Sevice - hp.strProdId: ' + hp.strProdId);
                    System.debug('Sevice - mapProd.containsKey(hp.strProdId): ' + mapProd.containsKey(hp.strProdId));
                    System.debug('Sevice - mapProd.get(hp.strProdId).Labor_Part__cd: ' + mapProd.get(hp.strProdId).Labor_Part__c);
                    if(mapProd.containsKey(hp.strProdId)){
                        if(mapProd.get(hp.strProdId).Labor_Part__c){
                            Sales_Order_Line__c sol = new Sales_Order_Line__c();
                                sol.Part_Number__c = hp.strProdId;
                                sol.Quantity__c = Decimal.valueOf(hp.strPartQty);
                                sol.Sales_Order__c = soCloned.Id;
                                sol.Case__c = soOrig.Service_Request__c;
                                sol.Warehouse__c = hp.strPartWarehouse;
                            lstSOL.add(sol);
                        }
                    }
                }
			}
            if(mapRet.size()>0){
                soRet.Order_Type__c = 'RETURN';
                insert soRet;
                for(HelperATPData hp: lstRetParts){
                    if(mapRet.containsKey(hp.strProdId)){
                        Sales_Order_Line__c sol = new Sales_Order_Line__c();
                            sol.Part_Number__c = hp.strProdId;
                            sol.Quantity__c = Decimal.valueOf(hp.strPartQty);
                            sol.Sales_Order__c = soRet.Id;
                            sol.Case__c = soOrig.Service_Request__c;
                            sol.Warehouse__c = hp.strPartWarehouse;
                            sol.Return_Reason__c = hp.strRetName;
                        lstSOL.add(sol);
                    }
                }
            }

		if(lstSOL.size()>0){
			try{
                insert lstSOL;
                retMessage = 'Order was created';
            } catch (Exception e){
                retMessage = 'Sorry there was an issue creating your order. ERROR: ' + e.getMessage();
            }
		}
        if(boolRemoveOrig){
            delete soOrig;
        }
        return retMessage;
	}*/
    @AuraEnabled
    public static HelperOrderHeaderSelections getOrderSelections(String caseId){
        HelperOrderHeaderSelections hohs = new HelperOrderHeaderSelections();
        List<Oracle_Order_Type__c> lstOrderTypes = new List<Oracle_Order_Type__c>();
        List<Account> lstAccts = new List<Account>();
        Case c = new Case();
        Account a = new Account();
        String strSiteId;
        String strParentId;
 
		//for(Oracle_Order_Type__c oot: Oracle_Order_Type__c.getall().values()){
        for(Oracle_Order_Type__c oot: [SELECT Id, Name, Description__c, Start_Date_Active__c, End_Date_Active__c, Order_Type_Id__c, Salesforce_Order_Type__c FROM Oracle_Order_Type__c WHERE End_Date_Active__c = NULL AND Salesforce_Order_Type__c = TRUE ORDER BY Name ASC]) {
			//if(oot.End_Date_Active__c == null && oot.Salesforce_Order_Type__c){
				lstOrderTypes.add(oot);
			//}
		}
        
        c = [SELECT Id, AccountId, CaseNumber FROM Case WHERE Id = :caseId];
        a = [SELECT Id, ParentId, BillingStreet FROM Account WHERE Id = :c.AccountId];
        strParentId = a.ParentId;
        strSiteId = a.Id;
        lstAccts = [SELECT Id
                                ,Name
                                ,BillingStreet
                                ,Oracle_Address_1__c
                                ,Oracle_Address_2__c
                                ,Oracle_Address_3__c
                                ,Oracle_Address_4__c
                                ,Oracle_City__c
                                ,Oracle_Country__c
                                ,Oracle_Party_Id__c
                                ,Oracle_Postal_Code__c
                                ,Oracle_SiteShipToUseId__c
                                ,Oracle_State__c
                    			,Display_BT_ST_Address__c
                        FROM Account 
                        WHERE ParentId = :strParentId
						ORDER BY Display_BT_ST_Address__c ASC
                        LIMIT 500];

        hohs.defAcct = a.Id;
        hohs.lstAcct = lstAccts;
        hohs.lstOrderType = lstOrderTypes;
        hohs.strCaseNumber = c.CaseNumber;

        return hohs;
    }
    @AuraEnabled
    public static List<Account> getMoreAccounts(String strAcctName){
        String strLike = '%' + strAcctName + '%';
        return [SELECT Id
                        ,Name
                        ,Customer_Number__c
                        ,BillingStreet
                        ,Oracle_Address_1__c
                        ,Oracle_Address_2__c
                        ,Oracle_Address_3__c
                        ,Oracle_Address_4__c
                        ,Oracle_City__c
                        ,Oracle_Country__c
                        ,Oracle_Party_Id__c
                        ,Oracle_Postal_Code__c
                        ,Oracle_SiteShipToUseId__c
                        ,Oracle_State__c
                FROM Account 
                WHERE (Name LIKE :strLike OR Oracle_Address_1__c LIKE :strLike OR Customer_Number__c LIKE :strLike)
                	AND RecordType.Name = 'SITE'
				ORDER BY
					Name ASC,
					Oracle_Address_1__c ASC
                LIMIT 500];
    }
    
    @AuraEnabled
    public static List<Contact> getShipToContacts(String strAccountId) {
        Set<Id> setACRs = new Set<Id>();
        for(AccountContactRelation objACR : [SELECT Id, ContactId FROM AccountContactRelation WHERE AccountId = :strAccountId]) {
            setACRs.add(objACR.ContactId);
        }
        
        return [
            SELECT
            	Id,
            	Order_Component_Display__c
            FROM
            	Contact
            WHERE
            	Id IN :setACRs
            ORDER BY
            	Order_Component_Display__c ASC
            LIMIT
            	200
        ];
    }
    
    public static Set<String> warehouseLookup(){
        Set<String> setWH = new Set<String>();
        for(Oracle_Warehouse__mdt ow: [SELECT Active__c, Organization_Code__c FROM Oracle_Warehouse__mdt WHERE Active__c = true]){
            setWH.add(ow.Organization_Code__c);
        }
        return setWH;
    }
    public static Set<String> getPartNumbers(String pName, String assetPNum, String strWH){
        Set<String> setPNums = new Set<String>();
        if(String.isBlank(strWH)){
            strWH = 'DO1';
        }
        String params = assetPNum + '&ip_organization_code=' + strWH;
        Informatica_CallOuts.BOM_Data bomDATA = new Informatica_CallOuts.BOM_Data();
        bomDATA = Informatica_CallOuts.BOMCallout(params);
        System.debug('pName: ' + pName);
        for(Informatica_CallOuts.Bomresult bom: bomDATA.bomresult){
            String strBOMName = bom.COMP_ITEM_DESCR;
            System.debug('strBOMName: ' + strBOMName);
            if(strBOMName.containsIgnoreCase(pName)){
                System.debug('bom.COMP_ITEM_DESCR: ' + bom.COMP_ITEM_DESCR);
                System.debug('bom.COMP_ITEM: ' + bom.COMP_ITEM);
                setPNums.add(bom.COMP_ITEM);
            }
        }
        System.debug('setPNums: ' + setPNums.size());
        return setPNums;
    }

}