/**
 * @description       : Test class for CartTaxCalculation
 * @author            : R1
 * @last modified on  : 12-05-2025
 * @last modified by  : R1
 * Modifications Log 
 * Ver   Date         Author                Modification
**/
@isTest
public class CartTaxCalculation_Test {
	@TestSetup
    static void setup(){
        Tax_Rate__c taxRate = new Tax_Rate__c(Combined_Rate__c = 0.03, ZIP_Start__c = 101, ZIP_End__c = 101);
        insert taxRate;
        ccrz__E_Cart__c cart = new ccrz__E_Cart__c(ccrz__EncryptedId__c = 'test',Payment_Reference__c = 'test');
        insert cart;
        ccrz__E_Product__c ccProduct = new ccrz__E_Product__c(Name = 'Test Prod',ccrz__SKU__c = 'test');
        insert ccProduct;
        ccrz__E_CartItem__c ccCartItem = new ccrz__E_CartItem__c(ccrz__Cart__c = cart.id,ccrz__Quantity__c = 4,ccrz__Product__c = ccProduct.Id,
            													ccrz__Price__c = 501.00,ccrz__SubAmount__c = 501.00);
        insert ccCartItem;
        ccrz__E_ContactAddr__c  shipTo = new ccrz__E_ContactAddr__c (ccrz__PostalCode__c = '101');
        insert shipTo;
        
        cart.ccrz__ShipTo__c = shipTo.Id;
        update cart;
    }
    
    @isTest
    static void getTaxAmountTest(){
        ccrz__E_Cart__c cart = [SELECT Id FROM ccrz__E_Cart__c LIMIT 1];
        Map<String,Object> inputData = new Map<String,Object>();
        inputData.put(ccrz.cc_hk_TaxCalculation.PARAM_CARTID,cart.Id);
		Test.startTest();
        Decimal response = new CartTaxCalculation().getTaxAmount(inputData);
		Test.stopTest();   
        Assert.areEqual(15.03,response,'getTaxAmountTest assertion failed');
    }
}