@isTest
public class CC_ERG_LogicAccountCreateAccount_Test {
    
    @TestSetup
    static void setupData() {
        CC_ERG_TestData.initCCSettings();
    }

    @isTest
    static void createAccount_Test(){
        SmartyStreets_API__c oAPIDetails = new SmartyStreets_API__c();
        oAPIDetails.Name = 'SeedUnitAddressVerify';
        oAPIDetails.auth_id__c ='0a4d060a-a263-40d1-b7ff-a17cbc33a9c4';
        oAPIDetails.auth_token__c ='GYvDxrGcWTMm57o97MN9';
        insert oAPIDetails; 
	    Map<String, Object> inputData = new Map<String, Object>();
        Map<String, Object> originalInputData = new Map<String, Object>();
        // Create Account
        Account acc = new Account(Name = 'Test Account', BillingCountryCode = 'US', BillingStateCode = 'GA', 
                             BillingStreet = '123 Broad Rd', BillingCity = 'Metropolis', 
                             BillingPostalCode = '23456',
                             ccrz__SourceSystem__c ='CloudCraze');
        insert acc;
        inputData.put(ccrz.ccApiAccount.ACCOUNT_NEW, acc);
        inputData.put(ccrz.ccApi.API_VERSION, 10);
        CC_ERG_LogicAccountCreateAccount logicCreateAccount = new CC_ERG_LogicAccountCreateAccount();
        Map<String, Object> output = logicCreateAccount.createAccount(inputData);
        System.assertNotEquals(null, output);      
    }
    
    @isTest
    static void createAccount_NewTest(){
        SmartyStreets_API__c oAPIDetails = new SmartyStreets_API__c();
        oAPIDetails.Name = 'SeedUnitAddressVerify';
        oAPIDetails.auth_id__c ='0a4d060a-a263-40d1-b7ff-a17cbc33a9c4';
        oAPIDetails.auth_token__c ='GYvDxrGcWTMm57o97MN9';
        insert oAPIDetails; 
        List<RecordType>  recLst = [SELECT id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Account'];
        String siteRecordId;
        String customerRecordId;
        String partyRecordId;
    
        if (recLst != null && recLst.size() > 0) {
          for (RecordType recType : recLst) {
            if (recType.DeveloperName == 'Site') {
              siteRecordId = recType.id;
            }
            if (recType.DeveloperName == 'Customer_Organization') {
              customerRecordId = recType.id;
            }
            if (recType.DeveloperName == 'Party') {
              partyRecordId = recType.id;
            }
          }
        }
        
	    Map<String, Object> inputData = new Map<String, Object>();
        Map<String, Object> originalInputData = new Map<String, Object>();
        //Insert User
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'B2B Storefront' LIMIT 1];
        
        Account acct = new Account(Name = 'Default Test Account'); 
        insert acct;
        
        Contact cont = new Contact(FirstName = 'firstName', LastName ='lastContact', AccountId = acct.Id,Email = 'testdata@drtest.com');
        insert cont;
        
        User testUser = new User(Alias = 'drtest', Email='druser@testorg.com', EmailEncodingKey='UTF-8',
                                FirstName='FirstlName', LastName='LastlName', LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US', ProfileId = profile.Id, ContactId = cont.Id,
                                TimeZoneSidKey='America/Los_Angeles', UserName='druserName@testorg.com');
        insert testUser;
        // Create Account
        Account acc = new Account(Name = 'Test Account', BillingCountryCode = 'US', BillingStateCode = 'GA', 
                             BillingStreet = '123 Broad Rd', BillingCity = 'Metropolis', 
                             BillingPostalCode = '23456',
                             ccrz__SourceSystem__c ='CloudCraze');
        insert acc;
        inputData.put(ccrz.ccApiAccount.ACCOUNT_NEW, acc);
        inputData.put(ccrz.ccApi.API_VERSION, 10);
        CC_ERG_LogicAccountCreateAccount logicCreateAccount = new CC_ERG_LogicAccountCreateAccount();
        Account partyAcc = CC_ERG_LogicAccountCreateAccount.createAccount(acc,testUser.Id,true,'',partyRecordId,true);
        System.assertNotEquals(null, partyAcc);      
    }
    @isTest
    static void createAccount_SameAddressTest(){
        //Insert User
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Minimum Access - Salesforce' LIMIT 1];
         User u = [SELECT Id, LastName, Username FROM User where profile.Name = 'System Administrator' AND isActive = true limit 1];  
        system.runAs(u){
        User testUser = new User(Alias = 'drtest', Email='druser@testorg.com', EmailEncodingKey='UTF-8',
                                  FirstName='FirstlName', LastName='LastlName', LanguageLocaleKey='en_US',
                                  LocaleSidKey='en_US', ProfileId = profile.Id, 
                                  TimeZoneSidKey='America/Los_Angeles', UserName='druserName@testorg.com');
        insert testUser;
        
          SmartyStreets_API__c oAPIDetails = new SmartyStreets_API__c();
          oAPIDetails.Name = 'SeedUnitAddressVerify';
          oAPIDetails.auth_id__c ='0a4d060a-a263-40d1-b7ff-a17cbc33a9c4';
          oAPIDetails.auth_token__c ='GYvDxrGcWTMm57o97MN9';
          insert oAPIDetails; 
          List<RecordType>  recLst = [SELECT id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Account'];
          String siteRecordId;
          String customerRecordId;
          String partyRecordId;
      
          if (recLst != null && recLst.size() > 0) {
            for (RecordType recType : recLst) {
              if (recType.DeveloperName == 'Site') {
                siteRecordId = recType.id;
              }
              if (recType.DeveloperName == 'Customer_Organization') {
                customerRecordId = recType.id;
              }
              if (recType.DeveloperName == 'Party') {
                partyRecordId = recType.id;
              }
            }
          }
          
          Map<String, Object> inputData = new Map<String, Object>();
          Map<String, Object> originalInputData = new Map<String, Object>();
          
          // Create Account
          Account acc = new Account(Name = 'Test Account', BillingCountryCode = 'US', BillingStateCode = 'GA', 
                                BillingStreet = '123 Broad Rd', BillingCity = 'Metropolis', 
                                BillingPostalCode = '23456',
                                ccrz__SourceSystem__c ='CloudCraze');
          insert acc;
          inputData.put(ccrz.ccApiAccount.ACCOUNT_NEW, acc);
          inputData.put(ccrz.ccApi.API_VERSION, 10);
          CC_ERG_LogicAccountCreateAccount logicCreateAccount = new CC_ERG_LogicAccountCreateAccount();
          Account partyAccount = CC_ERG_LogicAccountCreateAccount.creatAccountHeirarchy(acc,testUser.Id,false);
          Account partyAcc = CC_ERG_LogicAccountCreateAccount.createAccount(acc,testUser.Id,false,'',partyRecordId,false);
          System.assertNotEquals(null, partyAcc); 
        }
         
    }
}