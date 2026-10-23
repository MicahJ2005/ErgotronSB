/*
	Trigger for Integration_Id__c object.
	+ After delete logic.  Check the number of records remaining on the Integration_Id__c object.  If number of remaining records is below 500, regenerate
	500 more records and insert them.  The new records will be picked up by Informatica job "PROD-Integration_Id__c to XX_SALESFORCE_SECURITY_IDS" and
	inserted into the Oracle custom table XX_SALESFORCE_SECURITY_IDS.  These security ids are used to validate transactions between Salesforce and Oracle.
	
	MOD DATE		Who						Description
	12/16/2014		Chris Noe				Initial Release
*/

trigger Integration_Id_Trigger on Integration_Id__c (after delete) {
	if(trigger.isAfter && trigger.isDelete) {
		List<Integration_Id__c> listRemainingIntegrationIds = [select Id from Integration_Id__c limit 500];

		//Check the size of the list returned above.  If less than or equal to 500, then generate 500 new security ids.
		if(listRemainingIntegrationIds.size()<500) {
			List<Integration_Id__c> listNewIntegrationIds = new List<Integration_Id__c>();
			for(Integer i=0;i<500;i++) {
				Integration_Id__c oNewIntegrationId = new Integration_Id__c(Name='SECURITY ID ' + String.valueOf(i));
				listNewIntegrationIds.add(oNewIntegrationId);
			}

			//Insert new integration ids.
			if(!listNewIntegrationIds.isEmpty()) {
				insert listNewIntegrationIds;
			}
		}
	}
}