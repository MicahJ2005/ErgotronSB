/*
    Test class for Oracle_Create_Party_Controller.cls

    MOD DATE		Who						Description
    10/09/2014		Chris Noe				Initial Release
*/
@isTest
private class Oracle_Create_Party_Controller_Test {

    //Test method for creating Oracle party with US address
    static testMethod void createPartyUS() {
        //Create random string values for Oracle_Party_Number__c and Oracle_Party_Id.
        String sPartyNumber = 'ERGO' + String.valueOf(math.random()).left(20);
        String sPartyId = 'ERGO' + String.valueOf(math.random()).left(20);

        //Create Account for testing
        Account oAccount = Test_Environment_Utility.createInsertAccountUS();

        //Create Integration Id for testing
        Integration_Id__c oIntegrationId = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetail = Test_Environment_Utility.createInsertWebServiceDetails('Create Party');

        Test.startTest();
            //Retrieve newly created Account and Integration_Id__c fields needed for HTTP response.
            oAccount = [select Id, Name, BillingStreet, BillingCity, BillingStateCode, BillingPostalCode, BillingCountryCode from Account where Id = :oAccount.Id];            
            oIntegrationId = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationId.Id];

            //Set up mock web service response since web service callouts are not allowed from test classes
            SingleHTTPRequestMock_Test oResponse = new SingleHTTPRequestMock_Test(200,
                                  'OK',
                                  '{'+
                                  '  \"__type\": \"RepLocator.Party\",'+
                                  '  \"ip_verification_id\": \"' + oIntegrationId.Security_Id__c + '\",'+
                                  '  \"ip_party_name\": \"' + oAccount.Name + '\",'+
                                  '  \"ip_address1\": \"' + oAccount.BillingStreet + '\",'+
                                  '  \"ip_address2\": \"\",'+
                                  '  \"ip_address3\": \"\",'+
                                  '  \"ip_address4\": \"\",'+
                                  '  \"ip_city\": \"' + oAccount.BillingCity + '\",'+
                                  '  \"ip_state\": \"' + oAccount.BillingStateCode + '\",'+
                                  '  \"ip_province\": \"\",'+
                                  '  \"ip_postal_code\": \"' + oAccount.BillingPostalCode + '\",'+
                                  '  \"ip_country\": \"' + oAccount.BillingCountryCode + '\",'+
                                  '  \"ip_salesforce_ref_id\": \"' + oAccount.Id + '\",'+
                                  '  \"ip_county\": null,'+
                                  '  \"op_party_id\": \"' + sPartyId + '\",'+
                                  '  \"op_party_number\": \"' + sPartyNumber + '\",'+
                                  '  \"op_return_status\": \"\",'+
                                  '  \"op_return_message\": \"\"'+
                                  '}'
                                  , null);
            Test.setMock(HttpCalloutMock.class, oResponse); 

            PageReference oPageRef = Page.OracleCreateParty;
            Test.setCurrentPage(oPageRef); 
            //Invoke the standard and extension controllers with Account created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oAccount);
            oPageRef.getParameters().put('id',String.valueOf(oAccount.Id));
            Oracle_Create_Party_Controller oExtController = new Oracle_Create_Party_Controller(oStdController);

            //Invoke the createParty method on the Oracle_Create_Party_Controller.cls
            oPageRef = oExtController.createParty();

            //Assert return of OracleCreatePartySummary page
            system.assertEquals('/apex/oraclecreatepartysummary?id=' + oAccount.Id,oPageRef.getURL());	

            //Retrieve the Account object with Oracle_Party_Number__c and Oracle_Party_Id__c values
            oAccount = [select Id, Oracle_Party_Number__c, Oracle_Party_Id__c from Account where Id = :oAccount.Id];
            //Assert Oracle_Party_Number__c and Oracle_Party_Id__c values returned from the query above
            system.assertEquals(sPartyNumber,oAccount.Oracle_Party_Number__c);
            system.assertEquals(sPartyId,oAccount.Oracle_Party_Id__c);		
        Test.stopTest();
    }

    //Test method for creating Oracle party with CA address
    static testMethod void createPartyCA() {
        //Create random string values for Oracle_Party_Number__c and Oracle_Party_Id.
        String sPartyNumber = 'ERGO' + String.valueOf(math.random()).left(20);
        String sPartyId = 'ERGO' + String.valueOf(math.random()).left(20);

        //Create Account for testing
        Account oAccount = Test_Environment_Utility.createInsertAccountCA();

        //Create Integration Id for testing
        Integration_Id__c oIntegrationId = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetail = Test_Environment_Utility.createInsertWebServiceDetails('Create Party');

        Test.startTest();
            //Retrieve newly created Account and Integration_Id__c fields needed for HTTP response.
            oAccount = [select Id, Name, BillingStreet, BillingCity, BillingStateCode, BillingPostalCode, BillingCountryCode from Account where Id = :oAccount.Id];            
            oIntegrationId = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationId.Id];           

            //Set up mock web service response since web service callouts are not allowed from test classes
            SingleHTTPRequestMock_Test oResponse = new SingleHTTPRequestMock_Test(200,
                                  'OK',
                                  '{'+
                                  '  \"__type\": \"RepLocator.Party\",'+
                                  '  \"ip_verification_id\": \"' + oIntegrationId.Security_Id__c + '\",'+
                                  '  \"ip_party_name\": \"' + oAccount.Name + '\",'+
                                  '  \"ip_address1\": \"' + oAccount.BillingStreet + '\",'+
                                  '  \"ip_address2\": \"\",'+
                                  '  \"ip_address3\": \"\",'+
                                  '  \"ip_address4\": \"\",'+
                                  '  \"ip_city\": \"' + oAccount.BillingCity + '\",'+
                                  '  \"ip_state\": \"' + oAccount.BillingCountryCode + '\",'+
                                  '  \"ip_province\": \"' + oAccount.BillingStateCode + '\",'+
                                  '  \"ip_postal_code\": \"' + oAccount.BillingPostalCode + '\",'+
                                  '  \"ip_country\": \"' + oAccount.BillingCountryCode + '\",'+
                                  '  \"ip_salesforce_ref_id\": \"' + oAccount.Id + '\",'+
                                  '  \"ip_county\": null,'+
                                  '  \"op_party_id\": \"' + sPartyId + '\",'+
                                  '  \"op_party_number\": \"' + sPartyNumber + '\",'+
                                  '  \"op_return_status\": \"\",'+
                                  '  \"op_return_message\": \"\"'+
                                  '}'
                                  , null);
            Test.setMock(HttpCalloutMock.class, oResponse); 

            PageReference oPageRef = Page.OracleCreateParty;
            Test.setCurrentPage(oPageRef); 
            //Invoke the standard and extension controllers with Account created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oAccount);
            oPageRef.getParameters().put('id',String.valueOf(oAccount.Id));
            Oracle_Create_Party_Controller oExtController = new Oracle_Create_Party_Controller(oStdController);

            //Invoke the createParty method on the Oracle_Create_Party_Controller.cls
            oPageRef = oExtController.createParty();

            //Assert return of OracleCreatePartySummary page
            system.assertEquals('/apex/oraclecreatepartysummary?id=' + oAccount.Id,oPageRef.getURL());	

            //Retrieve the Account object with Oracle_Party_Number__c and Oracle_Party_Id__c values
            oAccount = [select Id, Oracle_Party_Number__c, Oracle_Party_Id__c from Account where Id = :oAccount.Id];
            //Assert Oracle_Party_Number__c and Oracle_Party_Id__c values returned from the query above
            system.assertEquals(sPartyNumber,oAccount.Oracle_Party_Number__c);
            system.assertEquals(sPartyId,oAccount.Oracle_Party_Id__c);		
        Test.stopTest();
    }

    //Test method for creating Oracle party with CN address
    static testMethod void createPartyCN() {
        //Create random string values for Oracle_Party_Number__c and Oracle_Party_Id.
        String sPartyNumber = 'ERGO' + String.valueOf(math.random()).left(20);
        String sPartyId = 'ERGO' + String.valueOf(math.random()).left(20);

        //Create Account for testing
        Account oAccount = Test_Environment_Utility.createInsertAccountCN();

        //Create Integration Id for testing
        Integration_Id__c oIntegrationId = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetail = Test_Environment_Utility.createInsertWebServiceDetails('Create Party');

        Test.startTest();
            //Retrieve newly created Account and Integration_Id__c fields needed for HTTP response.
            oAccount = [select Id, Name, BillingStreet, BillingCity, BillingStateCode, BillingPostalCode, BillingCountryCode from Account where Id = :oAccount.Id];            
            oIntegrationId = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationId.Id];           

            //Set up mock web service response since web service callouts are not allowed from test classes
            SingleHTTPRequestMock_Test oResponse = new SingleHTTPRequestMock_Test(200,
                                'OK',
                                '{'+
                                '  \"__type\": \"RepLocator.Party\",'+
                                '  \"ip_verification_id\": \"' + oIntegrationId.Security_Id__c + '\",'+
                                '  \"ip_party_name\": \"' + oAccount.Name + '\",'+
                                '  \"ip_address1\": \"' + oAccount.BillingStreet + '\",'+
                                '  \"ip_address2\": \"\",'+
                                '  \"ip_address3\": \"\",'+
                                '  \"ip_address4\": \"\",'+
                                '  \"ip_city\": \"' + oAccount.BillingCity + '\",'+
                                '  \"ip_state\": \"' + oAccount.BillingCountryCode + '\",'+
                                '  \"ip_province\": \"' + oAccount.BillingStateCode + '\",'+
                                '  \"ip_postal_code\": \"' + oAccount.BillingPostalCode + '\",'+
                                '  \"ip_country\": \"' + oAccount.BillingCountryCode + '\",'+
                                '  \"ip_salesforce_ref_id\": \"' + oAccount.Id + '\",'+
                                '  \"ip_county\": null,'+
                                '  \"op_party_id\": \"' + sPartyId + '\",'+
                                '  \"op_party_number\": \"' + sPartyNumber + '\",'+
                                '  \"op_return_status\": \"\",'+
                                '  \"op_return_message\": \"\"'+
                                '}'
                                , null);

            Test.setMock(HttpCalloutMock.class, oResponse); 

            PageReference oPageRef = Page.OracleCreateParty;
            Test.setCurrentPage(oPageRef); 
            //Invoke the standard and extension controllers with Account created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oAccount);
            oPageRef.getParameters().put('id',String.valueOf(oAccount.Id));
            Oracle_Create_Party_Controller oExtController = new Oracle_Create_Party_Controller(oStdController);

            //Invoke the createParty method on the Oracle_Create_Party_Controller.cls
            oPageRef = oExtController.createParty();

            //Assert return of OracleCreatePartySummary page
            system.assertEquals('/apex/oraclecreatepartysummary?id=' + oAccount.Id,oPageRef.getURL());	

            //Retrieve the Account object with Oracle_Party_Number__c and Oracle_Party_Id__c values
            oAccount = [select Id, Oracle_Party_Number__c, Oracle_Party_Id__c from Account where Id = :oAccount.Id];
            //Assert Oracle_Party_Number__c and Oracle_Party_Id__c values returned from the query above
            system.assertEquals(sPartyNumber,oAccount.Oracle_Party_Number__c);
            system.assertEquals(sPartyId,oAccount.Oracle_Party_Id__c);		
        Test.stopTest();
    }

    //Test method for callout exception
    static testMethod void createPartyCalloutException() {
        //Create Account for testing
        Account oAccount = Test_Environment_Utility.createInsertAccountUS();

        //Create Integration Id for testing
        Integration_Id__c oIntegrationId = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetail = Test_Environment_Utility.createInsertWebServiceDetails('Create Party');

        Test.startTest();
            //Retrieve newly created Account and Integration_Id__c fields needed for HTTP response.
            oAccount = [select Id, Name, BillingStreet, BillingCity, BillingStateCode, BillingPostalCode, BillingCountryCode from Account where Id = :oAccount.Id];            
            oIntegrationId = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationId.Id];           

            //Set up mock web service response since web service callouts are not allowed from test classes.  JSON string formatted with bad characters // which
            //will cause a callout exception to be thrown.
            SingleHTTPRequestMock_Test oResponse = new SingleHTTPRequestMock_Test(200,
                                  'OK',
                                  '//{'+
                                  '  \"__type\": \"RepLocator.Party\",'+
                                  '  \"ip_verification_id\": \"' + oIntegrationId.Security_Id__c + '\",'+
                                  '  \"ip_party_name\": \"' + oAccount.Name + '\",'+
                                  '  \"ip_address1\": \"' + oAccount.BillingStreet + '\",'+
                                  '  \"ip_address2\": \"\",'+
                                  '  \"ip_address3\": \"\",'+
                                  '  \"ip_address4\": \"\",'+
                                  '  \"ip_city\": \"' + oAccount.BillingCity + '\",'+
                                  '  \"ip_state\": \"' + oAccount.BillingStateCode + '\",'+
                                  '  \"ip_province\": \"\",'+
                                  '  \"ip_postal_code\": \"' + oAccount.BillingPostalCode + '\",'+
                                  '  \"ip_country\": \"' + oAccount.BillingCountryCode + '\",'+
                                  '  \"ip_salesforce_ref_id\": \"' + oAccount.Id + '\",'+
                                  '  \"ip_county\": null,'+
                                  '  \"op_party_id\": \"\",'+
                                  '  \"op_party_number\": \"\",'+
                                  '  \"op_return_status\": \"\",'+
                                  '  \"op_return_message\": \"\"'+
                                  '}'
                                  , null);

            Test.setMock(HttpCalloutMock.class, oResponse); 

            PageReference oPageRef = Page.OracleCreateParty;
            Test.setCurrentPage(oPageRef); 
            //Invoke the standard and extension controllers with Account created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oAccount);
            oPageRef.getParameters().put('id',String.valueOf(oAccount.Id));
            Oracle_Create_Party_Controller oExtController = new Oracle_Create_Party_Controller(oStdController);

            //Invoke the createParty method on the Oracle_Create_Party_Controller.cls
            oPageRef = oExtController.createParty();

            //Assert return of null page
            system.assertEquals(null,oPageRef);
            //Assert page messages
            Boolean bFoundMessage=false;
            for(ApexPages.Message oMessage :ApexPages.getMessages()) {
                if(oMessage.getDetail().contains('CALLOUT EXCEPTION')) {
                    bFoundMessage=true;
                }
            }	
            system.assert(bFoundMessage);

            //Retrieve the Account object with Oracle_Party_Number__c and Oracle_Party_Id__c values
            oAccount = [select Id, Oracle_Party_Number__c, Oracle_Party_Id__c from Account where Id = :oAccount.Id];
            //Assert Oracle_Party_Number__c and Oracle_Party_Id__c values are null
            system.assertEquals(null,oAccount.Oracle_Party_Number__c);
            system.assertEquals(null,oAccount.Oracle_Party_Id__c);		
        Test.stopTest();
    }			

    //Test method for callout status exception
    static testMethod void createPartyCalloutStatusException() {
        //Create Account for testing
        Account oAccount = Test_Environment_Utility.createInsertAccountUS();

        //Create Integration Id for testing
        Integration_Id__c oIntegrationId = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetail = Test_Environment_Utility.createInsertWebServiceDetails('Create Party');

        Test.startTest();
            //Retrieve newly created Account and Integration_Id__c fields needed for HTTP response.
            oAccount = [select Id, Name, BillingStreet, BillingCity, BillingStateCode, BillingPostalCode, BillingCountryCode from Account where Id = :oAccount.Id];            
            oIntegrationId = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationId.Id];            

            //Set up mock web service response since web service callouts are not allowed from test classes.  JSON string formatted with bad characters // which
            //will cause a callout exception to be thrown.
            SingleHTTPRequestMock_Test oResponse = new SingleHTTPRequestMock_Test(404,
                                  '',
                                  '{'+
                                  '  \"__type\": \"RepLocator.Party\",'+
                                  '  \"ip_verification_id\": \"' + oIntegrationId.Security_Id__c + '\",'+
                                  '  \"ip_party_name\": \"' + oAccount.Name + '\",'+
                                  '  \"ip_address1\": \"' + oAccount.BillingStreet + '\",'+
                                  '  \"ip_address2\": \"\",'+
                                  '  \"ip_address3\": \"\",'+
                                  '  \"ip_address4\": \"\",'+
                                  '  \"ip_city\": \"' + oAccount.BillingCity + '\",'+
                                  '  \"ip_state\": \"' + oAccount.BillingStateCode + '\",'+
                                  '  \"ip_province\": \"\",'+
                                  '  \"ip_postal_code\": \"' + oAccount.BillingPostalCode + '\",'+
                                  '  \"ip_country\": \"' + oAccount.BillingCountryCode + '\",'+
                                  '  \"ip_salesforce_ref_id\": \"' + oAccount.Id + '\",'+
                                  '  \"ip_county\": null,'+
                                  '  \"op_party_id\": \"\",'+
                                  '  \"op_party_number\": \"\",'+
                                  '  \"op_return_status\": \"\",'+
                                  '  \"op_return_message\": \"\"'+
                                  '}'
                                  , null);

            Test.setMock(HttpCalloutMock.class, oResponse); 

            PageReference oPageRef = Page.OracleCreateParty;
            Test.setCurrentPage(oPageRef); 
            //Invoke the standard and extension controllers with Account created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oAccount);
            oPageRef.getParameters().put('id',String.valueOf(oAccount.Id));
            Oracle_Create_Party_Controller oExtController = new Oracle_Create_Party_Controller(oStdController);

            //Invoke the createParty method on the Oracle_Create_Party_Controller.cls
            oPageRef = oExtController.createParty();

            //Assert return of null page
            system.assertEquals(null,oPageRef);
            //Assert page messages
            Boolean bFoundMessage=false;
            for(ApexPages.Message oMessage :ApexPages.getMessages()) {
                if(oMessage.getDetail().contains('STATUS EXCEPTION')) {
                    bFoundMessage=true;
                }
            }	
            system.assert(bFoundMessage);

            //Retrieve the Account object with Oracle_Party_Number__c and Oracle_Party_Id__c values
            oAccount = [select Id, Oracle_Party_Number__c, Oracle_Party_Id__c from Account where Id = :oAccount.Id];
            //Assert Oracle_Party_Number__c and Oracle_Party_Id__c values are null
            system.assertEquals(null,oAccount.Oracle_Party_Number__c);
            system.assertEquals(null,oAccount.Oracle_Party_Id__c);		
        Test.stopTest();
    }

    //Test method for callout Oracle API exception
    static testMethod void createPartyCalloutOracleAPIException() {
        //Create Account for testing
        Account oAccount = Test_Environment_Utility.createInsertAccountUS();

        //Create Integration Id for testing
        Integration_Id__c oIntegrationId = Test_Environment_Utility.createInsertIntegrationId();

        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetail = Test_Environment_Utility.createInsertWebServiceDetails('Create Party');

        Test.startTest();
            //Retrieve newly created Account and Integration_Id__c fields needed for HTTP response.
            oAccount = [select Id, Name, BillingStreet, BillingCity, BillingStateCode, BillingPostalCode, BillingCountryCode from Account where Id = :oAccount.Id];            
            oIntegrationId = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationId.Id];            

            //Set up mock web service response since web service callouts are not allowed from test classes.  JSON string formatted with bad characters // which
            //will cause a callout exception to be thrown.
            SingleHTTPRequestMock_Test oResponse = new SingleHTTPRequestMock_Test(200,
                                  'OK',
                                  '{'+
                                  '  \"__type\": \"RepLocator.Party\",'+
                                  '  \"ip_verification_id\": \"' + oIntegrationId.Security_Id__c + '\",'+
                                  '  \"ip_party_name\": \"' + oAccount.Name + '\",'+
                                  '  \"ip_address1\": \"' + oAccount.BillingStreet + '\",'+
                                  '  \"ip_address2\": \"\",'+
                                  '  \"ip_address3\": \"\",'+
                                  '  \"ip_address4\": \"\",'+
                                  '  \"ip_city\": \"' + oAccount.BillingCity + '\",'+
                                  '  \"ip_state\": \"' + oAccount.BillingStateCode + '\",'+
                                  '  \"ip_province\": \"\",'+
                                  '  \"ip_postal_code\": \"' + oAccount.BillingPostalCode + '\",'+
                                  '  \"ip_country\": \"' + oAccount.BillingCountryCode + '\",'+
                                  '  \"ip_salesforce_ref_id\": \"' + oAccount.Id + '\",'+
                                  '  \"ip_county\": null,'+
                                  '  \"op_party_id\": \"\",'+
                                  '  \"op_party_number\": \"\",'+
                                  '  \"op_return_status\": \"E\",'+
                                  '  \"op_return_message\": \"ORACLE API ERROR\"'+
                                  '}'
                                  , null);

            Test.setMock(HttpCalloutMock.class, oResponse); 

            PageReference oPageRef = Page.OracleCreateParty;
            Test.setCurrentPage(oPageRef); 
            //Invoke the standard and extension controllers with Account created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oAccount);
            oPageRef.getParameters().put('id',String.valueOf(oAccount.Id));
            Oracle_Create_Party_Controller oExtController = new Oracle_Create_Party_Controller(oStdController);

            //Invoke the createParty method on the Oracle_Create_Party_Controller.cls
            oPageRef = oExtController.createParty();

            //Assert return of null page
            system.assertEquals(null,oPageRef);
            //Assert page messages
            Boolean bFoundMessage=false;
            for(ApexPages.Message oMessage :ApexPages.getMessages()) {
                if(oMessage.getDetail().contains('ORACLE API EXCEPTION')) {
                    bFoundMessage=true;
                }
            }	
            system.assert(bFoundMessage);

            //Retrieve the Account object with Oracle_Party_Number__c and Oracle_Party_Id__c values
            oAccount = [select Id, Oracle_Party_Number__c, Oracle_Party_Id__c from Account where Id = :oAccount.Id];
            //Assert Oracle_Party_Number__c and Oracle_Party_Id__c values are null
            system.assertEquals(null,oAccount.Oracle_Party_Number__c);
            system.assertEquals(null,oAccount.Oracle_Party_Id__c);		
        Test.stopTest();
    }	
}