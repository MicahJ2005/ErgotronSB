/*
	Controller class for the SeedUnitOrderSubmit.page on the Seed_Unit_Order__c object.

	MOD DATE		Who						Description
	4/23/2014		Chris Noe				Initial Release
*/

public with sharing class Seed_Unit_Order_Submit_Controller {
    //Class variables
    public final Seed_Unit_Order__c oSeedUnitOrder;
    public Boolean bApprovalRequired {get; private set;}
   	public Boolean bMissingShipToLocation {get; private set;}
    
	//Constructor method
    public Seed_Unit_Order_Submit_Controller(ApexPages.StandardController stdController) {
        //Get the current Seed_Unit_Order__c record
        this.oSeedUnitOrder = (Seed_Unit_Order__c)stdController.getRecord();
		
		//Initialize boolean flags
		bApprovalRequired=false;
		bMissingShipToLocation=false;
		
		//Set flag for seed unit order approval required
		for(Seed_Unit_Product__c oSeedUnitProduct :[select Id, Seed_Unit_Eligible__c from Seed_Unit_Product__c where Seed_Unit_Order__c = :oSeedUnitOrder.Id]) {
			if(!oSeedUnitProduct.Seed_Unit_Eligible__c) {
				bApprovalRequired=true;
			}
		}
    	
    	//Verify that Ship To Location has been selected or entered
    	if(oSeedUnitOrder.Ship_To_Address1__c==NULL && oSeedUnitOrder.Ship_To_Org_Id__c==NULL){
    		bMissingShipToLocation=true;
    	}
    }
    
    public PageReference submitSeedUnitOrder() {
    	//Verify that the seed unit order has not already been submitted to Oracle or is not in the approval process.
    	if(!oSeedUnitOrder.Seed_Unit_Order_Submitted__c && oSeedUnitOrder.Seed_Unit_Approval_Status__c!='Submitted') {
	    	//Verify that the current seed unit order contains products
	    	if(oSeedUnitOrder.Total_Quantity__c>0) {
	    		
	    		//Verify that the user has selected a ship to location. If not, redirect them to the SeedUnitSelectShipTo.page.
	    		if(bMissingShipToLocation){
	    			PageReference oPageRef = Page.SeedUnitSelectShipTo;
	    			oPageRef.getParameters().put('id', oSeedUnitOrder.Id);
    				oPageRef.setRedirect(true);
    				return oPageRef;
	    		}
	    		
	    		//If approval is required, verify that the user has entered an ineligible product justification.  If not, redirect them to the SeedProductJustification.page. 
	    		if(bApprovalRequired && oSeedUnitOrder.Ineligible_Product_Justification_Long__c==NULL) {
	    			PageReference oPageRef = Page.SeedProductJustification;
	    			oPageRef.getParameters().put('id', oSeedUnitOrder.Id);
    				oPageRef.setRedirect(true);
    				return oPageRef;	    			
	    		}
	    		
	    		//All required information has been entered for the seed unit order.  Redirect the user to the confirmation page.
    			PageReference oPageRef = Page.SeedUnitOrderConfirmation;
    			oPageRef.getParameters().put('id', oSeedUnitOrder.Id);
				oPageRef.setRedirect(true);
				return oPageRef;
	    	}
	    	else {
	    		//No products selected on seed unit order.  Return summary page which will display a message to user directing them to add products to the seed unit order.
	    		PageReference oPageRef = Page.SeedUnitOrderSummary;
	    		oPageRef.getParameters().put('id', oSeedUnitOrder.Id);
    			oPageRef.setRedirect(true);
    			return oPageRef;
	    	}
    	}
    	else {
    		//Seed unit order already submitted.  Return summary page which will display a message to user indicating that the seed unit order has already been 
    		//submitted or is currently in the approval process.
	    	PageReference oPageRef = Page.SeedUnitOrderSummary;
	    	oPageRef.getParameters().put('id', oSeedUnitOrder.Id);
    		oPageRef.setRedirect(true);
    		return oPageRef;
    	}
    }
}