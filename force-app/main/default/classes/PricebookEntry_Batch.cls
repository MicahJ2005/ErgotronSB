/******************************************************************************
 * This can be scheduled, or run manually. 
 *		PricebookEntry_Batch batchClass = new PricebookEntry_Batch(); 
 *		Database.ExecuteBatch(batchClass, 10);
 *
 *  PricebookEntry_Batch
 *		Loops through all PBEs created/modified since last run and 
 * 		Sends the PBE Id into a flow
 * 		Using a batch job, because we can't write a trigger against
 * 		PricebookEntry object.
 *
 * @Author:			Sophia Murphy (Demand Chain)
 * @Date: 			02.04.2020
 *
 * @Updates
 * 						
 */
global class PricebookEntry_Batch implements Database.Batchable<sObject> , Schedulable, Database.Stateful  {
    public String query;
    public DateTime lastRunTime;
    public DateTime thisRunTime;
    public Integer batchSize;
    public PricebookBatch__c cs;
    
    global PricebookEntry_Batch() 
    {
        cs = PricebookBatch__c.getOrgDefaults();
        //first - get when we last ran this... 
        lastRunTime = cs.Last_Run_Time__c;
        thisRunTime = DateTime.now();
        try {
        	batchSize = cs.Batch_Size__c.intValue();
        } catch (Exception e) {
            batchSize = 10;
        }
        if(batchSize == null || batchSize <= 0) {
            batchSize = 10;
        }
        
    	this.query = 'SELECT Id, LastModifiedDate FROM PricebookEntry WHERE LastModifiedDate >= :lastRunTime' ;
        if(Test.isRunningTest())
        {
            this.query += ' LIMIT 200' ;
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
    	return Database.getQueryLocator(query);
    }
    
    global void execute(SchedulableContext sc) 
    {
		PricebookEntry_Batch b = new PricebookEntry_Batch(); 
		database.executebatch(b, batchSize);
    }

    global void execute(Database.BatchableContext BC, List<PricebookEntry> scope) 
    {
    	//for each record in our scope; we need to pass it into the FLOW
    	for (PricebookEntry pbe : scope) {

        	Flow.Interview flow = new Flow.Interview.PBE_to_CC_Price_List(new map<String,Object> 
                                                                             {'recordId' => pbe.Id});     
            if(!Test.isRunningTest()) {
                flow.start();    
            } 
    	}
    }

    global void finish(Database.BatchableContext BC) 
    {
    	cs.Last_Run_Time__c = thisRunTime;
        update cs;
    }
}