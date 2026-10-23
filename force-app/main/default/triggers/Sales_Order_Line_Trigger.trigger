/*
	Trigger for Sales_Order_Line__c object.

	+ Before Delete logic - Prevents the deletion of Sales_Order_Line__c records that have already been submitted to Oracle.
	
	MOD DATE		Who						Description
	07/07/2015		Chris Noe				Initial Release
*/

trigger Sales_Order_Line_Trigger on Sales_Order_Line__c (after insert, before delete) {

	////Before Delete Logic
	//if(trigger.isBefore && trigger.isDelete){
		////Call method checkSubmittedOrder to prevent the deletion of sales order lines that have been submitted to Oracle.
		//Sales_Order_Line_Utility.checkSubmittedOrderLine(trigger.old);
	//}

}