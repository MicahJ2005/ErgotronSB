/**
 * @description       : 
 * @author            : willh@demandchain.com
 * @group             : 
 * @last modified on  : 04-29-2021
 * @last modified by  : willh@demandchain.com
 * Modifications Log 
 * Ver   Date         Author                  Modification
 * 1.0   04-23-2021   willh@demandchain.com   Initial Version
**/
global class TrackingOrderEmailScheduler implements Schedulable {
    public static String CRON_EXP = '0 0 0 3 9 ? 2029';
    /**
    * @description 
    * @author willh@demandchain.com | 04-23-2021 
    * @param SchedulableContext sc 
    **/
    global void execute(SchedulableContext sc) {
        Batch_Size__mdt theBatchSize = [SELECT Number_of_Records_to_Process__c FROM Batch_Size__mdt WHERE DeveloperName = 'TrackingOrderEmailBatch' LIMIT 1];
        TrackingOrderEmailBatch theTrackingOrderEmailBatch = new TrackingOrderEmailBatch();
        database.executebatch(theTrackingOrderEmailBatch, (Integer)theBatchSize.Number_of_Records_to_Process__c);

    }
}