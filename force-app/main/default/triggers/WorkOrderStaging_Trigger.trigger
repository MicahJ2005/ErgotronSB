/*
Trigger for the Work Order Staging object

MOD DATE        Who                     Description
20180906        Andy Boettcher			Initial Release 
*/

trigger WorkOrderStaging_Trigger on Work_Order_Staging__c (before insert, before update) {
    
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate) ) {
        
        for(Work_Order_Staging__c objWOS : Trigger.new) {
            
            if(String.isNotBlank(objWOS.PO_Number__c)) {
                
                // First, Relate the Tech Deploy ID that matches the PO of the WOS record to this record
                
                //Are there any Tech Deploy records matching the PO?
                Integer IPCount = [select count() from Integration_Project__c where Ergotron_PO__c = :objWOS.PO_Number__c];
                if(IPCount>0){
                    Integration_Project__c objIP = [SELECT Id FROM Integration_Project__c WHERE Ergotron_PO__c = :objWOS.PO_Number__c ORDER BY CreatedDate DESC LIMIT 1];
                    objWOS.Tech_Deployment__c = objIP.Id;
                    
                    
                    // Then, if date fields are not null, copy the Completion and Scheduled Date to all Line Items under the Tech Deployment
                    Set<Id> setContractLineItemIds = new Set<Id>();
                    
                    List<Integration_Project_Service__c> lstLines = [SELECT Id, Completion_Date__c, Scheduled_Date__c, Contract_Line_Item__c FROM Integration_Project_Service__c WHERE Tech_Deployment_Record__c = :objWOS.Tech_Deployment__c];
                    for(Integration_Project_Service__c objLine : lstLines) {
                        objLine.Completion_Date__c = objWOS.Completion_Date__c;
                        objLine.Scheduled_Date__c = objWOS.Scheduled_Date__c;
                        setContractLineItemIds.add(objLine.Contract_Line_Item__c);
                    }
                    
                    update lstLines;
                    
                    // Finally, update all of the linked Contract Line Items of the Tech Deployment Lines with the same dates
                    List<ContractLineItem> lstContractLines = [SELECT Id, Last_PM_Date_from_TDLine__c, Scheduled_Date_from_TD_Line__c FROM ContractLineItem WHERE Id IN :setContractLineItemIds];
                    for (ContractLineItem objCLI : lstContractLines) {
                        objCLI.Last_PM_Date_from_TDLine__c = objWOS.Completion_Date__c;
                        objCLI.Scheduled_Date_from_TD_Line__c = objWOS.Scheduled_Date__c;
                    }
                    
                    update lstContractLines;
                }
            }
        }
    }
}