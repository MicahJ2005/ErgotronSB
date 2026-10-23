@isTest
public with sharing class CC_ERG_ProductSearchServiceTest {
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
    static void processRequestTest() {
        setupTestData(true, 'SeedUnitAddressVerify');
        System.debug('@@  ==> ' + testData);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/v1/fetchCart';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        CC_ERG_ProductRequest productRequest = new CC_ERG_ProductRequest();
        List<String> specTypelst = new List<String>{
                'Call Forwarding', 'test2'
        };
        productRequest.specType = specTypelst;
        List<String> featureslst = new List<String>{
                'Call Center', 'test2'
        };
        productRequest.features = featureslst;
        productRequest.zipCode = '248001';
        productRequest.jurisdictionCode = '007';
        productRequest.storefrontName = CC_ERG_Test_DataFactory.TEST_STOREFRONT;
        productRequest.locale = 'en_US';
        productRequest.userCurrency =CC_ERG_Test_DataFactory.TEST_CURRENCY_CODE;
        productRequest.countryCode = 'US';

        List<ccrz__E_Product__c> products = (List<ccrz__E_Product__c>) testData.get(CC_ERG_Test_DataFactory.TEST_PRODUCTS);
        for(ccrz__E_Product__c objProduct: products){
            CC_ERG_CartRequest.CartLineItem ob1 = new CC_ERG_CartRequest.CartLineItem();
            productRequest.sku = objProduct.ccrz__SKU__c;
        }

        
        Test.startTest();
        CC_ERG_ProductSearchService.processRequest(null);
        CC_ERG_ProductSearchService.processRequest(productRequest);
        CC_ERG_ProductSearchService.fetchProductBySKU(productRequest);

        productRequest.storefrontName = '';
        CC_ERG_ProductSearchService.processRequest(productRequest);
        CC_ERG_ProductSearchService.processRequest(null);
        CC_ERG_ProductSearchService.fetchProductBySKU(null);
        Test.stopTest();
    }
}