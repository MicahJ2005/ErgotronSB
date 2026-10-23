public with sharing class Sales_Order_SRAttachController {
/**
*   {Purpose}  �  TODO:  Provide Purpose
*
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 612-424-0032                  
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date    	Name             		Description
*   YYYYMMDD  	FN LN DCS				Created
*   =============================================================================
*/
	private final Sales_Order__c soSalesOrder;
	public String strAttachmentName {get;set;}


	///////////////////////////
	// Constructors
	///////////////////////////
	public Sales_Order_SRAttachController(ApexPages.standardController scMain) {
		soSalesOrder = (Sales_Order__c)scMain.getRecord();

		strAttachmentName = soSalesOrder.Name + '-' + soSalesOrder.Order_Type__c;
	}
	
	
	///////////////////////////
	// Action Methods
	///////////////////////////
	public PageReference prSR() {

		PageReference prPDF = Page.SalesOrderPrint;
	    prPdf.getParameters().put('id', soSalesOrder.Id);
	    Blob blPDF;
	    if(Test.isRunningTest()) {
	    	blPDF = Blob.valueOf('SALESFORCE DOES NOT SUPPORT getContentAsPDF IN TEST CLASSES!');
	    } else {
	    	blPDF = prPDF.getContentAsPDF();
	    }
		
	    
		Attachment objAtt = new Attachment();
		objAtt.body = blPDF;
		objAtt.ParentId = soSalesOrder.Service_Request__c;
		objAtt.Name = strAttachmentName + '.PDF';
	    objAtt.ContentType = 'application/pdf';
		insert objAtt;

		return new PageReference('/' + soSalesOrder.Service_Request__c);

	}



}