/*
    Controller class for the ServiceRequestSelectLocation.page on the Case object.  Handles logic for selecting an incident location for a service request.

    MOD DATE        Who                     Description
    07/09/2015      Chris Noe               Initial Release
*/

public with sharing class Service_Request_Select_Location_Cntrl {
	//Class variables
    public final Case oCase;
    public String sSelectedLocationId {get; set;}
    public Boolean bShipToLocations {get; private set;}
    public Map<String,Web_Service_Utility.ShipToSiteUseLookupResponse> mapShipToSiteUseLookupResponses {get; set;}
    public List<Web_Service_Utility.ShipToSiteUseLookupResponse> listShipToSiteUseLookupResponses {get; set;}

	public Service_Request_Select_Location_Cntrl(ApexPages.StandardController stdController) {
		//Method variables
		Account oShipToCustomerAccount = new Account();
        //Customer_Account__c oShipToCustomerAccount = new Customer_Account__c();
        String sCustomerAccountId;

        //Get the current Case record
        this.oCase = (Case)stdController.getRecord();

        //Initialize boolean flags
        bShipToLocations=false;

        try{
            //Get Ship To Customer Account based on the Customer_Name__c associated with the Case record
            oShipToCustomerAccount = [select Id, Customer_Account_Id__c from Account where Id = :oCase.AccountId and Oracle_Party_Status__c='A' limit 1];
            ///oShipToCustomerAccount = [select Id, Customer_Account_Id__c from Customer_Account__c where Party__c = :oCase.AccountId and Account_Status__c='A' limit 1];
          
            sCustomerAccountId = oShipToCustomerAccount.Customer_Account_Id__c;
        }
        catch(Exception oException) {
            //No customer account found for the Customer_Name__c associated with the Case
        }

        if(!String.isBlank(sCustomerAccountId)){
            //Query logic for outbound web service to retrieve ship to locations - Initiate web service callout
            listShipToSiteUseLookupResponses = Web_Service_Utility.SiteUseLookup(sCustomerAccountId, 'Select Incident Location');
            
            if(!listShipToSiteUseLookupResponses.isEmpty()){
                bShipToLocations=true;
                
                mapShipToSiteUseLookupResponses = new Map<String,Web_Service_Utility.ShipToSiteUseLookupResponse>();    
                //Spin through the list and add each item to a map so we can reference the address fields later and write them to the fields on the Case record.
                for(Web_Service_Utility.ShipToSiteUseLookupResponse oResponse :listShipToSiteUseLookupResponses){
                    mapShipToSiteUseLookupResponses.put(oResponse.SiteUseId,oResponse);
                }
            }
        }
	}

    //Page reference to return the user to the Case record
    public PageReference returnToServiceRequest() {
        PageReference oPageRef = new PageReference('/' + oCase.Id);
        oPageRef.setRedirect(true);
        return oPageRef;
    }

    //Method called when user selects a location
    public PageReference shipToSelect() {
        //Method variables
        PageReference oPageRef;
        String sEndUserLocation;
        
        //Get selected location id from page.
        sSelectedLocationId = Apexpages.currentpage().getParameters().get('shipLocId');
        
        if(!String.isBlank(sSelectedLocationId)){
            //Update Oracle incident address fields on the case 
            oCase.Incident_Address1_Oracle__c=mapShipToSiteUseLookupResponses.get(sSelectedLocationId).Address1;
            oCase.Incident_Address2_Oracle__c=mapShipToSiteUseLookupResponses.get(sSelectedLocationId).Address2;
            oCase.Incident_Address3_Oracle__c=mapShipToSiteUseLookupResponses.get(sSelectedLocationId).Address3;
            oCase.Incident_Address4_Oracle__c=mapShipToSiteUseLookupResponses.get(sSelectedLocationId).Address4;
            oCase.Incident_City_State_Zip_Country__c=mapShipToSiteUseLookupResponses.get(sSelectedLocationId).CityStateZipCountry;
            oCase.Incident_Org_Id__c=sSelectedLocationId;

            update oCase;
        }

		return returnToServiceRequest();

    }
}