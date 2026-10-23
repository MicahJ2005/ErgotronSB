/*
	Test class for Add_Int_Project_Product_Cntrl.cls.

	MOD DATE		Who						Description
	07/20/2015		Chris Noe				Initial Release
*/

@isTest
private class Add_Int_Project_Product_Cntrl_Test {

    //Test data setup method
    @testSetup
    static void testDataSetup() {
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
		Pricebook2 objServicePB = Test_Environment_Utility.createServicePricebookWithProduct(oProductFG);

		//Create Installed_Product__c for testing
    	//Installed_Product__c oInstalledProduct1 = Test_Environment_Utility.createInsertInstalledProductOracle('PRODUCT1', oAccountEndUser, oProductFG);
    	//Installed_Product__c oInstalledProduct2 = Test_Environment_Utility.createInsertInstalledProductOracle('PRODUCT2', oAccountEndUser, oProductFG);
		Asset oInstalledProduct1 = Test_Environment_Utility.createInsertInstalledProductOracle('PRODUCT1', oAccountEndUser, oProductFG);
    	Asset oInstalledProduct2 = Test_Environment_Utility.createInsertInstalledProductOracle('PRODUCT2', oAccountEndUser, oProductFG);
    	oInstalledProduct2.Oracle_Order_Number__c=oInstalledProduct1.Oracle_Order_Number__c;
    	update oInstalledProduct2;

    	//Create Integration_Project__c record for testing
    	Integration_Project__c oIntProject1 = Test_Environment_Utility.createInsertIntegrationProject('INTPROJECT1', oAccountEndUser, oAccountDistributor, oAccountReseller, oProductService, oContact);
        
        //Create Service_Contract__c record for testing
        //Service_Contract__c oServiceContract = Test_Environment_Utility.createInsertServiceContract('CONTRACT1', oAccountEndUser, oAccountDistributor, oAccountReseller, oProductService, oContact);
		ServiceContract oServiceContract1 = Test_Environment_Utility.createInsertServiceContract('CONTRACT1', oAccountEndUser, oAccountDistributor, oAccountReseller, oProductService, oContact, objServicePB);
    }

    static testmethod void testExceptionNoSearchNumber() {
		//Tests the Add_Int_Project_Product_Cntrl.installedProductSearch method when no search number is entered by the user.

		//Retrieve the Integration_Project__c record.
		Integration_Project__c oIntProject = [select Id from Integration_Project__c where Name='INTPROJECT1'];

        //Set page reference
        PageReference oPageRef = Page.AddIntProjectProduct;
        Test.setCurrentPage(oPageRef); 
        //Invoke the standard and extension controllers with Integration_Project__c record retrieved above
        ApexPages.StandardController oStdController = new ApexPages.StandardController(oIntProject);
        oPageRef.getParameters().put('id',String.valueOf(oIntProject.Id));
        oPageRef.getParameters().put('type','order');
        Add_Int_Project_Product_Cntrl oExtController = new Add_Int_Project_Product_Cntrl(oStdController);

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
		//Tests the Add_Int_Project_Product_Cntrl.installedProductSearch method when a valid order number is entered by the user.

		//Retrieve the Integration_Project__c record.
		Integration_Project__c oIntProject = [select Id from Integration_Project__c where Name='INTPROJECT1'];

		//Retrieve the Installed_Product__c record
		Asset oInstalledProduct = [select Id, Oracle_Order_Number__c from Asset limit 1];

        //Set page reference
        PageReference oPageRef = Page.AddIntProjectProduct;
        Test.setCurrentPage(oPageRef); 
        //Invoke the standard and extension controllers with Integration_Project__c record retrieved above
        ApexPages.StandardController oStdController = new ApexPages.StandardController(oIntProject);
        oPageRef.getParameters().put('id',String.valueOf(oIntProject.Id));
        oPageRef.getParameters().put('type','order');
        Add_Int_Project_Product_Cntrl oExtController = new Add_Int_Project_Product_Cntrl(oStdController);

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

        //Test addToIntProject method with no product selected
        oExtController.addToIntProject();

        //Assert page messages
        Boolean bFoundMessage=false;
        for(ApexPages.Message oMessage :ApexPages.getMessages()) {
            if(!String.isEmpty(oMessage.getDetail())) {
                bFoundMessage=true;
            }
        }	
        system.assert(bFoundMessage);

        //Select 1 record and then test addToIntProject method
        oExtController.listInstalledProducts[0].bSelected=true;
        oExtController.addToIntProject();

        //Assert variables
        system.assertEquals(false,oExtController.listInstalledProducts.isEmpty());
        system.assertEquals(true,oExtController.bRenderList);
        system.assertEquals('1',oExtController.sSearchSize);
        
        //Select remaining records and add to contract
        oExtController.selectAll();
        oExtController.addToIntProject();

        //Assert NULL search number
        system.assertEquals(NULL,oExtController.sSearchNumber);
    }

    static testmethod void testNoProductsFound() {
		//Tests the Add_Int_Project_Product_Cntrl.installedProductSearch method when the search yields no results.

		//Retrieve the Integration_Project__c record.
		Integration_Project__c oIntProject = [select Id from Integration_Project__c where Name='INTPROJECT1'];

		//Retrieve the Installed_Product__c record
		Asset oInstalledProduct = [select Id, Oracle_Order_Number__c from Asset limit 1];

        //Set page reference
        PageReference oPageRef = Page.AddIntProjectProduct;
        Test.setCurrentPage(oPageRef); 
        //Invoke the standard and extension controllers with Integration_Project__c record retrieved above
        ApexPages.StandardController oStdController = new ApexPages.StandardController(oIntProject);
        oPageRef.getParameters().put('id',String.valueOf(oIntProject.Id));
        oPageRef.getParameters().put('type','order');
        Add_Int_Project_Product_Cntrl oExtController = new Add_Int_Project_Product_Cntrl(oStdController);

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
        system.assertEquals('/' + oIntProject.Id, oExtController.returnToIntProject().getURL());
    }

    static testmethod void testContractFound() {
        //Tests the Add_Service_Contract_Product_Cntrl.installedProductSearch method when a valid contract number is entered by the user.
        List<ContractLineItem> listServiceContractProducts = new List<ContractLineItem>();

        //Retrieve the Service_Contract__c record.
        ServiceContract oServiceContract = [select Id, Name from ServiceContract  where Name='CONTRACT1'];

		//Retrieve Installed_Product__c records
        List<Asset> listInstalledProducts = [select Id, Product2Id from Asset];
		Set<Id> setProductIds = new Set<Id>();
		for(Asset objAsset : listInstalledProducts) {
			setProductIds.add(objAsset.Product2Id);
		}

		Pricebook2 objServicePB = [SELECT Id FROM Pricebook2 WHERE Name = 'SERVICE PRICE BOOK (Creating Service Contracts Only)'];

		List<PricebookEntry> lstPBE = [SELECT Id FROM PricebookEntry WHERE Product2Id IN :setProductIds AND Pricebook2Id = :objServicePB.Id];
		System.debug('PBEs?  = ' + lstPBE);

        //Add the Installed_Product__c records to the service contract retrieved above
        for(Asset oInstalledProduct :listInstalledProducts){
            listServiceContractProducts.add(
				new ContractLineItem(
					AssetId=oInstalledProduct.Id,
					ServiceContractId=oServiceContract.Id,
					Quantity=1,
					PricebookEntryId = lstPBE[0].Id,
					UnitPrice = 0
				)
			);
        }

        insert listServiceContractProducts;

        //Retrieve the Integration_Project record.
        Integration_Project__c oIntProject = [select Id, Name from Integration_Project__c  where Name='INTPROJECT1'];

        //Set page reference
        PageReference oPageRef = Page.AddIntProjectProduct;
        Test.setCurrentPage(oPageRef); 
        //Invoke the standard and extension controllers with Integration_Project__c record retrieved above
        ApexPages.StandardController oStdController = new ApexPages.StandardController(oIntProject);
        oPageRef.getParameters().put('id',String.valueOf(oIntProject.Id));
        oPageRef.getParameters().put('type','contract');
        Add_Int_Project_Product_Cntrl oExtController = new Add_Int_Project_Product_Cntrl(oStdController);

        //Set the contract number on the controller for search purposes
        oExtController.sSearchNumber = oServiceContract.Name;

        //Invoke the extension controller search method
        oExtController.installedProductSearch();

        //Assert list size of 1
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

        //Test addToIntProject method with no product selected
        oExtController.addToIntProject();

        //Assert page messages
        Boolean bFoundMessage=false;
        for(ApexPages.Message oMessage :ApexPages.getMessages()) {
            if(!String.isEmpty(oMessage.getDetail())) {
                bFoundMessage=true;
            }
        }   
        system.assert(bFoundMessage);

        //Select all records and then test addToIntProject method
        oExtController.selectAll();
        oExtController.addToIntProject();

        //Assert variables
        system.assertEquals(true,oExtController.listInstalledProducts.isEmpty());
        system.assertEquals(false,oExtController.bRenderList);
        system.assertEquals('0',oExtController.sSearchSize);

        //Assert NULL search number
        system.assertEquals(NULL,oExtController.sSearchNumber);
    }
}