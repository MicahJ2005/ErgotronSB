/*
	Test class for Order_Line_Notes_Cntrl.cls.

	MOD DATE		Who						Description
	04/23/2015		Chris Noe				Initial Release
    10/11/2017      DCS - MCS               Removal Customer_Account__c
*/

@isTest
private class Order_Line_Notes_Cntrl_Test {

    //Test data setup method
    @testSetup
    static void testDataSetup() {
    	//Create Account for testing
    	Account oAccount = Test_Environment_Utility.createInsertAccountUS();
    	//Customer_Account__c oCustomerAccount = Test_Environment_Utility.createInsertCustomerAccount(oAccount);

        //Create Order for testing
    	Order__c oOrder = new Order__c(Name='TEST', Customer__c=oAccount.Id, Customer_Account_new__c=oAccount.Id);
    	insert oOrder;

        //Create order line for testing.
    	Order_Line_Item__c oOrderLineItem = new Order_Line_Item__c(Name='TEST', Order__c=oOrder.Id, Actual_Shipment_Date__c=Date.newInstance(2015,1,1), CurrencyIsoCode='USD');
    	insert oOrderLineItem;
	}

	static testmethod void testUpdateNotes() {
		//Retrieve order from test date
		Order__c oOrder = [select Id from Order__c limit 1];

        //Set page reference
        PageReference oPageRef = Page.OrderLineNotes;
        Test.setCurrentPage(oPageRef); 
        //Invoke the standard and extension controllers with Order__c record retrieved above
        ApexPages.StandardController oStdController = new ApexPages.StandardController(oOrder);
        oPageRef.getParameters().put('id',String.valueOf(oOrder.Id));
        Order_Line_Notes_Cntrl oExtController = new Order_Line_Notes_Cntrl(oStdController);

        //Update Note
        oExtController.listOLI[0].Notes__c='HERE IS A TEST NOTE';
        oExtController.listOLI[0].Estimated_Completion_Date__c=Date.today();

        //Call save method on the controller and assert
        system.assertEquals('/' + oOrder.Id, oExtController.saveUpdates().getURL());
        //Assert Notes__c and Estimated_Completion_Date__c
        Order_Line_Item__c oOLI = [select Notes__c, Estimated_Completion_Date__c from Order_Line_Item__c where Order__c = :oOrder.Id];
        system.assertEquals('HERE IS A TEST NOTE', oOLI.Notes__c);
        system.assertEquals(Date.today(), oOLI.Estimated_Completion_Date__c);
        //Assert cancel method
        system.assertEquals('/' + oOrder.Id, oExtController.cancelUpdates().getURL());
	}
}