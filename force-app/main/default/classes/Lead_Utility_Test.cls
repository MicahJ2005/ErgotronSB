/*
    Test class for the Lead_Utility.cls.

    MOD DATE        Who                     Description
    11/04/2014      Chris Noe               Initial Release 
    6/29/2015       Chris Noe               Updates for the new Opportunity_Partner__c object - FB-00653.
*/

@IsTest
private class Lead_Utility_Test {

    static testmethod void testDeleteLead() {
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
    	update oProduct;

		Lead oLead = new Lead(LastName='Test',Company='Test',Status='Registration Submitted');
		insert oLead;
		Lead_Product__c oLeadProduct = new Lead_Product__c(Lead__c=oLead.Id, Product__c=oProduct.Id, Quantity__c=10);
		insert oLeadProduct;
		delete oLead;
	}

    static testmethod void testLeadConvertOpportunityPartnerContactUpdate() {

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

        //Get record type id for 'Ergotron Standard Lead'
        idLeadRecordTypeId = Lead.SObjectType.getDescribe().getRecordTypeInfosByName().get('Ergotron Standard Lead').getRecordTypeId();

        Lead oLead = new Lead(FirstName='TEST',LastName='Test',Company='Test',Status='Open',Partner_Account__c=oAccount.Id,Partner_Contact__c=oContact.Id,RecordTypeId=idLeadRecordTypeId,
                                Street='TEST',City='TEST',StateCode='MN',PostalCode='55121',CountryCode='US');
        insert oLead;

        //Set up lead conversion
        Database.LeadConvert oLeadConvert = new Database.LeadConvert();
        oLeadConvert.setLeadId(oLead.id);

        Test.startTest();
            LeadStatus oConvertStatus = [select Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            oLeadConvert.setConvertedStatus(oConvertStatus.MasterLabel);

            Database.LeadConvertResult oLeadConvertResult = Database.convertLead(oLeadConvert);

            //Assert Opportunity_Partner__c and ContactRole records have been created
            system.assertEquals(oAccount.Id,[select Id, Partner_Account__c from Opportunity_Partner__c where Opportunity__c = :oLeadConvertResult.getOpportunityId() and Partner_Role__c='Reseller'].Partner_Account__c);
            system.assertEquals(oContact.Id,[select Id, ContactId from OpportunityContactRole where OpportunityId = :oLeadConvertResult.getOpportunityId() and Role='Reseller Contact'].ContactId);
        Test.stopTest();
    }

    /**
    * @description 
    * @author willh@demandchain.com | 04-15-2021 
    * @return testMethod 
    **/
    static testMethod void updateLeadRegionalMapping() {

        Web_Service_Details__c oWebService = Test_Environment_Utility.createInsertWebServiceDetails('Territory Lookup');
        
        List<Region_Mapping__c> regionMappings = new List<Region_Mapping__c>{
            new Region_Mapping__c(Country__c='US',Region__c='Americas',Sub_Region__c='United States'),
            new Region_Mapping__c(Country__c='CA',Region__c='Americas',Sub_Region__c='Canada'),
            new Region_Mapping__c(Country__c='PR',Region__c='Americas',Sub_Region__c='United States'),
            new Region_Mapping__c(Country__c='IT',Region__c='EMEA')
        };
        insert regionMappings;
        //Create Partner Account and Partner Contact for the Lead
        Account oAccount = Test_Environment_Utility.createInsertAccountUS();
        Contact oContact = Test_Environment_Utility.createInsertContact(oAccount);

        List<Lead> newLeadList = new List<Lead>();
        Lead oLead = new Lead(FirstName='TEST',
                                LastName='Test',
                                Company='Test',
                                Status='Open',
                                Partner_Account__c=oAccount.Id,
                                Partner_Contact__c=oContact.Id,
                                Street='TEST',
                                City='TEST',
                                PostalCode='55121',
                                CountryCode='US');
        Lead oLead2 = new Lead(FirstName='TEST',
                                LastName='Test',
                                Company='Test',
                                Status='Open',
                                Partner_Account__c=oAccount.Id,
                                Partner_Contact__c=oContact.Id,
                                Street='TEST',
                                City='TEST',
                                PostalCode='55121',
                                CountryCode='CA');
        newLeadList.add(oLead);
        newLeadList.add(oLead2);

        insert newLeadList;

        System.assertEquals('Americas', [SELECT Region__c FROM Lead WHERE ID=: oLead.ID].Region__c, 'Region is correct');
		System.assertEquals('Americas', [SELECT Region__c FROM Lead WHERE ID=: oLead2.ID].Region__c, 'Region is correct');
		System.assertEquals('United States', [SELECT Sub_Region__c FROM Lead WHERE ID=: oLead.ID].Sub_Region__c, 'Sub-Region is correct');
		System.assertEquals('Canada', [SELECT Sub_Region__c FROM Lead WHERE ID=: oLead2.ID].Sub_Region__c, 'Sub-Region is correct');


        
    }
}