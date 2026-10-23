/*
	Controller class for the SeedUnitOrderSummary.page on the Seed_Unit_Order__c object.

	MOD DATE		Who						Description
	4/23/2014		Chris Noe				Initial Release
*/

public with sharing class Seed_Unit_Order_Summary_Controller {
    //Class variables
    public final Seed_Unit_Order__c oSeedUnitOrder;
    public String sOpptyRecordURL {get; private set;}
    public String sOrderRecordURL {get; private set;}
    public String sAddProductsURL {get; private set;}
    
	//Constructor method
    public Seed_Unit_Order_Summary_Controller(ApexPages.StandardController stdController) {
        //Get the current Seed_Unit_Order__c record
        this.oSeedUnitOrder = (Seed_Unit_Order__c)stdController.getRecord();
    	
    	//Build URL strings
		String sUrlRewrite = System.URL.getSalesforceBaseUrl().getHost();
	    String sfBaseProtocol = System.URL.getSalesforceBaseUrl().getProtocol();
	
	    //remove namespace
	    integer firstDotPos = sUrlRewrite.indexOf('.');
	    sURlRewrite = sURlRewrite.substring(firstDotPos+1);
	
	    //replace visual.force with salesforce
	    sURlRewrite = sURlRewrite.replace('visual.force', 'salesforce');
	    sUrlRewrite = sfBaseProtocol+'://'+sURlRewrite;
		
		//sOpptyRecordURL = sUrlRewrite + '/' + oSeedUnitOrder.Opportunity__c;
		//sOrderRecordURL = sUrlRewrite + '/' + oSeedUnitOrder.Id;
		//sAddProductsURL = sURLRewrite + '/a0K/e?CF00NG000000DHo8Q=' + oSeedUnitOrder.Name + '&CF00NG000000DHo8Q_lkid=' + oSeedUnitOrder.Id + '&retURL=%2F' + oSeedUnitOrder.Id;        

		sOpptyRecordURL = '/' + oSeedUnitOrder.Opportunity__c;
		sOrderRecordURL = '/' + oSeedUnitOrder.Id;
		sAddProductsURL = '/a0K/e?CF00NG000000DHo8Q=' + oSeedUnitOrder.Name + '&CF00NG000000DHo8Q_lkid=' + oSeedUnitOrder.Id + '&retURL=%2F' + oSeedUnitOrder.Id;
    }
    
    public String getFormattedSubmissionDate(){
    	return oSeedUnitOrder.Date_Time_Submitted_To_Oracle__c.format();
    }        
}