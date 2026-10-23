/*
    Controller class for the Lead_Create_Account_Party_Cntrl.cls.

    MOD DATE        Who                     Description
    12/09/2014      Chris Noe               Initial Release 
*/

@IsTest
private class Lead_Create_Account_Party_Cntrl_Test {

    static testmethod void testCreateAccount() {
    	//Create web service details for lead assignment callout and create party callout
		Web_Service_Details__c oWebServiceLead = Test_Environment_Utility.createInsertWebServiceDetails('Territory Lookup');

		Test.setMock(HttpCalloutMock.class, new Test_MOCK_ServiceCalls.generalCalloutMock());
		SmartyStreets_API__c ss = new SmartyStreets_API__c();
			ss.Name = 'SeedUnitAddressVerify';
			ss.auth_id__c = 'adsmfqmwepm09daasd';
			ss.auth_token__c = '23240kfir8fj8f8';
		insert ss;

        //Create Lead for test
    	Lead oLead = new Lead();
    	oLead.Company='Test';
    	oLead.FirstName='Test';
    	oLead.LastName='Test';
    	oLead.Ergotron_Vertical_Market__c='Enterprise';
    	oLead.Street='Test';
    	oLead.City='Test';
    	oLead.StateCode='MN';
    	oLead.PostalCode='55121';
    	oLead.CountryCode='US';
    	oLead.Territory_Account_Manager__c=UserInfo.getUserId();
		oLead.IsAddressValidated__c = true;

    	insert oLead;

        Test.startTest();
            PageReference oPageRef = Page.LeadCreateAccountParty;
            Test.setCurrentPage(oPageRef);

            //Instantiate standard and extension controller
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oLead);
            oPageRef.getParameters().put('id',String.valueOf(oLead.Id));
            Lead_Create_Account_Party_Cntrl oExtController = new Lead_Create_Account_Party_Cntrl(oStdController);

            //Assert NULL return from createAccount method on extension controller
            system.assertEquals(null,oExtController.createAccount());
        Test.stopTest();
    }

    static testmethod void testCreateParty() {
        //Create Integration Id for testing
        Integration_Id__c oIntegrationId = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for lead assignment callout and create party callout
        Web_Service_Details__c oWebServiceLead = Test_Environment_Utility.createInsertWebServiceDetails('Territory Lookup');
        Web_Service_Details__c oWebServiceParty = Test_Environment_Utility.createInsertWebServiceDetails('Create Party');

        //Create random string values for Oracle_Party_Number__c and Oracle_Party_Id.
        String sPartyNumber = 'ERGO' + String.valueOf(math.random()).left(20);
        String sPartyId = 'ERGO' + String.valueOf(math.random()).left(20);

      	//Create Lead for test
      	Lead oLead = new Lead();
      	oLead.Company='Test';
      	oLead.FirstName='Test';
      	oLead.LastName='Test';
      	oLead.Ergotron_Vertical_Market__c='Enterprise';
      	oLead.Street='Test';
      	oLead.City='Test';
      	oLead.StateCode='MN';
      	oLead.PostalCode='55121';
      	oLead.CountryCode='US';
      	oLead.Territory_Account_Manager__c=UserInfo.getUserId();

      	insert oLead;

      	//Create Account for test
      	Account oAccount = Test_Environment_Utility.createInsertAccountUS();
            
        Test.startTest();
            PageReference oPageRef = Page.LeadCreateAccountParty;
            Test.setCurrentPage(oPageRef);

            //Instantiate standard and extension controller
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oLead);
            oPageRef.getParameters().put('id',String.valueOf(oLead.Id));
            Lead_Create_Account_Party_Cntrl oExtController = new Lead_Create_Account_Party_Cntrl(oStdController);

            //Set sAccountId on extension controller
            oExtController.sNewAccountId=oAccount.Id;

            //Set up mock web service response since web service callouts are not allowed from test classes
            SingleHTTPRequestMock_Test oResponse = new SingleHTTPRequestMock_Test(200,
                                  'OK',
                                  '{'+
                                  '  \"__type\": \"RepLocator.Party\",'+
                                  '  \"ip_verification_id\": \"' + oIntegrationId.Security_Id__c + '\",'+
                                  '  \"ip_party_name\": \"' + oLead.Company + '\",'+
                                  '  \"ip_address1\": \"' + oLead.Street + '\",'+
                                  '  \"ip_address2\": \"\",'+
                                  '  \"ip_address3\": \"\",'+
                                  '  \"ip_address4\": \"\",'+
                                  '  \"ip_city\": \"' + oLead.City + '\",'+
                                  '  \"ip_state\": \"' + oLead.StateCode + '\",'+
                                  '  \"ip_province\": \"\",'+
                                  '  \"ip_postal_code\": \"' + oLead.PostalCode + '\",'+
                                  '  \"ip_country\": \"' + oLead.CountryCode + '\",'+
                                  '  \"ip_salesforce_ref_id\": \"' + oExtController.sNewAccountId + '\",'+
                                  '  \"ip_county\": null,'+
                                  '  \"op_party_id\": \"' + sPartyId + '\",'+
                                  '  \"op_party_number\": \"' + sPartyNumber + '\",'+
                                  '  \"op_return_status\": \"\",'+
                                  '  \"op_return_message\": \"\"'+
                                  '}'
                                  , null);
            Test.setMock(HttpCalloutMock.class, oResponse); 

            //Assert PageReference return from createParty method call
            system.assertEquals('/apex/leadcreateaccountpartysummary?id=' + oLead.Id,oExtController.createParty().getURL());
        Test.stopTest();
	}    

    static testmethod void testCreatePartyCanada() {
        //Create Integration Id for testing
        Integration_Id__c oIntegrationId = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for lead assignment callout and create party callout
        Web_Service_Details__c oWebServiceLead = Test_Environment_Utility.createInsertWebServiceDetails('Territory Lookup');
        Web_Service_Details__c oWebServiceParty = Test_Environment_Utility.createInsertWebServiceDetails('Create Party');

        //Create random string values for Oracle_Party_Number__c and Oracle_Party_Id.
        String sPartyNumber = 'ERGO' + String.valueOf(math.random()).left(20);
        String sPartyId = 'ERGO' + String.valueOf(math.random()).left(20);

        //Create Lead for test
        Lead oLead = new Lead();
        oLead.Company='Test';
        oLead.FirstName='Test';
        oLead.LastName='Test';
        oLead.Ergotron_Vertical_Market__c='Enterprise';
        oLead.Street='Test';
        oLead.City='Test';
        oLead.StateCode='BC';
        oLead.PostalCode='55121';
        oLead.CountryCode='CA';
        oLead.Territory_Account_Manager__c=UserInfo.getUserId();

        insert oLead;

        //Create Account for test
        Account oAccount = Test_Environment_Utility.createInsertAccountCA();
            
        Test.startTest();
            PageReference oPageRef = Page.LeadCreateAccountParty;
            Test.setCurrentPage(oPageRef);
            //Instantiate standard and extension controller
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oLead);
            oPageRef.getParameters().put('id',String.valueOf(oLead.Id));
            Lead_Create_Account_Party_Cntrl oExtController = new Lead_Create_Account_Party_Cntrl(oStdController);

            //Set sAccountId on extension controller
            oExtController.sNewAccountId=oAccount.Id;

            //Set up mock web service response since web service callouts are not allowed from test classes
            SingleHTTPRequestMock_Test oResponse = new SingleHTTPRequestMock_Test(200,
                                  'OK',
                                  '{'+
                                  '  \"__type\": \"RepLocator.Party\",'+
                                  '  \"ip_verification_id\": \"' + oIntegrationId.Security_Id__c + '\",'+
                                  '  \"ip_party_name\": \"' + oLead.Company + '\",'+
                                  '  \"ip_address1\": \"' + oLead.Street + '\",'+
                                  '  \"ip_address2\": \"\",'+
                                  '  \"ip_address3\": \"\",'+
                                  '  \"ip_address4\": \"\",'+
                                  '  \"ip_city\": \"' + oLead.City + '\",'+
                                  '  \"ip_state\": \"' + oLead.StateCode + '\",'+
                                  '  \"ip_province\": \"\",'+
                                  '  \"ip_postal_code\": \"' + oLead.PostalCode + '\",'+
                                  '  \"ip_country\": \"' + oLead.CountryCode + '\",'+
                                  '  \"ip_salesforce_ref_id\": \"' + oExtController.sNewAccountId + '\",'+
                                  '  \"ip_county\": null,'+
                                  '  \"op_party_id\": \"' + sPartyId + '\",'+
                                  '  \"op_party_number\": \"' + sPartyNumber + '\",'+
                                  '  \"op_return_status\": \"\",'+
                                  '  \"op_return_message\": \"\"'+
                                  '}'
                                  , null);
            Test.setMock(HttpCalloutMock.class, oResponse); 

            //Assert PageReference return from createParty method call
            system.assertEquals('/apex/leadcreateaccountpartysummary?id=' + oLead.Id,oExtController.createParty().getURL());
        Test.stopTest();
	}

    static testmethod void testCreatePartyChina() {
        //Create Integration Id for testing
        Integration_Id__c oIntegrationId = Test_Environment_Utility.createInsertIntegrationId();

    	//Create web service details for lead assignment callout and create party callout
		Web_Service_Details__c oWebServiceLead = Test_Environment_Utility.createInsertWebServiceDetails('Territory Lookup');
		Web_Service_Details__c oWebServiceParty = Test_Environment_Utility.createInsertWebServiceDetails('Create Party');

        //Create random string values for Oracle_Party_Number__c and Oracle_Party_Id.
        String sPartyNumber = 'ERGO' + String.valueOf(math.random()).left(20);
        String sPartyId = 'ERGO' + String.valueOf(math.random()).left(20);

    	//Create Lead for test
    	Lead oLead = new Lead();
    	oLead.Company='Test';
    	oLead.FirstName='Test';
    	oLead.LastName='Test';
    	oLead.Ergotron_Vertical_Market__c='Enterprise';
    	oLead.Street='Test';
    	oLead.City='Test';
    	oLead.StateCode='11';
    	oLead.PostalCode='55121';
    	oLead.CountryCode='CN';
    	oLead.Territory_Account_Manager__c=UserInfo.getUserId();

    	insert oLead;

    	//Create Account for test
    	Account oAccount = Test_Environment_Utility.createInsertAccountCN();
            
        Test.startTest();
            PageReference oPageRef = Page.LeadCreateAccountParty;
            Test.setCurrentPage(oPageRef);
            //Instantiate standard and extension controller
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oLead);
            oPageRef.getParameters().put('id',String.valueOf(oLead.Id));
			Lead_Create_Account_Party_Cntrl oExtController = new Lead_Create_Account_Party_Cntrl(oStdController);

			//Set sAccountId on extension controller
			oExtController.sNewAccountId=oAccount.Id;

            //Set up mock web service response since web service callouts are not allowed from test classes
            SingleHTTPRequestMock_Test oResponse = new SingleHTTPRequestMock_Test(200,
                                  'OK',
                                  '{'+
                                  '  \"__type\": \"RepLocator.Party\",'+
                                  '  \"ip_verification_id\": \"' + oIntegrationId.Security_Id__c + '\",'+
                                  '  \"ip_party_name\": \"' + oLead.Company + '\",'+
                                  '  \"ip_address1\": \"' + oLead.Street + '\",'+
                                  '  \"ip_address2\": \"\",'+
                                  '  \"ip_address3\": \"\",'+
                                  '  \"ip_address4\": \"\",'+
                                  '  \"ip_city\": \"' + oLead.City + '\",'+
                                  '  \"ip_state\": \"' + oLead.StateCode + '\",'+
                                  '  \"ip_province\": \"\",'+
                                  '  \"ip_postal_code\": \"' + oLead.PostalCode + '\",'+
                                  '  \"ip_country\": \"' + oLead.CountryCode + '\",'+
                                  '  \"ip_salesforce_ref_id\": \"' + oExtController.sNewAccountId + '\",'+
                                  '  \"ip_county\": null,'+
                                  '  \"op_party_id\": \"' + sPartyId + '\",'+
                                  '  \"op_party_number\": \"' + sPartyNumber + '\",'+
                                  '  \"op_return_status\": \"\",'+
                                  '  \"op_return_message\": \"\"'+
                                  '}'
                                  , null);
            Test.setMock(HttpCalloutMock.class, oResponse); 

            //Assert PageReference return from createParty method call
            system.assertEquals('/apex/leadcreateaccountpartysummary?id=' + oLead.Id,oExtController.createParty().getURL());
		Test.stopTest();
	}

    static testmethod void testCreatePartyCalloutException() {
		//Create Integration Id for testing
        Integration_Id__c oIntegrationId = Test_Environment_Utility.createInsertIntegrationId();

    	//Create web service details for lead assignment callout and create party callout
		Web_Service_Details__c oWebServiceLead = Test_Environment_Utility.createInsertWebServiceDetails('Territory Lookup');
		Web_Service_Details__c oWebServiceParty = Test_Environment_Utility.createInsertWebServiceDetails('Create Party');

        //Create random string values for Oracle_Party_Number__c and Oracle_Party_Id.
        String sPartyNumber = 'ERGO' + String.valueOf(math.random()).left(20);
        String sPartyId = 'ERGO' + String.valueOf(math.random()).left(20);

    	//Create Lead for test
    	Lead oLead = new Lead();
    	oLead.Company='Test';
    	oLead.FirstName='Test';
    	oLead.LastName='Test';
    	oLead.Ergotron_Vertical_Market__c='Enterprise';
    	oLead.Street='Test';
    	oLead.City='Test';
    	oLead.StateCode='MN';
    	oLead.PostalCode='55121';
    	oLead.CountryCode='US';
    	oLead.Territory_Account_Manager__c=UserInfo.getUserId();

    	insert oLead;

    	//Create Account for test
    	Account oAccount = Test_Environment_Utility.createInsertAccountUS();
            
        Test.startTest();
            //Set up mock web service response since web service callouts are not allowed from test classes
            SingleHTTPRequestMock_Test oResponse = new SingleHTTPRequestMock_Test(200,
                                  'OK',
                                  '//{'+
                                  '  \"__type\": \"RepLocator.Party\",'+
                                  '  \"ip_verification_id\": \"' + oIntegrationId.Security_Id__c + '\",'+
                                  '  \"ip_party_name\": \"' + oLead.Company + '\",'+
                                  '  \"ip_address1\": \"' + oLead.Street + '\",'+
                                  '  \"ip_address2\": \"\",'+
                                  '  \"ip_address3\": \"\",'+
                                  '  \"ip_address4\": \"\",'+
                                  '  \"ip_city\": \"' + oLead.City + '\",'+
                                  '  \"ip_state\": \"' + oLead.StateCode + '\",'+
                                  '  \"ip_province\": \"\",'+
                                  '  \"ip_postal_code\": \"' + oLead.PostalCode + '\",'+
                                  '  \"ip_country\": \"' + oLead.CountryCode + '\",'+
                                  '  \"ip_salesforce_ref_id\": \"' + oAccount.Id + '\",'+
                                  '  \"ip_county\": null,'+
                                  '  \"op_party_id\": \"' + sPartyId + '\",'+
                                  '  \"op_party_number\": \"' + sPartyNumber + '\",'+
                                  '  \"op_return_status\": \"\",'+
                                  '  \"op_return_message\": \"\"'+
                                  '}'
                                  , null);
            Test.setMock(HttpCalloutMock.class, oResponse); 

            PageReference oPageRef = Page.LeadCreateAccountParty;
            Test.setCurrentPage(oPageRef);
            //Instantiate standard and extension controller
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oLead);
            oPageRef.getParameters().put('id',String.valueOf(oLead.Id));
			Lead_Create_Account_Party_Cntrl oExtController = new Lead_Create_Account_Party_Cntrl(oStdController);

			//Set sAccountId on extension controller
			oExtController.sNewAccountId=oAccount.Id;

            //Assert PageReference return from createParty method call
            system.assertEquals(null,oExtController.createParty());
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

    static testmethod void testCreatePartyCalloutStatusException() {
		//Create Integration Id for testing
        Integration_Id__c oIntegrationId = Test_Environment_Utility.createInsertIntegrationId();

    	//Create web service details for lead assignment callout and create party callout
		Web_Service_Details__c oWebServiceLead = Test_Environment_Utility.createInsertWebServiceDetails('Territory Lookup');
		Web_Service_Details__c oWebServiceParty = Test_Environment_Utility.createInsertWebServiceDetails('Create Party');

        //Create random string values for Oracle_Party_Number__c and Oracle_Party_Id.
        String sPartyNumber = 'ERGO' + String.valueOf(math.random()).left(20);
        String sPartyId = 'ERGO' + String.valueOf(math.random()).left(20);

    	//Create Lead for test
    	Lead oLead = new Lead();
    	oLead.Company='Test';
    	oLead.FirstName='Test';
    	oLead.LastName='Test';
    	oLead.Ergotron_Vertical_Market__c='Enterprise';
    	oLead.Street='Test';
    	oLead.City='Test';
    	oLead.StateCode='MN';
    	oLead.PostalCode='55121';
    	oLead.CountryCode='US';
    	oLead.Territory_Account_Manager__c=UserInfo.getUserId();

    	insert oLead;

    	//Create Account for test
    	Account oAccount = Test_Environment_Utility.createInsertAccountUS();
            
        Test.startTest();
            //Set up mock web service response since web service callouts are not allowed from test classes
            SingleHTTPRequestMock_Test oResponse = new SingleHTTPRequestMock_Test(404,
                                  '',
                                  '{'+
                                  '  \"__type\": \"RepLocator.Party\",'+
                                  '  \"ip_verification_id\": \"' + oIntegrationId.Security_Id__c + '\",'+
                                  '  \"ip_party_name\": \"' + oLead.Company + '\",'+
                                  '  \"ip_address1\": \"' + oLead.Street + '\",'+
                                  '  \"ip_address2\": \"\",'+
                                  '  \"ip_address3\": \"\",'+
                                  '  \"ip_address4\": \"\",'+
                                  '  \"ip_city\": \"' + oLead.City + '\",'+
                                  '  \"ip_state\": \"' + oLead.StateCode + '\",'+
                                  '  \"ip_province\": \"\",'+
                                  '  \"ip_postal_code\": \"' + oLead.PostalCode + '\",'+
                                  '  \"ip_country\": \"' + oLead.CountryCode + '\",'+
                                  '  \"ip_salesforce_ref_id\": \"' + oAccount.Id + '\",'+
                                  '  \"ip_county\": null,'+
                                  '  \"op_party_id\": \"' + sPartyId + '\",'+
                                  '  \"op_party_number\": \"' + sPartyNumber + '\",'+
                                  '  \"op_return_status\": \"\",'+
                                  '  \"op_return_message\": \"\"'+
                                  '}'
                                  , null);
            Test.setMock(HttpCalloutMock.class, oResponse); 

            PageReference oPageRef = Page.LeadCreateAccountParty;
            Test.setCurrentPage(oPageRef);
            //Instantiate standard and extension controller
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oLead);
            oPageRef.getParameters().put('id',String.valueOf(oLead.Id));
			Lead_Create_Account_Party_Cntrl oExtController = new Lead_Create_Account_Party_Cntrl(oStdController);

			//Set sAccountId on extension controller
			oExtController.sNewAccountId=oAccount.Id;

            //Assert PageReference return from createParty method call
            system.assertEquals(null,oExtController.createParty());
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

    static testmethod void testCreatePartyOracleAPIException() {
		//Create Integration Id for testing
        Integration_Id__c oIntegrationId = Test_Environment_Utility.createInsertIntegrationId();

    	//Create web service details for lead assignment callout and create party callout
		Web_Service_Details__c oWebServiceLead = Test_Environment_Utility.createInsertWebServiceDetails('Territory Lookup');
		Web_Service_Details__c oWebServiceParty = Test_Environment_Utility.createInsertWebServiceDetails('Create Party');

        //Create random string values for Oracle_Party_Number__c and Oracle_Party_Id.
        String sPartyNumber = 'ERGO' + String.valueOf(math.random()).left(20);
        String sPartyId = 'ERGO' + String.valueOf(math.random()).left(20);

    	//Create Lead for test
    	Lead oLead = new Lead();
    	oLead.Company='Test';
    	oLead.FirstName='Test';
    	oLead.LastName='Test';
    	oLead.Ergotron_Vertical_Market__c='Enterprise';
    	oLead.Street='Test';
    	oLead.City='Test';
    	oLead.StateCode='MN';
    	oLead.PostalCode='55121';
    	oLead.CountryCode='US';
    	oLead.Territory_Account_Manager__c=UserInfo.getUserId();

    	insert oLead;

    	//Create Account for test
    	Account oAccount = Test_Environment_Utility.createInsertAccountUS();
            
        Test.startTest();
            //Set up mock web service response since web service callouts are not allowed from test classes
            SingleHTTPRequestMock_Test oResponse = new SingleHTTPRequestMock_Test(200,
                                  'OK',
                                  '{'+
                                  '  \"__type\": \"RepLocator.Party\",'+
                                  '  \"ip_verification_id\": \"' + oIntegrationId.Security_Id__c + '\",'+
                                  '  \"ip_party_name\": \"' + oLead.Company + '\",'+
                                  '  \"ip_address1\": \"' + oLead.Street + '\",'+
                                  '  \"ip_address2\": \"\",'+
                                  '  \"ip_address3\": \"\",'+
                                  '  \"ip_address4\": \"\",'+
                                  '  \"ip_city\": \"' + oLead.City + '\",'+
                                  '  \"ip_state\": \"' + oLead.StateCode + '\",'+
                                  '  \"ip_province\": \"\",'+
                                  '  \"ip_postal_code\": \"' + oLead.PostalCode + '\",'+
                                  '  \"ip_country\": \"' + oLead.CountryCode + '\",'+
                                  '  \"ip_salesforce_ref_id\": \"' + oAccount.Id + '\",'+
                                  '  \"ip_county\": null,'+
                                  '  \"op_party_id\": \"' + sPartyId + '\",'+
                                  '  \"op_party_number\": \"' + sPartyNumber + '\",'+
                                  '  \"op_return_status\": \"E\",'+
                                  '  \"op_return_message\": \"ORACLE API ERROR\"'+
                                  '}'
                                  , null);
            Test.setMock(HttpCalloutMock.class, oResponse); 

            PageReference oPageRef = Page.LeadCreateAccountParty;
            Test.setCurrentPage(oPageRef);
            //Instantiate standard and extension controller
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oLead);
            oPageRef.getParameters().put('id',String.valueOf(oLead.Id));
			Lead_Create_Account_Party_Cntrl oExtController = new Lead_Create_Account_Party_Cntrl(oStdController);

			//Set sAccountId on extension controller
			oExtController.sNewAccountId=oAccount.Id;

            //Assert PageReference return from createParty method call
            system.assertEquals(null,oExtController.createParty());
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

    static testmethod void testCreateExceptionAccountExists() {
		//Create web service details for lead assignment callout and create party callout
		Web_Service_Details__c oWebServiceLead = Test_Environment_Utility.createInsertWebServiceDetails('Territory Lookup');

    	//Create Account for test
    	Account oAccount = Test_Environment_Utility.createInsertAccountUS('test-1234');

    	//Create Lead for test
    	Lead oLead = new Lead();
    	oLead.Company='Test';
    	oLead.FirstName='Test';
    	oLead.LastName='Test';
    	oLead.Ergotron_Vertical_Market__c='Enterprise';
    	oLead.Street='Test';
    	oLead.City='Test';
    	oLead.StateCode='MN';
    	oLead.PostalCode='55121';
    	oLead.CountryCode='US';
    	oLead.Territory_Account_Manager__c=UserInfo.getUserId();
    	oLead.End_User_Account__c=oAccount.Id;

    	insert oLead;
            
        Test.startTest();
            PageReference oPageRef = Page.LeadCreateAccountParty;
            Test.setCurrentPage(oPageRef);
            //Instantiate standard and extension controller
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oLead);
            oPageRef.getParameters().put('id',String.valueOf(oLead.Id));
			Lead_Create_Account_Party_Cntrl oExtController = new Lead_Create_Account_Party_Cntrl(oStdController);

			system.assertEquals(true,oExtController.bAlreadyEndUser);
        Test.stopTest();
	}

    static testmethod void testCreatePartyNoIntegrationId() {
		//Create web service details for lead assignment callout and create party callout
		Web_Service_Details__c oWebServiceLead = Test_Environment_Utility.createInsertWebServiceDetails('Territory Lookup');
		Web_Service_Details__c oWebServiceParty = Test_Environment_Utility.createInsertWebServiceDetails('Create Party');

        //Create random string values for Oracle_Party_Number__c and Oracle_Party_Id.
        String sPartyNumber = 'ERGO' + String.valueOf(math.random()).left(20);
        String sPartyId = 'ERGO' + String.valueOf(math.random()).left(20);

    	//Create Lead for test
    	Lead oLead = new Lead();
    	oLead.Company='Test';
    	oLead.FirstName='Test';
    	oLead.LastName='Test';
    	oLead.Ergotron_Vertical_Market__c='Enterprise';
    	oLead.Street='Test';
    	oLead.City='Test';
    	oLead.StateCode='MN';
    	oLead.PostalCode='55121';
    	oLead.CountryCode='US';
    	oLead.Territory_Account_Manager__c=UserInfo.getUserId();

    	insert oLead;

    	//Create Account for test
    	Account oAccount = Test_Environment_Utility.createInsertAccountUS();
            
        Test.startTest();
            //Set up mock web service response since web service callouts are not allowed from test classes
            SingleHTTPRequestMock_Test oResponse = new SingleHTTPRequestMock_Test(200,
                                  'OK',
                                  '{'+
                                  '  \"__type\": \"RepLocator.Party\",'+
                                  '  \"ip_verification_id\": \"\",'+
                                  '  \"ip_party_name\": \"' + oLead.Company + '\",'+
                                  '  \"ip_address1\": \"' + oLead.Street + '\",'+
                                  '  \"ip_address2\": \"\",'+
                                  '  \"ip_address3\": \"\",'+
                                  '  \"ip_address4\": \"\",'+
                                  '  \"ip_city\": \"' + oLead.City + '\",'+
                                  '  \"ip_state\": \"' + oLead.StateCode + '\",'+
                                  '  \"ip_province\": \"\",'+
                                  '  \"ip_postal_code\": \"' + oLead.PostalCode + '\",'+
                                  '  \"ip_country\": \"' + oLead.CountryCode + '\",'+
                                  '  \"ip_salesforce_ref_id\": \"' + oAccount.Id + '\",'+
                                  '  \"ip_county\": null,'+
                                  '  \"op_party_id\": \"' + sPartyId + '\",'+
                                  '  \"op_party_number\": \"' + sPartyNumber + '\",'+
                                  '  \"op_return_status\": \"E\",'+
                                  '  \"op_return_message\": \"ORACLE API ERROR\"'+
                                  '}'
                                  , null);
            Test.setMock(HttpCalloutMock.class, oResponse); 

            PageReference oPageRef = Page.LeadCreateAccountParty;
            Test.setCurrentPage(oPageRef);
            //Instantiate standard and extension controller
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oLead);
            oPageRef.getParameters().put('id',String.valueOf(oLead.Id));
			Lead_Create_Account_Party_Cntrl oExtController = new Lead_Create_Account_Party_Cntrl(oStdController);

			//Set sAccountId on extension controller
			oExtController.sNewAccountId=oAccount.Id;

            //Assert PageReference return from createParty method call
            system.assertEquals(null,oExtController.createParty());
            //Assert page messages
            Boolean bFoundMessage=false;
            for(ApexPages.Message oMessage :ApexPages.getMessages()) {
				bFoundMessage=true;
            }	
            system.assert(bFoundMessage);
		Test.stopTest();
	}
}