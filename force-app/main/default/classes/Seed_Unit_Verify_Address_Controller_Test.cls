/*
    Test class for Seed_Unit_Verify_Address_Controller.cls

    MOD DATE        Who                     Description
    10/23/2014      Chris Noe               Initial Release
*/
@isTest
private class Seed_Unit_Verify_Address_Controller_Test {
	
	static testMethod void selectVerifiedAddressZipPlus4() {
        //Test method to provide testing and code coverage for selecting a verified address.

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
        //Create SmartyStreets_API__c record for testing
        SmartyStreets_API__c oSSAPI = new SmartyStreets_API__c();
        oSSAPI.Name='SeedUnitAddressVerify';
        oSSAPI.auth_id__c=String.valueOf(math.random()).left(20);
        oSSAPI.auth_token__c=String.valueOf(math.random()).left(20);
        insert oSSAPI;

        //Update address fields on seed unit order
        oSeedUnitOrder.Ship_To_Address1__c = '815 Connecticut Avenue Northwest';
        oSeedUnitOrder.Ship_To_Address2__c = 'Suite 900';
        oSeedUnitOrder.Ship_To_City__c = 'Washington';
        oSeedUnitOrder.Ship_To_State_Province__c = 'District of Columbia-DC';
        oSeedUnitOrder.Ship_To_Postal_Code__c = '20006';
        oSeedUnitOrder.Ship_To_Country__c = 'United States-US';
        update oSeedUnitOrder;

        Test.startTest();
            SingleHTTPRequestMock_Test oFakeResponseTrigger = new SingleHTTPRequestMock_Test(200,
                                                            'Complete',
                                                            '['+
               	'  {'+
               	'    \"input_id\": \"' + oSeedUnitOrder.Id + '\",'+
               	'    \"input_index\": 0,'+
               	'    \"candidate_index\": 0,'+
               	'    \"addressee\": \"TESTING\",'+
               	'    \"delivery_line_1\": \"815 Connecticut Ave NW Ste 900\",'+
               	'    \"delivery_line_2\": \"5th FLOOR\",'+
               	'    \"last_line\": \"Washington DC 20006-4004\",'+
               	'    \"delivery_point_barcode\": \"200064004996\",'+
               	'    \"components\": {'+
               	'      \"urbanization\": \"NONE\",'+
               	'      \"primary_number\": \"815\",'+
               	'      \"street_name\": \"Connecticut\",'+
               	'      \"street_predirection\": \"S\",'+
               	'      \"street_postdirection\": \"NW\",'+
               	'      \"street_suffix\": \"Ave\",'+
               	'      \"secondary_number\": \"900\",'+
               	'      \"secondary_designator\": \"Ste\",'+
               	'      \"extra_secondary_number\": \"5th\",'+
               	'      \"extra_secondary_designator\": \"Fl\",'+
               	'      \"pmb_designator\": \"N\",'+
               	'      \"pmb_number\": \"1\",'+
               	'      \"city_name\": \"Washington\",'+
               	'      \"default_city_name\": \"Washington\",'+
               	'      \"state_abbreviation\": \"DC\",'+
               	'      \"zipcode\": \"20006\",'+
               	'      \"plus4_code\": \"4004\",'+
               	'      \"delivery_point\": \"99\",'+
               	'      \"delivery_point_check_digit\": \"6\"'+
               	'    },'+
               	'    \"metadata\": {'+
               	'      \"record_type\": \"H\",'+
               	'      \"zip_type\": \"Standard\",'+
               	'      \"county_fips\": \"11001\",'+
               	'      \"county_name\": \"District of Columbia\",'+
               	'      \"carrier_route\": \"C086\",'+
               	'      \"congressional_district\": \"AL\",'+
               	'      \"building_default_indicator\": \"Y\",'+
               	'      \"rdi\": \"Commercial\",'+
               	'      \"elot_sequence\": \"0203\",'+
               	'      \"elot_sort\": \"A\",'+
               	'      \"latitude\": 38.90098,'+
               	'      \"longitude\": -77.03794,'+
               	'      \"precision\": \"Zip9\",'+
               	'      \"time_zone\": \"Eastern\",'+
               	'      \"utc_offset\": -5,'+
               	'      \"dst\": true'+
               	'    },'+
               	'    \"analysis\": {'+
               	'      \"dpv_match_code\": \"S\",'+
               	'      \"dpv_footnotes\": \"AACC\",'+
               	'      \"dpv_cmra\": \"N\",'+
               	'      \"dpv_vacant\": \"N\",'+
               	'      \"active\": \"Y\",'+
               	'      \"ews_match\": \"Y\",'+
               	'      \"footnotes\": \"N#S#\",'+
               	'      \"lacslink_code\": \"lacscode\",'+
               	'      \"lacslink_indicator\": \"Y\",'+
               	'      \"suitelink_match\": \"Y\"'+
               	'    }'+
               	'  }'+
               	']'
                 , null);
            Test.setMock(HttpCalloutMock.class, oFakeResponseTrigger);
            
            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            Seed_Unit_Verify_Address_Controller oExtController = new Seed_Unit_Verify_Address_Controller(oStdController);

            //Assert display verified address
            system.assertEquals(true,oExtController.bDisplayVerifiedAddress);

            //Set the index for the selected address
            PageReference oPageRef = Page.SeedUnitVerifyAddress;
            oPageRef.getParameters().put('addressIndex','0');
            Test.setCurrentPage(oPageRef);

            //Address index has been selected in lines above, call the updateAddress on controller
            oPageRef = oExtController.updateAddress();

            //Assert updated address values on the seed unit order
            oSeedUnitOrder = [select Id, Ship_To_Address1__c, Ship_To_Address2__c, Ship_To_City__c, Ship_To_State_Province__c, Ship_To_Postal_Code__c, Ship_To_County__c 
            					from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];

            system.assertEquals('815 S CONNECTICUT AVE NW',oSeedUnitOrder.Ship_To_Address1__c);
            system.assertEquals('STE 900',oSeedUnitOrder.Ship_To_Address2__c);
            system.assertEquals('WASHINGTON',oSeedUnitOrder.Ship_To_City__c);
            system.assertEquals('District of Columbia-DC',oSeedUnitOrder.Ship_To_State_Province__c);
            system.assertEquals('20006-4004',oSeedUnitOrder.Ship_To_Postal_Code__c);
            system.assertEquals('DISTRICT OF COLUMBIA',oSeedUnitOrder.Ship_To_County__c);
        Test.stopTest();
	}	

	static testMethod void selectVerifiedAddressNoZipPlus4() {
        //Test method to provide testing and code coverage for selecting a verified address.

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
        //Create SmartyStreets_API__c record for testing
        SmartyStreets_API__c oSSAPI = new SmartyStreets_API__c();
        oSSAPI.Name='SeedUnitAddressVerify';
        oSSAPI.auth_id__c=String.valueOf(math.random()).left(20);
        oSSAPI.auth_token__c=String.valueOf(math.random()).left(20);
        insert oSSAPI;

        //Update address fields on seed unit order
        oSeedUnitOrder.Ship_To_Address1__c = '815 Connecticut Avenue Northwest';
        oSeedUnitOrder.Ship_To_Address2__c = 'Suite 900';
        oSeedUnitOrder.Ship_To_City__c = 'Washington';
        oSeedUnitOrder.Ship_To_State_Province__c = 'District of Columbia-DC';
        oSeedUnitOrder.Ship_To_Postal_Code__c = '20006';
        oSeedUnitOrder.Ship_To_Country__c = 'United States-US';
        update oSeedUnitOrder;

        Test.startTest();
            SingleHTTPRequestMock_Test oFakeResponseTrigger = new SingleHTTPRequestMock_Test(200,
                                                            'Complete',
                                                            '['+
               	'  {'+
               	'    \"input_id\": \"' + oSeedUnitOrder.Id + '\",'+
               	'    \"input_index\": 0,'+
               	'    \"candidate_index\": 0,'+
               	'    \"addressee\": \"TESTING\",'+
               	'    \"delivery_line_1\": \"815 Connecticut Ave NW Ste 900\",'+
               	'    \"delivery_line_2\": \"5th FLOOR\",'+
               	'    \"last_line\": \"Washington DC 20006\",'+
               	'    \"delivery_point_barcode\": \"200064004996\",'+
               	'    \"components\": {'+
               	'      \"urbanization\": \"NONE\",'+
               	'      \"primary_number\": \"815\",'+
               	'      \"street_name\": \"Connecticut\",'+
               	'      \"street_predirection\": \"S\",'+
               	'      \"street_postdirection\": \"NW\",'+
               	'      \"street_suffix\": \"Ave\",'+
               	'      \"secondary_number\": \"900\",'+
               	'      \"secondary_designator\": \"Ste\",'+
               	'      \"extra_secondary_number\": \"5th\",'+
               	'      \"extra_secondary_designator\": \"Fl\",'+
               	'      \"pmb_designator\": \"N\",'+
               	'      \"pmb_number\": \"1\",'+
               	'      \"city_name\": \"Washington\",'+
               	'      \"default_city_name\": \"Washington\",'+
               	'      \"state_abbreviation\": \"DC\",'+
               	'      \"zipcode\": \"20006\",'+
               	'      \"plus4_code\": \"\",'+
               	'      \"delivery_point\": \"99\",'+
               	'      \"delivery_point_check_digit\": \"6\"'+
               	'    },'+
               	'    \"metadata\": {'+
               	'      \"record_type\": \"H\",'+
               	'      \"zip_type\": \"Standard\",'+
               	'      \"county_fips\": \"11001\",'+
               	'      \"county_name\": \"District of Columbia\",'+
               	'      \"carrier_route\": \"C086\",'+
               	'      \"congressional_district\": \"AL\",'+
               	'      \"building_default_indicator\": \"Y\",'+
               	'      \"rdi\": \"Commercial\",'+
               	'      \"elot_sequence\": \"0203\",'+
               	'      \"elot_sort\": \"A\",'+
               	'      \"latitude\": 38.90098,'+
               	'      \"longitude\": -77.03794,'+
               	'      \"precision\": \"Zip9\",'+
               	'      \"time_zone\": \"Eastern\",'+
               	'      \"utc_offset\": -5,'+
               	'      \"dst\": true'+
               	'    },'+
               	'    \"analysis\": {'+
               	'      \"dpv_match_code\": \"S\",'+
               	'      \"dpv_footnotes\": \"AACC\",'+
               	'      \"dpv_cmra\": \"N\",'+
               	'      \"dpv_vacant\": \"N\",'+
               	'      \"active\": \"Y\",'+
               	'      \"ews_match\": \"Y\",'+
               	'      \"footnotes\": \"N#S#\",'+
               	'      \"lacslink_code\": \"lacscode\",'+
               	'      \"lacslink_indicator\": \"Y\",'+
               	'      \"suitelink_match\": \"Y\"'+
               	'    }'+
               	'  }'+
               	']'
                 , null);
            Test.setMock(HttpCalloutMock.class, oFakeResponseTrigger);
            
            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            Seed_Unit_Verify_Address_Controller oExtController = new Seed_Unit_Verify_Address_Controller(oStdController);

            //Assert display verified address
            system.assertEquals(true,oExtController.bDisplayVerifiedAddress);

            //Set the index for the selected address
            PageReference oPageRef = Page.SeedUnitVerifyAddress;
            oPageRef.getParameters().put('addressIndex','0');
            Test.setCurrentPage(oPageRef);

            //Address index has been selected in lines above, call the updateAddress on controller
            oPageRef = oExtController.updateAddress();

            //Assert updated address values on the seed unit order
            oSeedUnitOrder = [select Id, Ship_To_Address1__c, Ship_To_Address2__c, Ship_To_City__c, Ship_To_State_Province__c, Ship_To_Postal_Code__c, Ship_To_County__c 
            					from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];

            system.assertEquals('815 S CONNECTICUT AVE NW',oSeedUnitOrder.Ship_To_Address1__c);
            system.assertEquals('STE 900',oSeedUnitOrder.Ship_To_Address2__c);
            system.assertEquals('WASHINGTON',oSeedUnitOrder.Ship_To_City__c);
            system.assertEquals('District of Columbia-DC',oSeedUnitOrder.Ship_To_State_Province__c);
            system.assertEquals('20006',oSeedUnitOrder.Ship_To_Postal_Code__c);
            system.assertEquals('DISTRICT OF COLUMBIA',oSeedUnitOrder.Ship_To_County__c);
        Test.stopTest();
	}

	static testMethod void verifySelectEdit() {
        //Test method to provide testing and code coverage for selecting Change on verify address page.

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
        //Create SmartyStreets_API__c record for testing
        SmartyStreets_API__c oSSAPI = new SmartyStreets_API__c();
        oSSAPI.Name='SeedUnitAddressVerify';
        oSSAPI.auth_id__c=String.valueOf(math.random()).left(20);
        oSSAPI.auth_token__c=String.valueOf(math.random()).left(20);
        insert oSSAPI;

        //Update address fields on seed unit order
        oSeedUnitOrder.Ship_To_Address1__c = '815 Connecticut Avenue Northwest';
        oSeedUnitOrder.Ship_To_Address2__c = 'Suite 900';
        oSeedUnitOrder.Ship_To_City__c = 'Washington';
        oSeedUnitOrder.Ship_To_State_Province__c = 'District of Columbia-DC';
        oSeedUnitOrder.Ship_To_Postal_Code__c = '20006';
        oSeedUnitOrder.Ship_To_Country__c = 'United States-US';
        update oSeedUnitOrder;

        Test.startTest();
            SingleHTTPRequestMock_Test oFakeResponseTrigger = new SingleHTTPRequestMock_Test(200,
                                                            'Complete',
                                                            '['+
               	'  {'+
               	'    \"input_id\": \"' + oSeedUnitOrder.Id + '\",'+
               	'    \"input_index\": 0,'+
               	'    \"candidate_index\": 0,'+
               	'    \"addressee\": \"TESTING\",'+
               	'    \"delivery_line_1\": \"815 Connecticut Ave NW Ste 900\",'+
               	'    \"delivery_line_2\": \"5th FLOOR\",'+
               	'    \"last_line\": \"Washington DC 20006\",'+
               	'    \"delivery_point_barcode\": \"200064004996\",'+
               	'    \"components\": {'+
               	'      \"urbanization\": \"NONE\",'+
               	'      \"primary_number\": \"815\",'+
               	'      \"street_name\": \"Connecticut\",'+
               	'      \"street_predirection\": \"S\",'+
               	'      \"street_postdirection\": \"NW\",'+
               	'      \"street_suffix\": \"Ave\",'+
               	'      \"secondary_number\": \"900\",'+
               	'      \"secondary_designator\": \"Ste\",'+
               	'      \"extra_secondary_number\": \"5th\",'+
               	'      \"extra_secondary_designator\": \"Fl\",'+
               	'      \"pmb_designator\": \"N\",'+
               	'      \"pmb_number\": \"1\",'+
               	'      \"city_name\": \"Washington\",'+
               	'      \"default_city_name\": \"Washington\",'+
               	'      \"state_abbreviation\": \"DC\",'+
               	'      \"zipcode\": \"20006\",'+
               	'      \"plus4_code\": \"\",'+
               	'      \"delivery_point\": \"99\",'+
               	'      \"delivery_point_check_digit\": \"6\"'+
               	'    },'+
               	'    \"metadata\": {'+
               	'      \"record_type\": \"H\",'+
               	'      \"zip_type\": \"Standard\",'+
               	'      \"county_fips\": \"11001\",'+
               	'      \"county_name\": \"District of Columbia\",'+
               	'      \"carrier_route\": \"C086\",'+
               	'      \"congressional_district\": \"AL\",'+
               	'      \"building_default_indicator\": \"Y\",'+
               	'      \"rdi\": \"Commercial\",'+
               	'      \"elot_sequence\": \"0203\",'+
               	'      \"elot_sort\": \"A\",'+
               	'      \"latitude\": 38.90098,'+
               	'      \"longitude\": -77.03794,'+
               	'      \"precision\": \"Zip9\",'+
               	'      \"time_zone\": \"Eastern\",'+
               	'      \"utc_offset\": -5,'+
               	'      \"dst\": true'+
               	'    },'+
               	'    \"analysis\": {'+
               	'      \"dpv_match_code\": \"S\",'+
               	'      \"dpv_footnotes\": \"AACC\",'+
               	'      \"dpv_cmra\": \"N\",'+
               	'      \"dpv_vacant\": \"N\",'+
               	'      \"active\": \"Y\",'+
               	'      \"ews_match\": \"Y\",'+
               	'      \"footnotes\": \"N#S#\",'+
               	'      \"lacslink_code\": \"lacscode\",'+
               	'      \"lacslink_indicator\": \"Y\",'+
               	'      \"suitelink_match\": \"Y\"'+
               	'    }'+
               	'  }'+
               	']'
                 , null);
            Test.setMock(HttpCalloutMock.class, oFakeResponseTrigger);
            
            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            Seed_Unit_Verify_Address_Controller oExtController = new Seed_Unit_Verify_Address_Controller(oStdController);

            //Assert display verified address
            system.assertEquals(true,oExtController.bDisplayVerifiedAddress);

            //User selects "Change" from the address verification screen.  Assert that SeedUnitSelectShipTo page is returned
            system.assertEquals('/apex/seedunitselectshipto?id='+oSeedUnitOrder.Id,oExtController.editShipTo().getURL());
        Test.stopTest();
	}

	static testMethod void verifySelectCancel() {
        //Test method to provide testing and code coverage for selecting Cancel on verify address page.

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
        //Create SmartyStreets_API__c record for testing
        SmartyStreets_API__c oSSAPI = new SmartyStreets_API__c();
        oSSAPI.Name='SeedUnitAddressVerify';
        oSSAPI.auth_id__c=String.valueOf(math.random()).left(20);
        oSSAPI.auth_token__c=String.valueOf(math.random()).left(20);
        insert oSSAPI;

        //Update address fields on seed unit order
        oSeedUnitOrder.Ship_To_Address1__c = '815 Connecticut Avenue Northwest';
        oSeedUnitOrder.Ship_To_Address2__c = 'Suite 900';
        oSeedUnitOrder.Ship_To_City__c = 'Washington';
        oSeedUnitOrder.Ship_To_State_Province__c = 'District of Columbia-DC';
        oSeedUnitOrder.Ship_To_Postal_Code__c = '20006';
        oSeedUnitOrder.Ship_To_Country__c = 'United States-US';
        update oSeedUnitOrder;

        Test.startTest();
            SingleHTTPRequestMock_Test oFakeResponseTrigger = new SingleHTTPRequestMock_Test(200,
                                                            'Complete',
                                                            '['+
               	'  {'+
               	'    \"input_id\": \"' + oSeedUnitOrder.Id + '\",'+
               	'    \"input_index\": 0,'+
               	'    \"candidate_index\": 0,'+
               	'    \"addressee\": \"TESTING\",'+
               	'    \"delivery_line_1\": \"815 Connecticut Ave NW Ste 900\",'+
               	'    \"delivery_line_2\": \"5th FLOOR\",'+
               	'    \"last_line\": \"Washington DC 20006\",'+
               	'    \"delivery_point_barcode\": \"200064004996\",'+
               	'    \"components\": {'+
               	'      \"urbanization\": \"NONE\",'+
               	'      \"primary_number\": \"815\",'+
               	'      \"street_name\": \"Connecticut\",'+
               	'      \"street_predirection\": \"S\",'+
               	'      \"street_postdirection\": \"NW\",'+
               	'      \"street_suffix\": \"Ave\",'+
               	'      \"secondary_number\": \"900\",'+
               	'      \"secondary_designator\": \"Ste\",'+
               	'      \"extra_secondary_number\": \"5th\",'+
               	'      \"extra_secondary_designator\": \"Fl\",'+
               	'      \"pmb_designator\": \"N\",'+
               	'      \"pmb_number\": \"1\",'+
               	'      \"city_name\": \"Washington\",'+
               	'      \"default_city_name\": \"Washington\",'+
               	'      \"state_abbreviation\": \"DC\",'+
               	'      \"zipcode\": \"20006\",'+
               	'      \"plus4_code\": \"\",'+
               	'      \"delivery_point\": \"99\",'+
               	'      \"delivery_point_check_digit\": \"6\"'+
               	'    },'+
               	'    \"metadata\": {'+
               	'      \"record_type\": \"H\",'+
               	'      \"zip_type\": \"Standard\",'+
               	'      \"county_fips\": \"11001\",'+
               	'      \"county_name\": \"District of Columbia\",'+
               	'      \"carrier_route\": \"C086\",'+
               	'      \"congressional_district\": \"AL\",'+
               	'      \"building_default_indicator\": \"Y\",'+
               	'      \"rdi\": \"Commercial\",'+
               	'      \"elot_sequence\": \"0203\",'+
               	'      \"elot_sort\": \"A\",'+
               	'      \"latitude\": 38.90098,'+
               	'      \"longitude\": -77.03794,'+
               	'      \"precision\": \"Zip9\",'+
               	'      \"time_zone\": \"Eastern\",'+
               	'      \"utc_offset\": -5,'+
               	'      \"dst\": true'+
               	'    },'+
               	'    \"analysis\": {'+
               	'      \"dpv_match_code\": \"S\",'+
               	'      \"dpv_footnotes\": \"AACC\",'+
               	'      \"dpv_cmra\": \"N\",'+
               	'      \"dpv_vacant\": \"N\",'+
               	'      \"active\": \"Y\",'+
               	'      \"ews_match\": \"Y\",'+
               	'      \"footnotes\": \"N#S#\",'+
               	'      \"lacslink_code\": \"lacscode\",'+
               	'      \"lacslink_indicator\": \"Y\",'+
               	'      \"suitelink_match\": \"Y\"'+
               	'    }'+
               	'  }'+
               	']'
                 , null);
            Test.setMock(HttpCalloutMock.class, oFakeResponseTrigger);
            
            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            Seed_Unit_Verify_Address_Controller oExtController = new Seed_Unit_Verify_Address_Controller(oStdController);

            //Assert display verified address
            system.assertEquals(true,oExtController.bDisplayVerifiedAddress);

            //User selects "Cancel" from the address verification screen.  Assert that Seed Unit Order standard view page is returned
            system.assertEquals('/'+oSeedUnitOrder.Id,oExtController.verifyCancel().getURL());

            //Retrieve seed unit order and verify that the address details have been cleared out
            oSeedUnitOrder = [select Ship_To_Address1__c, Ship_To_Address2__c, Ship_To_Address3__c, Ship_To_Address4__c, Ship_To_City__c, Ship_To_State_Province__c, Ship_To_Postal_Code__c,
            					SmartyStreets_Response__c from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];

            system.assertEquals(NULL,oSeedUnitOrder.Ship_To_Address1__c);
            system.assertEquals(NULL,oSeedUnitOrder.Ship_To_Address2__c);
            system.assertEquals(NULL,oSeedUnitOrder.Ship_To_Address3__c);
            system.assertEquals(NULL,oSeedUnitOrder.Ship_To_Address4__c);
            system.assertEquals(NULL,oSeedUnitOrder.Ship_To_City__c);
            system.assertEquals(NULL,oSeedUnitOrder.Ship_To_State_Province__c);
            system.assertEquals(NULL,oSeedUnitOrder.Ship_To_Postal_Code__c);
            system.assertEquals(NULL,oSeedUnitOrder.SmartyStreets_Response__c);
        Test.stopTest();
	}

	static testMethod void verifyWebServiceCalloutException() {
        //Test method to provide testing and code coverage for web service callout exception.

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
        //Create SmartyStreets_API__c record for testing
        SmartyStreets_API__c oSSAPI = new SmartyStreets_API__c();
        oSSAPI.Name='SeedUnitAddressVerify';
        oSSAPI.auth_id__c=String.valueOf(math.random()).left(20);
        oSSAPI.auth_token__c=String.valueOf(math.random()).left(20);
        insert oSSAPI;

        //Update address fields on seed unit order
        oSeedUnitOrder.Ship_To_Address1__c = '815 Connecticut Avenue Northwest';
        oSeedUnitOrder.Ship_To_Address2__c = 'Suite 900';
        oSeedUnitOrder.Ship_To_City__c = 'Washington';
        oSeedUnitOrder.Ship_To_State_Province__c = 'District of Columbia-DC';
        oSeedUnitOrder.Ship_To_Postal_Code__c = '20006';
        oSeedUnitOrder.Ship_To_Country__c = 'United States-US';
        update oSeedUnitOrder;

        Test.startTest();
            SingleHTTPRequestMock_Test oFakeResponseTrigger = new SingleHTTPRequestMock_Test(200,
                                                            'Complete',
                                                            '['+
               	'  //{'+
               	'    \"input_id\": \"' + oSeedUnitOrder.Id + '\",'+
               	'    \"input_index\": 0,'+
               	'    \"candidate_index\": 0,'+
               	'    \"addressee\": \"TESTING\",'+
               	'    \"delivery_line_1\": \"815 Connecticut Ave NW Ste 900\",'+
               	'    \"delivery_line_2\": \"5th FLOOR\",'+
               	'    \"last_line\": \"Washington DC 20006\",'+
               	'    \"delivery_point_barcode\": \"200064004996\",'+
               	'    \"components\": {'+
               	'      \"urbanization\": \"NONE\",'+
               	'      \"primary_number\": \"815\",'+
               	'      \"street_name\": \"Connecticut\",'+
               	'      \"street_predirection\": \"S\",'+
               	'      \"street_postdirection\": \"NW\",'+
               	'      \"street_suffix\": \"Ave\",'+
               	'      \"secondary_number\": \"900\",'+
               	'      \"secondary_designator\": \"Ste\",'+
               	'      \"extra_secondary_number\": \"5th\",'+
               	'      \"extra_secondary_designator\": \"Fl\",'+
               	'      \"pmb_designator\": \"N\",'+
               	'      \"pmb_number\": \"1\",'+
               	'      \"city_name\": \"Washington\",'+
               	'      \"default_city_name\": \"Washington\",'+
               	'      \"state_abbreviation\": \"DC\",'+
               	'      \"zipcode\": \"20006\",'+
               	'      \"plus4_code\": \"\",'+
               	'      \"delivery_point\": \"99\",'+
               	'      \"delivery_point_check_digit\": \"6\"'+
               	'    },'+
               	'    \"metadata\": {'+
               	'      \"record_type\": \"H\",'+
               	'      \"zip_type\": \"Standard\",'+
               	'      \"county_fips\": \"11001\",'+
               	'      \"county_name\": \"District of Columbia\",'+
               	'      \"carrier_route\": \"C086\",'+
               	'      \"congressional_district\": \"AL\",'+
               	'      \"building_default_indicator\": \"Y\",'+
               	'      \"rdi\": \"Commercial\",'+
               	'      \"elot_sequence\": \"0203\",'+
               	'      \"elot_sort\": \"A\",'+
               	'      \"latitude\": 38.90098,'+
               	'      \"longitude\": -77.03794,'+
               	'      \"precision\": \"Zip9\",'+
               	'      \"time_zone\": \"Eastern\",'+
               	'      \"utc_offset\": -5,'+
               	'      \"dst\": true'+
               	'    },'+
               	'    \"analysis\": {'+
               	'      \"dpv_match_code\": \"S\",'+
               	'      \"dpv_footnotes\": \"AACC\",'+
               	'      \"dpv_cmra\": \"N\",'+
               	'      \"dpv_vacant\": \"N\",'+
               	'      \"active\": \"Y\",'+
               	'      \"ews_match\": \"Y\",'+
               	'      \"footnotes\": \"N#S#\",'+
               	'      \"lacslink_code\": \"lacscode\",'+
               	'      \"lacslink_indicator\": \"Y\",'+
               	'      \"suitelink_match\": \"Y\"'+
               	'    }'+
               	'  }'+
               	']'
                 , null);
            Test.setMock(HttpCalloutMock.class, oFakeResponseTrigger);
            
            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            Seed_Unit_Verify_Address_Controller oExtController = new Seed_Unit_Verify_Address_Controller(oStdController);

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

	static testMethod void verifyWebServiceStatusException() {
        //Test method to provide testing and code coverage for web service status exception

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
        //Create SmartyStreets_API__c record for testing
        SmartyStreets_API__c oSSAPI = new SmartyStreets_API__c();
        oSSAPI.Name='SeedUnitAddressVerify';
        oSSAPI.auth_id__c=String.valueOf(math.random()).left(20);
        oSSAPI.auth_token__c=String.valueOf(math.random()).left(20);
        insert oSSAPI;

        //Update address fields on seed unit order
        oSeedUnitOrder.Ship_To_Address1__c = '815 Connecticut Avenue Northwest';
        oSeedUnitOrder.Ship_To_Address2__c = 'Suite 900';
        oSeedUnitOrder.Ship_To_City__c = 'Washington';
        oSeedUnitOrder.Ship_To_State_Province__c = 'District of Columbia-DC';
        oSeedUnitOrder.Ship_To_Postal_Code__c = '20006';
        oSeedUnitOrder.Ship_To_Country__c = 'United States-US';
        update oSeedUnitOrder;

        Test.startTest();
            SingleHTTPRequestMock_Test oFakeResponseTrigger = new SingleHTTPRequestMock_Test(404,
                                                            'BAD',
                                                            '[]', null);
            Test.setMock(HttpCalloutMock.class, oFakeResponseTrigger);
            
            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            Seed_Unit_Verify_Address_Controller oExtController = new Seed_Unit_Verify_Address_Controller(oStdController);

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

	static testMethod void testResponseClass() {
		//Coverage for all variables in the SmartyStreets_Validation_Reponse.cls.  Since we don't use all the fields in our current logic, they are not all covered 
		//in the test methods above.  This method provides covereage for all fields in this class.

		SmartyStreets_Validation_Response oResponse = new SmartyStreets_Validation_Response();
		SmartyStreets_Validation_Response.Analysis oResponseAnalysis = new SmartyStreets_Validation_Response.Analysis();
		SmartyStreets_Validation_Response.Components oResponseComponents = new SmartyStreets_Validation_Response.Components();
		SmartyStreets_Validation_Response.Metadata oResponseMetadata = new SmartyStreets_Validation_Response.Metadata();
		
		oResponseAnalysis.dpv_match_code='test';
		oResponseAnalysis.dpv_footnotes='test';
		oResponseAnalysis.dpv_cmra='test';
		oResponseAnalysis.dpv_vacant='test';
		oResponseAnalysis.active='test';
		oResponseAnalysis.ews_match='test';
		oResponseAnalysis.footnotes='test';
		oResponseAnalysis.lacslink_code='test';
		oResponseAnalysis.lacslink_indicator='test';
		oResponseAnalysis.suitelink_match='test';
		oResponse.input_id='test';
		oResponse.input_index=0;
		oResponse.candidate_index=0;
		oResponse.addressee='test';
		oResponse.delivery_line_1='test';
		oResponse.delivery_line_2='test';
		oResponse.last_line='test';
		oResponse.delivery_point_barcode='test';
		oResponse.sFormattedAddress1='test';
		oResponse.sFormattedAddress2='test';
		oResponse.sFormattedCityStateZip='test';
		oResponseComponents.urbanization='test';
		oResponseComponents.primary_number='test';
		oResponseComponents.street_name='test';
		oResponseComponents.street_predirection='test';
		oResponseComponents.street_postdirection='test';
		oResponseComponents.street_suffix='test';
		oResponseComponents.secondary_number='test';
		oResponseComponents.secondary_designator='test';
		oResponseComponents.extra_secondary_number='test';
		oResponseComponents.extra_secondary_designator='test';
		oResponseComponents.pmb_designator='test';
		oResponseComponents.pmb_number='test';
		oResponseComponents.city_name='test';
		oResponseComponents.default_city_name='test';
		oResponseComponents.state_abbreviation='test';
		oResponseComponents.zipcode='test';
		oResponseComponents.plus4_code='test';
		oResponseComponents.delivery_point='test';
		oResponseComponents.delivery_point_check_digit='test';
		oResponseMetadata.record_type='test';
		oResponseMetadata.zip_type='test';
		oResponseMetadata.county_fips='test';
		oResponseMetadata.county_name='test';
		oResponseMetadata.carrier_route='test';
		oResponseMetadata.congressional_district='test';
		oResponseMetadata.building_default_indicator='test';
		oResponseMetadata.rdi='test';
		oResponseMetadata.elot_sequence='test';
		oResponseMetadata.elot_sort='test';
		oResponseMetadata.latitude=100;
		oResponseMetadata.longitude=200;
		oResponseMetadata.precision='test';
		oResponseMetadata.time_zone='test';
		oResponseMetadata.utc_offset=1;
		oResponseMetadata.dst='test';
	}

    static testMethod void verifySelectUseThisAddress() {
        //Test method to provide testing and code coverage for selecting "Use This Address" on verify address page.

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
        //Create SmartyStreets_API__c record for testing
        SmartyStreets_API__c oSSAPI = new SmartyStreets_API__c();
        oSSAPI.Name='SeedUnitAddressVerify';
        oSSAPI.auth_id__c=String.valueOf(math.random()).left(20);
        oSSAPI.auth_token__c=String.valueOf(math.random()).left(20);
        insert oSSAPI;

        //Update address fields on seed unit order
        oSeedUnitOrder.Ship_To_Address1__c = '815 Connecticut Avenue Northwest';
        oSeedUnitOrder.Ship_To_Address2__c = 'Suite 900';
        oSeedUnitOrder.Ship_To_City__c = 'Washington';
        oSeedUnitOrder.Ship_To_State_Province__c = 'District of Columbia-DC';
        oSeedUnitOrder.Ship_To_Postal_Code__c = '20006';
        oSeedUnitOrder.Ship_To_Country__c = 'United States-US';
        update oSeedUnitOrder;

        Test.startTest();
            SingleHTTPRequestMock_Test oFakeResponseTrigger = new SingleHTTPRequestMock_Test(200,
                                                            'Complete',
                                                            '['+
                ']'
                 , null);
            Test.setMock(HttpCalloutMock.class, oFakeResponseTrigger);
            
            //Invoke the standard and extension controllers with seed unit order created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oSeedUnitOrder);
            Seed_Unit_Verify_Address_Controller oExtController = new Seed_Unit_Verify_Address_Controller(oStdController);

            //Assert display verified address
            system.assertEquals(false,oExtController.bDisplayVerifiedAddress);

            //User selects "Use This Address" from the address verification screen.  Assert that Seed Unit Order standard view page is returned
            system.assertEquals('/'+oSeedUnitOrder.Id,oExtController.useAddressEntered().getURL());

            //Retrieve seed unit order and assert fields
            oSeedUnitOrder = [select SmartyStreets_Response__c, Do_Not_Validate_Address__c from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];

            system.assertEquals(NULL,oSeedUnitOrder.SmartyStreets_Response__c);
            system.assertEquals(true,oSeedUnitOrder.Do_Not_Validate_Address__c);
        Test.stopTest();
    }	
}