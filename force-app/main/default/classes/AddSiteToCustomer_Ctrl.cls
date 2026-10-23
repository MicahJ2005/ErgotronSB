public class AddSiteToCustomer_Ctrl  {

	public ApexPages.StandardController scMain {get;set;}
	private Account objCustomerAcct;
	public Account objNewAccount {get;set;}
	private Boolean bolCreateCustomer = false;
	private Id rtParty;
	private Id rtCustomer;
	private Id rtSite;
	private Id idParentRecord;

	public AddSiteToCustomer_Ctrl(ApexPages.StandardController sc) {
		scMain = sc;
		objCustomerAcct = (Account)sc.getRecord();

		rtParty = Schema.SObjectType.Account.RecordTypeInfosByName.get('Party').RecordTypeId;
		rtCustomer = Schema.SObjectType.Account.RecordTypeInfosByName.get('Customer - Organization').RecordTypeId;
		rtSite = Schema.SObjectType.Account.RecordTypeInfosByName.get('Site').RecordTypeId;

		if(objCustomerAcct.RecordTypeId == rtParty) {
			bolCreateCustomer = true;
		}

		idParentRecord = objCustomerAcct.Id;

		objNewAccount = new Account(Name=objCustomerAcct.Name);
	}

	public PageReference save() {

		// Create Customer
		if(bolCreateCustomer) {
			Account objCustomer = new Account(Name=objNewAccount.Name, ParentId=idParentRecord, RecordTypeId=rtCustomer);
			insert objCustomer;
			idParentRecord = objCustomer.Id;	
		}

		// Create Site
		objNewAccount.Site_Deduplication__c = 'yes';
		objNewAccount.RecordTypeId = rtSite;
		objNewAccount.ParentId = idParentRecord;

		insert objNewAccount;

		PageReference prRef = new PageReference('/' + objNewAccount.Id);
		prRef.setRedirect(true);
		return prRef;
	}

}