/*
    Controller class for the AddServiceContractProduct.page.

    MOD DATE        Who                     Description
    04/22/2015      Chris Noe               Initial Release
*/

public with sharing class Add_Service_Contract_Product_Cntrl {
    //Class variables
    private ServiceContract oServiceContract {get;private set;}
    public List<installedProduct> listInstalledProducts {get;private set;}
    public String sSearchNumber {get; set;}
    public Boolean bRenderList {get;set;}
    public String sSearchSize {get;set;}
    public String sSearchType {get;set;}
    public String sSearchTypeCap {get;set;}
    Public PriceBookEntry srvcContPBE = new PriceBookEntry();
    
        
    public Add_Service_Contract_Product_Cntrl(ApexPages.StandardController oStdController) {
        //Retrieve the service contract and Service SKU Price Book Entry
        this.oServiceContract = (ServiceContract)oStdController.getRecord();
        PriceBookEntry pbEntry = [SELECT Id
                                  FROM PriceBookEntry
                                  WHERE Product2Id = :oServiceContract.Service_SKU__c
                                  AND PriceBook2.Name = 'SERVICE PRICE BOOK (Creating Service Contracts Only)' limit 1];
        if(pbEntry.Id != null){srvcContPBE = pbEntry;}

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
        //Search for Asset records based on the search value entered by the user.

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
                
                Set<Id> SetAssetIds = new Set<Id>();
                Set<Id> SetProductIds = new Set<Id>();

                for(Asset oInstalledProduct : [select Id
                                               , Product2Id
                                        		from Asset 
                                                where Oracle_Order_Number__c = :sSearchNumber 
                                               		AND Id NOT IN (select AssetId from ContractLineItem where ServiceContractId=:oServiceContract.Id)
                                                limit 1000]){
                    setAssetIds.add(oInstalledProduct.Id);
                    SetProductIds.add(oInstalledProduct.Product2Id);
                }
/*    05-NOV-2019 - Esau - Replaced with Service Contract SKU price book entry srvcContPBE 
                  Map<Id, Id> mapProdPBE = new Map<Id,Id>();

                //Get Service Contract Pricebook Entry Id
    			For(PriceBookEntry oPBE : [SELECT Id, Product2Id
                                          FROM PriceBookEntry 
                                          WHERE Product2Id IN :SetProductIds
                                          	AND PriceBook2.Name = 'SERVICE PRICE BOOK (Creating Service Contracts Only)']){
                	mapProdPBE.put(oPBE.Product2Id,oPBE.Id);
                }
*/                
                //Query for Installed Products using the order number entered by the user that are not already on the service contract.
                for(Asset oInstalledProduct : [select Id
                                               , Name
                                               , Account.Name
                                               , Oracle_Order_Number__c
                                               , Oracle_Status__c
                                               , Product2Id
                                               , Product2.Oracle_Part_Number__c
                                               , Product2.Oracle_Part_Name__c
                                               , Shipped_Date__c
                                               , End_User_Location__c
                                               , SerialNumber
                                        		from Asset 
                                               where Id IN :setAssetIds
                                               order by Name]){
                    installedProduct oNewInstalledProduct = new installedProduct();
                    oNewInstalledProduct.sId=oInstalledProduct.Id;                     
                    oNewInstalledProduct.sSerial=oInstalledProduct.SerialNumber;
                    oNewInstalledProduct.sPartNumber=oInstalledProduct.Product2.Oracle_Part_Number__c;
                    oNewInstalledProduct.sPartName=oInstalledProduct.Product2.Oracle_Part_Name__c;
                    if(oInstalledProduct.Shipped_Date__c != null){
                        oNewInstalledProduct.sShippedDate=String.valueOf(oInstalledProduct.Shipped_Date__c.month()) + '/' + String.valueOf(oInstalledProduct.Shipped_Date__c.day()) + '/' + String.valueOf(oInstalledProduct.Shipped_Date__c.year());
                    }                               
                                                   oNewInstalledProduct.sStatus=oInstalledProduct.Oracle_Status__c;
                    oNewInstalledProduct.sEndUserLocation=oInstalledProduct.End_User_Location__c;
                    oNewInstalledProduct.bSelected=false;
                    //oNewInstalledProduct.sPricebookEntryId=mapProdPBE.get(oInstalledProduct.Product2Id);
                    listInstalledProducts.add(oNewInstalledProduct);
                }               
            }
            else if(sSearchType=='contract') {
                //Build a set of existing Installed Products on the current service contract.  This set is built vs. doing an inner query because inner 
                //and outer selects cannot be on the same object type.
                for(ContractLineItem oCurrentContractProducts :[select AssetId from ContractLineItem where ServiceContractId=:oServiceContract.Id]){
                    setExistingProductSet.add(oCurrentContractProducts.AssetId);
                }

                //Query for Installed Products using the contract number entered by the user that are not already on the current service contract.  This query is run on the
                //ContractLineItem object since that is where the relationship between an installed product and a service contract is located
                for(ContractLineItem oInstalledProduct : [select Asset.Id
                                                          		, Asset.Name
                                                          		, Asset.Account.Name
                                                          		, Asset.Oracle_Order_Number__c
                                                          		, Asset.Oracle_Status__c
                                                          		, Asset.ProductCode
                                                          		, Asset.Product_Description__c
                                                         		, Asset.Shipped_Date__c
                                                         		, Asset.End_User_Location__c
                                                        		, Asset.SerialNumber
                                                        		, PricebookEntryId
                                        				  from ContractLineItem 
                                                          where ServiceContract.Name = :sSearchNumber 
                                                          		and AssetId NOT IN :setExistingProductSet 
                                                          order by CreatedDate limit 1000]){
                    installedProduct oNewInstalledProduct = new installedProduct();
                    oNewInstalledProduct.sId=oInstalledProduct.Asset.Id;
                    oNewInstalledProduct.sSerial=oInstalledProduct.Asset.SerialNumber;
                    oNewInstalledProduct.sPartNumber=oInstalledProduct.Asset.ProductCode;
                    oNewInstalledProduct.sPartName=oInstalledProduct.Asset.Product_Description__c;
					//oNewInstalledProduct.sPricebookEntryId=oInstalledProduct.PricebookEntryId;
                    if(oInstalledProduct.Asset.Shipped_Date__c != null) {
                        oNewInstalledProduct.sShippedDate=String.valueOf(oInstalledProduct.Asset.Shipped_Date__c.month()) + '/' + String.valueOf(oInstalledProduct.Asset.Shipped_Date__c.day()) + '/' + String.valueOf(oInstalledProduct.Asset.Shipped_Date__c.year());
                    }
                    oNewInstalledProduct.sStatus=oInstalledProduct.Asset.Oracle_Status__c;
                    oNewInstalledProduct.sEndUserLocation=oInstalledProduct.Asset.End_User_Location__c;
                    oNewInstalledProduct.bSelected=false;

                    listInstalledProducts.add(oNewInstalledProduct);
                }
            }   

            if(listInstalledProducts.isEmpty()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No products found for ' + sSearchType + ' ' + sSearchNumber + '.'));
            }
        }

        //Set flag for rendering list
        bRenderList = !listInstalledProducts.isEmpty();
        //Set size variable used in message
        sSearchSize = String.valueOf(listInstalledProducts.size());
    }

    public void addToContract() {
        //Method variables
        Boolean bSelected=false;
        List<ContractLineItem> listServiceContractProducts = new List<ContractLineItem>();
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
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No products selected.  Please select one or more products to add to the service contract.'));
        }
        else {
            //Loop through the list of products and insert ContractLineItem records for the selected items
            for(Integer i=0; i<listInstalledProducts.size(); i++) {
                if(listInstalledProducts[i].bSelected){

                    //Add selected product as a new service contract product record
                    ContractLineItem oNewSCProduct = new ContractLineItem(); 
                    oNewSCProduct.AssetId=listInstalledProducts[i].sId;
                    oNewSCProduct.ServiceContractId=oServiceContract.Id;
                    //oNewSCProduct.PricebookEntryId=listInstalledProducts[i].sPricebookEntryId;
                    oNewSCProduct.PricebookEntryId = srvcContPBE.Id;
                    oNewSCProduct.Quantity=1;
                    oNewSCProduct.UnitPrice = 0;
                    
                    //Add the new ContractLineItem record to the list for insert
                    listServiceContractProducts.add(oNewSCProduct);
                }
                else {
                    //Add the current item to the list to keep since it was not selected
                    listKeep.add(listInstalledProducts[i]);
                }
            }

            //Insert list of Service_Contract_Products__c
            insert listServiceContractProducts;  

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

    //Inner class used for displaying search results and selecting serial numbers to add to a service contract
    public with sharing class installedProduct {
        public String sPricebookEntryId {get;set;}
        public String sId {get;set;}
        public String sSerial {get;set;}
        public String sPartNumber {get;set;}
        public String sPartName {get;set;}
        public String sShippedDate {get;set;}
        public String sStatus {get;set;}
        public String sEndUserLocation {get;set;}
        public Boolean bSelected {get;set;}
    }

    public PageReference returnToServiceContract(){
        PageReference oPageRef = new PageReference('/' + oServiceContract.Id);
        oPageRef.setRedirect(true);
        return oPageRef;
    }
}