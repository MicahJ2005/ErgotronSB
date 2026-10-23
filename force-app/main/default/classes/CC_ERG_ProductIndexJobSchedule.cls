global class CC_ERG_ProductIndexJobSchedule  implements Schedulable{
   global void execute(SchedulableContext ctx) {
        Map<String, Object> productIndexInputData = new Map<String, Object> {
            ccrz.ccAPIProductIndex.CLEAN_ONLY => false,
            ccrz.ccAPIProductIndex.LOCALES => new Set<String>{'en_US', 'en'}, // Put all locales here
            'cleanAndCreatePI' => true
        };
        ccrz.ccProductIndexCleanupJob theJob = new ccrz.ccProductIndexCleanupJob(productIndexInputData);
        Database.executeBatch(theJob,1500);
   }
}
/*
 Here is the code to schedule the job to run daily at 5:15pm in case needed to run again.

cc_ProductIndexJobSchedule productIndexJob = new cc_ProductIndexJobSchedule();
String sch = '0 15 17 ? * * *'; //https://www.freeformatter.com/cron-expression-generator-quartz.html#
String jobID = system.schedule('Product Index Refresh', sch, productIndexJob); 

*/