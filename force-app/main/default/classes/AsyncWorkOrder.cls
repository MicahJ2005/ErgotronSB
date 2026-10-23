public class AsyncWorkOrder implements Queueable {
    public List<WorkOrder> woList = new List<WorkOrder>();

    public void execute(QueueableContext context) {
        Database.SaveResult[] srList = Database.update(woList, false);
    }
}