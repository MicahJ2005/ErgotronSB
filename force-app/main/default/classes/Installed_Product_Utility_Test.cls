/*
	Test class for Installed_Product_Trigger.trigger and Installed_Product_Utility.cls.

	MOD DATE		Who						Description
	04/23/2015		Chris Noe				Initial Release
*/

@isTest
private class Installed_Product_Utility_Test {
    ////Test data setup method
    //@testSetup
    //static void testDataSetup() {
    	////Create Account for testing
    	//Account oAccount = Test_Environment_Utility.createInsertAccountUS();

        ////Create Second Account for testing
        //Account oAccount2 = Test_Environment_Utility.createInsertAccountCA();

        //Contact oContact = Test_Environment_Utility.createInsertContact(oAccount);

    	////Create Product for testing
    	//Product2 oProduct = Test_Environment_Utility.createInsertProduct();

    	////Create Installed_Product__c for testing
    	//Installed_Product__c oInstalledProduct = Test_Environment_Utility.createInsertInstalledProductOracle('TEST', oAccount, oProduct);

        ////Create Case for testing, with account that matches Installed Product
        //Id rtCaseId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Global Service Support').getRecordTypeId();
        //Case oCase = Test_Environment_Utility.createInsertCase(oAccount, oContact, oInstalledProduct, rtCaseId);
    //}

    //static testmethod void testBeforeDelete() {
    	//Installed_Product__c oInstalledProduct = [select Id from Installed_Product__c limit 1];

    	////Try to delete and assert error message is returned
    	//try{
    		//delete oInstalledProduct;
    	//}
    	//catch(Exception oException) {
    		//system.assert(!String.isEmpty(oException.getMessage()));
    	//}
    //}

    //static testmethod void testBeforeUpdate() {
        ////Installed_Product_Utility_Test.testDataSetup();
        //Installed_Product__c oInstalledProduct = [select Id, Customer_Name__c from Installed_Product__c limit 1];
        //Case oCase = [select Id from Case limit 1];
        //Account oAccount = [select Id from Account Where BillingCountryCode='US' limit 1];
        //Account oAccount2 = [select Id from Account Where BillingCountryCode='CA' limit 1];
        
        ////Try to update the Installed product Account to a different account from the case
       //try{
            //oInstalledProduct.Customer_Name__c = oAccount2.id;
            //update oInstalledProduct;
       //}
        //catch(Exception oException) {
            //system.assert(!String.isEmpty(oException.getMessage()));

        //}
    //}
}