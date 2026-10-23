@isTest
public with sharing class CC_ERG_AddToCartServiceTest {

    public static Map<String, Object> testData;
    public static void setupTestData(Boolean createParentAccount, String name) {
        SmartyStreets_API__c ss = new SmartyStreets_API__c();
        ss.Name = name;
        ss.auth_id__c = 'adsmfqmwepm09daasd';
        ss.auth_token__c = '23240kfir8fj8f8';
        insert ss;           
        ccrz__E_Configuration__c theConfig = new ccrz__E_Configuration__c();
        testData = CC_ERG_TestData.setupAccountContactUser(createParentAccount,true);
    }
    
    @isTest
    static void addToCartTest() {
        setupTestData(true, 'SeedUnitAddressVerify');
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();   
        req.requestUri ='/services/apexrest/v1/addToCart';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        //Map<String, Object> dataMapResult = VONB2B_TestFactory.createB2BCheckoutData();
        //ccrz__E_Cart__c cartObj = (ccrz__E_Cart__c) dataMapResult.get(VONB2B_TestFactory.CC_CART);

        CC_ERG_CartRequest cartRequest1 = new CC_ERG_CartRequest();
        cartRequest1.storefrontName = CC_ERG_TestData.TEST_STOREFRONT;
        cartRequest1.locale = 'en_US';
        cartRequest1.userCurrency =CC_ERG_TestData.TEST_CURRENCY_CODE;
        cartRequest1.countryCode = 'US';

        cartRequest1.lineItems = new List<CC_ERG_CartRequest.CartLineItem>();

        Test.startTest();

        CC_ERG_AddToCartService.addToCart(null);

        for(ccrz__E_Product__c objProduct: (List<ccrz__E_Product__c>) testData.get(CC_ERG_TestData.TEST_PRODUCTS)){
            CC_ERG_CartRequest.CartLineItem ob1 = new CC_ERG_CartRequest.CartLineItem();
            ob1.sku = objProduct.ccrz__SKU__c;
            ob1.quantity = 1;
            ob1.cartItemId = objProduct.Id;
            cartRequest1.lineItems.add(ob1);
        }

        CC_ERG_AddToCartService.addToCart(cartRequest1);
        Test.stopTest();
    }
}