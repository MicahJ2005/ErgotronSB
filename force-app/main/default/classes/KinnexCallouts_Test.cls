@isTest
private class KinnexCallouts_Test {
    static testmethod void unitTest1() {
        
        //Setup the Firestore custom setting
        web_Service_Details__c wsD = new web_Service_Details__c();
        wsD.Name = 'Firestore';
        wsD.Client_Email__c = 'something@test.com';
        wsD.Endpoint__c = 'endpoint/';
        wsD.Name_Audience__c = 'something';
        wsD.Private_Key_Id__c = 'keyMeSomething';
        wsD.Project_Id__c = 'projectId';
        wsD.Description_Where_Used__c = 'used in test class';
        wsD.Exception_Email__c = 'something@test.com';
        insert wsD;
        
        //Create Account for testing
    	Account oAccount = Test_Environment_Utility.createInsertAccountUS();

		//Create Product for testing
    	Product2 oProduct = Test_Environment_Utility.createInsertProduct();

    	//Create Installed_Product__c for testing
    	Asset oInstalledProduct = Test_Environment_Utility.createInsertInstalledProductOracle('TEST', oAccount, oProduct);

    	//Create web service details for testing
        //Web_Service_Details__c oWebServiceDetail = Test_Environment_Utility.createInsertWebServiceDetails('Ship To Site Use Lookup');
        Set<Id> assetIds = new Set<Id>();
        assetIds.add(oInstalledProduct.Id);
        
        KinnexCallouts.doKinnexCallout(assetIds);
    }
}