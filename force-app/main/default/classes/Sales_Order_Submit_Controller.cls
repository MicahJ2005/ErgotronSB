/*
	Controller class for the SalesOrderSubmit.page on the Sales_Order__c object.

	MOD DATE		Who						Description
	7/02/2015		Chris Noe				Initial Release
*/

public with sharing class Sales_Order_Submit_Controller {
    //Class variables
    public final Sales_Order__c oSalesOrder;
   	public Boolean bMissingShipToLocation {get; private set;}

	public Sales_Order_Submit_Controller(ApexPages.StandardController stdController) {
        //Get the current Sales_Order record
        this.oSalesOrder = (Sales_Order__c)stdController.getRecord();
		
		//Initialize boolean flags
		bMissingShipToLocation=false;
		//Check for ship to location on the sales order
		bMissingShipToLocation = bMissingShipToLocation || oSalesOrder.Ship_To_Org_Id__c==NULL;
	}

	public PageReference submitSalesOrder() {
		//Verify that the sales order has not already been submitted.
		if(!oSalesOrder.Order_Submitted__c){
	    	//Verify that the sales order contains products with a quantity greater than 0.
	    	if(oSalesOrder.Total_Quantity__c>0) {
	    		//Verify that the user has selected a ship to location. If not, redirect them to the SalesOrderSelectShipTo.page.
	    		if(bMissingShipToLocation){
	    			PageReference oPageRef = Page.SalesOrderSelectShipTo;
	    			oPageRef.getParameters().put('id', oSalesOrder.Id);
    				oPageRef.setRedirect(true);
    				return oPageRef;
	    		}

	    		else{

	    			//All required information has been entered for the sales order.  Redirect the user to the confirmation page.
	    			PageReference oPageRef = Page.SalesOrderConfirmation;
    				oPageRef.getParameters().put('id', oSalesOrder.Id);
					oPageRef.setRedirect(true);
					return oPageRef;
	    		}
	    	}

	    	else{
	    		//No products selected on sales order.  Return summary page which will display a message to user directing them to add products to the sales order.
    			PageReference oPageRef = Page.SalesOrderSummary;
    			oPageRef.getParameters().put('id', oSalesOrder.Id);
				oPageRef.setRedirect(true);
				return oPageRef;
	    	}
		}

		else{
			//Sales order already submitted.  Return summary page which will display a message to user indicating that the sales order has already been submitted.
			PageReference oPageRef = Page.SalesOrderSummary;
			oPageRef.getParameters().put('id', oSalesOrder.Id);
			oPageRef.setRedirect(true);
			return oPageRef;
		}
	}
}