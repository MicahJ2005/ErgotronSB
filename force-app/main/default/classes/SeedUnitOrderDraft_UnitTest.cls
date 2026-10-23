/**
*   {Purpose}  -	Provide coverage for SeedUnitOrderDraftController
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
*   20160824  	Andy Boettcher DCS		Created
*   =============================================================================
*/
@isTest
private class SeedUnitOrderDraft_UnitTest {
	
	@testSetup static void createTestData() {

		// Create reCaptcha CS
		insert new reCaptchaGoogle__c(PublicKey__c = 'public',SecretKey__c = 'private', endpoint__c = 'https://googlerecaptcha');

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

	@isTest static void testSUOInputControl() {

		PageReference prTest = Page.SeedUnitOrderPublic;
		prTest.getParameters().put('brand', 'ergotron');
		Test.setCurrentPage(prTest);

		Id idLeadRecordType = Lead.SObjectType.getDescribe().getRecordTypeInfosByName().get('Seed Unit Order Submission').getRecordTypeId();
		
		Lead oLead = new Lead(
			FirstName='TEST',
			LastName='Test',
			Company='Test',
			RecordTypeId=idLeadRecordType,
			Street='TEST',
			City='TEST',
			StateCode='MN',
			PostalCode='55121',
			CountryCode='US',
			WebSeedProductRequested__c=[SELECT Id FROM Product2 WHERE IsActive=TRUE LIMIT 1].Id
		);

		SeedUnitOrderDraftController clsSUO = new SeedUnitOrderDraftController(new ApexPages.StandardController(oLead));

		test.startTest();

		// NULL
		clsSUO.soLead.Ergotron_Vertical_Market__c = null;
        System.Assert(clsSUO.lstProducts.size() == 1, 'Negative Products Issue, No VM chosen!');

		// Education		
		clsSUO.soLead.Ergotron_Vertical_Market__c = 'Education';
        System.Assert(clsSUO.lstProducts.size() == 2, 'Positive Products Issue, Education!');

        // Education		
		clsSUO.soLead.Ergotron_Vertical_Market__c = 'Enterprise';
        System.Assert(clsSUO.lstProducts.size() == 2, 'Positive Products Issue, Enterprise!');

        // Education		
		clsSUO.soLead.Ergotron_Vertical_Market__c = 'Government';
        System.Assert(clsSUO.lstProducts.size() == 1, 'Negative Products Issue, Government!');

        // Education		
		clsSUO.soLead.Ergotron_Vertical_Market__c = 'Healthcare';
        System.Assert(clsSUO.lstProducts.size() == 1, 'Negative Products Issue, Healthcare!');

        // Education		
		clsSUO.soLead.Ergotron_Vertical_Market__c = 'Office/Wellness';
        System.Assert(clsSUO.lstProducts.size() == 1, 'Negative Products Issue, Office/Wellness!');

        test.stopTest();

	}
    
    @isTest static void testSUOLeadResellerNegative() {
        Test.setMock(HttpCalloutMock.class, new Utility_reCaptcha_Test.GoogleHTTPCalloutMock());

        PageReference prTest = Page.SeedUnitOrderPublic;
		prTest.getParameters().put('brand', 'ergotron');
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
			Oracle_Salesrep_Id__c='1234567890',
			User_Region__c = 'Americas' 
		);

		System.runAs(objUser) {

			test.startTest();
	
			Id idLeadRecordType = Lead.SObjectType.getDescribe().getRecordTypeInfosByName().get('Seed Unit Order Submission').getRecordTypeId();
			
			Lead oLead = new Lead(
				FirstName='TEST',
				LastName='Test',
				Company='Test',
				RecordTypeId=idLeadRecordType,
				Street='TEST',
				City='TEST',
				StateCode='MN',
				PostalCode='55121',
				Phone='555-555-1234',
				Email='testuser123@ergotron.com',
				CountryCode='US',
				Ergotron_Vertical_Market__c = 'Education',
				OwnerId = UserInfo.getUserId(),
				IsLiftGateRequired__c=TRUE,
                WebSeedProductRequested__c = [SELECT Id FROM Product2 WHERE IsActive=TRUE LIMIT 1].Id
			);

	        SeedUnitOrderDraftController clsSUO = new SeedUnitOrderDraftController(new ApexPages.StandardController(oLead));

	        // Test Save - NO RESELLER INFORMATION - FAIL.
	        clsSUO.saveLead();

        	test.stopTest();

        }

    }

	@isTest static void testSUOLeadSubmission() {

		//Test.setMock(HttpCalloutMock.class, new Utility_reCaptcha_Test.GoogleHTTPCalloutMock());
		Test.setMock(HttpCalloutMock.class, new Test_MOCK_ServiceCalls.generalCalloutMock());

		PageReference prTest = Page.SeedUnitOrderPublic;
		prTest.getParameters().put('brand', 'ergotron');
		Test.setCurrentPage(prTest);

/*
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
*/
//		System.runAs(objUser) {

			SmartyStreets_API__c ss = new SmartyStreets_API__c();
				ss.Name = 'SeedUnitAddressVerify';
				ss.auth_id__c = 'adsmfqmwepm09daasd';
				ss.auth_token__c = '23240kfir8fj8f8';
			insert ss;

			test.startTest();
	
			Id idLeadRecordType = Lead.SObjectType.getDescribe().getRecordTypeInfosByName().get('Seed Unit Order Submission').getRecordTypeId();
			
			Lead oLead = new Lead(
				FirstName='TEST',
				LastName='Test',
				Company='Test',
				RecordTypeId=idLeadRecordType,
				Street='TEST',
				City='TEST',
				StateCode='MN',
				PostalCode='55121',
				Phone='555-555-1234',
				Email='testuser123@ergotron.com',
				CountryCode='US',
				Ergotron_Vertical_Market__c = 'Education',
				OwnerId = UserInfo.getUserId(),
				IsLiftGateRequired__c=TRUE,
                WebResellerName__c = 'RESELLER',
                WebResellerContact__c = 'RESELLER',
                WebResellerAddress1__c = 'RESELLER',
                WebResellerCity__c = 'RESELLER',
                WebResellerStateCountry__c = 'RESELLER',
                WebResellerPostalCode__c = 'RESELLER',
                WebResellerPhone__c = '5555555555',
                WebResellerEmail__c = 'ME@RESELLER.COM',
				IsAddressValidated__c = true
			);

	        SeedUnitOrderDraftController clsSUO = new SeedUnitOrderDraftController(new ApexPages.StandardController(oLead));
	        System.Assert(clsSUO.lstProducts.size() == 2, 'Products Issue!');

	        // Test Save - NO ZIP
	        clsSUO.soLead.PostalCode = null;
	        clsSUO.saveLead();

	        // Test Save - NO PRODUCT
	        clsSUO.soLead.WebSeedProductRequested__c = null;
	        clsSUO.saveLead();
            
            // Test Save - SHIPPING ADDRESS
            clsSUO.soLeadShipping.ShippingStreet__c = '';
            clsSUO.saveLead();

	        // Test Save - GENERAL DML ERROR
	        clsSUO.soLead.Company = null;
			clsSUO.soLead.LastName = null;
			clsSUO.soLead.OwnerId = null;
			clsSUO.saveLead();

	        // Test Save - SUCCESS
			clsSUO.soLead.Company = 'Test';
			clsSUO.soLead.LastName = 'Test';
	        clsSUO.soLead.PostalCode = '55121';
            clsSUO.soLead.State = 'Minnesota';
            clsSUO.soLead.Country = 'United States';
            clsSUO.soLeadBillingAddress.Ship_To_State_Province__c = 'Minnesota-MN';
            clsSUO.soLeadBillingAddress.Ship_To_Country__c = 'United States-US';
            clsSUO.soLead.ShippingState__c = 'Minnesota-MN';
            clsSUO.soLead.ShippingCountry__c = 'United States-US';
	        clsSUO.soLead.OwnerId = UserInfo.getUserId();
	        clsSUO.soLead.WebSeedProductRequested__c = [SELECT Id FROM Product2 WHERE IsActive=TRUE LIMIT 1].Id;
			clsSUO.soLead.IsAddressValidated__c = true;
			System.debug('This is the test lead being saved: ' + clsSUO.soLead);
	        clsSUO.saveLead();
	        System.Assert(clsSUO.bolShowResults == true, 'Something went wrong in the save!');

	        // Test Convert
	        Database.LeadConvert objLC = new Database.LeadConvert();
	        objLC.setLeadId(clsSUO.soLead.Id);
	        objLC.setOwnerId(UserInfo.getUserId());

	        LeadStatus convertStatus = [Select Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
	        objLC.setConvertedStatus(convertStatus.MasterLabel);

	        Database.LeadConvertResult objLCR = Database.convertLead(objLC);
	        System.assert(objLCR.isSuccess(), 'Lead Convert Failed!');

        	test.stopTest();

//        }

	}
    
    static testmethod void testGetProducts(){
        //Products are loaded in via the load test data call at the beginning of this class.
        Test.startTest();
        List<SeedUnitOrderDraftController.Option> options1 = SeedUnitOrderDraftController.getProductOptions('ergotron','Education');
        List<SeedUnitOrderDraftController.Option> options2 = SeedUnitOrderDraftController.getProductOptions('haworth','Education');
        List<SeedUnitOrderDraftController.Option> options3 = SeedUnitOrderDraftController.getProductOptions('ergotron','invalid');
        List<SeedUnitOrderDraftController.Option> options4 = SeedUnitOrderDraftController.getProductOptions('invalid','invalid');
        List<SeedUnitOrderDraftController.Option> options5 = SeedUnitOrderDraftController.getProductOptions(null,null);
        Test.stopTest();
        System.assert(options1.size() > 1,'ergotron products should have more than just the default option.');
        System.assert(options2.size() > 1,'haworth products should have more than just the default option.');
        System.assert(options3.size() >= 1,'invalid market products should only have default option.');
        System.assert(options4.size() >= 1,'invalid brand products should only have default option.');
        System.assert(options5.size() >= 1,'null parameter products should only have default option..');
    }
    
    static testmethod void testGetMarkets(){
        //All this does is do a describe to get picklist values.  Really no need for negative tests here.
        List<SeedUnitOrderDraftController.Option> options = SeedUnitOrderDraftController.getMarkets();
        System.assertNotEquals(true, options == null, 'market options should not be null.');
        System.assert(!options.isEmpty(), 'market options should not be empty.');
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