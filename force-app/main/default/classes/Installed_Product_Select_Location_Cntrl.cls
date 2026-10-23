/*
    Controller class for the InstalledProductSelectLocation.page on the Installed_Product__c object.  Handles logic for selecting an existing ship to location for an installed product.

    MOD DATE        Who                     Description
    05/11/2015      Chris Noe               Initial Release
*/

public with sharing class Installed_Product_Select_Location_Cntrl {

	public Installed_Product_Select_Location_Cntrl(ApexPages.StandardController stdController) { }
	
	////Class variables
    //public final Asset oInstalledProduct;
    //public String sSelectedLocationId {get; set;}
    //public Boolean bShipToLocations {get; private set;}
    //public Map<String,Web_Service_Utility.ShipToSiteUseLookupResponse> mapShipToSiteUseLookupResponses {get; set;}
    //public List<Web_Service_Utility.ShipToSiteUseLookupResponse> listShipToSiteUseLookupResponses {get; set;}

	//public Installed_Product_Select_Location_Cntrl(ApexPages.StandardController stdController) {
		////Method variables
		//Account oShipToCustomerAccount = new Account();
        //String sCustomerAccountId;

        ////Get the current Installed_Product__c record
        //this.oInstalledProduct = (Installed_Product__c)stdController.getRecord();

        ////Initialize boolean flags
        //bShipToLocations=false;

        //try{
            //System.debug('oInstalledProduct.Customer_Name__c: ' + oInstalledProduct.Customer_Name__c);
            ////Get Ship To Customer Account based on the Customer_Name__c associated with the Installed_Product__c record
            //oShipToCustomerAccount = [SELECT Id, Customer_Account_Id__c FROM Account WHERE Id = :oInstalledProduct.Customer_Name__c and Oracle_Party_Status__c ='A' LIMIT 1];
            //System.debug('oShipToCustomerAccount.Customer_Account_Id__c: ' + oShipToCustomerAccount.Customer_Account_Id__c);
            //sCustomerAccountId = oShipToCustomerAccount.Customer_Account_Id__c;
        //}
        //catch(Exception oException) {
            ////No customer account found for the Customer_Name__c associated with the Installed_Product__c
        //}

        //if(!String.isBlank(sCustomerAccountId)){
            ////Query logic for outbound web service to retrieve ship to locations - Initiate web service callout
            //listShipToSiteUseLookupResponses = Web_Service_Utility.SiteUseLookup(sCustomerAccountId, 'Select Installed Product Location');
            
            //if(!listShipToSiteUseLookupResponses.isEmpty()){
                //bShipToLocations=true;
                
                //mapShipToSiteUseLookupResponses = new Map<String,Web_Service_Utility.ShipToSiteUseLookupResponse>();    
                ////Spin through the list and add each item to a map so we can reference the address fields later and write them to the fields on the Installed_Product__c record.
                //for(Web_Service_Utility.ShipToSiteUseLookupResponse oResponse :listShipToSiteUseLookupResponses){
                    //mapShipToSiteUseLookupResponses.put(oResponse.SiteUseId,oResponse);
                //}
            //}
        //}
	//}

    ////Page reference to return the user to the Installed_Product__c record
    //public PageReference returnToProduct() {
        //PageReference oPageRef = new PageReference('/' + oInstalledProduct.Id);
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

        	////Set the End User Location (Shipped_To_Location__c) field on the Installed_Product__c record.
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

        	//oInstalledProduct.Shipped_To_Location__c = sEndUserLocation;

            ////Update Oracle Ship To Address Fields
            //oInstalledProduct.Ship_To_Address1_Oracle__c=mapShipToSiteUseLookupResponses.get(sSelectedLocationId).Address1;
            //oInstalledProduct.Ship_To_Address2_Oracle__c=mapShipToSiteUseLookupResponses.get(sSelectedLocationId).Address2;
            //oInstalledProduct.Ship_To_Address3_Oracle__c=mapShipToSiteUseLookupResponses.get(sSelectedLocationId).Address3;
            //oInstalledProduct.Ship_To_Address4_Oracle__c=mapShipToSiteUseLookupResponses.get(sSelectedLocationId).Address4;
            //oInstalledProduct.Ship_To_City_State_Zip_Country_Oracle__c=mapShipToSiteUseLookupResponses.get(sSelectedLocationId).CityStateZipCountry;
            //oInstalledProduct.Ship_To_Org_Id__c=sSelectedLocationId;

            //update oInstalledProduct;
        //}

		//return returnToProduct();

    //}
}