/**
 * Test class for cls_CreateApprovalURL
 * @author DCS
 * @date 5/18/2016
 */
@isTest
private class cls_test_CreateApprovalURL {
    
    static testmethod void testGenerateApprovalURL(){
        
        // Create Users
        Profile objProfile = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User objManager = new User(
            Alias = 'etstmgr', 
            Email='standardmanager@ergotron.test', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = objProfile.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='standardmanager@ergotron.test'
        );
        insert objManager;

        User objUser = new User(
            Alias = 'etstusr', 
            Email='standarduser@ergotron.test', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = objProfile.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='standarduser@ergotron.test',
            ManagerId=objManager.Id
        );

        System.runAs(objUser) {
            //Create an account first
            Account acct = new Account(
                Name='Test Account'
                ,Type = 'Architect'
                ,ShippingStreet = '111 1st Ave'
                ,ShippingCity = 'Rochester'
                ,ShippingState = 'Minnesota'
                ,ShippingPostalCode = '55906'
                ,ShippingCountryCode = 'US'
                ,BillingStreet = '111 1st Ave'
                ,BillingCity = 'Rochester'
                ,BillingState = 'Minnesota'
                ,BillingPostalCode = '55906'
                ,BillingCountryCode = 'US'
            );
            insert acct;
            
            System.Assert(acct.id != null, 'Oops, the Acct was not created correctly');
     
            Opportunity opp = Test_Environment_Utility.createInsertOpportunity('Demand Input', acct, 'Seeding', System.Today());
            System.Assert(opp.Id != null, 'Oops, the Opp was not created correctly');
            opp.Is_this_a_rollout__c = 'No';
            opp.Business_Justification__c = 'Business Justification';
            Update opp;

            cls_CmpApprovalURL ctrl = new  cls_CmpApprovalURL();
            
            Test.startTest();

            ctrl.recId = opp.Id;
            Approval.ProcessSubmitRequest req1 =
                new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(opp.id);
            // Submit the approval request
            Approval.ProcessResult result = Approval.process(req1);
            String url = ctrl.urlStr;
            Test.stopTest();
            System.assert(!String.isEmpty(url));
        }


            
    }
}