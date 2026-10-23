/*
	Test class for Order_Line_Item_Trigger.trigger and Order_Line_Item_Utility.cls.

	MOD DATE		Who						Description
	03/24/2015		Chris Noe				Initial Release
    10/11/2017      DCS - MCS               Removal Customer_Account__c
*/

@isTest
private class Order_Line_Item_Utility_Test {
    static testmethod void testOrderLineInsert() {
    	//Create Accounts for testing
    	Account oAccount = Test_Environment_Utility.createInsertAccountUS();
    	//Customer_Account__c oCustomerAccount = Test_Environment_Utility.createInsertCustomerAccount(oAccount);

    	Order__c oOrder = new Order__c(Name='TEST', Customer__c=oAccount.Id, Customer_Account_new__c=oAccount.Id);
    	insert oOrder;
    	
    	//Create Order_Line_Item__c records for testing (1 for each month)
    	List<Order_Line_Item__c> listOrderLineItems = new List<Order_Line_Item__c>();

        //Create order lines for fiscal year testing.
    	Order_Line_Item__c oOrderLineJan = new Order_Line_Item__c(Name='TESTJAN', Order__c=oOrder.Id, Actual_Shipment_Date__c=Date.newInstance(2015,1,1), CurrencyIsoCode='USD');
    	listOrderLineItems.add(oOrderLineJan);
    	Order_Line_Item__c oOrderLineFeb = new Order_Line_Item__c(Name='TESTFEB', Order__c=oOrder.Id, Actual_Shipment_Date__c=Date.newInstance(2015,2,1), CurrencyIsoCode='USD');
    	listOrderLineItems.add(oOrderLineFeb);
    	Order_Line_Item__c oOrderLineMar = new Order_Line_Item__c(Name='TESTMAR', Order__c=oOrder.Id, Actual_Shipment_Date__c=Date.newInstance(2015,3,1), CurrencyIsoCode='USD');
    	listOrderLineItems.add(oOrderLineMar);
    	Order_Line_Item__c oOrderLineApr = new Order_Line_Item__c(Name='TESTAPR', Order__c=oOrder.Id, Actual_Shipment_Date__c=Date.newInstance(2015,4,1), CurrencyIsoCode='USD');
    	listOrderLineItems.add(oOrderLineApr);
    	Order_Line_Item__c oOrderLineMay = new Order_Line_Item__c(Name='TESTMAY', Order__c=oOrder.Id, Actual_Shipment_Date__c=Date.newInstance(2015,5,1), CurrencyIsoCode='USD');
    	listOrderLineItems.add(oOrderLineMay);
    	Order_Line_Item__c oOrderLineJun = new Order_Line_Item__c(Name='TESTJUN', Order__c=oOrder.Id, Actual_Shipment_Date__c=Date.newInstance(2015,6,1), CurrencyIsoCode='USD');
    	listOrderLineItems.add(oOrderLineJun);
    	Order_Line_Item__c oOrderLineJul = new Order_Line_Item__c(Name='TESTJUL', Order__c=oOrder.Id, Actual_Shipment_Date__c=Date.newInstance(2015,7,1), CurrencyIsoCode='USD');
    	listOrderLineItems.add(oOrderLineJul);
    	Order_Line_Item__c oOrderLineAug = new Order_Line_Item__c(Name='TESTAUG', Order__c=oOrder.Id, Actual_Shipment_Date__c=Date.newInstance(2015,8,1), CurrencyIsoCode='USD');
    	listOrderLineItems.add(oOrderLineAug);
    	Order_Line_Item__c oOrderLineSep = new Order_Line_Item__c(Name='TESTSEP', Order__c=oOrder.Id, Actual_Shipment_Date__c=Date.newInstance(2015,9,1), CurrencyIsoCode='USD');
    	listOrderLineItems.add(oOrderLineSep);
    	Order_Line_Item__c oOrderLineOct = new Order_Line_Item__c(Name='TESTOCT', Order__c=oOrder.Id, Actual_Shipment_Date__c=Date.newInstance(2015,10,1), CurrencyIsoCode='USD');
    	listOrderLineItems.add(oOrderLineOct);
    	Order_Line_Item__c oOrderLineNov = new Order_Line_Item__c(Name='TESTNOV', Order__c=oOrder.Id, Actual_Shipment_Date__c=Date.newInstance(2015,11,1), CurrencyIsoCode='USD');
    	listOrderLineItems.add(oOrderLineNov);
    	Order_Line_Item__c oOrderLineDec = new Order_Line_Item__c(Name='TESTDEC', Order__c=oOrder.Id, Actual_Shipment_Date__c=Date.newInstance(2015,12,1), CurrencyIsoCode='USD');
    	listOrderLineItems.add(oOrderLineDec);

        //Create order line items for currency conversion testing
        Order_Line_Item__c oOrderLineUSD = new Order_Line_Item__c(Name='TESTUSD', Order__c=oOrder.Id, Actual_Shipment_Date__c=Date.newInstance(2014,10,1), CurrencyIsoCode='USD');
        listOrderLineItems.add(oOrderLineUSD);
        Order_Line_Item__c oOrderLineGBP = new Order_Line_Item__c(Name='TESTGBP', Order__c=oOrder.Id, Actual_Shipment_Date__c=Date.newInstance(2014,11,1), CurrencyIsoCode='GBP');
        listOrderLineItems.add(oOrderLineGBP);
        Order_Line_Item__c oOrderLineEUR = new Order_Line_Item__c(Name='TESTEUR', Order__c=oOrder.Id, Oracle_Creation_Date__c=Date.newInstance(2014,12,1), CurrencyIsoCode='EUR');
        listOrderLineItems.add(oOrderLineEUR);

    	insert listOrderLineItems;
    }
}