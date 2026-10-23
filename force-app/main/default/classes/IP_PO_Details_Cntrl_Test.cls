/*
	Test class for the IP_PO_Details_Cntrl.cls.

	MOD DATE		Who						Description
	07/10/2015		Chris Noe				Initial Release
*/

@isTest
private class IP_PO_Details_Cntrl_Test {
	
    //Test data setup method
    @testSetup
    static void testDataSetup() {
    	//Create Accounts for testing
    	Account oAccount = Test_Environment_Utility.createInsertAccountUS();
        //Create Customer_Account__c for testing
        Account oCustomerAccount = Test_Environment_Utility.createInsertAccountUS();

    	//Create Customer_Account__c for testing
    	//Customer_Account__c oCustomerAccount = Test_Environment_Utility.createInsertCustomerAccount(oAccount);

    	//Create Order__c for testing
    	Order__c oOrder = Test_Environment_Utility.createInsertOrder(oAccount,oCustomerAccount);

    	//Create Purchase_Order_Detail_OE__c for testing
    	Purchase_Order_Detail_OE__c oPO = Test_Environment_Utility.createInsertPurchaseOrder(oOrder);

    	//Create Integration_Project__c for testing
    	Integration_Project__c oIP = Test_Environment_Utility.createInsertIntegrationProject(oOrder);
    }
	
	static testmethod void testIPPODetails() {
		//Retrieve the Integration_Project__c record created in test data set up
		Integration_Project__c oIP = [select Id, Sales_Order__c from Integration_Project__c limit 1];
        
        Test.startTest();
            PageReference oPageRef = Page.ippodetails;
            Test.setCurrentPage(oPageRef);

			//Invoke the standard and extension controllers with the Integration_Project__c record retrieved above
			ApexPages.StandardController oStdController = new ApexPages.StandardController(oIP);
			ApexPages.currentPage().getParameters().put('id',oIP.id);
			IP_PO_Details_Cntrl oExtController = new IP_PO_Details_Cntrl(oStdController);
        	
			system.assertEquals(1,oExtController.listPODetails.size());
			system.assertEquals(true,oExtController.bPODetails);
		Test.stopTest(); 
	}
}