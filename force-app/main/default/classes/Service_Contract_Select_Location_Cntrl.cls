/*
    Controller class for the ServiceContractSelectLocation.page on the Service_Contract__c object.  Handles logic for selecting an existing ship to location for a service contract.

    MOD DATE        Who                     Description
    05/11/2015      Chris Noe               Initial Release
*/

public with sharing class Service_Contract_Select_Location_Cntrl {
	////Class variables
    //public final Service_Contract__c oServiceContract;
    //public String sSelectedLocationId {get; set;}
    //public Boolean bShipToLocations {get; private set;}
    //public Map<String,Web_Service_Utility.ShipToSiteUseLookupResponse> mapShipToSiteUseLookupResponses {get; set;}
    //public List<Web_Service_Utility.ShipToSiteUseLookupResponse> listShipToSiteUseLookupResponses {get; set;}

	//public Service_Contract_Select_Location_Cntrl(ApexPages.StandardController stdController) {
		////Method variables
		//Account oShipToCustomerAccount = new Account();
        //String sCustomerAccountId;

        ////Get the current Service_Contract__c record
        //this.oServiceContract = (Service_Contract__c)stdController.getRecord();

        ////Initialize boolean flags
        //bShipToLocations=false;

        //try{
            ////Get Ship To Customer Account based on the Customer_Name__c associated with the Service_Contract__c record
            //oShipToCustomerAccount = [select Id, Customer_Account_Id__c from Account where Id = :oServiceContract.Customer_Name__c and Oracle_Party_Status__c='A' limit 1];
          
            //sCustomerAccountId = oShipToCustomerAccount.Customer_Account_Id__c;
        //}
        //catch(Exception oException) {
            ////No customer account found for the Customer_Name__c associated with the Service_Contract__c
        //}

        //if(!String.isBlank(sCustomerAccountId)){
            ////Query logic for outbound web service to retrieve ship to locations - Initiate web service callout
            //listShipToSiteUseLookupResponses = Web_Service_Utility.SiteUseLookup(sCustomerAccountId, 'Select Service Contract Location');
            
            //if(!listShipToSiteUseLookupResponses.isEmpty()){
                //bShipToLocations=true;
                
                //mapShipToSiteUseLookupResponses = new Map<String,Web_Service_Utility.ShipToSiteUseLookupResponse>();    
                ////Spin through the list and add each item to a map so we can reference the address fields later and write them to the fields on the Service_Contract__c record.
                //for(Web_Service_Utility.ShipToSiteUseLookupResponse oResponse :listShipToSiteUseLookupResponses){
                    //mapShipToSiteUseLookupResponses.put(oResponse.SiteUseId,oResponse);
                //}
            //}
        //}
	//}

    ////Page reference to return the user to the Service_Contract__c record
    //public PageReference returnToServiceContract() {
        //PageReference oPageRef = new PageReference('/' + oServiceContract.Id);
        //oPageRef.setRedirect(true);
        //return oPageRef;
    //}

    ////Method called when user selects a location
    //public PageReference shipToSelect() {
        ////Method variables
        //PageReference oPageRef;
        //String sEndUserLocation;
        
        ////Get selected location id from page.
        //sSelectedLocationId = Apexpages.currentpage().getParameters().get('shipLocId');
        
        //if(!String.isBlank(sSelectedLocationId)){

        	////Set the End User Location (End_User_Location__c) field on the Service_Contract__c record.
        	//sEndUserLocation=mapShipToSiteUseLookupResponses.get(sSelectedLocationId).Address1;
        	//if(!String.isBlank(mapShipToSiteUseLookupResponses.get(sSelectedLocationId).Address2)){
        		//sEndUserLocation = sEndUserLocation + '\n' + mapShipToSiteUseLookupResponses.get(sSelectedLocationId).Address2;
        	//}
        	//if(!String.isBlank(mapShipToSiteUseLookupResponses.get(sSelectedLocationId).Address3)){
        		//sEndUserLocation = sEndUserLocation + '\n' + mapShipToSiteUseLookupResponses.get(sSelectedLocationId).Address3;
        	//}
        	//if(!String.isBlank(mapShipToSiteUseLookupResponses.get(sSelectedLocationId).Address4)){
        		//sEndUserLocation = sEndUserLocation + '\n' + mapShipToSiteUseLookupResponses.get(sSelectedLocationId).Address4;
        	//}

        	//sEndUserLocation = sEndUserLocation + '\n' + mapShipToSiteUseLookupResponses.get(sSelectedLocationId).CityStateZipCountry;

        	//oServiceContract.End_User_Location__c = sEndUserLocation;

            ////Update Oracle Ship To Address Fields
            //oServiceContract.Ship_To_Address1_Oracle__c=mapShipToSiteUseLookupResponses.get(sSelectedLocationId).Address1;
            //oServiceContract.Ship_To_Address2_Oracle__c=mapShipToSiteUseLookupResponses.get(sSelectedLocationId).Address2;
            //oServiceContract.Ship_To_Address3_Oracle__c=mapShipToSiteUseLookupResponses.get(sSelectedLocationId).Address3;
            //oServiceContract.Ship_To_Address4_Oracle__c=mapShipToSiteUseLookupResponses.get(sSelectedLocationId).Address4;
            //oServiceContract.Ship_To_City_State_Zip_Country_Oracle__c=mapShipToSiteUseLookupResponses.get(sSelectedLocationId).CityStateZipCountry;
            //oServiceContract.Ship_To_Org_Id__c=sSelectedLocationId;

            //update oServiceContract;
        //}

		//return returnToServiceContract();

    //}
}