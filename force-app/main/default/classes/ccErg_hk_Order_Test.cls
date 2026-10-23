@isTest
public class ccErg_hk_Order_Test {
    
    @TestSetUp
    private static void setupTestData() {
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
        ccOrderObj.ccrz__OrderStatus__c = 'Open';
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
            
            ccErg_hk_Order hkOrder = new ccErg_hk_Order();
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