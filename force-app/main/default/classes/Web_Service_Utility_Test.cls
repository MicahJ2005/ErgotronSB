/*
	Test class for Web_Service_Utility.cls and related Apex Triggers/Classes.

	MOD DATE		Who						Description
	3/21/2014		Chris Noe				Initial Release
	9/24/2014		Chris Noe 				Updated to include Keep_Me_As_Lead_Owner__c field when creating new leads in the test methods.
*/

@isTest (seeAllData=true)
private class Web_Service_Utility_Test {

	private static testmethod void testLeadTerritoryLookupCalloutSuccess() {
		//Create new Lead for the test
		Lead oLead = new Lead(FirstName='TEST', LastName='Test', Company='Test', StateCode='CA', CountryCode='US', PostalCode='90210',Keep_Me_As_Lead_Owner__c=false);
		insert oLead;
	
		//Set mock response and test territory lookup callout
		Test.startTest();
			SingleHTTPRequestMock_Test fakeResponseTrigger = new SingleHTTPRequestMock_Test(200,
			                                                'Complete',
			                                                '['+
				'  {'+
				'    \"__type\": \"RepLocator.rep\",'+
				'    \"ID\": \"' + oLead.Id + '\",'+
				'    \"Name\": \"LIMON, DAN\",'+
				'    \"Phone\": \"425-868-2257\",'+
				'    \"Email\": \"DLIMON@ERGOTRON.COM\",'+
				'    \"Ismanager\": \"N\",'+
				'    \"Multirep\": \"N\"'+
				'  }'+
				']'
			     , null);
				
			Test.setMock(HttpCalloutMock.class, fakeResponseTrigger);
			List<Id> listLeadIds = new List<Id>{oLead.Id};
			Lead_Utility.getLeadAssignments(listLeadIds);
		Test.stopTest(); 
	}
	
	private static testmethod void testLeadTerritoryLookupCalloutStatusException() {
		//Create new Lead for the test
		Lead oLead = new Lead(FirstName='TEST', LastName='Test', Company='Test', StateCode='CA', CountryCode='US', PostalCode='90210',Keep_Me_As_Lead_Owner__c=false);
		insert oLead;
	
		//Set mock response and test territory lookup callout
		Test.startTest();
			SingleHTTPRequestMock_Test fakeResponseTrigger = new SingleHTTPRequestMock_Test(204,
			                                                'NOT OK',
			                                                '['+
				'  {'+
				'    \"__type\": \"RepLocator.rep\",'+
				'    \"ID\": \"' + oLead.Id + '\",'+
				'    \"Name\": \"LIMON, DAN\",'+
				'    \"Phone\": \"425-868-2257\",'+
				'    \"Email\": \"DLIMON@ERGOTRON.COM\",'+
				'    \"Ismanager\": \"N\",'+
				'    \"Multirep\": \"N\"'+
				'  }'+
				']'
			     , null);
				
			Test.setMock(HttpCalloutMock.class, fakeResponseTrigger);
			List<Id> listLeadIds = new List<Id>{oLead.Id};
			Lead_Utility.getLeadAssignments(listLeadIds);
		Test.stopTest(); 
	}	

	private static testmethod void testLeadTerritoryLookupCalloutException() {
		//Create new Lead for the test
		Lead oLead = new Lead(FirstName='TEST', LastName='Test', Company='Test', StateCode='CA', CountryCode='US', PostalCode='90210',Keep_Me_As_Lead_Owner__c=false);
		insert oLead;
	
		//Set mock response and test territory lookup callout
		Test.startTest();
			SingleHTTPRequestMock_Test fakeResponseTrigger = new SingleHTTPRequestMock_Test(200,
			                                                'Complete',
			                                                '//['+
				'  {'+
				'    \"__type\": \"RepLocator.rep\",'+
				'    \"ID\": \"' + oLead.Id + '\",'+
				'    \"Name\": \"LIMON, DAN\",'+
				'    \"Phone\": \"425-868-2257\",'+
				'    \"Email\": \"DLIMON@ERGOTRON.COM\",'+
				'    \"Ismanager\": \"N\",'+
				'    \"Multirep\": \"N\"'+
				'  }'+
				']'
			     , null);
				
			Test.setMock(HttpCalloutMock.class, fakeResponseTrigger);
			List<Id> listLeadIds = new List<Id>{oLead.Id};
			Lead_Utility.getLeadAssignments(listLeadIds);
		Test.stopTest(); 
	}	

	private static testmethod void testPOSTerritoryLookupCalloutSuccess() {
        //Create POS record for testing
        POS__c oPOS = new POS__c(OwnerId='005G0000003r9HE',Product_Transfer_Date__c=Date.today(),Resale_Line_Id__c=String.valueOf(Test_Environment_Utility.getRandomInt(1, 1000)),Ship_To_State__c='MN',Ship_To_Country__c='US',Ship_To_Postal_Code__c='55372');
        insert oPOS;
	
		//Set mock response and test territory lookup callout
		Test.startTest();
			SingleHTTPRequestMock_Test fakeResponseTrigger = new SingleHTTPRequestMock_Test(200,
			                                                'Complete',
			                                                '['+
				'  {'+
				'    \"__type\": \"RepLocator.rep\",'+
				'    \"ID\": \"' + oPOS.Id + '\",'+
				'    \"Name\": \"LIMON, DAN\",'+
				'    \"Phone\": \"425-868-2257\",'+
				'    \"Email\": \"DLIMON@ERGOTRON.COM\",'+
				'    \"Ismanager\": \"N\",'+
				'    \"Multirep\": \"N\"'+
				'  }'+
				']'
			     , null);
				
			Test.setMock(HttpCalloutMock.class, fakeResponseTrigger);
			List<Id> listPOSIds = new List<Id>{oPOS.Id};
			Lead_Utility.getPOSAssignmentsCallout(listPOSIds);
		Test.stopTest(); 
	}
	
	private static testmethod void testInnerClassTerritoryLookupResponse(){
		//Test coverage for Web_Service_Utility.TerritoryLookupResponse
		
		Web_Service_Utility.TerritoryLookupResponse oTerritoryResponse = new Web_Service_Utility.TerritoryLookupResponse();
	}

	private static testmethod void testSiteUseLookupCalloutSuccess() {	
		//Set mock response and test site use lookup callout
		Test.startTest();
			SingleHTTPRequestMock_Test fakeResponseTrigger = new SingleHTTPRequestMock_Test(200,
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
			
			Test.setMock(HttpCalloutMock.class, fakeResponseTrigger);	
			List<Web_Service_Utility.ShipToSiteUseLookupResponse> listSiteUseLookup = Web_Service_Utility.SiteUseLookup('10000','Seed Unit Order Select Ship To');
		Test.stopTest(); 
	}
	
	private static testmethod void testSiteUseLookupCalloutStatusException() {
		//Set mock response and test site use lookup callout
		Test.startTest();
			SingleHTTPRequestMock_Test fakeResponseTrigger = new SingleHTTPRequestMock_Test(204,
			                                                'NOT OK',
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
			
			Test.setMock(HttpCalloutMock.class, fakeResponseTrigger);	
			List<Web_Service_Utility.ShipToSiteUseLookupResponse> listSiteUseLookup = Web_Service_Utility.SiteUseLookup('10000','Seed Unit Order Select Ship To');
		Test.stopTest(); 
	}	

	private static testmethod void testSiteUseLookupCalloutCalloutException() {
		//Set mock response and test site use lookup callout
		Test.startTest();
			SingleHTTPRequestMock_Test fakeResponseTrigger = new SingleHTTPRequestMock_Test(200,
			                                                'Complete',
			                                                '//['+
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
			
			Test.setMock(HttpCalloutMock.class, fakeResponseTrigger);	
			List<Web_Service_Utility.ShipToSiteUseLookupResponse> listSiteUseLookup = Web_Service_Utility.SiteUseLookup('10000','Seed Unit Order Select Ship To');
		Test.stopTest(); 
	}	

	private static testmethod void testInnerClassSiteUseLookupResponse(){
		//Test coverage for Web_Service_Utility.ShipToSiteUseLookupResponse
		
		Web_Service_Utility.ShipToSiteUseLookupResponse oSiteUseResponse = new Web_Service_Utility.ShipToSiteUseLookupResponse();
	}
}