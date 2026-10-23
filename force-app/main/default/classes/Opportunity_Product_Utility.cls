/*
	Class used by the Apex Component OpportunityProduct.component to retrieve the OpportunityLineItem records for an opportunity.  This component
	is used in the Visualforce email template "Special Pricing Approval Request".  This implementation was chosen because there are fields in the
	email template that the submitting user does not have access to.  This class along with the component allows for the display of these fields
	because the class is declared as without sharing.

	MOD DATE		Who						Description
	03/12/2015		Chris Noe				Initial Release
	06/22/2023		Esau Sanchez			Extended_Margin__c field added
*/

public without sharing class Opportunity_Product_Utility {
	public String sOpportunityId='';							//set by the OpportunityProduct.component
	public List<OppProduct> listProducts = new List<OppProduct>();

	public void setsOpportunityId(String sOpptyId) {
		sOpportunityId = sOpptyId;
	}

	public String getsOpportunityId() {
		return sOpportunityId;
	}

	public List<OppProduct> getlistProducts() {
		if(sOpportunityId!='' && sOpportunityId!=NULL) {
			List<OppProduct> listReturn = new List<OppProduct>();

			for(OpportunityLineItem oOpptyLine : [select CurrencyIsoCode, Product2.Name, Quantity, ListPrice, Max_Rebate_Percent__c, Target_End_User_Price__c, Estimated_Reseller_Margin__c, Target_Reseller_Price__c,
				 Estimated_Distribution_Margin__c, Target_Distribution_Price__c, Distribution_List_Price__c, Target_Rebate_Amount__c, Target_Rebate__c, Exceeds_Max_Rebate__c, Item_Margin__c, Extended_Margin__c, Description 
				 from OpportunityLineItem where OpportunityId=:sOpportunityId]){
				OppProduct oOppProduct = new OppProduct();
				oOppProduct.CurrencyIsoCode=oOpptyLine.CurrencyIsoCode;
				oOppProduct.ProductName=oOpptyLine.Product2.Name;
				oOppProduct.Quantity=oOpptyLine.Quantity;
				oOppProduct.ListPrice=oOpptyLine.ListPrice;
				oOppProduct.MaxRebatePercent=oOpptyLine.Max_Rebate_Percent__c;
				oOppProduct.TargetEndUserPrice=oOpptyLine.Target_End_User_Price__c;
				oOppProduct.EstimatedResellerMargin=oOpptyLine.Estimated_Reseller_Margin__c;
				oOppProduct.TargetResellerPrice=oOpptyLine.Target_Reseller_Price__c;
				oOppProduct.EstimatedDistributionMargin=oOpptyLine.Estimated_Distribution_Margin__c;
				oOppProduct.TargetDistributionPrice=oOpptyLine.Target_Distribution_Price__c;
				oOppProduct.DistributionPrice=oOpptyLine.Distribution_List_Price__c;
				oOppProduct.TargetRebateAmount=oOpptyLine.Target_Rebate_Amount__c;
				oOppProduct.TargetRebate=oOpptyLine.Target_Rebate__c;
				oOppProduct.ExceedsMaxRebate=oOpptyLine.Exceeds_Max_Rebate__c;
				oOppProduct.ItemMargin=oOpptyLine.Item_Margin__c;
				oOppProduct.ExtendedMargin=oOpptyLine.Extended_Margin__c;
				oOppProduct.Description=oOpptyLine.Description;

				listReturn.add(oOppProduct);
			}

			return listReturn;
		}
		else {
			return null;
		}
	}

	public class OppProduct {
		//Results from the getlistProducts are populated on an inner class because some of the fields returned are not accessible by the running user and therefor cannot
		//be displayed on the Visualforce component.
		public String CurrencyIsoCode {set; get;}
		public String ProductName {set; get;}
		public Decimal Quantity {set; get;}
		public Decimal ListPrice {set; get;}
		public Decimal MaxRebatePercent {set; get;}
		public Decimal TargetEndUserPrice {set; get;}
		public Decimal EstimatedResellerMargin {set; get;}
		public Decimal TargetResellerPrice {set; get;}
		public Decimal EstimatedDistributionMargin {set; get;}
		public Decimal TargetDistributionPrice {set; get;}
		public Decimal DistributionPrice {set; get;}
		public Decimal TargetRebateAmount {set; get;}
		public Decimal TargetRebate {set; get;}
		public Boolean ExceedsMaxRebate {set; get;}
		public Decimal ItemMargin {set; get;}
		public Decimal ExtendedMargin {set; get;}
		public String Description {set; get;}
	}
}