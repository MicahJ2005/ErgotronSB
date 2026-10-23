/*
	Test class for Opportunity_Trigger.trigger and Opportunity_Utility.cls.

	MOD DATE		Who						Description
	2/25/2014		Chris Noe				Initial Release
	5/20/2014		Chris Noe				Added testInsertOpportunityDefaultDistributor method to support auto-selection of distributor partners on Ergotron Branded opportunities.
	6/24/2014		Chris Noe				Updated to use Test_Environment_Utility methods for creating data
	4/20/2015 		Chris Noe 				Added test method testSeedUnitsExist.
	6/29/2015       Chris Noe               Updates for the new Opportunity_Partner__c object - FB-00653.
*/

@isTest
private class Opportunity_Utility_Test {
    
    @testSetup static void setupData() {

		ccrz__E_AccountGroup__c cAG = new ccrz__E_AccountGroup__c ();
        cAG.Name = 'Replacement Parts';
		insert cAG;

        Pricebook2 oNewCanadaPricebook = new Pricebook2(Name='Canada Standard', IsActive=true);
		insert oNewCanadaPricebook;
    }
	
	static testMethod void testInsertOpportunitySingle() {
		//Tests insert of a single Opportunity record
		List<Oppty_Record_Type_Pricebook__c> listOpptyRTPriceBook = new List<Oppty_Record_Type_Pricebook__c>();
		Map<Id, Id> mapOpptyRTPriceBook = new Map<Id, Id>();
		List<Opportunity> listOpportunity = new List<Opportunity>();
		
		//Create Pricebook2 record
		Pricebook2 oNewPriceBook = new Pricebook2(Name='Test', IsActive=true);
		insert oNewPriceBook;
		
		//Create Account for testing
		Account oNewAccount = Test_Environment_Utility.createInsertAccountUS();
		oNewAccount.region__c = 'Americas';
		update oNewAccount;
		
		//Retrieve the current Opportunity record type values and create Oppty_Record_Type_Pricebook__c records each record type and the Pricebook2.Id created above.
		//Also create an opportunity for each record type.
		for(RecordType oOpptyRecordType : [select Id from RecordType where SobjectType='Opportunity']) {
			mapOpptyRTPriceBook.put(oOpptyRecordType.Id,oNewPriceBook.Id);
			listOpptyRTPriceBook.add(new Oppty_Record_Type_Pricebook__c(Name=oOpptyRecordType.Id, Price_Book_Id__c=oNewPriceBook.Id, Description__c='TESTING: ' + oOpptyRecordType.Id));
			listOpportunity.add(new Opportunity(Name='Test: ' + oOpptyRecordType.Id, AccountId=oNewAccount.Id, StageName='Prospecting', CloseDate=Date.today(), RecordTypeId=oOpptyRecordType.Id));
		}	
		
		//Add invalid id value to custom setting to catch exception testing
		listOpptyRTPriceBook.add(new Oppty_Record_Type_Pricebook__c(Name='BAD-ID', Price_Book_Id__c='BAD-ID', Description__c='BAD-ID'));
		
		//Insert custom setting values and opportunities
		if(!listOpptyRTPriceBook.isEmpty() && !listOpportunity.isEmpty()){
			insert listOpptyRTPriceBook;
			insert listOpportunity;
			
			//Assert that Pricebook2Id was set correctly based on the 
			for(Opportunity oOpportunity :[select Id, RecordTypeId, Pricebook2Id from Opportunity where Id in :listOpportunity]){
				system.assertEquals(mapOpptyRTPriceBook.get(oOpportunity.RecordTypeId), oOpportunity.Pricebook2Id);
			}
		}
	}
	
	static testMethod void testInsertOpportunityDefaultDistributor() {
		//Create Accounts for testing
		Account oEndUserAccountUS = Test_Environment_Utility.createInsertAccountUS();
		Account oEndUserAccountCA = Test_Environment_Utility.createInsertAccountCA();

		Account oDistributorAccountUS = Test_Environment_Utility.createInsertAccountUS();
		Account oDistributorAccountCA = Test_Environment_Utility.createInsertAccountCA();
		
		//Create Opportunity_Distributor_Mapping__c records for testing
		Opportunity_Distributor_Mapping__c oODMUS = new Opportunity_Distributor_Mapping__c(Name='US', Country_Unique__c='US');
		insert oODMUS;
		Opportunity_Distributor__c oODUS = new Opportunity_Distributor__c(Distributor__c=oDistributorAccountUS.Id,Opportunity_Distributor_Mapping__c=oODMUS.Id);
		insert oODUS;

		Opportunity_Distributor_Mapping__c oODMCA = new Opportunity_Distributor_Mapping__c(Name='CA', Country_Unique__c='CA');
		insert oODMCA;
		Opportunity_Distributor__c oODCA = new Opportunity_Distributor__c(Distributor__c=oDistributorAccountCA.Id,Opportunity_Distributor_Mapping__c=oODMCA.Id);
		insert oODCA;
		
		//Create opportunity for testing	
		List<Opportunity> listOpportunity = new List<Opportunity>();
		Opportunity oOpportunityUS = Test_Environment_Utility.createOpportunity('Ergotron Forecast Opportunity', oEndUserAccountUS, 'Prospecting', Date.today());
		listOpportunity.add(oOpportunityUS);
		Opportunity oOpportunityCA = Test_Environment_Utility.createOpportunity('Ergotron Forecast Opportunity', oEndUserAccountCA, 'Prospecting', Date.today());
		listOpportunity.add(oOpportunityCA);
		insert listOpportunity;
		
		test.startTest();
			Opportunity_Partner__c oPartnerUS = [select Partner_Account__c from Opportunity_Partner__c where Opportunity__c=:oOpportunityUS.Id];
			system.assertEquals(oODUS.Distributor__c, oPartnerUS.Partner_Account__c);

			Opportunity_Partner__c oPartnerCA = [select Partner_Account__c from Opportunity_Partner__c where Opportunity__c=:oOpportunityCA.Id];
			system.assertEquals(oODCA.Distributor__c, oPartnerCA.Partner_Account__c);
		test.stopTest();
	}	

	/* This test is no longer needed.  The Seed_Unit_Order object is not used any more. */
	/* 
	static testMethod void testSeedUnitsExist() {
        //Create account for testing
        Account oAccount = Test_Environment_Utility.createInsertAccountUS();
        //Create contact for testing
        Contact oContact = Test_Environment_Utility.createInsertContact(oAccount);
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccount, 'Seeding', Date.today());
        //Create seed unit order for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Hospital', oAccount, oContact);
        //Create product for testing
        Product2 oProduct = Test_Environment_Utility.createInsertProduct();
        //Create seed unit product for testing
        Seed_Unit_Product__c oSeedUnitProduct = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProduct, 5);
        
        test.startTest();
        	//Update Seed_Unit_Order__c and set Seed Unit Order Submitted flag to true
        	oSeedUnitOrder.Seed_Unit_Order_Submitted__c=true;
        	update oSeedUnitOrder;
        	
        	try{
        		delete oOpportunity;	
        	}
        	catch(Exception oException){
        		system.assert(oException.getMessage().contains('This opportunity cannot be deleted because it contains seed unit orders that have been submitted to Oracle.'));
        	}
        test.stopTest();
	}
	 */
    
    static testMethod void testPullConvertedLeadProduct() {
        //Need a lead, and convert it - that will send the lead through the lead trigger and into the Opportunity_Utility
        ////Set up lead conversion
        Test.setMock(HttpCalloutMock.class, new Test_MOCK_ServiceCalls.generalCalloutMock());
		SmartyStreets_API__c ss = new SmartyStreets_API__c();
			ss.Name = 'SeedUnitAddressVerify';
			ss.auth_id__c = 'adsmfqmwepm09daasd';
			ss.auth_token__c = '23240kfir8fj8f8';
		insert ss;
        
         //Method variables
        Id idLeadRecordTypeId;

        //Create web service details record record by lead assignment callout
        Web_Service_Details__c oWebService = Test_Environment_Utility.createInsertWebServiceDetails('Territory Lookup');

        //Create Partner Account and Partner Contact for the Lead
        Account oAccount = Test_Environment_Utility.createInsertAccountUS();
        oAccount.Authorized_Reseller__c = true;
        update oAccount;
        Contact oContact = Test_Environment_Utility.createInsertContact(oAccount);
        //Create Products for testing
    	Product2 oProductService = Test_Environment_Utility.createInsertProduct();
    	oProductService.Item_Type__c='E-SERVICE';
    	oProductService.Name='SERVICE';
    	update oProductService;

        //Get record type id for 'Ergotron Standard Lead'
        idLeadRecordTypeId = Lead.SObjectType.getDescribe().getRecordTypeInfosByName().get('Seed Unit Order Submission').getRecordTypeId();
        //idLeadRecordTypeId = Lead.SObjectType.getDescribe().getRecordTypeInfosByName().get('Ergotron Standard Lead').getRecordTypeId();

        Lead oLead = new Lead(FirstName='TEST',LastName='Test',Company='Test',Status='Open',Partner_Account__c=oAccount.Id,Partner_Contact__c=oContact.Id,RecordTypeId=idLeadRecordTypeId,
                                Street='TEST',City='TEST',StateCode='MN',PostalCode='55121',CountryCode='US');
        oLead.WebSeedProductRequested__c = oProductService.Id;
        insert oLead;
        
        Database.LeadConvert oLeadConvert = new Database.LeadConvert();
        oLeadConvert.setLeadId(oLead.id);
        
        LeadStatus oConvertStatus = [select Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        oLeadConvert.setConvertedStatus(oConvertStatus.MasterLabel);
        
        Database.LeadConvertResult oLeadConvertResult = Database.convertLead(oLeadConvert);
    }
}