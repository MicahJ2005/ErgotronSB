/*
	Trigger for Order__c object.
	+ Before Insert/Update Logic - Calls Order_Utility.updateFiscalDetails method to update the Booked_Year__c, Booked_Quarter__c, and Booked_Month__c
	values for each order in the trigger.
	
	MOD DATE		Who						Description
	03/24/2015		Chris Noe				Initial Release
	04/07/2015		Chris Noe 				Added call to Order_Utility.updateShipToAccountDetails method
*/

trigger Order_Trigger on Order__c (before insert, before update) {
	
	//Before insert/update logic
	if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)) {
		//Call Order_Utility.updateFiscalDetails method to update the Booked_Year__c, Booked_Quarter__c, and Booked_Month__c values for each order in the trigger.
		Order_Utility.updateFiscalDetails(trigger.new);

		//Call Order_Utility.updateShipToAccountDetails method to update the Ship_To_Customer_Account__c and Ship_To_Party__c values
		Order_Utility.updateShipToAccountDetails(trigger.new);
	}
}