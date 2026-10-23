/**
*   {Purpose}  -	Provide coverage for ResellerAuthFormPublicController
*
*	{Code Covered}	- Full Class Coverage
*
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 612-424-0032                  
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date    	Name             		Description
*   20170706  	Andy Boettcher DCS		Created
*   =============================================================================
*/

@isTest
private class ResellerAuthFormCtrl_UnitTest {
	
	@testSetup static void createTestData() {

		// Create reCaptcha CS
		insert new reCaptchaGoogle__c(PublicKey__c = 'public',SecretKey__c = 'private');

		//Create web service details record record by lead assignment callout
		Web_Service_Details__c oWebService = Test_Environment_Utility.createInsertWebServiceDetails('Territory Lookup');

    	//Create product for test
    	Product2 oProduct = Test_Environment_Utility.createInsertProduct();
    	oProduct.Item_Type__c='E-FG';
    	oProduct.Inventory_Item_Status_Code__c='MASTER';
    	oProduct.IsActive=true;
        oProduct.MSRP_EMEA_APAC_USD__c=10;
        oProduct.MSRP_EMEA_EUR__c=10;
        oProduct.MSRP_EMEA_GBP__c=10;
        oProduct.MSRP_US_STANDARD_USD__c=10;
    	oProduct.ProductCode='TEST';
    	oProduct.Costing_Inventory__c = 'F';
    	oProduct.PublicSeedUnitEligibleEducation__c = TRUE;
    	oProduct.PublicSeedUnitEligibleEnterprise__c = TRUE;
    	oProduct.PublicSeedUnitEligibleGovernment__c = FALSE;
    	oProduct.PublicSeedUnitEligibleHospital__c = FALSE;
    	oProduct.Public_Seed_Unit_Eligible_Haworth__c = TRUE;
    	update oProduct;

		Id idStdPricebook = Test.getStandardPricebookId();
		PricebookEntry objPBE = new PricebookEntry(
			Pricebook2Id = idStdPricebook,
			Product2Id = oProduct.Id,
			UnitPrice = 10000,
			IsActive = true
		);

	}

	@isTest static void testSUOLeadSubmissionSuccess() {

		Test.setMock(HttpCalloutMock.class, new Utility_reCaptcha_Test.GoogleHTTPCalloutMock());

		PageReference prTest = Page.SeedUnitOrderPublic;
		Test.setCurrentPage(prTest);

		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
		User objUser = new User(
			Alias = 'ergotest', 
			Email='ergotest@ergotron.com', 
			EmailEncodingKey='UTF-8', 
			LastName='Testing', 
			LanguageLocaleKey='en_US', 
			LocaleSidKey='en_US', 
			ProfileId = p.Id, 
			TimeZoneSidKey='America/Chicago', 
			UserName='ergotest@ergotron.com.SUODraft',
			Oracle_Salesrep_Id__c='1234567890' 
		);

		System.runAs(objUser) {

			test.startTest();
	
				//Id idLeadRecordType = Lead.SObjectType.getDescribe().getRecordTypeInfosByName().get('Seed Unit Order Submission').getRecordTypeId();
				
				Lead oLead = new Lead(
					FirstName='TEST',
					LastName='Test',
					Company='Test',
					Street='TEST',
					City='TEST',
					StateCode='MN',
					PostalCode='55121',
					Phone='555-555-1234',
					Email='testuser123@ergotron.com',
					CountryCode='US',
					Ergotron_Vertical_Market__c = 'Education',
					OwnerId = UserInfo.getUserId()
				);

		        ResellerAuthFormPublicController clsRAP = new ResellerAuthFormPublicController(new ApexPages.StandardController(oLead));

		        clsRAP.saveLead();

        	test.stopTest();

        }

	}

	@isTest static void testSUOLeadSubmissionFailure() {

		Test.setMock(HttpCalloutMock.class, new Utility_reCaptcha_Test.GoogleHTTPCalloutMock());

		PageReference prTest = Page.SeedUnitOrderPublic;
		Test.setCurrentPage(prTest);

		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
		User objUser = new User(
			Alias = 'ergotest', 
			Email='ergotest@ergotron.com', 
			EmailEncodingKey='UTF-8', 
			LastName='Testing', 
			LanguageLocaleKey='en_US', 
			LocaleSidKey='en_US', 
			ProfileId = p.Id, 
			TimeZoneSidKey='America/Chicago', 
			UserName='ergotest@ergotron.com.SUODraft',
			Oracle_Salesrep_Id__c='1234567890' 
		);

		System.runAs(objUser) {

			test.startTest();
	
				//Id idLeadRecordType = Lead.SObjectType.getDescribe().getRecordTypeInfosByName().get('Seed Unit Order Submission').getRecordTypeId();
				
				Lead oLead = new Lead(
					FirstName='TEST',
					Company='Test',
					Street='TEST',
					City='TEST',
					StateCode='MN',
					Phone='555-555-1234',
					Email='testuser123@ergotron.com',
					CountryCode='US',
					Ergotron_Vertical_Market__c = 'Education',
					OwnerId = UserInfo.getUserId()
				);

		        ResellerAuthFormPublicController clsRAP = new ResellerAuthFormPublicController(new ApexPages.StandardController(oLead));

		        clsRAP.saveLead();

        	test.stopTest();

        }

	}

	public class GoogleHTTPCalloutMock implements HttpCalloutMock {
	    // Implement this interface method
	    public HTTPResponse respond(HTTPRequest req) {
			// Create a fake response
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');
			res.setBody('{"success":"true"}');
			res.setStatusCode(200);
			return res;
	    }
  }
	
}