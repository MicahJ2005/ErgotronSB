/*
    Test class for Product_Schedule_Trigger.trigger and Product_Schedule_Utility.cls.

    MOD DATE        Who                         Description
    08/20/2019      Sophia Murphy (Dem.Chain)   Initially created as a replacement for a failing process builder and flow
                                                Case #214868
    03/20/2024      Esau Sanchez                Comment assert lines because we are deactivating the Product_Schedule_Trigger
*/
@isTest
private class Product_Schedule_Utility_Test {
    
    @isTest
    static void testUpdateSetCloseDate() {

        Date testDate1 = Date.today();
        Date testDate2 = testDate1.addDays(5);
        Date testDate3 = testDate1.addDays(10);

        User myTestUser = Test_Environment_Utility.createInsertUser();
        Account acct = Test_Environment_Utility.createInsertAccountUS();
        Opportunity opp = Test_Environment_Utility.createInsertOpportunity('Sales Development', acct, 'Open', testDate1);
        //Product2 prod = Test_Environment_Utility.createInsertProduct();

        //Create Products for testing
        List<Product2> listProducts = Test_Environment_Utility.generateFGProducts(2, true);

        //Generate standard prices
        Map<Id, Decimal> mapStandardProductPrices = Test_Environment_Utility.generateProductPrices(listProducts, 100);
        List<PricebookEntry> listStdPricebookEntries = Test_Environment_Utility.generatePricebookEntries(mapStandardProductPrices, Test.getStandardPricebookId(), true);

        //Create non Standard Pricebook for testing
        Pricebook2 oNonStandardPricebook = Test_Environment_Utility.generatePricebooks(1, true).get(0);

        //Create non standard pricebook entries
        List<PricebookEntry> listNonStdPricebookEntries = Test_Environment_Utility.generatePricebookEntries(mapStandardProductPrices, oNonStandardPricebook.Id, true);
        listNonStdPricebookEntries = [select Id, Product2Id, ProductCode from PricebookEntry where Id in :listNonStdPricebookEntries];

        //Add line items to the opportunities
        List<OpportunityLineItem> listOpptyLineItems = new List<OpportunityLineItem>();

        listOpptyLineItems.add(new OpportunityLineItem (
                                                    OpportunityId=opp.Id,
                                                    PricebookEntryId=listNonStdPricebookEntries[0].Id,
                                                    Quantity=100,
                                                    UnitPrice=100,
                                                    Target_End_User_Price__c=100,
                                                    Rebate_Amount__c=20,
                                                    Estimated_Distribution_Margin__c=5,
                                                    Estimated_Reseller_Margin__c=10));

        listOpptyLineItems.add(new OpportunityLineItem (
                                                    OpportunityId=opp.Id,
                                                    PricebookEntryId=listNonStdPricebookEntries[1].Id,
                                                    Quantity=100,
                                                    UnitPrice=100,
                                                    Target_End_User_Price__c=100,
                                                    Rebate_Amount__c=20,
                                                    Estimated_Distribution_Margin__c=5,
                                                    Estimated_Reseller_Margin__c=10));                                      

        insert listOpptyLineItems;

        List<OpportunityLineItemSchedule> listOpptyLineSchedItems = new List<OpportunityLineItemSchedule>();

        listOpptyLineSchedItems.add(new OpportunityLineItemSchedule (
                                                    Quantity=5,
                                                    Type='Quantity',
                                                    ScheduleDate = testDate2,
                                                    OpportunityLineItemId=listOpptyLineItems[0].Id));

        listOpptyLineSchedItems.add(new OpportunityLineItemSchedule (
                                                    Quantity=5,
                                                    Type='Quantity',
                                                    ScheduleDate = testDate3,
                                                    OpportunityLineItemId=listOpptyLineItems[0].Id));                              

        insert listOpptyLineSchedItems;

        //Don't need to create product schedules; the opp line scheds do it automatically.

        //Confirm that the opp close date changed to the earlist opp line sched - testDate2
        Opportunity myOpp = [SELECT Id, CloseDate FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
        // system.assertEquals(testDate2, myOpp.CloseDate);  // Commenting this line because we are inactivating the Product_Schedule_Trigger

        //Now grab one of the Product Schedules - change the date to testDate1 - 
        //and since that is earlier; the opp closedate should change to that
        Product_Schedule__c ps = [SELECT Id, Scheduled_Date__c FROM Product_Schedule__c WHERE Opportunity__c = :opp.Id LIMIT 1];
        ps.Scheduled_Date__c = testDate1;
        update ps;

        myOpp = [SELECT Id, CloseDate FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
        // system.assertEquals(testDate1, myOpp.CloseDate);  // Commenting this line because we are inactivating the Product_Schedule_Trigger


    }
}