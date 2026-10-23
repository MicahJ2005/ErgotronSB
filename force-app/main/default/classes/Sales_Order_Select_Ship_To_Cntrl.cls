/*
    Controller class for the SalesOrderSelectShipTo.page.

    MOD DATE        Who                     Description
    06/24/2015      Chris Noe               Initial Release
    10/11/2017      DCS - MCS               Removal Customer_Account__c 
*/

public without sharing class Sales_Order_Select_Ship_To_Cntrl {
    //Class variables
    public final Sales_Order__c oSalesOrder;
    public String sSelectedLocationId {get; set;}
    public Boolean bShipToLocations {get; private set;}
    public Boolean bOrderSubmitted {get; private set;}
    public Map<String,Web_Service_Utility.ShipToSiteUseLookupResponse> mapShipToSiteUseLookupResponses {get; set;}
    public List<Web_Service_Utility.ShipToSiteUseLookupResponse> listShipToSiteUseLookupResponses {get; set;}

    //Constructor
	public Sales_Order_Select_Ship_To_Cntrl(ApexPages.StandardController oStdController) {
        //Method Variables
        Account oBillToCustomerAccount = new Account();
        Account oShipToCustomerAccount = new Account();
        String sCustomerAccountId;

		//Get the current Sales_Order__c record
        oSalesOrder = (Sales_Order__c)oStdController.getRecord();  	

        //Initialize boolean flags
        bOrderSubmitted=false;
        bShipToLocations=false;

        //Determine if the sales order has already been submitted.  If submitted, no changes can be made and a list of ship to
        //addresses will not be rendered.
        if(oSalesOrder.Order_Submitted__c) {
            bOrderSubmitted=true;
        }

        else {
        	//If the bill to and ship to customer are the same on the sales order, query for the customer account and set the Ship To Customer Account
        	//and Sold To Customer Account fields on the Sales Order.
        	if(oSalesOrder.Bill_To_Customer__c==oSalesOrder.Ship_To_Customer__c){
                try{
                    oShipToCustomerAccount = [select Id, Customer_Account_Id__c from Account where Id = :oSalesOrder.Ship_To_Customer__c and Oracle_Party_Status__c='A' limit 1];
                  
                    oSalesOrder.Bill_To_Customer_Account_new__c = oShipToCustomerAccount.Id;
                    oSalesOrder.Ship_To_Customer_Account_new__c = oShipToCustomerAccount.Id;
                    sCustomerAccountId = oShipToCustomerAccount.Customer_Account_Id__c;
                }
                catch(Exception oException) {
                    //No Customer Account record found. Set values to NULL.
                    oSalesOrder.Bill_To_Customer_Account_new__c = NULL;
                    oSalesOrder.Ship_To_Customer_Account_new__c = NULL;
                }
        	}
        	else{
        		//Bill To and Ship To Customer are different.  Query for each Customer Account and set the Ship To Customer Account
        		//and Sold To Customer Account fields on the Sales Order.
                try{
                    //Get Ship To Customer Account
                    oShipToCustomerAccount = [select Id, Customer_Account_Id__c from Account where Id = :oSalesOrder.Ship_To_Customer__c and Oracle_Party_Status__c='A' limit 1];
                  
                    oSalesOrder.Ship_To_Customer_Account_new__c = oShipToCustomerAccount.Id;
                    sCustomerAccountId = oShipToCustomerAccount.Customer_Account_Id__c;
                }
                catch(Exception oException) {
                    //No Customer Account record found. Set values to NULL.
                    oSalesOrder.Bill_To_Customer_Account_new__c = NULL;
                    oSalesOrder.Ship_To_Customer_Account_new__c = NULL;
                }                
                
                try{
                    //Get Bill To Customer Account
                    oBillToCustomerAccount = [select Id, Customer_Account_Id__c from Account where Id = :oSalesOrder.Bill_To_Customer__c and Oracle_Party_Status__c='A' limit 1];
                  
                    oSalesOrder.Bill_To_Customer_Account_new__c = oBillToCustomerAccount.Id;
                }
                catch(Exception oException) {
                    //No Customer Account record found.  Set values to NULL.
                    oSalesOrder.Bill_To_Customer_Account_new__c = NULL;
                    oSalesOrder.Ship_To_Customer_Account_new__c = NULL;
                }
        	}
			
			//Load list of ship to locations for the Ship To Customer on the seed unit order by calling Oracle web service and passing in the CustomerAccountId
            if(oSalesOrder.Ship_To_Customer_Account_new__c!=NULL){
                
                //Query logic for outbound web service to retrieve ship to locations - Initiate web service callout
                listShipToSiteUseLookupResponses = Web_Service_Utility.SiteUseLookup(sCustomerAccountId, 'Sales Order Select Ship To');

                if(!listShipToSiteUseLookupResponses.isEmpty()){
                    bShipToLocations=true;
                    
                    mapShipToSiteUseLookupResponses = new Map<String,Web_Service_Utility.ShipToSiteUseLookupResponse>();    
                    //Spin through the list and add each item to a map so we can reference the address fields later and write them to the fields on the sales order
                    for(Web_Service_Utility.ShipToSiteUseLookupResponse oResponse :listShipToSiteUseLookupResponses){
                        mapShipToSiteUseLookupResponses.put(oResponse.SiteUseId,oResponse);
                    }
                }
            }
        }
	}

	//Method called when user selects a location on the SalesOrderSelectShipTo.pag
    public PageReference shipToSelect() {
        //Get selected location id from page.
        sSelectedLocationId = Apexpages.currentpage().getParameters().get('shipLocId');
        if(sSelectedLocationId!=NULL){
            //Set Ship_To_Org_Id__c field along with text address fields to the values from the selected Oracle ship to address.            
            oSalesOrder.Ship_To_Org_Id__c=sSelectedLocationId;
            oSalesOrder.Ship_To_Address1_Oracle__c=mapShipToSiteUseLookupResponses.get(sSelectedLocationId).Address1;
            oSalesOrder.Ship_To_Address2_Oracle__c=mapShipToSiteUseLookupResponses.get(sSelectedLocationId).Address2;
            oSalesOrder.Ship_To_Address3_Oracle__c=mapShipToSiteUseLookupResponses.get(sSelectedLocationId).Address3;
            oSalesOrder.Ship_To_Address4_Oracle__c=mapShipToSiteUseLookupResponses.get(sSelectedLocationId).Address4;
            oSalesOrder.Ship_To_Location_Name_Oracle__c=mapShipToSiteUseLookupResponses.get(sSelectedLocationId).LocationName;
            oSalesOrder.Ship_To_City_State_Zip_Country_Oracle__c=mapShipToSiteUseLookupResponses.get(sSelectedLocationId).CityStateZipCountry;           
            
            //Update the sales order and return the user to the seed unit detail page
            update oSalesOrder;
        }

        return returnToSalesOrder();
    }

    //Page reference to return the user to the view page for the sales order
    public PageReference returnToSalesOrder() {
        PageReference oPageRef = new PageReference('/' + oSalesOrder.Id);
        oPageRef.setRedirect(true);
        return oPageRef;
    }
}