/*
	Controller class for the OrderLineNotes.page.

	MOD DATE		Who						Description
	04/24/2015		Chris Noe				Initial Release
*/

public with sharing class Order_Line_Notes_Cntrl {
	//Class variables
	private Order__c oOrder {get;private set;}
	//public List<orderLine> listOLI {get;private set;}
	public List<Order_Line_Item__c> listOLI {get;private set;}

	public Order_Line_Notes_Cntrl(ApexPages.StandardController oStdController) {
         //Retrieve the order
        this.oOrder = (Order__c)oStdController.getRecord();
	
        //Retrieve order line items
        this.listOLI = [select Id, Name, Product_Name__c, Status__c, Quantity__c, Notes__c, Estimated_Completion_Date__c 
					from Order_Line_Item__c where Order__c = :oOrder.Id order by Line_Number__c];
	}

	public PageReference saveUpdates(){
		//Save updates from the page

		update this.listOLI;

    	return returnToOrder();
	}

	public PageReference cancelUpdates(){
		//Cancel and return to order
		return returnToOrder();
	}

	public PageReference returnToOrder(){
    	PageReference oPageRef = new PageReference('/' + oOrder.Id);
        oPageRef.setRedirect(true);
        return oPageRef;		
	}
}