/*
	Test class for Customer_Account_Override.cls.

	MOD DATE		Who						Description
	3/20/2014		Chris Noe				Initial Release
*/

@isTest
private class Customer_Account_Override_Test {
	
	static testmethod void testViewRedirectStandard() {

		Account oAccount = Test_Environment_Utility.createInsertAccountUS();
		Customer_Account__c oCustomerAccount = Test_Environment_Utility.createInsertCustomerAccount(oAccount);
		
		Test.startTest();
			PageReference oPageRef = Page.overrideCustomerAccountView;
			Test.setCurrentPage(oPageRef);

			ApexPages.StandardController oStdController = new ApexPages.StandardController(oCustomerAccount);
			oPageRef.getParameters().put('id',String.valueOf(oCustomerAccount.Id));
			Customer_Account_Override oExtController = new Customer_Account_Override(oStdController);
			
			System.runAs(Test_Environment_Utility.createInsertUser()){
				PageReference oReturnPageRef = oExtController.RedirectAccount();
				
				system.assertEquals('/' + oAccount.Id, oReturnPageRef.getUrl());
			}

				
		Test.stopTest(); 
	}

	static testmethod void testViewRedirectAdmin() {
		Account oAccount = Test_Environment_Utility.createInsertAccountUS();
		Customer_Account__c oCustomerAccount = Test_Environment_Utility.createInsertCustomerAccount(oAccount);
		
		Test.startTest();
			PageReference oPageRef = Page.overrideCustomerAccountView;
			Test.setCurrentPage(oPageRef);

			ApexPages.StandardController oStdController = new ApexPages.StandardController(oCustomerAccount);
			oPageRef.getParameters().put('id',String.valueOf(oCustomerAccount.Id));
			Customer_Account_Override oExtController = new Customer_Account_Override(oStdController);
			
			PageReference oReturnPageRef = oExtController.RedirectAccount();
			
			system.assertEquals(null, oReturnPageRef);
		Test.stopTest(); 
	}
}