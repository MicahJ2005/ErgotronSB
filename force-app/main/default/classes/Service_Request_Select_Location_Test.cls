/*
    Test class for Service_Request_Select_Location_Cntrl.cls

    MOD DATE        Who                     Description
    07/09/2015      Chris Noe               Initial Release

*/

@isTest
private class Service_Request_Select_Location_Test {
	
    //Test data setup method
    @testSetup
    static void testDataSetup() {
	    //Create Accounts for testing
	    Account oAccount = Test_Environment_Utility.createInsertAccountUS();

	    //Create Contact for testing
	    Contact oContact = Test_Environment_Utility.createInsertContact(oAccount);

	    //Create Customer_Account__c for testing
	    //Customer_Account__c oCustomerAccount = Test_Environment_Utility.createInsertCustomerAccount(oAccount);

	    //Create Case for testing
	    Case oCase = Test_Environment_Utility.createInsertCase(oAccount,oContact,null,null);

	    //Create web service details for testing
        Web_Service_Details__c oWebServiceDetail = Test_Environment_Utility.createInsertWebServiceDetails('Ship To Site Use Lookup');
    }

    static testMethod void shipToSelect() {
		//Retrieve the Case record.
		Case oCase = [select Id, AccountId from Case limit 1];

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
                   '    \"Address2\": \"STE 100\",'+
                   '    \"Address3\": \"ROOM 409\",'+
                   '    \"Address4\": \"WEST WING\",'+
                   '    \"AccountDescription\": \"DOMESTIC\",'+
                   '    \"PartyNumber\": \"303075\"'+
                   '  }'+
                   ']'
                    , null);
               
            Test.setMock(HttpCalloutMock.class, oFakeResponseTrigger); 

            //Set page reference
            PageReference oPageRef = Page.ServiceRequestSelectLocation;
            Test.setCurrentPage(oPageRef); 
       
            //Invoke the standard and extension controllers with Case record retrieved above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oCase);
            oPageRef.getParameters().put('id',String.valueOf(oCase.Id));
            Service_Request_Select_Location_Cntrl oExtController = new Service_Request_Select_Location_Cntrl(oStdController);

            //Select location and assert selection and return to view page for this case
            oPageRef.getParameters().put('shipLocId','611088');
            system.assertEquals('/' + oCase.Id,oExtController.shipToSelect().getURL());
                        
            //Retrieve Case record and assert address fields
            oCase = [select Incident_Address1_Oracle__c,Incident_Address2_Oracle__c,Incident_Address3_Oracle__c,Incident_Address4_Oracle__c,Incident_City_State_Zip_Country__c,Incident_Org_Id__c
                            from Case where Id=:oCase.Id];
            system.assertEquals('2109 FOX DR',oCase.Incident_Address1_Oracle__c);  
            system.assertEquals('STE 100',oCase.Incident_Address2_Oracle__c);  
            system.assertEquals('ROOM 409',oCase.Incident_Address3_Oracle__c);  
            system.assertEquals('WEST WING',oCase.Incident_Address4_Oracle__c);
            system.assertEquals('CHAMPAIGN,IL, 61820, US',oCase.Incident_City_State_Zip_Country__c);  
            system.assertEquals('611088',oCase.Incident_Org_Id__c);  
        Test.stopTest();     
	}
}