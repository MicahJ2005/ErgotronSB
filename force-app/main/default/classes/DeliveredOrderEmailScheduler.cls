global class DeliveredOrderEmailScheduler implements Schedulable {
    public static String CRON_EXP = '0 0 0 3 9 ? 2024';
    
    global void execute(SchedulableContext sc) {
        Batch_Size__mdt theBatchSize = [SELECT Number_of_Records_to_Process__c FROM Batch_Size__mdt WHERE DeveloperName = 'DeliveredOrderEmail' LIMIT 1];
        DeliveredOrderEmailBatch emailBatch = new DeliveredOrderEmailBatch();
        database.executebatch(emailBatch, (Integer)theBatchSize.Number_of_Records_to_Process__c);

    }
}