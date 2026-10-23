/*
	Test class for Order_Trigger.trigger and Order_Utility.cls.

	MOD DATE		Who						Description
	03/24/2015		Chris Noe				Initial Release
    04/07/2015      Chris Noe               Test updates for new method Order_Utility.updateShipToAccountDetails
    10/11/2017      DCS - MCS               Removal Customer_Account__c
*/

@isTest
private class Order_Utility_Test {
    static testmethod void testOrderInsert() {
    	//Create Accounts for testing
    	Account oAccount = Test_Environment_Utility.createInsertAccountUS();
    	//Customer_Account__c oCustomerAccount = Test_Environment_Utility.createInsertCustomerAccount(oAccount);

    	//Create Order__c records for testing (1 for each month)
    	List<Order__c> listOrders = new List<Order__c>();

    	Order__c oOrderJan = new Order__c(Name='TESTJAN', Ship_To_Customer_Account_Number__c=oAccount.Account_Number__c, Customer__c=oAccount.Id, Customer_Account_new__c=oAccount.Id, Booked_Date__c=Date.newInstance(2015,1,1));
    	listOrders.add(oOrderJan);
    	Order__c oOrderFeb = new Order__c(Name='TESTFEB', Ship_To_Customer_Account_Number__c=oAccount.Account_Number__c, Customer__c=oAccount.Id, Customer_Account_new__c=oAccount.Id, Booked_Date__c=Date.newInstance(2015,2,1));
    	listOrders.add(oOrderFeb);
    	Order__c oOrderMar = new Order__c(Name='TESTMAR', Ship_To_Customer_Account_Number__c=oAccount.Account_Number__c, Customer__c=oAccount.Id, Customer_Account_new__c=oAccount.Id, Booked_Date__c=Date.newInstance(2015,3,1));
    	listOrders.add(oOrderMar);
    	Order__c oOrderApr = new Order__c(Name='TESTAPR', Ship_To_Customer_Account_Number__c=oAccount.Account_Number__c, Customer__c=oAccount.Id, Customer_Account_new__c=oAccount.Id, Booked_Date__c=Date.newInstance(2015,4,1));
    	listOrders.add(oOrderApr);
    	Order__c oOrderMay = new Order__c(Name='TESTMAY', Ship_To_Customer_Account_Number__c=oAccount.Account_Number__c, Customer__c=oAccount.Id, Customer_Account_new__c=oAccount.Id, Booked_Date__c=Date.newInstance(2015,5,1));
    	listOrders.add(oOrderMay);
    	Order__c oOrderJun = new Order__c(Name='TESTJUN', Ship_To_Customer_Account_Number__c=oAccount.Account_Number__c, Customer__c=oAccount.Id, Customer_Account_new__c=oAccount.Id, Booked_Date__c=Date.newInstance(2015,6,1));
    	listOrders.add(oOrderJun);
    	Order__c oOrderJul = new Order__c(Name='TESTJUL', Ship_To_Customer_Account_Number__c=oAccount.Account_Number__c, Customer__c=oAccount.Id, Customer_Account_new__c=oAccount.Id, Booked_Date__c=Date.newInstance(2015,7,1));
    	listOrders.add(oOrderJul);
    	Order__c oOrderAug = new Order__c(Name='TESTAUG', Ship_To_Customer_Account_Number__c=oAccount.Account_Number__c, Customer__c=oAccount.Id, Customer_Account_new__c=oAccount.Id, Booked_Date__c=Date.newInstance(2015,8,1));
    	listOrders.add(oOrderAug);
    	Order__c oOrderSep = new Order__c(Name='TESTSEP', Ship_To_Customer_Account_Number__c=oAccount.Account_Number__c, Customer__c=oAccount.Id, Customer_Account_new__c=oAccount.Id, Booked_Date__c=Date.newInstance(2015,9,1));
    	listOrders.add(oOrderSep);
    	Order__c oOrderOct = new Order__c(Name='TESTOCT', Ship_To_Customer_Account_Number__c=oAccount.Account_Number__c, Customer__c=oAccount.Id, Customer_Account_new__c=oAccount.Id, Booked_Date__c=Date.newInstance(2015,10,1));
    	listOrders.add(oOrderOct);
    	Order__c oOrderNov = new Order__c(Name='TESTNOV', Ship_To_Customer_Account_Number__c=oAccount.Account_Number__c, Customer__c=oAccount.Id, Customer_Account_new__c=oAccount.Id, Booked_Date__c=Date.newInstance(2015,11,1));
    	listOrders.add(oOrderNov);
    	Order__c oOrderDec = new Order__c(Name='TESTDEC', Ship_To_Customer_Account_Number__c=oAccount.Account_Number__c, Customer__c=oAccount.Id, Customer_Account_new__c=oAccount.Id, Booked_Date__c=Date.newInstance(2015,12,1));
    	listOrders.add(oOrderDec);

    	insert listOrders;
    }
}