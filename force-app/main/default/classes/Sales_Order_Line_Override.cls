/*
	Controller class for the overrideSalesOrderLine.page on the Sales_Order_Line__c object.  Redirects the user to the Sales_Order__c record
	associated with the Sales_Order_Line__c record.

	MOD DATE		Who						Description
	6/24/2015		Chris Noe				Initial Release
*/

public with sharing class Sales_Order_Line_Override {

	private Sales_Order_Line__c oSalesOrderLine {get;private set;}

	public Sales_Order_Line_Override(ApexPages.StandardController oStdController) {
        this.oSalesOrderLine = (Sales_Order_Line__c)oStdController.getRecord();
    }
    
    public PageReference redirect(){
    	return new PageReference('/' + oSalesOrderLine.Sales_Order__c);
    }
}