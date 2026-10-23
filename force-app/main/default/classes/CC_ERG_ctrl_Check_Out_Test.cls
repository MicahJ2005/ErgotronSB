@isTest
public without sharing class CC_ERG_ctrl_Check_Out_Test {
    
    public static Map<String, Object> testData;

    public static void setupTestData(Boolean createParentAccount) {
        
        SmartyStreets_API__c ss = new SmartyStreets_API__c();
            ss.Name = 'SeedUnitAddressVerify';
            ss.auth_id__c = 'adsmfqmwepm09daasd';
            ss.auth_token__c = '23240kfir8fj8f8';
        insert ss;           
        ccrz__E_Configuration__c theConfig = new ccrz__E_Configuration__c(
            
        );
        testData = CC_ERG_Test_DataFactory.setupAccountContactUser(createParentAccount,true);
        ccrz__E_Cart__c cart = new ccrz__E_Cart__c(ccrz__EncryptedId__c = 'test',Payment_Reference__c = 'test');
        insert cart;
    }// end of generate test data  

    @isTest
    public static void doATPForStore() {
        setupTestData(true);
		ccrz__E_Cart__c cart = [SELECT Id,ccrz__EncryptedId__c FROM ccrz__E_Cart__c LIMIT 1];
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = (String) testData.get(CC_ERG_Test_DataFactory.TEST_STOREFRONT);
        ctx.portalUserId = ((User) testData.get(CC_ERG_Test_DataFactory.TEST_CHILD_ACC_USER)).Id;
        ctx.effAccountId = ((Account) testData.get(CC_ERG_Test_DataFactory.TEST_CHILD_ACCOUNT)).Id;
        ctx.currentCartId = cart.ccrz__EncryptedId__c;
        ccrz.cc_CallContext.init(ctx);

        CC_ERG_ctrl_Check_Out  checkout = new CC_ERG_ctrl_Check_Out();

        CC_ERG_ctrl_Check_Out.doATPForStore(ctx, '2321');
        CC_ERG_ctrl_Check_Out.updatecart(ctx, 'US', '2321', '1');



        String currCartENCID;
        Map<String, Object> addToCartResult = ccrz.ccApiCart.addTo(new Map<String, Object>{
                ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                ccrz.ccApiCart.LINE_DATA => new List<Map<String, Object>>{
                        new Map<String, Object>{
                                ccrz.ccApiCart.LINE_DATA_SKU => CC_ERG_Test_DataFactory.TEST_SKU + 1,
                                ccrz.ccApiCart.LINE_DATA_QUANTITY => 3
                        }
                }
        });

        currCartENCID = (String) addToCartResult.get(ccrz.ccApiCart.CART_ENCID);

        CC_ERG_ctrl_Check_Out.updatecartOwner(currCartENCID);
}
    
    /**
     * @author R1
     * @description Test class for fileUpload method
    **/
    @isTest
    static void fileUploadTest(){
        setupTestData(true);
        User user = (User) testData.get(CC_ERG_Test_DataFactory.TEST_CHILD_ACC_USER);
        System.runAs(user){
            Test.startTest();
            Boolean response = CC_ERG_ctrl_Check_Out.fileUpload('test','testbase64',user.Id);
            Test.stopTest();
            Assert.areEqual(false,response,'fileUploadTest assertion failed');
        }
    }
    
    /**
     * @author R1
     * @description Test class for fileUpload method - exception case
    **/
    @isTest
    static void fileUploadTestCase2(){
        Test.startTest();
        Boolean response = CC_ERG_ctrl_Check_Out.fileUpload('','','');
        Test.stopTest();
       	Assert.areEqual(false,response,'fileUploadTestCase2 assertion failed');
    }
}