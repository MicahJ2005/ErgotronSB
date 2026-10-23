@isTest
private class EnhancedNoteMigrationBatchTest {

    @TestSetup
    static void makeData(){

        Web_Service_Details__c oWebService = Test_Environment_Utility.createInsertWebServiceDetails('Territory Lookup');

        //create leads
        List<Lead> leads = new List<Lead>();
        String recType = 'Ergotron Standard Lead';
        for (Integer i = 0; i < 10; i++) {
            Lead l = new Lead();
            l.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(recType).getRecordTypeId();
            l.lastname = 'Lead ' + i + ' ' + Datetime.now();
            leads.add(l);
        }
        insert leads;

        // Create Enhanced_Note_Migration_Staging__c records for leads
        List<Enhanced_Note_Migration_Staging__c> enmsList = new List<Enhanced_Note_Migration_Staging__c>();

        for (Lead l : leads) {
            Enhanced_Note_Migration_Staging__c enms = new Enhanced_Note_Migration_Staging__c();
            enms.Target_Record_Id__c = l.Id;
            enms.Note_Title__c = 'Lead Note ' + l.Id;
            enms.Note_Content__c = Datetime.now() + ' Test note for lead ' + l.Id;
            enms.Processing_Status__c = 'Pending';
            enmsList.add(enms);
        }
        insert enmsList;
    }

    @isTest
    static void myUnitTest() {
        // TO DO: implement unit test
        Test.startTest();
        EnhancedNoteMigrationBatchLauncher.runBatch();
        Test.stopTest();
        System.assertEquals(10, [select count() from Enhanced_Note_Migration_Staging__c where Processing_Status__c = 'Processed']);

    }

    static void errorTest() {
        // Create a staging record with invalid Target_Record_Id__c to simulate error
        Enhanced_Note_Migration_Staging__c badStage = [select id from Enhanced_Note_Migration_Staging__c limit 1];
        badStage.Target_Record_Id__c = '123456789012345678';
        update badStage;

        Test.startTest();
        EnhancedNoteMigrationBatchLauncher.runBatch();
        Test.stopTest();
        Enhanced_Note_Migration_Staging__c result = [SELECT Processing_Status__c FROM Enhanced_Note_Migration_Staging__c WHERE Id = :badStage.Id LIMIT 1];
        System.assertEquals('Error', result.Processing_Status__c);
        }
}