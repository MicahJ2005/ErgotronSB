@isTest
public with sharing class CC_Erg_DifAdddrSelectorTest {
    /*
     * Salesforce 2020
     *  Author: gvansteeter
     *    Date: 2020.05.12
     * Purpose: Test class to cover functionality of the cc_erg_DiffAddrSelector class
     */     
    public static Map<String,Object> testData;
    
    public static void setupTestData(Boolean createParentAccount) {
        
        SmartyStreets_API__c ss = new SmartyStreets_API__c();
            ss.Name = 'SeedUnitAddressVerify';
            ss.auth_id__c = 'adsmfqmwepm09daasd';
            ss.auth_token__c = '23240kfir8fj8f8';
        insert ss;           
        
        ccrz__E_Configuration__c theConfig = new ccrz__E_Configuration__c(
            
        );
        testData = CC_ERG_Test_DataFactory.setupAccountContactUser(createParentAccount,true);

    }// end of generate test data    
    
    @isTest
    public static void testDiffAddrSelector() {
        setupTestData(true);
        Test.startTest();
        // create a cart
        ccrz__E_Cart__c theCart = CC_ERG_Test_DataFactory.createCart(true, true, testData);
        
        // Update the TEST_CASE with the cart.
        Case theCase = ((Case) testData.get(CC_ERG_Test_DataFactory.TEST_CASE));
        theCase.CC_CartId__c = theCart.Id;
        update theCase;
        

        //get a different address
        //String searchString = ERG_Test_DataFactory.TEST_PARENT_ACCOUNT;
        String searchString = ((Account) testData.get(CC_ERG_Test_DataFactory.TEST_PARENT_ACCOUNT)).Name;
        Map<ID,String> acctsMap = cc_erg_diffAddrSelector.getMapofAccounts(searchString);
        // get the account Id out of the map.
        Set<ID> mySet = new Set<ID>();
        mySet = acctsMap.keySet();
        ID theAccountId = new List<Id>(mySet).get(0);
        // use it to update the billto address
        Map<Id,String> result = cc_erg_diffAddrSelector.updateCartAddress(theAccountId, 'BillTo', theCart.Id);
        // use it to update the shipto address
        result = cc_erg_diffAddrSelector.updateCartAddress(theAccountId, 'ShipTo', theCart.Id);
        
        // Delete the cart in order to test the trigger
        delete theCart;
        Test.stopTest();
    }
}