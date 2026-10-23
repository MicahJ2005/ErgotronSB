@isTest
public with sharing class CC_ERG_OrderCreate_CtrlTest {
    
    public static Map<String, Object> testData;

    public static void setupTestData(Boolean createParentAccount) {
        
        SmartyStreets_API__c ss = new SmartyStreets_API__c();
            ss.Name = 'SeedUnitAddressVerify';
            ss.auth_id__c = 'adsmfqmwepm09daasd';
            ss.auth_token__c = '23240kfir8fj8f8';
        insert ss;           
        
        ccrz__E_Configuration__c theConfig = new ccrz__E_Configuration__c(
            
        );
        testData = CC_ERG_Test_DataFactory.setupAccountContactUser(createParentAccount,false);

    }// end of generate test data    
    

    @isTest
    public static void testController() {
        
        setupTestData(true);
        Test.startTest();
        String testCaseid = ( (Case) testData.get(CC_ERG_Test_DataFactory.TEST_CASE) ).id;
        
        Test.setCurrentPageReference(new PageReference('Page.myPage'));
        System.currentPageReference().getParameters().put('caseID', testCaseid);
        
        CC_ERG_OrderCreate controller = new CC_ERG_OrderCreate();
        
        controller.getthePriceListsDropDown();
        controller.gettheOrderTypeDropDown();
        controller.getselectedPriceList();
        
        String selectedPriceList= 'testdata';
        controller.setselectedPriceList(selectedPriceList);
        
        String testerstring = controller.forwardURL; 
        List<Id> testerlist = controller.plIds;
      
        controller.getOrderType();
        
        ID testerID = controller.ThisCaseID;
        
        controller.getPriceListsOptions();
        
        testerstring = 'an order type';
        controller.setOrderType(testerstring);     
        
        controller.createOrUpdateUser();
        
        controller.getGoToThisPLPURL();
       
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = (String) testData.get(CC_ERG_Test_DataFactory.TEST_STOREFRONT);
        User theUser = [SELECT Id FROM User LIMIT 1]; // this should be the user from createOrUpdateUser.
        ctx.portalUserId = theUser.Id;
        //ctx.portalUserId = ((User) testData.get(ERG_Test_DataFactory.TEST_CHILD_ACC_USER)).Id;
        ctx.effAccountId = ((Account) testData.get(CC_ERG_Test_DataFactory.TEST_CHILD_ACCOUNT)).Id;
        ccrz.cc_CallContext.init(ctx);   
        
        ccrz.cc_RemoteActionResult myRAR;        
        
//      String caseId;
//      String priceListId;
        String orderType;       

        List<ccrz__E_Pricelist__c> pls = [select Id from ccrz__E_Pricelist__c];
        
        List<Oracle_Order_Type__c> ord = [SELECT Order_Type_id__c FROM Oracle_Order_Type__c WHERE Salesforce_Order_Type__c = true AND Domestic__c = true  Order By Name];

        String plst = pls[0].id;
        String otype = ord[0].id;
        
        myRAR = CC_Erg_OrderCreate.manageCarts(ctx, testerId, plst, otype);         // This will create a new cart.
        myRAR = CC_Erg_OrderCreate.manageCarts(ctx, testerId, plst, otype);         // This will select the current active cart.
        Test.stopTest();
    } // end of test controller
}// end of class defintion