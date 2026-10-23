public without sharing class TrackingInfoSearchController {
/**
*   {Purpose}	- Controller for TrackingInfoSearch VF Page to search and display 
*				  Tracking info for orders.
*
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 612-424-0032                  
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date    	Name             		Description
*   20160809  	Andy Boettcher DCS		Created
*   =============================================================================
*/
	private final Order__c soObject;
	public String strOrderNumber {get;set;}
	public String strPONumber {get;set;}
	public List<hClsResult> lstResults {get;set;}

	///////////////////////////
	// Constructors
	///////////////////////////
	public TrackingInfoSearchController(ApexPages.StandardController scController) {
		// TODO
		this.soObject = (Order__c)scController.getRecord();
		strOrderNumber = '';
		strPONumber = '';
		if(ApexPages.currentPage().getParameters().get('id') != '') {
			strOrderNumber = this.soObject.Name;
		}

		lstResults = new List<hClsResult>();

		if(strOrderNumber != null) {
			doSearch();
		}
		
	}
	
	///////////////////////////
	// GET / SET
	///////////////////////////

	
	///////////////////////////
	// Action Methods
	///////////////////////////
	public void doSearch() {

		lstResults = new List<hClsResult>();

		//Map<String, Order_Tracking_Number__c> mapOTN = new Map<String, Order_Tracking_Number__c>();
		Map<String, Order_Line_Item__c> mapOLI = new Map<String, Order_Line_Item__c>();
		Set<String> setOrderNumber = new Set<String>();

		// Query for Order Line Items
		for(Order_Line_Item__c objOLI : [SELECT Name, Order__c, Product_Code__c, Line_Id__c, Actual_Shipment_Date__c, Order__r.Name FROM Order_Line_Item__c WHERE Order__r.Name = :strOrderNumber OR Order__r.Customer_PO_Number__c = :strPONumber]) {
			mapOLI.put(objOLI.Line_Id__c, objOLI);
			setOrderNumber.add(objOLI.Order__r.Name);
		}

		// Query and Stack OTNs - use LineID + Tracking Number to handle multiple ships per Line
		for(Order_Tracking_Number__c objOTN : [SELECT Id, Name, Line_Id__c, Tracking_Number__c, Quantity__c, Carrier_Code__c FROM Order_Tracking_Number__c WHERE Order_Number__c IN :setOrderNumber]) {
			hClsResult clsResult = new hClsResult();
			clsResult.objOTN = objOTN;
			clsResult.objOLI = mapOLI.get(objOTN.Line_ID__c);
			lstResults.add(clsResult);
		}
	}
	
	///////////////////////////
	// Inner / Helper Classes
	///////////////////////////
	public class hClsResult {
		public Order_Line_Item__c objOLI {get;set;}
		public Order_Tracking_Number__c objOTN {get;set;}
	}
}