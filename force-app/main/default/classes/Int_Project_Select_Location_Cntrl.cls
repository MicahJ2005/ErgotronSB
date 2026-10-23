/*
    Controller class for the IntProjectSelectLocation.page on the Integration_Project__c object.  Handles logic for selecting an existing ship to location for an integration project.

    MOD DATE        Who                     Description
    07/20/2015      Chris Noe               Initial Release
*/

public with sharing class Int_Project_Select_Location_Cntrl {
	//Class variables
    public final Integration_Project__c oIntProject;
    public String sSelectedLocationId {get; set;}
    public Boolean bShipToLocations {get; private set;}
    public Map<String,Web_Service_Utility.ShipToSiteUseLookupResponse> mapShipToSiteUseLookupResponses {get; set;}
    public List<Web_Service_Utility.ShipToSiteUseLookupResponse> listShipToSiteUseLookupResponses {get; set;}

	public Int_Project_Select_Location_Cntrl(ApexPages.StandardController stdController) {
		//Method variables
		Account oShipToCustomerAccount = new Account();
        String sCustomerAccountId;

        //Get the current Integration_Project__c record
        this.oIntProject = (Integration_Project__c)stdController.getRecord();

        //Initialize boolean flags
        bShipToLocations=false;

        try{
            //Get Ship To Customer Account based on the Customer_Name__c associated with the Integration_Project__c record
            oShipToCustomerAccount = [select Id, Customer_Account_Id__c from Account where Id = :oIntProject.End_User_Customer__c and Oracle_Party_Status__c='A' limit 1];
          
            sCustomerAccountId = oShipToCustomerAccount.Customer_Account_Id__c;
        }
        catch(Exception oException) {
            //No Customer_Account__c record found for the End_User_Customer__c associated with the Integration_Project__c
        }

        if(!String.isBlank(sCustomerAccountId)){
            //Query logic for outbound web service to retrieve ship to locations - Initiate web service callout
            listShipToSiteUseLookupResponses = Web_Service_Utility.SiteUseLookup(sCustomerAccountId, 'Select Integration Project Location');
            
            if(!listShipToSiteUseLookupResponses.isEmpty()){
                bShipToLocations=true;
                
                mapShipToSiteUseLookupResponses = new Map<String,Web_Service_Utility.ShipToSiteUseLookupResponse>();    
                //Spin through the list and add each item to a map so we can reference the address fields later and write them to the fields on the Integration_Project__c record.
                for(Web_Service_Utility.ShipToSiteUseLookupResponse oResponse :listShipToSiteUseLookupResponses){
                    mapShipToSiteUseLookupResponses.put(oResponse.SiteUseId,oResponse);
                }
            }
        }
	}

    //Page reference to return the user to the Integration_Project__c record
    public PageReference returnToIntProject() {
        PageReference oPageRef = new PageReference('/' + oIntProject.Id);
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
            //Update Oracle Ship To Address Fields on the Integration_Project__c record
            oIntProject.Project_Address1_Oracle__c=mapShipToSiteUseLookupResponses.get(sSelectedLocationId).Address1;
            oIntProject.Project_Address2_Oracle__c=mapShipToSiteUseLookupResponses.get(sSelectedLocationId).Address2;
            oIntProject.Project_Address3_Oracle__c=mapShipToSiteUseLookupResponses.get(sSelectedLocationId).Address3;
            oIntProject.Project_Address4_Oracle__c=mapShipToSiteUseLookupResponses.get(sSelectedLocationId).Address4;
            oIntProject.Project_City_State_Zip_Country__c=mapShipToSiteUseLookupResponses.get(sSelectedLocationId).CityStateZipCountry;
            oIntProject.Project_Org_Id__c=sSelectedLocationId;

            update oIntProject;
        }

		return returnToIntProject();

    }
}