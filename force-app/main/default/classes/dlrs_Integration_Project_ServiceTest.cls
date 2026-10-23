/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Integration_Project_ServiceTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Integration_Project_ServiceTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Integration_Project_Service__c());
    }
}