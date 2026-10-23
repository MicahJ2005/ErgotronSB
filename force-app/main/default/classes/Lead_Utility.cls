/*
	Utility class to handle operations performed on the Lead and POS__c objects.

	MOD DATE		Who						Description
	2/28/2014		Chris Noe				Initial Release
	8/11/2014		Chris Noe				Updates to remove lead owner assignment logic. Leads are now assigned using workflow rules based on the value in the
											Lead.Lead_Assignment_Rep_Name__c which is populated by the call to the Oracle territory assignment web service.
	9/24/2014		Chris Noe 				Updated getLeadAssignmentsCallout method to evaluate the Keep_Me_As_Lead_Owner__c field.  If checked, lead asignment
											logic does not fire.
	10/31/2014 		Chris Noe 				Updated getLeadAssignmentsCallout method to exclude Leads that have a LeadSource of MailChimp.
	1/27/2015 		Chris Noe 				Added method leadConvertOpportunityPartnerContactUpdate.
	2/24/2015 		Chris Noe 				Added method updateOwnerLanguageCode to update Lead.Owner_Language_Code__c value.
	6/29/2015       Chris Noe               Updates for the new Opportunity_Partner__c object - FB-00653.
*/

public without sharing class Lead_Utility {
	public static boolean HasRun = false;
	
	@future(callout=true)
	public static void getLeadAssignments(List<Id> listLeadIds) {
		//Call method to execute callout to web service method for lead assignment.
		getLeadAssignmentsCallout(listLeadIds);
	}


/**
* @description 
* @author willh@demandchain.com | 04-14-2021 
* @param List<Lead> newLeadList 
* @param Map<ID Lead> oldLeadMap 
**/
public static void updateRegionalMapping(List<Lead> newLeadList, Map<ID, Lead> oldLeadMap) {
    //Since this is coming from a before trigger; this whole method is wrapped in a try/catch
    //	we don't want anything to prevent this lead from being imported.
    //	Required fields are handled via the UI; and we need to ensure that other integrations
    //	can still get leads put in without this method hanging them up.
    try {
        Map<String, List<Lead>> countryCodeToLeadMap = new Map<String, List<Lead>>();
        for(Lead theLead : newLeadList) {
            String oldCountryCode = '';
            
            if(oldLeadMap != null) {
                Lead oldLead = oldLeadMap.get(theLead.ID);
                if(oldLead != null) {
                    oldCountryCode = oldLead.CountryCode;
                }        
            }
            
            //if (theLead.CountryCode != null || theLead.CountryCode != oldLeadMap.get(theLead.ID).CountryCode) {
            if (theLead.CountryCode != null || theLead.CountryCode != oldCountryCode) {
                if (countryCodeToLeadMap.get(theLead.CountryCode) != null) {
                    countryCodeToLeadMap.get(theLead.CountryCode).add(theLead);
                } else {
                    List<Lead> tempLeadList = new List<Lead>();
                    tempLeadList.add(theLead);
                    countryCodeToLeadMap.put(theLead.CountryCode,tempLeadList );
                }
            } //END: if (theLead.CountryCode != null || theLead.CountryCode != oldCountryCode)
        } //END: for(Lead theLead : newLeadList)
    
        if(!countryCodeToLeadMap.values().isEmpty()){
            for(Region_Mapping__c theRegionalMapping :
                [Select
                    Id,
                    Country__c,
                    Region__c,
                    Sub_Region__c
                    From
                    Region_Mapping__c
                    Where
                    Country__c in :countryCodeToLeadMap.keySet()]){
                for(Lead theLead : countryCodeToLeadMap.get(theRegionalMapping.Country__c)){
                    theLead.Region__c = theRegionalMapping.Region__c;
                    theLead.Sub_Region__c = theRegionalMapping.Sub_Region__c;
                }
            }
        } //END:  if(!countryCodeToLeadMap.values().isEmpty())
    } catch (Exception e) {}
    
    }

	public static void getLeadAssignmentsCallout(List<Id> listLeadIds) {

		System.Debug('STARTING getPOSAssignmentsCallout');
		System.Debug(listLeadIds);

		//Method variables
		List<Lead> listLeadUpdate = new List<Lead>();
		List<Web_Service_Utility.TerritoryLookupRequest> listTerritoryLookupRequest = new List<Web_Service_Utility.TerritoryLookupRequest>();
		//List<Web_Service_Utility.TerritoryLookupResponse> listTerritoryLookupResponse = new List<Web_Service_Utility.TerritoryLookupResponse>();
		List<Web_Service_Utility.TerritoryLookupResponseV2> lstTerritoryLookupResponse = new List<Web_Service_Utility.TerritoryLookupResponseV2>();
		Set<String> setSalesrepEmail = new Set<String>();
		Map<String,Id> mapLeadTAM = new Map<String,Id>();

		if(!listLeadIds.isEmpty()){

			Map<Id, Lead> mapLeads = new Map<Id, Lead>([
				select 
					Id, 
					CountryCode, 
					PostalCode, 
					StateCode, 
					Keep_Me_As_Lead_Owner__c, 
					LeadSource, 
					Ergotron_Vertical_Market__c,
					ShippingCountry__c,
					ShippingState__c,
					ShippingPostalCode__c
				from 
					Lead 
				where 
					Id in :listLeadIds
					AND IsConverted = FALSE
			]);

			//Build list of territory lookup request items which will be used to generate the JSON request.
			for(Lead oLead : mapLeads.values()) {

				String strCountryCode = oLead.ShippingCountry__c == null ? oLead.CountryCode : oLead.ShippingCountry__c;
				if(strCountryCode != null) {
					if(strCountryCode.indexOf('-') > 0) {
						strCountryCode = strCountryCode.substringAfter('-');
					}
				}

				String strPostalCode = oLead.ShippingPostalCode__c == null ? oLead.PostalCode : oLead.ShippingPostalCode__c;

				String strStateCode = oLead.ShippingState__c == null ? oLead.StateCode : oLead.ShippingState__c;
				if(strStateCode != null) {
					if(strStateCode.indexOf('-') > 0) {
						strStateCode = strStateCode.substringAfter('-');
					}
				}

				//Verify that the user does not want to stay as the current owner and that the lead source is not MailChimp.
				if(!oLead.Keep_Me_As_Lead_Owner__c && oLead.LeadSource!='MailChimp'){
					Web_Service_Utility.TerritoryLookupRequest oTerritoryLookupRequest = new Web_Service_Utility.TerritoryLookupRequest(
							oLead.Id, 
							strCountryCode, 
							strPostalCode, 
							strStateCode,
							oLead.Ergotron_Vertical_Market__c
					);

					listTerritoryLookupRequest.add(oTerritoryLookupRequest);
				}
			}

			System.Debug(listTerritoryLookupRequest);
			
			if(!listTerritoryLookupRequest.isEmpty()) {
				//Initiate web service callout
				//listTerritoryLookupResponse = Web_Service_Utility.TerritoryLookupCallout(listTerritoryLookupRequest, 'Lead Assignments');
				lstTerritoryLookupResponse = Web_Service_Utility.TerritoryLookupCallout(listTerritoryLookupRequest, 'Lead Assignments');

				if(Test.isRunningTest()) {

					User oUser = [SELECT Id, Email FROM User WHERE Profile.Name = 'Ergotron Integration Profile' LIMIT 1];

					for(Lead oLead : mapLeads.values()) {
						Web_Service_Utility.TerritoryLookupResponseV2 clsTLR = new Web_Service_Utility.TerritoryLookupResponseV2();
						clsTLR.LeadId = oLead.Id;
						clsTLR.Name = 'Testy McTesterson';
						clsTLR.Email = oUser.Email;
						clsTLR.Phone = '555-555-5555';
						clsTLR.RoleCode = 'SALES_MANAGER';
						lstTerritoryLookupResponse.add(clsTLR);
					}
				}

				System.Debug(lstTerritoryLookupResponse);

				//for(Web_Service_Utility.TerritoryLookupResponse oTerritoryLookup :listTerritoryLookupResponse){
				for(Web_Service_Utility.TerritoryLookupResponseV2 oTerritoryLookup :lstTerritoryLookupResponse){
					if(oTerritoryLookup.Email!=NULL) {
						//Add email address returned by the web service to setSalesrepEmail
						String sEmail = oTerritoryLookup.Email;
						System.Debug('ADDING ' + sEmail + ' to the setSalesrepEmail set');
						if(sEmail.length() > 0) { setSalesrepEmail.add(sEmail.toLowerCase()); }
					}
				}

				System.Debug(setSalesrepEmail);

				if(!setSalesrepEmail.isEmpty()){
					//Get a list of users based of set of salesrep emails populated above.
					for(User oUser : [select Id, User_Key__c from User where IsActive = TRUE AND User_Key__c in :setSalesrepEmail]) {
						System.Debug('ADDING UserId ' + oUser.Id + ' (' + oUser.User_Key__c + ') to the mapLeadTAM map');
						mapLeadTAM.put(oUser.User_Key__c.toLowerCase(), oUser.Id);
					}
				}

				System.Debug('STEP 1');
				System.Debug(mapLeadTAM);

				// Put all territory results into MAP
				Map<Id, List<Web_Service_Utility.TerritoryLookupResponseV2>> mapVerticalAssignments = new Map<Id, List<Web_Service_Utility.TerritoryLookupResponseV2>>();

				// First, spin up the Map and get new lists in for all Leads
				for(Web_Service_Utility.TerritoryLookupResponseV2 oTerritoryLookup :lstTerritoryLookupResponse) {
					mapVerticalAssignments.put(oTerritoryLookup.LeadID, new List<Web_Service_Utility.TerritoryLookupResponseV2>());
				}

				// Second, spin through the Map again and populate all reps for the lead
				for(Web_Service_Utility.TerritoryLookupResponseV2 oTerritoryLookup :lstTerritoryLookupResponse) {
					mapVerticalAssignments.get(oTerritoryLookup.LeadID).add(oTerritoryLookup);
				}

				System.Debug('STEP 2');
				System.Debug(mapVerticalAssignments);

				// Lastly, loop through original Lead list and determine Verticalized territory assignment
				for(Lead soLead : mapLeads.values()) {
					Lead oLeadUpdate = new Lead(Id=soLead.Id);
					oLeadUpdate.Lead_Assignment_Multi_Rep__c = 'N';
					oLeadUpdate.Territory_Account_Manager__c = null;

					// VERTICAL SPECIFIC
					if(soLead.Ergotron_Vertical_Market__c == 'Healthcare') {
						System.Debug('CHECKING HEALTHCARE');
						for(Web_Service_Utility.TerritoryLookupResponseV2 objTerritory : mapVerticalAssignments.get(soLead.Id)) {
							if(objTerritory.RoleCode == 'HEALTHCARE_REP') {
								System.Debug('FOUND HEALTHCARE');
								oLeadUpdate.Territory_Account_Manager__c = mapLeadTAM.get(objTerritory.Email.toLowerCase());
								oLeadUpdate.Lead_Assignment_Rep_Email__c = objTerritory.Email;
								oLeadUpdate.Lead_Assignment_Rep_Name__c = objTerritory.Name;
								oLeadUpdate.Lead_Assignment_Rep_Phone__c = objTerritory.Phone;
								oLeadUpdate.Lead_Assignment_Is_Manager__c = 'N';
								//oLeadUpdate.OwnerId = mapLeadTAM.get(objTerritory.Email.toLowerCase());
							}
						}
					}

					System.Debug(oLeadUpdate.Territory_Account_Manager__c);

					// FAILOVER #1 - CHECK FOR REP
					if(oLeadUpdate.Territory_Account_Manager__c == null) {
						System.Debug('CHECKING FOR REP - NON VERTICAL');
						for(Web_Service_Utility.TerritoryLookupResponseV2 objTerritory : mapVerticalAssignments.get(soLead.Id)) {
							if(objTerritory.RoleCode == 'SALES_REP') {
								oLeadUpdate.Territory_Account_Manager__c = mapLeadTAM.get(objTerritory.Email.toLowerCase());
								oLeadUpdate.Lead_Assignment_Rep_Email__c = objTerritory.Email;
								oLeadUpdate.Lead_Assignment_Rep_Name__c = objTerritory.Name;
								oLeadUpdate.Lead_Assignment_Rep_Phone__c = objTerritory.Phone;
								oLeadUpdate.Lead_Assignment_Is_Manager__c = 'N';
							}
						}
					}

					// FAILOVER #2 - CHECK FOR MANAGER
					if(oLeadUpdate.Territory_Account_Manager__c == null) {
						System.Debug('CHECKING FOR MANAGER - NON VERTICAL');
						for(Web_Service_Utility.TerritoryLookupResponseV2 objTerritory : mapVerticalAssignments.get(soLead.Id)) {
							if(objTerritory.RoleCode == 'SALES_MANAGER') {
								oLeadUpdate.Territory_Account_Manager__c = mapLeadTAM.get(objTerritory.Email.toLowerCase());
								oLeadUpdate.Lead_Assignment_Rep_Email__c = objTerritory.Email;
								oLeadUpdate.Lead_Assignment_Rep_Name__c = objTerritory.Name;
								oLeadUpdate.Lead_Assignment_Rep_Phone__c = objTerritory.Phone;
								oLeadUpdate.Lead_Assignment_Is_Manager__c = 'Y';
							}
						}
					}

					listLeadUpdate.add(oLeadUpdate);

				}

				//for(Web_Service_Utility.TerritoryLookupResponse oTerritoryLookup :listTerritoryLookupResponse){					

				//	Lead oLeadUpdate = new Lead();
				//	oLeadUpdate.Id=oTerritoryLookup.ID;
				//	oLeadUpdate.Lead_Assignment_Is_Manager__c=oTerritoryLookup.Ismanager;
				//	oLeadUpdate.Lead_Assignment_Multi_Rep__c=oTerritoryLookup.Multirep;
				//	oLeadUpdate.Lead_Assignment_Rep_Email__c=oTerritoryLookup.Email;
				//	oLeadUpdate.Lead_Assignment_Rep_Name__c=oTerritoryLookup.Name;
				//	oLeadUpdate.Lead_Assignment_Rep_Phone__c=oTerritoryLookup.Phone;

				//	String sEmail = oTerritoryLookup.Email;
				//	//Set Territory_Account_Manager__c if email is found in map.  Check for assignment to Shep Stahel or David Milnor.  If the callout to the 
				//	//Oracle territory assignment logic returns either Milnor or Stahel, we need to assign based on the "Ergotron Vertical Market" on the Lead.  
				//	//This is required because the Texas/Oklahoma/Arkansas region is now managed by zip code/vertical as opposed to just zip code.  We have a workflow 
				//	//set up for each TAM in a vertical territory that assigns the Territory Account Manager value based on the "Ergotron Vertical Market" value on the 
				//	//Lead.  Steve Reinecke is the default rep returned from Oracle when no territory account manager is found so those are excluded as well.
				//	if(mapLeadTAM.containsKey(sEmail.toLowerCase()) && !sEmail.contains('REINECKE') && !sEmail.contains('STAHEL') && !sEmail.contains('MILNOR')){
				//		//This lead is in a traditional zip code based territory.  Assign to the sales rep returned from Oracle.
				//		oLeadUpdate.Territory_Account_Manager__c = mapLeadTAM.get(sEmail.toLowerCase());
				//	}
					
				//	listLeadUpdate.add(oLeadUpdate);
				//}
						
				//Update leads with data from web service response
				if(!listLeadUpdate.isEmpty()){
					update listLeadUpdate;
				}
			}
		}
	}

	public static void getPOSAssignmentsCallout(List<Id> listPOSIds) {

		System.Debug('STARTING getPOSAssignmentsCallout');

		//Method variables
		List<POS__c> listPOSUpdate = new List<POS__c>();
		List<Web_Service_Utility.TerritoryLookupRequest> listTerritoryLookupRequest = new List<Web_Service_Utility.TerritoryLookupRequest>();
		//List<Web_Service_Utility.TerritoryLookupResponse> listTerritoryLookupResponse = new List<Web_Service_Utility.TerritoryLookupResponse>();
		List<Web_Service_Utility.TerritoryLookupResponseV2> lstTerritoryLookupResponse = new List<Web_Service_Utility.TerritoryLookupResponseV2>();
		Set<String> setSalesrepEmail = new Set<String>();
		Map<String,Id> mapPOSOwner = new Map<String,Id>();
		Map<Id, POS__c> mapPOS = new Map<Id, POS__c>([
			select 
				Id, 
				Ship_To_Country__c, 
				Ship_To_State__c, 
				Ship_To_Postal_Code__c 
			from POS__c 
			where Id in :listPOSIds
		]);
		
		if(!listPOSIds.isEmpty()){
			//Build list of territory lookup request items which will be used to generate the JSON request.
			for(POS__c oPOS : mapPOS.values()) {
				Web_Service_Utility.TerritoryLookupRequest oTerritoryLookupRequest = new Web_Service_Utility.TerritoryLookupRequest(oPOS.Id, oPOS.Ship_To_Country__c, oPOS.Ship_To_Postal_Code__c, oPOS.Ship_To_State__c);
				listTerritoryLookupRequest.add(oTerritoryLookupRequest);
			}
			
			if(!listTerritoryLookupRequest.isEmpty()) {
				//Initiate web service callout
				//listTerritoryLookupResponse = Web_Service_Utility.TerritoryLookupCallout(listTerritoryLookupRequest, 'POS Assignments');
				lstTerritoryLookupResponse = Web_Service_Utility.TerritoryLookupCallout(listTerritoryLookupRequest, 'POS Assignments');

				if(Test.isRunningTest()) {

					User oUser = [SELECT Id, Email FROM User WHERE Profile.Name = 'Ergotron Integration Profile' LIMIT 1];

					for(POS__c oPOS : mapPOS.values()) {
						Web_Service_Utility.TerritoryLookupResponseV2 clsTLR = new Web_Service_Utility.TerritoryLookupResponseV2();
						clsTLR.LeadId = oPOS.Id;
						clsTLR.Name = 'Testy McTesterson';
						clsTLR.Email = oUser.Email;
						clsTLR.Phone = '555-555-5555';
						clsTLR.RoleCode = 'SALES_MANAGER';
						lstTerritoryLookupResponse.add(clsTLR);
					}
				}
			
				//if(!listTerritoryLookupResponse.isEmpty()) {
				if(!lstTerritoryLookupResponse.isEmpty()) {
					//for(Web_Service_Utility.TerritoryLookupResponse oTerritoryLookup :listTerritoryLookupResponse){
					for(Web_Service_Utility.TerritoryLookupResponseV2 oTerritoryLookup :lstTerritoryLookupResponse){
						if(oTerritoryLookup.Email!=NULL) {
							//Add email address returned by the web service to setSalesrepEmail
							String sEmail = oTerritoryLookup.Email;
							setSalesrepEmail.add(sEmail.toLowerCase());
						}
					}
					
					if(!setSalesrepEmail.isEmpty()){
						//Get a list of users based of set of salesrep emails populated above.
						for(User oUser : [select Id, Email from User where Email in :setSalesrepEmail]) {
							mapPOSOwner.put(oUser.Email, oUser.Id);
						}

						// Put all territory results into MAP
						Map<Id, List<Web_Service_Utility.TerritoryLookupResponseV2>> mapVerticalAssignments = new Map<Id, List<Web_Service_Utility.TerritoryLookupResponseV2>>();

						// First, spin up the Map and get new lists in for all Leads
						for(Web_Service_Utility.TerritoryLookupResponseV2 oTerritoryLookup :lstTerritoryLookupResponse) {
							mapVerticalAssignments.put(oTerritoryLookup.LeadID, new List<Web_Service_Utility.TerritoryLookupResponseV2>());
						}

						// Second, spin through the Map again and populate all reps for the lead
						for(Web_Service_Utility.TerritoryLookupResponseV2 oTerritoryLookup :lstTerritoryLookupResponse) {
							mapVerticalAssignments.get(oTerritoryLookup.LeadID).add(oTerritoryLookup);
						}

						for(POS__c objPOS : mapPOS.values()) {
							POS__c oPOSUpdate = new POS__c(Id=objPOS.Id);

							//// VERTICAL SPECIFIC
							//if(soLead.Ergotron_Vertical_Market__c == 'Healthcare') {
							//	for(Web_Service_Utility.TerritoryLookupResponseV2 objTerritory : mapVerticalAssignments.get(soLead.Id)) {
							//		if(objTerritory.RoleCode == 'HEALTHCARE_REP') {
							//			oLeadUpdate.Territory_Account_Manager__c = mapLeadTAM.get(mapLeadTAM.get(objTerritory.Email.toLowerCase()));
							//			oLeadUpdate.Lead_Assignment_Rep_Email__c = objTerritory.Email;
							//			oLeadUpdate.Lead_Assignment_Rep_Name__c = objTerritory.Name;
							//			oLeadUpdate.Lead_Assignment_Rep_Phone__c = objTerritory.Phone;
							//			oLeadUpdate.Lead_Assignment_Is_Manager__c = 'N';
							//		}
							//	}
							//}

							// FAILOVER #1 - CHECK FOR REP
							if(oPOSUpdate.Territory_Email__c == null) {
								for(Web_Service_Utility.TerritoryLookupResponseV2 objTerritory : mapVerticalAssignments.get(objPOS.Id)) {
									if(objTerritory.RoleCode == 'SALES_REP') {
										oPOSUpdate.Territory_Email__c = objTerritory.Email.toLowerCase();
										oPOSUpdate.Territory_Name__c = objTerritory.Name;
									}
								}
							}

							// FAILOVER #2 - CHECK FOR MANAGER
							if(oPOSUpdate.Territory_Email__c == null) {
								for(Web_Service_Utility.TerritoryLookupResponseV2 objTerritory : mapVerticalAssignments.get(objPOS.Id)) {
									if(objTerritory.RoleCode == 'SALES_MANAGER') {
										oPOSUpdate.Territory_Email__c = objTerritory.Email.toLowerCase();
										oPOSUpdate.Territory_Name__c = objTerritory.Name;
									}
								}
							}

							//Set owner if email is found in map of POS__c owners
							if(mapPOSOwner.containsKey(oPOSUpdate.Territory_Email__c.toLowerCase())){
								oPOSUpdate.OwnerId = mapPOSOwner.get(oPOSUpdate.Territory_Email__c.toLowerCase());
							}

							listPOSUpdate.add(oPOSUpdate);
						}
						
						//for(Web_Service_Utility.TerritoryLookupResponse oTerritoryLookup :listTerritoryLookupResponse){
						//	POS__c oPOSUpdate = new POS__c();
						//	oPOSUpdate.Id=oTerritoryLookup.ID;
						//	String sEmail = oTerritoryLookup.Email;
						//	oPOSUpdate.Territory_Email__c=sEmail.toLowerCase();
						//	oPOSUpdate.Territory_Name__c=oTerritoryLookup.Name;
							
						//	//Set owner if email is found in map of POS__c owners
						//	if(mapPOSOwner.containsKey(sEmail.toLowerCase())){
						//		oPOSUpdate.OwnerId = mapPOSOwner.get(sEmail.toLowerCase());
						//	}
							
						//	listPOSUpdate.add(oPOSUpdate);
						//}
						
						//Update POS__c with data from web service response
						if(!listPOSUpdate.isEmpty()){
							update listPOSUpdate;
						}					
					}
				}
			}
		}
	}

	public static void cleanupLeadProducts(List<Lead> listLeads) {
		//Deletes all Lead_Product__c records related to the leads passed into this method.  This is required because the Lead object cannot be
		//the master object for a custom object and therefor cascade deletes are not applied to related Lead_Product__c records.
		delete [select Id from Lead_Product__c where Lead__c in :listLeads];
	}

	public static void leadConvertOpportunityPartnerContactUpdate(List<Lead> listLeads) {
		//Check leads that are being converted to determine if the Partner_Account__c and Partner_Contact__c fields are populated and that
		//the lead has been converted to an opportunity.  Add Contact Role and Opportunity_Partner__c record to the the converted opportunity based on the
		//values in the Partner_Contact__c and Partner_Account__c fields.

		//Method Variables
		List<OpportunityContactRole> listOpptyContactRoles = new List<OpportunityContactRole>();
		List<Opportunity_Partner__c> listOpptyPartners = new List<Opportunity_Partner__c>();

		for(Lead oLead :listLeads){
			//Check to see if Partner_Contact__c is populated.
			if(oLead.Partner_Contact__c!=null){
				OpportunityContactRole oResellerContactRole = new OpportunityContactRole();
				oResellerContactRole.Role = 'Reseller Contact';
				oResellerContactRole.OpportunityId = oLead.ConvertedOpportunityId;
				oResellerContactRole.ContactId = oLead.Partner_Contact__c;
				listOpptyContactRoles.add(oResellerContactRole);
			}

			//Check to see if Partner_Account__c is populated.
			if(oLead.Partner_Account__c!=null){
				Opportunity_Partner__c oResellerPartner = new Opportunity_Partner__c();
				oResellerPartner.Opportunity__c = oLead.ConvertedOpportunityId;
				oResellerPartner.Partner_Account__c = oLead.Partner_Account__c;
				oResellerPartner.Partner_Role__c = 'Reseller';
				listOpptyPartners.add(oResellerPartner);
			}
		}

		//Insert OpportunityContactRole records
		if(!listOpptyContactRoles.isEmpty()){
			insert listOpptyContactRoles;
		}

		//Insert Opportunity_Partner__c records
		if(!listOpptyPartners.isEmpty()){
			insert listOpptyPartners;
		}
	}

	public static void updateLeadProductCurrency(List<Id> listLeads) {
		//Updates the CurrencyIsoCode on all Lead_Product__c records associated with the leads passed into this method when
		//the currency value is changed on a Lead.

		//Method variables
		List<Lead_Product__c> listLeadProductUpdate = new List<Lead_Product__c>();

		for(Lead_Product__c oLeadProduct : [select Id, CurrencyIsoCode, Lead__r.CurrencyIsoCode from Lead_Product__c where Lead__c in :listLeads]) {
			Lead_Product__c oLeadProductUpdate = new Lead_Product__c(Id=oLeadProduct.Id,CurrencyIsoCode=oLeadProduct.Lead__r.CurrencyIsoCode);
			listLeadProductUpdate.add(oLeadProductUpdate);
		}

		if(!listLeadProductUpdate.isEmpty()){
			update listLeadProductUpdate;
		}
	}

	public static void updateOwnerLanguageCode(List<Lead> listLeads) {
		//Updates the Lead.Owner_Language_Code__c field with the Owner.LanguageLocaleKey value.

		//Method Variables
		Set<Id> setOwnerIds = new Set<Id>();
		Map<Id,User> mapOwners = new Map<Id,User>();

		for(Lead oLead :listLeads){
			setOwnerIds.add(oLead.OwnerId);
		}

		if(!setOwnerIds.isEmpty()){
			for(User oUser : [select Id, LanguageLocaleKey from User where Id in :setOwnerIds]) {
				mapOwners.put(oUser.Id,oUser);
			}
		}

		for(Lead oLead :listLeads){
			if(mapOwners.containsKey(oLead.OwnerId)){
				oLead.Owner_Language_Code__c=mapOwners.get(oLead.OwnerId).LanguageLocaleKey;
			}
		}
	}
}