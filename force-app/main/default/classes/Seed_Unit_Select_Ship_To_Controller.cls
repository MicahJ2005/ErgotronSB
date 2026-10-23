/*
    Controller class for the SeedUnitSelectShipTo.page on the Seed_Unit_Order__c object.  Handles logic for selecting an existing ship to location or entering a new one.

    MOD DATE        Who                     Description
    4/23/2014       Chris Noe               Initial Release
    5/30/2014       Chris Noe               Updates to support external web service call to Oracle to retrieve ship to addresses.
    8/7/2014        Chris Noe               Updates to support default of corporate address when no ship to addresses exist for the customer.
    9/3/2014        Chris Noe               Updates related to FB-00449 to properly set the bill to account on seed unit orders for hospitals.
    10/9/2014       Chris Noe               Updates related to FB-00383 and the implementation of SmartyStreets US address valdiation.
    11/14/2014      Chris Noe               Updates related to FB-00384 bill seed orders to end user and ship to reseller customer
*/

public without sharing class Seed_Unit_Select_Ship_To_Controller {
    //Class variables
    public final Seed_Unit_Order__c oSeedUnitOrder;
    public String sSelectedLocationId {get; set;}
    public Boolean bShipToLocations {get; private set;}
    public Boolean bRenderList {get; private set;}
    public Boolean bRenderContactAddress {get; private set;}
    public String sOpptyRecordURL {get; private set;}
    public String sOrderRecordURL {get; private set;}
    public Map<String,Web_Service_Utility.ShipToSiteUseLookupResponse> mapShipToSiteUseLookupResponses {get; set;}
    public List<Web_Service_Utility.ShipToSiteUseLookupResponse> listShipToSiteUseLookupResponses {get; set;}
    public Contact soSTContact {get; private set;}
        
    //Constructor method
    public Seed_Unit_Select_Ship_To_Controller(ApexPages.StandardController stdController) {
        //Method Variables
        Account oSoldToCustomerAccount = new Account();
        Account oShipToCustomerAccount = new Account();
        String sCustomerAccountId;
        
        //Get the current Seed_Unit_Order__c record
        this.oSeedUnitOrder = (Seed_Unit_Order__c)stdController.getRecord();

        //Initialize boolean flags
        bRenderList=true;
        bShipToLocations=false;
        bRenderContactAddress=false;

        //Determine if the seed unit order has already been submitted or is in the approval process.  If so, do not render the page.
        if(oSeedUnitOrder.Seed_Unit_Order_Submitted__c || oSeedUnitOrder.Seed_Unit_Approval_Status__c=='Submitted') {
            bRenderList=false;
        }

        else {
            //If the bill to and ship to customer are the same on the seed order, query for the customer account using the ship to Salesforce Id and set both the 
            //sold to customer account and ship to customer account to the same value.
            if(oSeedUnitOrder.Sold_To_Salesforce_Id__c==oSeedUnitOrder.Ship_To_Salesforce_Id__c) {
                try{
                    oShipToCustomerAccount = [select Id, Customer_Account_Id__c from Account where Id = :oSeedUnitOrder.Ship_To_Salesforce_Id__c and Oracle_Party_Status__c='A' AND Customer_Account_Id__c != NULL ORDER BY Customer_Account_Id__c DESC limit 1];
                  
                    oSeedUnitOrder.Sold_To_Org_new__c = oShipToCustomerAccount.Id;
                    oSeedUnitOrder.Ship_To_Customer_Account_new__c = oShipToCustomerAccount.Id;
                    sCustomerAccountId = oShipToCustomerAccount.Customer_Account_Id__c;
                }
                catch(Exception oException) {
                    //No customer account found for the Ship To Account associated with this seed unit order.  Set Bill and Ship To customer to NULL.
                    oSeedUnitOrder.Sold_To_Org_new__c = NULL;
                    oSeedUnitOrder.Ship_To_Customer_Account_new__c = NULL;
                }
            }

            else {
                //Bill and ship to customer are different, query for customer account using ship to salesforce id to set ship to customer account.  Use the sold to salesforce id
                //to set the sold to customer account.
                try{
                    //Get Ship To Customer Account
                    oShipToCustomerAccount = [select Id, Customer_Account_Id__c from Account where Id = :oSeedUnitOrder.Ship_To_Salesforce_Id__c and Oracle_Party_Status__c='A' AND Customer_Account_Id__c != NULL ORDER BY Customer_Account_Id__c DESC limit 1];
                  
                    oSeedUnitOrder.Ship_To_Customer_Account_new__c = oShipToCustomerAccount.Id;
                    sCustomerAccountId = oShipToCustomerAccount.Customer_Account_Id__c;
                }
                catch(Exception oException) {
                    //No customer account found for the Ship To Account associated with this seed unit order.  Set Ship To customer to NULL.
                    oSeedUnitOrder.Ship_To_Customer_Account_new__c = NULL;
                }                
                
                try{
                    //Get Bill To Customer Account
                    oSoldToCustomerAccount = [select Id, Customer_Account_Id__c from Account where Id = :oSeedUnitOrder.Sold_To_Salesforce_Id__c and Oracle_Party_Status__c='A' limit 1];
                  
                    oSeedUnitOrder.Sold_To_Org_new__c = oSoldToCustomerAccount.Id;
                }
                catch(Exception oException) {
                    //No customer account found for the Ship To Account associated with this seed unit order.  Set Bill To customer to NULL.
                    oSeedUnitOrder.Sold_To_Org_new__c = NULL;
                } 
            }
            //Load list of ship to locations for the Ship To Customer on the seed unit order by calling Oracle web service and passing in the CustomerAccountId
            if(oSeedUnitOrder.Ship_To_Customer_Account_new__c!=NULL){
                
                //Query logic for outbound web service to retrieve ship to locations - Initiate web service callout
                listShipToSiteUseLookupResponses = Web_Service_Utility.SiteUseLookup(sCustomerAccountId, 'Seed Unit Order Select Ship To');

                if(!listShipToSiteUseLookupResponses.isEmpty()){
                    bShipToLocations=true;
                    
                    mapShipToSiteUseLookupResponses = new Map<String,Web_Service_Utility.ShipToSiteUseLookupResponse>();    
                    //Spin through the list and add each item to a map so we can reference the address fields later and write them to the fields on the order
                    for(Web_Service_Utility.ShipToSiteUseLookupResponse oResponse :listShipToSiteUseLookupResponses){
                        mapShipToSiteUseLookupResponses.put(oResponse.SiteUseId,oResponse);
                    }
                } 
                
                else {
                    //Default the shipping address to the corporate address from the Ship_To_Account__c if Address1 is NULL.
                    if(oSeedUnitOrder.Ship_To_Address1__c==NULL || oSeedUnitOrder.Ship_To_Address1__c=='') {
                        oSeedUnitOrder.Ship_To_Address1__c = oSeedUnitOrder.Ship_To_Account__r.BillingStreet;
                        oSeedUnitOrder.Ship_To_City__c = oSeedUnitOrder.Ship_To_Account__r.BillingCity;
                        if(oSeedUnitOrder.Ship_To_Account__r.BillingState!=NULL && oSeedUnitOrder.Ship_To_Account__r.BillingStateCode!=NULL) {
                            oSeedUnitOrder.Ship_To_State_Province__c = oSeedUnitOrder.Ship_To_Account__r.BillingState + '-' + oSeedUnitOrder.Ship_To_Account__r.BillingStateCode;    
                        }
                        oSeedUnitOrder.Ship_To_Postal_Code__c = oSeedUnitOrder.Ship_To_Account__r.BillingPostalCode;
                        if(oSeedUnitOrder.Ship_To_Account__r.BillingCountry!=NULL && oSeedUnitOrder.Ship_To_Account__r.BillingCountryCode!=NULL) {
                            oSeedUnitOrder.Ship_To_Country__c = oSeedUnitOrder.Ship_To_Account__r.BillingCountry + '-' + oSeedUnitOrder.Ship_To_Account__r.BillingCountryCode;    
                        }                 
                    }
                }
            }
            
            else {
                //Default the shipping address to the corporate address from the Ship_To_Account__c if Address1 is NULL.
                if(oSeedUnitOrder.Ship_To_Address1__c==NULL || oSeedUnitOrder.Ship_To_Address1__c=='') {
                    oSeedUnitOrder.Ship_To_Address1__c = oSeedUnitOrder.Ship_To_Account__r.BillingStreet;
                    oSeedUnitOrder.Ship_To_City__c = oSeedUnitOrder.Ship_To_Account__r.BillingCity;
                    if(oSeedUnitOrder.Ship_To_Account__r.BillingState!=NULL && oSeedUnitOrder.Ship_To_Account__r.BillingStateCode!=NULL) {
                        oSeedUnitOrder.Ship_To_State_Province__c = oSeedUnitOrder.Ship_To_Account__r.BillingState + '-' + oSeedUnitOrder.Ship_To_Account__r.BillingStateCode;    
                    }
                    oSeedUnitOrder.Ship_To_Postal_Code__c = oSeedUnitOrder.Ship_To_Account__r.BillingPostalCode;
                    if(oSeedUnitOrder.Ship_To_Account__r.BillingCountry!=NULL && oSeedUnitOrder.Ship_To_Account__r.BillingCountryCode!=NULL) {
                            oSeedUnitOrder.Ship_To_Country__c = oSeedUnitOrder.Ship_To_Account__r.BillingCountry + '-' + oSeedUnitOrder.Ship_To_Account__r.BillingCountryCode;    
                    }           
                }
            }

            // Pull Associated Contact's address if it exists
            if(oSeedUnitOrder.Ship_To_Contact__c != NULL) {
                soSTContact = [SELECT MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry FROM Contact WHERE Id = :oSeedUnitOrder.Ship_To_Contact__c];

                if(soSTContact.MailingStreet != NULL) {
                    bRenderContactAddress=true;
                    if(soSTContact.MailingCountry == 'United States') {
                        oSeedUnitOrder.Ship_To_Country__c = 'United States-US';
                    }
                    if(soSTContact.MailingCountry == 'Canada') {
                        oSeedUnitOrder.Ship_To_Country__c = 'Canada-CA';
                    }
                    //oSeedUnitOrder.Ship_To_State_Province__c = soSTContact.MailingState;

                }
            }
        }

        //Build URL strings
        String sUrlRewrite = System.URL.getSalesforceBaseUrl().getHost();
        String sfBaseProtocol = System.URL.getSalesforceBaseUrl().getProtocol();
    
        //remove namespace
        integer firstDotPos = sUrlRewrite.indexOf('.');
        sURlRewrite = sURlRewrite.substring(firstDotPos+1);
    
        //replace visual.force with salesforce
        sURlRewrite = sURlRewrite.replace('visual.force', 'salesforce');
        sUrlRewrite = sfBaseProtocol+'://'+sURlRewrite;
        
        sOpptyRecordURL = sUrlRewrite + '/' + oSeedUnitOrder.Opportunity__c;
        sOrderRecordURL = sUrlRewrite + '/' + oSeedUnitOrder.Id;        
    }       
    
    //Page reference to return the user to the view page for the seed unit order
    public PageReference returnToSeedOrder() {
        PageReference oPageRef = new PageReference('/' + oSeedUnitOrder.Id);
        oPageRef.setRedirect(true);
        return oPageRef;
    }
    
    //Method called when user clicks "Save" or selects an existing location on the SeedUnitOrderSelectShipTo Visualforce page
    public PageReference shipToSaveSelect() {
        //Method variables
        PageReference oPageRef;
        
        //Get selected location id from page.
        sSelectedLocationId = Apexpages.currentpage().getParameters().get('shipLocId');
        if(sSelectedLocationId!=NULL){
            //Set Ship_To_Org_Id__c field along with text address fields to the values from the selected Oracle ship to address.            
            oSeedUnitOrder.Ship_To_Org_Id__c=sSelectedLocationId;
            oSeedUnitOrder.Ship_To_Address1_Oracle__c=mapShipToSiteUseLookupResponses.get(sSelectedLocationId).Address1;
            oSeedUnitOrder.Ship_To_Address2_Oracle__c=mapShipToSiteUseLookupResponses.get(sSelectedLocationId).Address2;
            oSeedUnitOrder.Ship_To_Address3_Oracle__c=mapShipToSiteUseLookupResponses.get(sSelectedLocationId).Address3;
            oSeedUnitOrder.Ship_To_Address4_Oracle__c=mapShipToSiteUseLookupResponses.get(sSelectedLocationId).Address4;
            oSeedUnitOrder.Ship_To_Location_Name_Oracle__c=mapShipToSiteUseLookupResponses.get(sSelectedLocationId).LocationName;
            oSeedUnitOrder.Ship_To_City_State_Zip_Country_Oracle__c=mapShipToSiteUseLookupResponses.get(sSelectedLocationId).CityStateZipCountry;           
            
            //Clear the previous values in new address fields in case they were entered prior to selecting an existing address.
            oSeedUnitOrder.Ship_To_Address1__c=NULL;
            oSeedUnitOrder.Ship_To_Address2__c=NULL;
            oSeedUnitOrder.Ship_To_Address3__c=NULL;
            oSeedUnitOrder.Ship_To_Address4__c=NULL;
            oSeedUnitOrder.Ship_To_City__c=NULL;
            oSeedUnitOrder.Ship_To_State_Province__c=NULL;
            oSeedUnitOrder.Ship_To_Postal_Code__c=NULL;

            //Set SmartyStreets response field to NULL
            oSeedUnitOrder.SmartyStreets_Response__c=NULL;
            
            //Update the seed unit order and return the user to the seed unit detail page
            update oSeedUnitOrder;
            oPageRef = returnToSeedOrder();
        }

        //Existing location was not selected, check to see if required address fields have been populated for new address (applies to all countries)
        else if(oSeedUnitOrder.Ship_To_Address1__c==NULL || oSeedUnitOrder.Ship_To_City__c==NULL || oSeedUnitOrder.Ship_To_Postal_Code__c==NULL || oSeedUnitOrder.Ship_To_Country__c==NULL) {
            //Required fields for new address have not been populated, add error message to page
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a ship to location or enter a new one.'));
        }

        //For countries with states/provinces (US, CA, CN), verify that a state/province was selected
        else if((oSeedUnitOrder.Ship_To_Country__c=='United States-US' || oSeedUnitOrder.Ship_To_Country__c=='Canada-CA' || oSeedUnitOrder.Ship_To_Country__c=='China-CN') && oSeedUnitOrder.Ship_To_State_Province__c==NULL) {
            //State/Province not selected.  Add error to page
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a state/province.'));
        }
        
        else {
            //Clear any previously selected Oracle ship to location details
            oSeedUnitOrder.Ship_To_Org_Id__c=NULL;
            oSeedUnitOrder.Ship_To_Address1_Oracle__c=NULL;
            oSeedUnitOrder.Ship_To_Address2_Oracle__c=NULL;
            oSeedUnitOrder.Ship_To_Address3_Oracle__c=NULL;
            oSeedUnitOrder.Ship_To_Address4_Oracle__c=NULL;
            oSeedUnitOrder.Ship_To_Location_Name_Oracle__c=NULL;
            oSeedUnitOrder.Ship_To_City_State_Zip_Country_Oracle__c=NULL;
            
            //Update the seed unit order and return the user to the seed unit detail page
            update oSeedUnitOrder;

            //Redirect user to SeedUnitVerifyAddress.page if new address country = US
            if(oSeedUnitOrder.Ship_To_Country__c=='United States-US' && !oSeedUnitOrder.Do_Not_Validate_Address__c) {
                oPageRef = Page.SeedUnitVerifyAddress;
                oPageRef.getParameters().put('id', oSeedUnitOrder.Id);
                oPageRef.setRedirect(true);            
            }
            else {
                oPageRef = returnToSeedOrder();
            }
        }
        
        return oPageRef;
    }

    public void doNothing() { }
}