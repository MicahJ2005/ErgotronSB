/**
* @description       : 
* @author            : Rajesh Kumar
* @group             : 
* @last modified on  : 09-12-2020
* @last modified by  : Rajesh Kumar
* Modifications Log 
* Ver   Date         Author         Modification
* 1.0   09-06-2020   Rajesh Kumar   Initial Version
* 1.1   10-23-2020   GVanSteeter	 Modified cartHeader SOQL
*                                   Added logic at bottom of sales order creation if branch to deactivate the user if 
*                                   the cart Contact is not a store member.
* 1.2  10-23-2020    Esau Sanchez   On sales order creation, set Sales_Order__c.Source__c = "B2BCommerce"
*		07-28-2021	  Esau Sanchez   On sales order line creation, added Price__c and Calculate_Price__c fields
* 		09-17-2021	  Sophia Murphy  Demand Chain
* 									 Added in delay of 1 hour before sending Order to Oracle; DC Case 10352; https://app.asana.com/0/1199602135063439/1200498374027431/f
* 		09-17-2021	  Esau Sanchez	 Copy the CC Order Number from the CC Order to the Sales Order so we can use this in the order confirmation email
**/
trigger ERGB2BOrderToSalesOrder on ccrz__E_Order__c (before update,after update) {
    for(ccrz__E_Order__c theOrder : Trigger.new){
                     ccrz__E_Order__c oldOrder = Trigger.oldMap.get(theOrder.ID);
        
                     //once we get the older version, we can get any field's value from older version to compare.
                     if(!String.isBlank(theOrder.ccrz__OrderStatus__c) && !String.isBlank(oldOrder.ccrz__OrderStatus__c) 
                        && theOrder.ccrz__OrderStatus__c != oldOrder.ccrz__OrderStatus__c && oldOrder.ccrz__OrderStatus__c =='On Hold'
                        && theOrder.ccrz__OrderStatus__c == 'Order Submitted') {
                            
                            if(Trigger.isUpdate){
                                if(Trigger.isBefore){
                                    theOrder.ERG_Order_Sync_Status__c ='Ready For Sales Order';
                                }
                                if(Trigger.isAfter){
                                    ERG_CCOrderToSalesOrder__e event = new ERG_CCOrderToSalesOrder__e();
                                    event.CCOrder__c  = JSON.serialize(theOrder);
                                    Database.SaveResult result = EventBus.publish(event);  
                                }
                            }
                        }
                     }
                     }
                     //Version 2020.02.24 16
                     //CC_ERG_CreateAccountHierarchy.createSalesOrderEvent(Trigger.old);
                     /* for(ccrz__E_Order__c theOrder : Trigger.new){

//Copy CC Order Number to a text field to allow searching by CC Order Number
theOrder.Order_Number_Txt__c = String.valueOf(theOrder.ccrz__OrderNumber__c?.intValue());

system.debug('In for');
//Assumption is that by the time this trigger executes, there will always be a related TransactionPayment record.
List<ccrz__E_TransactionPayment__c> listTrxPmts = [select ccrz__AccountNumber__c, ccrz__TransactionCode__c, ccrz__Token__c from ccrz__E_TransactionPayment__c where ccrz__CCOrder__c = :theOrder.Id];
//System.debug(System.LoggingLevel.DEBUG, 'debug_ERGB2BOrderToSalesOrder: AT THE TOP: OrderStatus='+theOrder.ccrz__OrderStatus__c+'; Sales_Order_c='+theOrder.Sales_Order__c);

ccrz__E_Cart__c cart = [Select Id, Source__c,ccrz__Contact__c, ccrz__Contact__r.Store_Member__c, pricelistOverride__c, ergotron_order_type__c, (Select Id From Cases__r) from ccrz__E_Cart__c where Id =: theOrder.ccrz__OriginatedCart__c];
List<Id> orderAddyIds = new List<Id>{theOrder.ccrz__BillTo__c, theOrder.ccrz__ShipTo__c};
System.debug('orderAddyIds :'+orderAddyIds);
List<ccrz__E_ContactAddr__c> addresses = [Select c.ccrz__State__c,contactId__c, c.ccrz__StateISOCode__c, c.ccrz__PostalCode__c, c.ccrz__LastName__c, c.ccrz__FirstName__c, c.ccrz__Email__c, c.ccrz__DaytimePhone__c, c.ccrz__Country__c, c.ccrz__CountryISOCode__c, c.ccrz__CompanyName__c, c.ccrz__City__c, c.ccrz__AddressThirdline__c, c.ccrz__AddressSecondline__c, c.ccrz__AddressFirstline__c, c.ccrz__Partner_Id__c, ccrz__ShippingComments__c
From ccrz__E_ContactAddr__c c
Where c.Id in: orderAddyIds LIMIT 2];
System.debug('addresses :'+addresses);
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

System.debug('order => '+theOrder);
System.debug('theOrder.ccrz__OrderStatus__c => '+theOrder.ccrz__OrderStatus__c);
System.debug('theOrder.Sales_Order__c => '+theOrder.Sales_Order__c);
System.debug('cart => '+cart);
System.debug('cart => '+cart.Source__c);
System.debug('isAccountHierarchyProcessed => '+isAccountHierarchyProcessed);
// DO NOT CREATE A SALES ORDER IF ONE IS ALREADY LINKED TO THE ORDER!
if('Order Submitted'.equals(theOrder.ccrz__OrderStatus__c) && theOrder?.Sales_Order__c == null && 
(cart?.Source__c?.equalsIgnoreCase('Salesforce') || isAccountHierarchyProcessed)
){
//System.debug(System.LoggingLevel.DEBUG, 'debug_ERGB2BOrderToSalesOrder: INSIDE IF STATEMENT');
// 2020.10.23 gvansteeter commented out: ccrz__E_Cart__c cartHeader = [Select c.pricelistOverride__c, c.ergotron_order_type__c, (Select Id From Cases__r) From ccrz__E_Cart__c c where c.Id =: theOrder.ccrz__OriginatedCart__c];
//ccrz__E_Cart__c cartHeader = [SELECT c.ccrz__Contact__c, c.ccrz__Contact__r.Store_Member__c, c.pricelistOverride__c, c.ergotron_order_type__c, (Select Id From Cases__r) 
//FROM ccrz__E_Cart__c c 
//WHERE c.Id =: theOrder.ccrz__OriginatedCart__c];

Sales_Order__c newSalesOrder = new Sales_Order__c();

//2020.02.21: need the List Header Id to put on the salesorder.
List<ccrz__E_PriceList__c> listPL = [Select price_book__r.List_Header_Id__c From ccrz__E_PriceList__c Where Id = :cart.priceListOverride__c];
if(listPL.size()>0){
for(ccrz__E_PriceList__c thePL: listPL){
newSalesOrder.Seed_Price_List__c = thePl.price_book__r.List_Header_Id__c;
}
}

if(listTrxPmts.size()>0) {
if(String.IsNotBlank(listTrxPmts[0].ccrz__TransactionCode__c)){
newSalesOrder.Customer_PO_Number__c = listTrxPmts[0].ccrz__TransactionCode__c;
}else{
newSalesOrder.Customer_PO_Number__c = listTrxPmts[0].ccrz__AccountNumber__c;
}
newSalesOrder.CC_Order_Number__c = String.valueOf(theOrder.ccrz__OrderNumber__c?.intValue());
newSalesOrder.Credit_Card_Approval_Code__c = listTrxPmts[0].ccrz__Token__c;
}

newSalesOrder.Order_Sub_Type__c = 'Product';
newSalesOrder.Order_Type_Id__c = cart.ergotron_order_type__c;

List<Oracle_Order_Type__c> oraOrdTypes = [SELECT Name, Order_Type_id__c, Salesforce_Order_Type__c FROM Oracle_Order_Type__c];

for(Oracle_Order_Type__c theOraOrdType : oraOrdTypes){
if(theOraOrdType.Order_Type_id__c==newSalesOrder.Order_Type_Id__c) {
newSalesOrder.Order_Type__c = theOraOrdType.Name;      
}
}

newSalesOrder.Freight_Carrier_Account_Number__c = theOrder.cc_FreightCarrierActNbr__c;
// If couldn't get FCAN order, let's try the cart.
if(newSalesOrder.Freight_Carrier_Account_Number__c == null){
ccrz__E_Cart__c theCart = [SELECT cc_FreightCarrierActNbr__c FROM ccrz__E_Cart__c WHERE Id = :theOrder.ccrz__OriginatedCart__c];
newSalesOrder.Freight_Carrier_Account_Number__c = theCart.cc_FreightCarrierActNbr__c;
}

if(cart.Cases__r != null && cart.Cases__r.size() > 0){
newSalesOrder.Service_Request__c = cart.Cases__r[0].Id;

}

for(ccrz__E_ContactAddr__c address : addresses){
System.debug('address -->'+address);
System.debug('address.ccrz__Partner_Id__c -->'+address.ccrz__Partner_Id__c);
// System.debug('address.theOrder.ccrz__Partner_Id__c -->'+theOrder.ccrz__ShipTo__r.ccrz__Partner_Id__c);
if(theOrder.ccrz__BillTo__c == address.Id){
newSalesOrder.Bill_To_Customer__c = address.ccrz__Partner_Id__c;//added 2020.02.11

}
System.debug('theOrder.ccrz__ShipTo__c -->'+theOrder.ccrz__ShipTo__c);
System.debug('address.Id  :'+address.Id);
if(theOrder.ccrz__ShipTo__c == address.Id){
System.debug('theOrder.shipContactId__c :'+theOrder.shipContactId__c);
if(theOrder.shipContactId__c != null){
newSalesOrder.Ship_To_Contact__c = theOrder.shipContactId__c;
}else{
newSalesOrder.Ship_To_Contact__c = theOrder.ccrz__Contact__c;
}
newSalesOrder.Billl_To_Contact__c = theOrder.ccrz__Contact__c;
newSalesOrder.Ship_To_Customer__c = address.ccrz__Partner_Id__c;//added 2020.02.11
newSalesOrder.Ship_To_City_State_Zip_Country_Oracle__c = address.ccrz__City__c + ',' + address.ccrz__StateISOCode__c + ',' + address.ccrz__PostalCode__c + ',' + address.ccrz__CountryISOCode__c;
newSalesOrder.Ship_To_Address3_Oracle__c = address.ccrz__AddressThirdLine__c;
newSalesOrder.Ship_To_Address2_Oracle__c = address.ccrz__AddressSecondLine__c;
newSalesOrder.Ship_To_Address1_Oracle__c = address.ccrz__AddressFirstLine__c;
newSalesOrder.Cust_Delivery_Info__c = address.ccrz__ShippingComments__c; // shipping notes
}
}
// Esau Sanchez - Ergotron - 4/22/2020
newSalesOrder.Ship_Complete__c = theOrder.ccrz__ShipComplete__c;
newSalesOrder.Source__c = 'B2BCommerce'; // Esau Sanchez - Ergotron - 10/22/2020

insert newSalesOrder;

System.debug('New inserted sales order => '+newSalesOrder);

List<Sales_Order_Line__c> newSalesOrderLines = new List<Sales_Order_Line__c>();
List<ccrz__E_CartItem__c> cartItems = [select id, ccrz__product__r.ccrz__sku__c, ergo_wh_location__c from ccrz__E_CartItem__c where ccrz__Cart__r.Id =: theOrder.ccrz__OriginatedCart__c];

Map<String, String> skuToLocationCode = new Map<String, String>();

for(ccrz__E_CartItem__c theItem : cartItems){

skuToLocationCode.put(theItem.ccrz__Product__r.ccrz__SKU__c, theItem.ergo_wh_location__c);
}
List<Product2> stdProds = [select id, productCode from Product2 where ProductCode in: skuToLocationCode.keySet()];
Map<String, Id> skuToProducts = new Map<String, Id>();
for(Product2 theProd: stdProds){
skuToProducts.put(theProd.ProductCode, theProd.Id);
}

for(ccrz__E_OrderItem__c theOrderItem : [select id, ccrz__product__r.Name, ccrz__product__r.ccrz__SKU__c, ccrz__quantity__c, ccrz__subamount__c, ccrz__ItemTotal__c from ccrz__E_OrderItem__c where ccrz__Order__r.Id =: theOrder.Id]){
Sales_Order_Line__c newSalesOrderLine = new Sales_Order_Line__c();
newSalesOrderLine.Sales_Order__c = newSalesOrder.Id;
newSalesOrderLine.Warehouse__c = skuToLocationCode.get(theOrderItem.ccrz__product__r.ccrz__SKU__c);
newSalesOrderLine.Quantity__c = theOrderItem.ccrz__quantity__c;
newSalesOrderLine.Part_Number__c = skuToProducts.get(theOrderItem.ccrz__product__r.ccrz__SKU__c);
newSalesOrderLine.CC_Order_Item__c = theOrderItem.Id;
newSalesOrderLine.Price__c = theOrderItem.ccrz__ItemTotal__c/theOrderItem.ccrz__Quantity__c;
newSalesOrderLine.Calculate_Price__c = 'N';
newSalesOrderLines.add(newSalesOrderLine);
}
//System.debug(System.LoggingLevel.DEBUG, 'debug_ERGB2BOrderToSalesOrder: INSERT NEWSALESORDERLINES');
insert newSalesOrderLines;
/*
//System.debug(System.LoggingLevel.DEBUG, 'debug_ERGB2BOrderToSalesOrder: CALL THE HELPER');
ERGB2BOrderToSalesOrderHelper.updateOrderWithSalesOrderId(theOrder.Id, newSalesOrder.Id);
*/
                     /* theOrder.Sales_Order__c = newSalesOrder.Id;
//System.debug(System.LoggingLevel.DEBUG, 'debug_ERGB2BOrderToSalesOrder: SUBMIT TO ICRT');
boolean skipOracle = false;
List<ccrz__E_Configuration__c> skipOraCfg =[SELECT Name, ccrz__ConfigurationMeta__r.name, ccrz__TextValue__c FROM ccrz__E_Configuration__c where ccrz__ConfigurationMeta__r.name = 'Skip Oracle Transmit' limit 1];
if(skipOraCfg.size() > 0){
if(skipOraCfg[0].ccrz__TextValue__c != null)
skipOracle = Boolean.valueOf(skipOraCfg[0].ccrz__TextValue__c);
}
if(!Test.isRunningTest() && !skipOracle){
ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'ERGB2BOrderToSalesOrder: SubmitToOracle='+newSalesOrder.Id);
ICRT_TransmitOrder.singleIdToSubmitOrderToICRT(newSalesOrder.Id);
//System.debug(System.LoggingLevel.DEBUG, 'debug_ERGB2BOrderToSalesOrder: AT THE BOTTOM: RETURN FROM ICRTS SUBMISSION');
}
// 2020.10.23 added by gvansteeter
//  on creation of a sales order, if the contact on the order's originating cart is not 
//  a store member, then deactivate the user tied to the contact
//  theOrder.ccrz__OriginatedCart__c
if(!cart.ccrz__Contact__r.Store_Member__c){
try{
ID uId = ccrz.cc_CallContext.currUserId;
//ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'ERGB2BOrderToSalesOrder: uId='+uId);
CC_ERG_static_utils.deactivateUser(uId);
}catch(Exception e){

}
}	
}		
}*/