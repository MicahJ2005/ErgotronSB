/*
    Trigger against Product_Schedule__c object

    MOD DATE        Who                         Description
    08/20/2019      Sophia Murphy (Dem.Chain)   Initially created as a replacement for a failing process builder and flow
                                                Case #214868
*/
trigger Product_Schedule_Trigger on Product_Schedule__c (after insert, after update)  { 

    if(trigger.isAfter && trigger.isInsert) {
        Product_Schedule_Utility.setOppCloseDate(trigger.new);
    }
    
    if(trigger.isAfter && trigger.isUpdate){
        Product_Schedule_Utility.setOppCloseDate(trigger.new);
    }
}