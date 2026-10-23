global without sharing class ccErg_hk_Order extends digitalriverb2b.DRB2B_hk_Order {
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

    global override Map<String,Object> place(Map<String,Object> inputData) {
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'debug_ccErg_hk_Order#place');  
        
        String currentStep = (String) inputData.get(ccrz.cc_hk_order.PARAM_PLACE_STEP);
        System.debug('>>>currentStep'+currentStep);
        if(ccrz.cc_hk_Order.STEP_END.equals(currentStep)) {
            ccrz__E_Order__c currentOrder = (ccrz__E_Order__c)inputData.get(ccrz.cc_hk_Order.PARAM_ORDER);

            insertCaseComment(currentOrder);
            
            updateFCAN(currentOrder);
        }else if(ccrz.cc_hk_Order.STEP_UPDATE_ORDER_STATUS_PRE.equals(currentStep)){
            System.debug('inputData------->'+inputData);
            super.place(inputData);
        }
        
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:X', 'debug_ccErg_hk_Order#place');        
        return inputData;
    }
}