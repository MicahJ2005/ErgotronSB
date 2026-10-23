/*
	Test class for Add_Int_Project_Product_Cntrl.cls.

	MOD DATE		Who						Description
	20170303		Andy Boettcher DCS 		Initial Release
	20180517		Andy Boettcher DCS		Sunsetted for Lightning Service Console
*/

@isTest
private class ServiceContractProductSearch_UnitTest {

	////Test data setup method
    //@testSetup static void testDataSetup() {
		////Create End User Account for testing
		//Account oAccountEndUser = Test_Environment_Utility.createInsertAccountUS();
		//oAccountEndUser.Name='End User';
		//update oAccountEndUser;

		////Create Reseller Account for testing
		//Account oAccountReseller = Test_Environment_Utility.createInsertAccountUS();
		//oAccountReseller.Name='Reseller';
		//update oAccountReseller;

		////Create Distributor Account for testing
		//Account oAccountDistributor = Test_Environment_Utility.createInsertAccountUS();
		//oAccountDistributor.Name='Distributor';
		//update oAccountDistributor;

		////Create Contact for testing
		//Contact oContact = Test_Environment_Utility.createInsertContact(oAccountEndUser);

		////Create Products for testing
		//Product2 oProductService = Test_Environment_Utility.createInsertProduct();
		//oProductService.Item_Type__c='E-SERVICE';
		//oProductService.Name='SERVICE';
		//update oProductService;

		//Product2 oProductFG = Test_Environment_Utility.createInsertProduct();
		//oProductFG.Name='FG';
		//update oProductFG;

		////Create Installed_Product__c for testing
		//Installed_Product__c oInstalledProduct1 = Test_Environment_Utility.createInsertInstalledProductOracle('PRODUCT1', oAccountEndUser, oProductFG);
		//Installed_Product__c oInstalledProduct2 = Test_Environment_Utility.createInsertInstalledProductOracle('PRODUCT2', oAccountEndUser, oProductFG);
		//oInstalledProduct2.Oracle_Order_Number__c=oInstalledProduct1.Oracle_Order_Number__c;
		//update oInstalledProduct2;

		////Create Service_Contract__c record for testing
		//Service_Contract__c oServiceContract = Test_Environment_Utility.createInsertServiceContract('CONTRACT1', oAccountEndUser, oAccountDistributor, oAccountReseller, oProductService, oContact);

		//// Create Service Contact Products
		//insert new Service_Contract_Product__c(Service_Contract__c=oServiceContract.Id, Installed_Product__c=oInstalledProduct1.Id);
       
    //}

    //@isTest
    //static void testController() {

    	//Service_Contract__c objSC = [SELECT Id FROM Service_Contract__c LIMIT 1];
    	//Account objAcct = [SELECT Id FROM Account WHERE Name='End User'];

    	//Test.setCurrentPage(Page.ServiceContractProductsSearchPage);
    	//System.currentPageReference().getParameters().put('id', objSC.Id);
    	//System.currentPageReference().getParameters().put('customerId', objAcct.Id);

    	//ServiceContractProductSearchController clsSCP = new ServiceContractProductSearchController(new ApexPages.StandardController(objSC));
    	//clsSCP.searchstring = 'PRODUCT1';
    	//clsSCP.search();

    	//clsSCP.ipId = [SELECT Id FROM Installed_Product__c LIMIT 1].Id;

    	//clsSCP.saveScpRecord();

    //}

}