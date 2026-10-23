/*
    Test class for Installed_Product_Select_Location_Cntrl.cls

    MOD DATE        Who                     Description
    05/11/2015      Chris Noe               Initial Release

*/
@isTest
private class Installed_Product_Select_Location_Test {
    //Test data setup method
    @testSetup
    static void testDataSetup() {
    	//Create Account for testing
    	Account oAccount = Test_Environment_Utility.createInsertAccountUS();

    	//Create Customer_Account__c for testing
    	//Customer_Account__c oCustomerAccount = Test_Environment_Utility.createInsertCustomerAccount(oAccount);

    	//Create Product for testing
    	Product2 oProduct = Test_Environment_Utility.createInsertProduct();

    	//Create Installed_Product__c for testing
    	Asset oInstalledProduct = Test_Environment_Utility.createInsertInstalledProductOracle('TEST', oAccount, oProduct);

    	//Create web service details for testing
        Web_Service_Details__c oWebServiceDetail = Test_Environment_Utility.createInsertWebServiceDetails('Ship To Site Use Lookup');
    }

	@IsTest
	private static void testController() {

		////Set page reference
	    PageReference oPageRef = Page.InstalledProductSelectLocation;
	    Test.setCurrentPage(oPageRef); 

		Asset oInstalledProduct = [select Id, AccountId from Asset limit 1];

		//Invoke the standard and extension controllers with Installed_Product__c record retrieved above
	    ApexPages.StandardController oStdController = new ApexPages.StandardController(oInstalledProduct);
	    oPageRef.getParameters().put('id',String.valueOf(oInstalledProduct.Id));
	    Installed_Product_Select_Location_Cntrl oExtController = new Installed_Product_Select_Location_Cntrl(oStdController);
	}

    //static testMethod void shipToSelect() {
		
		////Retrieve the Installed_Product__c record.
		//Asset oInstalledProduct = [select Id, AccountId from Asset limit 1];

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
	        //PageReference oPageRef = Page.InstalledProductSelectLocation;
	        //Test.setCurrentPage(oPageRef); 
	        
	        ////Invoke the standard and extension controllers with Installed_Product__c record retrieved above
	        //ApexPages.StandardController oStdController = new ApexPages.StandardController(oInstalledProduct);
	        //oPageRef.getParameters().put('id',String.valueOf(oInstalledProduct.Id));
	        //Installed_Product_Select_Location_Cntrl oExtController = new Installed_Product_Select_Location_Cntrl(oStdController);

	        ////Select location and assert selection and return to view page for this installed product
	        //oPageRef.getParameters().put('shipLocId','611088');
	        //system.assertEquals('/' + oInstalledProduct.Id,oExtController.shipToSelect().getURL()); 

            ////Retrieve Installed_Product__c record and assert address fields
            //oInstalledProduct = [select Ship_To_Address1_Oracle__c,Ship_To_Address2_Oracle__c,Ship_To_Address3_Oracle__c,Ship_To_Address4_Oracle__c,Ship_To_City_State_Zip_Country_Oracle__c,Ship_To_Org_Id__c
                            //from Asset where Id=:oInstalledProduct.Id];
            //system.assertEquals('2109 FOX DR',oInstalledProduct.Ship_To_Address1_Oracle__c);  
            //system.assertEquals('STE 100',oInstalledProduct.Ship_To_Address2_Oracle__c);  
            //system.assertEquals('ROOM 409',oInstalledProduct.Ship_To_Address3_Oracle__c);  
            //system.assertEquals('WEST WING',oInstalledProduct.Ship_To_Address4_Oracle__c);
            //system.assertEquals('CHAMPAIGN,IL, 61820, US',oInstalledProduct.Ship_To_City_State_Zip_Country_Oracle__c);  
            //system.assertEquals('611088',oInstalledProduct.Ship_To_Org_Id__c);       
        //Test.stopTest();     
	//}
}