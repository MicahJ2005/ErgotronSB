@isTest
public class ccErgoServiceAddressBookTest {
    
    @TestSetup
    static void setupData() {
        CC_ERG_TestData.initCCSettings();
    }
    @isTest
    public static void  ccErgoServiceAddressBookTest() {
        Test.startTest();
        SmartyStreets_API__c ss = new SmartyStreets_API__c();
        ss.Name = 'SeedUnitAddressVerify';
        ss.auth_id__c = 'adsmfqmwepm09daasd';
        ss.auth_token__c = '23240kfir8fj8f8';
        insert ss;           
        // ccrz__E_Configuration__c theConfig = new ccrz__E_Configuration__c();
        // testData = CC_ERG_TestData.setupAccountContactUser(createParentAccount,true);

        ccrz.cc_CallContext.isGuest = false;
        Map<String, Object> inputData = new Map<String, Object>();
        Account acct = new Account(Name = 'Default Test Account', BillingStreet ='10705 McCool Dr E' //, BillingCity = 'Burnsville',
        // BillingCountryCode = 'US', BillingCountry = 'United States', BillingPostalCode = '55337', BillingStateCode = 'MN'
        ); 
        insert acct;

        Account acct1 = new Account(Name = 'Default Test Account1', ParentID = acct.Id
        //, BillingStreet ='10707 McCool Dr E', BillingCity = 'Burnsville',
        // BillingCountryCode = 'US', BillingCountry = 'United States', BillingPostalCode = '55337', BillingStateCode = 'MN'
        ); 
        insert acct1;
        
        Contact cont = new Contact(FirstName = 'firstName', LastName ='lastContact', AccountId = acct.Id,Email = 'testdata@drtest.com');
        insert cont;

        ccrz.cc_CallContext.currAccountId = acct1.Id;
        ccrz.cc_CallContext.currContact = cont;
        ccErgoServiceAddressBook adrsBook = new ccErgoServiceAddressBook();
        adrsBook.fetch(inputData);
        Test.stopTest();


    }
}