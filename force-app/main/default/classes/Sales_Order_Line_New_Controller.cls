/*
    Controller class for the SalesOrderLineNew.page.

    MOD DATE        Who                     Description
    07/07/2015      Chris Noe               Initial Release 
*/

public with sharing class Sales_Order_Line_New_Controller {
	//Class variables
    public final Sales_Order_Line__c oSalesOrderLine;
    public Sales_Order__c oSalesOrder {get; private set;}
    public List<selectOption> listReturnReasonOptions {get;private set;}
    public String sReturnReason {get;set;}
    public Map<String,String> mapReturnReasons {get;private set;}
    public Boolean bReturnFlag {get;private set;}
    public Boolean bAlreadySubmitted {get;private set;}
    public String sSalesOrderId {get;set;}	

	public Sales_Order_Line_New_Controller(ApexPages.StandardController oStdController) {
		
		//Get the current Sales_Order_Line__c record
        oSalesOrderLine = (Sales_Order_Line__c)oStdController.getRecord();

        //Retrieve URL parameters for Sales_Order__c Id
        sSalesOrderId = ApexPages.currentPage().getParameters().get('soid');

        if(sSalesOrderId!=NULL){
            //Retrieve Sales_Order__c record
            oSalesOrder = [select Id, Order_Type__c, Order_Submitted__c, Oracle_Sales_Order_Number__c, Oracle_Order_Status__c, Date_Time_Submitted__c
             from Sales_Order__c where Id = :sSalesOrderId];
        }

		//Set the selected return reason if working with an exisitng Sales_Order_Line__c record
        if(oSalesOrderLine.Id!=NULL){
        	sReturnReason=oSalesOrderLine.Return_Reason_Code__c;

	        //Set flag to indicate whether or not the parent Sales_Order__c is a return order type
			bReturnFlag=false;
			bReturnFlag = bReturnFlag || oSalesOrderLine.Sales_Order__r.Order_Type__c.contains('RETURN');
        }
        else {
        	oSalesOrderLine.Sales_Order__c=sSalesOrderId;

        	//Set flag to indicate whether or not the parent Sales_Order__c is a return order type
			bReturnFlag=false;
			bReturnFlag = bReturnFlag || oSalesOrder.Order_Type__c.contains('RETURN');

			//Set flag to indicate whether or not the parent Sales_Order__c has already been submitted
			bAlreadySubmitted=false;
			bAlreadySubmitted = bAlreadySubmitted || oSalesOrder.Order_Submitted__c;
        }

		//Build list of return reasons from custom setting Oracle_Return_Reason__c.
		listReturnReasonOptions = new List<selectOption>();
		mapReturnReasons = new Map<String,String>();

		//Add blank value to the selection list
		listReturnReasonOptions.add(new SelectOption('', '-- Select One --'));       

        //Retrieve all return reasons from custom setting
        Map<String, Oracle_Return_Reason__c> mapReturnReasonSetting = Oracle_Return_Reason__c.getAll();
        List<String> listReturnReasonCodes = new List<String>();
        listReturnReasonCodes.addAll(mapReturnReasonSetting.keySet());
        listReturnReasonCodes.sort();
        
        //Create the Select Options.
        for (String sReturnReasonCode : listReturnReasonCodes) {
            Oracle_Return_Reason__c oReturnReason = mapReturnReasonSetting.get(sReturnReasonCode);
            
            //Add return reason to the selection list based on the custom setting fields.  Only display return reasons that have a Start Date Active value that is less than or equal to today,
            //an End Date Active value that is NULL or greater than today, and a Enabled_Flag__c value of True
            if(oReturnReason.Enabled_Flag__c && oReturnReason.Start_Date_Active__c<=Date.today() && (oReturnReason.End_Date_Active__c==NULL || oReturnReason.End_Date_Active__c>Date.today())){
	            listReturnReasonOptions.add(new SelectOption(oReturnReason.Lookup_Code__c,oReturnReason.Description__c));

	            //Add key value pair to mapReturnReasons
	            mapReturnReasons.put(oReturnReason.Lookup_Code__c,oReturnReason.Description__c);            	
            }

		}
	}

	public PageReference saveSalesOrderLine() {
        //Verify required fields

        //Return Reason
        if(sReturnReason==NULL && bReturnFlag){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a return reason.'));
            return null;
        }

        //Insert/Update Sales_Order_Line__c
        oSalesOrderLine.Return_Reason_Code__c=sReturnReason;
        oSalesOrderLine.Return_Reason__c=mapReturnReasons.get(sReturnReason);

        try{
        	upsert oSalesOrderLine;	
        }
        catch(Exception oException){
            return null;        	
        }
        

        PageReference oPageRef = new PageReference('/' + oSalesOrderLine.Sales_Order__c);
        oPageRef.setRedirect(true);
        return oPageRef;		
	}
}