/**
 * @description       : 
 * @author            : Titus.K@DemandChain.com
 * @group             : 
 * @last modified on  : 10-10-2022
 * @last modified by  : Titus.K@DemandChain.com
**/
@isTest
public with sharing class SalesOrderLineComponentControllerTest {

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
        insert o;

        ccrz__E_Product__c p = new ccrz__E_Product__c();
        p.Name = 'tester';
        p.ccrz__SKU__c = '123';
        p.ccrz__StartDate__c = System.Today();
        p.ccrz__EndDate__c = System.Today();
        p.Product__c = prod.id;
        insert p;

        ccrz__E_ProductMedia__c m = new ccrz__E_ProductMedia__c();
        m.ccrz__StartDate__c = System.Today();
        m.ccrz__EndDate__c = System.Today();
        m.ccrz__Sequence__c = 1;
        m.ccrz__URI__c = 'www.test.com';
        m.ccrz__Product__c = p.id;
        insert m;

       
    }

    @isTest
    public static void itemCreationTest() {
        setup();

        Test.startTest();
        SalesOrderLineComponentController controller = new SalesOrderLineComponentController();
        List<SalesOrderLineComponentController.Item> lstItem = controller.getlstItems();
        Test.stopTest();
        System.assertEquals(lstItem.size(), 1);
       
    }
}