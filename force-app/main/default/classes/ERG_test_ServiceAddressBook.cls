@isTest
public with sharing class ERG_test_ServiceAddressBook {
    public static Map<String, Object> testData;

    public static void setupTestData(Boolean createParentAccount) {
        ccrz__E_Configuration__c theConfig = new ccrz__E_Configuration__c(
        	
        );
        testData = ERG_Test_DataFactory.setupAccountContactUser(createParentAccount, true);
    }
	
	@isTest
	public static void testServiceAddressBook(){
		setupTestData(true);
		Test.startTest();

        SmartyStreets_API__c ss = new SmartyStreets_API__c();
        ss.Name = 'SeedUnitAddressVerify';
        ss.auth_id__c = 'adsmfqmwepm09daasd';
        ss.auth_token__c = '23240kfir8fj8f8';
        insert ss;        
        
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = (String) testData.get(ERG_Test_DataFactory.TEST_STOREFRONT);
        ctx.portalUserId = ((User) testData.get(ERG_Test_DataFactory.TEST_CHILD_ACC_USER)).Id;		
		ctx.effAccountId = ((Account) testData.get(ERG_Test_DataFactory.TEST_CHILD_ACCOUNT)).Id;
        ccrz.cc_CallContext.init(ctx);

        Map<String,Object> addrFetch = ccrz.ccApiAddressBook.fetch(new Map<String,Object>{
			 ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION
			,ccrz.ccApiAddressBook.ACCOUNTID => ctx.effAccountId
		});			

		Test.stopTest();
	}
}