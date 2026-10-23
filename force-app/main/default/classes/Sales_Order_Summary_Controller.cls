/*
	Controller class for the SalesOrderSummary.page on the Sales_Order__c object.

	MOD DATE		Who						Description
	7/2/2014		Chris Noe				Initial Release
*/

public with sharing class Sales_Order_Summary_Controller {
    //Class variables
    public final Sales_Order__c oSalesOrder;

	public Sales_Order_Summary_Controller(ApexPages.StandardController stdController) {
        //Get the current Sales_Order__c record
        this.oSalesOrder = (Sales_Order__c)stdController.getRecord();        
    }
    
    public String getFormattedSubmissionDate(){
    	return oSalesOrder.Date_Time_Submitted__c.format();
    }

    public PageReference returnToSalesOrder(){
		PageReference oPageRef = new PageReference('/' + oSalesOrder.Id);
		oPageRef.setRedirect(true);
		return oPageRef;
    }

    public PageReference returnToServiceRequest(){
		PageReference oPageRef = new PageReference('/' + oSalesOrder.Service_Request__c);
		oPageRef.setRedirect(true);
		return oPageRef;
    }

    public PageReference returnToServiceContract(){
		PageReference oPageRef = new PageReference('/' + oSalesOrder.Service_Contract__c);
		oPageRef.setRedirect(true);
		return oPageRef;
    }
}