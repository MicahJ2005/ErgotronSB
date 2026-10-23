/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Program_Rebate_Line_ItemTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Program_Rebate_Line_ItemTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Program_Rebate_Line_Item__c());
    }
}