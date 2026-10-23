/*
	Controller class for the CustomerAccounts.page.

	MOD DATE		Who						Description
	5/12/2014		Chris Noe				Initial Release
*/

public with sharing class Customer_Account_Controller {
	private Account oAccount {get;private set;}
	public List<Customer_Account__c> listCustomerAccounts {get;private set;}
	
	public Customer_Account_Controller(ApexPages.StandardController oStdController) {
        //Retrieve the Accout record
        this.oAccount = (Account)oStdController.getRecord();
        
        //Populate list of customer accounts
        this.listCustomerAccounts=[select Name, Account_Number__c, Freight_Terms__c, Price_List__c, Payment_Terms__c, Account_Description__c
        							from Customer_Account__c where Party__c = :oAccount.Id and Account_Status__c='A'];
	}    
}