/*
	Trigger for Sales_Order__c object.
	
	+ Before Insert/Update logic - Sets the submitted flag on all Sales_Order_Line__c records associated with the Sales_Order__c record.

	+ Before Delete logic - Prevents the deletion of Sales_Order__c records that have already been submitted to Oracle.
	
	MOD DATE		Who						Description
	6/25/2015		Chris Noe				Initial Release
*/

trigger Sales_Order_Trigger on Sales_Order__c (before insert, before update, before delete, after insert) {
	//Before Insert/Update Logic
	if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
		//Call method updateSalesOrderLineSubmitted to update the submitted flag when a Sales_Order__c record is submitted.
		
		//Variables
		List<Id> listSalesOrderIds = new List<Id>();
		
		for(Sales_Order__c oSalesOrder :trigger.new){
			if(oSalesOrder.Order_Submitted__c && !trigger.oldMap.get(oSalesOrder.Id).Order_Submitted__c){
				listSalesOrderIds.add(oSalesOrder.Id);
			}
		}
		
		if(!listSalesOrderIds.isEmpty()) {
			Sales_Order_Utility.updateSalesOrderLineSubmitted(listSalesOrderIds);	
		}
	}

	//Before Delete Logic
	if(trigger.isBefore && trigger.isDelete){
		//Call method checkSubmittedOrder to prevent the deletion of sales orders that have been submitted to Oracle.
		Sales_Order_Utility.checkSubmittedOrder(trigger.old);
	}
	if(trigger.isAfter && trigger.isInsert){
		//SalesOrder_TriggerMethods.createServiceChildCase(trigger.new);
	}
}