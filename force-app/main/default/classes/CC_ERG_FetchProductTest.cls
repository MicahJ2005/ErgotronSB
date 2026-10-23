@isTest
public with sharing class CC_ERG_FetchProductTest {
    
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
    static void processRequestTest() {
        setupTestData(true);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/v1/fetchCart';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        CC_ERG_ProductRequest productRequest2 = new CC_ERG_ProductRequest();
        List<String> specTypelst = new List<String>{
                'Call Forwarding', 'test2'
        };
        productRequest2.specType = specTypelst;
        List<String> featureslst = new List<String>{
                'Call Center', 'test2'
        };
        productRequest2.features = featureslst;
        productRequest2.zipCode = '248001';
        productRequest2.jurisdictionCode = '007';
        productRequest2.storefrontName = CC_ERG_Test_DataFactory.TEST_STOREFRONT;
        productRequest2.locale = 'en_US';
        productRequest2.userCurrency =CC_ERG_Test_DataFactory.TEST_CURRENCY_CODE;
        productRequest2.countryCode = 'US';

        for(ccrz__E_Product__c objProduct: (List<ccrz__E_Product__c>) testData.get(CC_ERG_Test_DataFactory.TEST_PRODUCTS)){
            CC_ERG_CartRequest.CartLineItem ob1 = new CC_ERG_CartRequest.CartLineItem();
            productRequest2.sku = objProduct.ccrz__SKU__c;
            productRequest2.quantity = 1;
        }

        
        Test.startTest();
        CC_ERG_FetchProduct.processRequest(productRequest2);
        CC_ERG_FetchProduct.fetchAllProducts(productRequest2);
        productRequest2.storefrontName = '';
        CC_ERG_FetchProduct.processRequest(productRequest2);
        CC_ERG_ProductRequest obClass1 = new CC_ERG_ProductRequest();
        obClass1 = null;
        CC_ERG_FetchProduct.processRequest(obClass1);
        CC_ERG_FetchProduct.fetchAllProducts(productRequest2);
        Test.stopTest();
    }
}