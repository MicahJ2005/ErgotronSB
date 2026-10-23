@isTest
public class ERG_ReCreateSalesOrderControllerTest {
   
    static testMethod void recreateSalesOrder() {
           Account account = Test_Environment_Utility.createInsertAccountUS();
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
        contactAddress.ccrz__Partner_Id__c = account.Id;
        insert contactAddress;
        
        ccrz__E_ContactAddr__c contactAddress1 = new ccrz__E_ContactAddr__c();
        contactAddress1.ccrz__CompanyName__c = 'Test Account1';
        contactAddress1.ccrz__AddressFirstline__c = 'Address line one1';
        contactAddress1.ccrz__City__c = 'Metropolis';
        contactAddress1.ccrz__State__c = 'Georgia';
        contactAddress1.ccrz__StateISOCode__c='GA';
        contactAddress1.ccrz__Country__c = 'United States';
        contactAddress1.ccrz__CountryISOCode__c='US';
        contactAddress1.ccrz__PostalCode__c = '78667';
        contactAddress1.ccrz__FirstName__c = 'Test1';
        contactAddress1.ccrz__LastName__c = 'Singh1';
        contactAddress1.ccrz__Partner_Id__c =account.Id;
        insert contactAddress1;
        ccrz__E_Cart__c ccCart = new ccrz__E_Cart__c();
        ccCart.ccrz__CartStatus__c = 'Open';
        ccCart.ccrz__ActiveCart__c = True;
        ccCart.ccrz__BuyerCompanyName__c = 'TestCompany';
        ccCart.cc_FreightCarrierActNbr__c= 'FCA234234';
        Insert ccCart;
        
        ccrz__E_Order__c  ccOrder = new ccrz__E_Order__c();
        ccOrder.ccrz__OriginatedCart__c = ccCart.id;
        ccOrder.ccrz__OrderNumber__c= 111;
        ccOrder.ccrz__OrderStatus__c = 'Order Submitted';
        ccOrder.ERG_Order_Sync_Status__c = 'Ready For Sales Order';
        ccOrder.ccrz__ShipAmount__c = 10;        
        ccOrder.ccrz__BillTo__c = contactAddress.Id;
        ccOrder.ccrz__ShipTo__c = contactAddress1.Id;
        insert ccOrder;
        
        Sales_Order__c salesOrder= new Sales_Order__c();
        salesOrder.CC_Order_Number__c = String.valueOf(ccOrder.ccrz__OrderNumber__c);
        insert salesOrder;
        
        ccOrder.Sales_Order__c = salesOrder.Id;
        update ccOrder;
        
        ccrz__E_Product__c ccProduct = new ccrz__E_Product__c();
        ccProduct.Name = 'Test Prod';
        ccProduct.ccrz__StartDate__c = Date.Today();
        ccProduct.ccrz__EndDate__c = Date.today().addDays(10);
        ccProduct.ccrz__SKU__c ='35-341-200';
        ccProduct.ccrz__ProductStatus__c ='Released';
        ccProduct.ccrz__Quantityperunit__c =1.000000;
        insert ccProduct;
        
        
        ccrz__E_OrderItem__c  ccOrderItem = new ccrz__E_OrderItem__c();
        ccOrderItem.ccrz__Order__c = ccOrder.Id;
        ccOrderItem.ccrz__Quantity__c = 4;
        ccOrderItem.ccrz__Product__c = ccProduct.Id;
        ccOrderItem.ccrz__Price__c = 501.00;
        ccOrderItem.ccrz__SubAmount__c = 501.00;
        insert ccOrderItem;     
        
        Test.startTest();
        System.debug('ccOrder=='+ccOrder);
        ERG_ReCreateSalesOrderController.createSalesOrder(ccOrder.Id);
        ERG_ReCreateSalesOrderController.createSalesOrder(null);
        Test.stopTest();
    }
}