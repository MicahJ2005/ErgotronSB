/*
	Controller class for the overrideSeedUnitProductView.page on the Seed_Unit_Product__c object.  Redirects the user to the Seed_Unit_Order__c record
	associated with the Seed_Unit_Product__c

	MOD DATE		Who						Description
	4/11/2014		Chris Noe				Initial Release
*/

public with sharing class Seed_Product_Override {

	private Seed_Unit_Product__c oSeedUnitProduct {get;private set;}

	public Seed_Product_Override(ApexPages.StandardController oStdController) {
        this.oSeedUnitProduct = (Seed_Unit_Product__c)oStdController.getRecord();
    }
    
    public PageReference RedirectSeedUnitOrder(){
    	return new PageReference('/' + oSeedUnitProduct.Seed_Unit_Order__c);
    }
}