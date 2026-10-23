@isTest
public class CC_ERG_hk_Order_Test {
    
    @TestSetUp
    private static void setupTestData() {
        
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
    
      
        ccrz__E_Cart__c ccCartObj = new ccrz__E_Cart__c();
        ccCartObj.ccrz__CartStatus__c = 'Open';
        ccCartObj.ccrz__ActiveCart__c = True;
        ccCartObj.ccrz__BuyerCompanyName__c = 'TestCompany';
        ccCartObj.cc_FreightCarrierActNbr__c= 'FCA234234';
        Insert ccCartObj;
        
        Case caseObj = new case();
        caseObj.Subject='Test Case';
        caseObj.Status ='New';
        caseObj.Origin ='Phone';
        caseObj.CC_CartId__c = ccCartObj.id;
        insert caseObj;
        
        ccrz__E_Order__c  ccOrderObj = new ccrz__E_Order__c();
        ccOrderObj.ccrz__OriginatedCart__c = ccCartObj.id;
        ccOrderObj.ccrz__OrderStatus__c = 'Order Submitted';
        ccOrderObj.ccrz__BillTo__c = contactAddress.Id;
        ccOrderObj.ccrz__ShipTo__c = contactAddress1.Id;
        ccOrderObj.ERG_Order_Sync_Status__c ='Ready For Sales Order';
        ccOrderObj.ccrz__ShipAmount__c=10;
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
    }
    
    
    static testMethod void orderPlaceMethod_Test() {
        
        Test.startTest();
            ccrz__E_Order__c  ccOrderObj = [select Name,
                                            ccrz__OriginatedCart__c,
                                            ccrz__SubtotalAmount__c,
                                            ccrz__TaxAmount__c,
                                            ccrz__TotalAmount__c,
                                            ccrz__OrderStatus__c,
                                            ccrz__BillTo__c,
                                            ccrz__ShipTo__c
                                            from ccrz__E_Order__c limit 1];
            
            CC_ERG_hk_Order hkOrder = new CC_ERG_hk_Order();
            Map<String, Object> inputData;
            
            //ccrz.cc_hk_Order.STEP_END
            inputData = new Map<String, Object>();
            inputData.put(ccrz.cc_hk_order.PARAM_PLACE_STEP, ccrz.cc_hk_Order.STEP_END);
            inputData.put(ccrz.cc_hk_Order.PARAM_ORDER, ccOrderObj);
            hkOrder.place(inputData);
            
            //ccrz.cc_hk_Order.STEP_UPDATE_ORDER_STATUS_PRE
            inputData = new Map<String, Object>();
            inputData.put(ccrz.cc_hk_order.PARAM_PLACE_STEP, ccrz.cc_hk_Order.STEP_UPDATE_ORDER_STATUS_PRE);
            inputData.put(ccrz.cc_hk_Order.PARAM_ORDER, ccOrderObj);
            hkOrder.place(inputData); 
                    
        Test.stopTest();
    }
    
    
    
}