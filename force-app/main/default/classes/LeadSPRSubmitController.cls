public with sharing class LeadSPRSubmitController {
/**
*   {Purpose}  �  TODO:  Provide Purpose
*
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 612-424-0032                  
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date    	Name             		Description
*   20160610  	Andy Boettcher DCS		Created
*   =============================================================================
*/
	public Lead soObject {get;set;}

	///////////////////////////
	// Constructors
	///////////////////////////
	public LeadSPRSubmitController(ApexPages.StandardController scController) {
		// TODO
		soObject = [SELECT Id, DesiredRebateType__c FROM Lead WHERE Id = :scController.getId()];

		soObject.DesiredRebateType__c = 'DEAL';
	}
	
	///////////////////////////
	// GET / SET
	///////////////////////////

	
	///////////////////////////
	// Action Methods
	///////////////////////////
	public PageReference prepForOracle() {

		// Loop through Lead and Lead Products to set the "SendToOracle" flag
		soObject.IsSentToOracle__c = true;

		List<Lead_Product__c> lstProducts = [SELECT Id, IsSentToOracle__c FROM Lead_Product__c WHERE Lead__c = :soObject.Id];

		for(Lead_Product__c soProduct : lstProducts) {
			soProduct.IsSentToOracle__c = true;
		}

		update soObject;
		if(!lstProducts.isEmpty()) { update lstProducts; }



		PageReference prRef = new PageReference('/' + soObject.Id);
		prRef.setRedirect(true);
		return prRef;

	}
	
	
	///////////////////////////
	// Inner / Helper Classes
	///////////////////////////
}