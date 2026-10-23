public class ERG_ReCreateSalesOrderController {
        // check if address is verified and update the CC order status
        @AuraEnabled
        public static String createSalesOrder(String ccOrderId){
            String isCreated = 'false';
            try{ 
                List<ccrz__E_Order__c> listOfCCOrders = [Select id, sales_order__c,sales_order__r.Oracle_Interface_Message__c,
                                                         ccrz__OriginatedCart__c,ccrz__OriginatedCart__r.isAddressVerified__c,ERG_Order_Sync_Status__c 
                                                         FROM ccrz__E_Order__c where id=: ccOrderId 
                                                         AND (sales_order__r.OracleSalesOrderRefNumber__c = null or sales_order__r.OracleSalesOrderRefNumber__c = 'NA')
                                                         LIMIT 1];
                if(!listOfCCOrders.isEmpty()){
                    ccrz__E_Order__c ccOrder =listOfCCOrders[0];
                    if(ccOrder.sales_order__r.Oracle_Interface_Message__c == NULL || (ccOrder.sales_order__r.Oracle_Interface_Message__c != NULL && !ccOrder.sales_order__r.Oracle_Interface_Message__c.containsIgnoreCase(ERG_Constants.Order_Created_Successfully))){
                       string salesOrderId= ccOrder.Sales_Order__c;
                        //update cc order
                       updateCCOrder(ccOrder);
                        
                        // delete sales order and update cc order
                        deletedFailedSalesOrder(salesOrderId, ccOrder);
                        if(!Test.isRunningTest()){
                        // re-create sales order
                        ERG_CCOrderToSalesOrder__e event = new ERG_CCOrderToSalesOrder__e();
                        event.CCOrder__c  = JSON.serialize(ccOrder);
                        Database.SaveResult result = EventBus.publish(event);  
                        }
                        isCreated = 'true';
                    }
                }
                else{
                    isCreated = 'NA';
                }
            }
            catch(Exception ex){
                isCreated = 'false';
                System.debug('Exception in createSalesOrder method');
            }
            return isCreated;
        }
        
        //delete previously failed sales order and update cc order
        private static void deletedFailedSalesOrder(string salesOrderId, ccrz__E_Order__c ccOrder){
            List<Sales_Order__c> listOfSalesOrders = [SELECT Id,Order_Submitted__c FROM Sales_Order__c WHERE Id=: salesOrderId  LIMIT 1];
            if(!listOfSalesOrders.isEmpty()){
                Sales_Order__c salesOrder = listOfSalesOrders[0];
                salesOrder.Order_Submitted__c= false;
                update salesOrder;
                
                System.debug('salesOrder='+salesOrder);
                delete salesOrder;
            }
        }
        
        private static void updateCCOrder(ccrz__e_Order__c ccOrder){
            ccOrder.Sales_Order__c = null;
            ccOrder.ERG_Order_Sync_Status__c =ERG_Constants.Ready_For_Sales_Order;
            update ccOrder; 
        }
    }