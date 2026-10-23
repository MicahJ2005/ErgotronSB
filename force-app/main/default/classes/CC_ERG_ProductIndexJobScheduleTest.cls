@istest
public class CC_ERG_ProductIndexJobScheduleTest {
    
    public static final String testSchedule = '0 0 0 3 9 ? 2022';
    public static testmethod void testProductIndexJobSchedule() {
        
        Test.startTest();
        
        String jobId = System.schedule('testBasicScheduledApex',testSchedule, 
                                       new CC_ERG_ProductIndexJobSchedule());
        Test.stopTest();
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(testSchedule, ct.CronExpression);
        
    }
}