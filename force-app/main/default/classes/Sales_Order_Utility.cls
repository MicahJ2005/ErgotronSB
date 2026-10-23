/*
	Utility class to handle operations performed on the Sales_Order__c object.

	MOD DATE		Who						Description
	6/25/2015		Chris Noe				Initial Release
*/

public with sharing class Sales_Order_Utility {
	public static void updateSalesOrderLineSubmitted(List<Id> listSalesOrderIds) {
		//This method updates the Order_Line_Submitted__c flag on all Sales_Order_Line__c records related to the Sales_Order_Line__c id values passed into the method.
		
		//Method variables
		List<Sales_Order_Line__c> listSalesOrderLines = new List<Sales_Order_Line__c>();
		
		for(Sales_Order_Line__c oOrderLine :[select Id, Order_Line_Submitted__c from Sales_Order_Line__c where Sales_Order__c in :listSalesOrderIds]) {
			Sales_Order_Line__c oOrderLineUpdate = new Sales_Order_Line__c(Id=oOrderLine.Id, Order_Line_Submitted__c=true);
			listSalesOrderLines.add(oOrderLineUpdate);
		}
		
		if(!listSalesOrderLines.isEmpty()){
			update listSalesOrderLines;
		}
	}

	public static void checkSubmittedOrder(List<Sales_Order__c> listSalesOrders){
		//This method checks to see if a Sales Order has been submitted to Oracle prior to deleting the record.  If the Order_Submitted__c value
		//is true, the Sales Order cannot be deleted.

		for(Sales_Order__c oSalesOrder :listSalesOrders) {
			if(oSalesOrder.Order_Submitted__c){
				oSalesOrder.addError('This sales order cannot be deleted because it has already been submitted to Oracle.');
			}
		}
	}
}