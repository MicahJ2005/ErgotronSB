/*
	Test class for POS_Owner_Assignment_Batch.cls

	MOD DATE		Who						Description
	5/16/2014		Chris Noe				Initial Release
*/
@isTest
private class POS_Owner_Assignment_Batch_Test {

    private static testMethod void testPOSBatchAssignment() {
        //Create POS record for testing
        POS__c oPOS = new POS__c(OwnerId='005G0000003r9HE',Product_Transfer_Date__c=Date.today(),Resale_Line_Id__c=String.valueOf(Test_Environment_Utility.getRandomInt(1, 1000)),Ship_To_State__c='MN',Ship_To_Country__c='US',Ship_To_Postal_Code__c='55372');
        insert oPOS;
        
        //Create Web_Service_Details__c record for testing
        Web_Service_Details__c oWSDetails = new Web_Service_Details__c();
        oWSDetails.Name='Territory Lookup';
        oWSDetails.Endpoint__c='https://internalapps.ergotron.com:8443/replocatorservice/Service1.asmx/GetDataJSON';
        oWSDetails.Exception_Email__c='salesforce@ergotron.com';
        oWSDetails.Description_Where_Used__c='test';
        oWSDetails.Username__c='test';
        oWSDetails.Password__c='test';
        insert oWSDetails;
        
        //Create batch job
        Test.startTest();
        	Id idBatchJobId = Database.executeBatch(new POS_Owner_Assignment_Batch(),1000);
        Test.stopTest();
        
        List<AsyncApexJob> BatchAsyncApexJob=[select Id from AsyncApexJob where Id = :idBatchJobId];
        system.assert(BatchAsyncApexJob.size()>0);
    }

    static testMethod void testPOSAssignmentSchedule(){
        //Tests the POS_Owner_Assignment_Schedule.cls

        test.startTest();
            String sch = '0 1 * * * ?'; 
            String jobId = system.schedule('Schedule Job', sch, new POS_Owner_Assignment_Schedule());
        test.stopTest();

        system.assert([SELECT c.Id FROM CronTrigger c WHERE c.Id=:jobId].size()>0);
    }
}