/*
	Test class for Seed_Unit_Order_Confirmation_Controller.cls

	MOD DATE		Who						Description
	4/24/2014		Chris Noe				Initial Release
    9/3/2014        Chris Noe               Updates related to FB-00449 to properly set the bill to account on seed unit orders for hospitals.
    10/9/2014       Chris Noe               Updates related to FB-00368 and the implementation of new web service callouts for creating customers.
*/
@isTest
private class Seed_Unit_Order_Confirmation_Cntrl_Test {
    static testMethod void orderConfirmationSubmitApprovalRequiredTest() {
        //Tests the Seed_Unit_Order_Confirmation_Controller.orderConfirmationSubmit method

        //Create accounts for testing
        Account oAccountParent = Test_Environment_Utility.createInsertAccountUS();
        Account oAccountChild = Test_Environment_Utility.createInsertAccountUS();
        oAccountChild.ParentId=oAccountParent.Id;
        update oAccountChild;
        //Create contact for testing
        Contact oContact = Test_Environment_Utility.createInsertContact(oAccountChild);
        //Create customer account for testing
        //Customer_Account__c oCustomerAccount = Test_Environment_Utility.createInsertCustomerAccount(oAccountParent);
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccountChild, 'Seeding', Date.today());
        
        //Create user and manager and assign user as opportunity owner
        User oUser = Test_Environment_Utility.createInsertUser();
        User oManager = Test_Environment_Utility.createInsertUser();
        oUser.ManagerId=oManager.Id;
        oUser.Oracle_Salesrep_Id__c = String.valueOf(Test_Environment_Utility.getRandomInt(1, 99999));
        update oUser;
        oOpportunity.OwnerId=oUser.Id;
        update oOpportunity;
        
        //Create Integration Id for testing
        Integration_Id__c oIntegrationId = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetail = Test_Environment_Utility.createInsertWebServiceDetails('Create Customer');

        //Create seed unit orders for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Hospital', oAccountChild, oContact);
        oSeedUnitOrder.Salesrep__c = oUser.Id;
        update oSeedUnitOrder;

        //Create products for testing
        Product2 oProduct = Test_Environment_Utility.createInsertProduct();
        //Create seed unit products for testing
        Seed_Unit_Product__c oSeedUnitProduct = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProduct, 5); 
        
        Test.startTest();
            //Retrieve newly created Integration_Id__c and Seed_Unit_Order__c fields needed for HTTP response.
            oIntegrationId = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationId.Id];              
            
            //Query for seed unit order created above in order to retrieve formula field values
            oSeedUnitOrder = [select Id, Sold_To_Org_new__c, Opportunity__c, Opportunity__r.Account.ParentId, Opportunity__r.AccountId, Name, Seed_Unit_Order_Submitted__c, Seed_Unit_Approval_Status__c,
                                Opportunity__r.Account.BillingStreet, Opportunity__r.Account.BillingCity, Opportunity__r.Account.BillingStateCode, Opportunity__r.Account.BillingPostalCode, Ship_To_Country__c,
                                Opportunity__r.Account.BillingCountryCode, Seed_Unit_Location_Type__c, Opportunity__r.Account.Parent.ParentId, Opportunity__r.Account.Name, Ship_To_Org_Id__c,
                                Ship_To_Address4__c, Ship_To_Address3__c, Ship_To_Address2__c, Sold_To_Salesforce_Id__c, Opportunity__r.Account.Id, Sold_To_Party_Name__c, Ship_To_County__c, Ship_To_Address__c,
                                Ship_To_Address1__c, Ship_To_City__c, ORIG_SYS_DOCUMENT_REF__c, Sold_To_Party_Id__c, Sold_To_Org_Id__c, Ship_To_State_Province__c, Ship_To_Postal_Code__c, Ship_To_Contact_First_Name__c,
                                Ship_To_Contact_Last_Name__c, Ship_To_Contact_Email__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Role_Id__c, Ship_To_Account__r.Name, Ship_To_Salesforce_Id__c,
                                Ship_To_Customer_Account_Id__c, Ship_To_Party_Id__c, Ship_To_Party_Name__c, Ship_To_Contact__c
                                from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];

            //Set up response since web service callouts are not allowed from test classes
            SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(200,
                                                            'OK',
                '{'+
                '  \"__type\": \"RepLocator.Customer\",'+
                '  \"ip_verification_id\": \"' + oIntegrationId.Security_Id__c + '\",'+
                '  \"ip_party_id\": \"\",'+
                '  \"ip_cust_account_id\": \"\",'+
                '  \"ip_ship_to_site_use_id\": \"\",'+
                '  \"ip_organization_name\": \"TEST ACCOUNT\",'+
                '  \"ip_account_name\": \"DOMESTIC\",'+
                '  \"ip_address1\": \"16180 FLYING CLOUD DR\",'+
                '  \"ip_address2\": \"\",'+
                '  \"ip_address3\": \"\",'+
                '  \"ip_address4\": \"\",'+
                '  \"ip_city\": \"EDEN PRAIRIE\",'+
                '  \"ip_state\": \"MN\",'+
                '  \"ip_province\": \"\",'+
                '  \"ip_postal_code\": \"55347\",'+
                '  \"ip_country\": \"US\",'+
                '  \"ip_county\": \"\",'+
                '  \"ip_person_first_name\": \"CHRIS\",'+
                '  \"ip_person_last_name\": \"NOE\",'+
                '  \"ip_raw_phone_number\": \"9522231265\",'+
                '  \"ip_email_address\": \"CNOE@ERGOTRON.COM\",'+
                '  \"ip_is_bill_to_address\": \"Y\",'+
                '  \"ip_is_ship_to_address\": \"Y\",'+
                '  \"ip_salesforce_ref_id\": \"' + oSeedUnitOrder.Id + '\",'+
                '  \"op_party_id\": \"109872635\",'+
                '  \"op_party_number\": \"109872635\",'+
                '  \"op_cust_account_id\": \"\",'+
                '  \"op_ship_to_site_use_id\": \"626880\",'+
                '  \"op_bill_to_site_use_id\": \"626879\",'+
                '  \"op_ship_to_contact_id\": \"21046994\",'+
                '  \"op_cust_account_role_id\": \"19300031\",'+
                '  \"op_return_status\": \"\",'+
                '  \"op_return_message\": \"\"'+
                '}'
                 , null);
            Test.setMock(HttpCalloutMock.class, oFakeResponse);         

            /*BEGIN TEST: APPROVAL REQUIRED*/

            //Create PageReference to the SeedUnitOrderConfirmation
            PageReference oPageRef = Page.SeedUnitOrderConfirmation;
            Test.setCurrentPage(oPageRef);

            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            ApexPages.currentPage().getParameters().put('id',oSeedUnitOrder.id);
            Seed_Unit_Order_Confirmation_Controller oExtController = new Seed_Unit_Order_Confirmation_Controller(oStdController);
            
            //Assert approval required flag
            system.assertEquals(true,oExtController.bApprovalRequired);
            
            oPageRef = oExtController.orderConfirmationSubmit();
            //Assert PageReference returned by call above
            system.assertEquals('/apex/seedunitordersummary?id=' + oSeedUnitOrder.Id,oPageRef.getURL());
            
            //Assertions for buttons on the confirmation page (Edit Ship To and Edit Order Details)
            system.assertEquals('/apex/seedunitselectshipto?id=' + oSeedUnitOrder.Id,oExtController.selectShipTo().getURL());
            system.assertEquals('/' + oSeedUnitOrder.Id + '/e?retURL=%2F' + oSeedUnitOrder.Id,oExtController.editOrderDetails().getURL());          
        Test.stopTest();
    }

    static testMethod void orderConfirmationSubmitNoApprovalRequiredTest() {
        //Tests the Seed_Unit_Order_Confirmation_Controller.orderConfirmationSubmit method
        
        //Create accounts for testing
        Account oAccountParent = Test_Environment_Utility.createInsertAccountUS();
        Account oAccountChild = Test_Environment_Utility.createInsertAccountUS();
        oAccountChild.ParentId=oAccountParent.Id;
        update oAccountChild;
        //Create contact for testing
        Contact oContact = Test_Environment_Utility.createInsertContact(oAccountChild);
        //Create customer account for testing
        //Customer_Account__c oCustomerAccount = Test_Environment_Utility.createInsertCustomerAccount(oAccountParent);
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccountChild, 'Seeding', Date.today());
        
        //Create user and manager and assign user as opportunity owner
        User oUser = Test_Environment_Utility.createInsertUser();
        User oManager = Test_Environment_Utility.createInsertUser();
        oUser.ManagerId=oManager.Id;
        oUser.Oracle_Salesrep_Id__c = String.valueOf(Test_Environment_Utility.getRandomInt(1, 99999));
        update oUser;
        oOpportunity.OwnerId=oUser.Id;
        update oOpportunity;
        
        //Create Integration Id for testing
        Integration_Id__c oIntegrationId = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetail = Test_Environment_Utility.createInsertWebServiceDetails('Create Customer');

        //Create seed unit orders for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Hospital', oAccountChild, oContact);
        oSeedUnitOrder.Salesrep__c = oUser.Id;
        update oSeedUnitOrder;
        //Create products for testing
        Product2 oProductEligible = Test_Environment_Utility.createInsertProduct();
        oProductEligible.Seed_Unit_Eligible_Hospital__c=true;
        update oProductEligible;
        //Create seed unit products for testing
        Seed_Unit_Product__c oSeedUnitProductEligible = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProductEligible, 5);
        
        Test.startTest();
            //Retrieve newly created Integration_Id__c and Seed_Unit_Order__c fields needed for HTTP response.
            oIntegrationId = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationId.Id];              
            
            //Query for seed unit order created above in order to retrieve formula field values
            oSeedUnitOrder = [select Id, Sold_To_Org_new__c, Opportunity__c, Opportunity__r.Account.ParentId, Opportunity__r.AccountId, Name, Seed_Unit_Order_Submitted__c, Seed_Unit_Approval_Status__c,
                                Opportunity__r.Account.BillingStreet, Opportunity__r.Account.BillingCity, Opportunity__r.Account.BillingStateCode, Opportunity__r.Account.BillingPostalCode, Ship_To_Country__c,
                                Opportunity__r.Account.BillingCountryCode, Seed_Unit_Location_Type__c, Opportunity__r.Account.Parent.ParentId, Opportunity__r.Account.Name, Ship_To_Org_Id__c,
                                Ship_To_Address4__c, Ship_To_Address3__c, Ship_To_Address2__c, Sold_To_Salesforce_Id__c, Opportunity__r.Account.Id, Sold_To_Party_Name__c, Ship_To_County__c, Ship_To_Address__c,
                                Ship_To_Address1__c, Ship_To_City__c, ORIG_SYS_DOCUMENT_REF__c, Sold_To_Party_Id__c, Sold_To_Org_Id__c, Ship_To_State_Province__c, Ship_To_Postal_Code__c, Ship_To_Contact_First_Name__c,
                                Ship_To_Contact_Last_Name__c, Ship_To_Contact_Email__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Role_Id__c, Ship_To_Account__r.Name, Ship_To_Salesforce_Id__c,
                                Ship_To_Customer_Account_Id__c, Ship_To_Party_Id__c, Ship_To_Party_Name__c, Ship_To_Contact__c
                                from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];

            //Set up response since web service callouts are not allowed from test classes
            SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(200,
                                                            'OK',
                '{'+
                '  \"__type\": \"RepLocator.Customer\",'+
                '  \"ip_verification_id\": \"' + oIntegrationId.Security_Id__c + '\",'+
                '  \"ip_party_id\": \"\",'+
                '  \"ip_cust_account_id\": \"\",'+
                '  \"ip_ship_to_site_use_id\": \"\",'+
                '  \"ip_organization_name\": \"TEST ACCOUNT\",'+
                '  \"ip_account_name\": \"DOMESTIC\",'+
                '  \"ip_address1\": \"16180 FLYING CLOUD DR\",'+
                '  \"ip_address2\": \"\",'+
                '  \"ip_address3\": \"\",'+
                '  \"ip_address4\": \"\",'+
                '  \"ip_city\": \"EDEN PRAIRIE\",'+
                '  \"ip_state\": \"MN\",'+
                '  \"ip_province\": \"\",'+
                '  \"ip_postal_code\": \"55347\",'+
                '  \"ip_country\": \"US\",'+
                '  \"ip_county\": \"\",'+
                '  \"ip_person_first_name\": \"CHRIS\",'+
                '  \"ip_person_last_name\": \"NOE\",'+
                '  \"ip_raw_phone_number\": \"9522231265\",'+
                '  \"ip_email_address\": \"CNOE@ERGOTRON.COM\",'+
                '  \"ip_is_bill_to_address\": \"Y\",'+
                '  \"ip_is_ship_to_address\": \"Y\",'+
                '  \"ip_salesforce_ref_id\": \"' + oSeedUnitOrder.Id + '\",'+
                '  \"op_party_id\": \"109872635\",'+
                '  \"op_party_number\": \"109872635\",'+
                '  \"op_cust_account_id\": \"\",'+
                '  \"op_ship_to_site_use_id\": \"626880\",'+
                '  \"op_bill_to_site_use_id\": \"626879\",'+
                '  \"op_ship_to_contact_id\": \"21046994\",'+
                '  \"op_cust_account_role_id\": \"19300031\",'+
                '  \"op_return_status\": \"\",'+
                '  \"op_return_message\": \"\"'+
                '}'
                 , null);
            Test.setMock(HttpCalloutMock.class, oFakeResponse);  

            /*BEGIN TEST: NO APPROVAL REQUIRED*/
            
            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            Seed_Unit_Order_Confirmation_Controller oExtController = new Seed_Unit_Order_Confirmation_Controller(oStdController);
            
            //Assert approval required flag
            system.assertEquals(false,oExtController.bApprovalRequired);
            
            PageReference oPageRef = oExtController.orderConfirmationSubmit();
            //Assert PageReference returned by call above
            system.assertEquals('/apex/seedunitordersummary?id=' + oSeedUnitOrder.Id,oPageRef.getURL());                
        Test.stopTest();
    }

    static testMethod void orderConfirmationSubmitExistingCustomerAddressTest() {
        //Tests the Seed_Unit_Order_Confirmation_Controller.orderConfirmationSubmit method for existing customer.
        
        //Create accounts for testing
        Account oAccount = Test_Environment_Utility.createInsertAccountUS();
        oAccount.Oracle_Party_Id__c='ERGO' + String.valueOf(math.random()).left(20);
        update oAccount;
        //Create customer account for testing
        //Customer_Account__c oCustomerAccount = Test_Environment_Utility.createInsertCustomerAccount(oAccount);
        Account oCustomerAccount = Test_Environment_Utility.createInsertAccountUS();
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccount, 'Seeding', Date.today());
        
        //Create user and manager and assign user as opportunity owner
        User oUser = Test_Environment_Utility.createInsertUser();
        User oManager = Test_Environment_Utility.createInsertUser();
        oUser.ManagerId=oManager.Id;
        oUser.Oracle_Salesrep_Id__c = String.valueOf(Test_Environment_Utility.getRandomInt(1, 99999));
        update oUser;
        oOpportunity.OwnerId=oUser.Id;
        update oOpportunity;
        
        //Create Integration Id for testing
        Integration_Id__c oIntegrationId = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetail = Test_Environment_Utility.createInsertWebServiceDetails('Create Customer');

        //Create Contact for testing
        Contact oContact = Test_Environment_Utility.createInsertContact(oAccount);

        //Create seed unit orders for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Enterprise', oAccount, oContact);
        oSeedUnitOrder.Salesrep__c = oUser.Id;
        oSeedUnitOrder.Sold_To_Org_new__c = oCustomerAccount.Id;
        oSeedUnitOrder.Ship_To_Org_Id__c = String.valueOf(math.random()).left(20);
        oSeedUnitOrder.Ship_To_Contact__c = oContact.Id;
        update oSeedUnitOrder;
        //Create products for testing
        Product2 oProductEligible = Test_Environment_Utility.createInsertProduct();
        oProductEligible.Seed_Unit_Eligible_Enterprise__c=true;
        update oProductEligible;
        //Create seed unit products for testing
        Seed_Unit_Product__c oSeedUnitProductEligible = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProductEligible, 5);
        
        Test.startTest();
            //Retrieve newly created Account, Customer_Account__c, Seed_Unit_Order__c and Integration_Id__c fields needed for HTTP response.
            oIntegrationId = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationId.Id];              
            oAccount = [select Id, Oracle_Party_Id__c from Account where Id = :oAccount.Id];
            oCustomerAccount = [select Id, Customer_Account_Id__c from Account where Id = :oCustomerAccount.Id];
            
            //Query for seed unit order created above in order to retrieve formula field values
            oSeedUnitOrder = [select Id, Sold_To_Org_new__c, Opportunity__c, Opportunity__r.Account.ParentId, Opportunity__r.AccountId, Name, Seed_Unit_Order_Submitted__c, Seed_Unit_Approval_Status__c,
                                Opportunity__r.Account.BillingStreet, Opportunity__r.Account.BillingCity, Opportunity__r.Account.BillingStateCode, Opportunity__r.Account.BillingPostalCode, Ship_To_Country__c,
                                Opportunity__r.Account.BillingCountryCode, Seed_Unit_Location_Type__c, Opportunity__r.Account.Parent.ParentId, Opportunity__r.Account.Name, Ship_To_Org_Id__c,
                                Ship_To_Address4__c, Ship_To_Address3__c, Ship_To_Address2__c, Sold_To_Salesforce_Id__c, Opportunity__r.Account.Id, Sold_To_Party_Name__c, Ship_To_County__c, Ship_To_Address__c,
                                Ship_To_Address1__c, Ship_To_City__c, ORIG_SYS_DOCUMENT_REF__c, Sold_To_Party_Id__c, Sold_To_Org_Id__c, Ship_To_State_Province__c, Ship_To_Postal_Code__c, Ship_To_Contact_First_Name__c,
                                Ship_To_Contact_Last_Name__c, Ship_To_Contact_Email__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Role_Id__c, Ship_To_Account__r.Name, Ship_To_Salesforce_Id__c,
                                Ship_To_Customer_Account_Id__c, Ship_To_Party_Id__c, Ship_To_Party_Name__c, Ship_To_Contact__c
                                from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];

            //Set up response since web service callouts are not allowed from test classes
            SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(200,
                                                            'OK',
                '{'+
                '  \"__type\": \"RepLocator.Customer\",'+
                '  \"ip_verification_id\": \"' + oIntegrationId.Security_Id__c + '\",'+
                '  \"ip_party_id\": \"' + oAccount.Oracle_Party_Id__c + '\",'+
                '  \"ip_cust_account_id\": \"' + oCustomerAccount.Customer_Account_Id__c + '\",'+
                '  \"ip_ship_to_site_use_id\": \"' + oSeedUnitOrder.Ship_To_Org_Id__c + '\",'+
                '  \"ip_organization_name\": \"\",'+
                '  \"ip_account_name\": \"\",'+
                '  \"ip_address1\": \"\",'+
                '  \"ip_address2\": \"\",'+
                '  \"ip_address3\": \"\",'+
                '  \"ip_address4\": \"\",'+
                '  \"ip_city\": \"\",'+
                '  \"ip_state\": \"\",'+
                '  \"ip_province\": \"\",'+
                '  \"ip_postal_code\": \"\",'+
                '  \"ip_country\": \"\",'+
                '  \"ip_county\": \"\",'+
                '  \"ip_person_first_name\": \"CHRIS\",'+
                '  \"ip_person_last_name\": \"NOE\",'+
                '  \"ip_raw_phone_number\": \"9522231265\",'+
                '  \"ip_email_address\": \"CNOE@ERGOTRON.COM\",'+
                '  \"ip_is_bill_to_address\": \"\",'+
                '  \"ip_is_ship_to_address\": \"\",'+
                '  \"ip_salesforce_ref_id\": \"' + oSeedUnitOrder.Id + '\",'+
                '  \"op_party_id\": \"' + oAccount.Oracle_Party_Id__c + '\",'+
                '  \"op_party_number\": \"\",'+
                '  \"op_cust_account_id\": \"' + oCustomerAccount.Customer_Account_Id__c + '\",'+
                '  \"op_ship_to_site_use_id\": \"' + oSeedUnitOrder.Ship_To_Org_Id__c + '\",'+
                '  \"op_bill_to_site_use_id\": \"\",'+
                '  \"op_ship_to_contact_id\": \"21046994\",'+
                '  \"op_cust_account_role_id\": \"19300031\",'+
                '  \"op_return_status\": \"\",'+
                '  \"op_return_message\": \"\"'+
                '}'
                 , null);
            Test.setMock(HttpCalloutMock.class, oFakeResponse);

            /*BEGIN TEST: Existing customer and address*/
            
            //Create PageReference to the SeedUnitOrderConfirmation
            PageReference oPageRef = Page.SeedUnitOrderConfirmation;
            Test.setCurrentPage(oPageRef);

            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            ApexPages.currentPage().getParameters().put('id',oSeedUnitOrder.id);
            Seed_Unit_Order_Confirmation_Controller oExtController = new Seed_Unit_Order_Confirmation_Controller(oStdController);
            
            oPageRef = oExtController.orderConfirmationSubmit();
            
            oSeedUnitOrder = [select Id, Ship_To_Contact_Role_Id__c from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];
            //Assert PageReference returned by call above
            system.assertEquals('/apex/seedunitordersummary?id=' + oSeedUnitOrder.Id,oPageRef.getURL());  
            //Assert the Ship To Contact Role Id
            system.assertEquals('19300031',oSeedUnitOrder.Ship_To_Contact_Role_Id__c);                          
        Test.stopTest();
    }

    static testMethod void orderConfirmationSubmitExistingCustomerNewAddressTest() {
        //Tests the Seed_Unit_Order_Confirmation_Controller.orderConfirmationSubmit method for existing customer with new address.
        
        //Create accounts for testing
        Account oAccount = Test_Environment_Utility.createInsertAccountUS();
        oAccount.Oracle_Party_Id__c='ERGO' + String.valueOf(math.random()).left(20);
        update oAccount;
        //Create customer account for testing
        //Customer_Account__c oCustomerAccount = Test_Environment_Utility.createInsertCustomerAccount(oAccount);
        Account oCustomerAccount = Test_Environment_Utility.createInsertAccountUS();
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccount, 'Seeding', Date.today());
        
        //Create user and manager and assign user as opportunity owner
        User oUser = Test_Environment_Utility.createInsertUser();
        User oManager = Test_Environment_Utility.createInsertUser();
        oUser.ManagerId=oManager.Id;
        oUser.Oracle_Salesrep_Id__c = String.valueOf(Test_Environment_Utility.getRandomInt(1, 99999));
        update oUser;
        oOpportunity.OwnerId=oUser.Id;
        update oOpportunity;
        
        //Create Integration Id for testing
        Integration_Id__c oIntegrationId = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetail = Test_Environment_Utility.createInsertWebServiceDetails('Create Customer');

        //Create Contact for testing
        Contact oContact = Test_Environment_Utility.createInsertContact(oAccount);

        //Create seed unit orders for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Enterprise', oAccount, oContact);
        oSeedUnitOrder.Salesrep__c = oUser.Id;
        oSeedUnitOrder.Sold_To_Org_new__c = oCustomerAccount.Id;
        oSeedUnitOrder.Ship_To_Contact__c = oContact.Id;
        oSeedUnitOrder.Ship_To_Address1__c = 'Test Address1';
        oSeedUnitOrder.Ship_To_Address2__c = 'Test Address2';
        oSeedUnitOrder.Ship_To_Address3__c = 'Test Address3';
        oSeedUnitOrder.Ship_To_Address4__c = 'Test Address4';
        oSeedUnitOrder.Ship_To_City__c = 'SAINT LOUIS';
        oSeedUnitOrder.Ship_To_State_Province__c = 'MO';
        oSeedUnitOrder.Ship_To_Postal_Code__c = '63124';
        oSeedUnitOrder.Ship_To_Country__c = 'United States-US';
        oSeedUnitOrder.Ship_To_County__c = 'SAINT LOUIS';
        update oSeedUnitOrder;
        //Create products for testing
        Product2 oProductEligible = Test_Environment_Utility.createInsertProduct();
        oProductEligible.Seed_Unit_Eligible_Enterprise__c=true;
        update oProductEligible;
        //Create seed unit products for testing
        Seed_Unit_Product__c oSeedUnitProductEligible = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProductEligible, 5);
        
        Test.startTest();
            //Retrieve newly created Account, Customer_Account__c, Seed_Unit_Order__c and Integration_Id__c fields needed for HTTP response.
            oIntegrationId = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationId.Id];              
            oAccount = [select Id, Oracle_Party_Id__c from Account where Id = :oAccount.Id];
            oCustomerAccount = [select Id, Customer_Account_Id__c from Account where Id = :oCustomerAccount.Id];
            
            //Query for seed unit order created above in order to retrieve formula field values
            oSeedUnitOrder = [select Id, Sold_To_Org_new__c, Opportunity__c, Opportunity__r.Account.ParentId, Opportunity__r.AccountId, Name, Seed_Unit_Order_Submitted__c, Seed_Unit_Approval_Status__c,
                                Opportunity__r.Account.BillingStreet, Opportunity__r.Account.BillingCity, Opportunity__r.Account.BillingStateCode, Opportunity__r.Account.BillingPostalCode, Ship_To_Country__c,
                                Opportunity__r.Account.BillingCountryCode, Seed_Unit_Location_Type__c, Opportunity__r.Account.Parent.ParentId, Opportunity__r.Account.Name, Ship_To_Org_Id__c,
                                Ship_To_Address4__c, Ship_To_Address3__c, Ship_To_Address2__c, Sold_To_Salesforce_Id__c, Opportunity__r.Account.Id, Sold_To_Party_Name__c, Ship_To_County__c, Ship_To_Address__c,
                                Ship_To_Address1__c, Ship_To_City__c, ORIG_SYS_DOCUMENT_REF__c, Sold_To_Party_Id__c, Sold_To_Org_Id__c, Ship_To_State_Province__c, Ship_To_Postal_Code__c, Ship_To_Contact_First_Name__c,
                                Ship_To_Contact_Last_Name__c, Ship_To_Contact_Email__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Role_Id__c, Ship_To_Account__r.Name, Ship_To_Salesforce_Id__c,
                                Ship_To_Customer_Account_Id__c, Ship_To_Party_Id__c, Ship_To_Party_Name__c, Ship_To_Contact__c
                                from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];

            //Set up response since web service callouts are not allowed from test classes
            SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(200,
                                                            'OK',
                '{'+
                '  \"__type\": \"RepLocator.Customer\",'+
                '  \"ip_verification_id\": \"' + oIntegrationId.Security_Id__c + '\",'+
                '  \"ip_party_id\": \"' + oAccount.Oracle_Party_Id__c + '\",'+
                '  \"ip_cust_account_id\": \"' + oCustomerAccount.Customer_Account_Id__c + '\",'+
                '  \"ip_ship_to_site_use_id\": \"\",'+
                '  \"ip_organization_name\": \"\",'+
                '  \"ip_account_name\": \"\",'+
                '  \"ip_address1\": \"' + oSeedUnitOrder.Ship_To_Address1__c + '\",'+
                '  \"ip_address2\": \"' + oSeedUnitOrder.Ship_To_Address2__c + '\",'+
                '  \"ip_address3\": \"' + oSeedUnitOrder.Ship_To_Address3__c + '\",'+
                '  \"ip_address4\": \"' + oSeedUnitOrder.Ship_To_Address4__c + '\",'+
                '  \"ip_city\": \"' + oSeedUnitOrder.Ship_To_City__c + '\",'+
                '  \"ip_state\": \"' + oSeedUnitOrder.Ship_To_State_Province__c + '\",'+
                '  \"ip_province\": \"\",'+
                '  \"ip_postal_code\": \"' + oSeedUnitOrder.Ship_To_Postal_Code__c + '\",'+
                '  \"ip_country\": \"' + oSeedUnitOrder.Ship_To_Country__c + '\",'+
                '  \"ip_county\": \"' + oSeedUnitOrder.Ship_To_County__c + '\",'+
                '  \"ip_person_first_name\": \"CHRIS\",'+
                '  \"ip_person_last_name\": \"NOE\",'+
                '  \"ip_raw_phone_number\": \"9522231265\",'+
                '  \"ip_email_address\": \"CNOE@ERGOTRON.COM\",'+
                '  \"ip_is_bill_to_address\": \"\",'+
                '  \"ip_is_ship_to_address\": \"Y\",'+
                '  \"ip_salesforce_ref_id\": \"' + oSeedUnitOrder.Id + '\",'+
                '  \"op_party_id\": \"' + oAccount.Oracle_Party_Id__c + '\",'+
                '  \"op_party_number\": \"\",'+
                '  \"op_cust_account_id\": \"' + oCustomerAccount.Customer_Account_Id__c + '\",'+
                '  \"op_ship_to_site_use_id\": \"19099009\",'+
                '  \"op_bill_to_site_use_id\": \"\",'+
                '  \"op_ship_to_contact_id\": \"21046994\",'+
                '  \"op_cust_account_role_id\": \"19300030\",'+
                '  \"op_return_status\": \"\",'+
                '  \"op_return_message\": \"\"'+
                '}'
                 , null);
            Test.setMock(HttpCalloutMock.class, oFakeResponse); 

            /*BEGIN TEST: Existing Customer, new address*/
            
            //Create PageReference to the SeedUnitOrderConfirmation
            PageReference oPageRef = Page.SeedUnitOrderConfirmation;
            Test.setCurrentPage(oPageRef);

            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            ApexPages.currentPage().getParameters().put('id',oSeedUnitOrder.id);
            Seed_Unit_Order_Confirmation_Controller oExtController = new Seed_Unit_Order_Confirmation_Controller(oStdController);
            
            oPageRef = oExtController.orderConfirmationSubmit();
            
            oSeedUnitOrder = [select Id, Ship_To_Org_Id__c, Ship_To_Contact_Role_Id__c from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];
            //Assert PageReference returned by call above
            system.assertEquals('/apex/seedunitordersummary?id=' + oSeedUnitOrder.Id,oPageRef.getURL());  
            //Assert the Ship To Contact Role Id
            system.assertEquals('19300030',oSeedUnitOrder.Ship_To_Contact_Role_Id__c);   
            //Assert the Ship To Org Id
            system.assertEquals('19099009',oSeedUnitOrder.Ship_To_Org_Id__c);              
        Test.stopTest();
    }  

    static testMethod void orderConfirmationSubmitNewCustomerNewAddressCanadaTest() {
        //Tests the Seed_Unit_Order_Confirmation_Controller.orderConfirmationSubmit method for new Canadian customer and address.
        
        //Create accounts for testing
        Account oAccount = Test_Environment_Utility.createInsertAccountCA();
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccount, 'Seeding', Date.today());
        
        //Create user and manager and assign user as opportunity owner
        User oUser = Test_Environment_Utility.createInsertUser();
        User oManager = Test_Environment_Utility.createInsertUser();
        oUser.ManagerId=oManager.Id;
        oUser.Oracle_Salesrep_Id__c = String.valueOf(Test_Environment_Utility.getRandomInt(1, 99999));
        update oUser;
        oOpportunity.OwnerId=oUser.Id;
        update oOpportunity;
        
        //Create Integration Id for testing
        Integration_Id__c oIntegrationId = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetail = Test_Environment_Utility.createInsertWebServiceDetails('Create Customer');

        //Create Contact for testing
        Contact oContact = Test_Environment_Utility.createInsertContact(oAccount);

        //Create seed unit orders for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Enterprise', oAccount, oContact);
        oSeedUnitOrder.Salesrep__c = oUser.Id;
        oSeedUnitOrder.Ship_To_Contact__c = oContact.Id;
        oSeedUnitOrder.Ship_To_Address1__c = 'Test Address1';
        oSeedUnitOrder.Ship_To_Address2__c = 'Test Address2';
        oSeedUnitOrder.Ship_To_Address3__c = 'Test Address3';
        oSeedUnitOrder.Ship_To_Address4__c = 'Test Address4';
        oSeedUnitOrder.Ship_To_City__c = 'Test City';
        oSeedUnitOrder.Ship_To_State_Province__c = 'BC';
        oSeedUnitOrder.Ship_To_Postal_Code__c = 'X9H 4YN';
        oSeedUnitOrder.Ship_To_Country__c = 'Canada-CA';
        update oSeedUnitOrder;
        //Create products for testing
        Product2 oProductEligible = Test_Environment_Utility.createInsertProduct();
        oProductEligible.Seed_Unit_Eligible_Enterprise__c=true;
        update oProductEligible;
        //Create seed unit products for testing
        Seed_Unit_Product__c oSeedUnitProductEligible = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProductEligible, 5);
        
        Test.startTest();
            //Retrieve newly created Account, Customer_Account__c, Seed_Unit_Order__c and Integration_Id__c fields needed for HTTP response.
            oIntegrationId = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationId.Id];              
            oAccount = [select Id, Name from Account where Id = :oAccount.Id];
            
            //Query for seed unit order created above in order to retrieve formula field values
            oSeedUnitOrder = [select Id, Sold_To_Org_new__c, Opportunity__c, Opportunity__r.Account.ParentId, Opportunity__r.AccountId, Name, Seed_Unit_Order_Submitted__c, Seed_Unit_Approval_Status__c,
                                Opportunity__r.Account.BillingStreet, Opportunity__r.Account.BillingCity, Opportunity__r.Account.BillingStateCode, Opportunity__r.Account.BillingPostalCode, Ship_To_Country__c,
                                Opportunity__r.Account.BillingCountryCode, Seed_Unit_Location_Type__c, Opportunity__r.Account.Parent.ParentId, Opportunity__r.Account.Name, Ship_To_Org_Id__c,
                                Ship_To_Address4__c, Ship_To_Address3__c, Ship_To_Address2__c, Sold_To_Salesforce_Id__c, Opportunity__r.Account.Id, Sold_To_Party_Name__c, Ship_To_County__c, Ship_To_Address__c,
                                Ship_To_Address1__c, Ship_To_City__c, ORIG_SYS_DOCUMENT_REF__c, Sold_To_Party_Id__c, Sold_To_Org_Id__c, Ship_To_State_Province__c, Ship_To_Postal_Code__c, Ship_To_Contact_First_Name__c,
                                Ship_To_Contact_Last_Name__c, Ship_To_Contact_Email__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Role_Id__c, Ship_To_Account__r.Name, Ship_To_Salesforce_Id__c,
                                Ship_To_Customer_Account_Id__c, Ship_To_Party_Id__c, Ship_To_Party_Name__c, Ship_To_Contact__c
                                from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];

            //Set up response since web service callouts are not allowed from test classes
            SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(200,
                                                            'OK',
                '{'+
                '  \"__type\": \"RepLocator.Customer\",'+
                '  \"ip_verification_id\": \"' + oIntegrationId.Security_Id__c + '\",'+
                '  \"ip_party_id\": \"\",'+
                '  \"ip_cust_account_id\": \"\",'+
                '  \"ip_ship_to_site_use_id\": \"\",'+
                '  \"ip_organization_name\": \"' + oAccount.Name + '\",'+
                '  \"ip_account_name\": \"CANADA\",'+
                '  \"ip_address1\": \"' + oSeedUnitOrder.Ship_To_Address1__c + '\",'+
                '  \"ip_address2\": \"' + oSeedUnitOrder.Ship_To_Address2__c + '\",'+
                '  \"ip_address3\": \"' + oSeedUnitOrder.Ship_To_Address3__c + '\",'+
                '  \"ip_address4\": \"' + oSeedUnitOrder.Ship_To_Address4__c + '\",'+
                '  \"ip_city\": \"' + oSeedUnitOrder.Ship_To_City__c + '\",'+
                '  \"ip_state\": \"' + oSeedUnitOrder.Ship_To_Country__c + '\",'+
                '  \"ip_province\": \"' + oSeedUnitOrder.Ship_To_State_Province__c + '\",'+
                '  \"ip_postal_code\": \"' + oSeedUnitOrder.Ship_To_Postal_Code__c + '\",'+
                '  \"ip_country\": \"' + oSeedUnitOrder.Ship_To_Country__c + '\",'+
                '  \"ip_county\": \"\",'+
                '  \"ip_person_first_name\": \"CHRIS\",'+
                '  \"ip_person_last_name\": \"NOE\",'+
                '  \"ip_raw_phone_number\": \"9522231265\",'+
                '  \"ip_email_address\": \"CNOE@ERGOTRON.COM\",'+
                '  \"ip_is_bill_to_address\": \"\",'+
                '  \"ip_is_ship_to_address\": \"Y\",'+
                '  \"ip_salesforce_ref_id\": \"' + oSeedUnitOrder.Id + '\",'+
                '  \"op_party_id\": \"187267221\",'+
                '  \"op_party_number\": \"\",'+
                '  \"op_cust_account_id\": \"16762542\",'+
                '  \"op_ship_to_site_use_id\": \"19099009\",'+
                '  \"op_bill_to_site_use_id\": \"\",'+
                '  \"op_ship_to_contact_id\": \"21046994\",'+
                '  \"op_cust_account_role_id\": \"19300030\",'+
                '  \"op_return_status\": \"\",'+
                '  \"op_return_message\": \"\"'+
                '}'
                 , null);
            Test.setMock(HttpCalloutMock.class, oFakeResponse); 

            /*BEGIN TEST: New Canadian customer and address*/
            
            //Create PageReference to the SeedUnitOrderConfirmation
            PageReference oPageRef = Page.SeedUnitOrderConfirmation;
            Test.setCurrentPage(oPageRef);

            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            ApexPages.currentPage().getParameters().put('id',oSeedUnitOrder.id);
            Seed_Unit_Order_Confirmation_Controller oExtController = new Seed_Unit_Order_Confirmation_Controller(oStdController);
            
            oPageRef = oExtController.orderConfirmationSubmit();
            
            oSeedUnitOrder = [select Id, Ship_To_Org_Id__c, Ship_To_Contact_Role_Id__c, Sold_To_Org_Id__c from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];
            //Assert PageReference returned by call above
            system.assertEquals('/apex/seedunitordersummary?id=' + oSeedUnitOrder.Id,oPageRef.getURL());  
            //Assert the Ship To Contact Role Id
            system.assertEquals('19300030',oSeedUnitOrder.Ship_To_Contact_Role_Id__c);   
            //Assert the Ship To Org Id
            system.assertEquals('19099009',oSeedUnitOrder.Ship_To_Org_Id__c);     
            //Assert the Sold To Org Id
            system.assertEquals('16762542',oSeedUnitOrder.Sold_To_Org_Id__c);         
        Test.stopTest();
    } 

    static testMethod void orderConfirmationSubmitNewCustomerNewAddressNonUSCATest() {
        //Tests the Seed_Unit_Order_Confirmation_Controller.orderConfirmationSubmit method for existing new non-US/CA customer and address.
        
        //Create accounts for testing
        Account oAccount = Test_Environment_Utility.createInsertAccountCA();
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccount, 'Seeding', Date.today());
        
        //Create user and manager and assign user as opportunity owner
        User oUser = Test_Environment_Utility.createInsertUser();
        User oManager = Test_Environment_Utility.createInsertUser();
        oUser.ManagerId=oManager.Id;
        oUser.Oracle_Salesrep_Id__c = String.valueOf(Test_Environment_Utility.getRandomInt(1, 99999));
        update oUser;
        oOpportunity.OwnerId=oUser.Id;
        update oOpportunity;
        
        //Create Integration Id for testing
        Integration_Id__c oIntegrationId = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetail = Test_Environment_Utility.createInsertWebServiceDetails('Create Customer');

        //Create Contact for testing
        Contact oContact = Test_Environment_Utility.createInsertContact(oAccount);

        //Create seed unit orders for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Enterprise', oAccount, oContact);
        oSeedUnitOrder.Salesrep__c = oUser.Id;
        oSeedUnitOrder.Ship_To_Contact__c = oContact.Id;
        oSeedUnitOrder.Ship_To_Address1__c = 'Test Address1';
        oSeedUnitOrder.Ship_To_Address2__c = 'Test Address2';
        oSeedUnitOrder.Ship_To_Address3__c = 'Test Address3';
        oSeedUnitOrder.Ship_To_Address4__c = 'Test Address4';
        oSeedUnitOrder.Ship_To_City__c = 'Test City';
        oSeedUnitOrder.Ship_To_State_Province__c = '';
        oSeedUnitOrder.Ship_To_Postal_Code__c = 'TEST ZIP';
        oSeedUnitOrder.Ship_To_Country__c = 'FR';
        update oSeedUnitOrder;
        //Create products for testing
        Product2 oProductEligible = Test_Environment_Utility.createInsertProduct();
        oProductEligible.Seed_Unit_Eligible_Enterprise__c=true;
        update oProductEligible;
        //Create seed unit products for testing
        Seed_Unit_Product__c oSeedUnitProductEligible = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProductEligible, 5);
        
        Test.startTest();
            //Retrieve newly created Account, Customer_Account__c, Seed_Unit_Order__c and Integration_Id__c fields needed for HTTP response.
            oIntegrationId = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationId.Id];              
            oAccount = [select Id, Name from Account where Id = :oAccount.Id];
            
            //Query for seed unit order created above in order to retrieve formula field values
            oSeedUnitOrder = [select Id, Sold_To_Org_new__c, Opportunity__c, Opportunity__r.Account.ParentId, Opportunity__r.AccountId, Name, Seed_Unit_Order_Submitted__c, Seed_Unit_Approval_Status__c,
                                Opportunity__r.Account.BillingStreet, Opportunity__r.Account.BillingCity, Opportunity__r.Account.BillingStateCode, Opportunity__r.Account.BillingPostalCode, Ship_To_Country__c,
                                Opportunity__r.Account.BillingCountryCode, Seed_Unit_Location_Type__c, Opportunity__r.Account.Parent.ParentId, Opportunity__r.Account.Name, Ship_To_Org_Id__c,
                                Ship_To_Address4__c, Ship_To_Address3__c, Ship_To_Address2__c, Sold_To_Salesforce_Id__c, Opportunity__r.Account.Id, Sold_To_Party_Name__c, Ship_To_County__c, Ship_To_Address__c,
                                Ship_To_Address1__c, Ship_To_City__c, ORIG_SYS_DOCUMENT_REF__c, Sold_To_Party_Id__c, Sold_To_Org_Id__c, Ship_To_State_Province__c, Ship_To_Postal_Code__c, Ship_To_Contact_First_Name__c,
                                Ship_To_Contact_Last_Name__c, Ship_To_Contact_Email__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Role_Id__c, Ship_To_Account__r.Name, Ship_To_Salesforce_Id__c,
                                Ship_To_Customer_Account_Id__c, Ship_To_Party_Id__c, Ship_To_Party_Name__c, Ship_To_Contact__c
                                from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];

            //Set up response since web service callouts are not allowed from test classes
            SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(200,
                                                            'OK',
                '{'+
                '  \"__type\": \"RepLocator.Customer\",'+
                '  \"ip_verification_id\": \"' + oIntegrationId.Security_Id__c + '\",'+
                '  \"ip_party_id\": \"\",'+
                '  \"ip_cust_account_id\": \"\",'+
                '  \"ip_ship_to_site_use_id\": \"\",'+
                '  \"ip_organization_name\": \"' + oAccount.Name + '\",'+
                '  \"ip_account_name\": \"CANADA\",'+
                '  \"ip_address1\": \"' + oSeedUnitOrder.Ship_To_Address1__c + '\",'+
                '  \"ip_address2\": \"' + oSeedUnitOrder.Ship_To_Address2__c + '\",'+
                '  \"ip_address3\": \"' + oSeedUnitOrder.Ship_To_Address3__c + '\",'+
                '  \"ip_address4\": \"' + oSeedUnitOrder.Ship_To_Address4__c + '\",'+
                '  \"ip_city\": \"' + oSeedUnitOrder.Ship_To_City__c + '\",'+
                '  \"ip_state\": \"\",'+
                '  \"ip_province\": \"\",'+
                '  \"ip_postal_code\": \"' + oSeedUnitOrder.Ship_To_Postal_Code__c + '\",'+
                '  \"ip_country\": \"' + oSeedUnitOrder.Ship_To_Country__c + '\",'+
                '  \"ip_county\": \"\",'+
                '  \"ip_person_first_name\": \"CHRIS\",'+
                '  \"ip_person_last_name\": \"NOE\",'+
                '  \"ip_raw_phone_number\": \"9522231265\",'+
                '  \"ip_email_address\": \"CNOE@ERGOTRON.COM\",'+
                '  \"ip_is_bill_to_address\": \"\",'+
                '  \"ip_is_ship_to_address\": \"Y\",'+
                '  \"ip_salesforce_ref_id\": \"' + oSeedUnitOrder.Id + '\",'+
                '  \"op_party_id\": \"187267221\",'+
                '  \"op_party_number\": \"\",'+
                '  \"op_cust_account_id\": \"16762542\",'+
                '  \"op_ship_to_site_use_id\": \"19099009\",'+
                '  \"op_bill_to_site_use_id\": \"\",'+
                '  \"op_ship_to_contact_id\": \"21046994\",'+
                '  \"op_cust_account_role_id\": \"19300030\",'+
                '  \"op_return_status\": \"\",'+
                '  \"op_return_message\": \"\"'+
                '}'
                 , null);
            Test.setMock(HttpCalloutMock.class, oFakeResponse); 

            /*BEGIN TEST: New customer/address non US/CA*/
            
            //Create PageReference to the SeedUnitOrderConfirmation
            PageReference oPageRef = Page.SeedUnitOrderConfirmation;
            Test.setCurrentPage(oPageRef);

            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            ApexPages.currentPage().getParameters().put('id',oSeedUnitOrder.id);
            Seed_Unit_Order_Confirmation_Controller oExtController = new Seed_Unit_Order_Confirmation_Controller(oStdController);
            
            oPageRef = oExtController.orderConfirmationSubmit();
            
            oSeedUnitOrder = [select Id, Ship_To_Org_Id__c, Ship_To_Contact_Role_Id__c, Sold_To_Org_Id__c from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];
            //Assert PageReference returned by call above
            system.assertEquals('/apex/seedunitordersummary?id=' + oSeedUnitOrder.Id,oPageRef.getURL());  
            //Assert the Ship To Contact Role Id
            system.assertEquals('19300030',oSeedUnitOrder.Ship_To_Contact_Role_Id__c);   
            //Assert the Ship To Org Id
            system.assertEquals('19099009',oSeedUnitOrder.Ship_To_Org_Id__c);     
            //Assert the Sold To Org Id
            system.assertEquals('16762542',oSeedUnitOrder.Sold_To_Org_Id__c);                
        Test.stopTest();
    }  

    static testMethod void orderConfirmationSubmitWSCalloutException() {
        //Tests the Seed_Unit_Order_Confirmation_Controller.orderConfirmationSubmit method for a web service callout exception
        
        //Create accounts for testing
        Account oAccount = Test_Environment_Utility.createInsertAccountCA();
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccount, 'Seeding', Date.today());
        
        //Create user and manager and assign user as opportunity owner
        User oUser = Test_Environment_Utility.createInsertUser();
        User oManager = Test_Environment_Utility.createInsertUser();
        oUser.ManagerId=oManager.Id;
        oUser.Oracle_Salesrep_Id__c = String.valueOf(Test_Environment_Utility.getRandomInt(1, 99999));
        update oUser;
        oOpportunity.OwnerId=oUser.Id;
        update oOpportunity;
        
        //Create Integration Id for testing
        Integration_Id__c oIntegrationId = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetail = Test_Environment_Utility.createInsertWebServiceDetails('Create Customer');

        //Create Contact for testing
        Contact oContact = Test_Environment_Utility.createInsertContact(oAccount);

        //Create seed unit orders for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Enterprise', oAccount, oContact);
        oSeedUnitOrder.Salesrep__c = oUser.Id;
        oSeedUnitOrder.Ship_To_Contact__c = oContact.Id;
        oSeedUnitOrder.Ship_To_Address1__c = 'Test Address1';
        oSeedUnitOrder.Ship_To_Address2__c = 'Test Address2';
        oSeedUnitOrder.Ship_To_Address3__c = 'Test Address3';
        oSeedUnitOrder.Ship_To_Address4__c = 'Test Address4';
        oSeedUnitOrder.Ship_To_City__c = 'Test City';
        oSeedUnitOrder.Ship_To_State_Province__c = '';
        oSeedUnitOrder.Ship_To_Postal_Code__c = 'TEST ZIP';
        oSeedUnitOrder.Ship_To_Country__c = 'FR';
        update oSeedUnitOrder;
        //Create products for testing
        Product2 oProductEligible = Test_Environment_Utility.createInsertProduct();
        oProductEligible.Seed_Unit_Eligible_Enterprise__c=true;
        update oProductEligible;
        //Create seed unit products for testing
        Seed_Unit_Product__c oSeedUnitProductEligible = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProductEligible, 5);
        
        Test.startTest();
            //Retrieve newly created Account, Customer_Account__c, Seed_Unit_Order__c and Integration_Id__c fields needed for HTTP response.
            oIntegrationId = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationId.Id];              
            oAccount = [select Id, Name from Account where Id = :oAccount.Id];
            
            //Query for seed unit order created above in order to retrieve formula field values
            oSeedUnitOrder = [select Id, Sold_To_Org_new__c, Opportunity__c, Opportunity__r.Account.ParentId, Opportunity__r.AccountId, Name, Seed_Unit_Order_Submitted__c, Seed_Unit_Approval_Status__c,
                                Opportunity__r.Account.BillingStreet, Opportunity__r.Account.BillingCity, Opportunity__r.Account.BillingStateCode, Opportunity__r.Account.BillingPostalCode, Ship_To_Country__c,
                                Opportunity__r.Account.BillingCountryCode, Seed_Unit_Location_Type__c, Opportunity__r.Account.Parent.ParentId, Opportunity__r.Account.Name, Ship_To_Org_Id__c,
                                Ship_To_Address4__c, Ship_To_Address3__c, Ship_To_Address2__c, Sold_To_Salesforce_Id__c, Opportunity__r.Account.Id, Sold_To_Party_Name__c, Ship_To_County__c, Ship_To_Address__c,
                                Ship_To_Address1__c, Ship_To_City__c, ORIG_SYS_DOCUMENT_REF__c, Sold_To_Party_Id__c, Sold_To_Org_Id__c, Ship_To_State_Province__c, Ship_To_Postal_Code__c, Ship_To_Contact_First_Name__c,
                                Ship_To_Contact_Last_Name__c, Ship_To_Contact_Email__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Role_Id__c, Ship_To_Account__r.Name, Ship_To_Salesforce_Id__c,
                                Ship_To_Customer_Account_Id__c, Ship_To_Party_Id__c, Ship_To_Party_Name__c, Ship_To_Contact__c
                                from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];

            //Set up response since web service callouts are not allowed from test classes - this is a bad JSON format that includes '//' at the beginning of the string
            //which will trigger the callout exception logic.
            SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(200,
                                                            'OK',
                '//{'+
                '  \"__type\": \"RepLocator.Customer\",'+
                '  \"ip_verification_id\": \"' + oIntegrationId.Security_Id__c + '\",'+
                '  \"ip_party_id\": \"\",'+
                '  \"ip_cust_account_id\": \"\",'+
                '  \"ip_ship_to_site_use_id\": \"\",'+
                '  \"ip_organization_name\": \"' + oAccount.Name + '\",'+
                '  \"ip_account_name\": \"CANADA\",'+
                '  \"ip_address1\": \"' + oSeedUnitOrder.Ship_To_Address1__c + '\",'+
                '  \"ip_address2\": \"' + oSeedUnitOrder.Ship_To_Address2__c + '\",'+
                '  \"ip_address3\": \"' + oSeedUnitOrder.Ship_To_Address3__c + '\",'+
                '  \"ip_address4\": \"' + oSeedUnitOrder.Ship_To_Address4__c + '\",'+
                '  \"ip_city\": \"' + oSeedUnitOrder.Ship_To_City__c + '\",'+
                '  \"ip_state\": \"\",'+
                '  \"ip_province\": \"\",'+
                '  \"ip_postal_code\": \"' + oSeedUnitOrder.Ship_To_Postal_Code__c + '\",'+
                '  \"ip_country\": \"' + oSeedUnitOrder.Ship_To_Country__c + '\",'+
                '  \"ip_county\": \"\",'+
                '  \"ip_person_first_name\": \"CHRIS\",'+
                '  \"ip_person_last_name\": \"NOE\",'+
                '  \"ip_raw_phone_number\": \"9522231265\",'+
                '  \"ip_email_address\": \"CNOE@ERGOTRON.COM\",'+
                '  \"ip_is_bill_to_address\": \"\",'+
                '  \"ip_is_ship_to_address\": \"Y\",'+
                '  \"ip_salesforce_ref_id\": \"' + oSeedUnitOrder.Id + '\",'+
                '  \"op_party_id\": \"187267221\",'+
                '  \"op_party_number\": \"\",'+
                '  \"op_cust_account_id\": \"16762542\",'+
                '  \"op_ship_to_site_use_id\": \"19099009\",'+
                '  \"op_bill_to_site_use_id\": \"\",'+
                '  \"op_ship_to_contact_id\": \"21046994\",'+
                '  \"op_cust_account_role_id\": \"19300030\",'+
                '  \"op_return_status\": \"\",'+
                '  \"op_return_message\": \"\"'+
                '}'
                 , null);
            Test.setMock(HttpCalloutMock.class, oFakeResponse); 

            /*BEGIN TEST: Web service callout exception*/
            
            //Create PageReference to the SeedUnitOrderConfirmation
            PageReference oPageRef = Page.SeedUnitOrderConfirmation;
            Test.setCurrentPage(oPageRef);

            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            ApexPages.currentPage().getParameters().put('id',oSeedUnitOrder.id);
            Seed_Unit_Order_Confirmation_Controller oExtController = new Seed_Unit_Order_Confirmation_Controller(oStdController);
            
            oPageRef = oExtController.orderConfirmationSubmit();   
            //Assert null return for page ref
            system.assertEquals(null,oPageRef);
            //Assert page messages
            Boolean bFoundMessage=false;
            for(ApexPages.Message oMessage :ApexPages.getMessages()) {
                if(oMessage.getDetail().contains('CALLOUT EXCEPTION')) {
                    bFoundMessage=true;
                }
            }   
            system.assert(bFoundMessage);            
        Test.stopTest();
    }

    static testMethod void orderConfirmationSubmitWSStatusException() {
        //Tests the Seed_Unit_Order_Confirmation_Controller.orderConfirmationSubmit method for a web service status exception
        
        //Create accounts for testing
        Account oAccount = Test_Environment_Utility.createInsertAccountCA();
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccount, 'Seeding', Date.today());
        
        //Create user and manager and assign user as opportunity owner
        User oUser = Test_Environment_Utility.createInsertUser();
        User oManager = Test_Environment_Utility.createInsertUser();
        oUser.ManagerId=oManager.Id;
        oUser.Oracle_Salesrep_Id__c = String.valueOf(Test_Environment_Utility.getRandomInt(1, 99999));
        update oUser;
        oOpportunity.OwnerId=oUser.Id;
        update oOpportunity;
        
        //Create Integration Id for testing
        Integration_Id__c oIntegrationId = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetail = Test_Environment_Utility.createInsertWebServiceDetails('Create Customer');

        //Create Contact for testing
        Contact oContact = Test_Environment_Utility.createInsertContact(oAccount);

        //Create seed unit orders for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Enterprise', oAccount, oContact);
        oSeedUnitOrder.Salesrep__c = oUser.Id;
        oSeedUnitOrder.Ship_To_Contact__c = oContact.Id;
        oSeedUnitOrder.Ship_To_Address1__c = 'Test Address1';
        oSeedUnitOrder.Ship_To_Address2__c = 'Test Address2';
        oSeedUnitOrder.Ship_To_Address3__c = 'Test Address3';
        oSeedUnitOrder.Ship_To_Address4__c = 'Test Address4';
        oSeedUnitOrder.Ship_To_City__c = 'Test City';
        oSeedUnitOrder.Ship_To_State_Province__c = '';
        oSeedUnitOrder.Ship_To_Postal_Code__c = 'TEST ZIP';
        oSeedUnitOrder.Ship_To_Country__c = 'FR';
        update oSeedUnitOrder;
        //Create products for testing
        Product2 oProductEligible = Test_Environment_Utility.createInsertProduct();
        oProductEligible.Seed_Unit_Eligible_Enterprise__c=true;
        update oProductEligible;
        //Create seed unit products for testing
        Seed_Unit_Product__c oSeedUnitProductEligible = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProductEligible, 5);
        
        Test.startTest();
            //Retrieve newly created Account, Customer_Account__c, Seed_Unit_Order__c and Integration_Id__c fields needed for HTTP response.
            oIntegrationId = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationId.Id];              
            oAccount = [select Id, Name from Account where Id = :oAccount.Id];
            
            //Query for seed unit order created above in order to retrieve formula field values
            oSeedUnitOrder = [select Id, Sold_To_Org_new__c, Opportunity__c, Opportunity__r.Account.ParentId, Opportunity__r.AccountId, Name, Seed_Unit_Order_Submitted__c, Seed_Unit_Approval_Status__c,
                                Opportunity__r.Account.BillingStreet, Opportunity__r.Account.BillingCity, Opportunity__r.Account.BillingStateCode, Opportunity__r.Account.BillingPostalCode, Ship_To_Country__c,
                                Opportunity__r.Account.BillingCountryCode, Seed_Unit_Location_Type__c, Opportunity__r.Account.Parent.ParentId, Opportunity__r.Account.Name, Ship_To_Org_Id__c,
                                Ship_To_Address4__c, Ship_To_Address3__c, Ship_To_Address2__c, Sold_To_Salesforce_Id__c, Opportunity__r.Account.Id, Sold_To_Party_Name__c, Ship_To_County__c, Ship_To_Address__c,
                                Ship_To_Address1__c, Ship_To_City__c, ORIG_SYS_DOCUMENT_REF__c, Sold_To_Party_Id__c, Sold_To_Org_Id__c, Ship_To_State_Province__c, Ship_To_Postal_Code__c, Ship_To_Contact_First_Name__c,
                                Ship_To_Contact_Last_Name__c, Ship_To_Contact_Email__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Role_Id__c, Ship_To_Account__r.Name, Ship_To_Salesforce_Id__c,
                                Ship_To_Customer_Account_Id__c, Ship_To_Party_Id__c, Ship_To_Party_Name__c, Ship_To_Contact__c
                                from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];

            //Set up response since web service callouts are not allowed from test classes
            SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(404,
                                                            '',
                '{'+
                '  \"__type\": \"RepLocator.Customer\",'+
                '  \"ip_verification_id\": \"' + oIntegrationId.Security_Id__c + '\",'+
                '  \"ip_party_id\": \"\",'+
                '  \"ip_cust_account_id\": \"\",'+
                '  \"ip_ship_to_site_use_id\": \"\",'+
                '  \"ip_organization_name\": \"' + oAccount.Name + '\",'+
                '  \"ip_account_name\": \"CANADA\",'+
                '  \"ip_address1\": \"' + oSeedUnitOrder.Ship_To_Address1__c + '\",'+
                '  \"ip_address2\": \"' + oSeedUnitOrder.Ship_To_Address2__c + '\",'+
                '  \"ip_address3\": \"' + oSeedUnitOrder.Ship_To_Address3__c + '\",'+
                '  \"ip_address4\": \"' + oSeedUnitOrder.Ship_To_Address4__c + '\",'+
                '  \"ip_city\": \"' + oSeedUnitOrder.Ship_To_City__c + '\",'+
                '  \"ip_state\": \"\",'+
                '  \"ip_province\": \"\",'+
                '  \"ip_postal_code\": \"' + oSeedUnitOrder.Ship_To_Postal_Code__c + '\",'+
                '  \"ip_country\": \"' + oSeedUnitOrder.Ship_To_Country__c + '\",'+
                '  \"ip_county\": \"\",'+
                '  \"ip_person_first_name\": \"CHRIS\",'+
                '  \"ip_person_last_name\": \"NOE\",'+
                '  \"ip_raw_phone_number\": \"9522231265\",'+
                '  \"ip_email_address\": \"CNOE@ERGOTRON.COM\",'+
                '  \"ip_is_bill_to_address\": \"\",'+
                '  \"ip_is_ship_to_address\": \"Y\",'+
                '  \"ip_salesforce_ref_id\": \"' + oSeedUnitOrder.Id + '\",'+
                '  \"op_party_id\": \"187267221\",'+
                '  \"op_party_number\": \"\",'+
                '  \"op_cust_account_id\": \"16762542\",'+
                '  \"op_ship_to_site_use_id\": \"19099009\",'+
                '  \"op_bill_to_site_use_id\": \"\",'+
                '  \"op_ship_to_contact_id\": \"21046994\",'+
                '  \"op_cust_account_role_id\": \"19300030\",'+
                '  \"op_return_status\": \"\",'+
                '  \"op_return_message\": \"\"'+
                '}'
                 , null);
            Test.setMock(HttpCalloutMock.class, oFakeResponse); 

            /*BEGIN TEST: Web service status exception*/
            
            //Create PageReference to the SeedUnitOrderConfirmation
            PageReference oPageRef = Page.SeedUnitOrderConfirmation;
            Test.setCurrentPage(oPageRef);

            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            ApexPages.currentPage().getParameters().put('id',oSeedUnitOrder.id);
            Seed_Unit_Order_Confirmation_Controller oExtController = new Seed_Unit_Order_Confirmation_Controller(oStdController);
            
            oPageRef = oExtController.orderConfirmationSubmit();   
            //Assert null return for page ref
            system.assertEquals(null,oPageRef);
            //Assert page messages
            Boolean bFoundMessage=false;
            for(ApexPages.Message oMessage :ApexPages.getMessages()) {
                if(oMessage.getDetail().contains('STATUS EXCEPTION')) {
                    bFoundMessage=true;
                }
            }   
            system.assert(bFoundMessage);             
        Test.stopTest();
    } 

    static testMethod void orderConfirmationSubmitOracleAPIException() {
        //Tests the Seed_Unit_Order_Confirmation_Controller.orderConfirmationSubmit method for an Oracle API exception
        
        //Create accounts for testing
        Account oAccount = Test_Environment_Utility.createInsertAccountCA();
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccount, 'Seeding', Date.today());
        
        //Create user and manager and assign user as opportunity owner
        User oUser = Test_Environment_Utility.createInsertUser();
        User oManager = Test_Environment_Utility.createInsertUser();
        oUser.ManagerId=oManager.Id;
        oUser.Oracle_Salesrep_Id__c = String.valueOf(Test_Environment_Utility.getRandomInt(1, 99999));
        update oUser;
        oOpportunity.OwnerId=oUser.Id;
        update oOpportunity;
        
        //Create Integration Id for testing
        Integration_Id__c oIntegrationId = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetail = Test_Environment_Utility.createInsertWebServiceDetails('Create Customer');

        //Create Contact for testing
        Contact oContact = Test_Environment_Utility.createInsertContact(oAccount);

        //Create seed unit orders for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Enterprise', oAccount, oContact);
        oSeedUnitOrder.Salesrep__c = oUser.Id;
        oSeedUnitOrder.Ship_To_Contact__c = oContact.Id;
        oSeedUnitOrder.Ship_To_Address1__c = 'Test Address1';
        oSeedUnitOrder.Ship_To_Address2__c = 'Test Address2';
        oSeedUnitOrder.Ship_To_Address3__c = 'Test Address3';
        oSeedUnitOrder.Ship_To_Address4__c = 'Test Address4';
        oSeedUnitOrder.Ship_To_City__c = 'Test City';
        oSeedUnitOrder.Ship_To_State_Province__c = '';
        oSeedUnitOrder.Ship_To_Postal_Code__c = 'TEST ZIP';
        oSeedUnitOrder.Ship_To_Country__c = 'FR';
        update oSeedUnitOrder;
        //Create products for testing
        Product2 oProductEligible = Test_Environment_Utility.createInsertProduct();
        oProductEligible.Seed_Unit_Eligible_Enterprise__c=true;
        update oProductEligible;
        //Create seed unit products for testing
        Seed_Unit_Product__c oSeedUnitProductEligible = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProductEligible, 5);
        
        Test.startTest();
            //Retrieve newly created Account, Customer_Account__c, Seed_Unit_Order__c and Integration_Id__c fields needed for HTTP response.
            oIntegrationId = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationId.Id];              
            oAccount = [select Id, Name from Account where Id = :oAccount.Id];
            
            //Query for seed unit order created above in order to retrieve formula field values
            oSeedUnitOrder = [select Id, Sold_To_Org_new__c, Opportunity__c, Opportunity__r.Account.ParentId, Opportunity__r.AccountId, Name, Seed_Unit_Order_Submitted__c, Seed_Unit_Approval_Status__c,
                                Opportunity__r.Account.BillingStreet, Opportunity__r.Account.BillingCity, Opportunity__r.Account.BillingStateCode, Opportunity__r.Account.BillingPostalCode, Ship_To_Country__c,
                                Opportunity__r.Account.BillingCountryCode, Seed_Unit_Location_Type__c, Opportunity__r.Account.Parent.ParentId, Opportunity__r.Account.Name, Ship_To_Org_Id__c,
                                Ship_To_Address4__c, Ship_To_Address3__c, Ship_To_Address2__c, Sold_To_Salesforce_Id__c, Opportunity__r.Account.Id, Sold_To_Party_Name__c, Ship_To_County__c, Ship_To_Address__c,
                                Ship_To_Address1__c, Ship_To_City__c, ORIG_SYS_DOCUMENT_REF__c, Sold_To_Party_Id__c, Sold_To_Org_Id__c, Ship_To_State_Province__c, Ship_To_Postal_Code__c, Ship_To_Contact_First_Name__c,
                                Ship_To_Contact_Last_Name__c, Ship_To_Contact_Email__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Role_Id__c, Ship_To_Account__r.Name, Ship_To_Salesforce_Id__c,
                                Ship_To_Customer_Account_Id__c, Ship_To_Party_Id__c, Ship_To_Party_Name__c, Ship_To_Contact__c
                                from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];

            //Set up response since web service callouts are not allowed from test classes
            SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(200,
                                                            'OK',
                '{'+
                '  \"__type\": \"RepLocator.Customer\",'+
                '  \"ip_verification_id\": \"' + oIntegrationId.Security_Id__c + '\",'+
                '  \"ip_party_id\": \"\",'+
                '  \"ip_cust_account_id\": \"\",'+
                '  \"ip_ship_to_site_use_id\": \"\",'+
                '  \"ip_organization_name\": \"' + oAccount.Name + '\",'+
                '  \"ip_account_name\": \"CANADA\",'+
                '  \"ip_address1\": \"' + oSeedUnitOrder.Ship_To_Address1__c + '\",'+
                '  \"ip_address2\": \"' + oSeedUnitOrder.Ship_To_Address2__c + '\",'+
                '  \"ip_address3\": \"' + oSeedUnitOrder.Ship_To_Address3__c + '\",'+
                '  \"ip_address4\": \"' + oSeedUnitOrder.Ship_To_Address4__c + '\",'+
                '  \"ip_city\": \"' + oSeedUnitOrder.Ship_To_City__c + '\",'+
                '  \"ip_state\": \"\",'+
                '  \"ip_province\": \"\",'+
                '  \"ip_postal_code\": \"' + oSeedUnitOrder.Ship_To_Postal_Code__c + '\",'+
                '  \"ip_country\": \"' + oSeedUnitOrder.Ship_To_Country__c + '\",'+
                '  \"ip_county\": \"\",'+
                '  \"ip_person_first_name\": \"CHRIS\",'+
                '  \"ip_person_last_name\": \"NOE\",'+
                '  \"ip_raw_phone_number\": \"9522231265\",'+
                '  \"ip_email_address\": \"CNOE@ERGOTRON.COM\",'+
                '  \"ip_is_bill_to_address\": \"\",'+
                '  \"ip_is_ship_to_address\": \"Y\",'+
                '  \"ip_salesforce_ref_id\": \"' + oSeedUnitOrder.Id + '\",'+
                '  \"op_party_id\": \"187267221\",'+
                '  \"op_party_number\": \"\",'+
                '  \"op_cust_account_id\": \"16762542\",'+
                '  \"op_ship_to_site_use_id\": \"19099009\",'+
                '  \"op_bill_to_site_use_id\": \"\",'+
                '  \"op_ship_to_contact_id\": \"21046994\",'+
                '  \"op_cust_account_role_id\": \"19300030\",'+
                '  \"op_return_status\": \"E\",'+
                '  \"op_return_message\": \"ORACLE API ERROR\"'+
                '}'
                 , null);
            Test.setMock(HttpCalloutMock.class, oFakeResponse); 

            /*BEGIN TEST: Oracle API Exception*/
            
            //Create PageReference to the SeedUnitOrderConfirmation
            PageReference oPageRef = Page.SeedUnitOrderConfirmation;
            Test.setCurrentPage(oPageRef);

            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            ApexPages.currentPage().getParameters().put('id',oSeedUnitOrder.id);
            Seed_Unit_Order_Confirmation_Controller oExtController = new Seed_Unit_Order_Confirmation_Controller(oStdController);
            
            oPageRef = oExtController.orderConfirmationSubmit();   
            //Assert null return for page ref
            system.assertEquals(null,oPageRef);
            //Assert page messages
            Boolean bFoundMessage=false;
            for(ApexPages.Message oMessage :ApexPages.getMessages()) {
                if(oMessage.getDetail().contains('ORACLE API EXCEPTION')) {
                    bFoundMessage=true;
                }
            }   
            system.assert(bFoundMessage);             
        Test.stopTest();
    } 

    static testMethod void orderConfirmationSubmitApprovalRequiredException() {
        //Tests the Seed_Unit_Order_Confirmation_Controller.orderConfirmationSubmit method for an approval required exception
        
        //Create accounts for testing
        Account oAccount = Test_Environment_Utility.createInsertAccountCA();
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccount, 'Seeding', Date.today());
        
        //Create user and manager and assign user as opportunity owner
        User oUser = Test_Environment_Utility.createInsertUser();
        User oManager = Test_Environment_Utility.createInsertUser();
        oUser.ManagerId=oManager.Id;
        oUser.Oracle_Salesrep_Id__c = String.valueOf(Test_Environment_Utility.getRandomInt(1, 99999));
        update oUser;
        oOpportunity.OwnerId=oUser.Id;
        update oOpportunity;
        
        //Create Integration Id for testing
        Integration_Id__c oIntegrationId = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetail = Test_Environment_Utility.createInsertWebServiceDetails('Create Customer');

        //Create Contact for testing
        Contact oContact = Test_Environment_Utility.createInsertContact(oAccount);

        //Create seed unit orders for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Enterprise', oAccount, oContact);
        //Create products for testing
        Product2 oProduct = Test_Environment_Utility.createInsertProduct();
        //Create seed unit products for testing
        Seed_Unit_Product__c oSeedUnitProductEligible = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProduct, 5);

        //Update seed unit order details
        oSeedUnitOrder.Salesrep__c = oUser.Id;
        oSeedUnitOrder.Ship_To_Contact__c = oContact.Id;
        oSeedUnitOrder.Ship_To_Address1__c = 'Test Address1';
        oSeedUnitOrder.Ship_To_Address2__c = 'Test Address2';
        oSeedUnitOrder.Ship_To_Address3__c = 'Test Address3';
        oSeedUnitOrder.Ship_To_Address4__c = 'Test Address4';
        oSeedUnitOrder.Ship_To_City__c = 'Test City';
        oSeedUnitOrder.Ship_To_State_Province__c = '';
        oSeedUnitOrder.Ship_To_Postal_Code__c = 'TEST ZIP';
        oSeedUnitOrder.Ship_To_Country__c = 'FR';
        oSeedUnitOrder.Seed_Unit_Approval_Status__c = 'Submitted';
        update oSeedUnitOrder;
        
        Test.startTest();
            //Retrieve newly created Account, Customer_Account__c, Seed_Unit_Order__c and Integration_Id__c fields needed for HTTP response.
            oIntegrationId = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationId.Id];              
            oAccount = [select Id, Name from Account where Id = :oAccount.Id];
            
            //Query for seed unit order created above in order to retrieve formula field values
            oSeedUnitOrder = [select Id, Sold_To_Org_new__c, Opportunity__c, Opportunity__r.Account.ParentId, Opportunity__r.AccountId, Name, Seed_Unit_Order_Submitted__c, Seed_Unit_Approval_Status__c,
                                Opportunity__r.Account.BillingStreet, Opportunity__r.Account.BillingCity, Opportunity__r.Account.BillingStateCode, Opportunity__r.Account.BillingPostalCode, Ship_To_Country__c,
                                Opportunity__r.Account.BillingCountryCode, Seed_Unit_Location_Type__c, Opportunity__r.Account.Parent.ParentId, Opportunity__r.Account.Name, Ship_To_Org_Id__c,
                                Ship_To_Address4__c, Ship_To_Address3__c, Ship_To_Address2__c, Sold_To_Salesforce_Id__c, Opportunity__r.Account.Id, Sold_To_Party_Name__c, Ship_To_County__c, Ship_To_Address__c,
                                Ship_To_Address1__c, Ship_To_City__c, ORIG_SYS_DOCUMENT_REF__c, Sold_To_Party_Id__c, Sold_To_Org_Id__c, Ship_To_State_Province__c, Ship_To_Postal_Code__c, Ship_To_Contact_First_Name__c,
                                Ship_To_Contact_Last_Name__c, Ship_To_Contact_Email__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Role_Id__c, Ship_To_Account__r.Name, Ship_To_Salesforce_Id__c,
                                Ship_To_Customer_Account_Id__c, Ship_To_Party_Id__c, Ship_To_Party_Name__c, Ship_To_Contact__c
                                from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];

            //Set up response since web service callouts are not allowed from test classes
            SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(200,
                                                            'OK',
                '{'+
                '  \"__type\": \"RepLocator.Customer\",'+
                '  \"ip_verification_id\": \"' + oIntegrationId.Security_Id__c + '\",'+
                '  \"ip_party_id\": \"\",'+
                '  \"ip_cust_account_id\": \"\",'+
                '  \"ip_ship_to_site_use_id\": \"\",'+
                '  \"ip_organization_name\": \"' + oAccount.Name + '\",'+
                '  \"ip_account_name\": \"CANADA\",'+
                '  \"ip_address1\": \"' + oSeedUnitOrder.Ship_To_Address1__c + '\",'+
                '  \"ip_address2\": \"' + oSeedUnitOrder.Ship_To_Address2__c + '\",'+
                '  \"ip_address3\": \"' + oSeedUnitOrder.Ship_To_Address3__c + '\",'+
                '  \"ip_address4\": \"' + oSeedUnitOrder.Ship_To_Address4__c + '\",'+
                '  \"ip_city\": \"' + oSeedUnitOrder.Ship_To_City__c + '\",'+
                '  \"ip_state\": \"\",'+
                '  \"ip_province\": \"\",'+
                '  \"ip_postal_code\": \"' + oSeedUnitOrder.Ship_To_Postal_Code__c + '\",'+
                '  \"ip_country\": \"' + oSeedUnitOrder.Ship_To_Country__c + '\",'+
                '  \"ip_county\": \"\",'+
                '  \"ip_person_first_name\": \"CHRIS\",'+
                '  \"ip_person_last_name\": \"NOE\",'+
                '  \"ip_raw_phone_number\": \"9522231265\",'+
                '  \"ip_email_address\": \"CNOE@ERGOTRON.COM\",'+
                '  \"ip_is_bill_to_address\": \"\",'+
                '  \"ip_is_ship_to_address\": \"Y\",'+
                '  \"ip_salesforce_ref_id\": \"' + oSeedUnitOrder.Id + '\",'+
                '  \"op_party_id\": \"187267221\",'+
                '  \"op_party_number\": \"\",'+
                '  \"op_cust_account_id\": \"16762542\",'+
                '  \"op_ship_to_site_use_id\": \"19099009\",'+
                '  \"op_bill_to_site_use_id\": \"\",'+
                '  \"op_ship_to_contact_id\": \"21046994\",'+
                '  \"op_cust_account_role_id\": \"19300030\",'+
                '  \"op_return_status\": \"\",'+
                '  \"op_return_message\": \"\"'+
                '}'
                 , null);
            Test.setMock(HttpCalloutMock.class, oFakeResponse); 

            /*BEGIN TEST: Approval submission exception*/
            
            //Create PageReference to the SeedUnitOrderConfirmation
            PageReference oPageRef = Page.SeedUnitOrderConfirmation;
            Test.setCurrentPage(oPageRef);

            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            ApexPages.currentPage().getParameters().put('id',oSeedUnitOrder.id);
            Seed_Unit_Order_Confirmation_Controller oExtController = new Seed_Unit_Order_Confirmation_Controller(oStdController);
            
            oPageRef = oExtController.orderConfirmationSubmit();   
            //Assert null return for page ref
            system.assertEquals(null,oPageRef);              
        Test.stopTest();
    } 

    static testMethod void orderConfirmationSubmitCreateRelationship() {
        //Tests the creation of a customer relationship for bill to/ship to purposes.
        
        //Create accounts for testing
        Account oAccountFrom = Test_Environment_Utility.createInsertAccountUS();
        Account oAccountTo = Test_Environment_Utility.createInsertAccountUS();

        //Create customer accounts for testing
        Account oCustomerAccountFrom = Test_Environment_Utility.createInsertAccountUS();
        Account oCustomerAccountTo = Test_Environment_Utility.createInsertAccountUS();

        //Create Integration Id for testing
        Integration_Id__c oIntegrationId = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetail = Test_Environment_Utility.createInsertWebServiceDetails('Create Relationship');

        Test.startTest();
            //Retrieve newly created Customer_Account__c and Integration_Id__c fields needed for HTTP response.
            oIntegrationId = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationId.Id]; 
            oCustomerAccountFrom = [select Id, Customer_Account_Id__c from Account where Id = :oCustomerAccountFrom.Id];
            oCustomerAccountTo = [select Id, Customer_Account_Id__c from Account where Id = :oCustomerAccountTo.Id];

            //Set up response since web service callouts are not allowed from test classes
            SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(200,
                                                            'OK',
                '{'+
                '  \"__type\": \"RepLocator.Relationship\",'+
                '  \"ip_verification_id\": \"' + oIntegrationId.Security_Id__c + '\",'+
                '  \"ip_cust_account_id\": \"' + oCustomerAccountFrom.Customer_Account_Id__c + '\",'+
                '  \"ip_related_cust_account_id\": \"' + oCustomerAccountTo.Customer_Account_Id__c + '\",'+
                '  \"ip_bill_to_flag\": \"\",'+
                '  \"ip_ship_to_flag\": \"Y\",'+
                '  \"op_return_status\": \"\",'+
                '  \"op_return_message\": \"\"'+
                '}' 
                 , null);
            Test.setMock(HttpCalloutMock.class, oFakeResponse);

            Oracle_Customer_Utility.CreateRelationshipRequest oCreateRelationshipRequest = new Oracle_Customer_Utility.CreateRelationshipRequest();
            oCreateRelationshipRequest.ip_verification_id=oIntegrationId.Security_Id__c;
            oCreateRelationshipRequest.ip_bill_to_flag='';
            oCreateRelationshipRequest.ip_ship_to_flag='Y';
            oCreateRelationshipRequest.ip_cust_account_id=oCustomerAccountFrom.Customer_Account_Id__c;
            oCreateRelationshipRequest.ip_salesforce_ref_id=oAccountFrom.Id;
            oCreateRelationshipRequest.ip_related_cust_account_id=oCustomerAccountTo.Customer_Account_Id__c;

            Oracle_Customer_Utility.CreateRelationshipResponse oCreateRelationshipResponse = new Oracle_Customer_Utility.CreateRelationshipResponse();
            oCreateRelationshipResponse = Oracle_Customer_Utility.createRelationshipCallout(oCreateRelationshipRequest, 'TEST CLASS');

            //Assertiions
            system.assertEquals(oIntegrationId.Security_Id__c,oCreateRelationshipResponse.ip_verification_id);
            system.assertEquals('Y',oCreateRelationshipResponse.ip_ship_to_flag);
            system.assertEquals(oCustomerAccountFrom.Customer_Account_Id__c,oCreateRelationshipResponse.ip_cust_account_id);
            system.assertEquals(oCustomerAccountTo.Customer_Account_Id__c,oCreateRelationshipResponse.ip_related_cust_account_id);
            system.assertEquals('200',oCreateRelationshipResponse.ws_callout_status_code);
            system.assertEquals('CALLOUT STATUS MESSAGE: OK',oCreateRelationshipResponse.ws_callout_status_message);
        Test.stopTest();        
    }

    static testMethod void orderConfirmationSubmitCreateRelationshipCalloutException() {
        //Tests the creation of a customer relationship for bill to/ship to purposes.  This method tests callout exception logic.
        
        //Create accounts for testing
        Account oAccountFrom = Test_Environment_Utility.createInsertAccountUS();
        Account oAccountTo = Test_Environment_Utility.createInsertAccountUS();

        //Create customer accounts for testing
        Account oCustomerAccountFrom = Test_Environment_Utility.createInsertAccountUS();
        Account oCustomerAccountTo = Test_Environment_Utility.createInsertAccountUS();

        //Create Integration Id for testing
        Integration_Id__c oIntegrationId = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetail = Test_Environment_Utility.createInsertWebServiceDetails('Create Relationship');

        Test.startTest();
            //Retrieve newly created Customer_Account__c and Integration_Id__c fields needed for HTTP response.
            oIntegrationId = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationId.Id]; 
            oCustomerAccountFrom = [select Id, Customer_Account_Id__c from Account where Id = :oCustomerAccountFrom.Id];
            oCustomerAccountTo = [select Id, Customer_Account_Id__c from Account where Id = :oCustomerAccountTo.Id];

            //Set up response since web service callouts are not allowed from test classes - incorrect JSON format
            SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(200,
                                                            'OK',
                '//{'+
                '  \"__type\": \"RepLocator.Relationship\",'+
                '  \"ip_verification_id\": \"' + oIntegrationId.Security_Id__c + '\",'+
                '  \"ip_cust_account_id\": \"' + oCustomerAccountFrom.Customer_Account_Id__c + '\",'+
                '  \"ip_related_cust_account_id\": \"' + oCustomerAccountTo.Customer_Account_Id__c + '\",'+
                '  \"ip_bill_to_flag\": \"\",'+
                '  \"ip_ship_to_flag\": \"Y\",'+
                '  \"op_return_status\": \"\",'+
                '  \"op_return_message\": \"\"'+
                '}' 
                 , null);
            Test.setMock(HttpCalloutMock.class, oFakeResponse);

            Oracle_Customer_Utility.CreateRelationshipRequest oCreateRelationshipRequest = new Oracle_Customer_Utility.CreateRelationshipRequest();
            oCreateRelationshipRequest.ip_verification_id=oIntegrationId.Security_Id__c;
            oCreateRelationshipRequest.ip_bill_to_flag='';
            oCreateRelationshipRequest.ip_ship_to_flag='Y';
            oCreateRelationshipRequest.ip_cust_account_id=oCustomerAccountFrom.Customer_Account_Id__c;
            oCreateRelationshipRequest.ip_salesforce_ref_id=oAccountFrom.Id;
            oCreateRelationshipRequest.ip_related_cust_account_id=oCustomerAccountTo.Customer_Account_Id__c;

            Oracle_Customer_Utility.CreateRelationshipResponse oCreateRelationshipResponse = new Oracle_Customer_Utility.CreateRelationshipResponse();
            oCreateRelationshipResponse = Oracle_Customer_Utility.createRelationshipCallout(oCreateRelationshipRequest, 'TEST CLASS');

            //Assertiion for callout exception
            system.assert(oCreateRelationshipResponse.ws_exception_message.contains('CALLOUT EXCEPTION'));
        Test.stopTest();        
    } 

    static testMethod void orderConfirmationSubmitCreateRelationshipCalloutStatusException() {
        //Tests the creation of a customer relationship for bill to/ship to purposes.  This method tests callout status exception logic.
        
        //Create accounts for testing
        Account oAccountFrom = Test_Environment_Utility.createInsertAccountUS();
        Account oAccountTo = Test_Environment_Utility.createInsertAccountUS();

        //Create customer accounts for testing
        Account oCustomerAccountFrom = Test_Environment_Utility.createInsertAccountUS();
        Account oCustomerAccountTo = Test_Environment_Utility.createInsertAccountUS();

        //Create Integration Id for testing
        Integration_Id__c oIntegrationId = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetail = Test_Environment_Utility.createInsertWebServiceDetails('Create Relationship');

        Test.startTest();
            //Retrieve newly created Customer_Account__c and Integration_Id__c fields needed for HTTP response.
            oIntegrationId = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationId.Id]; 
            oCustomerAccountFrom = [select Id, Customer_Account_Id__c from Account where Id = :oCustomerAccountFrom.Id];
            oCustomerAccountTo = [select Id, Customer_Account_Id__c from Account where Id = :oCustomerAccountTo.Id];

            //Set up response since web service callouts are not allowed from test classes
            SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(404,
                                                            'BAD',
                '{'+
                '  \"__type\": \"RepLocator.Relationship\",'+
                '  \"ip_verification_id\": \"' + oIntegrationId.Security_Id__c + '\",'+
                '  \"ip_cust_account_id\": \"' + oCustomerAccountFrom.Customer_Account_Id__c + '\",'+
                '  \"ip_related_cust_account_id\": \"' + oCustomerAccountTo.Customer_Account_Id__c + '\",'+
                '  \"ip_bill_to_flag\": \"\",'+
                '  \"ip_ship_to_flag\": \"Y\",'+
                '  \"op_return_status\": \"\",'+
                '  \"op_return_message\": \"\"'+
                '}' 
                 , null);
            Test.setMock(HttpCalloutMock.class, oFakeResponse);

            Oracle_Customer_Utility.CreateRelationshipRequest oCreateRelationshipRequest = new Oracle_Customer_Utility.CreateRelationshipRequest();
            oCreateRelationshipRequest.ip_verification_id=oIntegrationId.Security_Id__c;
            oCreateRelationshipRequest.ip_bill_to_flag='';
            oCreateRelationshipRequest.ip_ship_to_flag='Y';
            oCreateRelationshipRequest.ip_cust_account_id=oCustomerAccountFrom.Customer_Account_Id__c;
            oCreateRelationshipRequest.ip_salesforce_ref_id=oAccountFrom.Id;
            oCreateRelationshipRequest.ip_related_cust_account_id=oCustomerAccountTo.Customer_Account_Id__c;

            Oracle_Customer_Utility.CreateRelationshipResponse oCreateRelationshipResponse = new Oracle_Customer_Utility.CreateRelationshipResponse();
            oCreateRelationshipResponse = Oracle_Customer_Utility.createRelationshipCallout(oCreateRelationshipRequest, 'TEST CLASS');

            //Assertiions
            system.assertEquals('404',oCreateRelationshipResponse.ws_callout_status_code);
            //system.assertEquals('CALLOUT STATUS MESSAGE: BAD',oCreateRelationshipResponse.ws_callout_status_message);
            system.assertNotEquals(NULL, oCreateRelationshipResponse.ws_callout_status_message);
        Test.stopTest();        
    }

    static testMethod void orderConfirmationSubmitCreateRelationshipOracleAPIException() {
        //Tests the creation of a customer relationship for bill to/ship to purposes.  This method tests callout Oracle API status exception logic.
        
        //Create accounts for testing
        Account oAccountFrom = Test_Environment_Utility.createInsertAccountUS();
        Account oAccountTo = Test_Environment_Utility.createInsertAccountUS();

        //Create customer accounts for testing
        Account oCustomerAccountFrom = Test_Environment_Utility.createInsertAccountUS();
        Account oCustomerAccountTo = Test_Environment_Utility.createInsertAccountUS();

        //Create Integration Id for testing
        Integration_Id__c oIntegrationId = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetail = Test_Environment_Utility.createInsertWebServiceDetails('Create Relationship');

        Test.startTest();
            //Retrieve newly created Customer_Account__c and Integration_Id__c fields needed for HTTP response.
            oIntegrationId = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationId.Id]; 
            oCustomerAccountFrom = [select Id, Customer_Account_Id__c from Account where Id = :oCustomerAccountFrom.Id];
            oCustomerAccountTo = [select Id, Customer_Account_Id__c from Account where Id = :oCustomerAccountTo.Id];

            //Set up response since web service callouts are not allowed from test classes
            SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(200,
                                                            'OK',
                '{'+
                '  \"__type\": \"RepLocator.Relationship\",'+
                '  \"ip_verification_id\": \"' + oIntegrationId.Security_Id__c + '\",'+
                '  \"ip_cust_account_id\": \"' + oCustomerAccountFrom.Customer_Account_Id__c + '\",'+
                '  \"ip_related_cust_account_id\": \"' + oCustomerAccountTo.Customer_Account_Id__c + '\",'+
                '  \"ip_bill_to_flag\": \"\",'+
                '  \"ip_ship_to_flag\": \"Y\",'+
                '  \"op_return_status\": \"E\",'+
                '  \"op_return_message\": \"ORACLE API EXCEPTION\"'+
                '}' 
                 , null);
            Test.setMock(HttpCalloutMock.class, oFakeResponse);

            Oracle_Customer_Utility.CreateRelationshipRequest oCreateRelationshipRequest = new Oracle_Customer_Utility.CreateRelationshipRequest();
            oCreateRelationshipRequest.ip_verification_id=oIntegrationId.Security_Id__c;
            oCreateRelationshipRequest.ip_bill_to_flag='';
            oCreateRelationshipRequest.ip_ship_to_flag='Y';
            oCreateRelationshipRequest.ip_cust_account_id=oCustomerAccountFrom.Customer_Account_Id__c;
            oCreateRelationshipRequest.ip_salesforce_ref_id=oAccountFrom.Id;
            oCreateRelationshipRequest.ip_related_cust_account_id=oCustomerAccountTo.Customer_Account_Id__c;

            Oracle_Customer_Utility.CreateRelationshipResponse oCreateRelationshipResponse = new Oracle_Customer_Utility.CreateRelationshipResponse();
            oCreateRelationshipResponse = Oracle_Customer_Utility.createRelationshipCallout(oCreateRelationshipRequest, 'TEST CLASS');

            //Assertiions
            system.assertEquals('E',oCreateRelationshipResponse.op_return_status);
            system.assertEquals('ORACLE API EXCEPTION',oCreateRelationshipResponse.op_return_message);
        Test.stopTest();        
    }

    static testMethod void orderConfirmationSubmitNewShipExistingBillToCustomerUS() {
        //Tests the Seed_Unit_Order_Confirmation_Controller.orderConfirmationSubmit method for new ship to and existing bill to customer (different ship to bill to) - US Customer
        //End User (bill to) Party and Customer Exists
        //Reseller (ship to) Party and Customer do not exist
        String sPartyIdentifier = 'ERGO' + String.valueOf(math.random()).left(20);
        //Create accounts for testing
        Account oAccountEndUser = Test_Environment_Utility.createInsertAccountUS();
        oAccountEndUser.Oracle_Party_Id__c=sPartyIdentifier;
        oAccountEndUser.Oracle_Party_Number__c=sPartyIdentifier;
        update oAccountEndUser;
        Account oAccountReseller = Test_Environment_Utility.createInsertAccountUS();
        //Create Customer_Account__c for testing
        Account oCustomerAccount = Test_Environment_Utility.createInsertAccountUS();
        //Create Contact for testing
        Contact oContactReseller = Test_Environment_Utility.createInsertContact(oAccountReseller);
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccountEndUser, 'Seeding', Date.today());
        
        //Create Integrations Id for testing
        Integration_Id__c oIntegrationIdBillTo = Test_Environment_Utility.createInsertIntegrationId();
        Integration_Id__c oIntegrationIdShipTo = Test_Environment_Utility.createInsertIntegrationId();
        Integration_Id__c oIntegrationIdRelationship = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetailCreateCustomer = Test_Environment_Utility.createInsertWebServiceDetails('Create Customer');
        Web_Service_Details__c oWebServiceDetailCreateRelationship = Test_Environment_Utility.createInsertWebServiceDetails('Create Relationship');

        //Create seed unit orders for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Enterprise', oAccountReseller, oContactReseller);
        oSeedUnitOrder.Sold_To_Org_new__c = oCustomerAccount.Id;
        oSeedUnitOrder.Ship_To_Address1__c = 'Test Address1';
        oSeedUnitOrder.Ship_To_Address2__c = 'Test Address2';
        oSeedUnitOrder.Ship_To_Address3__c = 'Test Address3';
        oSeedUnitOrder.Ship_To_Address4__c = 'Test Address4';
        oSeedUnitOrder.Ship_To_City__c = 'SAINT LOUIS';
        oSeedUnitOrder.Ship_To_County__c = 'SAINT LOUIS';
        oSeedUnitOrder.Ship_To_State_Province__c = 'MO';
        oSeedUnitOrder.Ship_To_Postal_Code__c = '66218';
        oSeedUnitOrder.Ship_To_Country__c = 'United States-US';
        update oSeedUnitOrder;
        //Create products for testing
        Product2 oProductEligible = Test_Environment_Utility.createInsertProduct();
        oProductEligible.Seed_Unit_Eligible_Enterprise__c=true;
        update oProductEligible;
        //Create seed unit products for testing
        Seed_Unit_Product__c oSeedUnitProductEligible = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProductEligible, 5);
        
        Test.startTest();
            //Retrieve newly created Account, Customer_Account__c, Seed_Unit_Order__c and Integration_Id__c fields needed for HTTP response.
            oIntegrationIdShipTo = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationIdShipTo.Id];              
            oAccountReseller = [select Id, Name from Account where Id = :oAccountReseller.Id];
            
            //Query for seed unit order created above in order to retrieve formula field values
            oSeedUnitOrder = [select Id, Sold_To_Org_new__c, Opportunity__c, Opportunity__r.Account.ParentId, Opportunity__r.AccountId, Name, Seed_Unit_Order_Submitted__c, Seed_Unit_Approval_Status__c,
                                Opportunity__r.Account.BillingStreet, Opportunity__r.Account.BillingCity, Opportunity__r.Account.BillingStateCode, Opportunity__r.Account.BillingPostalCode, Ship_To_Country__c,
                                Opportunity__r.Account.BillingCountryCode, Seed_Unit_Location_Type__c, Opportunity__r.Account.Parent.ParentId, Opportunity__r.Account.Name, Ship_To_Org_Id__c,
                                Ship_To_Address4__c, Ship_To_Address3__c, Ship_To_Address2__c, Sold_To_Salesforce_Id__c, Opportunity__r.Account.Id, Sold_To_Party_Name__c, Ship_To_County__c, Ship_To_Address__c,
                                Ship_To_Address1__c, Ship_To_City__c, ORIG_SYS_DOCUMENT_REF__c, Sold_To_Party_Id__c, Sold_To_Org_Id__c, Ship_To_State_Province__c, Ship_To_Postal_Code__c, Ship_To_Contact_First_Name__c,
                                Ship_To_Contact_Last_Name__c, Ship_To_Contact_Email__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Role_Id__c, Ship_To_Account__r.Name, Ship_To_Salesforce_Id__c,
                                Ship_To_Customer_Account_Id__c, Ship_To_Party_Id__c, Ship_To_Party_Name__c, Ship_To_Contact__c
                                from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];

            //Set up response since web service callouts are not allowed from test classes
            SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(200,
                                                            'OK',
                '{'+
                '  \"__type\": \"RepLocator.Customer\",'+
                '  \"ip_verification_id\": \"' + oIntegrationIdShipTo.Security_Id__c + '\",'+
                '  \"ip_party_id\": \"\",'+
                '  \"ip_cust_account_id\": \"\",'+
                '  \"ip_ship_to_site_use_id\": \"\",'+
                '  \"ip_organization_name\": \"' + oAccountReseller.Name + '\",'+
                '  \"ip_account_name\": \"DOMESTIC\",'+
                '  \"ip_address1\": \"' + oSeedUnitOrder.Ship_To_Address1__c + '\",'+
                '  \"ip_address2\": \"' + oSeedUnitOrder.Ship_To_Address2__c + '\",'+
                '  \"ip_address3\": \"' + oSeedUnitOrder.Ship_To_Address3__c + '\",'+
                '  \"ip_address4\": \"' + oSeedUnitOrder.Ship_To_Address4__c + '\",'+
                '  \"ip_city\": \"' + oSeedUnitOrder.Ship_To_City__c + '\",'+
                '  \"ip_state\": \"' + oSeedUnitOrder.Ship_To_Country__c + '\",'+
                '  \"ip_province\": \"' + oSeedUnitOrder.Ship_To_State_Province__c + '\",'+
                '  \"ip_postal_code\": \"' + oSeedUnitOrder.Ship_To_Postal_Code__c + '\",'+
                '  \"ip_country\": \"' + oSeedUnitOrder.Ship_To_Country__c + '\",'+
                '  \"ip_county\": \"\",'+
                '  \"ip_person_first_name\": \"CHRIS\",'+
                '  \"ip_person_last_name\": \"NOE\",'+
                '  \"ip_raw_phone_number\": \"9522231265\",'+
                '  \"ip_email_address\": \"CNOE@ERGOTRON.COM\",'+
                '  \"ip_is_bill_to_address\": \"\",'+
                '  \"ip_is_ship_to_address\": \"Y\",'+
                '  \"ip_salesforce_ref_id\": \"' + oSeedUnitOrder.Id + '\",'+
                '  \"op_party_id\": \"187267221\",'+
                '  \"op_party_number\": \"\",'+
                '  \"op_cust_account_id\": \"16762542\",'+
                '  \"op_ship_to_site_use_id\": \"19099009\",'+
                '  \"op_bill_to_site_use_id\": \"\",'+
                '  \"op_ship_to_contact_id\": \"21046994\",'+
                '  \"op_cust_account_role_id\": \"19300030\",'+
                '  \"op_return_status\": \"\",'+
                '  \"op_return_message\": \"\"'+
                '}'
                 , null);
            Test.setMock(HttpCalloutMock.class, oFakeResponse); 
            
            //Create PageReference to the SeedUnitOrderConfirmation
            PageReference oPageRef = Page.SeedUnitOrderConfirmation;
            Test.setCurrentPage(oPageRef);

            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            ApexPages.currentPage().getParameters().put('id',oSeedUnitOrder.id);
            Seed_Unit_Order_Confirmation_Controller oExtController = new Seed_Unit_Order_Confirmation_Controller(oStdController);
            
            oPageRef = oExtController.orderConfirmationSubmit();        
        Test.stopTest();
    }    

    static testMethod void orderConfirmationSubmitExistingShipNewBillToCustomerUS() {
        //Tests the Seed_Unit_Order_Confirmation_Controller.orderConfirmationSubmit method for new ship to and bill to customer (different ship to bill to) - US Customer
        //End User Party and Customer does not exist
        //Reseller (ship to) Party and Customer do exist, new address required
        String sPartyIdentifier = 'ERGO' + String.valueOf(math.random()).left(20);
        //Create accounts for testing
        Account oAccountEndUser = Test_Environment_Utility.createInsertAccountUS();
        Account oAccountReseller = Test_Environment_Utility.createInsertAccountUS();
        oAccountReseller.Oracle_Party_Id__c=sPartyIdentifier;
        oAccountReseller.Oracle_Party_Number__c=sPartyIdentifier;
        update oAccountReseller;
        //Create Customer_Account__c for testing
        Account oCustomerAccount = Test_Environment_Utility.createInsertAccountUS();
        //Create Contact for testing
        Contact oContactReseller = Test_Environment_Utility.createInsertContact(oAccountReseller);
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccountEndUser, 'Seeding', Date.today());
        
        //Create Integrations Id for testing
        Integration_Id__c oIntegrationIdBillTo = Test_Environment_Utility.createInsertIntegrationId();
        Integration_Id__c oIntegrationIdShipTo = Test_Environment_Utility.createInsertIntegrationId();
        Integration_Id__c oIntegrationIdRelationship = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetailCreateCustomer = Test_Environment_Utility.createInsertWebServiceDetails('Create Customer');
        Web_Service_Details__c oWebServiceDetailCreateRelationship = Test_Environment_Utility.createInsertWebServiceDetails('Create Relationship');

        //Create seed unit orders for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Enterprise', oAccountReseller, oContactReseller);
        oSeedUnitOrder.Ship_To_Customer_Account_new__c = oCustomerAccount.Id;
        oSeedUnitOrder.Ship_To_Address1__c = 'Test Address1';
        oSeedUnitOrder.Ship_To_Address2__c = 'Test Address2';
        oSeedUnitOrder.Ship_To_Address3__c = 'Test Address3';
        oSeedUnitOrder.Ship_To_Address4__c = 'Test Address4';
        oSeedUnitOrder.Ship_To_City__c = 'Test City';
        oSeedUnitOrder.Ship_To_State_Province__c = 'MN';
        oSeedUnitOrder.Ship_To_Postal_Code__c = '55044';
        oSeedUnitOrder.Ship_To_Country__c = 'United States-US';
        update oSeedUnitOrder;
        //Create products for testing
        Product2 oProductEligible = Test_Environment_Utility.createInsertProduct();
        oProductEligible.Seed_Unit_Eligible_Enterprise__c=true;
        update oProductEligible;
        //Create seed unit products for testing
        Seed_Unit_Product__c oSeedUnitProductEligible = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProductEligible, 5);
        
        Test.startTest();
            //Retrieve newly created Account, Customer_Account__c, Seed_Unit_Order__c and Integration_Id__c fields needed for HTTP response.
            oIntegrationIdBillTo = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationIdBillTo.Id];              
            oAccountEndUser = [select Id, Name from Account where Id = :oAccountEndUser.Id];
            
            //Query for seed unit order created above in order to retrieve formula field values
            oSeedUnitOrder = [select Id, Sold_To_Org_new__c, Opportunity__c, Opportunity__r.Account.ParentId, Opportunity__r.AccountId, Name, Seed_Unit_Order_Submitted__c, Seed_Unit_Approval_Status__c,
                                Opportunity__r.Account.BillingStreet, Opportunity__r.Account.BillingCity, Opportunity__r.Account.BillingStateCode, Opportunity__r.Account.BillingPostalCode, Ship_To_Country__c,
                                Opportunity__r.Account.BillingCountryCode, Seed_Unit_Location_Type__c, Opportunity__r.Account.Parent.ParentId, Opportunity__r.Account.Name, Ship_To_Org_Id__c,
                                Ship_To_Address4__c, Ship_To_Address3__c, Ship_To_Address2__c, Sold_To_Salesforce_Id__c, Opportunity__r.Account.Id, Sold_To_Party_Name__c, Ship_To_County__c, Ship_To_Address__c,
                                Ship_To_Address1__c, Ship_To_City__c, ORIG_SYS_DOCUMENT_REF__c, Sold_To_Party_Id__c, Sold_To_Org_Id__c, Ship_To_State_Province__c, Ship_To_Postal_Code__c, Ship_To_Contact_First_Name__c,
                                Ship_To_Contact_Last_Name__c, Ship_To_Contact_Email__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Role_Id__c, Ship_To_Account__r.Name, Ship_To_Salesforce_Id__c,
                                Ship_To_Customer_Account_Id__c, Ship_To_Party_Id__c, Ship_To_Party_Name__c, Ship_To_Contact__c
                                from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];

            //Set up response since web service callouts are not allowed from test classes
            SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(200,
                                                            'OK',
                '{'+
                '  \"__type\": \"RepLocator.Customer\",'+
                '  \"ip_verification_id\": \"' + oIntegrationIdBillTo.Security_Id__c + '\",'+
                '  \"ip_party_id\": \"\",'+
                '  \"ip_cust_account_id\": \"\",'+
                '  \"ip_ship_to_site_use_id\": \"\",'+
                '  \"ip_organization_name\": \"' + oAccountEndUser.Name + '\",'+
                '  \"ip_account_name\": \"DOMESTIC\",'+
                '  \"ip_address1\": \"' + oSeedUnitOrder.Ship_To_Address1__c + '\",'+
                '  \"ip_address2\": \"' + oSeedUnitOrder.Ship_To_Address2__c + '\",'+
                '  \"ip_address3\": \"' + oSeedUnitOrder.Ship_To_Address3__c + '\",'+
                '  \"ip_address4\": \"' + oSeedUnitOrder.Ship_To_Address4__c + '\",'+
                '  \"ip_city\": \"' + oSeedUnitOrder.Ship_To_City__c + '\",'+
                '  \"ip_state\": \"' + oSeedUnitOrder.Ship_To_Country__c + '\",'+
                '  \"ip_province\": \"' + oSeedUnitOrder.Ship_To_State_Province__c + '\",'+
                '  \"ip_postal_code\": \"' + oSeedUnitOrder.Ship_To_Postal_Code__c + '\",'+
                '  \"ip_country\": \"' + oSeedUnitOrder.Ship_To_Country__c + '\",'+
                '  \"ip_county\": \"\",'+
                '  \"ip_person_first_name\": \"CHRIS\",'+
                '  \"ip_person_last_name\": \"NOE\",'+
                '  \"ip_raw_phone_number\": \"9522231265\",'+
                '  \"ip_email_address\": \"CNOE@ERGOTRON.COM\",'+
                '  \"ip_is_bill_to_address\": \"\",'+
                '  \"ip_is_ship_to_address\": \"Y\",'+
                '  \"ip_salesforce_ref_id\": \"' + oSeedUnitOrder.Id + '\",'+
                '  \"op_party_id\": \"187267221\",'+
                '  \"op_party_number\": \"\",'+
                '  \"op_cust_account_id\": \"16762542\",'+
                '  \"op_ship_to_site_use_id\": \"19099009\",'+
                '  \"op_bill_to_site_use_id\": \"\",'+
                '  \"op_ship_to_contact_id\": \"21046994\",'+
                '  \"op_cust_account_role_id\": \"19300030\",'+
                '  \"op_return_status\": \"\",'+
                '  \"op_return_message\": \"\"'+
                '}'
                 , null);
            Test.setMock(HttpCalloutMock.class, oFakeResponse); 
            
            //Create PageReference to the SeedUnitOrderConfirmation
            PageReference oPageRef = Page.SeedUnitOrderConfirmation;
            Test.setCurrentPage(oPageRef);

            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            ApexPages.currentPage().getParameters().put('id',oSeedUnitOrder.id);
            Seed_Unit_Order_Confirmation_Controller oExtController = new Seed_Unit_Order_Confirmation_Controller(oStdController);
            
            oPageRef = oExtController.orderConfirmationSubmit();        
        Test.stopTest();
    }

    static testMethod void orderConfirmationSubmitNewShipExistingBillToCustomerCA() {
        //Tests the Seed_Unit_Order_Confirmation_Controller.orderConfirmationSubmit method for new ship to and existing bill to customer (different ship to bill to) - CA Customer
        //End User (bill to) Party and Customer Exists
        //Reseller (ship to) Party and Customer do not exist
        String sPartyIdentifier = 'ERGO' + String.valueOf(math.random()).left(20);
        //Create accounts for testing
        Account oAccountEndUser = Test_Environment_Utility.createInsertAccountCA();
        oAccountEndUser.Oracle_Party_Id__c=sPartyIdentifier;
        oAccountEndUser.Oracle_Party_Number__c=sPartyIdentifier;
        update oAccountEndUser;
        Account oAccountReseller = Test_Environment_Utility.createInsertAccountCA();
        //Create Customer_Account__c for testing
        Account oCustomerAccount = Test_Environment_Utility.createInsertAccountUS();
        //Create Contact for testing
        Contact oContactReseller = Test_Environment_Utility.createInsertContact(oAccountReseller);
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccountEndUser, 'Seeding', Date.today());
        
        //Create Integrations Id for testing
        Integration_Id__c oIntegrationIdBillTo = Test_Environment_Utility.createInsertIntegrationId();
        Integration_Id__c oIntegrationIdShipTo = Test_Environment_Utility.createInsertIntegrationId();
        Integration_Id__c oIntegrationIdRelationship = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetailCreateCustomer = Test_Environment_Utility.createInsertWebServiceDetails('Create Customer');
        Web_Service_Details__c oWebServiceDetailCreateRelationship = Test_Environment_Utility.createInsertWebServiceDetails('Create Relationship');

        //Create seed unit orders for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Enterprise', oAccountReseller, oContactReseller);
        oSeedUnitOrder.Sold_To_Org_new__c = oCustomerAccount.Id;
        oSeedUnitOrder.Ship_To_Address1__c = 'Test Address1';
        oSeedUnitOrder.Ship_To_Address2__c = 'Test Address2';
        oSeedUnitOrder.Ship_To_Address3__c = 'Test Address3';
        oSeedUnitOrder.Ship_To_Address4__c = 'Test Address4';
        oSeedUnitOrder.Ship_To_City__c = 'Test City';
        oSeedUnitOrder.Ship_To_State_Province__c = 'BC';
        oSeedUnitOrder.Ship_To_Postal_Code__c = 'X1B 4Y7';
        oSeedUnitOrder.Ship_To_Country__c = 'Canada-CA';
        update oSeedUnitOrder;
        //Create products for testing
        Product2 oProductEligible = Test_Environment_Utility.createInsertProduct();
        oProductEligible.Seed_Unit_Eligible_Enterprise__c=true;
        update oProductEligible;
        //Create seed unit products for testing
        Seed_Unit_Product__c oSeedUnitProductEligible = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProductEligible, 5);
        
        Test.startTest();
            //Retrieve newly created Account, Customer_Account__c, Seed_Unit_Order__c and Integration_Id__c fields needed for HTTP response.
            oIntegrationIdShipTo = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationIdShipTo.Id];              
            oAccountReseller = [select Id, Name from Account where Id = :oAccountReseller.Id];
            
            //Query for seed unit order created above in order to retrieve formula field values
            oSeedUnitOrder = [select Id, Sold_To_Org_new__c, Opportunity__c, Opportunity__r.Account.ParentId, Opportunity__r.AccountId, Name, Seed_Unit_Order_Submitted__c, Seed_Unit_Approval_Status__c,
                                Opportunity__r.Account.BillingStreet, Opportunity__r.Account.BillingCity, Opportunity__r.Account.BillingStateCode, Opportunity__r.Account.BillingPostalCode, Ship_To_Country__c,
                                Opportunity__r.Account.BillingCountryCode, Seed_Unit_Location_Type__c, Opportunity__r.Account.Parent.ParentId, Opportunity__r.Account.Name, Ship_To_Org_Id__c,
                                Ship_To_Address4__c, Ship_To_Address3__c, Ship_To_Address2__c, Sold_To_Salesforce_Id__c, Opportunity__r.Account.Id, Sold_To_Party_Name__c, Ship_To_County__c, Ship_To_Address__c,
                                Ship_To_Address1__c, Ship_To_City__c, ORIG_SYS_DOCUMENT_REF__c, Sold_To_Party_Id__c, Sold_To_Org_Id__c, Ship_To_State_Province__c, Ship_To_Postal_Code__c, Ship_To_Contact_First_Name__c,
                                Ship_To_Contact_Last_Name__c, Ship_To_Contact_Email__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Role_Id__c, Ship_To_Account__r.Name, Ship_To_Salesforce_Id__c,
                                Ship_To_Customer_Account_Id__c, Ship_To_Party_Id__c, Ship_To_Party_Name__c, Ship_To_Contact__c
                                from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];

            //Set up response since web service callouts are not allowed from test classes
            SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(200,
                                                            'OK',
                '{'+
                '  \"__type\": \"RepLocator.Customer\",'+
                '  \"ip_verification_id\": \"' + oIntegrationIdShipTo.Security_Id__c + '\",'+
                '  \"ip_party_id\": \"\",'+
                '  \"ip_cust_account_id\": \"\",'+
                '  \"ip_ship_to_site_use_id\": \"\",'+
                '  \"ip_organization_name\": \"' + oAccountReseller.Name + '\",'+
                '  \"ip_account_name\": \"CANADA\",'+
                '  \"ip_address1\": \"' + oSeedUnitOrder.Ship_To_Address1__c + '\",'+
                '  \"ip_address2\": \"' + oSeedUnitOrder.Ship_To_Address2__c + '\",'+
                '  \"ip_address3\": \"' + oSeedUnitOrder.Ship_To_Address3__c + '\",'+
                '  \"ip_address4\": \"' + oSeedUnitOrder.Ship_To_Address4__c + '\",'+
                '  \"ip_city\": \"' + oSeedUnitOrder.Ship_To_City__c + '\",'+
                '  \"ip_state\": \"' + oSeedUnitOrder.Ship_To_Country__c + '\",'+
                '  \"ip_province\": \"' + oSeedUnitOrder.Ship_To_State_Province__c + '\",'+
                '  \"ip_postal_code\": \"' + oSeedUnitOrder.Ship_To_Postal_Code__c + '\",'+
                '  \"ip_country\": \"' + oSeedUnitOrder.Ship_To_Country__c + '\",'+
                '  \"ip_county\": \"\",'+
                '  \"ip_person_first_name\": \"CHRIS\",'+
                '  \"ip_person_last_name\": \"NOE\",'+
                '  \"ip_raw_phone_number\": \"9522231265\",'+
                '  \"ip_email_address\": \"CNOE@ERGOTRON.COM\",'+
                '  \"ip_is_bill_to_address\": \"\",'+
                '  \"ip_is_ship_to_address\": \"Y\",'+
                '  \"ip_salesforce_ref_id\": \"' + oSeedUnitOrder.Id + '\",'+
                '  \"op_party_id\": \"187267221\",'+
                '  \"op_party_number\": \"\",'+
                '  \"op_cust_account_id\": \"16762542\",'+
                '  \"op_ship_to_site_use_id\": \"19099009\",'+
                '  \"op_bill_to_site_use_id\": \"\",'+
                '  \"op_ship_to_contact_id\": \"21046994\",'+
                '  \"op_cust_account_role_id\": \"19300030\",'+
                '  \"op_return_status\": \"\",'+
                '  \"op_return_message\": \"\"'+
                '}'
                 , null);
            Test.setMock(HttpCalloutMock.class, oFakeResponse); 
            
            //Create PageReference to the SeedUnitOrderConfirmation
            PageReference oPageRef = Page.SeedUnitOrderConfirmation;
            Test.setCurrentPage(oPageRef);

            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            ApexPages.currentPage().getParameters().put('id',oSeedUnitOrder.id);
            Seed_Unit_Order_Confirmation_Controller oExtController = new Seed_Unit_Order_Confirmation_Controller(oStdController);
            
            oPageRef = oExtController.orderConfirmationSubmit();        
        Test.stopTest();
    }

    static testMethod void orderConfirmationSubmitExistingShipNewBillToCustomerCA() {
        //Tests the Seed_Unit_Order_Confirmation_Controller.orderConfirmationSubmit method for new ship to and bill to customer (different ship to bill to) - CA Customer
        //End User Party and Customer does not exist
        //Reseller (ship to) Party and Customer do exist, new address required
        String sPartyIdentifier = 'ERGO' + String.valueOf(math.random()).left(20);
        //Create accounts for testing
        Account oAccountEndUser = Test_Environment_Utility.createInsertAccountCA();
        Account oAccountReseller = Test_Environment_Utility.createInsertAccountCA();
        oAccountReseller.Oracle_Party_Id__c=sPartyIdentifier;
        oAccountReseller.Oracle_Party_Number__c=sPartyIdentifier;
        update oAccountReseller;
        //Create Customer_Account__c for testing
        Account oCustomerAccount = Test_Environment_Utility.createInsertAccountUS();
        //Create Contact for testing
        Contact oContactReseller = Test_Environment_Utility.createInsertContact(oAccountReseller);
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccountEndUser, 'Seeding', Date.today());
        
        //Create Integrations Id for testing
        Integration_Id__c oIntegrationIdBillTo = Test_Environment_Utility.createInsertIntegrationId();
        Integration_Id__c oIntegrationIdShipTo = Test_Environment_Utility.createInsertIntegrationId();
        Integration_Id__c oIntegrationIdRelationship = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetailCreateCustomer = Test_Environment_Utility.createInsertWebServiceDetails('Create Customer');
        Web_Service_Details__c oWebServiceDetailCreateRelationship = Test_Environment_Utility.createInsertWebServiceDetails('Create Relationship');

        //Create seed unit orders for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Enterprise', oAccountReseller, oContactReseller);
        oSeedUnitOrder.Ship_To_Customer_Account_new__c = oCustomerAccount.Id;
        oSeedUnitOrder.Ship_To_Address1__c = 'Test Address1';
        oSeedUnitOrder.Ship_To_Address2__c = 'Test Address2';
        oSeedUnitOrder.Ship_To_Address3__c = 'Test Address3';
        oSeedUnitOrder.Ship_To_Address4__c = 'Test Address4';
        oSeedUnitOrder.Ship_To_City__c = 'Test City';
        oSeedUnitOrder.Ship_To_State_Province__c = 'BC';
        oSeedUnitOrder.Ship_To_Postal_Code__c = 'X1B 4Y7';
        oSeedUnitOrder.Ship_To_Country__c = 'Canada-CA';
        update oSeedUnitOrder;
        //Create products for testing
        Product2 oProductEligible = Test_Environment_Utility.createInsertProduct();
        oProductEligible.Seed_Unit_Eligible_Enterprise__c=true;
        update oProductEligible;
        //Create seed unit products for testing
        Seed_Unit_Product__c oSeedUnitProductEligible = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProductEligible, 5);
        
        Test.startTest();
            //Retrieve newly created Account, Customer_Account__c, Seed_Unit_Order__c and Integration_Id__c fields needed for HTTP response.
            oIntegrationIdBillTo = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationIdBillTo.Id];              
            oAccountEndUser = [select Id, Name from Account where Id = :oAccountEndUser.Id];
            
            //Query for seed unit order created above in order to retrieve formula field values
            oSeedUnitOrder = [select Id, Sold_To_Org_new__c, Opportunity__c, Opportunity__r.Account.ParentId, Opportunity__r.AccountId, Name, Seed_Unit_Order_Submitted__c, Seed_Unit_Approval_Status__c,
                                Opportunity__r.Account.BillingStreet, Opportunity__r.Account.BillingCity, Opportunity__r.Account.BillingStateCode, Opportunity__r.Account.BillingPostalCode, Ship_To_Country__c,
                                Opportunity__r.Account.BillingCountryCode, Seed_Unit_Location_Type__c, Opportunity__r.Account.Parent.ParentId, Opportunity__r.Account.Name, Ship_To_Org_Id__c,
                                Ship_To_Address4__c, Ship_To_Address3__c, Ship_To_Address2__c, Sold_To_Salesforce_Id__c, Opportunity__r.Account.Id, Sold_To_Party_Name__c, Ship_To_County__c, Ship_To_Address__c,
                                Ship_To_Address1__c, Ship_To_City__c, ORIG_SYS_DOCUMENT_REF__c, Sold_To_Party_Id__c, Sold_To_Org_Id__c, Ship_To_State_Province__c, Ship_To_Postal_Code__c, Ship_To_Contact_First_Name__c,
                                Ship_To_Contact_Last_Name__c, Ship_To_Contact_Email__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Role_Id__c, Ship_To_Account__r.Name, Ship_To_Salesforce_Id__c,
                                Ship_To_Customer_Account_Id__c, Ship_To_Party_Id__c, Ship_To_Party_Name__c, Ship_To_Contact__c
                                from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];

            //Set up response since web service callouts are not allowed from test classes
            SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(200,
                                                            'OK',
                '{'+
                '  \"__type\": \"RepLocator.Customer\",'+
                '  \"ip_verification_id\": \"' + oIntegrationIdBillTo.Security_Id__c + '\",'+
                '  \"ip_party_id\": \"\",'+
                '  \"ip_cust_account_id\": \"\",'+
                '  \"ip_ship_to_site_use_id\": \"\",'+
                '  \"ip_organization_name\": \"' + oAccountEndUser.Name + '\",'+
                '  \"ip_account_name\": \"CANADA\",'+
                '  \"ip_address1\": \"' + oSeedUnitOrder.Ship_To_Address1__c + '\",'+
                '  \"ip_address2\": \"' + oSeedUnitOrder.Ship_To_Address2__c + '\",'+
                '  \"ip_address3\": \"' + oSeedUnitOrder.Ship_To_Address3__c + '\",'+
                '  \"ip_address4\": \"' + oSeedUnitOrder.Ship_To_Address4__c + '\",'+
                '  \"ip_city\": \"' + oSeedUnitOrder.Ship_To_City__c + '\",'+
                '  \"ip_state\": \"' + oSeedUnitOrder.Ship_To_Country__c + '\",'+
                '  \"ip_province\": \"' + oSeedUnitOrder.Ship_To_State_Province__c + '\",'+
                '  \"ip_postal_code\": \"' + oSeedUnitOrder.Ship_To_Postal_Code__c + '\",'+
                '  \"ip_country\": \"' + oSeedUnitOrder.Ship_To_Country__c + '\",'+
                '  \"ip_county\": \"\",'+
                '  \"ip_person_first_name\": \"CHRIS\",'+
                '  \"ip_person_last_name\": \"NOE\",'+
                '  \"ip_raw_phone_number\": \"9522231265\",'+
                '  \"ip_email_address\": \"CNOE@ERGOTRON.COM\",'+
                '  \"ip_is_bill_to_address\": \"\",'+
                '  \"ip_is_ship_to_address\": \"Y\",'+
                '  \"ip_salesforce_ref_id\": \"' + oSeedUnitOrder.Id + '\",'+
                '  \"op_party_id\": \"187267221\",'+
                '  \"op_party_number\": \"\",'+
                '  \"op_cust_account_id\": \"16762542\",'+
                '  \"op_ship_to_site_use_id\": \"19099009\",'+
                '  \"op_bill_to_site_use_id\": \"\",'+
                '  \"op_ship_to_contact_id\": \"21046994\",'+
                '  \"op_cust_account_role_id\": \"19300030\",'+
                '  \"op_return_status\": \"\",'+
                '  \"op_return_message\": \"\"'+
                '}'
                 , null);
            Test.setMock(HttpCalloutMock.class, oFakeResponse); 
            
            //Create PageReference to the SeedUnitOrderConfirmation
            PageReference oPageRef = Page.SeedUnitOrderConfirmation;
            Test.setCurrentPage(oPageRef);

            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            ApexPages.currentPage().getParameters().put('id',oSeedUnitOrder.id);
            Seed_Unit_Order_Confirmation_Controller oExtController = new Seed_Unit_Order_Confirmation_Controller(oStdController);
            
            oPageRef = oExtController.orderConfirmationSubmit();        
        Test.stopTest();
    }                                                                                                                                                    

    static testMethod void orderConfirmationSubmitNewShipExistingBillToCustomerCN() {
        //Tests the Seed_Unit_Order_Confirmation_Controller.orderConfirmationSubmit method for new ship to and existing bill to customer (different ship to bill to) - CN Customer
        //End User (bill to) Party and Customer Exists
        //Reseller (ship to) Party and Customer do not exist
        String sPartyIdentifier = 'ERGO' + String.valueOf(math.random()).left(20);
        //Create accounts for testing
        Account oAccountEndUser = Test_Environment_Utility.createInsertAccountCN();
        oAccountEndUser.Oracle_Party_Id__c=sPartyIdentifier;
        oAccountEndUser.Oracle_Party_Number__c=sPartyIdentifier;
        update oAccountEndUser;
        Account oAccountReseller = Test_Environment_Utility.createInsertAccountCN();
        //Create Customer_Account__c for testing
        Account oCustomerAccount = Test_Environment_Utility.createInsertAccountUS();
        //Create Contact for testing
        Contact oContactReseller = Test_Environment_Utility.createInsertContact(oAccountReseller);
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccountEndUser, 'Seeding', Date.today());
        
        //Create Integrations Id for testing
        Integration_Id__c oIntegrationIdBillTo = Test_Environment_Utility.createInsertIntegrationId();
        Integration_Id__c oIntegrationIdShipTo = Test_Environment_Utility.createInsertIntegrationId();
        Integration_Id__c oIntegrationIdRelationship = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetailCreateCustomer = Test_Environment_Utility.createInsertWebServiceDetails('Create Customer');
        Web_Service_Details__c oWebServiceDetailCreateRelationship = Test_Environment_Utility.createInsertWebServiceDetails('Create Relationship');

        //Create seed unit orders for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Enterprise', oAccountReseller, oContactReseller);
        oSeedUnitOrder.Sold_To_Org_new__c = oCustomerAccount.Id;
        oSeedUnitOrder.Ship_To_Address1__c = 'Test Address1';
        oSeedUnitOrder.Ship_To_Address2__c = 'Test Address2';
        oSeedUnitOrder.Ship_To_Address3__c = 'Test Address3';
        oSeedUnitOrder.Ship_To_Address4__c = 'Test Address4';
        oSeedUnitOrder.Ship_To_City__c = 'Test City';
        oSeedUnitOrder.Ship_To_State_Province__c = 'BJ';
        oSeedUnitOrder.Ship_To_Postal_Code__c = 'X1B 4Y7';
        oSeedUnitOrder.Ship_To_Country__c = 'CN';
        update oSeedUnitOrder;
        //Create products for testing
        Product2 oProductEligible = Test_Environment_Utility.createInsertProduct();
        oProductEligible.Seed_Unit_Eligible_Enterprise__c=true;
        update oProductEligible;
        //Create seed unit products for testing
        Seed_Unit_Product__c oSeedUnitProductEligible = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProductEligible, 5);
        
        Test.startTest();
            //Retrieve newly created Account, Customer_Account__c, Seed_Unit_Order__c and Integration_Id__c fields needed for HTTP response.
            oIntegrationIdShipTo = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationIdShipTo.Id];              
            oAccountReseller = [select Id, Name from Account where Id = :oAccountReseller.Id];
            
            //Query for seed unit order created above in order to retrieve formula field values
            oSeedUnitOrder = [select Id, Sold_To_Org_new__c, Opportunity__c, Opportunity__r.Account.ParentId, Opportunity__r.AccountId, Name, Seed_Unit_Order_Submitted__c, Seed_Unit_Approval_Status__c,
                                Opportunity__r.Account.BillingStreet, Opportunity__r.Account.BillingCity, Opportunity__r.Account.BillingStateCode, Opportunity__r.Account.BillingPostalCode, Ship_To_Country__c,
                                Opportunity__r.Account.BillingCountryCode, Seed_Unit_Location_Type__c, Opportunity__r.Account.Parent.ParentId, Opportunity__r.Account.Name, Ship_To_Org_Id__c,
                                Ship_To_Address4__c, Ship_To_Address3__c, Ship_To_Address2__c, Sold_To_Salesforce_Id__c, Opportunity__r.Account.Id, Sold_To_Party_Name__c, Ship_To_County__c, Ship_To_Address__c,
                                Ship_To_Address1__c, Ship_To_City__c, ORIG_SYS_DOCUMENT_REF__c, Sold_To_Party_Id__c, Sold_To_Org_Id__c, Ship_To_State_Province__c, Ship_To_Postal_Code__c, Ship_To_Contact_First_Name__c,
                                Ship_To_Contact_Last_Name__c, Ship_To_Contact_Email__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Role_Id__c, Ship_To_Account__r.Name, Ship_To_Salesforce_Id__c,
                                Ship_To_Customer_Account_Id__c, Ship_To_Party_Id__c, Ship_To_Party_Name__c, Ship_To_Contact__c
                                from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];

            //Set up response since web service callouts are not allowed from test classes
            SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(200,
                                                            'OK',
                '{'+
                '  \"__type\": \"RepLocator.Customer\",'+
                '  \"ip_verification_id\": \"' + oIntegrationIdShipTo.Security_Id__c + '\",'+
                '  \"ip_party_id\": \"\",'+
                '  \"ip_cust_account_id\": \"\",'+
                '  \"ip_ship_to_site_use_id\": \"\",'+
                '  \"ip_organization_name\": \"' + oAccountReseller.Name + '\",'+
                '  \"ip_account_name\": \"INTERNATIONAL\",'+
                '  \"ip_address1\": \"' + oSeedUnitOrder.Ship_To_Address1__c + '\",'+
                '  \"ip_address2\": \"' + oSeedUnitOrder.Ship_To_Address2__c + '\",'+
                '  \"ip_address3\": \"' + oSeedUnitOrder.Ship_To_Address3__c + '\",'+
                '  \"ip_address4\": \"' + oSeedUnitOrder.Ship_To_Address4__c + '\",'+
                '  \"ip_city\": \"' + oSeedUnitOrder.Ship_To_City__c + '\",'+
                '  \"ip_state\": \"' + oSeedUnitOrder.Ship_To_Country__c + '\",'+
                '  \"ip_province\": \"' + oSeedUnitOrder.Ship_To_State_Province__c + '\",'+
                '  \"ip_postal_code\": \"' + oSeedUnitOrder.Ship_To_Postal_Code__c + '\",'+
                '  \"ip_country\": \"' + oSeedUnitOrder.Ship_To_Country__c + '\",'+
                '  \"ip_county\": \"\",'+
                '  \"ip_person_first_name\": \"CHRIS\",'+
                '  \"ip_person_last_name\": \"NOE\",'+
                '  \"ip_raw_phone_number\": \"9522231265\",'+
                '  \"ip_email_address\": \"CNOE@ERGOTRON.COM\",'+
                '  \"ip_is_bill_to_address\": \"\",'+
                '  \"ip_is_ship_to_address\": \"Y\",'+
                '  \"ip_salesforce_ref_id\": \"' + oSeedUnitOrder.Id + '\",'+
                '  \"op_party_id\": \"187267221\",'+
                '  \"op_party_number\": \"\",'+
                '  \"op_cust_account_id\": \"16762542\",'+
                '  \"op_ship_to_site_use_id\": \"19099009\",'+
                '  \"op_bill_to_site_use_id\": \"\",'+
                '  \"op_ship_to_contact_id\": \"21046994\",'+
                '  \"op_cust_account_role_id\": \"19300030\",'+
                '  \"op_return_status\": \"\",'+
                '  \"op_return_message\": \"\"'+
                '}'
                 , null);
            Test.setMock(HttpCalloutMock.class, oFakeResponse); 
            
            //Create PageReference to the SeedUnitOrderConfirmation
            PageReference oPageRef = Page.SeedUnitOrderConfirmation;
            Test.setCurrentPage(oPageRef);

            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            ApexPages.currentPage().getParameters().put('id',oSeedUnitOrder.id);
            Seed_Unit_Order_Confirmation_Controller oExtController = new Seed_Unit_Order_Confirmation_Controller(oStdController);
            
            oPageRef = oExtController.orderConfirmationSubmit();        
        Test.stopTest();
    }

    static testMethod void orderConfirmationSubmitExistingShipNewBillToCustomerCN() {
        //Tests the Seed_Unit_Order_Confirmation_Controller.orderConfirmationSubmit method for new ship to and bill to customer (different ship to bill to) - CN Customer
        //End User Party and Customer does not exist
        //Reseller (ship to) Party and Customer do exist, new address required
        String sPartyIdentifier = 'ERGO' + String.valueOf(math.random()).left(20);
        //Create accounts for testing
        Account oAccountEndUser = Test_Environment_Utility.createInsertAccountCN();
        Account oAccountReseller = Test_Environment_Utility.createInsertAccountCN();
        oAccountReseller.Oracle_Party_Id__c=sPartyIdentifier;
        oAccountReseller.Oracle_Party_Number__c=sPartyIdentifier;
        update oAccountReseller;
        //Create Customer_Account__c for testing
        Account oCustomerAccount = Test_Environment_Utility.createInsertAccountUS();
        //Create Contact for testing
        Contact oContactReseller = Test_Environment_Utility.createInsertContact(oAccountReseller);
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccountEndUser, 'Seeding', Date.today());
        
        //Create Integrations Id for testing
        Integration_Id__c oIntegrationIdBillTo = Test_Environment_Utility.createInsertIntegrationId();
        Integration_Id__c oIntegrationIdShipTo = Test_Environment_Utility.createInsertIntegrationId();
        Integration_Id__c oIntegrationIdRelationship = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetailCreateCustomer = Test_Environment_Utility.createInsertWebServiceDetails('Create Customer');
        Web_Service_Details__c oWebServiceDetailCreateRelationship = Test_Environment_Utility.createInsertWebServiceDetails('Create Relationship');

        //Create seed unit orders for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Enterprise', oAccountReseller, oContactReseller);
        oSeedUnitOrder.Ship_To_Customer_Account_new__c = oCustomerAccount.Id;
        oSeedUnitOrder.Ship_To_Address1__c = 'Test Address1';
        oSeedUnitOrder.Ship_To_Address2__c = 'Test Address2';
        oSeedUnitOrder.Ship_To_Address3__c = 'Test Address3';
        oSeedUnitOrder.Ship_To_Address4__c = 'Test Address4';
        oSeedUnitOrder.Ship_To_City__c = 'Test City';
        oSeedUnitOrder.Ship_To_State_Province__c = 'BJ';
        oSeedUnitOrder.Ship_To_Postal_Code__c = 'X1B 4Y7';
        oSeedUnitOrder.Ship_To_Country__c = 'CN';
        update oSeedUnitOrder;
        //Create products for testing
        Product2 oProductEligible = Test_Environment_Utility.createInsertProduct();
        oProductEligible.Seed_Unit_Eligible_Enterprise__c=true;
        update oProductEligible;
        //Create seed unit products for testing
        Seed_Unit_Product__c oSeedUnitProductEligible = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProductEligible, 5);
        
        Test.startTest();
            //Retrieve newly created Account, Customer_Account__c, Seed_Unit_Order__c and Integration_Id__c fields needed for HTTP response.
            oIntegrationIdBillTo = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationIdBillTo.Id];              
            oAccountEndUser = [select Id, Name from Account where Id = :oAccountEndUser.Id];
            
            //Query for seed unit order created above in order to retrieve formula field values
            oSeedUnitOrder = [select Id, Sold_To_Org_new__c, Opportunity__c, Opportunity__r.Account.ParentId, Opportunity__r.AccountId, Name, Seed_Unit_Order_Submitted__c, Seed_Unit_Approval_Status__c,
                                Opportunity__r.Account.BillingStreet, Opportunity__r.Account.BillingCity, Opportunity__r.Account.BillingStateCode, Opportunity__r.Account.BillingPostalCode, Ship_To_Country__c,
                                Opportunity__r.Account.BillingCountryCode, Seed_Unit_Location_Type__c, Opportunity__r.Account.Parent.ParentId, Opportunity__r.Account.Name, Ship_To_Org_Id__c,
                                Ship_To_Address4__c, Ship_To_Address3__c, Ship_To_Address2__c, Sold_To_Salesforce_Id__c, Opportunity__r.Account.Id, Sold_To_Party_Name__c, Ship_To_County__c, Ship_To_Address__c,
                                Ship_To_Address1__c, Ship_To_City__c, ORIG_SYS_DOCUMENT_REF__c, Sold_To_Party_Id__c, Sold_To_Org_Id__c, Ship_To_State_Province__c, Ship_To_Postal_Code__c, Ship_To_Contact_First_Name__c,
                                Ship_To_Contact_Last_Name__c, Ship_To_Contact_Email__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Role_Id__c, Ship_To_Account__r.Name, Ship_To_Salesforce_Id__c,
                                Ship_To_Customer_Account_Id__c, Ship_To_Party_Id__c, Ship_To_Party_Name__c, Ship_To_Contact__c
                                from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];

            //Set up response since web service callouts are not allowed from test classes
            SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(200,
                                                            'OK',
                '{'+
                '  \"__type\": \"RepLocator.Customer\",'+
                '  \"ip_verification_id\": \"' + oIntegrationIdBillTo.Security_Id__c + '\",'+
                '  \"ip_party_id\": \"\",'+
                '  \"ip_cust_account_id\": \"\",'+
                '  \"ip_ship_to_site_use_id\": \"\",'+
                '  \"ip_organization_name\": \"' + oAccountEndUser.Name + '\",'+
                '  \"ip_account_name\": \"INTERNATIONAL\",'+
                '  \"ip_address1\": \"' + oSeedUnitOrder.Ship_To_Address1__c + '\",'+
                '  \"ip_address2\": \"' + oSeedUnitOrder.Ship_To_Address2__c + '\",'+
                '  \"ip_address3\": \"' + oSeedUnitOrder.Ship_To_Address3__c + '\",'+
                '  \"ip_address4\": \"' + oSeedUnitOrder.Ship_To_Address4__c + '\",'+
                '  \"ip_city\": \"' + oSeedUnitOrder.Ship_To_City__c + '\",'+
                '  \"ip_state\": \"' + oSeedUnitOrder.Ship_To_Country__c + '\",'+
                '  \"ip_province\": \"' + oSeedUnitOrder.Ship_To_State_Province__c + '\",'+
                '  \"ip_postal_code\": \"' + oSeedUnitOrder.Ship_To_Postal_Code__c + '\",'+
                '  \"ip_country\": \"' + oSeedUnitOrder.Ship_To_Country__c + '\",'+
                '  \"ip_county\": \"\",'+
                '  \"ip_person_first_name\": \"CHRIS\",'+
                '  \"ip_person_last_name\": \"NOE\",'+
                '  \"ip_raw_phone_number\": \"9522231265\",'+
                '  \"ip_email_address\": \"CNOE@ERGOTRON.COM\",'+
                '  \"ip_is_bill_to_address\": \"\",'+
                '  \"ip_is_ship_to_address\": \"Y\",'+
                '  \"ip_salesforce_ref_id\": \"' + oSeedUnitOrder.Id + '\",'+
                '  \"op_party_id\": \"187267221\",'+
                '  \"op_party_number\": \"\",'+
                '  \"op_cust_account_id\": \"16762542\",'+
                '  \"op_ship_to_site_use_id\": \"19099009\",'+
                '  \"op_bill_to_site_use_id\": \"\",'+
                '  \"op_ship_to_contact_id\": \"21046994\",'+
                '  \"op_cust_account_role_id\": \"19300030\",'+
                '  \"op_return_status\": \"\",'+
                '  \"op_return_message\": \"\"'+
                '}'
                 , null);
            Test.setMock(HttpCalloutMock.class, oFakeResponse); 
            
            //Create PageReference to the SeedUnitOrderConfirmation
            PageReference oPageRef = Page.SeedUnitOrderConfirmation;
            Test.setCurrentPage(oPageRef);

            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            ApexPages.currentPage().getParameters().put('id',oSeedUnitOrder.id);
            Seed_Unit_Order_Confirmation_Controller oExtController = new Seed_Unit_Order_Confirmation_Controller(oStdController);
            
            oPageRef = oExtController.orderConfirmationSubmit();        
        Test.stopTest();
    }

    static testMethod void orderConfirmationSubmitExistingShipNoAddressNewBillToCustomerUS() {
        //Tests the Seed_Unit_Order_Confirmation_Controller.orderConfirmationSubmit method for new ship to and bill to customer (different ship to bill to) - US Customer
        //End User Party and Customer does not exist
        //Reseller (ship to) Party and Customer do exist, new address not required
        String sPartyIdentifier = 'ERGO' + String.valueOf(math.random()).left(20);
        //Create accounts for testing
        Account oAccountEndUser = Test_Environment_Utility.createInsertAccountUS();
        Account oAccountReseller = Test_Environment_Utility.createInsertAccountUS();
        oAccountReseller.Oracle_Party_Id__c=sPartyIdentifier;
        oAccountReseller.Oracle_Party_Number__c=sPartyIdentifier;
        update oAccountReseller;
        //Create Customer_Account__c for testing
        Account oCustomerAccount = Test_Environment_Utility.createInsertAccountUS();
        //Create Contact for testing
        Contact oContactReseller = Test_Environment_Utility.createInsertContact(oAccountReseller);
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccountEndUser, 'Seeding', Date.today());
        
        //Create Integrations Id for testing
        Integration_Id__c oIntegrationIdBillTo = Test_Environment_Utility.createInsertIntegrationId();
        Integration_Id__c oIntegrationIdShipTo = Test_Environment_Utility.createInsertIntegrationId();
        Integration_Id__c oIntegrationIdRelationship = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetailCreateCustomer = Test_Environment_Utility.createInsertWebServiceDetails('Create Customer');
        Web_Service_Details__c oWebServiceDetailCreateRelationship = Test_Environment_Utility.createInsertWebServiceDetails('Create Relationship');

        //Create seed unit orders for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Enterprise', oAccountReseller, oContactReseller);
        oSeedUnitOrder.Ship_To_Customer_Account_new__c = oCustomerAccount.Id;
        oSeedUnitOrder.Ship_To_Org_Id__c = String.valueOf(math.random()).left(20);
        update oSeedUnitOrder;
        //Create products for testing
        Product2 oProductEligible = Test_Environment_Utility.createInsertProduct();
        oProductEligible.Seed_Unit_Eligible_Enterprise__c=true;
        update oProductEligible;
        //Create seed unit products for testing
        Seed_Unit_Product__c oSeedUnitProductEligible = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProductEligible, 5);
        
        Test.startTest();
            //Retrieve newly created Account, Customer_Account__c, Seed_Unit_Order__c and Integration_Id__c fields needed for HTTP response.
            oIntegrationIdBillTo = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationIdBillTo.Id];              
            oAccountEndUser = [select Id, Name from Account where Id = :oAccountEndUser.Id];
            
            //Query for seed unit order created above in order to retrieve formula field values
            oSeedUnitOrder = [select Id, Sold_To_Org_new__c, Opportunity__c, Opportunity__r.Account.ParentId, Opportunity__r.AccountId, Name, Seed_Unit_Order_Submitted__c, Seed_Unit_Approval_Status__c,
                                Opportunity__r.Account.BillingStreet, Opportunity__r.Account.BillingCity, Opportunity__r.Account.BillingStateCode, Opportunity__r.Account.BillingPostalCode, Ship_To_Country__c,
                                Opportunity__r.Account.BillingCountryCode, Seed_Unit_Location_Type__c, Opportunity__r.Account.Parent.ParentId, Opportunity__r.Account.Name, Ship_To_Org_Id__c,
                                Ship_To_Address4__c, Ship_To_Address3__c, Ship_To_Address2__c, Sold_To_Salesforce_Id__c, Opportunity__r.Account.Id, Sold_To_Party_Name__c, Ship_To_County__c, Ship_To_Address__c,
                                Ship_To_Address1__c, Ship_To_City__c, ORIG_SYS_DOCUMENT_REF__c, Sold_To_Party_Id__c, Sold_To_Org_Id__c, Ship_To_State_Province__c, Ship_To_Postal_Code__c, Ship_To_Contact_First_Name__c,
                                Ship_To_Contact_Last_Name__c, Ship_To_Contact_Email__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Role_Id__c, Ship_To_Account__r.Name, Ship_To_Salesforce_Id__c,
                                Ship_To_Customer_Account_Id__c, Ship_To_Party_Id__c, Ship_To_Party_Name__c, Ship_To_Contact__c
                                from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];

            //Set up response since web service callouts are not allowed from test classes
            SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(200,
                                                            'OK',
                '{'+
                '  \"__type\": \"RepLocator.Customer\",'+
                '  \"ip_verification_id\": \"' + oIntegrationIdBillTo.Security_Id__c + '\",'+
                '  \"ip_party_id\": \"\",'+
                '  \"ip_cust_account_id\": \"\",'+
                '  \"ip_ship_to_site_use_id\": \"\",'+
                '  \"ip_organization_name\": \"' + oAccountEndUser.Name + '\",'+
                '  \"ip_account_name\": \"DOMESTIC\",'+
                '  \"ip_address1\": \"' + oSeedUnitOrder.Ship_To_Address1__c + '\",'+
                '  \"ip_address2\": \"' + oSeedUnitOrder.Ship_To_Address2__c + '\",'+
                '  \"ip_address3\": \"' + oSeedUnitOrder.Ship_To_Address3__c + '\",'+
                '  \"ip_address4\": \"' + oSeedUnitOrder.Ship_To_Address4__c + '\",'+
                '  \"ip_city\": \"' + oSeedUnitOrder.Ship_To_City__c + '\",'+
                '  \"ip_state\": \"' + oSeedUnitOrder.Ship_To_Country__c + '\",'+
                '  \"ip_province\": \"' + oSeedUnitOrder.Ship_To_State_Province__c + '\",'+
                '  \"ip_postal_code\": \"' + oSeedUnitOrder.Ship_To_Postal_Code__c + '\",'+
                '  \"ip_country\": \"' + oSeedUnitOrder.Ship_To_Country__c + '\",'+
                '  \"ip_county\": \"\",'+
                '  \"ip_person_first_name\": \"CHRIS\",'+
                '  \"ip_person_last_name\": \"NOE\",'+
                '  \"ip_raw_phone_number\": \"9522231265\",'+
                '  \"ip_email_address\": \"CNOE@ERGOTRON.COM\",'+
                '  \"ip_is_bill_to_address\": \"\",'+
                '  \"ip_is_ship_to_address\": \"Y\",'+
                '  \"ip_salesforce_ref_id\": \"' + oSeedUnitOrder.Id + '\",'+
                '  \"op_party_id\": \"187267221\",'+
                '  \"op_party_number\": \"\",'+
                '  \"op_cust_account_id\": \"16762542\",'+
                '  \"op_ship_to_site_use_id\": \"19099009\",'+
                '  \"op_bill_to_site_use_id\": \"\",'+
                '  \"op_ship_to_contact_id\": \"21046994\",'+
                '  \"op_cust_account_role_id\": \"19300030\",'+
                '  \"op_return_status\": \"\",'+
                '  \"op_return_message\": \"\"'+
                '}'
                 , null);
            Test.setMock(HttpCalloutMock.class, oFakeResponse); 
            
            //Create PageReference to the SeedUnitOrderConfirmation
            PageReference oPageRef = Page.SeedUnitOrderConfirmation;
            Test.setCurrentPage(oPageRef);

            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            ApexPages.currentPage().getParameters().put('id',oSeedUnitOrder.id);
            Seed_Unit_Order_Confirmation_Controller oExtController = new Seed_Unit_Order_Confirmation_Controller(oStdController);
            
            oPageRef = oExtController.orderConfirmationSubmit();        
        Test.stopTest();
    }

    static testMethod void orderConfirmationSubmitExistingShipNewBillToCustomerExistingBillToPartyUS() {
        //Tests the Seed_Unit_Order_Confirmation_Controller.orderConfirmationSubmit method for new ship to and bill to customer (different ship to bill to) - US Customer
        //End User Party and Customer does not exist
        //Reseller (ship to) Party and Customer do exist, new address required
        String sPartyIdentifierEndUser = 'ERGO' + String.valueOf(math.random()).left(20);
        String sPartyIdentifierReseller = 'ERGO' + String.valueOf(math.random()).left(20);
        //Create accounts for testing
        Account oAccountEndUser = Test_Environment_Utility.createInsertAccountUS();
        oAccountEndUser.Oracle_Party_Id__c = sPartyIdentifierEndUser;
        oAccountEndUser.Oracle_Party_Number__c = sPartyIdentifierEndUser;
        update oAccountEndUser;
        Account oAccountReseller = Test_Environment_Utility.createInsertAccountUS();
        oAccountReseller.Oracle_Party_Id__c=sPartyIdentifierReseller;
        oAccountReseller.Oracle_Party_Number__c=sPartyIdentifierReseller;
        update oAccountReseller;
        //Create Customer_Account__c for testing
        Account oCustomerAccount = Test_Environment_Utility.createInsertAccountUS();
        //Create Contact for testing
        Contact oContactReseller = Test_Environment_Utility.createInsertContact(oAccountReseller);
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccountEndUser, 'Seeding', Date.today());
        
        //Create Integrations Id for testing
        Integration_Id__c oIntegrationIdBillTo = Test_Environment_Utility.createInsertIntegrationId();
        Integration_Id__c oIntegrationIdShipTo = Test_Environment_Utility.createInsertIntegrationId();
        Integration_Id__c oIntegrationIdRelationship = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetailCreateCustomer = Test_Environment_Utility.createInsertWebServiceDetails('Create Customer');
        Web_Service_Details__c oWebServiceDetailCreateRelationship = Test_Environment_Utility.createInsertWebServiceDetails('Create Relationship');

        //Create seed unit orders for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Enterprise', oAccountReseller, oContactReseller);
        oSeedUnitOrder.Ship_To_Customer_Account_new__c = oCustomerAccount.Id;
        oSeedUnitOrder.Ship_To_Org_Id__c = String.valueOf(math.random()).left(20);
        oSeedUnitOrder.Ship_To_Contact_Role_Id__c = String.valueOf(math.random()).left(20);
        update oSeedUnitOrder;
        //Create products for testing
        Product2 oProductEligible = Test_Environment_Utility.createInsertProduct();
        oProductEligible.Seed_Unit_Eligible_Enterprise__c=true;
        update oProductEligible;
        //Create seed unit products for testing
        Seed_Unit_Product__c oSeedUnitProductEligible = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProductEligible, 5);
        
        Test.startTest();
            //Retrieve newly created Account, Customer_Account__c, Seed_Unit_Order__c and Integration_Id__c fields needed for HTTP response.
            oIntegrationIdBillTo = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationIdBillTo.Id];              
            oAccountEndUser = [select Id, Name from Account where Id = :oAccountEndUser.Id];
            
            //Query for seed unit order created above in order to retrieve formula field values
            oSeedUnitOrder = [select Id, Sold_To_Org_new__c, Opportunity__c, Opportunity__r.Account.ParentId, Opportunity__r.AccountId, Name, Seed_Unit_Order_Submitted__c, Seed_Unit_Approval_Status__c,
                                Opportunity__r.Account.BillingStreet, Opportunity__r.Account.BillingCity, Opportunity__r.Account.BillingStateCode, Opportunity__r.Account.BillingPostalCode, Ship_To_Country__c,
                                Opportunity__r.Account.BillingCountryCode, Seed_Unit_Location_Type__c, Opportunity__r.Account.Parent.ParentId, Opportunity__r.Account.Name, Ship_To_Org_Id__c,
                                Ship_To_Address4__c, Ship_To_Address3__c, Ship_To_Address2__c, Sold_To_Salesforce_Id__c, Opportunity__r.Account.Id, Sold_To_Party_Name__c, Ship_To_County__c, Ship_To_Address__c,
                                Ship_To_Address1__c, Ship_To_City__c, ORIG_SYS_DOCUMENT_REF__c, Sold_To_Party_Id__c, Sold_To_Org_Id__c, Ship_To_State_Province__c, Ship_To_Postal_Code__c, Ship_To_Contact_First_Name__c,
                                Ship_To_Contact_Last_Name__c, Ship_To_Contact_Email__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Role_Id__c, Ship_To_Account__r.Name, Ship_To_Salesforce_Id__c,
                                Ship_To_Customer_Account_Id__c, Ship_To_Party_Id__c, Ship_To_Party_Name__c, Ship_To_Contact__c
                                from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];

            //Set up response since web service callouts are not allowed from test classes
            SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(200,
                                                            'OK',
                '{'+
                '  \"__type\": \"RepLocator.Customer\",'+
                '  \"ip_verification_id\": \"' + oIntegrationIdBillTo.Security_Id__c + '\",'+
                '  \"ip_party_id\": \"\",'+
                '  \"ip_cust_account_id\": \"\",'+
                '  \"ip_ship_to_site_use_id\": \"\",'+
                '  \"ip_organization_name\": \"' + oAccountEndUser.Name + '\",'+
                '  \"ip_account_name\": \"DOMESTIC\",'+
                '  \"ip_address1\": \"' + oSeedUnitOrder.Ship_To_Address1__c + '\",'+
                '  \"ip_address2\": \"' + oSeedUnitOrder.Ship_To_Address2__c + '\",'+
                '  \"ip_address3\": \"' + oSeedUnitOrder.Ship_To_Address3__c + '\",'+
                '  \"ip_address4\": \"' + oSeedUnitOrder.Ship_To_Address4__c + '\",'+
                '  \"ip_city\": \"' + oSeedUnitOrder.Ship_To_City__c + '\",'+
                '  \"ip_state\": \"' + oSeedUnitOrder.Ship_To_Country__c + '\",'+
                '  \"ip_province\": \"' + oSeedUnitOrder.Ship_To_State_Province__c + '\",'+
                '  \"ip_postal_code\": \"' + oSeedUnitOrder.Ship_To_Postal_Code__c + '\",'+
                '  \"ip_country\": \"' + oSeedUnitOrder.Ship_To_Country__c + '\",'+
                '  \"ip_county\": \"\",'+
                '  \"ip_person_first_name\": \"CHRIS\",'+
                '  \"ip_person_last_name\": \"NOE\",'+
                '  \"ip_raw_phone_number\": \"9522231265\",'+
                '  \"ip_email_address\": \"CNOE@ERGOTRON.COM\",'+
                '  \"ip_is_bill_to_address\": \"\",'+
                '  \"ip_is_ship_to_address\": \"Y\",'+
                '  \"ip_salesforce_ref_id\": \"' + oSeedUnitOrder.Id + '\",'+
                '  \"op_party_id\": \"187267221\",'+
                '  \"op_party_number\": \"\",'+
                '  \"op_cust_account_id\": \"16762542\",'+
                '  \"op_ship_to_site_use_id\": \"19099009\",'+
                '  \"op_bill_to_site_use_id\": \"\",'+
                '  \"op_ship_to_contact_id\": \"21046994\",'+
                '  \"op_cust_account_role_id\": \"19300030\",'+
                '  \"op_return_status\": \"\",'+
                '  \"op_return_message\": \"\"'+
                '}'
                 , null);
            Test.setMock(HttpCalloutMock.class, oFakeResponse); 
            
            //Create PageReference to the SeedUnitOrderConfirmation
            PageReference oPageRef = Page.SeedUnitOrderConfirmation;
            Test.setCurrentPage(oPageRef);

            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            ApexPages.currentPage().getParameters().put('id',oSeedUnitOrder.id);
            Seed_Unit_Order_Confirmation_Controller oExtController = new Seed_Unit_Order_Confirmation_Controller(oStdController);
            
            oPageRef = oExtController.orderConfirmationSubmit();        
        Test.stopTest();
    }

    static testMethod void orderConfirmationSubmitWSCalloutExceptionSoldTo() {
        //Tests the Seed_Unit_Order_Confirmation_Controller.orderConfirmationSubmit method for a web service callout exception when creating new sold to account
        
        String sPartyIdentifier = 'ERGO' + String.valueOf(math.random()).left(20);
        //Create accounts for testing
        Account oAccountEndUser = Test_Environment_Utility.createInsertAccountUS();
        Account oAccountReseller = Test_Environment_Utility.createInsertAccountUS();
        oAccountReseller.Oracle_Party_Id__c=sPartyIdentifier;
        oAccountReseller.Oracle_Party_Number__c=sPartyIdentifier;
        update oAccountReseller;
        //Create Customer_Account__c for testing
        Account oCustomerAccount = Test_Environment_Utility.createInsertAccountUS();
        //Create Contact for testing
        Contact oContactReseller = Test_Environment_Utility.createInsertContact(oAccountReseller);
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccountEndUser, 'Seeding', Date.today());
        
        //Create Integrations Id for testing
        Integration_Id__c oIntegrationIdBillTo = Test_Environment_Utility.createInsertIntegrationId();
        Integration_Id__c oIntegrationIdShipTo = Test_Environment_Utility.createInsertIntegrationId();
        Integration_Id__c oIntegrationIdRelationship = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetailCreateCustomer = Test_Environment_Utility.createInsertWebServiceDetails('Create Customer');
        Web_Service_Details__c oWebServiceDetailCreateRelationship = Test_Environment_Utility.createInsertWebServiceDetails('Create Relationship');

        //Create seed unit orders for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Enterprise', oAccountReseller, oContactReseller);
        oSeedUnitOrder.Ship_To_Customer_Account_new__c = oCustomerAccount.Id;
        oSeedUnitOrder.Ship_To_Address1__c = 'Test Address1';
        oSeedUnitOrder.Ship_To_Address2__c = 'Test Address2';
        oSeedUnitOrder.Ship_To_Address3__c = 'Test Address3';
        oSeedUnitOrder.Ship_To_Address4__c = 'Test Address4';
        oSeedUnitOrder.Ship_To_City__c = 'Test City';
        oSeedUnitOrder.Ship_To_State_Province__c = 'MN';
        oSeedUnitOrder.Ship_To_Postal_Code__c = '55044';
        oSeedUnitOrder.Ship_To_Country__c = 'United States-US';
        update oSeedUnitOrder;
        //Create products for testing
        Product2 oProductEligible = Test_Environment_Utility.createInsertProduct();
        oProductEligible.Seed_Unit_Eligible_Enterprise__c=true;
        update oProductEligible;
        //Create seed unit products for testing
        Seed_Unit_Product__c oSeedUnitProductEligible = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProductEligible, 5);
        
        Test.startTest();
            //Retrieve newly created Account, Seed_Unit_Order__c and Integration_Id__c fields needed for HTTP response.
            oIntegrationIdBillTo = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationIdBillTo.Id];              
            oAccountEndUser = [select Id, Name from Account where Id = :oAccountEndUser.Id];
            
            //Query for seed unit order created above in order to retrieve formula field values
            oSeedUnitOrder = [select Id, Sold_To_Org_new__c, Opportunity__c, Opportunity__r.Account.ParentId, Opportunity__r.AccountId, Name, Seed_Unit_Order_Submitted__c, Seed_Unit_Approval_Status__c,
                                Opportunity__r.Account.BillingStreet, Opportunity__r.Account.BillingCity, Opportunity__r.Account.BillingStateCode, Opportunity__r.Account.BillingPostalCode, Ship_To_Country__c,
                                Opportunity__r.Account.BillingCountryCode, Seed_Unit_Location_Type__c, Opportunity__r.Account.Parent.ParentId, Opportunity__r.Account.Name, Ship_To_Org_Id__c,
                                Ship_To_Address4__c, Ship_To_Address3__c, Ship_To_Address2__c, Sold_To_Salesforce_Id__c, Opportunity__r.Account.Id, Sold_To_Party_Name__c, Ship_To_County__c, Ship_To_Address__c,
                                Ship_To_Address1__c, Ship_To_City__c, ORIG_SYS_DOCUMENT_REF__c, Sold_To_Party_Id__c, Sold_To_Org_Id__c, Ship_To_State_Province__c, Ship_To_Postal_Code__c, Ship_To_Contact_First_Name__c,
                                Ship_To_Contact_Last_Name__c, Ship_To_Contact_Email__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Role_Id__c, Ship_To_Account__r.Name, Ship_To_Salesforce_Id__c,
                                Ship_To_Customer_Account_Id__c, Ship_To_Party_Id__c, Ship_To_Party_Name__c, Ship_To_Contact__c
                                from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];

            //Set up response since web service callouts are not allowed from test classes - this is a bad JSON format that includes '//' at the beginning of the string
            //which will trigger the callout exception logic.
            SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(200,
                                                            'OK',
                '//{'+
                '  \"__type\": \"RepLocator.Customer\",'+
                '  \"ip_verification_id\": \"' + oIntegrationIdBillTo.Security_Id__c + '\",'+
                '  \"ip_party_id\": \"\",'+
                '  \"ip_cust_account_id\": \"\",'+
                '  \"ip_ship_to_site_use_id\": \"\",'+
                '  \"ip_organization_name\": \"' + oAccountEndUser.Name + '\",'+
                '  \"ip_account_name\": \"CANADA\",'+
                '  \"ip_address1\": \"' + oSeedUnitOrder.Ship_To_Address1__c + '\",'+
                '  \"ip_address2\": \"' + oSeedUnitOrder.Ship_To_Address2__c + '\",'+
                '  \"ip_address3\": \"' + oSeedUnitOrder.Ship_To_Address3__c + '\",'+
                '  \"ip_address4\": \"' + oSeedUnitOrder.Ship_To_Address4__c + '\",'+
                '  \"ip_city\": \"' + oSeedUnitOrder.Ship_To_City__c + '\",'+
                '  \"ip_state\": \"\",'+
                '  \"ip_province\": \"\",'+
                '  \"ip_postal_code\": \"' + oSeedUnitOrder.Ship_To_Postal_Code__c + '\",'+
                '  \"ip_country\": \"' + oSeedUnitOrder.Ship_To_Country__c + '\",'+
                '  \"ip_county\": \"\",'+
                '  \"ip_person_first_name\": \"CHRIS\",'+
                '  \"ip_person_last_name\": \"NOE\",'+
                '  \"ip_raw_phone_number\": \"9522231265\",'+
                '  \"ip_email_address\": \"CNOE@ERGOTRON.COM\",'+
                '  \"ip_is_bill_to_address\": \"\",'+
                '  \"ip_is_ship_to_address\": \"Y\",'+
                '  \"ip_salesforce_ref_id\": \"' + oSeedUnitOrder.Id + '\",'+
                '  \"op_party_id\": \"187267221\",'+
                '  \"op_party_number\": \"\",'+
                '  \"op_cust_account_id\": \"16762542\",'+
                '  \"op_ship_to_site_use_id\": \"19099009\",'+
                '  \"op_bill_to_site_use_id\": \"\",'+
                '  \"op_ship_to_contact_id\": \"21046994\",'+
                '  \"op_cust_account_role_id\": \"19300030\",'+
                '  \"op_return_status\": \"\",'+
                '  \"op_return_message\": \"\"'+
                '}'
                 , null);
            Test.setMock(HttpCalloutMock.class, oFakeResponse); 

            /*BEGIN TEST: Web service callout exception*/
            
            //Create PageReference to the SeedUnitOrderConfirmation
            PageReference oPageRef = Page.SeedUnitOrderConfirmation;
            Test.setCurrentPage(oPageRef);

            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            ApexPages.currentPage().getParameters().put('id',oSeedUnitOrder.id);
            Seed_Unit_Order_Confirmation_Controller oExtController = new Seed_Unit_Order_Confirmation_Controller(oStdController);
            
            oPageRef = oExtController.orderConfirmationSubmit();   
            //Assert null return for page ref
            system.assertEquals(null,oPageRef);
            //Assert page messages
            Boolean bFoundMessage=false;
            for(ApexPages.Message oMessage :ApexPages.getMessages()) {
                if(oMessage.getDetail().contains('CALLOUT EXCEPTION')) {
                    bFoundMessage=true;
                }
            }   
            system.assert(bFoundMessage);            
        Test.stopTest();
    }

    static testMethod void orderConfirmationSubmitWSStatusExceptionSoldTo() {
        //Tests the Seed_Unit_Order_Confirmation_Controller.orderConfirmationSubmit method for a web service status exception when creating new sold to account
        
        String sPartyIdentifier = 'ERGO' + String.valueOf(math.random()).left(20);
        //Create accounts for testing
        Account oAccountEndUser = Test_Environment_Utility.createInsertAccountUS();
        Account oAccountReseller = Test_Environment_Utility.createInsertAccountUS();
        oAccountReseller.Oracle_Party_Id__c=sPartyIdentifier;
        oAccountReseller.Oracle_Party_Number__c=sPartyIdentifier;
        update oAccountReseller;
        //Create Customer_Account__c for testing
        Account oCustomerAccount = Test_Environment_Utility.createInsertAccountUS();
        //Create Contact for testing
        Contact oContactReseller = Test_Environment_Utility.createInsertContact(oAccountReseller);
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccountEndUser, 'Seeding', Date.today());
        
        //Create Integrations Id for testing
        Integration_Id__c oIntegrationIdBillTo = Test_Environment_Utility.createInsertIntegrationId();
        Integration_Id__c oIntegrationIdShipTo = Test_Environment_Utility.createInsertIntegrationId();
        Integration_Id__c oIntegrationIdRelationship = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetailCreateCustomer = Test_Environment_Utility.createInsertWebServiceDetails('Create Customer');
        Web_Service_Details__c oWebServiceDetailCreateRelationship = Test_Environment_Utility.createInsertWebServiceDetails('Create Relationship');

        //Create seed unit orders for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Enterprise', oAccountReseller, oContactReseller);
        oSeedUnitOrder.Ship_To_Customer_Account_new__c = oCustomerAccount.Id;
        oSeedUnitOrder.Ship_To_Address1__c = 'Test Address1';
        oSeedUnitOrder.Ship_To_Address2__c = 'Test Address2';
        oSeedUnitOrder.Ship_To_Address3__c = 'Test Address3';
        oSeedUnitOrder.Ship_To_Address4__c = 'Test Address4';
        oSeedUnitOrder.Ship_To_City__c = 'Test City';
        oSeedUnitOrder.Ship_To_State_Province__c = 'MN';
        oSeedUnitOrder.Ship_To_Postal_Code__c = '55044';
        oSeedUnitOrder.Ship_To_Country__c = 'United States-US';
        update oSeedUnitOrder;
        //Create products for testing
        Product2 oProductEligible = Test_Environment_Utility.createInsertProduct();
        oProductEligible.Seed_Unit_Eligible_Enterprise__c=true;
        update oProductEligible;
        //Create seed unit products for testing
        Seed_Unit_Product__c oSeedUnitProductEligible = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProductEligible, 5);
        
        Test.startTest();
            //Retrieve newly created Account, Seed_Unit_Order__c and Integration_Id__c fields needed for HTTP response.
            oIntegrationIdBillTo = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationIdBillTo.Id];              
            oAccountEndUser = [select Id, Name from Account where Id = :oAccountEndUser.Id];
            
            //Query for seed unit order created above in order to retrieve formula field values
            oSeedUnitOrder = [select Id, Sold_To_Org_new__c, Opportunity__c, Opportunity__r.Account.ParentId, Opportunity__r.AccountId, Name, Seed_Unit_Order_Submitted__c, Seed_Unit_Approval_Status__c,
                                Opportunity__r.Account.BillingStreet, Opportunity__r.Account.BillingCity, Opportunity__r.Account.BillingStateCode, Opportunity__r.Account.BillingPostalCode, Ship_To_Country__c,
                                Opportunity__r.Account.BillingCountryCode, Seed_Unit_Location_Type__c, Opportunity__r.Account.Parent.ParentId, Opportunity__r.Account.Name, Ship_To_Org_Id__c,
                                Ship_To_Address4__c, Ship_To_Address3__c, Ship_To_Address2__c, Sold_To_Salesforce_Id__c, Opportunity__r.Account.Id, Sold_To_Party_Name__c, Ship_To_County__c, Ship_To_Address__c,
                                Ship_To_Address1__c, Ship_To_City__c, ORIG_SYS_DOCUMENT_REF__c, Sold_To_Party_Id__c, Sold_To_Org_Id__c, Ship_To_State_Province__c, Ship_To_Postal_Code__c, Ship_To_Contact_First_Name__c,
                                Ship_To_Contact_Last_Name__c, Ship_To_Contact_Email__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Role_Id__c, Ship_To_Account__r.Name, Ship_To_Salesforce_Id__c,
                                Ship_To_Customer_Account_Id__c, Ship_To_Party_Id__c, Ship_To_Party_Name__c, Ship_To_Contact__c
                                from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];

            //Set up response since web service callouts are not allowed from test classes
            SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(404,
                                                            '',
                '{'+
                '  \"__type\": \"RepLocator.Customer\",'+
                '  \"ip_verification_id\": \"' + oIntegrationIdBillTo.Security_Id__c + '\",'+
                '  \"ip_party_id\": \"\",'+
                '  \"ip_cust_account_id\": \"\",'+
                '  \"ip_ship_to_site_use_id\": \"\",'+
                '  \"ip_organization_name\": \"' + oAccountEndUser.Name + '\",'+
                '  \"ip_account_name\": \"CANADA\",'+
                '  \"ip_address1\": \"' + oSeedUnitOrder.Ship_To_Address1__c + '\",'+
                '  \"ip_address2\": \"' + oSeedUnitOrder.Ship_To_Address2__c + '\",'+
                '  \"ip_address3\": \"' + oSeedUnitOrder.Ship_To_Address3__c + '\",'+
                '  \"ip_address4\": \"' + oSeedUnitOrder.Ship_To_Address4__c + '\",'+
                '  \"ip_city\": \"' + oSeedUnitOrder.Ship_To_City__c + '\",'+
                '  \"ip_state\": \"\",'+
                '  \"ip_province\": \"\",'+
                '  \"ip_postal_code\": \"' + oSeedUnitOrder.Ship_To_Postal_Code__c + '\",'+
                '  \"ip_country\": \"' + oSeedUnitOrder.Ship_To_Country__c + '\",'+
                '  \"ip_county\": \"\",'+
                '  \"ip_person_first_name\": \"CHRIS\",'+
                '  \"ip_person_last_name\": \"NOE\",'+
                '  \"ip_raw_phone_number\": \"9522231265\",'+
                '  \"ip_email_address\": \"CNOE@ERGOTRON.COM\",'+
                '  \"ip_is_bill_to_address\": \"\",'+
                '  \"ip_is_ship_to_address\": \"Y\",'+
                '  \"ip_salesforce_ref_id\": \"' + oSeedUnitOrder.Id + '\",'+
                '  \"op_party_id\": \"187267221\",'+
                '  \"op_party_number\": \"\",'+
                '  \"op_cust_account_id\": \"16762542\",'+
                '  \"op_ship_to_site_use_id\": \"19099009\",'+
                '  \"op_bill_to_site_use_id\": \"\",'+
                '  \"op_ship_to_contact_id\": \"21046994\",'+
                '  \"op_cust_account_role_id\": \"19300030\",'+
                '  \"op_return_status\": \"\",'+
                '  \"op_return_message\": \"\"'+
                '}'
                 , null);
            Test.setMock(HttpCalloutMock.class, oFakeResponse); 

            /*BEGIN TEST: Web service status exception*/
            
            //Create PageReference to the SeedUnitOrderConfirmation
            PageReference oPageRef = Page.SeedUnitOrderConfirmation;
            Test.setCurrentPage(oPageRef);

            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            ApexPages.currentPage().getParameters().put('id',oSeedUnitOrder.id);
            Seed_Unit_Order_Confirmation_Controller oExtController = new Seed_Unit_Order_Confirmation_Controller(oStdController);
            
            oPageRef = oExtController.orderConfirmationSubmit();   
            //Assert null return for page ref
            system.assertEquals(null,oPageRef);
            //Assert page messages
            Boolean bFoundMessage=false;
            for(ApexPages.Message oMessage :ApexPages.getMessages()) {
                if(oMessage.getDetail().contains('STATUS EXCEPTION')) {
                    bFoundMessage=true;
                }
            }   
            system.assert(bFoundMessage);           
        Test.stopTest();
    }

    static testMethod void orderConfirmationSubmitOracleAPIExceptionSoldTo() {
        //Tests the Seed_Unit_Order_Confirmation_Controller.orderConfirmationSubmit method for an Oracle API exception when creating new sold to account
        
        String sPartyIdentifier = 'ERGO' + String.valueOf(math.random()).left(20);
        //Create accounts for testing
        Account oAccountEndUser = Test_Environment_Utility.createInsertAccountUS();
        Account oAccountReseller = Test_Environment_Utility.createInsertAccountUS();
        oAccountReseller.Oracle_Party_Id__c=sPartyIdentifier;
        oAccountReseller.Oracle_Party_Number__c=sPartyIdentifier;
        update oAccountReseller;
        //Create Customer_Account__c for testing
        Account oCustomerAccount = Test_Environment_Utility.createInsertAccountUS();
        //Create Contact for testing
        Contact oContactReseller = Test_Environment_Utility.createInsertContact(oAccountReseller);
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccountEndUser, 'Seeding', Date.today());
        
        //Create Integrations Id for testing
        Integration_Id__c oIntegrationIdBillTo = Test_Environment_Utility.createInsertIntegrationId();
        Integration_Id__c oIntegrationIdShipTo = Test_Environment_Utility.createInsertIntegrationId();
        Integration_Id__c oIntegrationIdRelationship = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetailCreateCustomer = Test_Environment_Utility.createInsertWebServiceDetails('Create Customer');
        Web_Service_Details__c oWebServiceDetailCreateRelationship = Test_Environment_Utility.createInsertWebServiceDetails('Create Relationship');

        //Create seed unit orders for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Enterprise', oAccountReseller, oContactReseller);
        oSeedUnitOrder.Ship_To_Customer_Account_new__c = oCustomerAccount.Id;
        oSeedUnitOrder.Ship_To_Address1__c = 'Test Address1';
        oSeedUnitOrder.Ship_To_Address2__c = 'Test Address2';
        oSeedUnitOrder.Ship_To_Address3__c = 'Test Address3';
        oSeedUnitOrder.Ship_To_Address4__c = 'Test Address4';
        oSeedUnitOrder.Ship_To_City__c = 'Test City';
        oSeedUnitOrder.Ship_To_State_Province__c = 'MN';
        oSeedUnitOrder.Ship_To_Postal_Code__c = '55044';
        oSeedUnitOrder.Ship_To_Country__c = 'United States-US';
        update oSeedUnitOrder;
        //Create products for testing
        Product2 oProductEligible = Test_Environment_Utility.createInsertProduct();
        oProductEligible.Seed_Unit_Eligible_Enterprise__c=true;
        update oProductEligible;
        //Create seed unit products for testing
        Seed_Unit_Product__c oSeedUnitProductEligible = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProductEligible, 5);
        
        Test.startTest();
            //Retrieve newly created Account, Seed_Unit_Order__c and Integration_Id__c fields needed for HTTP response.
            oIntegrationIdBillTo = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationIdBillTo.Id];              
            oAccountEndUser = [select Id, Name from Account where Id = :oAccountEndUser.Id];
            
            //Query for seed unit order created above in order to retrieve formula field values
            oSeedUnitOrder = [select Id, Sold_To_Org_new__c, Opportunity__c, Opportunity__r.Account.ParentId, Opportunity__r.AccountId, Name, Seed_Unit_Order_Submitted__c, Seed_Unit_Approval_Status__c,
                                Opportunity__r.Account.BillingStreet, Opportunity__r.Account.BillingCity, Opportunity__r.Account.BillingStateCode, Opportunity__r.Account.BillingPostalCode, Ship_To_Country__c,
                                Opportunity__r.Account.BillingCountryCode, Seed_Unit_Location_Type__c, Opportunity__r.Account.Parent.ParentId, Opportunity__r.Account.Name, Ship_To_Org_Id__c,
                                Ship_To_Address4__c, Ship_To_Address3__c, Ship_To_Address2__c, Sold_To_Salesforce_Id__c, Opportunity__r.Account.Id, Sold_To_Party_Name__c, Ship_To_County__c, Ship_To_Address__c,
                                Ship_To_Address1__c, Ship_To_City__c, ORIG_SYS_DOCUMENT_REF__c, Sold_To_Party_Id__c, Sold_To_Org_Id__c, Ship_To_State_Province__c, Ship_To_Postal_Code__c, Ship_To_Contact_First_Name__c,
                                Ship_To_Contact_Last_Name__c, Ship_To_Contact_Email__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Role_Id__c, Ship_To_Account__r.Name, Ship_To_Salesforce_Id__c,
                                Ship_To_Customer_Account_Id__c, Ship_To_Party_Id__c, Ship_To_Party_Name__c, Ship_To_Contact__c
                                from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];

            //Set up response since web service callouts are not allowed from test classes
            SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(200,
                                                            'OK',
                '{'+
                '  \"__type\": \"RepLocator.Customer\",'+
                '  \"ip_verification_id\": \"' + oIntegrationIdBillTo.Security_Id__c + '\",'+
                '  \"ip_party_id\": \"\",'+
                '  \"ip_cust_account_id\": \"\",'+
                '  \"ip_ship_to_site_use_id\": \"\",'+
                '  \"ip_organization_name\": \"' + oAccountEndUser.Name + '\",'+
                '  \"ip_account_name\": \"CANADA\",'+
                '  \"ip_address1\": \"' + oSeedUnitOrder.Ship_To_Address1__c + '\",'+
                '  \"ip_address2\": \"' + oSeedUnitOrder.Ship_To_Address2__c + '\",'+
                '  \"ip_address3\": \"' + oSeedUnitOrder.Ship_To_Address3__c + '\",'+
                '  \"ip_address4\": \"' + oSeedUnitOrder.Ship_To_Address4__c + '\",'+
                '  \"ip_city\": \"' + oSeedUnitOrder.Ship_To_City__c + '\",'+
                '  \"ip_state\": \"\",'+
                '  \"ip_province\": \"\",'+
                '  \"ip_postal_code\": \"' + oSeedUnitOrder.Ship_To_Postal_Code__c + '\",'+
                '  \"ip_country\": \"' + oSeedUnitOrder.Ship_To_Country__c + '\",'+
                '  \"ip_county\": \"\",'+
                '  \"ip_person_first_name\": \"CHRIS\",'+
                '  \"ip_person_last_name\": \"NOE\",'+
                '  \"ip_raw_phone_number\": \"9522231265\",'+
                '  \"ip_email_address\": \"CNOE@ERGOTRON.COM\",'+
                '  \"ip_is_bill_to_address\": \"\",'+
                '  \"ip_is_ship_to_address\": \"Y\",'+
                '  \"ip_salesforce_ref_id\": \"' + oSeedUnitOrder.Id + '\",'+
                '  \"op_party_id\": \"187267221\",'+
                '  \"op_party_number\": \"\",'+
                '  \"op_cust_account_id\": \"16762542\",'+
                '  \"op_ship_to_site_use_id\": \"19099009\",'+
                '  \"op_bill_to_site_use_id\": \"\",'+
                '  \"op_ship_to_contact_id\": \"21046994\",'+
                '  \"op_cust_account_role_id\": \"19300030\",'+
                '  \"op_return_status\": \"E\",'+
                '  \"op_return_message\": \"ORACLE API ERROR\"'+
                '}'
                 , null);
            Test.setMock(HttpCalloutMock.class, oFakeResponse); 

            /*BEGIN TEST: Oracle API Exception*/
            
            //Create PageReference to the SeedUnitOrderConfirmation
            PageReference oPageRef = Page.SeedUnitOrderConfirmation;
            Test.setCurrentPage(oPageRef);

            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            ApexPages.currentPage().getParameters().put('id',oSeedUnitOrder.id);
            Seed_Unit_Order_Confirmation_Controller oExtController = new Seed_Unit_Order_Confirmation_Controller(oStdController);
            
            oPageRef = oExtController.orderConfirmationSubmit();   
            //Assert null return for page ref
            system.assertEquals(null,oPageRef);
            //Assert page messages
            Boolean bFoundMessage=false;
            for(ApexPages.Message oMessage :ApexPages.getMessages()) {
                if(oMessage.getDetail().contains('ORACLE API EXCEPTION')) {
                    bFoundMessage=true;
                }
            }   
            system.assert(bFoundMessage);             
        Test.stopTest();
    }

    static testMethod void orderConfirmationSubmitWSCalloutExceptionShipTo() {
        //Tests the Seed_Unit_Order_Confirmation_Controller.orderConfirmationSubmit method for a web service callout exception when creating new ship to account
        
        String sPartyIdentifier = 'ERGO' + String.valueOf(math.random()).left(20);
        //Create accounts for testing
        Account oAccountEndUser = Test_Environment_Utility.createInsertAccountUS();
        oAccountEndUser.Oracle_Party_Id__c=sPartyIdentifier;
        oAccountEndUser.Oracle_Party_Number__c=sPartyIdentifier;
        update oAccountEndUser;
        Account oAccountReseller = Test_Environment_Utility.createInsertAccountUS();

        //Create Customer_Account__c for testing
        Account oCustomerAccount = Test_Environment_Utility.createInsertAccountUS();
        //Create Contact for testing
        Contact oContactReseller = Test_Environment_Utility.createInsertContact(oAccountReseller);
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccountEndUser, 'Seeding', Date.today());
        
        //Create Integrations Id for testing
        Integration_Id__c oIntegrationIdBillTo = Test_Environment_Utility.createInsertIntegrationId();
        Integration_Id__c oIntegrationIdShipTo = Test_Environment_Utility.createInsertIntegrationId();
        Integration_Id__c oIntegrationIdRelationship = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetailCreateCustomer = Test_Environment_Utility.createInsertWebServiceDetails('Create Customer');
        Web_Service_Details__c oWebServiceDetailCreateRelationship = Test_Environment_Utility.createInsertWebServiceDetails('Create Relationship');

        //Create seed unit orders for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Enterprise', oAccountReseller, oContactReseller);
        oSeedUnitOrder.Sold_To_Org_new__c = oCustomerAccount.Id;
        oSeedUnitOrder.Ship_To_Address1__c = 'Test Address1';
        oSeedUnitOrder.Ship_To_Address2__c = 'Test Address2';
        oSeedUnitOrder.Ship_To_Address3__c = 'Test Address3';
        oSeedUnitOrder.Ship_To_Address4__c = 'Test Address4';
        oSeedUnitOrder.Ship_To_City__c = 'Test City';
        oSeedUnitOrder.Ship_To_State_Province__c = 'MN';
        oSeedUnitOrder.Ship_To_Postal_Code__c = '55044';
        oSeedUnitOrder.Ship_To_Country__c = 'United States-US';
        update oSeedUnitOrder;
        //Create products for testing
        Product2 oProductEligible = Test_Environment_Utility.createInsertProduct();
        oProductEligible.Seed_Unit_Eligible_Enterprise__c=true;
        update oProductEligible;
        //Create seed unit products for testing
        Seed_Unit_Product__c oSeedUnitProductEligible = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProductEligible, 5);
        
        Test.startTest();
            //Retrieve newly created Account, Seed_Unit_Order__c and Integration_Id__c fields needed for HTTP response.
            oIntegrationIdShipTo = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationIdShipTo.Id];              
            oAccountReseller = [select Id, Name from Account where Id = :oAccountReseller.Id];
            
            //Query for seed unit order created above in order to retrieve formula field values
            oSeedUnitOrder = [select Id, Sold_To_Org_new__c, Opportunity__c, Opportunity__r.Account.ParentId, Opportunity__r.AccountId, Name, Seed_Unit_Order_Submitted__c, Seed_Unit_Approval_Status__c,
                                Opportunity__r.Account.BillingStreet, Opportunity__r.Account.BillingCity, Opportunity__r.Account.BillingStateCode, Opportunity__r.Account.BillingPostalCode, Ship_To_Country__c,
                                Opportunity__r.Account.BillingCountryCode, Seed_Unit_Location_Type__c, Opportunity__r.Account.Parent.ParentId, Opportunity__r.Account.Name, Ship_To_Org_Id__c,
                                Ship_To_Address4__c, Ship_To_Address3__c, Ship_To_Address2__c, Sold_To_Salesforce_Id__c, Opportunity__r.Account.Id, Sold_To_Party_Name__c, Ship_To_County__c, Ship_To_Address__c,
                                Ship_To_Address1__c, Ship_To_City__c, ORIG_SYS_DOCUMENT_REF__c, Sold_To_Party_Id__c, Sold_To_Org_Id__c, Ship_To_State_Province__c, Ship_To_Postal_Code__c, Ship_To_Contact_First_Name__c,
                                Ship_To_Contact_Last_Name__c, Ship_To_Contact_Email__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Role_Id__c, Ship_To_Account__r.Name, Ship_To_Salesforce_Id__c,
                                Ship_To_Customer_Account_Id__c, Ship_To_Party_Id__c, Ship_To_Party_Name__c, Ship_To_Contact__c
                                from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];

            //Set up response since web service callouts are not allowed from test classes - this is a bad JSON format that includes '//' at the beginning of the string
            //which will trigger the callout exception logic.
            SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(200,
                                                            'OK',
                '//{'+
                '  \"__type\": \"RepLocator.Customer\",'+
                '  \"ip_verification_id\": \"' + oIntegrationIdShipTo.Security_Id__c + '\",'+
                '  \"ip_party_id\": \"\",'+
                '  \"ip_cust_account_id\": \"\",'+
                '  \"ip_ship_to_site_use_id\": \"\",'+
                '  \"ip_organization_name\": \"' + oAccountReseller.Name + '\",'+
                '  \"ip_account_name\": \"CANADA\",'+
                '  \"ip_address1\": \"' + oSeedUnitOrder.Ship_To_Address1__c + '\",'+
                '  \"ip_address2\": \"' + oSeedUnitOrder.Ship_To_Address2__c + '\",'+
                '  \"ip_address3\": \"' + oSeedUnitOrder.Ship_To_Address3__c + '\",'+
                '  \"ip_address4\": \"' + oSeedUnitOrder.Ship_To_Address4__c + '\",'+
                '  \"ip_city\": \"' + oSeedUnitOrder.Ship_To_City__c + '\",'+
                '  \"ip_state\": \"\",'+
                '  \"ip_province\": \"\",'+
                '  \"ip_postal_code\": \"' + oSeedUnitOrder.Ship_To_Postal_Code__c + '\",'+
                '  \"ip_country\": \"' + oSeedUnitOrder.Ship_To_Country__c + '\",'+
                '  \"ip_county\": \"\",'+
                '  \"ip_person_first_name\": \"CHRIS\",'+
                '  \"ip_person_last_name\": \"NOE\",'+
                '  \"ip_raw_phone_number\": \"9522231265\",'+
                '  \"ip_email_address\": \"CNOE@ERGOTRON.COM\",'+
                '  \"ip_is_bill_to_address\": \"\",'+
                '  \"ip_is_ship_to_address\": \"Y\",'+
                '  \"ip_salesforce_ref_id\": \"' + oSeedUnitOrder.Id + '\",'+
                '  \"op_party_id\": \"187267221\",'+
                '  \"op_party_number\": \"\",'+
                '  \"op_cust_account_id\": \"16762542\",'+
                '  \"op_ship_to_site_use_id\": \"19099009\",'+
                '  \"op_bill_to_site_use_id\": \"\",'+
                '  \"op_ship_to_contact_id\": \"21046994\",'+
                '  \"op_cust_account_role_id\": \"19300030\",'+
                '  \"op_return_status\": \"\",'+
                '  \"op_return_message\": \"\"'+
                '}'
                 , null);
            Test.setMock(HttpCalloutMock.class, oFakeResponse); 

            /*BEGIN TEST: Web service callout exception*/
            
            //Create PageReference to the SeedUnitOrderConfirmation
            PageReference oPageRef = Page.SeedUnitOrderConfirmation;
            Test.setCurrentPage(oPageRef);

            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            ApexPages.currentPage().getParameters().put('id',oSeedUnitOrder.id);
            Seed_Unit_Order_Confirmation_Controller oExtController = new Seed_Unit_Order_Confirmation_Controller(oStdController);
            
            oPageRef = oExtController.orderConfirmationSubmit();   
            //Assert null return for page ref
            system.assertEquals(null,oPageRef);
            //Assert page messages
            Boolean bFoundMessage=false;
            for(ApexPages.Message oMessage :ApexPages.getMessages()) {
                if(oMessage.getDetail().contains('CALLOUT EXCEPTION')) {
                    bFoundMessage=true;
                }
            }   
            system.assert(bFoundMessage);            
        Test.stopTest();
    }

    static testMethod void orderConfirmationSubmitWSStatusExceptionShipTo() {
        //Tests the Seed_Unit_Order_Confirmation_Controller.orderConfirmationSubmit method for a web service status exception when creating new ship to account
        
        String sPartyIdentifier = 'ERGO' + String.valueOf(math.random()).left(20);
        //Create accounts for testing
        Account oAccountEndUser = Test_Environment_Utility.createInsertAccountUS();
        oAccountEndUser.Oracle_Party_Id__c=sPartyIdentifier;
        oAccountEndUser.Oracle_Party_Number__c=sPartyIdentifier;
        update oAccountEndUser;
        Account oAccountReseller = Test_Environment_Utility.createInsertAccountUS();

        //Create Customer_Account__c for testing
        Account oCustomerAccount = Test_Environment_Utility.createInsertAccountUS();
        //Create Contact for testing
        Contact oContactReseller = Test_Environment_Utility.createInsertContact(oAccountReseller);
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccountEndUser, 'Seeding', Date.today());
        
        //Create Integrations Id for testing
        Integration_Id__c oIntegrationIdBillTo = Test_Environment_Utility.createInsertIntegrationId();
        Integration_Id__c oIntegrationIdShipTo = Test_Environment_Utility.createInsertIntegrationId();
        Integration_Id__c oIntegrationIdRelationship = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetailCreateCustomer = Test_Environment_Utility.createInsertWebServiceDetails('Create Customer');
        Web_Service_Details__c oWebServiceDetailCreateRelationship = Test_Environment_Utility.createInsertWebServiceDetails('Create Relationship');

        //Create seed unit orders for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Enterprise', oAccountReseller, oContactReseller);
        oSeedUnitOrder.Sold_To_Org_new__c = oCustomerAccount.Id;
        oSeedUnitOrder.Ship_To_Address1__c = 'Test Address1';
        oSeedUnitOrder.Ship_To_Address2__c = 'Test Address2';
        oSeedUnitOrder.Ship_To_Address3__c = 'Test Address3';
        oSeedUnitOrder.Ship_To_Address4__c = 'Test Address4';
        oSeedUnitOrder.Ship_To_City__c = 'Test City';
        oSeedUnitOrder.Ship_To_State_Province__c = 'MN';
        oSeedUnitOrder.Ship_To_Postal_Code__c = '55044';
        oSeedUnitOrder.Ship_To_Country__c = 'United States-US';
        update oSeedUnitOrder;
        //Create products for testing
        Product2 oProductEligible = Test_Environment_Utility.createInsertProduct();
        oProductEligible.Seed_Unit_Eligible_Enterprise__c=true;
        update oProductEligible;
        //Create seed unit products for testing
        Seed_Unit_Product__c oSeedUnitProductEligible = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProductEligible, 5);
        
        Test.startTest();
            //Retrieve newly created Account, Seed_Unit_Order__c and Integration_Id__c fields needed for HTTP response.
            oIntegrationIdShipTo = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationIdShipTo.Id];              
            oAccountReseller = [select Id, Name from Account where Id = :oAccountReseller.Id];
            
            //Query for seed unit order created above in order to retrieve formula field values
            oSeedUnitOrder = [select Id, Sold_To_Org_new__c, Opportunity__c, Opportunity__r.Account.ParentId, Opportunity__r.AccountId, Name, Seed_Unit_Order_Submitted__c, Seed_Unit_Approval_Status__c,
                                Opportunity__r.Account.BillingStreet, Opportunity__r.Account.BillingCity, Opportunity__r.Account.BillingStateCode, Opportunity__r.Account.BillingPostalCode, Ship_To_Country__c,
                                Opportunity__r.Account.BillingCountryCode, Seed_Unit_Location_Type__c, Opportunity__r.Account.Parent.ParentId, Opportunity__r.Account.Name, Ship_To_Org_Id__c,
                                Ship_To_Address4__c, Ship_To_Address3__c, Ship_To_Address2__c, Sold_To_Salesforce_Id__c, Opportunity__r.Account.Id, Sold_To_Party_Name__c, Ship_To_County__c, Ship_To_Address__c,
                                Ship_To_Address1__c, Ship_To_City__c, ORIG_SYS_DOCUMENT_REF__c, Sold_To_Party_Id__c, Sold_To_Org_Id__c, Ship_To_State_Province__c, Ship_To_Postal_Code__c, Ship_To_Contact_First_Name__c,
                                Ship_To_Contact_Last_Name__c, Ship_To_Contact_Email__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Role_Id__c, Ship_To_Account__r.Name, Ship_To_Salesforce_Id__c,
                                Ship_To_Customer_Account_Id__c, Ship_To_Party_Id__c, Ship_To_Party_Name__c, Ship_To_Contact__c
                                from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];

            //Set up response since web service callouts are not allowed from test classes
            SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(404,
                                                            '',
                '{'+
                '  \"__type\": \"RepLocator.Customer\",'+
                '  \"ip_verification_id\": \"' + oIntegrationIdShipTo.Security_Id__c + '\",'+
                '  \"ip_party_id\": \"\",'+
                '  \"ip_cust_account_id\": \"\",'+
                '  \"ip_ship_to_site_use_id\": \"\",'+
                '  \"ip_organization_name\": \"' + oAccountReseller.Name + '\",'+
                '  \"ip_account_name\": \"CANADA\",'+
                '  \"ip_address1\": \"' + oSeedUnitOrder.Ship_To_Address1__c + '\",'+
                '  \"ip_address2\": \"' + oSeedUnitOrder.Ship_To_Address2__c + '\",'+
                '  \"ip_address3\": \"' + oSeedUnitOrder.Ship_To_Address3__c + '\",'+
                '  \"ip_address4\": \"' + oSeedUnitOrder.Ship_To_Address4__c + '\",'+
                '  \"ip_city\": \"' + oSeedUnitOrder.Ship_To_City__c + '\",'+
                '  \"ip_state\": \"\",'+
                '  \"ip_province\": \"\",'+
                '  \"ip_postal_code\": \"' + oSeedUnitOrder.Ship_To_Postal_Code__c + '\",'+
                '  \"ip_country\": \"' + oSeedUnitOrder.Ship_To_Country__c + '\",'+
                '  \"ip_county\": \"\",'+
                '  \"ip_person_first_name\": \"CHRIS\",'+
                '  \"ip_person_last_name\": \"NOE\",'+
                '  \"ip_raw_phone_number\": \"9522231265\",'+
                '  \"ip_email_address\": \"CNOE@ERGOTRON.COM\",'+
                '  \"ip_is_bill_to_address\": \"\",'+
                '  \"ip_is_ship_to_address\": \"Y\",'+
                '  \"ip_salesforce_ref_id\": \"' + oSeedUnitOrder.Id + '\",'+
                '  \"op_party_id\": \"187267221\",'+
                '  \"op_party_number\": \"\",'+
                '  \"op_cust_account_id\": \"16762542\",'+
                '  \"op_ship_to_site_use_id\": \"19099009\",'+
                '  \"op_bill_to_site_use_id\": \"\",'+
                '  \"op_ship_to_contact_id\": \"21046994\",'+
                '  \"op_cust_account_role_id\": \"19300030\",'+
                '  \"op_return_status\": \"\",'+
                '  \"op_return_message\": \"\"'+
                '}'
                 , null);
            Test.setMock(HttpCalloutMock.class, oFakeResponse); 

            /*BEGIN TEST: Web service status exception*/
            
            //Create PageReference to the SeedUnitOrderConfirmation
            PageReference oPageRef = Page.SeedUnitOrderConfirmation;
            Test.setCurrentPage(oPageRef);

            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            ApexPages.currentPage().getParameters().put('id',oSeedUnitOrder.id);
            Seed_Unit_Order_Confirmation_Controller oExtController = new Seed_Unit_Order_Confirmation_Controller(oStdController);
            
            oPageRef = oExtController.orderConfirmationSubmit();   
            //Assert null return for page ref
            system.assertEquals(null,oPageRef);
            //Assert page messages
            Boolean bFoundMessage=false;
            for(ApexPages.Message oMessage :ApexPages.getMessages()) {
                if(oMessage.getDetail().contains('STATUS EXCEPTION')) {
                    bFoundMessage=true;
                }
            }   
            system.assert(bFoundMessage);           
        Test.stopTest();
    }

    static testMethod void orderConfirmationSubmitOracleAPIExceptionShipTo() {
        //Tests the Seed_Unit_Order_Confirmation_Controller.orderConfirmationSubmit method for an Oracle API exception when creating new ship to account
        
        String sPartyIdentifier = 'ERGO' + String.valueOf(math.random()).left(20);
        //Create accounts for testing
        Account oAccountEndUser = Test_Environment_Utility.createInsertAccountUS();
        oAccountEndUser.Oracle_Party_Id__c=sPartyIdentifier;
        oAccountEndUser.Oracle_Party_Number__c=sPartyIdentifier;
        update oAccountEndUser;
        Account oAccountReseller = Test_Environment_Utility.createInsertAccountUS();

        //Create Customer_Account__c for testing
        Account oCustomerAccount = Test_Environment_Utility.createInsertAccountUS();
        //Create Contact for testing
        Contact oContactReseller = Test_Environment_Utility.createInsertContact(oAccountReseller);
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccountEndUser, 'Seeding', Date.today());
        
        //Create Integrations Id for testing
        Integration_Id__c oIntegrationIdBillTo = Test_Environment_Utility.createInsertIntegrationId();
        Integration_Id__c oIntegrationIdShipTo = Test_Environment_Utility.createInsertIntegrationId();
        Integration_Id__c oIntegrationIdRelationship = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetailCreateCustomer = Test_Environment_Utility.createInsertWebServiceDetails('Create Customer');
        Web_Service_Details__c oWebServiceDetailCreateRelationship = Test_Environment_Utility.createInsertWebServiceDetails('Create Relationship');

        //Create seed unit orders for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Enterprise', oAccountReseller, oContactReseller);
        oSeedUnitOrder.Sold_To_Org_new__c = oCustomerAccount.Id;
        oSeedUnitOrder.Ship_To_Address1__c = 'Test Address1';
        oSeedUnitOrder.Ship_To_Address2__c = 'Test Address2';
        oSeedUnitOrder.Ship_To_Address3__c = 'Test Address3';
        oSeedUnitOrder.Ship_To_Address4__c = 'Test Address4';
        oSeedUnitOrder.Ship_To_City__c = 'Test City';
        oSeedUnitOrder.Ship_To_State_Province__c = 'MN';
        oSeedUnitOrder.Ship_To_Postal_Code__c = '55044';
        oSeedUnitOrder.Ship_To_Country__c = 'United States-US';
        update oSeedUnitOrder;
        //Create products for testing
        Product2 oProductEligible = Test_Environment_Utility.createInsertProduct();
        oProductEligible.Seed_Unit_Eligible_Enterprise__c=true;
        update oProductEligible;
        //Create seed unit products for testing
        Seed_Unit_Product__c oSeedUnitProductEligible = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProductEligible, 5);
        
        Test.startTest();
            //Retrieve newly created Account, Seed_Unit_Order__c and Integration_Id__c fields needed for HTTP response.
            oIntegrationIdShipTo = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationIdShipTo.Id];              
            oAccountReseller = [select Id, Name from Account where Id = :oAccountReseller.Id];
            
            //Query for seed unit order created above in order to retrieve formula field values
            oSeedUnitOrder = [select Id, Sold_To_Org_new__c, Opportunity__c, Opportunity__r.Account.ParentId, Opportunity__r.AccountId, Name, Seed_Unit_Order_Submitted__c, Seed_Unit_Approval_Status__c,
                                Opportunity__r.Account.BillingStreet, Opportunity__r.Account.BillingCity, Opportunity__r.Account.BillingStateCode, Opportunity__r.Account.BillingPostalCode, Ship_To_Country__c,
                                Opportunity__r.Account.BillingCountryCode, Seed_Unit_Location_Type__c, Opportunity__r.Account.Parent.ParentId, Opportunity__r.Account.Name, Ship_To_Org_Id__c,
                                Ship_To_Address4__c, Ship_To_Address3__c, Ship_To_Address2__c, Sold_To_Salesforce_Id__c, Opportunity__r.Account.Id, Sold_To_Party_Name__c, Ship_To_County__c, Ship_To_Address__c,
                                Ship_To_Address1__c, Ship_To_City__c, ORIG_SYS_DOCUMENT_REF__c, Sold_To_Party_Id__c, Sold_To_Org_Id__c, Ship_To_State_Province__c, Ship_To_Postal_Code__c, Ship_To_Contact_First_Name__c,
                                Ship_To_Contact_Last_Name__c, Ship_To_Contact_Email__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Role_Id__c, Ship_To_Account__r.Name, Ship_To_Salesforce_Id__c,
                                Ship_To_Customer_Account_Id__c, Ship_To_Party_Id__c, Ship_To_Party_Name__c, Ship_To_Contact__c
                                from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];

            //Set up response since web service callouts are not allowed from test classes
            SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(200,
                                                            'OK',
                '{'+
                '  \"__type\": \"RepLocator.Customer\",'+
                '  \"ip_verification_id\": \"' + oIntegrationIdShipTo.Security_Id__c + '\",'+
                '  \"ip_party_id\": \"\",'+
                '  \"ip_cust_account_id\": \"\",'+
                '  \"ip_ship_to_site_use_id\": \"\",'+
                '  \"ip_organization_name\": \"' + oAccountReseller.Name + '\",'+
                '  \"ip_account_name\": \"CANADA\",'+
                '  \"ip_address1\": \"' + oSeedUnitOrder.Ship_To_Address1__c + '\",'+
                '  \"ip_address2\": \"' + oSeedUnitOrder.Ship_To_Address2__c + '\",'+
                '  \"ip_address3\": \"' + oSeedUnitOrder.Ship_To_Address3__c + '\",'+
                '  \"ip_address4\": \"' + oSeedUnitOrder.Ship_To_Address4__c + '\",'+
                '  \"ip_city\": \"' + oSeedUnitOrder.Ship_To_City__c + '\",'+
                '  \"ip_state\": \"\",'+
                '  \"ip_province\": \"\",'+
                '  \"ip_postal_code\": \"' + oSeedUnitOrder.Ship_To_Postal_Code__c + '\",'+
                '  \"ip_country\": \"' + oSeedUnitOrder.Ship_To_Country__c + '\",'+
                '  \"ip_county\": \"\",'+
                '  \"ip_person_first_name\": \"CHRIS\",'+
                '  \"ip_person_last_name\": \"NOE\",'+
                '  \"ip_raw_phone_number\": \"9522231265\",'+
                '  \"ip_email_address\": \"CNOE@ERGOTRON.COM\",'+
                '  \"ip_is_bill_to_address\": \"\",'+
                '  \"ip_is_ship_to_address\": \"Y\",'+
                '  \"ip_salesforce_ref_id\": \"' + oSeedUnitOrder.Id + '\",'+
                '  \"op_party_id\": \"187267221\",'+
                '  \"op_party_number\": \"\",'+
                '  \"op_cust_account_id\": \"16762542\",'+
                '  \"op_ship_to_site_use_id\": \"19099009\",'+
                '  \"op_bill_to_site_use_id\": \"\",'+
                '  \"op_ship_to_contact_id\": \"21046994\",'+
                '  \"op_cust_account_role_id\": \"19300030\",'+
                '  \"op_return_status\": \"E\",'+
                '  \"op_return_message\": \"ORACLE API ERROR\"'+
                '}'
                 , null);
            Test.setMock(HttpCalloutMock.class, oFakeResponse); 

            /*BEGIN TEST: Oracle API Exception*/
            
            //Create PageReference to the SeedUnitOrderConfirmation
            PageReference oPageRef = Page.SeedUnitOrderConfirmation;
            Test.setCurrentPage(oPageRef);

            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            ApexPages.currentPage().getParameters().put('id',oSeedUnitOrder.id);
            Seed_Unit_Order_Confirmation_Controller oExtController = new Seed_Unit_Order_Confirmation_Controller(oStdController);
            
            oPageRef = oExtController.orderConfirmationSubmit();   
            //Assert null return for page ref
            system.assertEquals(null,oPageRef);
            //Assert page messages
            Boolean bFoundMessage=false;
            for(ApexPages.Message oMessage :ApexPages.getMessages()) {
                if(oMessage.getDetail().contains('ORACLE API EXCEPTION')) {
                    bFoundMessage=true;
                }
            }   
            system.assert(bFoundMessage);             
        Test.stopTest();
    }

    static testMethod void orderConfirmationSubmitWSCalloutExceptionRelationship() {
        //Tests the Seed_Unit_Order_Confirmation_Controller.orderConfirmationSubmit method for a web service callout exception when creating ship to relationship
        
        String sPartyIdentifierEndUser = 'ERGO' + String.valueOf(math.random()).left(20);
        String sPartyIdentifierReseller = 'ERGO' + String.valueOf(math.random()).left(20);
        //Create accounts for testing
        Account oAccountEndUser = Test_Environment_Utility.createInsertAccountUS();
        oAccountEndUser.Oracle_Party_Id__c=sPartyIdentifierEndUser;
        oAccountEndUser.Oracle_Party_Number__c=sPartyIdentifierEndUser;
        update oAccountEndUser;
        Account oAccountReseller = Test_Environment_Utility.createInsertAccountUS();
        oAccountReseller.Oracle_Party_Id__c=sPartyIdentifierReseller;
        oAccountReseller.Oracle_Party_Number__c=sPartyIdentifierReseller;
        update oAccountReseller;

        //Create Customer_Account__c records for testing
        Account oCustomerAccountEndUser = Test_Environment_Utility.createInsertAccountUS();
        Account oCustomerAccountReseller = Test_Environment_Utility.createInsertAccountUS();
        //Create Contact for testing
        Contact oContactReseller = Test_Environment_Utility.createInsertContact(oAccountReseller);
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccountEndUser, 'Seeding', Date.today());
        
        //Create Integrations Id for testing
        Integration_Id__c oIntegrationIdBillTo = Test_Environment_Utility.createInsertIntegrationId();
        Integration_Id__c oIntegrationIdShipTo = Test_Environment_Utility.createInsertIntegrationId();
        Integration_Id__c oIntegrationIdRelationship = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetailCreateCustomer = Test_Environment_Utility.createInsertWebServiceDetails('Create Customer');
        Web_Service_Details__c oWebServiceDetailCreateRelationship = Test_Environment_Utility.createInsertWebServiceDetails('Create Relationship');

        //Create seed unit orders for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Enterprise', oAccountReseller, oContactReseller);
        oSeedUnitOrder.Sold_To_Org_new__c = oCustomerAccountEndUser.Id;
        oSeedUnitOrder.Ship_To_Customer_Account_new__c = oCustomerAccountReseller.Id;
        oSeedUnitOrder.Ship_To_Org_Id__c = String.valueOf(math.random()).left(20);
        oSeedUnitOrder.Ship_To_Contact_Role_Id__c = String.valueOf(math.random()).left(20);
        update oSeedUnitOrder;
        //Create products for testing
        Product2 oProductEligible = Test_Environment_Utility.createInsertProduct();
        oProductEligible.Seed_Unit_Eligible_Enterprise__c=true;
        update oProductEligible;
        //Create seed unit products for testing
        Seed_Unit_Product__c oSeedUnitProductEligible = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProductEligible, 5);
        
        Test.startTest();
            //Retrieve newly created Account, Customer_Account__c, Seed_Unit_Order__c and Integration_Id__c fields needed for HTTP response.
            oIntegrationIdRelationship = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationIdShipTo.Id];
            oCustomerAccountReseller = [select Id, Customer_Account_Id__c from Account where Id = :oCustomerAccountReseller.Id];
            oCustomerAccountEndUser = [select Id, Customer_Account_Id__c from Account where Id = :oCustomerAccountEndUser.Id];
            
            //Query for seed unit order created above in order to retrieve formula field values
            oSeedUnitOrder = [select Id, Sold_To_Org_new__c, Opportunity__c, Opportunity__r.Account.ParentId, Opportunity__r.AccountId, Name, Seed_Unit_Order_Submitted__c, Seed_Unit_Approval_Status__c,
                                Opportunity__r.Account.BillingStreet, Opportunity__r.Account.BillingCity, Opportunity__r.Account.BillingStateCode, Opportunity__r.Account.BillingPostalCode, Ship_To_Country__c,
                                Opportunity__r.Account.BillingCountryCode, Seed_Unit_Location_Type__c, Opportunity__r.Account.Parent.ParentId, Opportunity__r.Account.Name, Ship_To_Org_Id__c,
                                Ship_To_Address4__c, Ship_To_Address3__c, Ship_To_Address2__c, Sold_To_Salesforce_Id__c, Opportunity__r.Account.Id, Sold_To_Party_Name__c, Ship_To_County__c, Ship_To_Address__c,
                                Ship_To_Address1__c, Ship_To_City__c, ORIG_SYS_DOCUMENT_REF__c, Sold_To_Party_Id__c, Sold_To_Org_Id__c, Ship_To_State_Province__c, Ship_To_Postal_Code__c, Ship_To_Contact_First_Name__c,
                                Ship_To_Contact_Last_Name__c, Ship_To_Contact_Email__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Role_Id__c, Ship_To_Account__r.Name, Ship_To_Salesforce_Id__c,
                                Ship_To_Customer_Account_Id__c, Ship_To_Party_Id__c, Ship_To_Party_Name__c, Ship_To_Contact__c
                                from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];
            //Set up response since web service callouts are not allowed from test classes - incorrect JSON format
            SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(200,
                                                            'OK',
                '//{'+
                '  \"__type\": \"RepLocator.Relationship\",'+
                '  \"ip_verification_id\": \"' + oIntegrationIdRelationship.Security_Id__c + '\",'+
                '  \"ip_cust_account_id\": \"' + oCustomerAccountReseller.Customer_Account_Id__c + '\",'+
                '  \"ip_related_cust_account_id\": \"' + oCustomerAccountEndUser.Customer_Account_Id__c + '\",'+
                '  \"ip_bill_to_flag\": \"\",'+
                '  \"ip_ship_to_flag\": \"Y\",'+
                '  \"op_return_status\": \"\",'+
                '  \"op_return_message\": \"\"'+
                '}' 
                 , null);
            Test.setMock(HttpCalloutMock.class, oFakeResponse);

            /*BEGIN TEST: Web service callout exception*/
            
            //Create PageReference to the SeedUnitOrderConfirmation
            PageReference oPageRef = Page.SeedUnitOrderConfirmation;
            Test.setCurrentPage(oPageRef);

            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            ApexPages.currentPage().getParameters().put('id',oSeedUnitOrder.id);
            Seed_Unit_Order_Confirmation_Controller oExtController = new Seed_Unit_Order_Confirmation_Controller(oStdController);
            
            oPageRef = oExtController.orderConfirmationSubmit();   
            //Assert null return for page ref
            system.assertEquals(null,oPageRef);
            //Assert page messages
            Boolean bFoundMessage=false;
            for(ApexPages.Message oMessage :ApexPages.getMessages()) {
                if(oMessage.getDetail().contains('CALLOUT EXCEPTION')) {
                    bFoundMessage=true;
                }
            }   
            system.assert(bFoundMessage);        
        Test.stopTest();
    }

    static testMethod void orderConfirmationSubmitWSStatusExceptionRelationship() {
        //Tests the Seed_Unit_Order_Confirmation_Controller.orderConfirmationSubmit method for a web service status exception when creating ship to relationship
        
        String sPartyIdentifierEndUser = 'ERGO' + String.valueOf(math.random()).left(20);
        String sPartyIdentifierReseller = 'ERGO' + String.valueOf(math.random()).left(20);
        //Create accounts for testing
        Account oAccountEndUser = Test_Environment_Utility.createInsertAccountUS();
        oAccountEndUser.Oracle_Party_Id__c=sPartyIdentifierEndUser;
        oAccountEndUser.Oracle_Party_Number__c=sPartyIdentifierEndUser;
        update oAccountEndUser;
        Account oAccountReseller = Test_Environment_Utility.createInsertAccountUS();
        oAccountReseller.Oracle_Party_Id__c=sPartyIdentifierReseller;
        oAccountReseller.Oracle_Party_Number__c=sPartyIdentifierReseller;
        update oAccountReseller;

        //Create Customer_Account__c records for testing
        Account oCustomerAccountEndUser = Test_Environment_Utility.createInsertAccountUS();
        Account oCustomerAccountReseller = Test_Environment_Utility.createInsertAccountUS();
        //Create Contact for testing
        Contact oContactReseller = Test_Environment_Utility.createInsertContact(oAccountReseller);
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccountEndUser, 'Seeding', Date.today());
        
        //Create Integrations Id for testing
        Integration_Id__c oIntegrationIdBillTo = Test_Environment_Utility.createInsertIntegrationId();
        Integration_Id__c oIntegrationIdShipTo = Test_Environment_Utility.createInsertIntegrationId();
        Integration_Id__c oIntegrationIdRelationship = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetailCreateCustomer = Test_Environment_Utility.createInsertWebServiceDetails('Create Customer');
        Web_Service_Details__c oWebServiceDetailCreateRelationship = Test_Environment_Utility.createInsertWebServiceDetails('Create Relationship');

        //Create seed unit orders for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Enterprise', oAccountReseller, oContactReseller);
        oSeedUnitOrder.Sold_To_Org_new__c = oCustomerAccountEndUser.Id;
        oSeedUnitOrder.Ship_To_Customer_Account_new__c = oCustomerAccountReseller.Id;
        oSeedUnitOrder.Ship_To_Org_Id__c = String.valueOf(math.random()).left(20);
        oSeedUnitOrder.Ship_To_Contact_Role_Id__c = String.valueOf(math.random()).left(20);
        update oSeedUnitOrder;
        //Create products for testing
        Product2 oProductEligible = Test_Environment_Utility.createInsertProduct();
        oProductEligible.Seed_Unit_Eligible_Enterprise__c=true;
        update oProductEligible;
        //Create seed unit products for testing
        Seed_Unit_Product__c oSeedUnitProductEligible = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProductEligible, 5);
        
        Test.startTest();
            //Retrieve newly created Account, Customer_Account__c, Seed_Unit_Order__c and Integration_Id__c fields needed for HTTP response.
            oIntegrationIdRelationship = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationIdShipTo.Id];
            oCustomerAccountReseller = [select Id, Customer_Account_Id__c from Account where Id = :oCustomerAccountReseller.Id];
            oCustomerAccountEndUser = [select Id, Customer_Account_Id__c from Account where Id = :oCustomerAccountEndUser.Id];
            
            //Query for seed unit order created above in order to retrieve formula field values
            oSeedUnitOrder = [select Id, Sold_To_Org_new__c, Opportunity__c, Opportunity__r.Account.ParentId, Opportunity__r.AccountId, Name, Seed_Unit_Order_Submitted__c, Seed_Unit_Approval_Status__c,
                                Opportunity__r.Account.BillingStreet, Opportunity__r.Account.BillingCity, Opportunity__r.Account.BillingStateCode, Opportunity__r.Account.BillingPostalCode, Ship_To_Country__c,
                                Opportunity__r.Account.BillingCountryCode, Seed_Unit_Location_Type__c, Opportunity__r.Account.Parent.ParentId, Opportunity__r.Account.Name, Ship_To_Org_Id__c,
                                Ship_To_Address4__c, Ship_To_Address3__c, Ship_To_Address2__c, Sold_To_Salesforce_Id__c, Opportunity__r.Account.Id, Sold_To_Party_Name__c, Ship_To_County__c, Ship_To_Address__c,
                                Ship_To_Address1__c, Ship_To_City__c, ORIG_SYS_DOCUMENT_REF__c, Sold_To_Party_Id__c, Sold_To_Org_Id__c, Ship_To_State_Province__c, Ship_To_Postal_Code__c, Ship_To_Contact_First_Name__c,
                                Ship_To_Contact_Last_Name__c, Ship_To_Contact_Email__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Role_Id__c, Ship_To_Account__r.Name, Ship_To_Salesforce_Id__c,
                                Ship_To_Customer_Account_Id__c, Ship_To_Party_Id__c, Ship_To_Party_Name__c, Ship_To_Contact__c
                                from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];

            //Set up response since web service callouts are not allowed from test classes
            SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(404,
                                                            'BAD',
                '{'+
                '  \"__type\": \"RepLocator.Relationship\",'+
                '  \"ip_verification_id\": \"' + oIntegrationIdRelationship.Security_Id__c + '\",'+
                '  \"ip_cust_account_id\": \"' + oCustomerAccountReseller.Customer_Account_Id__c + '\",'+
                '  \"ip_related_cust_account_id\": \"' + oCustomerAccountEndUser.Customer_Account_Id__c + '\",'+
                '  \"ip_bill_to_flag\": \"\",'+
                '  \"ip_ship_to_flag\": \"Y\",'+
                '  \"op_return_status\": \"\",'+
                '  \"op_return_message\": \"\"'+
                '}' 
                 , null);
            Test.setMock(HttpCalloutMock.class, oFakeResponse);

            /*BEGIN TEST: Web service callout exception*/
            
            //Create PageReference to the SeedUnitOrderConfirmation
            PageReference oPageRef = Page.SeedUnitOrderConfirmation;
            Test.setCurrentPage(oPageRef);

            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            ApexPages.currentPage().getParameters().put('id',oSeedUnitOrder.id);
            Seed_Unit_Order_Confirmation_Controller oExtController = new Seed_Unit_Order_Confirmation_Controller(oStdController);
            
            oPageRef = oExtController.orderConfirmationSubmit();   
            //Assert null return for page ref
            system.assertEquals(null,oPageRef);
            //Assert page messages
            Boolean bFoundMessage=false;
            for(ApexPages.Message oMessage :ApexPages.getMessages()) {
                if(oMessage.getDetail().contains('STATUS EXCEPTION')) {
                    bFoundMessage=true;
                }
            }   
            system.assert(bFoundMessage);
        Test.stopTest();
    }

    static testMethod void orderConfirmationSubmitOracleAPIExceptionRelationship() {
        //Tests the Seed_Unit_Order_Confirmation_Controller.orderConfirmationSubmit method for an Oracle API exception when creating ship to relationship
        
        String sPartyIdentifierEndUser = 'ERGO' + String.valueOf(math.random()).left(20);
        String sPartyIdentifierReseller = 'ERGO' + String.valueOf(math.random()).left(20);
        //Create accounts for testing
        Account oAccountEndUser = Test_Environment_Utility.createInsertAccountUS();
        oAccountEndUser.Oracle_Party_Id__c=sPartyIdentifierEndUser;
        oAccountEndUser.Oracle_Party_Number__c=sPartyIdentifierEndUser;
        update oAccountEndUser;
        Account oAccountReseller = Test_Environment_Utility.createInsertAccountUS();
        oAccountReseller.Oracle_Party_Id__c=sPartyIdentifierReseller;
        oAccountReseller.Oracle_Party_Number__c=sPartyIdentifierReseller;
        update oAccountReseller;

        //Create Customer_Account__c records for testing
        Account oCustomerAccountEndUser = Test_Environment_Utility.createInsertAccountUS();
        Account oCustomerAccountReseller = Test_Environment_Utility.createInsertAccountUS();
        //Create Contact for testing
        Contact oContactReseller = Test_Environment_Utility.createInsertContact(oAccountReseller);
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccountEndUser, 'Seeding', Date.today());
        
        //Create Integrations Id for testing
        Integration_Id__c oIntegrationIdBillTo = Test_Environment_Utility.createInsertIntegrationId();
        Integration_Id__c oIntegrationIdShipTo = Test_Environment_Utility.createInsertIntegrationId();
        Integration_Id__c oIntegrationIdRelationship = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetailCreateCustomer = Test_Environment_Utility.createInsertWebServiceDetails('Create Customer');
        Web_Service_Details__c oWebServiceDetailCreateRelationship = Test_Environment_Utility.createInsertWebServiceDetails('Create Relationship');

        //Create seed unit orders for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Enterprise', oAccountReseller, oContactReseller);
        oSeedUnitOrder.Sold_To_Org_new__c = oCustomerAccountEndUser.Id;
        oSeedUnitOrder.Ship_To_Customer_Account_new__c = oCustomerAccountReseller.Id;
        oSeedUnitOrder.Ship_To_Org_Id__c = String.valueOf(math.random()).left(20);
        oSeedUnitOrder.Ship_To_Contact_Role_Id__c = String.valueOf(math.random()).left(20);
        update oSeedUnitOrder;
        //Create products for testing
        Product2 oProductEligible = Test_Environment_Utility.createInsertProduct();
        oProductEligible.Seed_Unit_Eligible_Enterprise__c=true;
        update oProductEligible;
        //Create seed unit products for testing
        Seed_Unit_Product__c oSeedUnitProductEligible = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProductEligible, 5);
        
        Test.startTest();
            //Retrieve newly created Account, Customer_Account__c, Seed_Unit_Order__c and Integration_Id__c fields needed for HTTP response.
            oIntegrationIdRelationship = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationIdShipTo.Id];
            oCustomerAccountReseller = [select Id, Customer_Account_Id__c from Account where Id = :oCustomerAccountReseller.Id];
            oCustomerAccountEndUser = [select Id, Customer_Account_Id__c from Account where Id = :oCustomerAccountEndUser.Id];
            
            //Query for seed unit order created above in order to retrieve formula field values
            oSeedUnitOrder = [select Id, Sold_To_Org_new__c, Opportunity__c, Opportunity__r.Account.ParentId, Opportunity__r.AccountId, Name, Seed_Unit_Order_Submitted__c, Seed_Unit_Approval_Status__c,
                                Opportunity__r.Account.BillingStreet, Opportunity__r.Account.BillingCity, Opportunity__r.Account.BillingStateCode, Opportunity__r.Account.BillingPostalCode, Ship_To_Country__c,
                                Opportunity__r.Account.BillingCountryCode, Seed_Unit_Location_Type__c, Opportunity__r.Account.Parent.ParentId, Opportunity__r.Account.Name, Ship_To_Org_Id__c,
                                Ship_To_Address4__c, Ship_To_Address3__c, Ship_To_Address2__c, Sold_To_Salesforce_Id__c, Opportunity__r.Account.Id, Sold_To_Party_Name__c, Ship_To_County__c, Ship_To_Address__c,
                                Ship_To_Address1__c, Ship_To_City__c, ORIG_SYS_DOCUMENT_REF__c, Sold_To_Party_Id__c, Sold_To_Org_Id__c, Ship_To_State_Province__c, Ship_To_Postal_Code__c, Ship_To_Contact_First_Name__c,
                                Ship_To_Contact_Last_Name__c, Ship_To_Contact_Email__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Role_Id__c, Ship_To_Account__r.Name, Ship_To_Salesforce_Id__c,
                                Ship_To_Customer_Account_Id__c, Ship_To_Party_Id__c, Ship_To_Party_Name__c, Ship_To_Contact__c
                                from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];
                                
            //Set up response since web service callouts are not allowed from test classes
            SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(200,
                                                            'OK',
                '{'+
                '  \"__type\": \"RepLocator.Relationship\",'+
                '  \"ip_verification_id\": \"' + oIntegrationIdRelationship.Security_Id__c + '\",'+
                '  \"ip_cust_account_id\": \"' + oCustomerAccountReseller.Customer_Account_Id__c + '\",'+
                '  \"ip_related_cust_account_id\": \"' + oCustomerAccountEndUser.Customer_Account_Id__c + '\",'+
                '  \"ip_bill_to_flag\": \"\",'+
                '  \"ip_ship_to_flag\": \"Y\",'+
                '  \"op_return_status\": \"E\",'+
                '  \"op_return_message\": \"ORACLE API EXCEPTION\"'+
                '}' 
                 , null);
            Test.setMock(HttpCalloutMock.class, oFakeResponse);

            /*BEGIN TEST: Web service callout exception*/
            
            //Create PageReference to the SeedUnitOrderConfirmation
            PageReference oPageRef = Page.SeedUnitOrderConfirmation;
            Test.setCurrentPage(oPageRef);

            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            ApexPages.currentPage().getParameters().put('id',oSeedUnitOrder.id);
            Seed_Unit_Order_Confirmation_Controller oExtController = new Seed_Unit_Order_Confirmation_Controller(oStdController);
            
            oPageRef = oExtController.orderConfirmationSubmit();   
            //Assert null return for page ref
            system.assertEquals(null,oPageRef);
            //Assert page messages
            Boolean bFoundMessage=false;
            for(ApexPages.Message oMessage :ApexPages.getMessages()) {
                if(oMessage.getDetail().contains('ORACLE API EXCEPTION')) {
                    bFoundMessage=true;
                }
            }   
            system.assert(bFoundMessage);        
        Test.stopTest();
    }
}