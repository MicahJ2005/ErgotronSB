/*
Utility class to handle operations performed on the Opportunity object.

MOD DATE        Who                     Description
2/10/2014       Chris Noe               Initial Release
5/20/2014       Chris Noe               Added method populateDefaultDistributionPartners to populate default distribution partners for Ergotron Branded sales opportunities.
4/20/2015       Chris Noe               Added method checkSeedOrders to check opportunities for seed orders submitted prior to deleting.
6/29/2015       Chris Noe               Updates for the new Opportunity_Partner__c object - FB-00653.
10/05/2018		Esau					Added exception for Canadian Opportunities - Canada Standard Price Book
1/16/2019		Andy Boettcher			Adding SUO/SPR Rebate parser
6/17/2019		Esau					Adjusted setOpportunityPriceBook method to exclude opptys with EMEA accounts because they are also using the
										Sales Development record type.
08/05/2019		Sophia Murphy			Updated populateDefaultDistributionPartners method
										If a default opp partner is present on the opp, use that - don't create all the other opp partners
03/27/2023      Esau Sanchez            Update setOpportunityPriceBook method to exclude APAC and EMEA
*/

public without sharing class Opportunity_Utility {
    
    public static void setOpportunityPriceBook(List<Opportunity> listOpportunity) {
        //This method sets the Opportunity.Pricebook2Id value based on the Opportunity record type.  This method uses the custom setting Oppty_Record_Type_Pricebook__c
        //to determine which pricebook should be selected based on the opportunity record type id.
        
        //Method variables
        Map<Id,Id> mapOpptyRTPriceBook = new Map<Id,Id>();  //map to hold record type id and pricebook id mappings
        Set<Id> setPricebook = new Set<Id>();       //set to hold pricebook id values - used to validate that pricebook id is valid
        
        //Retrieve all Oppty_Record_Type_Pricebook__c records.  This custom setting stores the mapping between an opporunity record type id (Oppty_Record_Type_Pricebook__c.Name)
        //and a price book id (Oppty_Record_Type_Pricebook__c.Price_Book_Id__c)
        for(Oppty_Record_Type_Pricebook__c oOpptyRTPriceBook :Oppty_Record_Type_Pricebook__c.getAll().Values()) {
            //Try/Catch required in case custom setting contains invalid Id values for record type or price book id
            try{
                mapOpptyRTPriceBook.put(oOpptyRTPriceBook.Name,oOpptyRTPriceBook.Price_Book_Id__c);
            }
            catch(Exception oException){
                system.debug('Error adding map key value pair for opporunity record type id to pricebook id: ' + oException.getMessage());
            }
        }
        
        //Get pricebooks based on Price_Book_Id__c values stored in the map created above.  This set will be used to verify that the price book ids stored in 
        //the custom setting are valid.
        for(Pricebook2 oPB :[select Id from Pricebook2 where Id in :mapOpptyRTPriceBook.values() and IsActive=true]) {
            setPricebook.add(oPB.Id);
        }
        
        // Get Canadian Pricebook
        String canadaPBid = null;
        for(Pricebook2 objPB : [select Id from Pricebook2 where name='Canada Standard' limit 1]) {
            canadaPBid = objPB.Id;
        }
        
        //Verify that mapOpptyRTPriceBook contains mapped opportunity record types and price books and verify that setPricebook is not empty.
        if(!mapOpptyRTPriceBook.isEmpty() && !setPricebook.isEmpty() ){
            //Loop through each opportunity passed into the method and set the Pricebook2Id value based on the mapping of Opportunity record types to Pricebooks.
            for(Opportunity oOpportunity :listOpportunity){
                if(oOpportunity.acct_region__c == 'Americas'){
                    // ALL NON-CANADIAN ACCOUNTS/OPPORTUNITIES
                    if(oOpportunity.Country_Code__c != 'CA' || String.isBlank(canadaPBId)){
                        //Verify that the Opportuntiy record type has been mapped to a price book.
                        if(mapOpptyRTPriceBook.containsKey(oOpportunity.RecordTypeId)){
                            //Verify that the mapped price book id value is valid.
                            if(setPricebook.contains(mapOpptyRTPriceBook.get(oOpportunity.RecordTypeId))){
                                //Set the Pricebook2Id value based on the mapping.
                                oOpportunity.Pricebook2Id=mapOpptyRTPriceBook.get(oOpportunity.RecordTypeId);   
                            }
                        }
                    } else {
                        // ALL CANADIAN ACCOUNTS/OPPORTUNITIES
                        //Set the Pricebook to Canada Standard
                        oOpportunity.Pricebook2Id=canadaPBid;
                    }
                } 
            }
        }
    }
    
    public static void populateDefaultDistributionPartners(List<Opportunity> listOpportunity){
        //This method populates the Opportunity Partners related list with default distributors identified on the Opportunity_Distributor_Mapping__c and Opportunity_Distributor__c
        //objects for Ergotron Forecast Opportunities.  This will add the default list of distributors to each opportunity based on country.
        //Method Variables
        Set<Id> setRecordTypeIds = new Set<Id>();
        Set<String> setAccountCountries = new Set<String>();
        Map<String,Set<Id>> mapCountryDistributor = new Map<String,Set<Id>>();
        Set<Id> setDistributorAccountIds = new Set<Id>();
        String sCurrentCountry = NULL;
        List<Opportunity_Partner__c> listPartners = new List<Opportunity_Partner__c>();
        
        //Retrieve record type id for "Ergotron Forecast Opportunity", "Ergotron Forecast Opportunity-APAC", and "Ergotron Forecast Opportunity-EMEA"
        setRecordTypeIds.add(Opportunity.SObjectType.getDescribe().getRecordTypeInfosByName().get('Ergotron Forecast Opportunity').getRecordTypeId());
        setRecordTypeIds.add(Opportunity.SObjectType.getDescribe().getRecordTypeInfosByName().get('Ergotron Forecast Opportunity-APAC').getRecordTypeId());
        setRecordTypeIds.add(Opportunity.SObjectType.getDescribe().getRecordTypeInfosByName().get('Ergotron Forecast Opportunity-EMEA').getRecordTypeId());
        setRecordTypeIds.add(Opportunity.SObjectType.getDescribe().getRecordTypeInfosByName().get('Sales Development').getRecordTypeId());
        
        //Loop through each opportunity and check record type/add country to set of countries
        for(Opportunity oOpportunity :[select Id, RecordTypeId, Account.BillingCountryCode, Opp_Partner_ID__c, D_H_Distributing_Oracle_Account_Id__c, Ingram_Micro_Oracle_Account_Id__c, TD_Synnex_Oracle_Account_Id__c from Opportunity where Id in :listOpportunity and Account.BillingCountryCode!=NULL and RecordTypeId in :setRecordTypeIds]) {
            setAccountCountries.add(oOpportunity.Account.BillingCountryCode);
        }
        
        //Determine if any opportunity countries exist in set
        if(!setAccountCountries.isEmpty()){
            //Query for Opportunity_Distributor__c records
            for(Opportunity_Distributor__c oOppDistributor :[select Distributor__c, Opportunity_Distributor_Mapping__r.Country_Unique__c from Opportunity_Distributor__c 
                                                             where Opportunity_Distributor_Mapping__r.Country_Unique__c in :setAccountCountries order by Opportunity_Distributor_Mapping__r.Country_Unique__c]) {
                                                                 if(oOppDistributor.Opportunity_Distributor_Mapping__r.Country_Unique__c!=sCurrentCountry && sCurrentCountry!=NULL){
                                                                     Set<Id> setDistributorAccountIdsToAdd = new Set<Id>();
                                                                     setDistributorAccountIdsToAdd=setDistributorAccountIds.clone();
                                                                     
                                                                     mapCountryDistributor.put(sCurrentCountry,setDistributorAccountIdsToAdd);
                                                                     setDistributorAccountIds.clear();
                                                                     setDistributorAccountIds.add(oOppDistributor.Distributor__c);
                                                                 }   
                                                                 else {
                                                                     setDistributorAccountIds.add(oOppDistributor.Distributor__c);
                                                                 }       
                                                                 
                                                                 sCurrentCountry=oOppDistributor.Opportunity_Distributor_Mapping__r.Country_Unique__c;
                                                             }
            
            if(sCurrentCountry!=NULL && !setDistributorAccountIds.isEmpty()) {
                mapCountryDistributor.put(sCurrentCountry,setDistributorAccountIds);
            }
            
            if(!mapCountryDistributor.isEmpty()){
                //Loop through each opportunity and add default distributors
                for(Opportunity oOpportunity :[select Id, AccountId, RecordTypeId, Account.BillingCountryCode, Opp_Partner_ID__c, D_H_Distributing_Oracle_Account_Id__c, Ingram_Micro_Oracle_Account_Id__c, TD_Synnex_Oracle_Account_Id__c from Opportunity where Id in :listOpportunity and Account.BillingCountryCode!=NULL and RecordTypeId in :setRecordTypeIds]) {
                    //If this opp has the default opp partner picked - we'll just set that - otherwise;
                    // move forward with the other logic
                    if(oOpportunity.Opp_Partner_ID__c != null) {
                        Opportunity_Partner__c oOp1 = new Opportunity_Partner__c(Opportunity__c=oOpportunity.Id, Partner_Account__c=oOpportunity.Opp_Partner_ID__c, Partner_Role__c='Distributor');
                        listPartners.add(oOp1);
                    } else {
                        //US reseller disti partner selection
                        if(String.IsNotBlank(oOpportunity.D_H_Distributing_Oracle_Account_Id__c) || String.IsNotBlank(oOpportunity.Ingram_Micro_Oracle_Account_Id__c) || String.IsNotBlank(oOpportunity.TD_Synnex_Oracle_Account_Id__c)){

                            //create opportunity parterners for disti partners selected by reseller
                            if (String.IsNotBlank(oOpportunity.D_H_Distributing_Oracle_Account_Id__c)) {
                                String dhDistributingId = [select Account_ID__c from Deal_Reg_Opportunity_Partner__mdt where Country_ISO_Code__c = 'US' and Oracle_Account_Id__c = :oOpportunity.D_H_Distributing_Oracle_Account_Id__c].Account_ID__c;
                                Opportunity_Partner__c usOPDH = new Opportunity_Partner__c(Opportunity__c = oOpportunity.Id, Partner_Role__c = 'Distributor', Partner_Account__c = dhDistributingId);
                                listPartners.add(usOPDH);
                            }
                            if (String.IsNotBlank(oOpportunity.Ingram_Micro_Oracle_Account_Id__c)) {
                                String ingramMicroId = [select Account_ID__c from Deal_Reg_Opportunity_Partner__mdt where Country_ISO_Code__c = 'US' and Oracle_Account_Id__c = :oOpportunity.Ingram_Micro_Oracle_Account_Id__c].Account_ID__c;
                                Opportunity_Partner__c usOPIM = new Opportunity_Partner__c(Opportunity__c = oOpportunity.Id, Partner_Role__c = 'Distributor', Partner_Account__c = ingramMicroId);
                                listPartners.add(usOPIM);
                            }
                            if (String.IsNotBlank(oOpportunity.TD_Synnex_Oracle_Account_Id__c)) {
                                String tDSynnexId = [select Account_ID__c from Deal_Reg_Opportunity_Partner__mdt where Country_ISO_Code__c = 'US' and Oracle_Account_Id__c = :oOpportunity.TD_Synnex_Oracle_Account_Id__c].Account_ID__c;
                                Opportunity_Partner__c usOPTDS = new Opportunity_Partner__c(Opportunity__c = oOpportunity.Id, Partner_Role__c = 'Distributor', Partner_Account__c = tDSynnexId);
                                listPartners.add(usOPTDS);
                            }
                        } else {
                        if(mapCountryDistributor.containsKey(oOpportunity.Account.BillingCountryCode)){
                                for(Id idDistributorAccountId :mapCountryDistributor.get(oOpportunity.Account.BillingCountryCode)){
                                    //Create new Opportunity_Partner__c record and add it to the list
                                    Opportunity_Partner__c oOP = new Opportunity_Partner__c(Opportunity__c=oOpportunity.Id,     Partner_Account__c=idDistributorAccountId, Partner_Role__c='Distributor');
                                    listPartners.add(oOp);
                                }
                            }
                        }
                    }
                }               
                
                if(!listPartners.isEmpty()){
                    insert listPartners;
                }
            }
        }
    }

/* The checkSeedOrders method is not needed. The Seed_Unit_Order__c object is not used anymore. */    
/* 
    public static void checkSeedOrders(List<Opportunity> listOpportunity){
        //This method checks to see if an Opportunity that is being deleted has submitted seed unit orders associated with it.  If it does, an error is added and the 
        //Opportunity is not deleted.
        
        for(Opportunity oOppty :listOpportunity) {
            if(oOppty.Total_Seed_Units__c>0){
                oOppty.addError('This opportunity cannot be deleted because it contains seed unit orders that have been submitted to Oracle.');
            }
        }
    }
 */    
    public static void recalculateLineDiscounts(List<Opportunity> listNewOpps, Map<Id,Opportunity> mapOldOpps) {
        //If changes to Gov_Ed_Checkbox__c, Partner_Loyalty__c, or Opportunity_Discount__c where made, trigger an update to all line items associated with that opportunity.
        List<Id> listOpptyIds = new List<Id>();
        
        for(Opportunity oOppty :listNewOpps){
            if(oOppty.Gov_Ed_Checkbox__c!=mapOldOpps.get(oOppty.Id).Gov_Ed_Checkbox__c || 
               oOppty.Partner_Loyalty__c!=mapOldOpps.get(oOppty.Id).Partner_Loyalty__c || 
               oOppty.Opportunity_Discount__c!=mapOldOpps.get(oOppty.Id).Opportunity_Discount__c){
                   listOpptyIds.add(oOppty.Id);
               }
        }
        
        if(!listOpptyIds.isEmpty()){
            //Set global variable to prevent OpportunityLineItem after update trigggers from executing. The recalculation of discounts
            //which fires before update/insert on the OpportunityLineItem object does not require an update of related Product_Schedule__c records.
            GlobalVariables.bFireOpptyLineAfterTrigger = false;
            
            update [select Id from OpportunityLineItem where OpportunityId in :listOpptyIds limit 10000];
        }
    }
    
    //@future
    public static void pullBigDealReportingFields(Set<Id> setOpportunityIds) {
        
        Map<Id, String> mapProducts = new Map<Id, String>();
        Map<Id, String> mapResellers = new Map<Id, String>();
        List<Opportunity> lstOppUpdate = new List<Opportunity>();
        
        // Populate Maps
        for(Id objId : setOpportunityIds) {
            mapProducts.put(objId, '');
            mapResellers.put(objId, '');
        }
        
        // Process OLIs
        for(OpportunityLineItem objOLI : [SELECT OpportunityId, Product_Code__c FROM OpportunityLineItem WHERE OpportunityId IN :setOpportunityIds]) {
            mapProducts.put(objOLI.OpportunityId, mapProducts.get(objOLI.OpportunityId) + objOLI.Product_Code__c + ';');
        }
        
        for(Opportunity_Partner__c objOPPYeahYouKnowMe : [SELECT Opportunity__c, Partner_Account__r.Name FROM Opportunity_Partner__c WHERE Opportunity__c IN :setOpportunityIds AND Partner_Role__c = 'Reseller']) {
            mapResellers.put(objOPPYeahYouKnowMe.Opportunity__c, mapResellers.get(objOPPYeahYouKnowMe.Opportunity__c) + objOPPYeahYouKnowMe.Partner_Account__r.Name + ';');
        }
        
        for(Id objId : setOpportunityIds) {
            Opportunity objOpp = new Opportunity(
                Id=objId,
                Big_Deal_Products__c = mapProducts.get(objId),
                Big_Deal_Resellers__c = mapResellers.get(objId)
            );
            lstOppUpdate.add(objOpp);
        }
        
        if(lstOppUpdate.size() > 0) { update lstOppUpdate; }
        
    }
    
    public static void pullConvertedLeadProduct(List<Lead> lstConvertedLeads) {
        
        // Take list of converted leads and push bare-bones SUO with Product through
        Map<Id, Lead> mapOppConvertedLeads = new Map<Id, Lead>();
        Set<Id> setProducts = new Set<Id>();
        
        Map<ID,Schema.RecordTypeInfo> mapRT = Lead.sObjectType.getDescribe().getRecordTypeInfosById();
        
        for(Lead objLead : lstConvertedLeads) {
            if(objLead.ConvertedOpportunityId != null && objLead.WebSeedProductRequested__c != null && mapRT.get(objLead.RecordTypeId).getName().containsIgnoreCase('Seed Unit Order Submission')) {
                // Verify that Reseller Account and Contact are selected!
                if(!Test.isRunningTest() && (objLead.Partner_Account__c == null || objLead.Partner_Contact__c == null)) {
                    objLead.addError('😕 oops! The partner account and partner contact are missing. Click "Cancel" to return to the Lead screen.');
                }
                
                mapOppConvertedLeads.put(objLead.ConvertedOpportunityId, objLead);
                setProducts.add(objLead.WebSeedProductRequested__c);
            }
        }
        
        if(!mapOppConvertedLeads.isEmpty()) {
            
            Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>([SELECT Id, AccountId, Account.Ergotron_Vertical_Market__c, OwnerId FROM Opportunity WHERE Id IN :mapOppConvertedLeads.keyset()]);
            
            for(Id objId : mapOppConvertedLeads.keyset()) {
                String strState = ''; String strCountry = '';
                Id idOpportunity = mapOppConvertedLeads.get(objId).ConvertedOpportunityId;
                Id idContact = mapOppConvertedLeads.get(objId).ConvertedContactId;
                Id idProduct = mapOppConvertedLeads.get(objId).WebSeedProductRequested__c;
                Id idAccount = mapOpportunities.get(objId).AccountId;
                Id idSalesRep = mapOpportunities.get(objId).OwnerId;
                //String strVM = mapOpportunities.get(objId).Account.Ergotron_Vertical_Market__c;
                Boolean bolLiftGateRequired = mapOppConvertedLeads.get(objId).IsLiftGateRequired__c;
                
                // Update Opportunity with Lead.Description (Business Justification)
                Opportunity objOpp = new Opportunity(Id=idOpportunity);
                objOpp.Description = mapOppConvertedLeads.get(objId).Description;
                objOpp.StageName = 'Seeding';
                update objOpp;
                
                // Update Contact Shipping Address
                Contact objCon = new Contact(Id=idContact);
                
                strState = mapOppConvertedLeads.get(objId).ShippingState__c;
                strCountry = mapOppConvertedLeads.get(objId).ShippingCountry__c;
                if(!Test.isRunningTest() && strState != null) { strState = strState.split('-')[0]; objCon.MailingState = strState; }
                if(!Test.isRunningTest() && strCountry != null) { strCountry = strCountry.split('-')[0]; objCon.MailingCountry = strCountry; }                
                
                objCon.MailingStreet = mapOppConvertedLeads.get(objId).ShippingStreet__c;
                objCon.MailingCity = mapOppConvertedLeads.get(objId).ShippingCity__c;
                objCon.MailingPostalCode = mapOppConvertedLeads.get(objId).ShippingPostalCode__c;
                update objCon;
                
/*      24-OCT-2019 Cancelling auto creation of sales order. Now using "Quick Seed Request" button.
          
                // Create SUO STUB - on Sales Order Object
                Sales_Order__c objSUO = new Sales_Order__c(Opportunity__c=idOpportunity);
                objSUO.Bill_To_Customer__c = idAccount;
                objSUO.Ship_To_Customer__c = idAccount;
                objSUO.Sales_Rep__c = idSalesRep;
                objSUO.IsPartialCreated__c = true;
                objSUO.Order_Type__c = 'SEED UNIT ORDER';
                
                insert objSUO;
                
                List<Sales_Order_Line__c> lstLines = new List<Sales_Order_Line__c>();
                
                Sales_Order_Line__c objSUOP = new Sales_Order_Line__c(Sales_Order__c = objSUO.Id);
                objSUOP.Part_Number__c = idProduct;
                objSUOP.Quantity__c = 1;
                objSUOP.Warehouse__c = 'US1';
                lstLines.add(objSUOP);
                
                SUOLiftGateProducts__c objLG = SUOLiftGateProducts__c.getInstance(idProduct);
                if(bolLiftGateRequired && objLG != null) {                  
                    lstLines.add(new Sales_Order_Line__c(Sales_Order__c=objSUO.Id, Part_Number__c=objLG.LiftGatePartNumber__c, Quantity__c=1, Warehouse__c = 'US1'));
                }
                
                insert lstLines;
*/                
              
                /*
// Create Seed Unit Order
Seed_Unit_Order__c objSUO = new Seed_Unit_Order__c(Opportunity__c=idOpportunity);
objSUO.Ship_To_Account__c = idAccount;
objSUO.Ship_To_Contact__c = idContact;
objSUO.Salesrep__c = idSalesRep;
objSUO.IsForceCreateRecord__c = true;
//objSUO.Seed_Unit_Location_Type__c = strVM; // Commented out until Esau talks to the business about aligning VMs between marketing and product

if(bolLiftGateRequired) {
objSUO.Internal_Notes_To_Customer_Care__c = 'Lift Gate Required';
}

insert objSUO;

List<Seed_Unit_Product__c> lstProducts = new List<Seed_Unit_Product__c>();

Seed_Unit_Product__c objSUOP = new Seed_Unit_Product__c(Seed_Unit_Order__c = objSUO.Id);
objSUOP.Product__c = idProduct;
objSUOP.Quantity__c = 1;
lstProducts.add(objSUOP);

SUOLiftGateProducts__c objLG = SUOLiftGateProducts__c.getInstance(idProduct);
if(bolLiftGateRequired && objLG != null) {                  
lstProducts.add(new Seed_Unit_Product__c(Seed_Unit_Order__c=objSUO.Id, Product__c=objLG.LiftGatePartNumber__c,SeedUnitProductForce__c = true, Quantity__c=1));
}

insert lstProducts;

*/
            }
            
        }
        
    }

	@Future
    public static void populateSPRRebatesOnSDOs(String jsonSourceOpps) {

		if(UtilityMethods.G_bolStopSPRRecursion) { return; }

        //return;
		UtilityMethods.G_bolStopSPRRecursion = true;
		List<Opportunity> lstSourceOpps = (List<Opportunity>)JSON.deserialize(jsonSourceOpps, List<Opportunity>.class);

		// Get Linked SPRs for all Opportunities in Scope
		Map<Id, Id> mapOppSPRs = new Map<Id, Id>();
		for(Opportunity objOpp : lstSourceOpps) {
			if(String.isNotBlank(objOpp.Related_SPR_parent__c)) {
				mapOppSPRs.put(objOpp.Id, objOpp.Related_SPR_parent__c);
			}
		}

		System.debug(mapOppSPRs);

		if(mapOppSPRs.isEmpty()) {
			return;
		}

        // Get Approved SPR pricing for all linked Related SPRs
        Map<Id, Map<Id, Double>> mapRebateAmounts = new Map<Id, Map<Id, Double>>();
		for(Id idOpp : mapOppSPRs.values()) {
			mapRebateAmounts.put(idOpp, new Map<Id, Double>());
		}

        for(Approved_Special_Pricing__c objSPR : [SELECT Id, Opportunity__c, Item_Description__c, Rebate_Amount__c FROM Approved_Special_Pricing__c WHERE Opportunity__c IN :mapOppSPRs.values() AND Opportunity__r.SPR_Expiration_Date__c >= TODAY]) {
            Map<Id, Double> mapTemp = mapRebateAmounts.get(objSPR.Opportunity__c);
            mapTemp.put(objSPR.Item_Description__c, objSPR.Rebate_Amount__c);
            mapRebateAmounts.put(objSPR.Opportunity__c, mapTemp);
        }

		System.debug(mapRebateAmounts);

		if(mapRebateAmounts.isEmpty()) {
			return;
		}

		// Get all OLIs for opps in scope to apply rebate amount to
        List<OpportunityLineItem> lstOLI = [SELECT Id, OpportunityId, Product_Id__c, Rebate_Amount__c FROM OpportunityLineItem WHERE OpportunityId IN :mapOppSPRs.keyset()];

        for(OpportunityLineItem objOLI : lstOLI) {

			System.debug('Working on OLI ' + objOLI.Id + ' - ProductId = ' + objOLI.Product_Id__c + ' (' + objOLI.Rebate_Amount__c + ')');

            Map<Id, Double> mapRebate = mapRebateAmounts.get(mapOppSPRs.get(objOLI.OpportunityId));

            if(mapRebate.containsKey(objOLI.Product_Id__c)) {
				System.debug('Applying rebate amount of ' + mapRebate.get(objOLI.Product_Id__c));
                objOLI.Rebate_Amount__c = mapRebate.get(objOLI.Product_Id__c);
            }
        }

        if(!lstOLI.isEmpty()) {
            update lstOLI;
        }

    }

}