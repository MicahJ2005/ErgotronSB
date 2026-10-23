/*
	Controller class for the overrideLeadProductView.page on the Lead_Product__c object.  Redirects the user to the Lead record
	associated with the Lead_Product__c record.

	MOD DATE		Who						Description
	1/29/2015		Chris Noe				Initial Release
*/

public with sharing class Lead_Product_Override {

	private Lead_Product__c oLeadProduct {get;private set;}

	public Lead_Product_Override(ApexPages.StandardController oStdController) {
        this.oLeadProduct = (Lead_Product__c)oStdController.getRecord();
    }
    
    public PageReference RedirectLead(){
    	return new PageReference('/' + oLeadProduct.Lead__c);
    }
}