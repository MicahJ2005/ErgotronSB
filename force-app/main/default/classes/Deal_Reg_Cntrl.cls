/*
    Controller class for the DealRegNew.page, DealRegEdit.page, DealRegView.page.

    MOD DATE        Who                     Description
    11/11/2014      Chris Noe               Initial Release 
    08/05/2019      Sophia Murphy           Add oppPartner
    09/30/2026      Esau Sanchez            Removed calls to the Lead_Utility.getLeadAssignments method
                                            that updates the Territory_Account_Manager__c field. The webservice used to get
                                            this data is no longer available.
*/

public with sharing class Deal_Reg_Cntrl {
    //Class variables
    public final Lead oLead;
    public List<Lead_Product__c> listLeadProducts {get; set;}
    public Boolean bShowDelete {get; set;}
    public String sSelectedProduct {get; set;}
    public String sCurrency{get;set;}
    
    //Used to help instantiate a counter for the Visualforce table rows
    public final Integer ZERO {get; private set;}

    public Deal_Reg_Cntrl(ApexPages.StandardController stdController) {
        //Instatiate row counter for the list of deal registration products
        this.ZERO = 0;

        //Get the current Lead record
        oLead = (Lead)stdController.getRecord();        

        listLeadProducts = new List<Lead_Product__c>();

        //Get the list of deal registration products if Lead Id is populated
        if(oLead.Id!=NULL){
            listLeadProducts = [select Id, Name, Competitive_Make_Model__c, Lead__c, Notes__c, Product__c, Quantity__c, Product__r.Name
                                         from Lead_Product__c where Lead__c = :oLead.Id];
        
            if(listLeadProducts.isEmpty()) {
                addNewProduct();
            }
            
            if(oLead.Opp_Partner_ID__c != null) {
                this.oppPartner = oLead.Opp_Partner_ID__c;
            }
        }

        else {
            //Get current users details and set Lead.Country to User.Country
            User oUser = [select Id, CountryCode from User where Id = :UserInfo.getUserId()];
            oLead.CountryCode = oUser.CountryCode;
            addNewProduct();
        }
        
        bShowDelete=false;
        bShowDelete = bShowDelete || listLeadProducts.size()>1;

        //Get currency for logged in user
        sCurrency = UserInfo.getDefaultCurrency();
    }      

    /** Added 08/05/2019    Sophia Murphy   For the Opp Partner */
        String oppPartner;
        public String getOppPartner() {
            return oppPartner;
        }
    
        public void setOppPartner(String s) {
            this.oppPartner = s;
        }

        public List<SelectOption> getOppPartners() {
            List<SelectOption> options = new List<SelectOption>();
                options.add(new SelectOption('',System.Label.None));
            //08.25.2020 - Esau Sanchez - added user country code filter
            User currentUser = [select countrycode from user where id = :UserInfo.getUserId()];
            //08.20.2019 - Sophia Murphy (Demand Chain) - added sort order
            for(Deal_Reg_Opportunity_Partner__mdt dropRec : [SELECT MasterLabel, Account_ID__c FROM Deal_Reg_Opportunity_Partner__mdt where country_ISO_Code__c = :currentUser.countryCode ORDER BY Sort_Order__c, MasterLabel ]) {
                options.add(new SelectOption(dropRec.Account_ID__c, dropRec.MasterLabel));
            }
            return options;
        }
    /** END Addition: 08/05/2019 */

    public void addNewProduct(){
        Lead_Product__c oNewProduct = new Lead_Product__c();
        
        try{
            listLeadProducts.add(oNewProduct);
        }
        catch(Exception oExcection) {
            ApexPages.addMessages(oExcection);
        }

        bShowDelete=false;
        bShowDelete = bShowDelete || listLeadProducts.size()>1;
    }   

    public void removeProduct(){

        //Row index in Visualforce page is 1 based so we subtract one to get the item index for the list of products.
        Integer rowIndex = Integer.valueOf(sSelectedProduct) - 1;

        if(rowIndex >= 0){
            Lead_Product__c oProductToRemove = listLeadProducts.get(rowIndex);
            listLeadProducts.remove(rowIndex);
            if(oProductToRemove.Id != null){
                delete oProductToRemove;
            }
        }

        bShowDelete=false;
        bShowDelete = bShowDelete || listLeadProducts.size()>1;
    }

    public PageReference cancelReturn() {
      PageReference oPageRef = new PageReference('/home/home.jsp');
      return oPageRef;
    }

    public pageReference saveForLater() {
        //Method variables
        List<Lead_Product__c> listNewLeadProducts = new List<Lead_Product__c>();

        //Save deal registration but do not submit for approval.
        try {
            
            if(oLead.Id!=NULL) {
                //Retrieve partner contact and account details.
                User oUser = [select ContactId, AccountId from User where Id = :UserInfo.getUserId()];
                oLead.Partner_Contact__c = oUser.ContactId;
                oLead.Partner_Account__c = oUser.AccountId;
                oLead.Partner_User__c = oUser.Id;
                oLead.Opp_Partner_ID__c = oppPartner;

                //Clear lead assignment field values.  This is required because the submitter may have updated the lead details which would cause
                //a change in the assigned territory.
                oLead.Lead_Assignment_Is_Manager__c=null;
                oLead.Lead_Assignment_Multi_Rep__c=null;
                oLead.Lead_Assignment_Rep_Email__c=null;
                oLead.Lead_Assignment_Rep_Name__c=null;
                oLead.Lead_Assignment_Rep_Phone__c=null;
                oLead.Territory_Account_Manager__c=null;
                
                update oLead;
            }
            else {
                //Retrieve record type value for "Ergotron_Deal_Registration_Lead"
                RecordType oRT = [select Id from RecordType where SobjectType='Lead' and DeveloperName='Ergotron_Deal_Registration_Lead'];
                //Set RecordTypeId on the Lead
                oLead.RecordTypeId=oRT.Id;

                //Retrieve partner contact and account details.
                User oUser = [select ContactId, AccountId from User where Id = :UserInfo.getUserId()];
                oLead.Partner_Contact__c = oUser.ContactId;
                oLead.Partner_Account__c = oUser.AccountId;
                oLead.Partner_User__c = oUser.Id;
                oLead.Opp_Partner_ID__c = oppPartner;

                insert oLead;  
            }
            
            if(!listLeadProducts.isEmpty()){
                for(Integer i=0;i<listLeadProducts.size();i++){
                    if(listLeadProducts[i].Product__c!=NULL) {
                        listLeadProducts[i].Lead__c = oLead.Id;
                        listNewLeadProducts.add(listLeadProducts[i]);
                    }
                }

                if(!listNewLeadProducts.isEmpty()){
                    upsert listNewLeadProducts;
                }
            }
            
            PageReference oPageRef = Page.DealRegSaveConfirm;
            oPageRef.setRedirect(true);
            return oPageRef;
        }

        catch(Exception oExcection) {
            ApexPages.addMessages(oExcection);
            return null;
        }
    }

    public pageReference submitDealReg() {
        //Save the deal registration (lead/lead products) and submit it for approval.

        //Method variables
        Approval.ProcessSubmitRequest oApprovalProcess = new Approval.ProcessSubmitRequest();
        Approval.ProcessResult oProcessResult;
        List<Lead_Product__c> listNewLeadProducts = new List<Lead_Product__c>();
        Boolean bHasPartNumbers = false;

        //BEGIN: Validate required fields
        if(oLead.FirstName==NULL) {
            oLead.FirstName.addError(Label.Is_Required);
            return null;
        }

        if(oLead.Street==NULL) {
            oLead.Street.addError(Label.Is_Required);
            return null;
        }

        if(oLead.City==NULL) {
            oLead.City.addError(Label.Is_Required);
            return null;
        }

        if(oLead.Email==NULL) {
            oLead.Email.addError(Label.Is_Required);
            return null;
        }

        if((oLead.CountryCode=='US' || oLead.CountryCode=='CA' || oLead.CountryCode=='AU') && oLead.StateCode==NULL) {
            oLead.State.addError(Label.Is_Required);
            return null;
        }

        if(oLead.Phone==NULL) {
            oLead.Phone.addError(Label.Is_Required);
            return null;
        }

        if(oLead.PostalCode==NULL) {
            oLead.PostalCode.addError(Label.Is_Required);
            return null;
        }

        if(oLead.CountryCode==NULL) {
            oLead.Country.addError(Label.Is_Required);
            return null;
        }

        if(oLead.Ergotron_Vertical_Market__c==NULL) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.End_User_Vertical_Market + ' ' + Label.Is_Required));
            return null;
        }

        if(oLead.Expected_Ship_Date__c==NULL) {
            oLead.Expected_Ship_Date__c.addError(Label.Is_Required);
            return null;
        }
        
        if((oLead.CountryCode=='US' || oLead.CountryCode=='CA') && (oppPartner == NULL || oppPartner == '')) {
            //oLead.Opp_Partner_ID__c.addError(Label.Is_Required);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Distribution_Partner_Required));
            return null;
        }

        if(oLead.Description.length()==0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Deal_Registration_Comments_Required));
            return null;
        }
        
        //END: Validate required fields

        try {
            //Verify Part Numbers and Quantities exist for non-US/CA deal registrations
            if(oLead.CountryCode!='US' && oLead.CountryCode!='CA'){
                //Loop through each product record and verify that at least one record exists with a part number and quantity.
                for(Integer i=0;i<listLeadProducts.size();i++){
                    if(listLeadProducts[i].Product__c!=NULL && listLeadProducts[i].Quantity__c!=NULL) {
                        //Record was found with part number and quantity entered.  Set boolean flag to true and exit the loop.
                        bHasPartNumbers=true;
                        break;
                    }
                }

                if(!bHasPartNumbers) {
                    //User is attempting to submit a deal registration without part numbers and quantities (non-US/CA).  Display error and return to page.
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Deal_Registration_Parts_Required_Non_US_CA));
                    return null;
                }                
            }

            //Verify Part Numbers and Quantities
            if(!listLeadProducts.isEmpty()){
                for(Integer i=0;i<listLeadProducts.size();i++){
                    if(listLeadProducts[i].Product__c!=NULL && (listLeadProducts[i].Quantity__c==NULL || listLeadProducts[i].Quantity__c==0)) {
                        //Part Number was selected but no quantity was entered.  Add error and return nulll.
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Deal_Registration_Quantity_Required));
                        return null;
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
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Deal_Registration_Parts_Required_For_Submit));
                    return null;
                }
            }
            
            //Insert/Update Lead    
            if(oLead.Id!=NULL) {
                //Retrieve partner contact and account details.
                User oUser = [select ContactId, AccountId from User where Id = :UserInfo.getUserId()];
                oLead.Partner_Contact__c = oUser.ContactId;
                oLead.Partner_Account__c = oUser.AccountId;
                oLead.Partner_User__c = oUser.Id;
                oLead.Opp_Partner_ID__c = oppPartner;

                //Clear lead assignment field values.  This is required because the submitter may have updated the lead details which would cause
                //a change in the assigned territory.
                oLead.Lead_Assignment_Is_Manager__c=null;
                oLead.Lead_Assignment_Multi_Rep__c=null;
                oLead.Lead_Assignment_Rep_Email__c=null;
                oLead.Lead_Assignment_Rep_Name__c=null;
                oLead.Lead_Assignment_Rep_Phone__c=null;
                oLead.Territory_Account_Manager__c=null;
                
                //Update Lead Status to "Registration Submitted"
                oLead.Status = 'Registration Submitted';
                update oLead;

            }
            else {
                //Retrieve record type value for "Ergotron_Deal_Registration_Lead"
                RecordType oRT = [select Id from RecordType where SobjectType='Lead' and DeveloperName='Ergotron_Deal_Registration_Lead'];
                //Set RecordTypeId on the Lead
                oLead.RecordTypeId=oRT.Id;

                //Retrieve partner contact and account details.
                User oUser = [select ContactId, AccountId from User where Id = :UserInfo.getUserId()];
                oLead.Partner_Contact__c = oUser.ContactId;
                oLead.Partner_Account__c = oUser.AccountId;
                oLead.Partner_User__c = oUser.Id;
                oLead.Opp_Partner_ID__c = oppPartner;

                //Update Lead Status to "Registration Submitted"
                oLead.Status = 'Registration Submitted';
                insert oLead;  
            }

            //Insert associated Lead_Product__c records            
            if(!listLeadProducts.isEmpty()){
                for(Integer i=0;i<listLeadProducts.size();i++){
                    if(listLeadProducts[i].Product__c!=NULL) {
                        listLeadProducts[i].Lead__c = oLead.Id;
                        listNewLeadProducts.add(listLeadProducts[i]);
                    }
                }

                if(!listNewLeadProducts.isEmpty()){
                    upsert listNewLeadProducts;
                }
            }

            //Submit lead to approval process.
            oApprovalProcess.setObjectId(oLead.Id);
            oProcessResult = Approval.process(oApprovalProcess);

            PageReference oPageRef = Page.DealRegNewConfirm;
            oPageRef.setRedirect(true);
            return oPageRef;
        }

        catch(Exception oExcection) {
            ApexPages.addMessages(oExcection);
            return null;
        }
    }
}