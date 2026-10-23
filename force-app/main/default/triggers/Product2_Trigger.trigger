/*
	Trigger for Product2 object.
	+ After Insert Logic - calls method addStandardPricebookEntries on the Product2_Utility.cls to add a standard pricebook entry for each product based on the Product2.List_Price_Per_Unit__c value.
	+ Before Insert Logic - calls method setDefaultSchedules on the Product2_Utility.cls to update default quantity and revenue schedule values on each product.
	
	MOD DATE		Who						Description
	2/10/2014		Chris Noe				Initial Release
	6/30/2014		Chris Noe				Updates to remove logic for customer care USD pricelist.  Removed after update logic.
	7/15/2014		Chris Noe				Added before insert logic to call setDefaultSchedules method on the Product2_Utility.cls.
*/

trigger Product2_Trigger on Product2 (after insert, before insert) {
	
	if(trigger.isAfter && trigger.isInsert) {
		//For each new product, add a $0 Standard Price Book entry.
		Product2_Utility.addStandardPricebookEntries(trigger.new);
	}
	
	if(trigger.isBefore && trigger.isInsert){
		Product2_Utility.setDefaultSchedules(trigger.new);
	}
}