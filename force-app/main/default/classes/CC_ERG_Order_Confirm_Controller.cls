/**
 * Test class to run  : CC_ERG_Order_Confirm_ControllerTest
 * @description       : 
 * @author            : Unknown
 * @group             : 
 * @last modified on  : 08-10-2020
 * @last modified by  : Manoj Kumar
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   08-08-2020   Unknown   Initial Version
**/
public with sharing class CC_ERG_Order_Confirm_Controller {

    public String RelatedTo { get; set; }
    public CC_ERG_Order_Confirm_Controller() {}

    public Id salesOrderId {get;set;}
    public Id originatedCartId {get;set;}

    public ccrz__E_Order__c getOrder(){ 
        system.debug('salesOrderId =>' +salesOrderId);
        
        ccrz__E_Order__c returnOrder = [SELECT Id, Name, ccrz__Account__c, ccrz__BillTo__c, ccrz__OriginatedCart__r.ccrz__BillTo__r.ccrz__FirstName__c,ccrz__BillTo__r.ccrz__FirstName__c, ccrz__OriginatedCart__r.ccrz__BillTo__r.ccrz__lastName__c, ccrz__OriginatedCart__r.ccrz__BillTo__r.ccrz__AddressFirstline__c, ccrz__BillTo__r.ccrz__AddressSecondline__c, 
        ccrz__OriginatedCart__r.ccrz__BillTo__r.ccrz__City__c, ccrz__OriginatedCart__r.ccrz__BillTo__r.ccrz__StateISOCode__c, ccrz__OriginatedCart__r.ccrz__BillTo__r.ccrz__Country__c,
        ccrz__OriginatedCart__r.ccrz__BillTo__r.ccrz__PostalCode__c, ccrz__OriginatedCart__r.ccrz__ShipTo__c,ccrz__OriginatedCart__r.ccrz__ShipTo__r.ccrz__FirstName__c,
        ccrz__OriginatedCart__r.ccrz__ShipTo__r.ccrz__LastName__c,ccrz__OriginatedCart__r.ccrz__ShipTo__r.ccrz__AddressFirstline__c, ccrz__ShipTo__r.ccrz__AddressSecondline__c, ccrz__OriginatedCart__r.ccrz__ShipTo__r.ccrz__City__c,
        ccrz__OriginatedCart__r.ccrz__ShipTo__r.ccrz__StateISOCode__c,ccrz__OriginatedCart__r.ccrz__ShipTo__r.ccrz__Country__c,ccrz__OriginatedCart__r.ccrz__ShipTo__r.ccrz__PostalCode__c,
        ccrz__OriginatedCart__r.ccrz__TotalAmount__c, ccrz__OriginatedCart__r.ccrz__TaxAmount__c, ccrz__OriginatedCart__r.ccrz__ShipAmount__c, ccrz__OriginatedCart__r.ccrz__SubtotalAmount__c
        ,ccrz__OriginatedCart__r.Discount_Amount__c
        FROM ccrz__E_Order__c where id =:salesOrderId LIMIT 1];
        
        originatedCartId = returnOrder.ccrz__OriginatedCart__c;
        system.debug('originatedCartId =>' +originatedCartId);
        
        return returnOrder;

    }    

    public list<ccrz__E_CartItem__c> getOrderItem(){
        system.debug('salesOrderId =>' +salesOrderId);
        system.debug('originatedCartId =>' +originatedCartId);
        
        return   [SELECT Name, Id,ccrz__Product__r.Name, ccrz__Product__r.ccrz__AlternateName__c, ccrz__Price__c,ccrz__ItemTotal__c,
                    ccrz__Quantity__c,ccrz__SubAmount__c
                    from ccrz__E_CartItem__c where ccrz__Cart__c =:originatedCartId];
    }
   
    public String getCouponCode() {
        system.debug('salesOrderId =>' +salesOrderId);
        system.debug('originatedCartId =>' +originatedCartId);
        
        return [SELECT  ccrz__Coupon__r.ccrz__CouponCode__c FROM ccrz__E_CartCoupon__c WHERE ccrz__Cart__c =:originatedCartId LIMIT 1].ccrz__Coupon__r.ccrz__CouponCode__c;
    }

}