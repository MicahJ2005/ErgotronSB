/*
	Test class for Seed_Unit_Order_Submit_Controller.cls

	MOD DATE		Who						Description
	4/23/2014		Chris Noe				Initial Release
    9/3/2014        Chris Noe               Updates related to FB-00449 to properly set the bill to account on seed unit orders for hospitals.
    10/09/2014      Chris Noe               Updates related to FB-00368 and the implementation of new web service callouts for creating customers.
*/
@isTest
private class Seed_Unit_Order_Summary_Controller_Test {

    static testMethod void constructorTest() {
        //Test method for constructor and getFormattedSubmissionDate method
        String sPartyId = 'ERGO' + String.valueOf(math.random()).left(20);

		//Create account for testing
        Account oAccount = Test_Environment_Utility.createInsertAccountUS();
        oAccount.Oracle_Party_Id__c = sPartyId;
        oAccount.Oracle_Party_Number__c = sPartyId;
        update oAccount;
        //Create contact for testing
        Contact oContact = Test_Environment_Utility.createInsertContact(oAccount);
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccount, 'Seeding', Date.today());
        //Create seed unit orders for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Hospital', oAccount, oContact);
        //Create products for testing
        Product2 oProduct = Test_Environment_Utility.createInsertProduct();
        oProduct.Seed_Unit_Eligible_Hospital__c=true;
        update oProduct;
        //Create seed unit products for testing
        Seed_Unit_Product__c oSeedUnitProduct = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProduct, 5);

        //Create Integration Id for testing
        Integration_Id__c oIntegrationId = Test_Environment_Utility.createInsertIntegrationId();
        //Create web service details for testing
        Web_Service_Details__c oWebServiceDetail = Test_Environment_Utility.createInsertWebServiceDetails('Create Customer');
        
        Test.startTest();
            //Retrieve newly created Account, Seed_Unit_Order__c, and Integration_Id__c fields needed for HTTP response.
            oAccount = [select Id, Name, BillingStreet, BillingCity, BillingStateCode, BillingPostalCode, BillingCountryCode, Oracle_Party_Id__c, Oracle_Party_Number__c from Account where Id = :oAccount.Id];            
            oIntegrationId = [select Id, Security_Id__c from Integration_Id__c where Id = : oIntegrationId.Id];             
            oSeedUnitOrder = [select Id, Sold_To_Org__c, Opportunity__c, Opportunity__r.Account.ParentId, Opportunity__r.AccountId, Name, Seed_Unit_Order_Submitted__c, Seed_Unit_Approval_Status__c,
                                Opportunity__r.Account.BillingStreet, Opportunity__r.Account.BillingCity, Opportunity__r.Account.BillingStateCode, Opportunity__r.Account.BillingPostalCode, Ship_To_Country__c,
                                Opportunity__r.Account.BillingCountryCode, Seed_Unit_Location_Type__c, Opportunity__r.Account.Parent.ParentId, Opportunity__r.Account.Name, Ship_To_Org_Id__c,
                                Ship_To_Address4__c, Ship_To_Address3__c, Ship_To_Address2__c, Sold_To_Salesforce_Id__c, Opportunity__r.Account.Id, Sold_To_Party_Name__c, Ship_To_County__c, Ship_To_Address__c,
                                Ship_To_Address1__c, Ship_To_City__c, ORIG_SYS_DOCUMENT_REF__c, Sold_To_Party_Id__c, Sold_To_Org_Id__c, Ship_To_State_Province__c, Ship_To_Postal_Code__c, Ship_To_Contact_First_Name__c,
                                Ship_To_Contact_Last_Name__c, Ship_To_Contact_Email__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Role_Id__c, Ship_To_Account__r.Name, Ship_To_Salesforce_Id__c,
                                Ship_To_Customer_Account_Id__c, Ship_To_Party_Id__c, Ship_To_Party_Name__c, Ship_To_Contact__c
                                from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id]; 

            //Set up response since web service callouts are not allowed from test classes
            SingleHTTPRequestMock_Test fakeResponseTrigger = new SingleHTTPRequestMock_Test(200,
                                                            'OK',
                '{'+
                '  \"__type\": \"RepLocator.Customer\",'+
                '  \"ip_verification_id\": \"' + oIntegrationId.Security_Id__c + '\",'+
                '  \"ip_party_id\": \"' + oAccount.Oracle_Party_Id__c + '\",'+
                '  \"ip_cust_account_id\": \"\",'+
                '  \"ip_ship_to_site_use_id\": \"\",'+
                '  \"ip_organization_name\": \"\",'+
                '  \"ip_account_name\": \"\",'+
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
                '  \"op_party_id\": \"' + oAccount.Oracle_Party_Id__c + '\",'+
                '  \"op_party_number\": \"' + oAccount.Oracle_Party_Number__c + '\",'+
                '  \"op_cust_account_id\": \"\",'+
                '  \"op_ship_to_site_use_id\": \"626880\",'+
                '  \"op_bill_to_site_use_id\": \"626879\",'+
                '  \"op_ship_to_contact_id\": \"21046994\",'+
                '  \"op_cust_account_role_id\": \"19300031\",'+
                '  \"op_return_status\": \"\",'+
                '  \"op_return_message\": \"\"'+
                '}'
                 , null);
            Test.setMock(HttpCalloutMock.class, fakeResponseTrigger);			

            PageReference oPageRef = Page.SeedUnitOrderSummary;
            Test.setCurrentPage(oPageRef);
            //Submit seed unit order: Invoke the standard and extension controllers with seed unit order created above
			ApexPages.StandardController oStdControllerOrder = new ApexPages.StandardController(oSeedUnitOrder);
            oPageRef.getParameters().put('id',String.valueOf(oSeedUnitOrder.Id));
			Seed_Unit_Order_Confirmation_Controller oExtControllerOrder = new Seed_Unit_Order_Confirmation_Controller(oStdControllerOrder);
        	
        	PageReference oTestPageRefOrder = oExtControllerOrder.orderConfirmationSubmit();
        	
        	//Retrieve updated seed unit order
        	oSeedUnitOrder = [select Id, Opportunity__c, Name, Date_Time_Submitted_To_Oracle__c from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];
        	
        	ApexPages.StandardController oStdControllerSummary = new ApexPages.StandardController(oSeedUnitOrder);
			Seed_Unit_Order_Summary_Controller oExtControllerSummary = new Seed_Unit_Order_Summary_Controller(oStdControllerSummary);
        	
        	//Assert statment for getFormattedSubmissionDate method
        	system.assertEquals(oSeedUnitOrder.Date_Time_Submitted_To_Oracle__c.format(),oExtControllerSummary.getFormattedSubmissionDate());   
        Test.stopTest();       
    }
}