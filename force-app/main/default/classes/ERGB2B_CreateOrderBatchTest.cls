/**
 * @description       : 
 * @author            : Nandika Sharma
 * @group             : 
 * @last modified on  : 07-08-2022
 * @last modified by  : Nandika Sharma
**/
@isTest
public with sharing class ERGB2B_CreateOrderBatchTest {
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
    }
    @IsTest
    static void createOrderTest(){
        setupTestData(true);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/v1/fetchCart';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        system.runAs((User) testData.get(CC_ERG_TestData.TEST_CHILD_ACC_USER)){
            Integer lastModifiedDate = 1;
            integer lastModifiedTime = 5;
            Datetime cartUpdatedTime = Datetime.now().addMinutes(-lastModifiedTime);
            ccrz__E_Cart__c theCart = CC_ERG_TestData.createCart(true, true, testData);
            theCart.Source__c = 'Ergotron';
            theCart.ccrz__CartStatus__c = 'Open';
            theCart.digitalriverb2b__DR_Payment_State__c = 'Successful';
            theCart.ccrz__ActiveCart__c = false;
            theCart.digitalriverb2b__DR_Cart_Id__c = 'test';
            update theCart;
            ERGB2B_CreateOrderBatch batch = new ERGB2B_CreateOrderBatch();
            batch.failedCartList =  new List<ccrz__E_Cart__c>{theCart};
            batch.errMsgMap =   new Map<String,String>{theCart.Id=>'test'};
            batch.execute(null);
            batch.getFailedCartHtml('', URL.getSalesforceBaseUrl().toExternalForm(), new List<ccrz__E_Cart__c>{theCart});
            batch.createTransactionPayment(theCart,null,ERGB2B_OrderWrapper.parse(ERGB2B_OrderWrapperTest.ORDER_CC_JSON)); 
        }  
        Test.stopTest();     
    }

    @IsTest
    static void createOrderExceptionTest(){
        setupTestData(true);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/v1/fetchCart';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        ERGB2B_OrderWrapperTest.ORDER_JSON = '';
        system.runAs((User) testData.get(CC_ERG_TestData.TEST_CHILD_ACC_USER)){
            ccrz__E_Cart__c theCart = CC_ERG_TestData.createCart(true, true, testData);
            theCart.Source__c = 'Ergotron';
            theCart.ccrz__CartStatus__c = 'Open';
            theCart.digitalriverb2b__DR_Payment_State__c = 'Successful';
            theCart.ccrz__ActiveCart__c = false;
            theCart.digitalriverb2b__DR_Cart_Id__c = 'test';
            update theCart;
            ERGB2B_CreateOrderBatch batch = new ERGB2B_CreateOrderBatch();
            batch.processCart(theCart);
            batch.processCart(null);

        }  
        Test.stopTest();     
    }
      @IsTest
    static void Erg_ConstantsTest(){
        Erg_Constants.Site ='Site';
        Erg_Constants.Customer_Organization ='Customer_Organization';
        Erg_Constants.Party ='Party'; 
        Erg_Constants.eCommerce ='eCommerce';
        Erg_Constants.Americas ='Americas'; 
        Erg_Constants.CustomerAccount ='CustomerAccount'; 
        Erg_Constants.PartyAccount ='PartyAccount'; 
        Erg_Constants.PartyCustomerAccount ='PartyCustomerAccount'; 
        Erg_Constants.Consumer = 'Consumer';
        Erg_Constants.EndUser = 'End User';
        Erg_Constants.Salesforce ='Salesforce';
        Erg_Constants.Order_Submitted ='Order Submitted';
        Erg_Constants.Product ='Product'; 
        Erg_Constants.B2BCommerce ='B2BCommerce';
        Erg_Constants.Ready_For_Sales_Order ='Ready For Sales Order';
        Erg_Constants.Under_Review ='Under Review';
        Erg_Constants.Sales_Order_Created ='Sales Order Created';
        Erg_Constants.Order_Created_Successfully = 'Order Created Successfully';
        Erg_Constants.Not_Started = 'Not Started';
        Erg_Constants.FREIGHT_CHARGE ='FREIGHT-CHARGE';
    }
}