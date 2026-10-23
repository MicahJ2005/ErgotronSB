public class ContractLinesToTechDeployLines {

//--------When a Tech Deployment header record is created, this code will clone all active contract line items
//--------under the account of the tech deployment and create those lines as tech deployment lines.

    public static Void AssignContractLines(list<Integration_Project__c> lstTDHeader){
    
        List<Integration_Project_Service__c> lstTDL = new List<Integration_Project_Service__c>(); 
        Id TDLRecordtypeId = Schema.SObjectType.Integration_Project_Service__c.getRecordTypeInfosByName().get('Preventative Maintenance').getRecordTypeId(); 
        Id TDRecordtypeId = Schema.SObjectType.Integration_Project__c.getRecordTypeInfosByName().get('Preventative Maintenance').getRecordTypeId();   
        set<Id> setAccountIds = new set<Id>();
        For (Integration_Project__c oTDHeader :lstTDHeader) {
            system.debug ('Integration Project Header: ' + oTDHeader);
            If(oTDHeader.RecordTypeId == TDRecordtypeId){
                setAccountIds.add(oTDHeader.End_User_Customer__c);
            }                                            
        } 
        
        map<Id, list<ContractLineItem>> mapAccountLineItems = new map<Id, list<ContractLineItem>>();
        //retrieve active service contracts and lines underneath
        For (ServiceContract oSC : [SELECT Id, AccountId,(SELECT Id, AssetId, Service_SKU_Deployment_Type__c, Asset.Product2Id, Contract_Service_SKU__c FROM ContractLineItems WHERE Active_Contract__c = TRUE)
                                    FROM ServiceContract
                                    WHERE AccountId IN:setAccountIds]){
            //for the contract currently on, loop through line items and building out map of account line items
            For(ContractLineItem oCLI : oSC.ContractLineItems){
                   List<ContractLineItem> lstCLI = new List<ContractLineItem>();
                   If(mapAccountLineItems.containskey(oSC.AccountId)){
                       lstCLI = mapAccountLineItems.get(oSC.AccountId);
                   }
                   lstCLI.add(oCLI);
                   mapAccountLineItems.put(oSC.AccountId,lstCLI);
            }
        }
    
        For(Integration_Project__c oProject : lstTDHeader){
            If(mapAccountLineItems.containskey(oProject.End_User_Customer__c)){
                For (ContractLineItem oCLI : mapAccountLineItems.get(oProject.End_User_Customer__c)) {
                    system.debug ('contract line: ' + oCLI);
                    Integration_Project_Service__c oTDL = new Integration_Project_Service__c();
                    oTDL.Asset__c = oCLI.AssetId;
                    oTDL.Product__c = oCLI.Asset.Product2Id;
                    oTDL.Tech_Deployment_Record__c = oProject.id;
                    oTDL.Contract_Line_Item__c = oCLI.Id;
                    oTDL.RecordTypeId = TDLRecordtypeId;
                    oTDL.Service_Part_Number__c = oCLI.Contract_Service_SKU__c;
                    If(oCLI.Service_SKU_Deployment_Type__c == 'Powered Contract') {
                        oTDL.Deployment_Type__c = 'Powered Contract';
                    } else if (oCLI.Service_SKU_Deployment_Type__c == 'Non-Powered Contract'){
                        oTDL.Deployment_Type__c = 'Non-Powered Contract';
                    } else {
                        oTDL.Deployment_Type__c = 'Unassigned';
                    }
                    lstTDL.add(oTDL);
                }
            }    
        }  
    
        If(lstTDL.size()>0) {
            insert lstTDL;
        }
    }
}