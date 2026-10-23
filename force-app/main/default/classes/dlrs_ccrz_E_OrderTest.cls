/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_ccrz_E_OrderTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_ccrz_E_OrderTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new ccrz__E_Order__c());
    }
}