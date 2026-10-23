public without sharing class CC_ERG_CCOrderToSalesOrder {
    
    // Method to create Sales Order from CC Order invoked by platform event
    @InvocableMethod
    public static void CCOrderToSalesOrder(List<string> eventData){
        Map<String,Object> mapOfccOrder;
        for(String eventDataString: eventData){
            mapOfccOrder = new Map<String,Object>();
            mapOfccOrder = (Map<String,Object>)JSON.deserializeUntyped(eventDataString);
        }
        String ccOrderId;
        if(!mapOfccOrder.isEmpty()){
            // get the cc order to create sales order
            ccOrderId = (String)mapOfccOrder.get('Id'); 
        }
        if(String.isNotBlank(ccOrderId)){
            List<ccrz__E_Order__c> listOfCCOrders = [SELECT Id,ccrz__ShipMethod__c,ccrz__ShipAmount__c, ERG_Order_Sync_Status__c,
                                                     shipContactId__c,ccrz__Contact__c,
                                                     ccrz__ShipComplete__c,cc_FreightCarrierActNbr__c, Order_Number_Txt__c,
                                                     ccrz__OriginatedCart__c,ccrz__OrderNumber__c,ccrz__OrderStatus__c,
                                                     Sales_Order__c,ccrz__BillTo__c,ccrz__ShipTo__c, Payment_Reference__c FROM ccrz__E_Order__c
                                                     WHERE Id = :ccOrderId LIMIT 1];
            if(!listOfCCOrders.isEmpty()){
                ccrz__E_Order__c ccOrder =listOfCCOrders[0];
                //Copy CC Order Number to a text field to allow searching by CC Order Number
                //ccOrder.Order_Number_Txt__c = String.valueOf(ccOrder.ccrz__OrderNumber__c?.intValue());
                
                //Assumption is that by the time this trigger executes, there will always be a related TransactionPayment record.
                List<ccrz__E_TransactionPayment__c> listTrxPmts = [select ccrz__AccountNumber__c, ccrz__TransactionCode__c, ccrz__Token__c,ccrz__AccountType__c from ccrz__E_TransactionPayment__c where ccrz__CCOrder__c = :ccOrder.Id];
                
                List<ccrz__E_Cart__c> listOfCarts = [Select Id, Source__c,ccrz__Contact__c, ccrz__Contact__r.Store_Member__c, 
                                                     pricelistOverride__c, ergotron_order_type__c, (Select Id From Cases__r) 
                                                     FROM ccrz__E_Cart__c WHERE Id =: ccOrder.ccrz__OriginatedCart__c];
                
                List<Id> orderAddyIds = new List<Id>{ccOrder.ccrz__BillTo__c, ccOrder.ccrz__ShipTo__c};
            
                List<ccrz__E_ContactAddr__c> addresses = [Select c.ccrz__State__c,contactId__c, c.ccrz__StateISOCode__c, c.ccrz__PostalCode__c, c.ccrz__LastName__c, c.ccrz__FirstName__c, c.ccrz__Email__c, c.ccrz__DaytimePhone__c, c.ccrz__Country__c, c.ccrz__CountryISOCode__c, c.ccrz__CompanyName__c, c.ccrz__City__c, c.ccrz__AddressThirdline__c, c.ccrz__AddressSecondline__c, c.ccrz__AddressFirstline__c, c.ccrz__Partner_Id__c, ccrz__ShippingComments__c
                                                          From ccrz__E_ContactAddr__c c
                                                          Where c.Id in: orderAddyIds LIMIT 2];
                Boolean isAccountHierarchyProcessed = false;
                if(addresses?.size() > 0){
                    if(addresses?.get(0)?.ccrz__Partner_Id__c != null) {
                        isAccountHierarchyProcessed = true;
                    } else {
                        isAccountHierarchyProcessed = false;
                    }
                }
                if(addresses?.size() > 1){
                    if(addresses?.get(1)?.ccrz__Partner_Id__c != null) {
                        isAccountHierarchyProcessed = true;
                    } else {
                        isAccountHierarchyProcessed = false;
                    }
                }
                
                System.debug('order => '+ccOrder);
                System.debug('ccOrder.ccrz__OrderStatus__c => '+ccOrder.ccrz__OrderStatus__c);
                System.debug('ccOrder.Sales_Order__c => '+ccOrder.Sales_Order__c);
                System.debug('isAccountHierarchyProcessed => '+isAccountHierarchyProcessed);
                
                ccrz__E_Cart__c cart;
                if(!listOfCarts.isEmpty()){
                    cart = listOfCarts[0];
                }
                 System.debug('cart => '+cart);
                // DO NOT CREATE A SALES ORDER IF ONE IS ALREADY LINKED TO THE ORDER!
                if(Erg_Constants.Order_Submitted.equals(ccOrder.ccrz__OrderStatus__c) && ccOrder?.Sales_Order__c == null &&
                    ccOrder?.ERG_Order_Sync_Status__c.equalsIgnoreCase(Erg_Constants.Ready_For_Sales_Order) &&
                   (cart?.Source__c?.equalsIgnoreCase(Erg_Constants.Salesforce) || isAccountHierarchyProcessed)
                  ){
                      Sales_Order__c newSalesOrder = new Sales_Order__c();
                      //List Header Id to put on the salesorder.
                      List<ccrz__E_PriceList__c> listPL = [Select price_book__r.List_Header_Id__c From ccrz__E_PriceList__c Where Id = :cart.priceListOverride__c];
                      if(listPL.size()>0){
                          for(ccrz__E_PriceList__c thePL: listPL){
                              newSalesOrder.Seed_Price_List__c = thePl.price_book__r.List_Header_Id__c;
                          }
                      }
                      
                      if(listTrxPmts.size()>0) {
                          if(String.IsNotBlank(listTrxPmts[0].ccrz__AccountType__c) && listTrxPmts[0].ccrz__AccountType__c=='Credit Card'){
                          	  newSalesOrder.Customer_PO_Number__c = ccOrder.Order_Number_Txt__c;
                          }
                          else if(String.IsNotBlank(listTrxPmts[0].ccrz__TransactionCode__c)){
                              newSalesOrder.Customer_PO_Number__c = listTrxPmts[0].ccrz__TransactionCode__c;
                          }else{
                              newSalesOrder.Customer_PO_Number__c = listTrxPmts[0].ccrz__AccountNumber__c;
                          }
                          newSalesOrder.CC_Order_Number__c = String.valueOf(ccOrder.ccrz__OrderNumber__c?.intValue());
                          newSalesOrder.Credit_Card_Approval_Code__c = listTrxPmts[0].ccrz__Token__c;
                      }
                      //R1-29 May 2025-for CC
                      else{
                           newSalesOrder.Customer_PO_Number__c = ccOrder.Order_Number_Txt__c;
                           newSalesOrder.CC_Order_Number__c = String.valueOf(ccOrder.ccrz__OrderNumber__c?.intValue());
                           newSalesOrder.Credit_Card_Approval_Code__c = ccOrder.Payment_Reference__c; //ESanchez - Payment Reference from Stripe - 7-Jul-2025
                      }
                      
                      newSalesOrder.Order_Sub_Type__c =Erg_Constants.Product;
                      newSalesOrder.Order_Type_Id__c = cart.ergotron_order_type__c;
                      
                      List<Oracle_Order_Type__c> oraOrdTypes = [SELECT Name, Order_Type_id__c, Salesforce_Order_Type__c FROM Oracle_Order_Type__c];
                      
                      for(Oracle_Order_Type__c theOraOrdType : oraOrdTypes){
                          if(theOraOrdType.Order_Type_id__c==newSalesOrder.Order_Type_Id__c) {
                              newSalesOrder.Order_Type__c = theOraOrdType.Name;      
                          }
                      }
                      
                      newSalesOrder.Freight_Carrier_Account_Number__c = ccOrder.cc_FreightCarrierActNbr__c;
                      // If couldn't get FCAN order, let's try the cart.
                      if(newSalesOrder.Freight_Carrier_Account_Number__c == null){
                          ccrz__E_Cart__c theCart = [SELECT cc_FreightCarrierActNbr__c FROM ccrz__E_Cart__c WHERE Id = :ccOrder.ccrz__OriginatedCart__c];
                          newSalesOrder.Freight_Carrier_Account_Number__c = theCart.cc_FreightCarrierActNbr__c;
                      }
                      
                      if(cart.Cases__r != null && cart.Cases__r.size() > 0){
                          newSalesOrder.Service_Request__c = cart.Cases__r[0].Id;                  
                      }
                      
                      for(ccrz__E_ContactAddr__c address : addresses){
                          if(ccOrder.ccrz__BillTo__c == address.Id){
                              newSalesOrder.Bill_To_Customer__c = address.ccrz__Partner_Id__c;                      
                          }
                          
                          if(ccOrder.ccrz__ShipTo__c == address.Id){
                              if(ccOrder.shipContactId__c != null){
                                  newSalesOrder.Ship_To_Contact__c = ccOrder.shipContactId__c;
                              }else{
                                  newSalesOrder.Ship_To_Contact__c = ccOrder.ccrz__Contact__c;
                              }
                              newSalesOrder.Billl_To_Contact__c = ccOrder.ccrz__Contact__c;
                              newSalesOrder.Ship_To_Customer__c = address.ccrz__Partner_Id__c;
                              newSalesOrder.Ship_To_City_State_Zip_Country_Oracle__c = address.ccrz__City__c + ',' + address.ccrz__StateISOCode__c + ',' + address.ccrz__PostalCode__c + ',' + address.ccrz__CountryISOCode__c;
                              newSalesOrder.Ship_To_Address3_Oracle__c = address.ccrz__AddressThirdLine__c;
                              newSalesOrder.Ship_To_Address2_Oracle__c = address.ccrz__AddressSecondLine__c;
                              newSalesOrder.Ship_To_Address1_Oracle__c = address.ccrz__AddressFirstLine__c;
                              newSalesOrder.Cust_Delivery_Info__c = address.ccrz__ShippingComments__c; // shipping notes
                              
                          }
                      }
                      List<ERG_Shipping_Method__mdt> listOfShippingMethods= [SELECT Shipping_Method__c,Shipping_Code__c
                                                                            FROM ERG_Shipping_Method__mdt];
                      Map<string, string> mapOfShipMethods= new Map<string, string>();
                      if(!listOfShippingMethods.isEmpty()){
                          for(ERG_Shipping_Method__mdt shipMethods : listOfShippingMethods){
                            	mapOfShipMethods.put((shipMethods.Shipping_Method__c).toLowerCase(), shipMethods.Shipping_Code__c);
                          }
                          
                          string shipMethod = ccOrder.ccrz__ShipMethod__c; 
                          if(String.isNotBlank(shipMethod) && !mapOfShipMethods.isEmpty() && mapOfShipMethods.containsKey(shipMethod.toLowerCase()) && mapOfShipMethods.get(shipMethod.toLowerCase()) != NULL){
                              newSalesOrder.Shipping_Method_Code__c = mapOfShipMethods.get(shipMethod.toLowerCase());
                          }
                      }                      
                      newSalesOrder.Ship_Complete__c = ccOrder.ccrz__ShipComplete__c;
                      newSalesOrder.Source__c =Erg_Constants.B2BCommerce;              
                      insert newSalesOrder;
                      
                      System.debug('New inserted sales order => '+newSalesOrder);
                      
                      List<Sales_Order_Line__c> newSalesOrderLines = new List<Sales_Order_Line__c>();
                      List<ccrz__E_CartItem__c> cartItems = [select id, ccrz__product__r.ccrz__sku__c, ergo_wh_location__c from ccrz__E_CartItem__c where ccrz__Cart__r.Id =: ccOrder.ccrz__OriginatedCart__c];
                      
                      Map<String, String> skuToLocationCode = new Map<String, String>();
                      for(ccrz__E_CartItem__c theItem : cartItems){
                          skuToLocationCode.put(theItem.ccrz__Product__r.ccrz__SKU__c, theItem.ergo_wh_location__c);
                      }
                      List<Product2> stdProds = [SELECT id, productCode from Product2 
                                                 WHERE ProductCode in: skuToLocationCode.keySet() OR productCode =: ERG_Constants.FREIGHT_CHARGE ];
                      Map<String, Id> skuToProducts = new Map<String, Id>();
                      for(Product2 theProd: stdProds){
                          skuToProducts.put(theProd.ProductCode, theProd.Id);
                      }
                      
                      for(ccrz__E_OrderItem__c ccOrderItem : [select id, ccrz__product__r.Name, ccrz__product__r.ccrz__SKU__c, ccrz__quantity__c, ccrz__subamount__c, ccrz__ItemTotal__c from ccrz__E_OrderItem__c where ccrz__Order__r.Id =: ccOrder.Id]){
                          Sales_Order_Line__c newSalesOrderLine = new Sales_Order_Line__c();
                          newSalesOrderLine.Sales_Order__c = newSalesOrder.Id;
                          newSalesOrderLine.Warehouse__c = skuToLocationCode.get(ccOrderItem.ccrz__product__r.ccrz__SKU__c);
                          newSalesOrderLine.Quantity__c = ccOrderItem.ccrz__quantity__c;
                          newSalesOrderLine.Part_Number__c = skuToProducts.get(ccOrderItem.ccrz__product__r.ccrz__SKU__c);
                          newSalesOrderLine.CC_Order_Item__c = ccOrderItem.Id;
                          newSalesOrderLine.Price__c = ccOrderItem.ccrz__ItemTotal__c/ccOrderItem.ccrz__Quantity__c;
                          newSalesOrderLine.Calculate_Price__c = 'N';
                          newSalesOrderLines.add(newSalesOrderLine);
                      }
                      if(ccOrder.ccrz__ShipAmount__c != null && ccOrder.ccrz__ShipAmount__c != 0){                        
                          Sales_Order_Line__c newSalesOrderLine = new Sales_Order_Line__c();
                          newSalesOrderLine.Sales_Order__c = newSalesOrder.Id;
                          newSalesOrderLine.Quantity__c = 1;
                          newSalesOrderLine.Part_Number__c =skuToProducts.get(ERG_Constants.FREIGHT_CHARGE);
                          newSalesOrderLine.Price__c = ccOrder.ccrz__ShipAmount__c ;
                          newSalesOrderLine.Calculate_Price__c = 'N';
                          newSalesOrderLines.add(newSalesOrderLine);
                      }
                     
                      insert newSalesOrderLines;
                      
                      //update CC order field with Sales order id
                      updateOrderWithSalesOrderId(ccOrder.Id, newSalesOrder.Id);
                      
                      ccOrder.Sales_Order__c = newSalesOrder.Id;
                      boolean skipOracle = false;
                      List<ccrz__E_Configuration__c> skipOraCfg =[SELECT Name, ccrz__ConfigurationMeta__r.name, ccrz__TextValue__c FROM ccrz__E_Configuration__c where ccrz__ConfigurationMeta__r.name = 'Skip Oracle Transmit' limit 1];
                      if(skipOraCfg.size() > 0){
                          if(skipOraCfg[0].ccrz__TextValue__c != null)
                              skipOracle = Boolean.valueOf(skipOraCfg[0].ccrz__TextValue__c);
                      }
                      if(!Test.isRunningTest() && !skipOracle){
                          ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'ERGB2BOrderToSalesOrder: SubmitToOracle='+newSalesOrder.Id);
                          ICRT_TransmitOrder.singleIdToSubmitOrderToICRT(newSalesOrder.Id);
                      }
                      //  on creation of a sales order, if the contact on the order's originating cart is not 
                      //  a store member, then deactivate the user tied to the contact
                      //  ccOrder.ccrz__OriginatedCart__c
                      if(!cart.ccrz__Contact__r.Store_Member__c){
                          try{
                              ID uId = ccrz.cc_CallContext.currUserId;
                              //ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'ERGB2BOrderToSalesOrder: uId='+uId);
                              CC_ERG_static_utils.deactivateUser(uId);
                          }catch(Exception e){
                          }
                      }	
                  }
            }
        }
    }
    
    // update CC order with new sales order created and order sync status
    public static void updateOrderWithSalesOrderId(Id ccOrderId, Id salesOrderId){    	
        ccrz__E_Order__c ccOrder = new ccrz__E_Order__c();
        try{
            ccOrder.Id = ccOrderId;
            ccOrder.Sales_Order__c = salesOrderId;
            ccOrder.ERG_Order_Sync_Status__c = Erg_Constants.Sales_Order_Created;
            update ccOrder;
            System.debug('ccOrder=>>>>>'+ccOrder);
        }
        catch(Exception ex){
            System.debug('Exception in CC_ERG_CCOrderToSalesOrder>updateOrderWithSalesOrderId:'+ccOrderId);
        }
    }
}