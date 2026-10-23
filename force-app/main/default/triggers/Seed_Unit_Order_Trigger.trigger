/*
    Trigger for Seed_Unit_Order__c object.
    
    + Before Insert/Update Logic - updates the seed order approver, top level parent id values, and ship to account details. Also updates the seed order products
    submitted flag when the seed unit order submitted flag is checked.
    + Before Update Logic - Clear ship to details when the Ship_To_Account__c value changes.
    + Before Delete Logic - Blocks the delete action if the record has already been submitted to Oracle.
    
    MOD DATE        Who                     Description
    4/21/2014       Chris Noe               Initial Release
    6/24/2014       Chris Noe               Added before insert/update logic to set approver based on selected Salesrep__c value
    11/12/2014      Chris Noe               Added call to Seed_Unit_Order_Utility.updateTopLevelParentValues on before insert/before update
    4/21/2015       Chris Noe               Added before delete logic to verify that the seed unit order has not been submitted to Oracle.
*/

trigger Seed_Unit_Order_Trigger on Seed_Unit_Order__c (after insert, after update, before insert, before update, before delete) {
    //Before Insert/Update Logic
    if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
        //Call method updateSeedUnitProductsSubmitted which updates the Seed_Unit_Order_Submitted__c flag on all Seed_Unit_Product__c records related to the Seed_Unit_Order__c 
        //id values passed into the method. This logic will be called when the Submit_Seed_Unit_Order_Controller.submitSeedUnitOrder method sets the 
        //Seed_Unit_Order__c.Seed_Unit_Order_Submitted__c to true or when the "Seed Unit Order Approval" process updates Seed_Unit_Order__c.Seed_Unit_Order_Submitted__c to 
        //true after the seed unit order has been approved.
        
        //Variables
        List<Id> listSeedUnitOrderIds = new List<Id>();
        
        for(Seed_Unit_Order__c oSeedUnitOrder :trigger.new){
            if(oSeedUnitOrder.Seed_Unit_Order_Submitted__c && !trigger.oldMap.get(oSeedUnitOrder.Id).Seed_Unit_Order_Submitted__c){
                listSeedUnitOrderIds.add(oSeedUnitOrder.Id);
            }
        }
        
        if(!listSeedUnitOrderIds.isEmpty()) {
            Seed_Unit_Order_Utility.updateSeedUnitProductsSubmitted(listSeedUnitOrderIds);  
        }

        //Call method Seed_Unit_Order_Utility.updateSeedUnitOrderApprover which will update the Approver__c field on each Seed_Unit_Order__c record.
        Seed_Unit_Order_Utility.updateSeedUnitOrderApprover(trigger.new);

        //Call method to set top level parent id values
        Seed_Unit_Order_Utility.updateTopLevelParentValues(trigger.new);

        //Call method to set ship to account details
        Seed_Unit_Order_Utility.updateShipToAccountDetails(trigger.new);
    }
    
    //Before Update Logic
    if(trigger.isBefore && trigger.isUpdate) {
        //Call method which checks to see if the Ship_To_Account__c has changed and clears the ship to address details.
        Seed_Unit_Order_Utility.clearShipToDetails(trigger.new, trigger.oldMap);
    }

    //Before Delete Logic
    if(trigger.isBefore && trigger.isDelete){
        //Call method checkSubmittedOrder to prevent the deletion of seed unit orders that have been submitted to Oracle.
        Seed_Unit_Order_Utility.checkSubmittedOrder(trigger.old);
    }
}