/**
 * @description       : 
 * @author            : Titus.K@DemandChain.com
 * @group             : 
 * @last modified on  : 10-10-2022
 * @last modified by  : Titus.K@DemandChain.com
**/
@isTest
public with sharing class ccCartItemControllerTest {
    
    static void setup() {
        ccrz__E_Product__c p = new ccrz__E_Product__c();
        p.Name = 'tester';
        p.ccrz__SKU__c = '123';
        p.ccrz__StartDate__c = System.Today();
        p.ccrz__EndDate__c = System.Today();
        p.ccrz__Quantityperunit__c = 1;
        insert p;

        ccrz__E_ProductMedia__c m = new ccrz__E_ProductMedia__c();
        m.ccrz__StartDate__c = System.Today();
        m.ccrz__EndDate__c = System.Today();
        m.ccrz__Sequence__c = 1;
        m.ccrz__URI__c = 'www.test.com';
        m.ccrz__Product__c = p.id;
        insert m;

        ccrz__E_Cart__c c = new ccrz__E_Cart__c();
        c.ccrz__Name__c = 'testCart';
        insert c;

        ccrz__E_CartItem__c i = new ccrz__E_CartItem__c();
        i.ccrz__Price__c = 1;
        i.ccrz__Quantity__c = 1;
        i.ccrz__Cart__c = c.id;
        i.ccrz__DisplayProduct__c = p.id;
        insert i;
    }

    @isTest
    public static void itemCreationTest() {
        setup();

        Test.startTest();
        ccCartItemController controller = new ccCartItemController();
        List<ccCartItemController.Item> lstItem = controller.getlstItems();
        Test.stopTest();
        System.assertEquals(lstItem.size(), 1);
    }
}