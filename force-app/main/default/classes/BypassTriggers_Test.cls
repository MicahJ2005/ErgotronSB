@isTest
public with sharing class BypassTriggers_Test {
    @isTest
    public static void BypassTriggers_Positive_Test_1() {
        ProcessSwitches__c setting = new ProcessSwitches__c();
        setting.Bypass_All_Triggers__c = false;
        setting.Bypass_Objects__c = 'Case';
        insert setting;

        Test.startTest();
        Boolean result = BypassTriggers.bypass('Case');
        Test.stopTest();

        Assert.areEqual(true, result, 'Case should have been bypassed.');
    }

    @isTest
    public static void BypassTriggers_Positive_Test_2() {
        ProcessSwitches__c setting = new ProcessSwitches__c();
        setting.Bypass_All_Triggers__c = false;
        setting.Bypass_Objects__c = 'Case;Lead';
        insert setting;

        Test.startTest();
        Boolean result = BypassTriggers.bypass('Lead');
        Test.stopTest();

        Assert.areEqual(true, result, 'Lead should have been bypassed.');
    }

    @isTest
    public static void BypassTriggers_Positive_Test_3() {
        ProcessSwitches__c setting = new ProcessSwitches__c();
        setting.Bypass_All_Triggers__c = true;
        insert setting;

        Test.startTest();
        Boolean result = BypassTriggers.bypass('Case');
        Test.stopTest();

        Assert.areEqual(true, result, 'Case should have been bypassed.');
    }

    @isTest
    public static void BypassTriggers_Negative_Test_1() {
        Test.startTest();
        Boolean result = BypassTriggers.bypass('Case');
        Test.stopTest();

        Assert.areEqual(false, result, 'Case should not have been bypassed.');
    }

    @isTest
    public static void BypassTriggers_Negative_Test_2() {
        ProcessSwitches__c setting = new ProcessSwitches__c();
        setting.Bypass_All_Triggers__c = false;
        insert setting;

        Test.startTest();
        Boolean result = BypassTriggers.bypass('Case');
        Test.stopTest();

        Assert.areEqual(false, result, 'Case should not have been bypassed.');
    }

    @isTest
    public static void BypassTriggers_Trigger_Context() {
        ProcessSwitches__c setting = new ProcessSwitches__c();
        setting.Bypass_All_Triggers__c = true;
        insert setting;

        Case objCase = new Case();
        objCase.Status = 'New';
        objCase.Subject = 'Test Subject';
        objCase.Build_Warehouse__c = 'DO1';

        Test.startTest();
        insert objCase;
        Test.stopTest();

        //coverage only
    }

    @isTest
    public static void flowBypassObject_Test() {
        ProcessSwitches__c setting = new ProcessSwitches__c();
        setting.Bypass_All_Triggers__c = false;
        setting.Bypass_Objects__c = 'Case;Lead';
        insert setting;

      

        Test.startTest();
        List<Boolean> result = BypassTriggers.flowBypassObject(new List<String>{'case'});
        Test.stopTest();


        Assert.areEqual(true,result[0], 'Case should have been bypassed.');
        //coverage only
    }
}