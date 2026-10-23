/*
	Controller class for the OpportunityPricingSetup.page.

	MOD DATE		Who						Description
	03/27/2015		Chris Noe				Initial Release
*/

public with sharing class Opportunity_Pricing_Setup_Controller {

	//Class Variables
	private Opportunity oOpportunity {get;private set;}
	private ApexPages.StandardController oStd {get;private set;}
	public List<OpportunityLineItem> listOpptyLines {get;private set;}

	//Field access for Target Distribution Price, Distribution Price, and Item Margin %
	public Boolean bTargetDistyPriceAccess {get;private set;}
	public Boolean bDistyPriceAccess {get;private set;}
	public Boolean bItemMarginAccess {get;private set;}

	public Opportunity_Pricing_Setup_Controller(ApexPages.StandardController oStdController) {
		//Get the current Opportunity record
        this.oOpportunity = (Opportunity)oStdController.getRecord();

        oStd=oStdController;

        //Get the OpportunityLineItem records for this Opportunity
        listOpptyLines=[select Id, Product2.Oracle_Part_Name__c, Product2.Oracle_Part_Number__c, Quantity, ListPrice, Target_End_User_Price__c, Estimated_Reseller_Margin__c, 
        				Target_Reseller_Price_Number__c, Estimated_Distribution_Margin__c, Target_Distribution_Price_Number__c, Distribution_List_Price_Number__c, 
        				Target_Rebate_Amount__c, Item_Margin__c, CurrencyIsoCode, Description, Product_Discount__c, Rebate_Amount__c, Target_Rebate__c
        				from OpportunityLineItem where OpportunityId = :oOpportunity.Id order by Product2.ProductCode];

        //Get field level security for distribution prices
        bTargetDistyPriceAccess=Schema.sObjectType.OpportunityLineItem.fields.Target_Distribution_Price__c.isAccessible();
        bDistyPriceAccess=Schema.sObjectType.OpportunityLineItem.fields.Distribution_List_Price__c.isAccessible();
        bItemMarginAccess=Schema.sObjectType.OpportunityLineItem.fields.Item_Margin__c.isAccessible();
	}

	public PageReference saveUpdates() {
		//Validate required fields
		for(OpportunityLineItem oOpptyLineItemUpdate :listOpptyLines){
			//For each opportunity line item, the user must specify either a Rebate Amount, Product Discount %, or Target End User Price.  The only exception to this rule
			//is if an Opportunity.Opportunity_Discount__c value has been specified at the opportunity level.
			if(oOpportunity.Opportunity_Discount__c==NULL && oOpptyLineItemUpdate.Rebate_Amount__c==NULL && oOpptyLineItemUpdate.Product_Discount__c==NULL && oOpptyLineItemUpdate.Target_End_User_Price__c==NULL){
				oOpptyLineItemUpdate.addError('Please specify a Rebate Amount, Product Discount %, or Target End User Price for each line item below.');
				return null;
			}
		}

		try {
			update oOpportunity;
			update listOpptyLines;

			PageReference oPageRef = Page.OpportunityPricingSetup;
			oPageRef.getParameters().put('id', oOpportunity.Id);
			oPageRef.setRedirect(true);
			return oPageRef;
		}

		catch(Exception oException) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
			return null;
		}
	}

	public PageReference returnToOppty() {
		PageReference oPageRef = new PageReference('/' + oOpportunity.Id);
		oPageRef.setRedirect(true);
		return oPageRef;		
	}
}