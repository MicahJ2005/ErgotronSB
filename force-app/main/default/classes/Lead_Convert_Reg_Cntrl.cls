/*
    Controller class for the LeadConvertRegistration.page on the Lead object.

    MOD DATE        Who                     Description
    12/08/2014      Chris Noe               Initial Release
    01/29/2015      Chris Noe               EMEA deal registration conversion updates
    6/29/2015       Chris Noe               Updates for the new Opportunity_Partner__c object - FB-00653.
	7/16/2018		Esau Sanchez			Setting different opportunity stage based on Geography. Support Request #00052043.
	8/05/2019		Sophia Murphy			Add set for Opportunity_Partner field
*/

public without sharing class Lead_Convert_Reg_Cntrl {
    //Class variables
    public final Lead oLead;
    public Boolean bRequiredFields {get;set;}
    public Boolean bAlreadyConverted {get;set;}
    public String sConvertType {get;set;}
    
    public String oppPartnerName { get; set; }

    public Lead_Convert_Reg_Cntrl(ApexPages.StandardController stdController) {
        //Get the current Lead record
        this.oLead = (Lead)stdController.getRecord();
        
        //We know the oppPartner Id - but that's not a very nice thing to show users
        // so look it up from the metadata and show them the name instead.
		List<Deal_Reg_Opportunity_Partner__mdt> partnerList = new List<Deal_Reg_Opportunity_Partner__mdt>([SELECT MasterLabel, Account_ID__c FROM Deal_Reg_Opportunity_Partner__mdt WHERE Account_ID__c = :oLead.Opp_Partner_ID__c LIMIT 1]);
        if(partnerList.size() == 1) {
            oppPartnerName = partnerList[0].MasterLabel;
        }
        
        //Get the conversion type from the URL - dealreg=Deal Registration, spr=Special Pricing
        sConvertType = ApexPages.currentPage().getParameters().get('type');

        bAlreadyConverted=false;
        bRequiredFields=false;

        //Determine if the deal registration lead has already been converted to an opportunity
        if(oLead.Deal_Registration_Opportunity__c!=NULL) {
            bAlreadyConverted=true;
        }

        //Verify that all fields are populated on the Lead that are required for creating a Deal Registration SPR Type Opportunity from a lead.  These fields
        //are required when the user clicks the "Convert Registration" button on the deal registration lead
        if(oLead.End_User_Account__c!=NULL && oLead.FirstName!=NULL && oLead.LastName!=NULL && oLead.Phone!=NULL && oLead.Email!=NULL 
            && oLead.Partner_Account__c!=NULL && oLead.Partner_Contact__c!=NULL && oLead.Status=='Registration Approved - Priced' 
            && oLead.Registration_Approval_Status__c=='PM Approved - Priced' && oLead.Total_Quantity__c>0 && oLead.Territory_Account_Manager__c!=NULL
            && oLead.Date_Approved__c!=NULL && oLead.Expiration_Date__c!=NULL && sConvertType=='dealreg') {
            bRequiredFields=true;
        }
        
        //Verify that all fields are populated on the Lead that are required for creating a Special Pricing SPR Type Opportunity from a lead.  These fields
        //are required when the user clicks the "Convert To Special Pricing" button on the deal registration lead
        else if(oLead.End_User_Account__c!=NULL && oLead.FirstName!=NULL && oLead.LastName!=NULL && oLead.Phone!=NULL && oLead.Email!=NULL
            && oLead.Partner_Account__c!=NULL && oLead.Partner_Contact__c!=NULL && oLead.Status=='Registration Rejected' 
            && oLead.Deal_Registration_Rejection_Reason__c=='Moved To Special Pricing' && oLead.Total_Quantity__c>0 && oLead.Territory_Account_Manager__c!=NULL
            && sConvertType=='spr') {
            bRequiredFields=true;
        }   
    }

    public PageReference convertRegistration() {
        //Converts deal registration lead to an opportunity
        //Method Variables
        String sSPRCategory = '';                                 //Category for Special Pricing
        String sRecordTypeNA = 'Ergotron Forecast Opportunity';         //Record type for North America sales profiles
        String sRecordTypeEMEA = 'Ergotron Forecast Opportunity-EMEA';  //Record type for EMEA sales profiles
        String sRecordTypeAPAC = 'Ergotron Forecast Opportunity-APAC';  //Record type for APAC sales profiles
        String sDiscountGeography = '';                                 //This field determines the discount class based on geography for calculating target end user price
        Decimal dDefaultResellerMargin = 0.0;                           //Default reseller margin % based on geography and will be retrieved from a custom setting
        Decimal dDefaultDistributionMargin = 0.0;                       //Default distribution margin % based on geography and will be retrieved from a custom setting
        Decimal dTargetDistributionPrice = 0.0;                         //Distribution target price which will be calculated based on the geography and rebate amount
        Id idOpportunityRecordType;
        Opportunity oOpportunity = new Opportunity();
        String sPricebookId = '';
        Map<Id,Lead_Product__c> mapLeadProducts = new Map<Id,Lead_Product__c>();
        Map<Id,PricebookEntry> mapPricebookEntries = new Map<Id,PricebookEntry>();
        List<OpportunityLineItem> listOpptyLineItems = new List<OpportunityLineItem>();
        List<OpportunityLineItemSchedule> listOpptyLineItemSchedules = new List<OpportunityLineItemSchedule>();
        Contact oEndUserContact = new Contact();
        Pricebook2 oPricebook = new Pricebook2();
        List<OpportunityContactRole> listOpptyContactRoles = new List<OpportunityContactRole>();

        //Retrieve profile for Territory_Account_Manager__c
        User oUserTAM = [select Id, ProfileId from User where Id = :oLead.Territory_Account_Manager__c];
        Profile oProfile = [select Id, Name from Profile where Id = :oUserTAM.ProfileId];

        //Retrieve custom settings for default reseller and distribution margin percentages
        Default_Margin_Percentage__c oDefaultMarginSettings = Default_Margin_Percentage__c.getInstance();

        //Determine opportunity record type based on the profile assigned to the Territory Account Manager as well as the region-specific values.
        if(oProfile.Name=='Ergotron EMEA Sales Profile' || oProfile.Name=='Ergotron EMEA Sales Director Profile') {
            //Get EMEA Opportunity record type
            idOpportunityRecordType=Opportunity.SObjectType.getDescribe().getRecordTypeInfosByName().get(sRecordTypeEMEA).getRecordTypeId();
            
            //Set the SPR_Category for EMEA
            if(sConvertType=='dealreg') {
                sSPRCategory = 'Deal Registration';
            }

            //Set the default reseller and distribution margin percentages using custom setting.
            if(oDefaultMarginSettings.Deal_Reg_Reseller_Margin_EMEA__c!=NULL){
                dDefaultResellerMargin=oDefaultMarginSettings.Deal_Reg_Reseller_Margin_EMEA__c/100; 
            }
            
            if(oDefaultMarginSettings.Deal_Reg_Distribution_Margin_EMEA__c!=NULL){
                dDefaultDistributionMargin=oDefaultMarginSettings.Deal_Reg_Distribution_Margin_EMEA__c/100; 
            }

            //Set the discount class geography which will be used to calulate the distribution price.
            sDiscountGeography='EMEA';
        }
        else if(oProfile.Name=='Ergotron APAC Sales Profile' || oProfile.Name=='Ergotron APAC Sales Director Profile') {
            //Get APAC Opportunity record type
            idOpportunityRecordType=Opportunity.SObjectType.getDescribe().getRecordTypeInfosByName().get(sRecordTypeAPAC).getRecordTypeId();

            //Set the SPR_Category for APAC
            if(sConvertType=='dealreg') {
                sSPRCategory = 'Deal Registration';
            }

            //Set the default reseller and distribution margin percentages using custom setting.
            if(oDefaultMarginSettings.Deal_Reg_Reseller_Margin_APAC__c!=NULL){
                dDefaultResellerMargin=oDefaultMarginSettings.Deal_Reg_Reseller_Margin_APAC__c/100; 
            }
            
            if(oDefaultMarginSettings.Deal_Reg_Distribution_Margin_APAC__c!=NULL){
                dDefaultDistributionMargin=oDefaultMarginSettings.Deal_Reg_Distribution_Margin_APAC__c/100; 
            }

            //Set the discount class geography which will be used to calulate the distribution price.
            sDiscountGeography='APAC';
        }
        else {
            //Get North America Opportunity record type
            idOpportunityRecordType=Opportunity.SObjectType.getDescribe().getRecordTypeInfosByName().get(sRecordTypeNA).getRecordTypeId();
            
            //Set the default reseller and distribution margin percentages using custom setting.
            if(oDefaultMarginSettings.Deal_Reg_Reseller_Margin_NA__c!=NULL){
                dDefaultResellerMargin=oDefaultMarginSettings.Deal_Reg_Reseller_Margin_NA__c/100;   
            }
            
            if(oDefaultMarginSettings.Deal_Reg_Distribution_Margin_NA__c!=NULL){
                dDefaultDistributionMargin=oDefaultMarginSettings.Deal_Reg_Distribution_Margin_NA__c/100;   
            }

            //Set the discount class geography which will be used to calulate the distribution price.
            sDiscountGeography='NA';
        }

        //Create new Opportunity record
        oOpportunity.RecordTypeId=idOpportunityRecordType;
        if(sConvertType=='dealreg') {
            String sOpportunityName=oLead.End_User_Account__r.Name + ' - Deal Registration ';
            oOpportunity.SPR_Category__c = sSPRCategory;
            oOpportunity.Name = sOpportunityName.left(120);         
            oOpportunity.CloseDate = oLead.Expiration_Date__c;
            oOpportunity.SPR_Type__c = 'Deal Registration';
            //oOpportunity.SPR_Number__c = oLead.Rebate__c;
            oOpportunity.SPR_Expiration_Date__c = oLead.Expiration_Date__c;
            oOpportunity.SPR_Approval_Date__c = oLead.Date_Approved__c;
        }
        else {
            String sOpportunityName=oLead.End_User_Account__r.Name + ' - Special Pricing';
            oOpportunity.Name = sOpportunityName.left(120);
            oOpportunity.CloseDate = oLead.Expected_Ship_Date__c;
            oOpportunity.SPR_Type__c = 'Special Pricing';
        }

        oOpportunity.Opp_Partner_ID__c = oLead.Opp_Partner_ID__c;
        if (oppPartnerName == 'Bluestar Inc'){oOpportunity.Canada_Price_Book_Override__c = true;}
        oOpportunity.D_H_Distributing_Oracle_Account_Id__c = oLead.D_H_Distributing_Oracle_Account_Id__c;
        oOpportunity.Ingram_Micro_Oracle_Account_Id__c = oLead.Ingram_Micro_Oracle_Account_Id__c;
        oOpportunity.TD_Synnex_Oracle_Account_Id__c = oLead.TD_Synnex_Oracle_Account_Id__c;
        oOpportunity.AccountId = oLead.End_User_Account__c;
        
        //Set stage per Geography - ES
        if(sDiscountGeography=='EMEA') {
            oOpportunity.StageName = 'Qualification';
        } else {
            oOpportunity.StageName = 'Proposal/Price Quote';
        }

        oOpportunity.OwnerId = oLead.Territory_Account_Manager__c;
        oOpportunity.Related_Deal_Registration__c = oLead.Id;
        oOpportunity.SF_Key__c = oLead.Id;
        oOpportunity.Expected_Ship_Date__c = oLead.Expected_Ship_Date__c;
        oOpportunity.CurrencyIsoCode = oLead.CurrencyIsoCode;
        oOpportunity.Description = oLead.Description;
        insert oOpportunity;

        //Update Lead with reference to deal registration opportunity
        oLead.Deal_Registration_Opportunity__c = oOpportunity.Id;
        update oLead;

        //Determine Pricebook assigned to Opportunty - this is set by default using a trigger for North America and APAC.
        //For Europe, the pricebook is set based on the opportunity currency
        oOpportunity = [select Id, CurrencyIsoCode, Pricebook2Id from Opportunity where Id = :oOpportunity.Id];
        if(oOpportunity.Pricebook2Id==NULL) {
            //Evaluate Opportunity currency
            if(oOpportunity.CurrencyIsoCode=='GBP') {
                oPricebook = [select Id from Pricebook2 where Name = 'EUROPE GBP SRP PRICE LIST'];  
            }
            else if(oOpportunity.CurrencyIsoCode=='EUR') {
                oPricebook = [select Id from Pricebook2 where Name = 'EUROPE EURO SRP PRICE LIST']; 
            }
            else {
                oPricebook = [select Id from Pricebook2 where Name = 'EMEA-APAC USD STANDARD PRICE LIST'];  
            }

            oOpportunity.Pricebook2Id = oPricebook.Id;
            sPricebookId = oPricebook.Id;
            update oOpportunity;
        }
        else {
            sPricebookId = oOpportunity.Pricebook2Id;
        }

        //Retrieve Lead Product records from the deal registration lead
        for(Lead_Product__c oLeadProduct : [select Product__c, Quantity__c, Notes__c, Rebate_Amount__c from Lead_Product__c where Lead__c = :oLead.Id]) {
            mapLeadProducts.put(oLeadProduct.Product__c,oLeadProduct);
        }

        //Retrieve Active PricebookEntry records for the products on the deal registration
        for(PricebookEntry oPricebookEntry : [select Id, Product2Id, UnitPrice, Product2.Broadline_US_Discount__c, Product2.Broadline_APAC_Discount__c, Product2.Broadline_EMEA_Discount__c
                                             from PricebookEntry where Product2Id in :mapLeadProducts.keySet() and Pricebook2Id = :sPricebookId and IsActive=true]) {
            mapPricebookEntries.put(oPricebookEntry.Product2Id, oPricebookEntry);
        }

        //Create OpportunityLineItem records
        for(Lead_Product__c oLeadProduct :mapLeadProducts.values()) {
            //Check pricebook entries map for product
            if(mapPricebookEntries.containsKey(oLeadProduct.Product__c)) {
                OpportunityLineItem oOpptyLineItem = new OpportunityLineItem();
                oOpptyLineItem.OpportunityId = oOpportunity.Id;
                oOpptyLineItem.PricebookEntryId = mapPricebookEntries.get(oLeadProduct.Product__c).Id;
                oOpptyLineItem.Quantity = oLeadProduct.Quantity__c;
                
                //Calculate target distribution price based on discount class and calculated rebate from the Lead_Product__c record
                if(sDiscountGeography=='NA') {
                    dTargetDistributionPrice = (mapPricebookEntries.get(oLeadProduct.Product__c).UnitPrice * (1-(mapPricebookEntries.get(oLeadProduct.Product__c).Product2.Broadline_US_Discount__c/100))) - oLeadProduct.Rebate_Amount__c;
                }

                else if(sDiscountGeography=='EMEA') {
                    dTargetDistributionPrice = (mapPricebookEntries.get(oLeadProduct.Product__c).UnitPrice * (1-(mapPricebookEntries.get(oLeadProduct.Product__c).Product2.Broadline_EMEA_Discount__c/100))) - oLeadProduct.Rebate_Amount__c;   
                }

                else if(sDiscountGeography=='APAC') {
                    dTargetDistributionPrice = (mapPricebookEntries.get(oLeadProduct.Product__c).UnitPrice * (1-(mapPricebookEntries.get(oLeadProduct.Product__c).Product2.Broadline_APAC_Discount__c/100))) - oLeadProduct.Rebate_Amount__c;                   
                }
                
                Decimal dTargetEndUserPrice = (dTargetDistributionPrice / (1 - dDefaultDistributionMargin)) / (1 - dDefaultResellerMargin);

                if(dTargetEndUserPrice<=mapPricebookEntries.get(oLeadProduct.Product__c).UnitPrice) {
                    oOpptyLineItem.UnitPrice = dTargetEndUserPrice;
                    oOpptyLineItem.Target_End_User_Price__c = dTargetEndUserPrice;                  
                }
                else{
                    oOpptyLineItem.UnitPrice = mapPricebookEntries.get(oLeadProduct.Product__c).UnitPrice;
                    oOpptyLineItem.Target_End_User_Price__c = mapPricebookEntries.get(oLeadProduct.Product__c).UnitPrice;
                }

                oOpptyLineItem.Estimated_Distribution_Margin__c=dDefaultDistributionMargin*100;
                oOpptyLineItem.Estimated_Reseller_Margin__c=dDefaultResellerMargin*100;
                oOpptyLineItem.Description = oLeadProduct.Notes__c;
                listOpptyLineItems.add(oOpptyLineItem);
            }
        }

        //Insert Opportunity Line Items
        if(!listOpptyLineItems.isEmpty()) {
            insert listOpptyLineItems;
        }

        //Create OpportunityLineItemSchedule quantity records based on the OpportunityLineItem records inserted above.
        //Verify that scheduling is enabled in the org
        Schema.DescribeSObjectResult oDescribe = Product2.SObjectType.getDescribe();
        if(oDescribe.fields.getMap().containsKey('CanUseQuantitySchedule')) {
            //Create OpportunityLineItemSchedule for each OpportunityLineItem
            for(OpportunityLineItem oOpptyLineItem :[select Id, Quantity, Opportunity.CloseDate from OpportunityLineItem where Id in :listOpptyLineItems]) {
                OpportunityLineItemSchedule oOpptyLineItemSchedule = new OpportunityLineItemSchedule();
                oOpptyLineItemSchedule.OpportunityLineItemId = oOpptyLineItem.Id;
                oOpptyLineItemSchedule.Quantity = oOpptyLineItem.Quantity;
                oOpptyLineItemSchedule.ScheduleDate = oOpptyLineItem.Opportunity.CloseDate;
                oOpptyLineItemSchedule.Type = 'Quantity';

                listOpptyLineItemSchedules.add(oOpptyLineItemSchedule);
            }
        }

        //Insert Opportunity Line Item Schedule records
        if(!listOpptyLineItemSchedules.isEmpty()) {
            insert listOpptyLineItemSchedules;
        }

        //Determine if Contact exists with an email address matching the deal registration lead email address
        try{
            oEndUserContact = [select Id from Contact where Email = :oLead.Email];
        }
        catch (Exception oException){
            //Contact does not exist.  Create it and associate with end user account
            oEndUserContact.OwnerId = oLead.Territory_Account_Manager__c;
            oEndUserContact.AccountId = oLead.End_User_Account__c;
            oEndUserContact.FirstName = oLead.FirstName;
            oEndUserContact.LastName = oLead.LastName;
            oEndUserContact.Phone = oLead.Phone;
            oEndUserContact.Email = oLead.Email;
            oEndUserContact.Title = oLead.Title;
            oEndUserContact.Department = oLead.Department_Division__c;
            oEndUserContact.MailingStreet = oLead.Street;
            oEndUserContact.MailingCity = oLead.City;
            oEndUserContact.MailingStateCode = oLead.StateCode;
            oEndUserContact.MailingPostalCode = oLead.PostalCode;
            oEndUserContact.MailingCountryCode = oLead.CountryCode;

            insert oEndUserContact;
        }

        //Create contact roles on opportunity for end user contact and reseller contact
        OpportunityContactRole oEndUserContactRole = new OpportunityContactRole();
        oEndUserContactRole.Role = 'End User Contact';
        oEndUserContactRole.OpportunityId = oOpportunity.Id;
        oEndUserContactRole.ContactId = oEndUserContact.Id;
        listOpptyContactRoles.add(oEndUserContactRole);

        OpportunityContactRole oResellerContactRole = new OpportunityContactRole();
        oResellerContactRole.Role = 'Reseller Contact';
        oResellerContactRole.OpportunityId = oOpportunity.Id;
        oResellerContactRole.ContactId = oLead.Partner_Contact__c;
        listOpptyContactRoles.add(oResellerContactRole);

        insert listOpptyContactRoles;

        //Create Opportunity_Partner__c record for reseller
        Opportunity_Partner__c oResellerPartner = new Opportunity_Partner__c();
        oResellerPartner.Opportunity__c = oOpportunity.Id;
        oResellerPartner.Partner_Account__c = oLead.Partner_Account__c;
        oResellerPartner.Partner_Role__c = 'Reseller';

        insert oResellerPartner;

        PageReference oPageRef = Page.LeadConvertRegistrationSummary;
        oPageRef.getParameters().put('id', oOpportunity.Id);
        oPageRef.setRedirect(true);
        return oPageRef;
    }
}