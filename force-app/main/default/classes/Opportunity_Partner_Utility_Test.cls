/*
    Test class for the Opportunity_Partner_Utility.cls.

    MOD DATE        Who                     Description
    12/18/2014      Chris Noe               Initial Release 
    6/29/2015       Chris Noe               Updates for the new Opportunity_Partner__c object - FB-00653.
    10/11/2017		DCS - MCS 				Removal Customer_Account__c
*/

@IsTest
private class Opportunity_Partner_Utility_Test {

    static testmethod void testOpptyPartnerUtility() {
		//Create Accounts for testing
		Account oEndUserAccountUS = Test_Environment_Utility.createInsertAccountUS();
		Account oDistributorAccountUS = Test_Environment_Utility.createInsertAccountUS();

		//Create Opportunity_Distributor_Mapping__c records for testing
		Opportunity_Distributor_Mapping__c oODMUS = new Opportunity_Distributor_Mapping__c(Name='US', Country_Unique__c='US');
		insert oODMUS;
		Opportunity_Distributor__c oODUS = new Opportunity_Distributor__c(Distributor__c=oDistributorAccountUS.Id,Opportunity_Distributor_Mapping__c=oODMUS.Id);
		insert oODUS;
		//Create opportunity for testing
		Opportunity oOpportunityUS = Test_Environment_Utility.createOpportunity('Ergotron Forecast Opportunity', oEndUserAccountUS, 'Prospecting', Date.today());
		insert oOpportunityUS;

		//Intantiate controller and set opportunity id
		Opportunity_Partner_Utility oCntrl = new Opportunity_Partner_Utility();
		oCntrl.setsOpportunityId(oOpportunityUS.Id);
		system.assertEquals(oCntrl.getsOpportunityId(),oOpportunityUS.Id);

		//Get list of Opportunity Partner records for the opportunity and assert 1 record in the list
		List<Opportunity_Partner__c> listPartners = oCntrl.getlistPartners();
		system.assertEquals(1,listPartners.size());

		//Set opportunity id to blank and assert null return
		oCntrl.setsOpportunityId('');
		system.assertEquals(null,oCntrl.getlistPartners());
    }

    static testmethod void testUpdateOpportunityDiscountClass() {
		//Create Accounts for testing
		Account oEndUserAccountUS = Test_Environment_Utility.createInsertAccountUS();
		Account oDistributorAccountUS = Test_Environment_Utility.createInsertAccountUS();

		//Create customer account for testing
		//Customer_Account__c oCustomerAccount = Test_Environment_Utility.createInsertCustomerAccount(oDistributorAccountUS);

		//Create Opportunity_Distributor_Mapping__c records for testing
		Opportunity_Distributor_Mapping__c oODMUS = new Opportunity_Distributor_Mapping__c(Name='US', Country_Unique__c='US');
		insert oODMUS;
		Opportunity_Distributor__c oODUS = new Opportunity_Distributor__c(Distributor__c=oDistributorAccountUS.Id,Opportunity_Distributor_Mapping__c=oODMUS.Id);
		insert oODUS;
		//Create opportunity for testing
		Opportunity oOpportunityUS = Test_Environment_Utility.createOpportunity('Ergotron Forecast Opportunity', oEndUserAccountUS, 'Prospecting', Date.today());
		insert oOpportunityUS;

		//Create Opportunity_Partner__c record for testing
		Opportunity_Partner__c oOpptyPartner = Test_Environment_Utility.createInsertOpportunityPartner(oOpportunityUS.Id, oDistributorAccountUS.Id, 'Distributor');

		Test.startTest();
			//Assert Discount_Class__c on Opportunity
			system.assertEquals('BROADLINE US DISCOUNT',[select Discount_Class__c from Opportunity where Id=:oOpportunityUS.Id].Discount_Class__c);
		Test.stopTest();
    }
}