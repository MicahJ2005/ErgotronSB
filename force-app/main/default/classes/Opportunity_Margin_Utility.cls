/*
	Class used by the Apex Component OpportunityMargin.component to retrieve the Overall_Product_Margin__c for an opportunity.  This component
	is used in the Visualforce email template "Special Pricing Approval Request".  This implementation was chosen because Overall_Product_Margin__c
	is not accessible by the submitting user.  This class along with the component allows for the display of these fields
	because the class is declared as without sharing.

	MOD DATE		Who						Description
	03/13/2015		Chris Noe				Initial Release
*/

public without sharing class Opportunity_Margin_Utility {
	public String sOpportunityId='';							//set by the OpportunityMargin.component
	public Decimal dOverallProductMargin;

	public void setsOpportunityId(String sOpptyId) {
		sOpportunityId = sOpptyId;
	}

	public String getsOpportunityId() {
		return sOpportunityId;
	}

	public Decimal getdOverallProductMargin() {
		if(sOpportunityId!='' && sOpportunityId!=NULL) {
			dOverallProductMargin = [select Overall_Product_Margin__c from Opportunity where Id=:sOpportunityId].Overall_Product_Margin__c;
			return dOverallProductMargin;
		}
		else {
			return null;
		}
	}
}