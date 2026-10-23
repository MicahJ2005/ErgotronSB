/*
    Test class for the Contact_Utility.cls.

    MOD DATE        Who                     Description
    11/04/2014      Chris Noe               Initial Release 
*/

@IsTest
private class Contact_Utility_Test {

	static testmethod void testUpdateContactAccount() {
		//Create web service details record record by lead assignment callout
		Web_Service_Details__c oWebService = Test_Environment_Utility.createInsertWebServiceDetails('Territory Lookup');

		//Create 2 accounts for testing
		Account oAccount1 = Test_Environment_Utility.createInsertAccountUS();
		Account oAccount2 = Test_Environment_Utility.createInsertAccountUS();
		Contact oContact = Test_Environment_Utility.createInsertContact(oAccount1);

		//Create lead for testing
		Lead oLead = new Lead(LastName='Test', Company='Test', Partner_Contact__c=oContact.Id, Partner_Account__c=oAccount1.Id);
		insert oLead;

		//Update Account on Contact
		oContact.AccountId = oAccount2.Id;
		update oContact;
		
		//Retrieve lead and assert partner contact
		system.assertEquals(oContact.AccountId,[select Partner_Account__c from Lead where Id = :oLead.Id].Partner_Account__c);
	}

	static testmethod void testUpdateContactRegion() {
		Account newAccount = new Account();
		newAccount.Name = 'Hello World';
		newAccount.BillingCountry = 'United States';
		newAccount.Oracle_Party_Id__c = '12345';
		newAccount.Oracle_Customer_Account_Id__c = '123456';
		insert newAccount;

		List<Region_Mapping__c> regionMappings = new List<Region_Mapping__c>{
            new Region_Mapping__c(Country__c='US',Region__c='Americas',Sub_Region__c='US'),
            new Region_Mapping__c(Country__c='CA',Region__c='Americas',Sub_Region__c='Canada'),
            new Region_Mapping__c(Country__c='PR',Region__c='Americas',Sub_Region__c='US'),
            new Region_Mapping__c(Country__c='IT',Region__c='EMEA')
        };
        insert regionMappings;
		
		Contact newContact = new Contact();
		newContact.FirstName = 'Hello World';
		newContact.LastName = 'Test';
		newContact.MailingCountryCode = 'US';
		newContact.Account = newAccount;
		newContact.Oracle_Party_Id__c = '12345';
		newContact.Oracle_Account_Id__c = '123456';
		newContact.Oracle_Contact_Role_Id__c = '54321';

		Contact newContact2 = new Contact();
		newContact2.FirstName = 'Hello World';
		newContact2.LastName = 'Test2';
		newContact2.MailingCountryCode = 'CA';
		newContact2.Account = newAccount;
		newContact2.Oracle_Party_Id__c = '54321';
		newContact2.Oracle_Account_Id__c = '123456';
		newContact2.Oracle_Contact_Role_Id__c = '54321';
	
		List<Contact> ContactList = new List<Contact>();
		ContactList.add(newContact);
		ContactList.add(newContact2);

		insert ContactList;

		System.assertEquals('Americas', [SELECT Region__c FROM Contact WHERE ID=: newContact.ID].Region__c, 'Region is correct');
		System.assertEquals('Americas', [SELECT Region__c FROM Contact WHERE ID=: newContact2.ID].Region__c, 'Region is correct');
		System.assertEquals('US', [SELECT Sub_Region__c FROM Contact WHERE ID=: newContact	.ID].Sub_Region__c, 'Sub-Region is correct');
		System.assertEquals('Canada', [SELECT Sub_Region__c FROM Contact WHERE ID=: newContact2.ID].Sub_Region__c, 'Sub-Region is correct');

	}
}

// Select Country__c FROM Region_Mapping__c WHERE Country__c = 'United States'