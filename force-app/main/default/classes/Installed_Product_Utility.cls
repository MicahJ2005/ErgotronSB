/*
	Utility class to handle operations performed on the Installed_Product__c object.

	MOD DATE		Who						Description
	04/22/2015		Chris Noe				Initial Release
*/

public with sharing class Installed_Product_Utility {
	
	//public static void beforeDelete(List<Installed_Product__c> listInstalledProducts) {
		////Before delete logic for Installed_Product__c records.

		////Verify that the Installed_Product__c record(s) being deleted do not have an Oracle_Instance_Number__c value.  Records with this value populated originated from
		////Oracle and should not be deleted.
		//for(Installed_Product__c oInstalledProduct :listInstalledProducts){
			//if(oInstalledProduct.Oracle_Instance_Number__c!=NULL){
				//oInstalledProduct.addError('This installed product originated from Oracle and cannot be deleted.');
			//}
		//}
	//}

	//public static void beforeUpdate(map<id, Installed_Product__c> mapNewValues, map<id, Installed_Product__c> mapOldValues) {
		//map<id, integer> caseCount = new map<id, integer>();
		//Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Global Service Support').getRecordTypeId();

		//for(aggregateresult oAR: [Select Serial_Number__c, Count(id) recordCount
								//From Case
								//Where Serial_Number__c IN:mapNewValues.keySet()
								//And RecordType.Id = :caseRecordTypeId
								//Group By Serial_Number__c]) {

			//caseCount.put ((id)oAR.get('Serial_Number__c'), (integer)oAR.get('recordCount'));

		//}

		//for(Installed_Product__c oInstalledProductEdit :mapNewValues.values()) {
			//if(oInstalledProductEdit.Customer_Name__c != mapOldValues.get(oInstalledProductEdit.id).Customer_Name__c){
				
				//system.debug('caseCount: ' + caseCount + '   oInstalledProductEdit.id: ' + oInstalledProductEdit.id);
				
				//if(caseCount.containsKey(oInstalledProductEdit.id) ){
					//oInstalledProductEdit.addError(System.Label.InstalledProdUtil_Edit_Error);
				//}	
			//}
			
		//}
	//}
}