@isTest
public class LifeKinnex_Test {

    @isTest static void test1() {
        // Create test event instance for non-existing asset
        LifeKinnex__e kinnexEvent = new LifeKinnex__e(
            Device_Id__c = 'Test Device ID',
        	Serial_Number__c = 'Non-Existing Asset');
        
        Test.startTest();
        // Call method to publish events
        Database.SaveResult sr = EventBus.publish(kinnexEvent);
        
        Test.stopTest();
        
        // Perform validation here
        // Verify that the publish was successful
        System.assertEquals(true, sr.isSuccess());
        // Check that the case that the trigger created is present.
        List<Case> cases = [SELECT Id FROM Case];
        // Validate that this case was found.
        // There is only one test case in test context.
        System.assertEquals(1, cases.size());
    }

}