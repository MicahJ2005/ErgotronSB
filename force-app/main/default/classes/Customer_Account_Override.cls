/*
	Controller extension class for overrideCustomerAccountView.page.

	MOD DATE		Who						Description
	3/20/2014		Chris Noe				Initial Release
*/

public with sharing class Customer_Account_Override {

	private Customer_Account__c oCustomerAccount {get;private set;}

	public Customer_Account_Override(ApexPages.StandardController oStdController) {
        this.oCustomerAccount = (Customer_Account__c)oStdController.getRecord();
    }
    
    public PageReference RedirectAccount(){

    	List<Profile> lstProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
		String strProfileName = lstProfile[0].Name;

		if(strProfileName == 'System Administrator') {
			return null;
		} else {
			return new PageReference('/' + oCustomerAccount.Party__c);
		}
    }	
}