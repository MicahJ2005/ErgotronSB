/**
 * ENRPreviewSyncScheduler
 *
 * Thin Schedulable wrapper for ENRPreviewSyncBatch. Keeping the two classes
 * separate is required for the class to appear in Setup > Apex Classes >
 * Schedule Apex — Salesforce hides classes that implement both Schedulable
 * and Database.Batchable from the scheduler UI.
 *
 * To schedule via Execute Anonymous instead:
 *   System.schedule(
 *       'ENR Preview Sync - Hourly',
 *       '0 0 * * * ?',
 *       new ENRPreviewSyncScheduler()
 *   );
 */
public class ENRPreviewSyncScheduler implements Schedulable {
    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new ENRPreviewSyncBatch(), 200);
    }
}