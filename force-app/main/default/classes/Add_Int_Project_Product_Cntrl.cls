/*
Controller class for the AddIntProjectProduct.page.

MOD DATE		Who						Description
07/20/2015		Chris Noe				Initial Release
5/15/2018		Kelly Lafferty/DCS		Updated for new Asset/Contract structure
*/

public with sharing class Add_Int_Project_Product_Cntrl {
    //Class variables
    private Integration_Project__c oIntProject {get;private set;}
    public List<installedProduct> listInstalledProducts {get;private set;}
    public String sSearchNumber {get; set;}
    public Boolean bRenderList {get;set;}
    public String sSearchSize {get;set;}
    public String sSearchType {get;set;}
    public String sSearchTypeCap {get;set;}
    
    public Add_Int_Project_Product_Cntrl(ApexPages.StandardController oStdController) {
        //Retrieve the integration project
        this.oIntProject = (Integration_Project__c)oStdController.getRecord();
        
        //Get the search type from the URL - order=Order Search, contract=Contract Search
        sSearchType = ApexPages.currentPage().getParameters().get('type');
        
        //Set upper case value for search type
        if(sSearchType=='contract') {
            sSearchTypeCap='Contract';
        }
        else{
            sSearchTypeCap='Order';
        }
        
        //Create new instance of the installed products list
        listInstalledProducts = new List<installedProduct>();
        
        //Initialize list render to false
        bRenderList=false;
    }
    
    public void installedProductSearch(){
        //Search for Installed_Product__c records based on the search value entered by the user.
        
        //Method variables
        Set<Id> setExistingProductSet = new Set<Id>();
        
        //Clear the existing list of products
        listInstalledProducts.clear();
        
        if(sSearchNumber==NULL || sSearchNumber=='') {
            //No search number entered, display error.
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter ' + sSearchType + ' number below.'));
        }
        else{
            //Trim leading and trailing spaces from the search number entered by the user.
            sSearchNumber = sSearchNumber.trim();
            
            if(sSearchType=='order') {
                //Query for Installed Products using the order number entered by the user that are not already on the integration project.
                for(Asset oInstalledProduct : [select Id
                                               , Name
                                               , Account.Name
                                               , Oracle_Order_Number__c
                                               , Oracle_Status__c
                                               , Product2.Oracle_Part_Number__c
                                               , Product2.Oracle_Part_Name__c
                                               , Shipped_Date__c
                                               , Account.BillingStreet
                                               , Account.BillingCity
                                               , Account.BillingStateCode
                                               , Account.BillingPostalCode
                                               , Account.BillingCountry
                                               from Asset 
                                               where Oracle_Order_Number__c = :sSearchNumber 
                                               AND Integration_Project__c!=:oIntProject.Id
                                               order by Name limit 1000]){
                                                   installedProduct oNewInstalledProduct = new installedProduct();
                                                   oNewInstalledProduct.sId=oInstalledProduct.Id;
                                                   oNewInstalledProduct.sSerial=oInstalledProduct.Name;
                                                   oNewInstalledProduct.sPartNumber=oInstalledProduct.Product2.Oracle_Part_Number__c;
                                                   oNewInstalledProduct.sPartName=oInstalledProduct.Product2.Oracle_Part_Name__c;
                                                   
                                                   if(oInstalledProduct.Shipped_Date__c!=null){
                                                       oNewInstalledProduct.sShippedDate=String.valueOf(oInstalledProduct.Shipped_Date__c.month()) + '/' + String.valueOf(oInstalledProduct.Shipped_Date__c.day()) + '/' + String.valueOf(oInstalledProduct.Shipped_Date__c.year());
                                                   }
                                                   else{oNewInstalledProduct.sShippedDate='No Date Available';}
                                                   
                                                   oNewInstalledProduct.sStatus=oInstalledProduct.Oracle_Status__c;
                                                   oNewInstalledProduct.sEndUserLocation=
                                                       String.valueof(oInstalledProduct.Account.BillingStreet) + '\n' +
                                                       string.valueof(oInstalledProduct.Account.BillingCity) + ', ' +
                                                       String.valueof(oInstalledProduct.Account.BillingStateCode) + ' ' +
                                                       String.valueof(oInstalledProduct.Account.BillingPostalCode) + '\n' +
                                                       String.valueOf(oInstalledProduct.Account.BillingCountry);
                                                   oNewInstalledProduct.bSelected=false;
                                                   
                                                   listInstalledProducts.add(oNewInstalledProduct);
                                               }				
            }
            else if(sSearchType=='contract') {
                //Query for assets using the contract number entered by the user that are not already on the integration project.  This query is run on the
                //ContractLineItem object since that is where the relationship between an asset and a service contract is located.
                for(ContractLineItem oInstalledProduct : [select AssetId
                                                          , Asset.Name
                                                          , Asset.Account.Name
                                                          , Asset.Oracle_Order_Number__c
                                                          , Asset.Oracle_Status__c
                                                          , Asset.Product2.ProductCode
                                                          , Asset.Product2.Description
                                                          , Asset.Shipped_Date__c
                                                          , Asset.Account.BillingStreet
                                                          , Asset.Account.BillingCity
                                                          , Asset.Account.BillingStateCode
                                                          , Asset.Account.BillingPostalCode
                                                          , Asset.Account.BillingCountry
                                                          from ContractLineItem 
                                                          where ServiceContract.Name = :sSearchNumber
                                                          and Assetid!=null
                                                          and Asset.Integration_Project__c!=:oIntProject.Id
                                                          order by EndDate limit 1000]){
                                                              installedProduct oNewInstalledProduct = new installedProduct();
                                                              oNewInstalledProduct.sId=oInstalledProduct.AssetId;
                                                              oNewInstalledProduct.sSerial=oInstalledProduct.Asset.Name;
                                                              oNewInstalledProduct.sPartNumber=oInstalledProduct.Asset.Product2.ProductCode;
                                                              oNewInstalledProduct.sPartName=oInstalledProduct.Asset.Product2.Description;
                                                              If (oInstalledProduct.asset.shipped_date__c!=null)
                                                              {
                                                                  oNewInstalledProduct.sShippedDate=
                                                                      String.valueOf(oInstalledProduct.Asset.Shipped_Date__c.month()) + '/' + 
                                                                      String.valueOf(oInstalledProduct.Asset.Shipped_Date__c.day()) + '/' + 
                                                                      String.valueOf(oInstalledProduct.Asset.Shipped_Date__c.year());
                                                              }
                                                              else {
                                                                  oNewInstalledProduct.sShippedDate='No Date Available';}
                                                              oNewInstalledProduct.sStatus=oInstalledProduct.Asset.Oracle_Status__c;
                                                              oNewInstalledProduct.sEndUserLocation=
                                                                  String.valueof(oInstalledProduct.Asset.Account.BillingStreet) + '\n' +
                                                                  string.valueof(oInstalledProduct.Asset.Account.BillingCity) + ', ' +
                                                                  String.valueof(oInstalledProduct.Asset.Account.BillingStateCode) + ' ' +
                                                                  String.valueOf(oInstalledProduct.Asset.Account.BillingPostalCode)+'\n'+
                                                                  String.valueof(oInstalledProduct.Asset.Account.BillingCountry);
                                                              oNewInstalledProduct.bSelected=false;
                                                              
                                                              listInstalledProducts.add(oNewInstalledProduct);
                                                          }
            }	
            
            if(listInstalledProducts.isEmpty()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'There are no assets associated to ' + sSearchType + ' ' + sSearchNumber + '.'));
            }
        }
        
        //Set flag for rendering list
        bRenderList = !listInstalledProducts.isEmpty();
        //Set size variable used in message
        sSearchSize = String.valueOf(listInstalledProducts.size());
    }
    
    public void addToIntProject() {
        //This method adds the selected installed product records to the integration project.
        
        //Method variables
        Boolean bSelected=false;
        List<Asset> listUpdateInstalledProducts = new List<Asset>();
        List<installedProduct> listKeep = new List<installedProduct>();
        
        //Verify that at least one record in the list was selected.
        for(installedProduct oInstalledProduct :listInstalledProducts) {
            if(oInstalledProduct.bSelected){
                bSelected=true;
                break;
            }
        }
        
        if(!bSelected){
            //No records select, add error to the page
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No products selected.  Please select one or more products to add to the tech deployment.'));
        }
        else {
            //Loop through the list of products and update Installed_Product__c records for the selected items
            for(Integer i=0; i<listInstalledProducts.size(); i++) {
                if(listInstalledProducts[i].bSelected){
                    //Update the Integration_Project__c lookup field for the selected Installed_Product__c.
                    Asset oProduct = new Asset();
                    oProduct.Id=listInstalledProducts[i].sId;
                    oProduct.Integration_Project__c=oIntProject.Id;
                    
                    listUpdateInstalledProducts.add(oProduct);
                }
                else {
                    //Add the current item to the list to keep since it was not selected
                    listKeep.add(listInstalledProducts[i]);
                }
            }
            
            //Update the Installed_Product__c records
            update listUpdateInstalledProducts;	 
            
            //Set the main list to the list of items to keep
            listInstalledProducts=listKeep.clone();
            
            //Set flag for rendering list
            bRenderList = !listInstalledProducts.isEmpty();
            //Set size variable used in message
            sSearchSize = String.valueOf(listInstalledProducts.size());
            
            //If list is empty, reset search number value
            if(listInstalledProducts.isEmpty()){
                sSearchNumber=NULL;
            }
        }
    }
    
    public void selectAll() {
        //Selects all the records in the inner class object
        for(installedProduct oInstalledProduct :listInstalledProducts) {
            oInstalledProduct.bSelected=true;
        }
    }
    
    public void unselectAll() {
        //Un-Selects all the records in the inner class object
        for(installedProduct oInstalledProduct :listInstalledProducts) {
            oInstalledProduct.bSelected=false;
        }
    }
    
    //Inner class used for displaying search results and selecting serial numbers to add to an integration project
    public with sharing class installedProduct {
        public String sId {get;set;}
        public String sSerial {get;set;}
        public String sPartNumber {get;set;}
        public String sPartName {get;set;}
        public String sShippedDate {get;set;}
        public String sStatus {get;set;}
        public String sEndUserLocation {get;set;}
        public Boolean bSelected {get;set;}
    }
    
    public PageReference returnToIntProject(){
        PageReference oPageRef = new PageReference('/' + oIntProject.Id);
        oPageRef.setRedirect(true);
        return oPageRef;
    }
}