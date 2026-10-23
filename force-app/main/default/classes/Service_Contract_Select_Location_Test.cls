/*
    Test class for Service_Contract_Select_Location_Cntrl.cls

    MOD DATE        Who                     Description
    05/11/2015      Chris Noe               Initial Release
	20180517		Andy Boettcher			Sunsetted for Lighting Service Cloud

*/
@isTest
private class Service_Contract_Select_Location_Test {
    ////Test data setup method
    //@testSetup
    //static void testDataSetup() {
    	////Create Accounts for testing
    	//Account oAccountEndUser = Test_Environment_Utility.createInsertAccountUS();
    	//Account oAccountReseller = Test_Environment_Utility.createInsertAccountUS();
    	//Account oAccountDistributor = Test_Environment_Utility.createInsertAccountUS();

    	////Create Contact for testing
    	//Contact oContact = Test_Environment_Utility.createInsertContact(oAccountEndUser);

    	////Create Customer_Account__c for testing
    	////Customer_Account__c oCustomerAccount = Test_Environment_Utility.createInsertCustomerAccount(oAccountEndUser);

    	////Create Product for testing
    	//Product2 oProduct = Test_Environment_Utility.createInsertProduct();
    	//oProduct.Item_Type__c='E-SERVICE';
    	//update oProduct;

    	////Create Service_Contract__c for testing
    	//Service_Contract__c oServiceContract = Test_Environment_Utility.createInsertServiceContract('TEST', oAccountEndUser, oAccountDistributor, oAccountReseller, oProduct, oContact);

    	////Create web service details for testing
        //Web_Service_Details__c oWebServiceDetail = Test_Environment_Utility.createInsertWebServiceDetails('Ship To Site Use Lookup');
    //}

    //static testMethod void shipToSelect() {
		
		////Retrieve the Service_Contract__c record.
		//Service_Contract__c oServiceContract = [select Id, Customer_Name__c from Service_Contract__c limit 1];

		//Test.startTest();
			//SingleHTTPRequestMock_Test oFakeResponseTrigger = new SingleHTTPRequestMock_Test(200,
	                                                            //'Complete',
	                                                            //'['+
	                //'  {'+
	                //'    \"__type\": \"RepLocator.Site\",'+
	                //'    \"SiteUseId\": \"611088\",'+
	                //'    \"LocationName\": \"CHAMPAIGN 2109\",'+
	                //'    \"CustomerName\": \"AMDOCS\",'+
	                //'    \"CustomerNumber\": \"147872\",'+
	                //'    \"Address1\": \"2109 FOX DR\",'+
	                //'    \"CityStateZipCountry\": \"CHAMPAIGN,IL, 61820, US\",'+
	                //'    \"Address2\": \"STE 100\",'+
	                //'    \"Address3\": \"ROOM 409\",'+
	                //'    \"Address4\": \"WEST WING\",'+
	                //'    \"AccountDescription\": \"DOMESTIC\",'+
	                //'    \"PartyNumber\": \"303075\"'+
	                //'  }'+
	                //']'
	                 //, null);
	            
	        //Test.setMock(HttpCalloutMock.class, oFakeResponseTrigger); 

	        ////Set page reference
	        //PageReference oPageRef = Page.ServiceContractSelectLocation;
	        //Test.setCurrentPage(oPageRef); 
	        
	        ////Invoke the standard and extension controllers with Service_Contract__c record retrieved above
	        //ApexPages.StandardController oStdController = new ApexPages.StandardController(oServiceContract);
	        //oPageRef.getParameters().put('id',String.valueOf(oServiceContract.Id));
	        //Service_Contract_Select_Location_Cntrl oExtController = new Service_Contract_Select_Location_Cntrl(oStdController);

	        ////Select location and assert selection and return to view page for this service contract
	        //oPageRef.getParameters().put('shipLocId','611088');
	        //system.assertEquals('/' + oServiceContract.Id,oExtController.shipToSelect().getURL());    
	        
	        ////Retrieve Service_Contract__c record and assert address fields
	        //oServiceContract = [select Ship_To_Address1_Oracle__c,Ship_To_Address2_Oracle__c,Ship_To_Address3_Oracle__c,Ship_To_Address4_Oracle__c,Ship_To_City_State_Zip_Country_Oracle__c,Ship_To_Org_Id__c
	        				//from Service_Contract__c where Id=:oServiceContract.Id];
	        //system.assertEquals('2109 FOX DR',oServiceContract.Ship_To_Address1_Oracle__c);  
	        //system.assertEquals('STE 100',oServiceContract.Ship_To_Address2_Oracle__c);  
	        //system.assertEquals('ROOM 409',oServiceContract.Ship_To_Address3_Oracle__c);  
	        //system.assertEquals('WEST WING',oServiceContract.Ship_To_Address4_Oracle__c);
	        //system.assertEquals('CHAMPAIGN,IL, 61820, US',oServiceContract.Ship_To_City_State_Zip_Country_Oracle__c);  
	        //system.assertEquals('611088',oServiceContract.Ship_To_Org_Id__c);  
        //Test.stopTest();     
	//}
}