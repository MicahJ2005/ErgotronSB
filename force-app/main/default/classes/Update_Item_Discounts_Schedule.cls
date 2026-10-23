/*
	Schedule class that calls the batch class Update_Item_Discounts_Batch which updates distribution discounts for US, EMEA, and APAC based on 
	discount category codes and discount classes from Oracle.  This batch class runs nightly after Informatica jobs load Discount_Class__c records from Oracle.

	MOD DATE		Who						Description
	03/06/2015		Chris Noe				Initial Release
*/

global class Update_Item_Discounts_Schedule implements Schedulable {
	global void execute(SchedulableContext sc) {
		Update_Item_Discounts_Batch oBatch = new Update_Item_Discounts_Batch();
		Database.executeBatch(oBatch,2000);
	}
}