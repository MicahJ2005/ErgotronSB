@isTest
public with sharing class CC_ERG_FetchCartServiceTest {

    public static Map<String, Object> testData;

    public static void setupTestData(Boolean createParentAccount) {
        SmartyStreets_API__c ss = new SmartyStreets_API__c();
        ss.Name = 'SeedUnitAddressVerify';
        ss.auth_id__c = 'adsmfqmwepm09daasd';
        ss.auth_token__c = '23240kfir8fj8f8';
        insert ss;           
        ccrz__E_Configuration__c theConfig = new ccrz__E_Configuration__c();
        testData = CC_ERG_TestData.setupAccountContactUser(createParentAccount,true);
    }

    @isTest
    static void fetchCartTest() {
        setupTestData(true);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/v1/fetchCart';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        system.runAs((User) testData.get(CC_ERG_TestData.TEST_CHILD_ACC_USER)){
            
            ccrz__E_Cart__c theCart = CC_ERG_TestData.createCart(true, true, testData);

            CC_ERG_CartRequest cartRequest= new CC_ERG_CartRequest();
            cartRequest.storefrontName = CC_ERG_TestData.TEST_STOREFRONT;
            cartRequest.locale = 'en_US';
            cartRequest.userCurrency =CC_ERG_TestData.TEST_CURRENCY_CODE;
            cartRequest.countryCode = 'US';
            cartRequest.cartId = theCart.Id ;

            System.debug('@@ ==> ' + theCart.Id);
            Test.startTest();
            CC_ERG_FetchCartService.fetchCart(null);
            CC_ERG_FetchCartService.fetchCart(cartRequest);

            for(ccrz__E_Product__c objProduct: (List<ccrz__E_Product__c>) testData.get(CC_ERG_TestData.TEST_PRODUCTS)){
                ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c();
                cartItem.ccrz__Cart__c = theCart.Id;
                cartItem.ccrz__Quantity__c = 1.0;
                cartItem.ccrz__Price__c = 11.0;
                cartItem.ccrz__Product__c = objProduct.Id;
                insert cartItem;
            }

            CC_ERG_CartHelper.getCartItems(theCart);
            System.debug('@@ ==> ' + cartRequest.cartId);
            CC_ERG_FetchCartService.fetchCart(cartRequest);
            CC_ERG_CartManager.createCart(CC_ERG_TestData.TEST_STOREFRONT);

            Test.stopTest();
        }
    }
}