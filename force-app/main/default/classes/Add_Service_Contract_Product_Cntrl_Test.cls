/*
	Test class for Add_Service_Contract_Product_Cntrl.cls.

	MOD DATE		Who						Description
	04/23/2015		Chris Noe				Initial Release
	10/29/2019		Sophia Murphy (Demand Chain)
											Moved "startTest" up in the testContractFound method
*/

@isTest
private class Add_Service_Contract_Product_Cntrl_Test {

    //Test data setup method
    @testSetup
    static void testDataSetup() {
        //Create custom settings
    	Test_Environment_Utility.setupCustomSettings();
        
    	//Create End User Account for testing
    	Account oAccountEndUser = Test_Environment_Utility.createInsertAccountUS();
    	oAccountEndUser.Name='End User';
    	update oAccountEndUser;

    	//Create Reseller Account for testing
    	Account oAccountReseller = Test_Environment_Utility.createInsertAccountUS();
    	oAccountReseller.Name='Reseller';
    	update oAccountReseller;

    	//Create Distributor Account for testing
    	Account oAccountDistributor = Test_Environment_Utility.createInsertAccountUS();
    	oAccountDistributor.Name='Distributor';
    	update oAccountDistributor;

    	//Create Contact for testing
    	Contact oContact = Test_Environment_Utility.createInsertContact(oAccountEndUser);

    	//Create Products for testing
    	Product2 oProductService = Test_Environment_Utility.createInsertProduct();
    	oProductService.Item_Type__c='E-SERVICE';
    	oProductService.Name='SERVICE';
    	update oProductService;

    	Product2 oProductFG = Test_Environment_Utility.createInsertProduct();
    	oProductFG.Name='FG';
    	update oProductFG;

		// Create Pricebook and PBE
        Pricebook2 objServicePB = Test_Environment_Utility.createServicePricebookWithProduct(oProductService);
            
    	//Create Installed_Product__c for testing
    	//Installed_Product__c oInstalledProduct1 = Test_Environment_Utility.createInsertInstalledProductOracle('PRODUCT1', oAccountEndUser, oProductFG);
    	//Installed_Product__c oInstalledProduct2 = Test_Environment_Utility.createInsertInstalledProductOracle('PRODUCT2', oAccountEndUser, oProductFG);
		Asset oInstalledProduct1 = Test_Environment_Utility.createInsertInstalledProductOracle('PRODUCT1', oAccountEndUser, oProductFG);
    	Asset oInstalledProduct2 = Test_Environment_Utility.createInsertInstalledProductOracle('PRODUCT2', oAccountEndUser, oProductFG);
    	oInstalledProduct2.Oracle_Order_Number__c=oInstalledProduct1.Oracle_Order_Number__c;
    	update oInstalledProduct2;

    	//Create Service_Contract__c records for testing
    	//Service_Contract__c oServiceContract1 = Test_Environment_Utility.createInsertServiceContract('CONTRACT1', oAccountEndUser, oAccountDistributor, oAccountReseller, oProductService, oContact);
        //Service_Contract__c oServiceContract2 = Test_Environment_Utility.createInsertServiceContract('CONTRACT2', oAccountEndUser, oAccountDistributor, oAccountReseller, oProductService, oContact);
        //Service_Contract__c oServiceContract3 = Test_Environment_Utility.createInsertServiceContract('CONTRACT3', oAccountEndUser, oAccountDistributor, oAccountReseller, oProductService, oContact);
		ServiceContract oServiceContract1 = Test_Environment_Utility.createInsertServiceContract('CONTRACT1', oAccountEndUser, oAccountDistributor, oAccountReseller, oProductService, oContact, objServicePB);
        ServiceContract oServiceContract2 = Test_Environment_Utility.createInsertServiceContract('CONTRACT2', oAccountEndUser, oAccountDistributor, oAccountReseller, oProductService, oContact, objServicePB);
        ServiceContract oServiceContract3 = Test_Environment_Utility.createInsertServiceContract('CONTRACT3', oAccountEndUser, oAccountDistributor, oAccountReseller, oProductService, oContact, objServicePB);
    }

    static testmethod void testExceptionNoSearchNumber() {
		//Tests the Add_Service_Contract_Product_Cntrl.installedProductSearch method when no search number is entered by the user.

		//Retrieve the Service_Contract__c record.
		ServiceContract oServiceContract = [select Id, Service_SKU__c from ServiceContract where Name='CONTRACT1'];

        //Set page reference
        PageReference oPageRef = Page.AddServiceContractProduct;
        Test.setCurrentPage(oPageRef); 
        //Invoke the standard and extension controllers with Service_Contract__c record retrieved above
        ApexPages.StandardController oStdController = new ApexPages.StandardController(oServiceContract);
        oPageRef.getParameters().put('id',String.valueOf(oServiceContract.Id));
        oPageRef.getParameters().put('type','order');
        Add_Service_Contract_Product_Cntrl oExtController = new Add_Service_Contract_Product_Cntrl(oStdController);

        //Invoke the extension controller search method
        oExtController.installedProductSearch();

        //Assert page messages
        Boolean bFoundMessage=false;
        for(ApexPages.Message oMessage :ApexPages.getMessages()) {
            if(!String.isEmpty(oMessage.getDetail())) {
                bFoundMessage=true;
            }
        }	
        system.assert(bFoundMessage);
	}

    static testmethod void testOrderFound() {
		//Tests the Add_Service_Contract_Product_Cntrl.installedProductSearch method when a valid order number is entered by the user.

		//Retrieve the Service_Contract__c record.
		Pricebook2 objServicePB = [SELECT Id FROM Pricebook2 WHERE Name = 'SERVICE PRICE BOOK (Creating Service Contracts Only)'];
		ServiceContract oServiceContract = [select Id, Service_SKU__c from ServiceContract where Name='CONTRACT1'];
		oServiceContract.Pricebook2Id = objServicePB.Id;
        update oServiceContract;

		//Retrieve the Installed_Product__c record
		Asset oInstalledProduct = [select Id, Oracle_Order_Number__c from Asset limit 1];

        //Set page reference
        PageReference oPageRef = Page.AddServiceContractProduct;
        Test.setCurrentPage(oPageRef); 
        //Invoke the standard and extension controllers with Service_Contract__c record retrieved above
        ApexPages.StandardController oStdController = new ApexPages.StandardController(oServiceContract);
        oPageRef.getParameters().put('id',String.valueOf(oServiceContract.Id));
        oPageRef.getParameters().put('type','order');
        Add_Service_Contract_Product_Cntrl oExtController = new Add_Service_Contract_Product_Cntrl(oStdController);

        //Set the order number on the controller for search purposes
        oExtController.sSearchNumber = oInstalledProduct.Oracle_Order_Number__c;

        //Invoke the extension controller search method
        oExtController.installedProductSearch();

        //Assert list size of 2
        system.assertEquals(2,oExtController.listInstalledProducts.size());

        //Test select/unselect all methods
        oExtController.selectAll();
        for(Integer i=0;i<oExtController.listInstalledProducts.size();i++){
        	system.assertEquals(true,oExtController.listInstalledProducts[i].bSelected);
        }

        oExtController.unselectAll();
        for(Integer i=0;i<oExtController.listInstalledProducts.size();i++){
        	system.assertEquals(false,oExtController.listInstalledProducts[i].bSelected);
        }

        //Test addToContract method with no product selected
        oExtController.addToContract();

        //Assert page messages
        Boolean bFoundMessage=false;
        for(ApexPages.Message oMessage :ApexPages.getMessages()) {
            if(!String.isEmpty(oMessage.getDetail())) {
                bFoundMessage=true;
            }
        }	
        system.assert(bFoundMessage);

        //Select 1 record and then test addToContract method
        oExtController.listInstalledProducts[0].bSelected=true;
        oExtController.addToContract();

        //Assert variables
        system.assertEquals(false,oExtController.listInstalledProducts.isEmpty());
        system.assertEquals(true,oExtController.bRenderList);
        system.assertEquals('1',oExtController.sSearchSize);
        
        //Select remaining records and add to contract
        oExtController.selectAll();
        oExtController.addToContract();

        //Assert NULL search number
        system.assertEquals(NULL,oExtController.sSearchNumber);
    }

    static testmethod void testNoProductsFound() {
		//Tests the Add_Service_Contract_Product_Cntrl.installedProductSearch method when the search yields no results.

		//Retrieve the Service_Contract__c record.
		ServiceContract oServiceContract = [select Id, Service_SKU__c from ServiceContract where Name='CONTRACT1'];

		//Retrieve the Installed_Product__c record
		Asset oInstalledProduct = [select Id, Oracle_Order_Number__c from Asset limit 1];

        //Set page reference
        PageReference oPageRef = Page.AddServiceContractProduct;
        Test.setCurrentPage(oPageRef); 
        //Invoke the standard and extension controllers with Service_Contract__c record retrieved above
        ApexPages.StandardController oStdController = new ApexPages.StandardController(oServiceContract);
        oPageRef.getParameters().put('id',String.valueOf(oServiceContract.Id));
        oPageRef.getParameters().put('type','order');
        Add_Service_Contract_Product_Cntrl oExtController = new Add_Service_Contract_Product_Cntrl(oStdController);

        //Set the order number on the controller for search purposes
        oExtController.sSearchNumber = 'TEST';

        //Invoke the extension controller search method
        oExtController.installedProductSearch();

        //Assert list size of 1
        system.assertEquals(0,oExtController.listInstalledProducts.size());

        //Assert page messages
        Boolean bFoundMessage=false;
        for(ApexPages.Message oMessage :ApexPages.getMessages()) {
            if(!String.isEmpty(oMessage.getDetail())) {
                bFoundMessage=true;
            }
        }	
        system.assert(bFoundMessage);

        //Return to service contract
        system.assertEquals('/' + oServiceContract.Id, oExtController.returnToServiceContract().getURL());
    }

    static testmethod void testContractFound() {
        //Tests the Add_Service_Contract_Product_Cntrl.installedProductSearch method when a valid contract number is entered by the user.
        List<ContractLineItem> listServiceContractProducts = new List<ContractLineItem>();

        //Retrieve the old Service_Contract__c record.
        ServiceContract oServiceContractOld = [select Id, Pricebook2Id, Name from ServiceContract where Name='CONTRACT2'];
		
        //Retrieve Installed_Product__c records
        List<Asset> listInstalledProducts = [select Id, Product2Id from Asset];
		Set<Id> setProductIds = new Set<Id>();
		for(Asset objAsset : listInstalledProducts) {
			setProductIds.add(objAsset.Product2Id);
		}

		Pricebook2 objServicePB = [SELECT Id FROM Pricebook2 WHERE Name = 'SERVICE PRICE BOOK (Creating Service Contracts Only)'];
		oServiceContractOld.Pricebook2Id = objServicePB.Id;
        update oServiceContractOld;
        
		List<PricebookEntry> lstPBE = [SELECT Id FROM PricebookEntry WHERE Pricebook2Id = :objServicePB.Id];
		System.debug('PBEs?  = ' + lstPBE);

        //Add the Installed_Product__c records and add to the old service contract retrieved above
        for(Asset oInstalledProduct :listInstalledProducts){
            listServiceContractProducts.add(
				new ContractLineItem(
					AssetId=oInstalledProduct.Id,
					ServiceContractId=oServiceContractOld.Id,
					Quantity=1,
					PricebookEntryId = lstPBE[0].Id,
					UnitPrice = 0
				)
			);
        }

        insert listServiceContractProducts;

        //10.29.2019 - Sophia Murphy (Demand Chain)
        //Moved the startTest up, so that the Service Contract insert is run under a different context
        //and we don't get SOQL limits
       	Test.startTest();
        //Retrieve the new Service_Contract__c record.
        ServiceContract oServiceContractNew = [select Id, Pricebook2Id, Name, Service_SKU__c from ServiceContract where Name='CONTRACT3'];
		oServiceContractNew.Pricebook2Id = objServicePB.Id;
        update oServiceContractNew;

        //Create 1 service contract product for the new service contract
        ContractLineItem oNewServiceContractProduct = new ContractLineItem(
			AssetId=listInstalledProducts[0].Id,
			ServiceContractId=oServiceContractNew.Id,
			Quantity=1,
			PricebookEntryId = lstPBE[0].Id,
			UnitPrice = 0
		);
        insert oNewServiceContractProduct;

		//Test.startTest();		

        //Set page reference
        PageReference oPageRef = Page.AddServiceContractProduct;
        Test.setCurrentPage(oPageRef); 
        //Invoke the standard and extension controllers with Service_Contract__c record retrieved above
        ApexPages.StandardController oStdController = new ApexPages.StandardController(oServiceContractNew);
        oPageRef.getParameters().put('id',String.valueOf(oServiceContractNew.Id));
        oPageRef.getParameters().put('type','contract');
        Add_Service_Contract_Product_Cntrl oExtController = new Add_Service_Contract_Product_Cntrl(oStdController);

        //Set the contract number on the controller for search purposes
        oExtController.sSearchNumber = oServiceContractOld.Name;

        //Invoke the extension controller search method
        oExtController.installedProductSearch();

        //Assert list size of 1
        system.assertEquals(1,oExtController.listInstalledProducts.size());

        //Test select/unselect all methods
        oExtController.selectAll();
        for(Integer i=0;i<oExtController.listInstalledProducts.size();i++){
            system.assertEquals(true,oExtController.listInstalledProducts[i].bSelected);
        }

        oExtController.unselectAll();
        for(Integer i=0;i<oExtController.listInstalledProducts.size();i++){
            system.assertEquals(false,oExtController.listInstalledProducts[i].bSelected);
        }

        //Test addToContract method with no product selected
        oExtController.addToContract();

		Test.stopTest();

        //Assert page messages
        Boolean bFoundMessage=false;
        for(ApexPages.Message oMessage :ApexPages.getMessages()) {
            if(!String.isEmpty(oMessage.getDetail())) {
                bFoundMessage=true;
            }
        }   
        system.assert(bFoundMessage);

        //Select 1 record and then test addToContract method
        oExtController.listInstalledProducts[0].bSelected=true;
        oExtController.addToContract();

        //Assert variables
        system.assertEquals(true,oExtController.listInstalledProducts.isEmpty());
        system.assertEquals(false,oExtController.bRenderList);
        system.assertEquals('0',oExtController.sSearchSize);

        //Assert NULL search number
        system.assertEquals(NULL,oExtController.sSearchNumber);
    }
}