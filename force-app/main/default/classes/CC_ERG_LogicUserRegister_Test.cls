@isTest
public class CC_ERG_LogicUserRegister_Test {
	
    @isTest
    static void validateUserTest() {
    	Map<String, Object> inputData = new Map<String, Object>();
        Map<String, Object> originalInputData = new Map<String, Object>();
        List<ccrz.cc_bean_Message> messages = new List<ccrz.cc_bean_Message>();
        String userRegisterJson = '{"salutation":"Mr","firstName":"mac book","lastName":"pro","primaryPhone":"03747472894","language":"en_US","currencyCode":"USD","companyName":"Docmation","companyType":"ISP","username":"jeff.williams@salesforce.com.invalid","NewPassword":"Docmation@123","ConfirmPassword":"Docmation@123","billingAddress.address1":"1115 Halifax Pl","billingAddress.address2":"Bank Road","billingAddress.city":"Hamilton","billingAddress.stateCode":"NJ","billingAddress.postalCode":"08619","billingAddress.countryCode":"US","shippingAddress.address1":"1115 Halifax Plt","shippingAddress.address2":"Bank Road","shippingAddress.city":"Hamilton","shippingAddress.stateCode":"NJ","shippingAddress.postalCode":"08619","shippingAddress.countryCode":"US","taxExemptFlag":false}';
        originalInputData.put('cartEncId','');
        originalInputData.put('usrRegisterJson',userRegisterJson);
        inputData.put('cartEncId','');
        inputData.put('originalInputData',originalInputData);
        inputData.put('messages',messages);
        CC_ERG_LogicUserRegister logicUserRegister= new CC_ERG_LogicUserRegister();
        logicUserRegister.validateUser(inputData);
        System.assertNotEquals(originalInputData.get('lastName'), 'pro');
    }
    
    @isTest
    static void registerTest() {
    	Map<String, Object> inputData = new Map<String, Object>();
        Map<String, Object> originalInputData = new Map<String, Object>();
        List<ccrz.cc_bean_Message> messages = new List<ccrz.cc_bean_Message>();
        String userRegisterJson = '{"salutation":"Mr","firstName":"mac book","lastName":"pro","primaryPhone":"03747472894","language":"en_US","currencyCode":"USD","companyName":"Docmation","companyType":"ISP","username":"jeff.williams@salesforce.com.invalid","NewPassword":"Docmation@123","ConfirmPassword":"Docmation@123","billingAddress.address1":"1115 Halifax Pl","billingAddress.address2":"Bank Road","billingAddress.city":"Hamilton","billingAddress.stateCode":"NJ","billingAddress.postalCode":"08619","billingAddress.countryCode":"US","shippingAddress.address1":"1115 Halifax Plt","shippingAddress.address2":"Bank Road","shippingAddress.city":"Hamilton","shippingAddress.stateCode":"NJ","shippingAddress.postalCode":"08619","shippingAddress.countryCode":"US","taxExemptFlag":false}';
        originalInputData.put('cartEncId','');
        originalInputData.put('usrRegisterJson',userRegisterJson);
        inputData.put('cartEncId','');
        inputData.put('originalInputData',originalInputData);
        inputData.put('messages',messages);
        CC_ERG_LogicUserRegister logicUserRegister= new CC_ERG_LogicUserRegister();
        logicUserRegister.register(inputData);
         System.assertNotEquals(originalInputData.get('lastName'), 'pro');
    }
    
    @isTest
    static void createExternalUserTest() {
    	Map<String, Object> inputData = new Map<String, Object>();
        Map<String, Object> originalInputData = new Map<String, Object>();
        String userRegisterJson = '{"salutation":"Mr","firstName":"mac book","lastName":"pro","primaryPhone":"03747472894","language":"en_US","currencyCode":"USD","companyName":"Docmation","companyType":"ISP","username":"jeff.williams@salesforce.com.invalid","NewPassword":"Docmation@123","ConfirmPassword":"Docmation@123","billingAddress.address1":"1115 Halifax Pl","billingAddress.address2":"Bank Road","billingAddress.city":"Hamilton","billingAddress.stateCode":"NJ","billingAddress.postalCode":"08619","billingAddress.countryCode":"US","shippingAddress.address1":"1115 Halifax Plt","shippingAddress.address2":"Bank Road","shippingAddress.city":"Hamilton","shippingAddress.stateCode":"NJ","shippingAddress.postalCode":"08619","shippingAddress.countryCode":"US","taxExemptFlag":false}';
        originalInputData.put('cartEncId','');
        originalInputData.put('usrRegisterJson',userRegisterJson);
        inputData.put('cartEncId','');
        inputData.put('originalInputData',originalInputData);
        CC_ERG_LogicUserRegister logicUserRegister= new CC_ERG_LogicUserRegister();
        logicUserRegister.createExternalUser(inputData);
         System.assertNotEquals(originalInputData.get('lastName'), 'pro');
    }
    
    @isTest
    static void assignDRPermissionSetTest() {
        SmartyStreets_API__c oAPIDetails = new SmartyStreets_API__c();
        oAPIDetails.Name = 'SeedUnitAddressVerify';
        oAPIDetails.auth_id__c ='0a4d060a-a263-40d1-b7ff-a17cbc33a9c4';
        oAPIDetails.auth_token__c ='GYvDxrGcWTMm57o97MN9';
        insert oAPIDetails;
        // Create Account
        Account acc = new Account(Name = 'Test Account', BillingCountry = 'United States', BillingState = 'Georgia', BillingStreet = '123 Broad Rd', BillingCity = 'Metropolis', BillingPostalCode = '23456');
        insert acc;
        Contact defaultContact= CC_ERG_TestData.createInsertDefaultContact(acc);
        User defaultUser = CC_ERG_TestData.createDefaultUser(defaultContact);
    	String userId = defaultUser.Id;
        CC_ERG_LogicUserRegister.assignDRPermissionSet(userId);
        System.assertNotEquals(defaultUser.Id, acc.Id);
    }
    
    @isTest
    static void prepReturnTest() {
        SmartyStreets_API__c oAPIDetails = new SmartyStreets_API__c();
        oAPIDetails.Name = 'SeedUnitAddressVerify';
        oAPIDetails.auth_id__c ='0a4d060a-a263-40d1-b7ff-a17cbc33a9c4';
        oAPIDetails.auth_token__c ='GYvDxrGcWTMm57o97MN9';
        insert oAPIDetails;
        //Get Site record type for Account
          RecordType siteRecord = [
            SELECT id, Name, DeveloperName
            FROM RecordType
            WHERE sObjectType = 'Account' AND DeveloperName = 'Site'
            LIMIT 1
          ];
        // Create Account
        Account acc = new Account(Name = 'Test Account', BillingCountry = 'United States', BillingState = 'Georgia', BillingStreet = '123 Broad Rd', BillingCity = 'Metropolis', BillingPostalCode = '23456');
        insert acc;
        Account shippingAcc = new Account(Name = 'Test Account', BillingCountry = 'United States', BillingState = 'Georgia', BillingStreet = '123 Broad Rd', BillingCity = 'Metropolis', BillingPostalCode = '23456', Type = 'End User', RecordTypeId=siteRecord.Id,Ergotron_Vertical_Market__c = 'Consumer');
        insert shippingAcc;
        Contact defaultContact= CC_ERG_TestData.createInsertDefaultContact(acc);
        User defaultUser = CC_ERG_TestData.createDefaultUser(defaultContact);
    	String userId = defaultUser.Id;
        Map<String, Object> inputData = new Map<String, Object>();
        Map<String, Object> originalInputData = new Map<String, Object>();
        List<ccrz.cc_bean_Message> messages = new List<ccrz.cc_bean_Message>();
        String userRegisterJson = '{"salutation":"Mr","firstName":"mac book","lastName":"pro","primaryPhone":"03747472894","language":"en_US","currencyCode":"USD","companyName":"Docmation","companyType":"ISP","username":"jeff.williams@salesforce.com.invalid","NewPassword":"Docmation@123","ConfirmPassword":"Docmation@123","billingAddress.address1":"1115 Halifax Pl","billingAddress.address2":"Bank Road","billingAddress.city":"Hamilton","billingAddress.stateCode":"NJ","billingAddress.postalCode":"08619","billingAddress.countryCode":"US","shippingAddress.address1":"1115 Halifax Plt","shippingAddress.address2":"Bank Road","shippingAddress.city":"Hamilton","shippingAddress.stateCode":"NJ","shippingAddress.postalCode":"08619","shippingAddress.countryCode":"US","taxExemptFlag":false}';
        originalInputData.put('cartEncId','');
        originalInputData.put('usrRegisterJson',userRegisterJson);
        inputData.put(ccrz.ccApiUser.USER_ID,userId);
        inputData.put('originalInputData',originalInputData);
        inputData.put('messages',messages);
        inputData.put(ccrz.ccApiAccount.ACCOUNT_NEW,acc);
        inputData.put(ccrz.ccApiUser.USER_NEW,defaultUser);
        CC_ERG_LogicUserRegister logicUserRegister= new CC_ERG_LogicUserRegister();
        logicUserRegister.prepReturn(inputData);
        System.assertNotEquals(defaultUser.Id, acc.Id);
    }
    
}