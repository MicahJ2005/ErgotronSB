/*
    Test class for Int_Project_Select_Location_Cntrl.cls

    MOD DATE        Who                     Description
    07/20/2015      Chris Noe               Initial Release

*/
@isTest
private class Int_Project_Select_Location_Cntrl_Test {
    //Test data setup method
    @testSetup
    static void testDataSetup() {
    	//Create Accounts for testing
    	Account oAccountEndUser = Test_Environment_Utility.createInsertAccountUS();
    	Account oAccountReseller = Test_Environment_Utility.createInsertAccountUS();
    	Account oAccountDistributor = Test_Environment_Utility.createInsertAccountUS();

    	//Create Contact for testing
    	Contact oContact = Test_Environment_Utility.createInsertContact(oAccountEndUser);

    	//Create Customer_Account__c for testing
    	//Customer_Account__c oCustomerAccount = Test_Environment_Utility.createInsertCustomerAccount(oAccountEndUser);

    	//Create Product for testing
    	Product2 oProduct = Test_Environment_Utility.createInsertProduct();
    	oProduct.Item_Type__c='E-SERVICE';
    	update oProduct;

    	//Create Integration_Project__c for testing
    	Integration_Project__c oIntProject = Test_Environment_Utility.createInsertIntegrationProject('TEST', oAccountEndUser, oAccountDistributor, oAccountReseller, oProduct, oContact);

    	//Create web service details for testing
        Web_Service_Details__c oWebServiceDetail = Test_Environment_Utility.createInsertWebServiceDetails('Ship To Site Use Lookup');
    }

    static testMethod void shipToSelect() {
		
		//Retrieve the Integration_Project__c record.
		Integration_Project__c oIntProject = [select Id, End_User_Customer__c from Integration_Project__c limit 1];

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
	        PageReference oPageRef = Page.IntProjectSelectLocation;
	        Test.setCurrentPage(oPageRef); 
	        
	        //Invoke the standard and extension controllers with Integration_Project__c record retrieved above
	        ApexPages.StandardController oStdController = new ApexPages.StandardController(oIntProject);
	        oPageRef.getParameters().put('id',String.valueOf(oIntProject.Id));
	        Int_Project_Select_Location_Cntrl oExtController = new Int_Project_Select_Location_Cntrl(oStdController);

	        //Select location and assert selection and return to view page for this service contract
	        oPageRef.getParameters().put('shipLocId','611088');
	        system.assertEquals('/' + oIntProject.Id,oExtController.shipToSelect().getURL());    

	        //Retrieve Integration_Project__c record and assert address fields
	        oIntProject = [select Project_Address1_Oracle__c,Project_Address2_Oracle__c,Project_Address3_Oracle__c,Project_Address4_Oracle__c,Project_City_State_Zip_Country__c,Project_Org_Id__c
	        				from Integration_Project__c where Id=:oIntProject.Id];
	        system.assertEquals('2109 FOX DR',oIntProject.Project_Address1_Oracle__c);  
	        system.assertEquals('STE 100',oIntProject.Project_Address2_Oracle__c);  
	        system.assertEquals('ROOM 409',oIntProject.Project_Address3_Oracle__c);  
	        system.assertEquals('WEST WING',oIntProject.Project_Address4_Oracle__c);
	        system.assertEquals('CHAMPAIGN,IL, 61820, US',oIntProject.Project_City_State_Zip_Country__c);  
	        system.assertEquals('611088',oIntProject.Project_Org_Id__c);  
        Test.stopTest();     
	}
}