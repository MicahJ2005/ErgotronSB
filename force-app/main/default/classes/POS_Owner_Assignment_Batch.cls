/*
	Batch class used to assign POS record owners based on territory assignment in Oracle

	MOD DATE		Who						Description
	5/16/2014		Chris Noe				Initial Release
*/

global class POS_Owner_Assignment_Batch implements Database.Batchable<Sobject>, Database.Stateful, Database.AllowsCallouts {

	//Global variables to track, record update success and error, and the error string for the email message.
	global Integer iTotalCount = 0;
    global Integer iSuccessCount = 0;
    global Integer iErrorCount = 0;
    global String sErrorString = '';
    global String sOracleIntegrationUserId = '005G0000003r9HE';
    global String sQuery = 'select Id  from POS__c where OwnerId = :sOracleIntegrationUserId';
	
	global Database.QueryLocator start(Database.BatchableContext oBatchableContext){
        return Database.getQueryLocator(sQuery);
	}
	
	global void execute(Database.BatchableContext oBatchableContext, List<Sobject> listQueryScope){
        //Method Variables
        List<POS__c> listPOS = new List<POS__c>();
        List<Id> listPOSIds = new List<Id>();
        
		//Add each record in query scope to list of accounts to update
        for (Sobject oSobject : listQueryScope){
			iTotalCount++;
			listPOS.add((POS__c)oSobject);
        }
        
        //Add POS__c.Id values to listPOSIds for call to web service.
        for(POS__c oPOS :listPOS){
       		listPOSIds.add(oPOS.Id);
        }

		//Call Lead_Utility.getPOSAssignmentsCallout method to make assignments.
		Lead_Utility.getPOSAssignmentsCallout(listPOSIds);
	}	

	global void finish(Database.BatchableContext oBatchableContext){
		//No finish actions
	}	
}