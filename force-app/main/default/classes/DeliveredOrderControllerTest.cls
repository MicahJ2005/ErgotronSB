/**
 * @description       : 
 * Modifications Log 
 * Ver   Date         Author                  Modification
 * 1.0   01.17.2023   sophiam@demandchain.com   Initial Version
**/
@isTest
public with sharing class DeliveredOrderControllerTest {

    static void setup() {

        Product2 prod = new Product2(Name = 'Laptop X200',  Family = 'Hardware');
        prod.ProductCode = '343-902-085-00';
        prod.Inventory_Item_Status_Code__c = 'MASTER';
        prod.IsActive = true;
        insert prod;

        Sales_Order__c s = new Sales_Order__c();
        insert s;

        Sales_Order_Line__c o = new Sales_Order_Line__c();
        o.Sales_Order__c = s.id;
        o.Part_Number__c = prod.id;
        o.Quantity__c = 1;
        insert o;

        Order__c order = new Order__c();
        insert order;

        Order_Tracking_Number__c oTrack = new Order_Tracking_Number__c();
        oTrack.SF_Sales_Order__c = s.Id;
        oTrack.Line_ID__c = '02';
        oTrack.Tracking_Number__c = 'TESTING';
        insert oTrack;

        ccrz__E_Product__c p = new ccrz__E_Product__c();
        p.Name = 'tester';
        p.ccrz__SKU__c = '123';
        p.ccrz__StartDate__c = System.Today();
        p.ccrz__EndDate__c = System.Today();
        p.Product__c = prod.id;
        insert p;

        Order_Line_Item__c oli = new Order_Line_Item__c();
        oli.Order__c = order.Id;
        oli.Line_ID__c = '02';
        oli.Ordered_Item_Lookup__c = prod.Id;
        oli.CC_Product__c = p.Id;
        insert oli;

        ccrz__E_ProductMedia__c m = new ccrz__E_ProductMedia__c();
        m.ccrz__StartDate__c = System.Today();
        m.ccrz__EndDate__c = System.Today();
        m.ccrz__Sequence__c = 1;
        m.ccrz__URI__c = 'www.test.com';
        m.ccrz__Product__c = p.id;
        m.ccrz__Enabled__c = true;
        insert m;

        zkmulti__MCShipment__c shipment = new zkmulti__MCShipment__c();
        shipment.Sales_Order__c = s.Id;
        shipment.Order__c = order.Id;
        shipment.zkmulti__Tracking_Stage__c = 'Delivered';
        shipment.Order_Tracking_Number__c = oTrack.Id;
        shipment.Delivered_Email_Sent__c = false;
        shipment.zkmulti__Ship_Date__c = System.Today();
        shipment.zkmulti__Actual_Delivery_Date__c = System.Today();
        insert shipment;
    }

    @isTest
    public static void testOne() {
        setup();

        Test.startTest();
        DeliveredOrderController controller = new DeliveredOrderController();
        Sales_Order__c s = [SELECT Id FROM Sales_Order__c];
        controller.theID = s.Id;
        controller.getSalesOrder();
        List<DeliveredOrderController.DeliveredDetail> lstItem = controller.getDeliveredDetailsList();
        Test.stopTest();
        System.assertEquals(lstItem.size(), 1);
       
    }

    @isTest
    public static void testBatch() {
        setup();

        Test.startTest();
        System.debug('');
        /**List<zkmulti__MCShipment__c> myList = new List<zkmulti__MCShipment__c>([SELECT Id, Order__c, Sales_Order__c 
                FROM zkmulti__MCShipment__c 
                WHERE Sales_Order__c != null AND Delivered_Email_Sent__c = false 
                AND zkmulti__Tracking_Stage__c = 'Delivered'
                AND Order_Tracking_Number__r.Tracking_Number__c != null
                AND zkmulti__Ship_Date__c > 2022-12-01 
                LIMIT 200]);*/

        //System.debug('DC: myList: ' + myList);
        DeliveredOrderEmailBatch batch = new DeliveredOrderEmailBatch();
        Database.executeBatch(batch, 200);
        //batch.runBatch((List<sObject>)myList);

        Test.stopTest();
       
    }

    @isTest
    public static void testScheduler() {
        Test.startTest();
 
        // Schedule the test job
   
        String jobId = System.schedule('testBasicScheduledApex',
        DeliveredOrderEmailScheduler.CRON_EXP, 
           new DeliveredOrderEmailScheduler());
   
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
           NextFireTime
           FROM CronTrigger WHERE id = :jobId];
   
        // Verify the expressions are the same
        System.assertEquals(DeliveredOrderEmailScheduler.CRON_EXP, 
           ct.CronExpression);
   
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
   
        // Verify the next time the job will run
        System.assertEquals('2024-09-03 00:00:00', 
           String.valueOf(ct.NextFireTime));
      //   System.assertNotEquals(200, [SELECT Id, Product2Id, Floor__c, Start__c, UnitPrice FROM PricebookEntry].size());
   
     Test.stopTest();
    }
}