/*
	Schedule class that calls the batch class POS_Owner_Assignment_Batch which updates POS__c record owners based on territory assignment logic in Oracle.
	This batch class runs nightly after Informatica jobs load POS__c records from Oracle during the 12:00 AM task flow run.

	MOD DATE		Who						Description
	03/06/2015		Chris Noe				Initial Release
*/

global class POS_Owner_Assignment_Schedule implements Schedulable {
	global void execute(SchedulableContext sc) {
		POS_Owner_Assignment_Batch oPOSAssignmentBatch = new POS_Owner_Assignment_Batch();
		Database.executeBatch(oPOSAssignmentBatch,10);
	}
}