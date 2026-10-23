/*
	Controller class for the ippodetails.page.

	MOD DATE		Who						Description
	07/09/2014		Chris Noe				Initial Release
*/

public with sharing class IP_PO_Details_Cntrl {
	private Integration_Project__c oIntProject {get;private set;}
	public List<Purchase_Order_Detail_OE__c> listPODetails {get;private set;}
	public Boolean bPODetails {get;private set;}

	public IP_PO_Details_Cntrl(ApexPages.StandardController oStdController) {
        //Retrieve the Integration_Project__c record
        this.oIntProject = (Integration_Project__c)oStdController.getRecord();
        
        //Populate list of purchase order records if the Integration_Project__c is associated with a sales order
        if(oIntProject.Sales_Order__c!=NULL){
        	this.listPODetails=[select Name, Vendor_Name__c, Status__c, Quantity__c from Purchase_Order_Detail_OE__c where Order__c = :oIntProject.Sales_Order__c];	
        }
        
        //Set boolean flag for display of PO details
        bPODetails=false;
        bPODetails=bPODetails || listPODetails.size()>0;
	}
}