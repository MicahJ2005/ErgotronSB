/**
 * @description       : 
 * @author            : willh@demandchain.com
 * @group             : 
 * @last modified on  : 05-05-2021
 * @last modified by  : willh@demandchain.com
 * Modifications Log 
 * Ver   Date         Author                  Modification
 * 1.0   04-29-2021   willh@demandchain.com   Initial Version
**/

@istest
class TEST_TrackingOrderEmail {
    private static Sales_Order__c theSalesOrder;
    private static PricebookEntry pbe1;
    private static List<PriceBook2> PriceBook2List;
    private static List<PricebookEntry> PricebookEntryList;
    @testSetup static void setup() {
        
        Account theAccount = new Account(
            Name='Test Research Inc',
            Ergotron_Vertical_Market__c='Office/Wellness',  
            Type='End User'); 


         insert theAccount;
            
         Contact theContact = new Contact(
            AccountId=theAccount.ID, 
            LastName='TEST', 
            FirstName='Will', 
            Email='ewewewew@demandchain.com');

         insert theContact;

         Order__c theOrder = new Order__c(
            Name='123456789087654321', 
            CurrencyIsoCode='USD', 
            Customer__c=theAccount.ID);
            
         insert theOrder;


        Sales_Order__c theSalesOrder = new Sales_Order__c(
            Bill_To_Customer__c=theAccount.ID, 
            Customer_PO_Number__c='UNKNOWN', 
            Oracle_Sales_Order_Number__c=theOrder.ID, 
            Order_Submitted__c=false, 
            Order_Type__c='TEMP', 
            Ship_To_Address1_Oracle__c='123 Happy Street', 
            Ship_To_Contact__c=theContact.ID, 
            Ship_To_Customer__c=theAccount.ID, 
            Order_Sub_Type__c='Product',
            Queue__c=true, 
            Tracking_Order_Email_Sent__c=false);
         insert theSalesOrder;

        Order_Tracking_Number__c theOrderTrackingNumber = new Order_Tracking_Number__c(
            CurrencyIsoCode='USD', 
            Carrier_Code__c='FEDX', 
            Line_ID__c='12XU', 
            Line_Number__c='123141123', 
            Order_Number__c='2131244221421141422121', 
            Quantity__c=2, 
            Tracking_Number__c='1233141421421123', 
            Tracking_Unique_ID__c='3123213213213213', 
            SF_Sales_Order__c=theSalesOrder.ID);
         insert theOrderTrackingNumber;

         Product2 theProduct = new Product2(
            Name='WILL TEST', 
            Sales_Product_Category__c='Wall Furniture;Ergotron Home');
         insert theProduct;

         Order_Line_Item__c theOrderLineItem = new Order_Line_Item__c(
            Name='1234567654321', 
            Order__c=theOrder.ID, 
            Line_Id__c='12XU', 
            Ordered_Item_Lookup__c=theProduct.ID);
         insert theOrderLineItem;


    }
    
    static testmethod void testInserts() {

        Test.startTest();
 
   
        // Schedule the test job
   
        String jobId = System.schedule('testBasicScheduledApex',
        TrackingOrderEmailScheduler.CRON_EXP, 
           new TrackingOrderEmailScheduler());
   
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
           NextFireTime
           FROM CronTrigger WHERE id = :jobId];
   
        // Verify the expressions are the same
        System.assertEquals(TrackingOrderEmailScheduler.CRON_EXP, 
           ct.CronExpression);
   
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
   
        // Verify the next time the job will run
        System.assertEquals('2029-09-03 00:00:00', 
           String.valueOf(ct.NextFireTime));
      //   System.assertNotEquals(200, [SELECT Id, Product2Id, Floor__c, Start__c, UnitPrice FROM PricebookEntry].size());
   
     Test.stopTest();

   //   System.assertNotEquals(200, [SELECT Id, Product2Id, Floor__c, Start__c, UnitPrice FROM PricebookEntry].size());
 
   }


}