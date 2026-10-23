global without sharing class CC_ERG_hk_Order extends digitalriverb2b.DRB2B_hk_Order {
    // Task 175: Create a case comment with the order details when the order is "submitted."   
    private void insertCaseComment(ccrz__E_Order__c currentOrder) {
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'debug_ccErg_hk_Order#insertCaseComment');
        // refetch the order in order to guarantee that ordername, order subtotal and total are all available.
        ccrz__E_Order__c refetchOrder = [select Name,
                                         ccrz__OriginatedCart__c,
                                         ccrz__SubtotalAmount__c,
                                         ccrz__TaxAmount__c,
                                         ccrz__TotalAmount__c,
                                         ccrz__OrderStatus__c,
                                         ccrz__BillTo__c,
                                         ccrz__ShipTo__c
                                         from ccrz__E_Order__c
                                         where id = :currentOrder.Id];
        try{
            Case theCase = [select id
                            from Case
                            where CC_CartId__c = :refetchOrder.ccrz__OriginatedCart__c];
            
            // Format the case comment
            Map<Id, CaseComment> caseMap = new Map<Id,CaseComment>(); 
            CaseComment c = new CaseComment();
            c.CommentBody = 'ORDER: '+refetchOrder.Name+'\nID: '+refetchOrder.Id+'\nOrder Status: '+refetchOrder.ccrz__OrderStatus__c
                +'\n\nORDER ITEMS:';
            
            // We will have a loop here for the order items list
            for(ccrz__E_OrderItem__c ordItms : [select ccrz__Quantity__c, 
                                                ccrz__Product__r.ccrz__SKU__c, 
                                                ccrz__Product__r.Name 
                                                from ccrz__E_OrderItem__c 
                                                where ccrz__Order__c = :currentOrder.Id]) {
                                                    
                                                    c.CommentBody = c.CommentBody + '\nSKU: '+ordItms.ccrz__Product__r.ccrz__SKU__c
                                                        +'; ProdName: '+ordItms.ccrz__Product__r.Name
                                                        +'; OrderQty: '+ordItms.ccrz__Quantity__c+'.';         
                                                }
            
            c.IsPublished = true;
            c.ParentId = theCase.Id;
            insert c;
        } catch(Exception e) {
            System.debug(System.LoggingLevel.ERROR, 'An exception occurred while trying to insert a case comment on order submission: '+e.getMessage());
            ccrz.ccLog.log(System.LoggingLevel.ERROR, 'ccErg_hk_Order: ERROR'+e.getMessage());
        }
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:X', 'debug_ccErg_hk_Order#insertCaseComment');        
    }//end insertCaseComment
    
    // updateFCAN updates both the freight carrier number (FCAN) and the PO Number on the CC Order record.
    private void updateFCAN(ccrz__E_Order__c currentOrder) {
        ccrz__E_Order__c theOrder = [SELECT Id, ccrz__OriginatedCart__r.cc_FreightCarrierActNbr__c, cc_FreightCarrierActNbr__c,
                                     ccrz__OriginatedCart__r.Name, ccrz__OriginatedCart__r.ccrz__TotalAmount__c
                                     FROM ccrz__E_Order__c 
                                     WHERE Id = :currentOrder.Id];
        
        if(String.isNotBlank(theOrder.ccrz__OriginatedCart__r.cc_FreightCarrierActNbr__c)) {
            
            theOrder.cc_FreightCarrierActNbr__c = theOrder.ccrz__OriginatedCart__r.cc_FreightCarrierActNbr__c;
            
            update theOrder;           
        }
        
        //if the total amount on the cart is zero, then default the order po# to the case Name.
        //TODO: This will have to be replaced when the Place Order button on the checkout flow is changed so that the 
        //      CSR can get to the PO # field on the Payment Tab.
        if(theOrder.ccrz__OriginatedCart__r.ccrz__TotalAmount__c==0){
            theOrder.ccrz__PONumber__c = theOrder.ccrz__OriginatedCart__r.Name;
            
            update theOrder;
            
        }        
        
    }
    /*private void updateBillToShipTo(ccrz__E_Order__c currentOrder) {
ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'debug_ccErg_hk_Order#updateBillToShipTo');
ccrz__E_Order__c theOrder = [SELECT Id, ccrz__OriginatedCart__C,ccrz__BillTo__c,ccrz__ShipTo__c,ccrz__OriginatedCart__r.ccrz__BillTo__c,
ccrz__OriginatedCart__r.ccrz__ShipTo__c                                        
FROM ccrz__E_Order__c 
WHERE Id = :currentOrder.Id];
if(String.isNotBlank(theOrder.ccrz__OriginatedCart__C)) {
ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'debug_ccErg_hk_Order#updateBillToShipTo - Order Found');
// Get cart Billing & Shipping Addresses 
ccrz__E_ContactAddr__c cartBillTo = [SELECT Id FROM ccrz__E_ContactAddr__c WHERE Id = :theOrder.ccrz__OriginatedCart__r.ccrz__BillTo__c];
ccrz__E_ContactAddr__c cartShipTo = [SELECT Id FROM ccrz__E_ContactAddr__c WHERE Id = :theOrder.ccrz__OriginatedCart__r.ccrz__ShipTo__c];

// Create Required Billing & Shipping Address records for order
ccrz__E_ContactAddr__c orderBillTo = cartBillTo.clone(false, true, false, false);
ccrz__E_ContactAddr__c orderShipTo = cartShipTo.clone(false, true, false, false);

// Insert order Billing & Shipping Address
Insert orderBillTo;
Insert orderShipTo; 
theOrder.ccrz__BillTo__c = orderBillTo.id;
theOrder.ccrz__ShipTo__c = orderShipTo.id;
update theOrder;
}   

}*/
    
    private static void updateOrderSyncStatus(string currentOrderId, string source){
        
        List<ccrz__E_Order__c> listOfOrders = [SELECT Id, ERG_Order_Sync_Status__c
                                               FROM ccrz__E_Order__c 
                                               WHERE Id = :currentOrderId LIMIT 1];
        if(!listOfOrders.isEmpty()){
            for(ccrz__E_Order__c ccOrder: listOfOrders){
                if(source.equalsIgnoreCase(ERG_Constants.Salesforce)){
                    ccOrder.ERG_Order_Sync_Status__c =ERG_Constants.Ready_For_Sales_Order;
                }
                else{ 
                    ccOrder.ERG_Order_Sync_Status__c =ERG_Constants.Not_Started;
                }                
                update ccOrder;
                System.debug('hk order'+ ccOrder.ERG_Order_Sync_Status__c);
            }
        }
    }
    global override Map<String,Object> place(Map<String,Object> inputData) {
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'debug_ccErg_hk_Order#place');  
        
        String currentStep = (String) inputData.get(ccrz.cc_hk_order.PARAM_PLACE_STEP);
        System.debug('>>>currentStep'+currentStep);
        if(ccrz.cc_hk_Order.STEP_END.equals(currentStep)) {
            ccrz__E_Order__c currentOrder = (ccrz__E_Order__c)inputData.get(ccrz.cc_hk_Order.PARAM_ORDER);
            
            ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'debug_ccErg_hk_Order#place');
            if(currentOrder?.ccrz__OriginatedCart__c != null){
                ccrz__E_Cart__c cartData = [Select Id, Source__c from ccrz__E_Cart__c where Id =:  currentOrder.ccrz__OriginatedCart__c];
                ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:X', 'cart data '+cartData);
                
                // update order sync status to 'Not Started'
                updateOrderSyncStatus(currentOrder.Id,cartData.Source__c);
                
                if(cartData?.Source__c?.equalsIgnoreCase('Salesforce')) {                    
                    insertCaseComment(currentOrder);
                    updateFCAN(currentOrder);
                    
                    try{
                        ERG_CCOrderToSalesOrder__e event = new ERG_CCOrderToSalesOrder__e();
                        event.CCOrder__c  = JSON.serialize(currentOrder);
                        Database.SaveResult result = EventBus.publish(event);  
                    }
                    catch(Exception ex){
                        System.debug('Exception in calling event ->'+ ex.getMessage());
                    }
                    
                } else {
                    ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'debug_ccErg_hk_Order#place --> Now checkCCOrderBillToShipTo');
                    
                    try{
                        // create account hierarchy through platform event
                        ERG_CreateAccountHierarchy__e event = new ERG_CreateAccountHierarchy__e();
                        event.CCOrder__c  = JSON.serialize(currentOrder);
                        Database.SaveResult result = EventBus.publish(event); 
                    }
                    catch(Exception ex){
                        System.debug('Exception in calling event ->'+ ex.getMessage());
                    }
                }
            }
        }else if(ccrz.cc_hk_Order.STEP_UPDATE_ORDER_STATUS_PRE.equals(currentStep)){
            System.debug('inputData------->'+inputData);
            super.place(inputData);
        }
        
        
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:X', 'debug_ccErg_hk_Order#place');        
        return inputData;
    }
    
}