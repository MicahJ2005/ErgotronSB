/*
    Controller class for the DealRegNew.page, DealRegEdit.page, DealRegView.page.

    MOD DATE        Who                     Description
    11/11/2014      Chris Noe               Initial Release 
    08/05/2019      Sophia Murphy           Add oppPartner
    09/30/2026      Esau Sanchez            Removed calls to the Lead_Utility.getLeadAssignments method
                                            that updates the Territory_Account_Manager__c field. The webservice used to get
                                            this data is no longer available.
*/

public with sharing class Deal_Reg_Cntrl_Copy {

    @AuraEnabled(cacheable=true)
    public static Lead getLead(Id leadId){
    	System.debug('lead id '+ leadId);
        try{
            Lead oLead = 
                [Select 
                 	FirstName,
                 	LastName,
                 	Ergotron_Vertical_Market__c,
                 	Description,
                 	RFP_RFQ_Number__c,
                 	Company,
                 	Title, 
                	Email,
                 	Phone,
                 	Fax,
                 	Website,
                 	Expected_Ship_Date__c,
                 	City,
                 	PostalCode,
                 	Street,
                 	CountryCode,
                 	StateCode,
                 	Opp_Partner_ID__c,
                 	Department_Division__c,
                 	Program_Type__c,
                 	CurrencyISOCOde,
                 	Status,
                    D_H_Distributing__c,
                    Ingram_Micro__c,
                    TD_Synnex__c
                From 
                 	Lead 
                Where 
                 	Id = :leadId];
            return oLead;
        }catch(Exception e){
            return null;
        }
    }


    @AuraEnabled(cacheable=true)
    public static List<Lead_Product__c> getProducts(String searchKey) {
        return 
            [Select 
             	Id,
             	Name,
             	Product_Name__c,
             	Competitive_Make_Model__c,
             	Lead__c,
             	Notes__c,
             	Product__c,
             	Quantity__c,
             	Product__r.Name,
             	Product__r.External_URL__c
            From 
             	Lead_Product__c 
            Where 
             	Lead__c = :searchKey];
    }    

    /** Added 08/05/2019    Sophia Murphy   For the Opp Partner */
    
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getPartners() {
        Map<String,String> options = new Map<String,String>();
        User currentUser = [select countrycode from user where id = :UserInfo.getUserId()];
        for(Deal_Reg_Opportunity_Partner__mdt dropRec : [SELECT MasterLabel, Account_ID__c FROM Deal_Reg_Opportunity_Partner__mdt where country_ISO_Code__c = :currentUser.countryCode ORDER BY Sort_Order__c ]){
            options.put(dropRec.Account_Id__c, dropRec.MasterLabel);
        }
        return options;
    }

    @auraEnabled(cacheable=true)
    public static String getUserCountry() {
        return [SELECT CountryCode FROM User WHERE Id = :UserInfo.getUserId()].CountryCode;
    }

    @AuraEnabled
    public static String removeProduct(String idToRemove){
        system.debug('remove product');
        //Row index in Visualforce page is 1 based so we subtract one to get the item index for the list of products.
        if(idToRemove != null){
            Lead_Product__c oProductToRemove = [SELECT Id FROM Lead_Product__c WHERE Id = :idToRemove];
            delete oProductToRemove;

        }
        return 'Product Removed';
    }
        
    @AuraEnabled
    public static String submitDealReg(Lead oLead, List<Id> productIds) {
        //Save the deal registration (lead/lead products) and submit it for approval.
        system.debug('submit deal reg' + oLead);
        //Method variables
        system.debug('method variables');
        Approval.ProcessSubmitRequest oApprovalProcess = new Approval.ProcessSubmitRequest();
        Approval.ProcessResult oProcessResult;
        List<Lead_Product__c> listLeadProducts = [SELECT Id, Product__c, Quantity__c, Competitive_Make_Model__c, Lead__c, Notes__c FROM Lead_Product__c WHERE Id IN: productIds OR  (Lead__c != null AND Lead__c = :oLead.Id)];
        system.debug('list lead products'  + listLeadProducts);
        Boolean bHasPartNumbers = false;
        Boolean submitDeal = true;
        system.debug('begin validate fields');
        
        try {
            //Verify Part Numbers and Quantities exist for non-US/CA deal registrations
            if(oLead.CountryCode!='US' && oLead.CountryCode!='CA'){
                //Loop through each product record and verify that at least one record exists with a part number and quantity.
                for(Integer i=0;i<listLeadProducts.size();i++){
                    if(listLeadProducts[i].Product__c!=NULL && listLeadProducts[i].Quantity__c!=NULL) {
                        //Record was found with part number and quantity entered.  Set boolean flag to true and exit the loop.
                        bHasPartNumbers=true;
                        submitDeal = true;
                        break;
                    }
                }

                if(!bHasPartNumbers) {
                    //User is attempting to submit a deal registration without part numbers and quantities (non-US/CA).  Display error and return to page.
                    // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Deal_Registration_Parts_Required_Non_US_CA));
                    // return Label.Deal_Registration_Parts_Required_Non_US_CA;
                    submitDeal = false;
                    return Label.Deal_Registration_Parts_Required_Non_US_CA;
                    
                }                
            }

            //Verify Part Numbers and Quantities
            if(!listLeadProducts.isEmpty()){
                for(Integer i=0;i<listLeadProducts.size();i++){
                    if(listLeadProducts[i].Product__c!=NULL && (listLeadProducts[i].Quantity__c==NULL || listLeadProducts[i].Quantity__c==0)) {
                        //Part Number was selected but no quantity was entered.  Add error and return nulll.
                        // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Deal_Registration_Quantity_Required));
                        submitDeal = false;
                        return Label.Deal_Registration_Quantity_Required;
                    }
                }
            }
            
            //Verify that the registration contains part numbers and quantities if the current status is 'Registration Approved - Pending Pricing'
            if(oLead.Status=='Registration Approved - Pending Pricing') {
                //List is not empty.  Loop through each record and verify that at least one record exists with a part number and quantity.
                for(Integer i=0;i<listLeadProducts.size();i++){
                    if(listLeadProducts[i].Product__c!=NULL && listLeadProducts[i].Quantity__c!=NULL) {
                        //Record was found with part number and quantity entered.  Set boolean flag to true and exit the loop.
                        bHasPartNumbers=true;
                        break;
                    }
                }

                if(!bHasPartNumbers) {
                    //User is attempting to submit a deal registration that is Approved - Pending Pricing but has not selected any part numbers.  In order
                    //to submit again for approval, they must select part numbers and enter quantities prior to submitting. 
                    // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Deal_Registration_Parts_Required_For_Submit));
                    submitDeal = false;
                    return Label.Deal_Registration_Parts_Required_For_Submit;
                  
                }
            }
            
            //Insert/Update Lead   
            if(submitDeal = true){
                if(oLead.Id!=NULL) {
                    system.debug('lead id not null');
                    //Retrieve partner contact and account details.
                    User oUser = [select ContactId, AccountId from User where Id = :UserInfo.getUserId()];
                    oLead.Partner_Contact__c = oUser.ContactId;
                    oLead.Partner_Account__c = oUser.AccountId;
                    oLead.Partner_User__c = oUser.Id;
                    //  oLead.Opp_Partner_ID__c = oppPartner;

                    //Clear lead assignment field values.  This is required because the submitter may have updated the lead details which would cause
                    //a change in the assigned territory.
                    oLead.Lead_Assignment_Is_Manager__c=null;
                    oLead.Lead_Assignment_Multi_Rep__c=null;
                    oLead.Lead_Assignment_Rep_Email__c=null;
                    oLead.Lead_Assignment_Rep_Name__c=null;
                    oLead.Lead_Assignment_Rep_Phone__c=null;
                    oLead.Territory_Account_Manager__c=null;
                    
                    //Update Lead Status to "Registration Submitted"
                    system.debug('update lead status to registration submitted');
                    oLead.Status = 'Registration Submitted';
                    update oLead;
                }
                else {
                    system.debug('new lead');
                    //Retrieve record type value for "Ergotron_Deal_Registration_Lead"
                    RecordType oRT = [select Id from RecordType where SobjectType='Lead' and DeveloperName='Ergotron_Deal_Registration_Lead'];
                    system.debug(oRT);
                    //Set RecordTypeId on the Lead
                    oLead.RecordTypeId=oRT.Id;

                    //Retrieve partner contact and account details.
                    User oUser = [select ContactId, AccountId from User where Id = :UserInfo.getUserId()];
                    oLead.Partner_Contact__c = oUser.ContactId;
                    oLead.Partner_Account__c = oUser.AccountId;
                    oLead.Partner_User__c = oUser.Id;
                    // oLead.Opp_Partner_ID__c = oppPartner;

                    //Update Lead Status to "Registration Submitted"
                    oLead.Status = 'Registration Submitted';
                    system.debug('insert lead submitted');
                    insert oLead;  
                }

                //Insert associated Lead_Product__c records            
                if(!listLeadProducts.isEmpty()){
                    system.debug(listLeadProducts.size());
                    if(!listLeadProducts.isEmpty()){
                        upsert listLeadProducts;
                    }
                }

                //Submit lead to approval process.
                system.debug('submit for approval');

                oApprovalProcess.setObjectId(oLead.Id);
                oProcessResult = Approval.process(oApprovalProcess);

                return 'Submitted';
            }
            return null;
        }
        catch(Exception ex) {
            // ApexPages.addMessages(oExcection);
            return null;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Product2> getDealRegProducts(){
        return 
            [Select 
             	Id,
             	Name 
             From 
             	Product2 
             Where 
             	Item_Type__c in ('E-FG','E-SERVICE','PTO','E-KIT')
            	And Inventory_Item_Status_Code__c in ('MASTER','30-ACTIVE')
            	And Costing_Inventory__c in ('F','ANT')
            	And Not_allowed_in_SPR_or_DR__c = false
            	And (MSRP_EMEA_EUR__c > 0 Or MSRP_EMEA_GBP__c > 0 Or MSRP_EMEA_APAC_USD__c > 0 Or MSRP_US_STANDARD_USD__c > 0)
            	And IsActive = true];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Product2> getProductsById(List<Id> productIds){
        return [Select Id, Name, External_URL__c From Product2 Where Id in :productIds];
    }
    
    @AuraEnabled
    public static Id updateLead(Lead oLead, List<Lead_Product__c> products) {
        try {        
            Map<Id,Lead_Product__c> existingProductMap = new Map<Id,Lead_Product__c>();
            if(oLead.Id!=NULL) {
                
                Lead current = [Select Id,Status From Lead Where Id = :oLead.Id];
                if(current.Status == 'Registration Submitted'){
                    System.debug('JWL: registration has already been submitted.');
                	throw new AuraHandledException('This lead has already been submitted.');       
                }
                    
                //Retrieve partner contact and account details.
                User oUser = [select ContactId, AccountId from User where Id = :UserInfo.getUserId()];
                oLead.Partner_Contact__c = oUser.ContactId;
                oLead.Partner_Account__c = oUser.AccountId;
                oLead.Partner_User__c = oUser.Id;
                // oLead.Opp_Partner_ID__c = oppPartner;

                //Clear lead assignment field values.  This is required because the submitter may have updated the lead details which would cause
                //a change in the assigned territory.
                oLead.Lead_Assignment_Is_Manager__c=null;
                oLead.Lead_Assignment_Multi_Rep__c=null;
                oLead.Lead_Assignment_Rep_Email__c=null;
                oLead.Lead_Assignment_Rep_Name__c=null;
                oLead.Lead_Assignment_Rep_Phone__c=null;
                oLead.Territory_Account_Manager__c=null;
                update oLead;
                
                existingProductMap = new Map<Id,Lead_Product__c>([Select Id From Lead_Product__c Where Lead__c = :oLead.Id]);
            }
            else {
                system.debug('new lead');
                //Retrieve record type value for "Ergotron_Deal_Registration_Lead"
                RecordType oRT = [select Id from RecordType where SobjectType='Lead' and DeveloperName='Ergotron_Deal_Registration_Lead'];
                system.debug('rt ' + oRT);
                //Set RecordTypeId on the Lead
                oLead.RecordTypeId=oRT.Id;

                //Retrieve partner contact and account details.
                User oUser = [select ContactId, AccountId from User where Id = :UserInfo.getUserId()];
                oLead.Partner_Contact__c = oUser.ContactId;
                oLead.Partner_Account__c = oUser.AccountId;
                oLead.Partner_User__c = oUser.Id;
                oLead.Status = 'Registration Saved';
                // oLead.Opp_Partner_ID__c = oppPartner;

                insert oLead;  
            }
            
            if(products != null){
                Set<Id> currentProductIds = new Set<Id>();
                for(Lead_Product__c lp : products){
                    lp.Lead__c = oLead.Id;
                    if(lp.Id != null){
                        currentProductIds.add(lp.Id);
                    }
                }
                upsert products;
                
                List<Lead_Product__c> productsToRemove = new List<Lead_Product__c>();
                for(Id existingProductId : existingProductMap.keySet()){
                    if(!currentProductIds.contains(existingProductId)){
                    	productsToRemove.add(existingProductMap.get(existingProductId));    
                    }
                }
                System.debug('Deleting: ' + productsToRemove);
                delete productsToRemove;
            }
            return oLead.Id;
        }
        catch(Exception e) {
            System.debug(Logginglevel.ERROR, e.getMessage());
            System.debug(e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

	@AuraEnabled
	public static void saveAndSubmit(Lead oLead,List<Lead_Product__c> products){
        updateLead(oLead, products);
        List<Id> productIds = new List<Id>(new Map<Id,Lead_Product__c>([Select Id From Lead_Product__c Where Lead__c = :oLead.Id]).keySet());
        String result = submitDealReg(oLead, productIds);
        if(result != 'Submitted'){
            System.debug('JWL: result: ' + result);
            throw new AuraHandledException(result);
        }
	}
}