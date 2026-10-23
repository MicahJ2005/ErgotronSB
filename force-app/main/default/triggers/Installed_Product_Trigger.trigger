/*
    Trigger for Installed_Product__c object.
    + Before Delete Logic - Prevent deletion of Installed_Product__c records that orginated from Oracle (Oracle_Instance_Number__c!=NULL).
    
    MOD DATE        Who                     Description
    04/22/2015      Chris Noe               Initial Release
*/

trigger Installed_Product_Trigger on Installed_Product__c (before delete,before update) {

    ////Before delete logic.
    //if(trigger.isBefore && trigger.isDelete){
        //Installed_Product_Utility.beforeDelete(trigger.old);
	//}

    //if(trigger.isBefore && trigger.isUpdate){
    	//Installed_Product_Utility.beforeUpdate(trigger.newMap, trigger.oldMap);
    //}
}