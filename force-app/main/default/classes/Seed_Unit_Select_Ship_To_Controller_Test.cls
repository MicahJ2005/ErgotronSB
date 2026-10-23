/*
    Test class for Seed_Unit_Select_Ship_To_Controller.cls

    MOD DATE        Who                     Description
    4/24/2014       Chris Noe               Initial Release
    5/30/2014       Chris Noe               Updates to support external web service call to Oracle to retrieve ship to addresses.
    8/7/2014        Chris Noe               Updates to support default of corporate address when no ship to addresses exist for the customer.
    9/3/2014        Chris Noe               Updates related to FB-00449 to properly set the bill to account on seed unit orders for hospitals.
    11/14/2014      Chris Noe               Updates related to FB-00384 bill seed orders to end user and ship to reseller customer
*/
@isTest
private class Seed_Unit_Select_Ship_To_Controller_Test {

    static testMethod void shipToNoSelect() {
        //Test method for Seed_Unit_Select_Ship_To_Controller.shipToSaveSelect where no address is selected or entered.
        
        //Create account for testing
        Account oAccount = Test_Environment_Utility.createInsertAccountUS();
        //Create contact for testing
        Contact oContact = Test_Environment_Utility.createInsertContact(oAccount);
        //Create customer account for testing
        //Customer_Account__c oCustomerAccount = Test_Environment_Utility.createInsertCustomerAccount(oAccount);
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccount, 'Seeding', Date.today());
        //Create seed unit order for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Hospital', oAccount, oContact);
        //Create product for testing
        Product2 oProduct = Test_Environment_Utility.createInsertProduct();
        //Create seed unit product for testing
        Seed_Unit_Product__c oSeedUnitProduct = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProduct, 5);  
        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetail = Test_Environment_Utility.createInsertWebServiceDetails('Ship To Site Use Lookup');

        Test.startTest();
            SingleHTTPRequestMock_Test oFakeResponseTrigger = new SingleHTTPRequestMock_Test(200,
                                                            'Complete',
                                                            '['+
                '  {'+
                '    \"__type\": \"RepLocator.Site\",'+
                '    \"SiteUseId\": \"611088\",'+
                '    \"LocationName\": \"CHAMPAIGN 2109\",'+
                '    \"CustomerName\": \"AMDOCS\",'+
                '    \"CustomerNumber\": \"147872\",'+
                '    \"Address1\": \"2109 FOX DR\",'+
                '    \"CityStateZipCountry\": \"CHAMPAIGN,IL, 61820, US\",'+
                '    \"Address2\": \"\",'+
                '    \"Address3\": \"\",'+
                '    \"Address4\": \"\",'+
                '    \"AccountDescription\": \"DOMESTIC\",'+
                '    \"PartyNumber\": \"303075\"'+
                '  }'+
                ']'
                 , null);
            
            Test.setMock(HttpCalloutMock.class, oFakeResponseTrigger);

            /*BEGIN TEST: NO SHIP TO SELECTED*/
            
            PageReference oPageRef = Page.SeedUnitSelectShipTo;
            Test.setCurrentPage(oPageRef);
            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            oPageRef.getParameters().put('id',String.valueOf(oSeedUnitOrder.Id));
            Seed_Unit_Select_Ship_To_Controller oExtController = new Seed_Unit_Select_Ship_To_Controller(oStdController);
            
            oPageRef = oExtController.shipToSaveSelect();
            
            //Assert page reference returned for save/select - no ship to selected
            System.assertEquals(null,oPageRef); 
            //Check to verify that page message was added
            List<ApexPages.Message> listPageMessages = ApexPages.getMessages();
            Boolean bMessageFound=false;
            for(ApexPages.Message oMessage :listPageMessages){
                if(oMessage.getDetail().contains('Please select a ship to location or enter a new one')){
                    bMessageFound=true;
                }
            }
            system.assert(bMessageFound);
        Test.stopTest();
    }

    static testMethod void shipToSelected() {
        //Test method for Seed_Unit_Select_Ship_To_Controller.shipToSaveSelect method where existing ship to address is selected.
        
        //Create account for testing
        Account oAccount = Test_Environment_Utility.createInsertAccountUS();
        //Create contact for testing
        Contact oContact = Test_Environment_Utility.createInsertContact(oAccount);
        //Create customer account for testing
        //Customer_Account__c oCustomerAccount = Test_Environment_Utility.createInsertCustomerAccount(oAccount);
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccount, 'Seeding', Date.today());
        //Create seed unit order for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Hospital', oAccount, oContact);
        //Create product for testing
        Product2 oProduct = Test_Environment_Utility.createInsertProduct();
        //Create seed unit product for testing
        Seed_Unit_Product__c oSeedUnitProduct = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProduct, 5);  
        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetail = Test_Environment_Utility.createInsertWebServiceDetails('Ship To Site Use Lookup');

        Test.startTest();
            SingleHTTPRequestMock_Test oFakeResponseTrigger = new SingleHTTPRequestMock_Test(200,
                                                            'Complete',
                                                            '['+
                '  {'+
                '    \"__type\": \"RepLocator.Site\",'+
                '    \"SiteUseId\": \"611088\",'+
                '    \"LocationName\": \"CHAMPAIGN 2109\",'+
                '    \"CustomerName\": \"AMDOCS\",'+
                '    \"CustomerNumber\": \"147872\",'+
                '    \"Address1\": \"2109 FOX DR\",'+
                '    \"CityStateZipCountry\": \"CHAMPAIGN,IL, 61820, US\",'+
                '    \"Address2\": \"\",'+
                '    \"Address3\": \"\",'+
                '    \"Address4\": \"\",'+
                '    \"AccountDescription\": \"DOMESTIC\",'+
                '    \"PartyNumber\": \"303075\"'+
                '  }'+
                ']'
                 , null);
            
            Test.setMock(HttpCalloutMock.class, oFakeResponseTrigger);  
            
            /*BEGIN TEST: SHIP TO SELECTED*/
            
            oSeedUnitOrder = [select Id, Sold_To_Org_new__c, Seed_Unit_Order_Submitted__c, Seed_Unit_Approval_Status__c, Sold_To_Salesforce_Id__c, Ship_To_Account__r.BillingStreet, 
                                Ship_To_Account__r.BillingCity, Ship_To_Account__r.BillingState, Ship_To_Account__r.BillingStateCode, Ship_To_Account__r.BillingPostalCode, 
                                Ship_To_Account__r.BillingCountry, Ship_To_Account__r.BillingCountryCode, Ship_To_Salesforce_Id__c, Ship_To_Customer_Account_new__c, Opportunity__c
                                from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];

            PageReference oPageRef = Page.SeedUnitSelectShipTo;
            Test.setCurrentPage(oPageRef);

            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            //Add the selected ship to id parameter to the page
            oPageRef.getParameters().put('shipLocId','611088');
            oPageRef.getParameters().put('id',String.valueOf(oSeedUnitOrder.Id));
            Seed_Unit_Select_Ship_To_Controller oExtController = new Seed_Unit_Select_Ship_To_Controller(oStdController);

            oPageRef = oExtController.shipToSaveSelect();           
            
            //Assert page reference returned for save/select with ship to
            System.assertEquals('/' + oSeedUnitOrder.Id,oPageRef.getURL());

            //Assert Ship_To_Org_Id__c on Seed_Unit_Order__c
            System.assertEquals('611088',[select Id, Ship_To_Org_Id__c from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id].Ship_To_Org_Id__c);
        Test.stopTest();
    }

    static testMethod void shipToEntered() {
        //Test method for Seed_Unit_Select_Ship_To_Controller.shipToSaveSelect method where ship to is entered.
        
        //Create account for testing
        Account oAccount = Test_Environment_Utility.createInsertAccountUS();
        //Create contact for testing
        Contact oContact = Test_Environment_Utility.createInsertContact(oAccount);
        //Create customer account for testing
        //Customer_Account__c oCustomerAccount = Test_Environment_Utility.createInsertCustomerAccount(oAccount);
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccount, 'Seeding', Date.today());
        //Create seed unit order for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Hospital', oAccount, oContact);
        //Create product for testing
        Product2 oProduct = Test_Environment_Utility.createInsertProduct();
        //Create seed unit product for testing
        Seed_Unit_Product__c oSeedUnitProduct = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProduct, 5);  
        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetail = Test_Environment_Utility.createInsertWebServiceDetails('Ship To Site Use Lookup');

        Test.startTest();
            SingleHTTPRequestMock_Test oFakeResponseTrigger = new SingleHTTPRequestMock_Test(200,
                                                            'Complete',
                                                            '['+
                '  {'+
                '    \"__type\": \"RepLocator.Site\",'+
                '    \"SiteUseId\": \"611088\",'+
                '    \"LocationName\": \"CHAMPAIGN 2109\",'+
                '    \"CustomerName\": \"AMDOCS\",'+
                '    \"CustomerNumber\": \"147872\",'+
                '    \"Address1\": \"2109 FOX DR\",'+
                '    \"CityStateZipCountry\": \"CHAMPAIGN,IL, 61820, US\",'+
                '    \"Address2\": \"\",'+
                '    \"Address3\": \"\",'+
                '    \"Address4\": \"\",'+
                '    \"AccountDescription\": \"DOMESTIC\",'+
                '    \"PartyNumber\": \"303075\"'+
                '  }'+
                ']'
                 , null);
            
            Test.setMock(HttpCalloutMock.class, oFakeResponseTrigger);

            /*BEGIN TEST: SHIP TO ENTERED*/
            //Update address fields on Seed Unit Order
            oSeedUnitOrder.Ship_To_Org_Id__c=NULL;
            oSeedUnitOrder.Ship_To_Address1__c = '100 TEST AVE';
            oSeedUnitOrder.Ship_To_City__c = 'TEST CITY';
            oSeedUnitOrder.Ship_To_State_Province__c = 'Minnesota-MN';
            oSeedUnitOrder.Ship_To_Postal_Code__c = '55372';
            oSeedUnitOrder.Ship_To_Country__c = 'United States-US';
            update oSeedUnitOrder;
            
            //Query for updated Seed Unit Order record
            oSeedUnitOrder = [select Id, Sold_To_Org_new__c, Seed_Unit_Order_Submitted__c, Seed_Unit_Approval_Status__c, Ship_To_Org_Id__c, Ship_To_Address1__c, Ship_To_City__c, 
                                Ship_To_State_Province__c, Ship_To_Postal_Code__c, Ship_To_Country__c, Sold_To_Salesforce_Id__c, Ship_To_Account__r.BillingCountry, Ship_To_Account__r.BillingState,
                                Ship_To_Account__r.BillingStreet, Ship_To_Account__r.BillingCity, Ship_To_Account__r.BillingStateCode, Ship_To_Account__r.BillingPostalCode, 
                                Ship_To_Account__r.BillingCountryCode, Ship_To_Salesforce_Id__c, Ship_To_Customer_Account_new__c, Opportunity__c
                                from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];

            PageReference oPageRef = Page.SeedUnitSelectShipTo;
            oPageRef.getParameters().put('shipLocId',NULL);
            Test.setCurrentPage(oPageRef);
            
            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            oPageRef.getParameters().put('id',String.valueOf(oSeedUnitOrder.Id));
            Seed_Unit_Select_Ship_To_Controller oExtController = new Seed_Unit_Select_Ship_To_Controller(oStdController);

            oPageRef = oExtController.shipToSaveSelect();         
            
            //Assert page reference returned for save/select with ship to
            System.assertEquals('/apex/seedunitverifyaddress?id=' + oSeedUnitOrder.Id,oPageRef.getURL());
            //Assertions for boolean flags
            System.assertEquals(true,oExtController.bRenderList);
            System.assertEquals(false,oExtController.bShipToLocations);
        Test.stopTest();
    }

    static testMethod void shipToEnteredCanada() {
        //Test method for Seed_Unit_Select_Ship_To_Controller.shipToSaveSelect method where ship to is entered and country = Canada.
        
        //Create account for testing
        Account oAccount = Test_Environment_Utility.createInsertAccountCA();
        //Create contact for testing
        Contact oContact = Test_Environment_Utility.createInsertContact(oAccount);
        //Create customer account for testing
        //Customer_Account__c oCustomerAccount = Test_Environment_Utility.createInsertCustomerAccount(oAccount);
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccount, 'Seeding', Date.today());
        //Create seed unit order for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Hospital', oAccount, oContact);
        //Create product for testing
        Product2 oProduct = Test_Environment_Utility.createInsertProduct();
        //Create seed unit product for testing
        Seed_Unit_Product__c oSeedUnitProduct = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProduct, 5);  
        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetail = Test_Environment_Utility.createInsertWebServiceDetails('Ship To Site Use Lookup');

        Test.startTest();
            SingleHTTPRequestMock_Test oFakeResponseTrigger = new SingleHTTPRequestMock_Test(200,
                                                            'Complete',
                                                            '['+
                '  {'+
                '    \"__type\": \"RepLocator.Site\",'+
                '    \"SiteUseId\": \"611088\",'+
                '    \"LocationName\": \"CHAMPAIGN 2109\",'+
                '    \"CustomerName\": \"AMDOCS\",'+
                '    \"CustomerNumber\": \"147872\",'+
                '    \"Address1\": \"2109 FOX DR\",'+
                '    \"CityStateZipCountry\": \"CHAMPAIGN,IL, 61820, US\",'+
                '    \"Address2\": \"\",'+
                '    \"Address3\": \"\",'+
                '    \"Address4\": \"\",'+
                '    \"AccountDescription\": \"DOMESTIC\",'+
                '    \"PartyNumber\": \"303075\"'+
                '  }'+
                ']'
                 , null);
            
            Test.setMock(HttpCalloutMock.class, oFakeResponseTrigger);

            /*BEGIN TEST: SHIP TO ENTERED*/
            //Update address fields on Seed Unit Order
            oSeedUnitOrder.Ship_To_Org_Id__c=NULL;
            oSeedUnitOrder.Ship_To_Address1__c = '100 TEST AVE';
            oSeedUnitOrder.Ship_To_City__c = 'TEST CITY';
            oSeedUnitOrder.Ship_To_State_Province__c = 'British Columbia-BC';
            oSeedUnitOrder.Ship_To_Postal_Code__c = 'X67 453';
            oSeedUnitOrder.Ship_To_Country__c = 'Canada-CA';
            update oSeedUnitOrder;
            
            //Query for updated Seed Unit Order record
            oSeedUnitOrder = [select Id, Sold_To_Org_new__c, Seed_Unit_Order_Submitted__c, Seed_Unit_Approval_Status__c, Ship_To_Org_Id__c, Ship_To_Address1__c, Ship_To_City__c, 
                                Ship_To_State_Province__c, Ship_To_Postal_Code__c, Ship_To_Country__c, Sold_To_Salesforce_Id__c, Ship_To_Account__r.BillingCountry, Ship_To_Account__r.BillingState,
                                Ship_To_Account__r.BillingStreet, Ship_To_Account__r.BillingCity, Ship_To_Account__r.BillingStateCode, Ship_To_Account__r.BillingPostalCode, 
                                Ship_To_Account__r.BillingCountryCode, Ship_To_Salesforce_Id__c, Ship_To_Customer_Account_new__c, Opportunity__c
                                from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];

            PageReference oPageRef = Page.SeedUnitSelectShipTo;
            oPageRef.getParameters().put('shipLocId',NULL);
            Test.setCurrentPage(oPageRef);
            
            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            oPageRef.getParameters().put('id',String.valueOf(oSeedUnitOrder.Id));
            Seed_Unit_Select_Ship_To_Controller oExtController = new Seed_Unit_Select_Ship_To_Controller(oStdController);

            oPageRef = oExtController.shipToSaveSelect();         
            
            //Assert page reference returned for save/select with ship to
            System.assertEquals('/' + oSeedUnitOrder.Id,oPageRef.getURL());
            //Assertions for boolean flags
            System.assertEquals(true,oExtController.bRenderList);
            System.assertEquals(false,oExtController.bShipToLocations);
        Test.stopTest();
    }

    static testMethod void shipToDefault() {
        //Test method for Seed_Unit_Select_Ship_To_Controller.shipToSaveSelect method where ship to is defaulted from the associated account.
        
        //Create account for testing
        Account oAccount = Test_Environment_Utility.createInsertAccountUS();
        //Create contact for testing
        Contact oContact = Test_Environment_Utility.createInsertContact(oAccount);
        //Create customer account for testing
        //Customer_Account__c oCustomerAccount = Test_Environment_Utility.createInsertCustomerAccount(oAccount);
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccount, 'Seeding', Date.today());
        //Create seed unit order for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Hospital', oAccount, oContact);
        //Create product for testing
        Product2 oProduct = Test_Environment_Utility.createInsertProduct();
        //Create seed unit product for testing
        Seed_Unit_Product__c oSeedUnitProduct = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProduct, 5);  
        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetail = Test_Environment_Utility.createInsertWebServiceDetails('Ship To Site Use Lookup');

        Test.startTest();
            SingleHTTPRequestMock_Test oFakeResponseTrigger = new SingleHTTPRequestMock_Test(200,
                                                            'Complete',
                                                            '[]', null);
            
            Test.setMock(HttpCalloutMock.class, oFakeResponseTrigger);

            /*BEGIN TEST: SHIP TO DEFAULTED*/
            
            //Query for updated Seed Unit Order record
            oSeedUnitOrder = [select Id, Sold_To_Org_new__c, Seed_Unit_Order_Submitted__c, Seed_Unit_Approval_Status__c, Ship_To_Org_Id__c, Ship_To_Address1__c, Ship_To_City__c, 
                                Ship_To_State_Province__c, Ship_To_Postal_Code__c, Ship_To_Country__c, Sold_To_Salesforce_Id__c, Ship_To_Account__r.BillingCountry, Ship_To_Account__r.BillingState,
                                Ship_To_Account__r.BillingStreet, Ship_To_Account__r.BillingCity, Ship_To_Account__r.BillingStateCode, Ship_To_Account__r.BillingPostalCode, 
                                Ship_To_Account__r.BillingCountryCode, Ship_To_Salesforce_Id__c, Ship_To_Customer_Account_new__c, Opportunity__c
                                from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];

            PageReference oPageRef = Page.SeedUnitSelectShipTo;
            oPageRef.getParameters().put('shipLocId',NULL);
            Test.setCurrentPage(oPageRef);
            
            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            oPageRef.getParameters().put('id',String.valueOf(oSeedUnitOrder.Id));
            Seed_Unit_Select_Ship_To_Controller oExtController = new Seed_Unit_Select_Ship_To_Controller(oStdController);

            oPageRef = oExtController.shipToSaveSelect();         
            
            //Assert page reference returned for save/select with ship to
            System.assertEquals('/apex/seedunitverifyaddress?id=' + oSeedUnitOrder.Id,oPageRef.getURL());
            //Assertions for boolean flags
            System.assertEquals(true,oExtController.bRenderList);
            System.assertEquals(false,oExtController.bShipToLocations);
        Test.stopTest();
    }

    static testMethod void shipToSubmitted() {
        //Test method for Seed_Unit_Select_Ship_To_Controller.shipToSaveSelect method where seed unit order has already been submitted.
        
        //Create account for testing
        Account oAccount = Test_Environment_Utility.createInsertAccountUS();
        //Create contact for testing
        Contact oContact = Test_Environment_Utility.createInsertContact(oAccount);
        //Create customer account for testing
        //Customer_Account__c oCustomerAccount = Test_Environment_Utility.createInsertCustomerAccount(oAccount);
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccount, 'Seeding', Date.today());
        //Create seed unit order for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Enterprise', oAccount, oContact);

        //Create product for testing
        Product2 oProduct = Test_Environment_Utility.createInsertProduct();
        //Create seed unit product for testing
        Seed_Unit_Product__c oSeedUnitProduct = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProduct, 5);  
        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetail = Test_Environment_Utility.createInsertWebServiceDetails('Ship To Site Use Lookup');

        //Update seed approval status to submitted
        oSeedUnitOrder.Seed_Unit_Approval_Status__c='Submitted';
        update oSeedUnitOrder;

        Test.startTest();
            SingleHTTPRequestMock_Test oFakeResponseTrigger = new SingleHTTPRequestMock_Test(200,
                                                            'Complete',
                                                            '[]', null);
            
            Test.setMock(HttpCalloutMock.class, oFakeResponseTrigger);

            /*BEGIN TEST: SHIP TO SELECT ORDER SUBMITTED*/
            
            //Query for updated Seed Unit Order record
            oSeedUnitOrder = [select Id, Sold_To_Org_new__c, Seed_Unit_Order_Submitted__c, Seed_Unit_Approval_Status__c, Ship_To_Org_Id__c, Ship_To_Address1__c, Ship_To_City__c, 
                                Ship_To_State_Province__c, Ship_To_Postal_Code__c, Ship_To_Country__c, Sold_To_Salesforce_Id__c, Ship_To_Account__r.BillingCountry, Ship_To_Account__r.BillingState,
                                Ship_To_Account__r.BillingStreet, Ship_To_Account__r.BillingCity, Ship_To_Account__r.BillingStateCode, Ship_To_Account__r.BillingPostalCode, 
                                Ship_To_Account__r.BillingCountryCode, Ship_To_Salesforce_Id__c, Ship_To_Customer_Account_new__c, Opportunity__c
                                from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];

            PageReference oPageRef = Page.SeedUnitSelectShipTo;
            oPageRef.getParameters().put('shipLocId',NULL);
            Test.setCurrentPage(oPageRef);
            
            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            oPageRef.getParameters().put('id',String.valueOf(oSeedUnitOrder.Id));
            Seed_Unit_Select_Ship_To_Controller oExtController = new Seed_Unit_Select_Ship_To_Controller(oStdController);

            System.assertEquals(false,oExtController.bRenderList);
        Test.stopTest();
    }

    static testMethod void shipToSelectedShipToReseller() {
        //Test method for Seed_Unit_Select_Ship_To_Controller.shipToSaveSelect method where existing ship to address is selected and seed order is shipping to a different customer.
        
        //Create accounts for testing
        Account oAccountEndUser = Test_Environment_Utility.createInsertAccountUS();
        Account oAccountReseller = Test_Environment_Utility.createInsertAccountUS();
        //Create contact for testing
        Contact oContactReseller = Test_Environment_Utility.createInsertContact(oAccountReseller);
        //Create customer accounts for testing
        //Customer_Account__c oCustomerAccountEndUser = Test_Environment_Utility.createInsertCustomerAccount(oAccountEndUser);
        //Customer_Account__c oCustomerAccountReseller = Test_Environment_Utility.createInsertCustomerAccount(oAccountReseller);
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccountEndUser, 'Seeding', Date.today());
        //Create seed unit order for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Hospital', oAccountReseller, oContactReseller);
        //Create product for testing
        Product2 oProduct = Test_Environment_Utility.createInsertProduct();
        //Create seed unit product for testing
        Seed_Unit_Product__c oSeedUnitProduct = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProduct, 5);  
        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetail = Test_Environment_Utility.createInsertWebServiceDetails('Ship To Site Use Lookup');

        Test.startTest();
            SingleHTTPRequestMock_Test oFakeResponseTrigger = new SingleHTTPRequestMock_Test(200,
                                                            'Complete',
                                                            '['+
                '  {'+
                '    \"__type\": \"RepLocator.Site\",'+
                '    \"SiteUseId\": \"611088\",'+
                '    \"LocationName\": \"CHAMPAIGN 2109\",'+
                '    \"CustomerName\": \"AMDOCS\",'+
                '    \"CustomerNumber\": \"147872\",'+
                '    \"Address1\": \"2109 FOX DR\",'+
                '    \"CityStateZipCountry\": \"CHAMPAIGN,IL, 61820, US\",'+
                '    \"Address2\": \"\",'+
                '    \"Address3\": \"\",'+
                '    \"Address4\": \"\",'+
                '    \"AccountDescription\": \"DOMESTIC\",'+
                '    \"PartyNumber\": \"303075\"'+
                '  }'+
                ']'
                 , null);
            
            Test.setMock(HttpCalloutMock.class, oFakeResponseTrigger);  
            
            /*BEGIN TEST: SHIP TO SELECTED*/
            
            oSeedUnitOrder = [select Id, Sold_To_Org_new__c, Seed_Unit_Order_Submitted__c, Seed_Unit_Approval_Status__c, Ship_To_Org_Id__c, Ship_To_Address1__c, Ship_To_City__c, 
                                Ship_To_State_Province__c, Ship_To_Postal_Code__c, Ship_To_Country__c, Sold_To_Salesforce_Id__c, Ship_To_Account__r.BillingCountry, Ship_To_Account__r.BillingState,
                                Ship_To_Account__r.BillingStreet, Ship_To_Account__r.BillingCity, Ship_To_Account__r.BillingStateCode, Ship_To_Account__r.BillingPostalCode, 
                                Ship_To_Account__r.BillingCountryCode, Ship_To_Salesforce_Id__c, Ship_To_Customer_Account_new__c, Opportunity__c
                                from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];

            
            PageReference oPageRef = Page.SeedUnitSelectShipTo;
            Test.setCurrentPage(oPageRef);

            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            //Add the selected ship to id parameter to the page
            oPageRef.getParameters().put('shipLocId','611088');
            oPageRef.getParameters().put('id',String.valueOf(oSeedUnitOrder.Id));
            Seed_Unit_Select_Ship_To_Controller oExtController = new Seed_Unit_Select_Ship_To_Controller(oStdController);

            oPageRef = oExtController.shipToSaveSelect();           
            
            //Assert page reference returned for save/select with ship to
            System.assertEquals('/' + oSeedUnitOrder.Id,oPageRef.getURL());

            //Assert Ship_To_Org_Id__c on Seed_Unit_Order__c
            System.assertEquals('611088',[select Id, Ship_To_Org_Id__c from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id].Ship_To_Org_Id__c);
        Test.stopTest();
    }   

    static testMethod void shipToNoSelectShipToReseller() {
        //Test method for Seed_Unit_Select_Ship_To_Controller.shipToSaveSelect where no address is selected or entered and seed order is shipping to a different customer.
        
        //Create account for testing
        Account oAccountEndUser = Test_Environment_Utility.createInsertAccountUS();
        Account oAccountReseller = Test_Environment_Utility.createInsertAccountUS();
        //Create contact for testing
        Contact oContactReseller = Test_Environment_Utility.createInsertContact(oAccountReseller);
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccountEndUser, 'Seeding', Date.today());
        //Create seed unit order for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Hospital', oAccountReseller, oContactReseller);
        //Create product for testing
        Product2 oProduct = Test_Environment_Utility.createInsertProduct();
        //Create seed unit product for testing
        Seed_Unit_Product__c oSeedUnitProduct = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProduct, 5);  
        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetail = Test_Environment_Utility.createInsertWebServiceDetails('Ship To Site Use Lookup');

        Test.startTest();
            SingleHTTPRequestMock_Test oFakeResponseTrigger = new SingleHTTPRequestMock_Test(200,
                                                            'Complete',
                                                            '['+
                '  {'+
                '    \"__type\": \"RepLocator.Site\",'+
                '    \"SiteUseId\": \"611088\",'+
                '    \"LocationName\": \"CHAMPAIGN 2109\",'+
                '    \"CustomerName\": \"AMDOCS\",'+
                '    \"CustomerNumber\": \"147872\",'+
                '    \"Address1\": \"2109 FOX DR\",'+
                '    \"CityStateZipCountry\": \"CHAMPAIGN,IL, 61820, US\",'+
                '    \"Address2\": \"\",'+
                '    \"Address3\": \"\",'+
                '    \"Address4\": \"\",'+
                '    \"AccountDescription\": \"DOMESTIC\",'+
                '    \"PartyNumber\": \"303075\"'+
                '  }'+
                ']'
                 , null);
            
            Test.setMock(HttpCalloutMock.class, oFakeResponseTrigger);

            /*BEGIN TEST: NO SHIP TO SELECTED*/

            oSeedUnitOrder = [select Id, Sold_To_Org_new__c, Seed_Unit_Order_Submitted__c, Seed_Unit_Approval_Status__c, Ship_To_Org_Id__c, Ship_To_Address1__c, Ship_To_City__c, 
                                Ship_To_State_Province__c, Ship_To_Postal_Code__c, Ship_To_Country__c, Sold_To_Salesforce_Id__c, Ship_To_Account__r.BillingCountry, Ship_To_Account__r.BillingState,
                                Ship_To_Account__r.BillingStreet, Ship_To_Account__r.BillingCity, Ship_To_Account__r.BillingStateCode, Ship_To_Account__r.BillingPostalCode, 
                                Ship_To_Account__r.BillingCountryCode, Ship_To_Salesforce_Id__c, Ship_To_Customer_Account_new__c, Opportunity__c
                                from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];
            
            PageReference oPageRef = Page.SeedUnitSelectShipTo;
            Test.setCurrentPage(oPageRef);
            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            oPageRef.getParameters().put('id',String.valueOf(oSeedUnitOrder.Id));
            Seed_Unit_Select_Ship_To_Controller oExtController = new Seed_Unit_Select_Ship_To_Controller(oStdController);
        Test.stopTest();
    }  

    static testMethod void shipToEnteredNoState() {
        //Test method for Seed_Unit_Select_Ship_To_Controller.shipToSaveSelect method where ship to is entered but State/Province is blank.
        
        //Create account for testing
        Account oAccount = Test_Environment_Utility.createInsertAccountUS();
        //Create contact for testing
        Contact oContact = Test_Environment_Utility.createInsertContact(oAccount);
        //Create customer account for testing
        //Customer_Account__c oCustomerAccount = Test_Environment_Utility.createInsertCustomerAccount(oAccount);
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccount, 'Seeding', Date.today());
        //Create seed unit order for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Hospital', oAccount, oContact);
        //Create product for testing
        Product2 oProduct = Test_Environment_Utility.createInsertProduct();
        //Create seed unit product for testing
        Seed_Unit_Product__c oSeedUnitProduct = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProduct, 5);  
        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetail = Test_Environment_Utility.createInsertWebServiceDetails('Ship To Site Use Lookup');

        Test.startTest();
            SingleHTTPRequestMock_Test oFakeResponseTrigger = new SingleHTTPRequestMock_Test(200,
                                                            'Complete',
                                                            '['+
                '  {'+
                '    \"__type\": \"RepLocator.Site\",'+
                '    \"SiteUseId\": \"611088\",'+
                '    \"LocationName\": \"CHAMPAIGN 2109\",'+
                '    \"CustomerName\": \"AMDOCS\",'+
                '    \"CustomerNumber\": \"147872\",'+
                '    \"Address1\": \"2109 FOX DR\",'+
                '    \"CityStateZipCountry\": \"CHAMPAIGN,IL, 61820, US\",'+
                '    \"Address2\": \"\",'+
                '    \"Address3\": \"\",'+
                '    \"Address4\": \"\",'+
                '    \"AccountDescription\": \"DOMESTIC\",'+
                '    \"PartyNumber\": \"303075\"'+
                '  }'+
                ']'
                 , null);
            
            Test.setMock(HttpCalloutMock.class, oFakeResponseTrigger);

            /*BEGIN TEST: SHIP TO ENTERED*/
            //Update address fields on Seed Unit Order
            oSeedUnitOrder.Ship_To_Org_Id__c=NULL;
            oSeedUnitOrder.Ship_To_Address1__c = '100 TEST AVE';
            oSeedUnitOrder.Ship_To_City__c = 'TEST CITY';
            oSeedUnitOrder.Ship_To_Postal_Code__c = '55372';
            oSeedUnitOrder.Ship_To_Country__c = 'United States-US';
            update oSeedUnitOrder;
            
            //Query for updated Seed Unit Order record
            oSeedUnitOrder = [select Id, Sold_To_Org_new__c, Seed_Unit_Order_Submitted__c, Seed_Unit_Approval_Status__c, Ship_To_Org_Id__c, Ship_To_Address1__c, Ship_To_City__c, 
                                Ship_To_State_Province__c, Ship_To_Postal_Code__c, Ship_To_Country__c, Sold_To_Salesforce_Id__c, Ship_To_Account__r.BillingCountry, Ship_To_Account__r.BillingState,
                                Ship_To_Account__r.BillingStreet, Ship_To_Account__r.BillingCity, Ship_To_Account__r.BillingStateCode, Ship_To_Account__r.BillingPostalCode, 
                                Ship_To_Account__r.BillingCountryCode, Ship_To_Salesforce_Id__c, Ship_To_Customer_Account_new__c, Opportunity__c
                                from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];

            PageReference oPageRef = Page.SeedUnitSelectShipTo;
            oPageRef.getParameters().put('shipLocId',NULL);
            Test.setCurrentPage(oPageRef);
            
            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            oPageRef.getParameters().put('id',String.valueOf(oSeedUnitOrder.Id));
            Seed_Unit_Select_Ship_To_Controller oExtController = new Seed_Unit_Select_Ship_To_Controller(oStdController);

            oPageRef = oExtController.shipToSaveSelect();         
            
            //Assert page reference returned for save/select - no ship to selected
            System.assertEquals(null,oPageRef); 
            //Check to verify that page message was added
            List<ApexPages.Message> listPageMessages = ApexPages.getMessages();
            Boolean bMessageFound=false;
            for(ApexPages.Message oMessage :listPageMessages){
                if(oMessage.getDetail().contains('Please select a state')){
                    bMessageFound=true;
                }
            }
            system.assert(bMessageFound);
        Test.stopTest();
    }         
}