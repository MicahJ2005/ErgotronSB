public with sharing class EnhancedNoteMigrationBatchLauncher {

    public class Result {
        @InvocableVariable
        public String batchJobId;

        @InvocableVariable
        public String message;
    }

    @InvocableMethod(
        label='Run Enhanced Note Migration Batch'
        description='Starts the Enhanced Note Migration Batch with a scope size of 10.'
    )
    public static List<Result> runBatch() {
        Id batchJobId = Database.executeBatch(
            new EnhancedNoteMigrationBatch(),
            10
        );

        Result result = new Result();
        result.batchJobId = String.valueOf(batchJobId);
        result.message = 'Enhanced Note Migration Batch started with scope size 10.';

        return new List<Result>{ result };
    }
}