/*
  @description       : Test class for PaymentController
  @author            : R1
  @last modified on  : 12-05-2025
  @last modified by  : 
  Modifications Log 
  Ver   Date         Author         Modification

*/
@isTest
public class PaymentController_Test {
	@TestSetup
    static void setup(){
        ccrz__E_Cart__c cart = new ccrz__E_Cart__c(ccrz__EncryptedId__c = 'test',Payment_Reference__c = 'test');
        insert cart;
        
        ccrz__E_Order__c  order = new ccrz__E_Order__c(ccrz__OriginatedCart__c = cart.id, ccrz__OrderStatus__c = 'Open'); 
        insert order;
    }
    
    @isTest
    static void setupStripeTransactionTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new StripeMockResponseGenerator());
        Map<String,Object> response = PaymentController.setupStripeTransaction('test');
        Test.stopTest();
        Assert.areEqual(false,response.get('success'),'setupStripeTransactionTest assertion failed');
    }
    
    @isTest
    static void getPublicKeyTest(){
        Test.startTest();
        Map<String,Object> response = PaymentController.getPublicKey();
        Test.stopTest();
        Assert.areEqual(true,response.get('success'),'getPublicKeyTest assertion failed');
    }
    
    @isTest
    static void capturePaymentTest(){
        ccrz__E_Order__c order = [SELECT Id FROM ccrz__E_Order__c LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new StripeMockResponseGenerator());
        PaymentController.capturePayment(new List<String>{order.Id});
        Test.stopTest();
    }
    
    @isTest
    static void logStripePMErrorTest(){
        Test.startTest();
        Map<String,Object> response = PaymentController.logStripePMError('test','');
        Test.stopTest();
        Assert.areEqual(true,response.get('success'),'logStripePMErrorTest assertion failed');
    }
}