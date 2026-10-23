/**
 * @description       : 
 * @author            : Rajesh Kumar
 * @group             : 
 * @last modified on  : 09-14-2020
 * @last modified by  : Rajesh Kumar
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   09-14-2020   Rajesh Kumar   Initial Version
**/
@isTest
public class ERG_Order_Confirm_ControllerTest {
    
    @TestSetUp
    private static void setupTestData() {
        Sales_Order__c soObj = new Sales_Order__c();
        soObj.Order_Sub_Type__c ='Product';
        soObj.Customer_PO_Number__c = '12345';
        insert soObj;
        
        ccrz__E_Cart__c ccCartObj = new ccrz__E_Cart__c();
        ccCartObj.ccrz__CartStatus__c = 'Open';
        ccCartObj.ccrz__ActiveCart__c = True;
        ccCartObj.ccrz__BuyerCompanyName__c = 'TestCompany';
        ccCartObj.cc_FreightCarrierActNbr__c= 'FCA234234';
        Insert ccCartObj;

        //public static ccrz__E_ContactAddr__c getcontactCCAddress(){
            ccrz__E_ContactAddr__c contactAddress = new ccrz__E_ContactAddr__c();
            contactAddress.ccrz__CompanyName__c = 'Test Account';
            contactAddress.ccrz__AddressFirstline__c = 'Address line one';
            contactAddress.ccrz__City__c = 'Metropolis';
            contactAddress.ccrz__State__c = 'Georgia';
            contactAddress.ccrz__StateISOCode__c='GA';
            contactAddress.ccrz__Country__c = 'United States';
            contactAddress.ccrz__CountryISOCode__c='US';
            contactAddress.ccrz__PostalCode__c = '78666';
            contactAddress.ccrz__FirstName__c = 'Test';
            contactAddress.ccrz__LastName__c = 'Singh';
            contactAddress.ccrz__Partner_Id__c = '123456-543210';
            insert contactAddress;
        
        Case caseObj = new case();
        caseObj.Subject='Test Case';
        caseObj.Status ='New';
        caseObj.Origin ='Phone';
        caseObj.CC_CartId__c = ccCartObj.id;
        insert caseObj;
        
        ccrz__E_Order__c  ccOrderObj = new ccrz__E_Order__c();
        ccOrderObj.ccrz__OriginatedCart__c = ccCartObj.id;
        ccOrderObj.ccrz__OrderStatus__c = 'Open';
        ccOrderObj.Sales_Order__c =soObj.Id;
        ccOrderObj.ccrz__BillTo__c = contactAddress.Id;
        ccOrderObj.ccrz__ShipTo__c = contactAddress.Id; 
        insert ccOrderObj;
        
        ccrz__E_Product__c ccProductObj = new ccrz__E_Product__c();
        ccProductObj.Name = 'Test Prod';
        ccProductObj.ccrz__StartDate__c = Date.Today();
        ccProductObj.ccrz__EndDate__c = Date.today().addDays(10);
        ccProductObj.ccrz__SKU__c ='35-341-200';
        ccProductObj.ccrz__ProductStatus__c ='Released';
        ccProductObj.ccrz__Quantityperunit__c =1.000000;
        insert ccProductObj;
        
        
        ccrz__E_OrderItem__c  ccOrderItemObj = new ccrz__E_OrderItem__c();
        ccOrderItemObj.ccrz__Order__c = ccOrderObj.Id;
        ccOrderItemObj.ccrz__Quantity__c = 4;
        ccOrderItemObj.ccrz__Product__c = ccProductObj.Id;
        ccOrderItemObj.ccrz__Price__c = 501.00;
        ccOrderItemObj.ccrz__SubAmount__c = 501.00;
        insert ccOrderItemObj; 
        
        ccrz__E_CartItem__c ccCartItemObj = new ccrz__E_CartItem__c();
        ccCartItemObj.ccrz__Cart__c = ccCartObj.id;
        ccCartItemObj.ccrz__Quantity__c = 4;
        ccCartItemObj.ccrz__Product__c = ccProductObj.Id;
        ccCartItemObj.ccrz__Price__c = 501.00;
        ccCartItemObj.ccrz__SubAmount__c = 501.00;
        insert ccCartItemObj;
        
        
    }
    
    static testMethod void getOrderMethodTest() {
        Test.startTest();
        String salesOrderId = [select Id from Sales_Order__c limit 1].Id;
        ERG_Order_Confirm_Controller ergocc = new ERG_Order_Confirm_Controller();
        ergocc.salesOrderId = salesOrderId;
        ccrz__E_Order__c ccOrderObj = ergocc.getOrder();
        system.assert(ccOrderObj != null);
        Test.stopTest();
    }
    
    static testMethod void getOrderItemMethodTest() {
        Test.startTest();
        String salesOrderId = [select Id from Sales_Order__c limit 1].Id;
        ERG_Order_Confirm_Controller ergocc = new ERG_Order_Confirm_Controller();
        ergocc.salesOrderId = salesOrderId;
        List<ccrz__E_CartItem__c> cartItemList = ergocc.getOrderItem();
        system.assertEquals(1, cartItemList.size());
        Test.stopTest();
    }
    
}