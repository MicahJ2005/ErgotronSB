public with sharing class SalesOrder_TriggerMethods {
/**
*   {Purpose}  -  Trigger Logic Class
*
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 952.223.5604                
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date    	Name             		Description
*   20180309  	Andy Boettcher DCS		Added Header
*	20180517	Andy Boettcher DCS		Commented out for future use - business not ready yet
*   =============================================================================
*/
/*
	public static void createServiceChildCase(List<Sales_Order__c> lstSO){
		Set<Id> setCaseIds = new Set<Id>();
		Set<Id> setSrvCaseIds = new Set<Id>();
		List<Case> lstCase = new List<Case>();
		List<Case> lstServiceCase = new List<Case>();
		List<Sales_Order_Line__c> lstSOL = new List<Sales_Order_Line__c>();
		List<Integration_Project__c> lstInsertInt = new List<Integration_Project__c>();
		List<Integration_Project_Service__c> lstInsertIntLines = new List<Integration_Project_Service__c>();
		String servRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service').getRecordTypeId();
		for(Sales_Order__c so: lstSO){
			if(so.Order_Type__c == 'SERVICE'){
				setCaseIds.add(so.Service_Request__c);
			}
		}
		if(setCaseIds.size()>0){
			lstCase =[SELECT Id
								,AccountId
								,Account.Name
								,Account.X3rd_Party_Service_Provider__c
								,OwnerId
								,RecordTypeId
								,CreatedDate
								,Subject
								,Description
								,ContactId
								,Type
								,Sub_Type__c
								,Origin
								,AssetId
								,ProductId
								,Case_Language__c
								,Next_day_business__c
						FROM Case 
						WHERE Id in :setCaseIds];
			for(Case c :lstCase){
				Case newCase = new Case();
				newCase = c;
				newCase.ParentId = c.Id;
				newCase.Id = null;
				newCase.RecordTypeId = servRT;
				lstServiceCase.add(newCase);
			}
			if(!lstServiceCase.isEmpty()) {
				insert lstServiceCase;
			}
			Set<Id> setCHILDCases = new Set<Id>();
			for(Case newCases : [SELECT Id
										,ContactId
										,AccountId
										,CreatedDate
										,ParentId
										,Parent.CreatedDate
										,Account.X3rd_Party_Service_Provider__c
										,Next_day_business__c
									FROM Case
									WHERE ParentId in:setCaseIds]) {

				Integration_Project__c newIP = new Integration_Project__c();
					newIP.End_User_Contact__c = newCases.ContactId;
					newIP.End_User_Customer__c = newCases.AccountId;
					newIP.Issue_Date_Time__c = newCases.Parent.CreatedDate;
					newIP.Name = 'Service Dispatch: define naming convention';
					newIP.Product_Case__c = newCases.ParentId;
					newIP.Service_Case__c = newCases.Id;
					newIP.Next_day_business__c = newCases.Next_day_business__c;
					//newIP.X3rd_Party_Service_Provider__c = newCases.Account.X3rd_Party_Service_Provider__c;  // THIS SCREWED EVERYTHING UP
				lstInsertInt.add(newIP);
				setSrvCaseIds.add(newCases.Id);
			}
			if(!lstInsertInt.isEmpty()) {
				insert lstInsertInt;
			}
			lstSOL = [SELECT Id
							,Case__c
							,Case__r.Parent.AssetId
							,Case__r.Parent.ProductId
							,Sales_Order__c
							,Sales_Order__r.Order_Type__c
							,Part_Number__c
							,Quantity__c
						FROM Sales_Order_Line__c
						WHERE Sales_Order__r.Service_Request__c in :setCaseIds
			];
			for(Integration_Project__c ip: [SELECT Id, Service_Case__c, Product_Case__c FROM Integration_Project__c WHERE Service_Case__c in :setSrvCaseIds]){			
				System.debug('ip: ' + ip);
				for(Sales_Order_Line__c sol:lstSOL){
					if(sol.Case__c == ip.Product_Case__c){
						Integration_Project_Service__c newIPS = new Integration_Project_Service__c();
							newIPS.Tech_Deployment_Record__c = ip.Id;
							newIPS.Service_Part_Number__c = sol.Part_Number__c;
							newIPS.Product__c = sol.Case__r.Parent.ProductId;
							if(sol.Sales_Order__r.Order_Type__c == 'SERVICE'){
								newIPS.Service_Request__c = ip.Service_Case__c;
								newIPS.Asset__c = sol.Case__r.Parent.AssetId;
							}
							else{
								newIPS.Scope_of_Service__c = 'Shipped Item';
								newIPS.Product_Quantity__c = sol.Quantity__c;
							}
						lstInsertIntLines.add(newIPS);	
					}
				}
			}
			if(lstInsertIntLines.size()>0){
				insert lstInsertIntLines;
			}
		}
	}
*/
}