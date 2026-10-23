/*
	Trigger for Order__c object.
	+ Before Insert/Update Logic - Calls Order_Line_Item_Utility.updateFiscalDetails method to update the Shipped_Year__c, Shipped_Quarter__c, and Shipped_Month__c
	values for each order in the trigger.  Calls Order_Line_Item_Utility.updateExchangeRate to update the exchange rate based on the transaction date.
	
	MOD DATE		Who						Description
	03/24/2015		Chris Noe				Initial Release
	04/14/2015 		Chris Noe 				Added call to method updateExchangeRate for FB-00555
*/

trigger Order_Line_Item_Trigger on Order_Line_Item__c (before insert, before update) {
	
	//Before insert/update logic
	if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)) {
		//Call Order_Line_Item_Utility.updateFiscalDetails method to update the Shipped_Year__c, Shipped_Quarter__c, and Shipped_Month__c values for each order in the trigger.
		Order_Line_Item_Utility.updateFiscalDetails(trigger.new);

		//Order_Line_Item_Utility.updateExchangeRate method to update the Exchange_Rate__c value based on the transaction date.
		Order_Line_Item_Utility.updateExchangeRate(trigger.new);
	}
}