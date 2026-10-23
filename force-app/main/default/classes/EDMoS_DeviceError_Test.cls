@isTest
public class EDMoS_DeviceError_Test {

    @TestSetup
    static void dataSetup(){
        case c = new case();
        c.Device_Error__c = '{\"errorCode1\":\"Description1\",\"errorCode2\":\"Description2\",\"errorCode3\":\"Description3\"}';
        c.Alert_Type__c = 'Operational';
        insert c;
    }
  
    @isTest
    static void test1(){
        case c1 = [select id from case where Alert_Type__c = 'Operational' limit 1];
        EDMoS_DeviceErrorController errors = new EDMoS_DeviceErrorController();
        errors.caseId = c1.Id;
        List<String> errList = errors.deviceErrorList;
        System.debug('::: Error List ' + errList);
        System.assertEquals('(errorCode1: Description1, errorCode2: Description2, errorCode3: Description3)', errList.toString());
    }
    
    @isTest
    static void test2(){
        case c2 = [select id, Device_Error__c from case where Alert_Type__c = 'Operational' limit 1];
        c2.Device_Error__c = 'This is just a simple error line';
        update c2;
        EDMoS_DeviceErrorController errors = new EDMoS_DeviceErrorController();
        errors.caseId = c2.Id;
        List<String> errList = errors.deviceErrorList;
        System.debug('::: Error List ' + errList);
        System.assertEquals('(This is just a simple error line)', errList.toString());

    }

}