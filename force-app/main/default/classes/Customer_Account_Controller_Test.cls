/*
	Test class for the Customer_Account_Controller.cls.

	MOD DATE		Who						Description
	5/12/2014		Chris Noe				Initial Release
*/

@isTest
private class Customer_Account_Controller_Test {

    static testMethod void CustomerAccountTest() {
        //Create account for testing
        Account oAccount = Test_Environment_Utility.createInsertAccountUS();
		//Create customer account for testing
		Customer_Account__c oCustomerAccount = Test_Environment_Utility.createInsertCustomerAccount(oAccount);
		
        Test.startTest();
            PageReference oPageRef = Page.CustomerAccounts;
            Test.setCurrentPage(oPageRef);

			//Invoke the standard and extension controllers with the account created above
			ApexPages.StandardController oStdController = new ApexPages.StandardController(oAccount);
			ApexPages.currentPage().getParameters().put('id',oAccount.id);
			Customer_Account_Controller oExtController = new Customer_Account_Controller(oStdController);
        	
			system.assertEquals(1,oExtController.listCustomerAccounts.size());
		Test.stopTest();        			        
    }
}