/**
*   {Purpose}  -	Test Coverage for SRWizardController
*
*	{Code Covered}	- SRWizardController
*
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 612-424-0032                  
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date    	Name             		Description
*   20160411  	Andy Boettcher DCS		Created
*	20180517	Andy Boettcher DCS		Sunsetted for Lightning Service Cloud
*   =============================================================================
*/
@isTest
private class SRWizardController_UnitTest {

	//@testSetup static void setupTestData() {

		////Create Accounts for testing
    	//Account oAccountEndUser = Test_Environment_Utility.createInsertAccountUS();
    	//oAccountEndUser.Name = 'TESTLONG';
    	//oAccountEndUser.Oracle_Party_Number__c = '12345';  // Incredible!  I have that same combination on my luggage!
    	//update oAccountEndUser;

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

    	//// Create Installed Product
    	//Installed_Product__c oInstalledProduct = Test_Environment_Utility.createInsertInstalledProductOracle('ABC-123', oAccountEndUser, oProduct);

    	////Create Service_Contract__c for testing
    	//Service_Contract__c oServiceContract = Test_Environment_Utility.createInsertServiceContract('TEST', oAccountEndUser, oAccountDistributor, oAccountReseller, oProduct, oContact);
    	//Service_Contract_Product__c oSCP = new Service_Contract_Product__c();
    	//oSCP.Service_Contract__c = oServiceContract.Id;
    	//oSCP.Installed_Product__c = oInstalledProduct.Id;
    	//insert oSCP;

    	//// Create Case
    	//Case oCase = Test_Environment_Utility.createInsertCase(oAccountEndUser, oContact, null, null);
    	//oCase.Serial_Number__c = oInstalledProduct.Id;
    	//oCase.Service_Contract__c = oServiceContract.Id;
    	//update oCase;

	//}

	//@isTest static void testServiceContractSearch() {

		//PageReference prTest = Page.SRWizard;
		//Test.setCurrentPage(prTest);

		//SRWizardController clsWizCase = new SRWizardController(new ApexPages.standardController([SELECT Id FROM Case LIMIT 1]));

		//// Search by string
		//clsWizCase.clsQuickFind.strSearchServiceContract = 'TEST';
		//System.Assert(clsWizCase.lstServiceContracts.size() > 0, 'No Service Contracts found for search!');

		//// Search by Account Id
		//clsWizCase.clsQuickFind.strSearchServiceContract = '';
		//clsWizCase.clsQuickFind.idAccount = [SELECT Id FROM Account WHERE Oracle_Party_Number__c = '12345'].Id;
		//System.Assert(clsWizCase.lstServiceContracts.size() > 0, 'No Service Contracts found for search!');

		//// Service Contracts by Id
		//clsWizCase.clsQuickFind.idServiceContract = clsWizCase.lstServiceContracts[0].getValue();
		//System.Assert(clsWizCase.lstInstalledProducts.size() > 0, 'No Service Contracts found by Id search!');

		//// Service Contracts by Serial Number
		//clsWizCase.clsQuickFind.idInstalledProduct = [SELECT Id FROM Installed_Product__c].Id;
		//System.Assert(clsWizCase.lstServiceContracts.size() > 0, 'No Service Contracts found by Serial NUmber!');

	//}

	//@isTest static void testSerialNumberSearch() {

		//PageReference prTest = Page.SRWizard;
		//Test.setCurrentPage(prTest);

		//SRWizardController clsWizCase = new SRWizardController(new ApexPages.standardController([SELECT Id FROM Case LIMIT 1]));

		//// Search by string
		//clsWizCase.clsQuickFind.strSearchInstalledProduct = 'ABC-123';
		//System.Assert(clsWizCase.lstInstalledProducts.size() > 0, 'No Installed products found for search!');
		//clsWizCase.clsQuickFind.idInstalledProduct = clsWizCase.lstInstalledProducts[0].getValue();
		////clsWizCase.clsQuickFind.strSearchInstalledProduct = '';
		////System.Assert(clsWizCase.lstInstalledProducts.size() > 0, 'No Installed products found for id search!');
		////clsWizCase.clsQuickFind.strSearchAccount = 'TESTLONG';
		////clsWizCase.clsQuickFind.idAccount = clsWizCase.lstAccounts[0].getValue();
		////System.Assert(clsWizCase.lstInstalledProducts.size() > 0, 'No Installed products found for id search!');

	//}

	//@isTest static void testExistingCaseSearch() {

		//PageReference prTest = Page.SRWizard;
		//Test.setCurrentPage(prTest);

		//SRWizardController clsWizCase = new SRWizardController(new ApexPages.standardController([SELECT Id FROM Case LIMIT 1]));

		//clsWizCase.clsQuickFind.idInstalledProduct = [SELECT Id FROM Installed_Product__c].Id;
		//System.Assert(clsWizCase.lstExistingCases.size() == 1, 'No Pre-existing cases were found by Serial Number!');

	//}
	
	//@isTest static void testFullSearch() {
		
		//PageReference prTest = Page.SRWizard;
		//Test.setCurrentPage(prTest);

		//SRWizardController clsWizCase = new SRWizardController(new ApexPages.standardController([SELECT Id FROM Case LIMIT 1]));

		//// Test New Contact Link
		//PageReference prNewContact = clsWizCase.prNewContact;

		//// Clear all Search Results
		//clsWizCase.executeSearch();

		//// Test Search - Account
		//clsWizCase.clsQuickFind.strSearchAccount = 'TESTLONG';
		//System.Assert(clsWizCase.lstAccounts.size() > 0, 'No Accounts found for search!');
		//clsWizCase.clsQuickFind.idAccount = clsWizCase.lstAccounts[0].getValue();
		//clsWizCase.clsQuickFind.strSearchAccount = '';
		//System.Assert(clsWizCase.lstAccounts.size() > 0, 'No Accounts found for id search!');

		//// Test Search - Contact
		//clsWizCase.clsQuickFind.strSearchContact = 'First';
		//System.Assert(clsWizCase.lstContacts.size() > 0, 'No Contacts found for search!');
		//clsWizCase.clsQuickFind.idContact = clsWizCase.lstContacts[0].getValue();
		//clsWizCase.clsQuickFind.strSearchContact = '';
		//System.Assert(clsWizCase.lstContacts.size() > 0, 'No Accounts found for id search!');

		//clsWizCase.clsQuickFind.idServiceContract = clsWizCase.lstServiceContracts[0].getValue();
		//clsWizCase.clsQuickFind.idInstalledProduct = clsWizCase.lstInstalledProducts[0].getValue();

		//// Assign Values to Case - populated account
		//System.Assert(clsWizCase.clsQuickFind.idAccount != '', 'idAccount is not set!');
		//System.Assert(clsWizCase.clsQuickFind.idContact != '', 'idContact is not set!');
		//System.Assert(clsWizCase.clsQuickFind.idServiceContract != '', 'idServiceContract is not set!');
		//System.Assert(clsWizCase.clsQuickFind.idInstalledProduct != '', 'idInstalledProduct is not set!');
		//clsWizCase.searchForData();

		//// Assign Values to Case - null account
		//clsWizCase.clsQuickFind.idAccount = '';
		//System.Assert(clsWizCase.clsQuickFind.idAccount == '', 'idAccount is set!');
		//System.Assert(clsWizCase.clsQuickFind.idContact != '', 'idContact is not set!');
		//System.Assert(clsWizCase.clsQuickFind.idServiceContract != '', 'idServiceContract is not set!');
		//System.Assert(clsWizCase.clsQuickFind.idInstalledProduct != '', 'idInstalledProduct is not set!');
		//clsWizCase.searchForData();

	//}

	//@isTest static void testCreateNewContact() {

		//PageReference prTest = Page.SRWizard;
		//Test.setCurrentPage(prTest);

		//SRWizardController clsWiz = new SRWizardController(new ApexPages.standardController([SELECT Id FROM Contact LIMIT 1]));

		//System.Assert(clsWiz.saveContact() == null, 'False save presented a non-null return!');

		//clsWiz.soContact = new Contact();
		//clsWiz.soContact.FirstName = 'Test Firstname';
		//clsWiz.soContact.LastName = 'Test LastName';
		//clsWiz.soContact.Email = 'Test@Email.com';
		//clsWiz.soContact.Phone = '555-555-5555';
		//clsWiz.soContact.MobilePhone = '555-666-6666';
		//clsWiz.soContact.AccountId = [SELECT Id FROM Account WHERE Oracle_Party_Number__c = '12345'].Id;

		//System.Assert(clsWiz.saveContact() != null, 'True save presented a null return!');
	//}

	//@isTest static void testCreateSR() {

		//PageReference prTest = Page.SRWizard;
		//Test.setCurrentPage(prTest);

		//SRWizardController clsWiz = new SRWizardController(new ApexPages.standardController([SELECT Id FROM Case LIMIT 1]));

		//System.Assert(clsWiz.saveSR() == null, 'False save presented a non-null return!');

		//clsWiz.soCase.Id = null;
		//clsWiz.soCase.AccountId = [SELECT Id FROM Account WHERE Oracle_Party_Number__c = '12345'].Id;
		//clsWiz.soCase.ContactId = [SELECT Id FROM Contact].Id;
		//clsWiz.soCase.Serial_Number__c = [SELECT Id FROM Installed_Product__c].Id;
		//clsWiz.soCase.Service_Contract__c = [SELECT Id FROM Service_Contract__c].Id;

		//clsWiz.soCase.Type = 'Service Maintenance';
		//clsWiz.soCase.Problem_Codes__c = 'Casters/Base';
		//clsWiz.soCase.Subject = 'Test SR Create - Unit Test';
		//clsWiz.soCase.Disposition__c = 'RMA';
		//clsWiz.soCase.Out_Of_Box__c = 'No';

		////System.Assert(clsWiz.saveSR() != null, 'True save presented a null return!');

	//}
	
}