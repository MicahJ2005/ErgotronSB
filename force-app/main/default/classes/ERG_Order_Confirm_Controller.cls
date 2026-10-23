/**
 * @description       : 
 * @author            : Rajesh Kumar
 * @group             : 
 * @last modified on  : 08-10-2020
 * @last modified by  : Rajesh Kumar
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   08-08-2020   Rajesh Kumar   Initial Version
**/
public with sharing class ERG_Order_Confirm_Controller {
    public ERG_Order_Confirm_Controller() {}

    public Id salesOrderId {get;set;}
    public ccrz__E_Order__c getOrder(){

        return [SELECT Id, Name, ccrz__Account__c, ccrz__BillTo__c, ccrz__OriginatedCart__r.ccrz__BillTo__r.ccrz__FirstName__c,ccrz__BillTo__r.ccrz__FirstName__c,
        ccrz__OriginatedCart__r.ccrz__BillTo__r.ccrz__lastName__c, ccrz__OriginatedCart__r.ccrz__BillTo__r.ccrz__AddressFirstline__c, 
        ccrz__OriginatedCart__r.ccrz__BillTo__r.ccrz__City__c, ccrz__OriginatedCart__r.ccrz__BillTo__r.ccrz__StateISOCode__c, ccrz__OriginatedCart__r.ccrz__BillTo__r.ccrz__Country__c,
        ccrz__OriginatedCart__r.ccrz__BillTo__r.ccrz__PostalCode__c, ccrz__OriginatedCart__r.ccrz__ShipTo__c,ccrz__OriginatedCart__r.ccrz__ShipTo__r.ccrz__FirstName__c,
        ccrz__OriginatedCart__r.ccrz__ShipTo__r.ccrz__LastName__c,ccrz__OriginatedCart__r.ccrz__ShipTo__r.ccrz__AddressFirstline__c,ccrz__OriginatedCart__r.ccrz__ShipTo__r.ccrz__City__c,
        ccrz__OriginatedCart__r.ccrz__ShipTo__r.ccrz__StateISOCode__c,ccrz__OriginatedCart__r.ccrz__ShipTo__r.ccrz__Country__c,ccrz__OriginatedCart__r.ccrz__ShipTo__r.ccrz__PostalCode__c,
        ccrz__OriginatedCart__r.ccrz__TotalAmount__c, ccrz__OriginatedCart__r.ccrz__TaxAmount__c, ccrz__OriginatedCart__r.ccrz__ShipAmount__c, ccrz__OriginatedCart__r.ccrz__SubtotalAmount__c FROM ccrz__E_Order__c where Sales_Order__c =:salesOrderId];

    }    

    public list<ccrz__E_CartItem__c> getOrderItem(){
        
        ccrz__E_Order__c order = [SELECT Id, Name,ccrz__OriginatedCart__c FROM ccrz__E_Order__c where Sales_Order__c =:salesOrderId];

        return   [SELECT Name, Id,ccrz__Product__r.Name,ccrz__Price__c,ccrz__ItemTotal__c,
                    ccrz__Quantity__c,ccrz__SubAmount__c
                    from ccrz__E_CartItem__c where ccrz__Cart__c =:order.ccrz__OriginatedCart__c];
    }

}