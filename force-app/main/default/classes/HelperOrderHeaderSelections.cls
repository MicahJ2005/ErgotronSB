public class HelperOrderHeaderSelections {
	@AuraEnabled public List<Oracle_Order_Type__c> lstOrderType{get;set;}
	@AuraEnabled public List<Account> lstAcct{get;set;}
	@AuraEnabled public String defAcct{get;set;}
    @AuraEnabled public String strCaseNumber {get;set;}
    // @AuraEnabled public List<Contact> lstSTContacts {get;set;}
}