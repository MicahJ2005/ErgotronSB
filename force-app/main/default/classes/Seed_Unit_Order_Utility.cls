/*
	Utility class to handle operations performed on the Seed_Unit_Order__c object.

	MOD DATE		Who						Description
	4/21/2014		Chris Noe				Initial Release
	6/24/2014		Chris Noe				Updated with new method updateSeedUnitOrderApprover which sets the Approver__c field on each Seed_Unit_Order__c record based on Salesrep__c.Manager
	4/21/2015 		Chris Noe 				Added method checkSubmittedOrder which verifies that the seed unit order has not been submitted to Oracle prior to deletion.
	7/31/2017		Esau Sanchez			Commented lines 148 to 157, and 162. Condition to pull parent account if location type is Clinic or Hospital 
*/

public with sharing class Seed_Unit_Order_Utility {
	
	public static void updateSeedUnitProductsSubmitted(List<Id> listSeedUnitOrderIds) {
		//This method updates the Seed_Unit_Order_Submitted__c flag on all Seed_Unit_Product__c records related to the Seed_Unit_Order__c id values passed into the method.
		
		//Method variables
		List<Seed_Unit_Product__c> listSeedUnitProducts = new List<Seed_Unit_Product__c>();
		
		for(Seed_Unit_Product__c oSeedUnitProduct :[select Id, Seed_Unit_Order_Submitted__c from Seed_Unit_Product__c where Seed_Unit_Order__c in :listSeedUnitOrderIds]) {
			Seed_Unit_Product__c oSeedUnitProductUpdate = new Seed_Unit_Product__c(Id=oSeedUnitProduct.Id, Seed_Unit_Order_Submitted__c=true);
			listSeedUnitProducts.add(oSeedUnitProductUpdate);
		}
		
		if(!listSeedUnitProducts.isEmpty()){
			update listSeedUnitProducts;
		}
	}
	
	public static void updateSeedUnitOrderApprover(List<Seed_Unit_Order__c> listSeedUnitOrders) {
		//This method sets the Approver__c value on a Seed_Unit_Order__c record based on the Manager value assigned to the Salesrep__c user lookup.
		
		//Method variables
		Set<Id> setSalesrepIds = new Set<Id>();
		Map<Id,Id> mapManagerIds = new Map<Id,Id>();
		
		//Loop through each seed unit order passed into this method and retrieve the Salesrep user id value
		for(Seed_Unit_Order__c oSeedUnitOrder :listSeedUnitOrders){
			setSalesrepIds.add(oSeedUnitOrder.Salesrep__c);
		}
		
		//Retrieve the manager for each Salesrep retrieved above
		for(User oUser :[select Id, ManagerId from User where Id in :setSalesrepIds]){
			mapManagerIds.put(oUser.Id, oUser.ManagerId);
		}
		
		//Loop through each seed unit order and set the Approver field using the values in mapManagerIds
		for(Seed_Unit_Order__c oSeedUnitOrder :listSeedUnitOrders){
			//Verify that the map contains the key for the current salesrep__c value
			if(mapManagerIds.containsKey(oSeedUnitOrder.Salesrep__c)){
				oSeedUnitOrder.Approver__c=mapManagerIds.get(oSeedUnitOrder.Salesrep__c);
			}
		}
	}

	public static void updateTopLevelParentValues(List<Seed_Unit_Order__c> listSeedUnitOrders) {
		//This method populates the Ship_To_Account_Top_Level_Id__c and Ship_To_Contact_Account_Top_Level_Id__c values based on the selected Ship_To_Contact__c and 
		//Ship_To_Account__c values on the seed unit order.

		//Method variables
		Set<Id> setShipToContactIds = new Set<Id>();
		Set<Id> setShipToAccountIds = new Set<Id>();
		Map<Id,String> mapShipToContactTopLevelAccountIds = new Map<Id,String>();
		Map<Id,String> mapShipToAccountopLevelAccountIds = new Map<Id,String>();

		//Loop through each seed unit order passed into this method and retrieve the Ship_To_Contact__c and Ship_To_Account__c ids 
		for(Seed_Unit_Order__c oSeedUnitOrder :listSeedUnitOrders){
			if(oSeedUnitOrder.Ship_To_Contact__c!=NULL) {
				setShipToContactIds.add(oSeedUnitOrder.Ship_To_Contact__c);
			}
			if(oSeedUnitOrder.Ship_To_Account__c!=NULL) {
				setShipToAccountIds.add(oSeedUnitOrder.Ship_To_Account__c);
			}
		}

		//Retrieve Ship To Contact top level account ids
		if(!setShipToContactIds.isEmpty()) {
			for(Contact oContact :[select Id, Top_Level_Account_Parent_Id__c from Contact where Id in :setShipToContactIds]) {
				mapShipToContactTopLevelAccountIds.put(oContact.Id, oContact.Top_Level_Account_Parent_Id__c);
			}
		}

		//Retrieve Ship To Account top level account ids
		if(!setShipToAccountIds.isEmpty()) {
			for(Account oAccount:[select Id, Top_Level_Account_Id__c from Account where Id in :setShipToAccountIds]) {
				mapShipToAccountopLevelAccountIds.put(oAccount.Id, oAccount.Top_Level_Account_Id__c);
			}
		}

		//Loop through each seed unit order and set the top level parent id values
		for(Seed_Unit_Order__c oSeedUnitOrder :listSeedUnitOrders){
			//Set contact top level account id
			if(!mapShipToContactTopLevelAccountIds.isEmpty()) {
				if(mapShipToContactTopLevelAccountIds.containsKey(oSeedUnitOrder.Ship_To_Contact__c)) {
					oSeedUnitOrder.Ship_To_Contact_Account_Top_Level_Id__c=mapShipToContactTopLevelAccountIds.get(oSeedUnitOrder.Ship_To_Contact__c);
				}
			}

			//Set account top level id
			if(!mapShipToAccountopLevelAccountIds.isEmpty()) {
				if(mapShipToAccountopLevelAccountIds.containsKey(oSeedUnitOrder.Ship_To_Account__c)) {
					oSeedUnitOrder.Ship_To_Account_Top_Level_Id__c=mapShipToAccountopLevelAccountIds.get(oSeedUnitOrder.Ship_To_Account__c);
				}
			}
		}			
	}

	public static void updateShipToAccountDetails(List<Seed_Unit_Order__c> listSeedUnitOrders) {
		//This method populates the Ship_To_Salesforce_Id__c, Ship_To_Party_Id__c, Ship_To_Party_Name__c, and Ship_To_Party_Number__c values on the 
		//seed unit order.  This logic is performed via Apex due to the object reference limitation for formula fields imposed by Salesforce (15).

		//Method variables
		Set<Id> setShipToAccountIds = new Set<Id>();
		Set<Id> setSoldToOpportunityIds = new Set<Id>();
		Map<Id,Account> mapShipToAccounts = new Map<Id,Account>();
		Map<Id,Opportunity> mapSoldToOpportunities = new Map<Id,Opportunity>();

		//Loop through each seed unit order passed into this method and retrieve the Ship_To_Account__c and Opportunity__c ids 
		for(Seed_Unit_Order__c oSeedUnitOrder :listSeedUnitOrders){
			if(oSeedUnitOrder.Ship_To_Account__c!=NULL) {
				setShipToAccountIds.add(oSeedUnitOrder.Ship_To_Account__c);
			}
			if(oSeedUnitOrder.Opportunity__c!=NULL) {
				setSoldToOpportunityIds.add(oSeedUnitOrder.Opportunity__c);
			}
		}

		//Retrieve Ship_To_Account__c account details
		if(!setShipToAccountIds.isEmpty()) {
			for(Account oAccount :[select Id, Name, Oracle_Party_Id__c, Oracle_Party_Number__c from Account where Id in :setShipToAccountIds]) {
				mapShipToAccounts.put(oAccount.Id, oAccount);
			}
		}

		//Retrieve Opportunity account and top level account details
		if(!setSoldToOpportunityIds.isEmpty()) {
			for(Opportunity oOpportunity:[select Id, Account.Id, Account.Name, Account.Oracle_Party_Id__c, Account.Oracle_Party_Number__c, 
										Account.Top_Level_Account_Id__c, Account.Top_Level_Account_Name__c, Account.Top_Level_Oracle_Party_Id__c, Account.Top_Level_Oracle_Party_Number__c
										from Opportunity where Id in :setSoldToOpportunityIds]) {
				mapSoldToOpportunities.put(oOpportunity.Id, oOpportunity);
			}
		}

		//Loop through each seed unit order passed to the method and determine the Account to pull ship to details from.
		for(Seed_Unit_Order__c oSeedUnitOrder :listSeedUnitOrders) {
			//If the Ship_To_Account__c matches the Opportunity__r.Account and the seed location type is Clinic or Hospital, set the ship to account details to the top level parent values.
			if(oSeedUnitOrder.Ship_To_Account__c==mapSoldToOpportunities.get(oSeedUnitOrder.Opportunity__c).Account.Id) {
				
/*				if(oSeedUnitOrder.Seed_Unit_Location_Type__c=='Clinic' || oSeedUnitOrder.Seed_Unit_Location_Type__c=='Hospital') {
					//Bill and Ship to customer is the top level parent when shipping to hospital or clinic
					oSeedUnitOrder.Ship_To_Salesforce_Id__c=String.valueof(mapSoldToOpportunities.get(oSeedUnitOrder.Opportunity__c).Account.Top_Level_Account_Id__c).left(15);
					oSeedUnitOrder.Ship_To_Party_Id__c=mapSoldToOpportunities.get(oSeedUnitOrder.Opportunity__c).Account.Top_Level_Oracle_Party_Id__c;
					oSeedUnitOrder.Ship_To_Party_Name__c=mapSoldToOpportunities.get(oSeedUnitOrder.Opportunity__c).Account.Top_Level_Account_Name__c;
					oSeedUnitOrder.Ship_To_Party_Number__c=mapSoldToOpportunities.get(oSeedUnitOrder.Opportunity__c).Account.Top_Level_Oracle_Party_Number__c;
				}

				else {
*/
					oSeedUnitOrder.Ship_To_Salesforce_Id__c=String.valueof(mapSoldToOpportunities.get(oSeedUnitOrder.Opportunity__c).Account.Id).left(15);
					oSeedUnitOrder.Ship_To_Party_Id__c=mapSoldToOpportunities.get(oSeedUnitOrder.Opportunity__c).Account.Oracle_Party_Id__c;
					oSeedUnitOrder.Ship_To_Party_Name__c=mapSoldToOpportunities.get(oSeedUnitOrder.Opportunity__c).Account.Name;
					oSeedUnitOrder.Ship_To_Party_Number__c=mapSoldToOpportunities.get(oSeedUnitOrder.Opportunity__c).Account.Oracle_Party_Number__c;		
//				}
			}

			//Ship_To_Account__c is different than the opportunity account id.  Set the ship to account details based on the Ship_To_Account__c
			else {
				oSeedUnitOrder.Ship_To_Salesforce_Id__c=String.valueof(mapShipToAccounts.get(oSeedUnitOrder.Ship_To_Account__c).Id).left(15);
				oSeedUnitOrder.Ship_To_Party_Id__c=mapShipToAccounts.get(oSeedUnitOrder.Ship_To_Account__c).Oracle_Party_Id__c;
				oSeedUnitOrder.Ship_To_Party_Name__c=mapShipToAccounts.get(oSeedUnitOrder.Ship_To_Account__c).Name;
				oSeedUnitOrder.Ship_To_Party_Number__c=mapShipToAccounts.get(oSeedUnitOrder.Ship_To_Account__c).Oracle_Party_Number__c;	
			}
		}
	}

	public static void clearShipToDetails(List<Seed_Unit_Order__c> listSeedUnitOrdersNew, Map<Id,Seed_Unit_Order__c> mapSeedUnitOrdersOld) {
		//Updates ship to address details to NULL when the Ship_To_Account__c changes on a seed unit order.
		for(Seed_Unit_Order__c oSeedUnitOrder :listSeedUnitOrdersNew) {
			if(oSeedUnitOrder.Ship_To_Account__c!=mapSeedUnitOrdersOld.get(oSeedUnitOrder.Id).Ship_To_Account__c && mapSeedUnitOrdersOld.get(oSeedUnitOrder.Id).Ship_To_Account__c!=NULL) {
				//Ship to account has changed, clear any previously entered or selected ship to address information
				oSeedUnitOrder.Ship_To_Address1__c=NULL;
				oSeedUnitOrder.Ship_To_Address2__c=NULL;
				oSeedUnitOrder.Ship_To_Address3__c=NULL;
				oSeedUnitOrder.Ship_To_Address4__c=NULL;
				oSeedUnitOrder.Ship_To_Address1_Oracle__c=NULL;
				oSeedUnitOrder.Ship_To_Address2_Oracle__c=NULL;
				oSeedUnitOrder.Ship_To_Address3_Oracle__c=NULL;
				oSeedUnitOrder.Ship_To_Address4_Oracle__c=NULL;
				oSeedUnitOrder.Ship_To_City__c=NULL;
				oSeedUnitOrder.Ship_To_City_State_Zip_Country_Oracle__c=NULL;
				oSeedUnitOrder.Ship_To_Location_Name_Oracle__c=NULL;
				oSeedUnitOrder.Ship_To_Org_Id__c=NULL;
				oSeedUnitOrder.Ship_To_County__c=NULL;
				oSeedUnitOrder.Ship_To_Postal_Code__c=NULL;
				oSeedUnitOrder.Ship_To_State_Province__c=NULL;
				oSeedUnitOrder.Ship_To_Customer_Account_new__c=NULL;
			}
		}
	}

	public static void checkSubmittedOrder(List<Seed_Unit_Order__c> listSeedUnitOrders){
		//This method checks to see if a Seed Unit Order has been submitted to Oracle prior to deleting the record.  If the Seed_Unit_Order_Submitted__c value
		//is true, the Seed Unit Order cannot be deleted.

		for(Seed_Unit_Order__c oSeedUnit :listSeedUnitOrders) {
			if(oSeedUnit.Seed_Unit_Order_Submitted__c){
				oSeedUnit.addError('This seed unit order cannot be deleted because it has already been submitted to Oracle.');
			}
		}
	}	
}