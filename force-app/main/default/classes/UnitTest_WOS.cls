@isTest 
private class UnitTest_WOS {

	@TestSetup static void dataSetup() {

		Test_Environment_Utility.setupCustomSettings();
		
		List<Product2> lstProducts = Test_Environment_Utility.generateFGProducts(10, true);
		Product2 objServiceProduct = lstProducts[0];
		objServiceProduct.Item_Type__c = 'E-SERVICE';
		update objServiceProduct;

		Pricebook2 objServicePB = Test_Environment_Utility.createServicePricebookWithProduct(objServiceProduct);

		Account objAcct = Test_Environment_Utility.createInsertAccountUS('9585474');
		Contact objContact = Test_Environment_Utility.createInsertContact(objAcct);

		Asset objAsset = Test_Environment_Utility.createInsertInstalledProductOracle('test asset', objAcct, objServiceProduct);
		
		ServiceContract objSC = Test_Environment_Utility.createInsertServiceContract('test contact',objAcct,objAcct,objAcct,objServiceProduct,objContact,objServicePB);
		ContractLineItem objCLI = new ContractLineItem(
				ServiceContractId = objSC.Id,
				AssetId = objAsset.Id,
				StartDate = System.today(),
				EndDate = System.today().addDays(90),
				PricebookEntryId = [SELECT Id FROM PricebookEntry WHERE Pricebook2Id = :objServicePB.Id LIMIT 1].Id,
				Quantity = 1,
				UnitPrice = 0
		);
		insert objCLI;

		Integration_Project__c objIP = Test_Environment_Utility.createInsertIntegrationProject('test IP', objAcct, objAcct, objAcct, objServiceProduct, objContact);
		objIP.Ergotron_PO__c = '123456';
		update objIP;

		Integration_Project_Service__c objTechLine = new Integration_Project_Service__c(
			Tech_Deployment_Record__c=objIP.Id,
			Contract_Line_Item__c = objCLI.Id
		);
		insert objTechLine;

	}

	@isTest
	private static void testWOSPONumberSpreaderNegative() {

		Test.startTest();

		Work_Order_Staging__c objWO = new Work_Order_Staging__c();
		insert objWO;

		objWO.PO_Number__c = '';
		update objWO;

		Test.stopTest();

	}

	@isTest
	private static void testWOSPONumberSpreaderPositive() {

		Test.startTest();

		Work_Order_Staging__c objWO = new Work_Order_Staging__c();
		insert objWO;

		objWO.PO_Number__c = '123456';
		update objWO;

		Test.stopTest();

	}
}