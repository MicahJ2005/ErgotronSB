@isTest
public class CC_ERG_static_utils_Test {
	public static Map<String, Object> testData;

    public static void setupTestData(Boolean createParentAccount) {
        ccrz__E_Configuration__c theConfig = new ccrz__E_Configuration__c(
          
        );
        testData = ERG_Test_DataFactory.setupAccountContactUser(createParentAccount, true);
    }
    @isTest
    public static void accFilter_Test() {
        setupTestData(true);
        SmartyStreets_API__c ss = new SmartyStreets_API__c();
        ss.Name = 'SeedUnitAddressVerify';
        ss.auth_id__c = 'adsmfqmwepm09daasd';
        ss.auth_token__c = '23240kfir8fj8f8';
        insert ss;  
        
    	CC_ERG_static_utils.accFilter(new Map<String, Object>(), 'string', 'string', 'string');
        String priceListId = CC_ERG_static_utils.pricelistId;
    }
    @isTest
    public static void deactivateUser_Test() {
        setupTestData(true);
        SmartyStreets_API__c ss = new SmartyStreets_API__c();
        ss.Name = 'SeedUnitAddressVerify';
        ss.auth_id__c = 'adsmfqmwepm09daasd';
        ss.auth_token__c = '23240kfir8fj8f8';
        insert ss;  
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    	CC_ERG_static_utils.deactivateUser(thisUser.Id);
        String priceListId = CC_ERG_static_utils.pricelistId;
    }
}