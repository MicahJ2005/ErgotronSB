/*
    Test class for the Deal_Reg_Cntrl.cls.

    MOD DATE        Who                     Description
    11/04/2014      Chris Noe               Initial Release 
*/

@IsTest
private class Deal_Reg_Cntrl_Test {

    static testmethod void testControllerSave() {
		//Get user for testing
		User oUser = [select Id from User where ProfileId='00eG0000000g7Ph' and IsActive=true limit 1];

		//Create web service details record record by lead assignment callout
		Web_Service_Details__c oWebService = Test_Environment_Utility.createInsertWebServiceDetails('Territory Lookup');

    	//Create product for test
    	Product2 oProduct = Test_Environment_Utility.createInsertProduct();
    	oProduct.Item_Type__c='E-FG';
    	oProduct.Inventory_Item_Status_Code__c='MASTER';
    	oProduct.IsActive=true;
    	oProduct.MSRP_EMEA_APAC_USD__c=10;
    	oProduct.MSRP_EMEA_EUR__c=10;
    	oProduct.MSRP_EMEA_GBP__c=10;
    	oProduct.MSRP_US_STANDARD_USD__c=10;
    	oProduct.ProductCode='TEST';
    	update oProduct;

		system.runAs(oUser) {
			Test.startTest();
		    	Lead oLead = new Lead();

		    	ApexPages.StandardController oStdController = new ApexPages.StandardController(oLead);
		    	Deal_Reg_Cntrl oExtController = new Deal_Reg_Cntrl(oStdController);

		    	//Test cancelReturn method
		    	system.assertEquals('/home/home.jsp',oExtController.cancelReturn().getUrl());

		    	//Test save for later
		    	oLead.Company='Test';
		    	oLead.LastName='Test';
		    	//Save without product
		    	system.assertEquals('/apex/dealregsaveconfirm',oExtController.saveForLater().getUrl());

		    	//Reload the lead
				oStdController = new ApexPages.StandardController(oLead);
				oExtController = new Deal_Reg_Cntrl(oStdController);
		    	Lead_Product__c oLeadProduct1 = new Lead_Product__c(Product__c=oProduct.Id, Quantity__c=100);
		    	Lead_Product__c oLeadProduct2 = new Lead_Product__c(Product__c=oProduct.Id, Quantity__c=50);
		    	oExtController.listLeadProducts.add(oLeadProduct1);
		    	oExtController.listLeadProducts.add(oLeadProduct2);
		    	//Save with product
		    	system.assertEquals('/apex/dealregsaveconfirm',oExtController.saveForLater().getUrl());

		    	//Reload the lead
				oStdController = new ApexPages.StandardController(oLead);
				oExtController = new Deal_Reg_Cntrl(oStdController);

		    	//Test remove product row
		    	oExtController.sSelectedProduct='1';
		    	oExtController.removeProduct();
		    	system.assertEquals(false,oExtController.bShowDelete);  	
	    	Test.stopTest(); 
	    }
    }

    static testmethod void testControllerSubmit() {
		//Get user for testing
		User oUser = [select Id from User where ProfileId='00eG0000000g7Ph' and IsActive=true limit 1];
		
		//Create web service details record record by lead assignment callout
		Web_Service_Details__c oWebService = Test_Environment_Utility.createInsertWebServiceDetails('Territory Lookup');

    	//Create product for test
    	Product2 oProduct = Test_Environment_Utility.createInsertProduct();
    	oProduct.Item_Type__c='E-FG';
    	oProduct.Inventory_Item_Status_Code__c='MASTER';
    	oProduct.IsActive=true;
    	oProduct.MSRP_EMEA_APAC_USD__c=10;
    	oProduct.MSRP_EMEA_EUR__c=10;
    	oProduct.MSRP_EMEA_GBP__c=10;
    	oProduct.MSRP_US_STANDARD_USD__c=10;
    	oProduct.ProductCode='TEST';
    	update oProduct;

		system.runAs(oUser) {
		    Test.startTest();	
		    	Lead oLead = new Lead();

		    	ApexPages.StandardController oStdController = new ApexPages.StandardController(oLead);
		    	Deal_Reg_Cntrl oExtController = new Deal_Reg_Cntrl(oStdController);

		    	//Testing Submit
		    	oLead.Company='Test';
		    	oLead.LastName='Test';
		    	//Submit - FirstName Required
		    	system.assertEquals(null,oExtController.submitDealReg());
				
				oLead.FirstName='Test';
		    	//Submit - Street Required
		    	system.assertEquals(null,oExtController.submitDealReg());

				oLead.Street='Test';
		    	//Submit - City Required
		    	system.assertEquals(null,oExtController.submitDealReg());

				oLead.City='Test';
		    	//Submit - Email Required
		    	system.assertEquals(null,oExtController.submitDealReg());

				oLead.Email='test@test.com';
		    	//Submit - StateCode Required
		    	oLead.CountryCode='US';
		    	system.assertEquals(null,oExtController.submitDealReg());

				oLead.StateCode='MN';
		    	//Submit - Phone Required
		    	system.assertEquals(null,oExtController.submitDealReg());

				oLead.Phone='8888888888';
		    	//Submit - PostalCode Required
		    	system.assertEquals(null,oExtController.submitDealReg());

				oLead.PostalCode='55121';
		    	//Submit - CountryCode Required
		    	oLead.CountryCode=NULL;
		    	system.assertEquals(null,oExtController.submitDealReg());

				oLead.CountryCode='US';
		    	//Submit - Ergotron Vertical Market Required
		    	system.assertEquals(null,oExtController.submitDealReg());
		    	
		    	oLead.Ergotron_Vertical_Market__c='Enterprise';
		    	//Submit - Expected_Ship_Date__c Required
		    	system.assertEquals(null,oExtController.submitDealReg());

				oLead.Expected_Ship_Date__c=Date.today();
				oLead.Description='';
		    	//Submit - Description Required
		    	system.assertEquals(null,oExtController.submitDealReg());

		    	oLead.Description='TEST DESCRIPTION';
	
            
		    	//Add product with quantity
		    	Lead_Product__c oLeadProduct = new Lead_Product__c(Product__c=oProduct.Id, Quantity__c=100);
		    	oExtController.listLeadProducts.add(oLeadProduct);
		    	
		    	//Submit with Product and Quantity selected
		    	//need oppPartner set..
		    	oExtController.setOppPartner('001TEST');
				system.assertEquals('/apex/dealregnewconfirm',oExtController.submitDealReg().getUrl());
			Test.stopTest(); 
		}
		   
	}

    static testmethod void testControllerSubmitDraft() {
		//Get user for testing
		User oUser = [select Id from User where ProfileId='00eG0000000g7Ph' and IsActive=true and CountryCode='US' limit 1];

		//Create web service details record record by lead assignment callout
		Web_Service_Details__c oWebService = Test_Environment_Utility.createInsertWebServiceDetails('Territory Lookup');

    	//Create product for test
    	Product2 oProduct = Test_Environment_Utility.createInsertProduct();
    	oProduct.Item_Type__c='E-FG';
    	oProduct.Inventory_Item_Status_Code__c='MASTER';
    	oProduct.IsActive=true;
    	oProduct.MSRP_EMEA_APAC_USD__c=10;
    	oProduct.MSRP_EMEA_EUR__c=10;
    	oProduct.MSRP_EMEA_GBP__c=10;
    	oProduct.MSRP_US_STANDARD_USD__c=10;
    	oProduct.ProductCode='TEST';
    	update oProduct;

    	system.runAs(oUser) {
	    	Test.startTest();
		    	Lead oLead = new Lead();

		    	ApexPages.StandardController oStdController = new ApexPages.StandardController(oLead);
		    	Deal_Reg_Cntrl oExtController = new Deal_Reg_Cntrl(oStdController);

		    	//Testing Submit
		    	oLead.Company='Test';
		    	oLead.LastName='Test';
				//Save without product
		    	system.assertEquals('/apex/dealregsaveconfirm',oExtController.saveForLater().getUrl());
		    	
		    	//Update with required fields
				oLead.FirstName='Test';
		    	oLead.Street='Test';
		    	oLead.City='Test';
		    	oLead.Email='test@test.com';
		    	oLead.Phone='8888888888';
		    	oLead.PostalCode='55121';
		    	oLead.CountryCode='US';
		    	oLead.StateCode='MN';
		    	oLead.Expected_Ship_Date__c=Date.today();
				oLead.Description='TEST DESCRIPTION';
				oLead.Status='Registration Approved - Pending Pricing';
				oLead.Ergotron_Vertical_Market__c='Enterprise';
            	
				//Submit - Parts Required
		    	system.assertEquals(null,oExtController.submitDealReg());

		    	//Add product with quantity
		    	Lead_Product__c oLeadProduct = new Lead_Product__c(Product__c=oProduct.Id, Quantity__c=100);
		    	oExtController.listLeadProducts.add(oLeadProduct);
		    	
		    	//Submit with Product and Quantity selected
		    	//need oppPartner set..
		    	oExtController.setOppPartner('001TEST');
				system.assertEquals('/apex/dealregnewconfirm',oExtController.submitDealReg().getUrl());
			Test.stopTest(); 	
		}   
	}

    static testmethod void testControllerSubmitExceptions() {
		//Get user for testing
		User oUser = [select Id from User where ProfileId='00eG0000000g7Ph' and IsActive=true limit 1];
		
		//Create web service details record record by lead assignment callout
		Web_Service_Details__c oWebService = Test_Environment_Utility.createInsertWebServiceDetails('Territory Lookup');

    	//Create product for test
    	Product2 oProduct = Test_Environment_Utility.createInsertProduct();
    	oProduct.Item_Type__c='E-FG';
    	oProduct.Inventory_Item_Status_Code__c='MASTER';
    	oProduct.IsActive=true;
    	oProduct.MSRP_EMEA_APAC_USD__c=10;
    	oProduct.MSRP_EMEA_EUR__c=10;
    	oProduct.MSRP_EMEA_GBP__c=10;
    	oProduct.MSRP_US_STANDARD_USD__c=10;
    	oProduct.ProductCode='TEST';
    	update oProduct;

		system.runAs(oUser) {
		    Test.startTest();	
		    	//TEST NON-US/CA
		    	Lead oLead = new Lead();

		    	ApexPages.StandardController oStdController = new ApexPages.StandardController(oLead);
		    	Deal_Reg_Cntrl oExtController = new Deal_Reg_Cntrl(oStdController);

		    	//Populate Lead Fields
		    	oLead.Company='Test';
		    	oLead.LastName='Test';
				oLead.FirstName='Test';
		    	oLead.Street='Test';
		    	oLead.City='Test';
		    	oLead.Email='test@test.com';
		    	oLead.Phone='8888888888';
		    	oLead.PostalCode='55121';
		    	oLead.CountryCode='AU';
		    	oLead.StateCode='NT';
		    	oLead.Expected_Ship_Date__c=Date.today();
				oLead.Description='TEST DESCRIPTION';
				oLead.Status='Registration Approved - Pending Pricing';
				oLead.Ergotron_Vertical_Market__c='Enterprise';

				//Submit - Parts Required
		    	system.assertEquals(null,oExtController.submitDealReg());

		    	//Add product with quantity
		    	Lead_Product__c oLeadProduct = new Lead_Product__c(Product__c=oProduct.Id, Quantity__c=100);
		    	oExtController.listLeadProducts.add(oLeadProduct);
		    	
		    	//Submit with Product and Quantity selected
				system.assertEquals('/apex/dealregnewconfirm',oExtController.submitDealReg().getUrl());

		    	//TEST US/CA
		    	oLead = new Lead();

		    	oStdController = new ApexPages.StandardController(oLead);
		    	oExtController = new Deal_Reg_Cntrl(oStdController);

		    	//Populate Lead Fields
		    	oLead.Company='Test';
		    	oLead.LastName='Test';
				oLead.FirstName='Test';
		    	oLead.Street='Test';
		    	oLead.City='Test';
		    	oLead.Email='test@test.com';
		    	oLead.Phone='8888888888';
		    	oLead.PostalCode='55121';
		    	oLead.CountryCode='US';
		    	oLead.StateCode='MN';
		    	oLead.Expected_Ship_Date__c=Date.today();
				oLead.Description='TEST DESCRIPTION';
				oLead.Status='Registration Approved - Pending Pricing';
				oLead.Ergotron_Vertical_Market__c='Enterprise';

		    	//Add product with NO quantity
		    	oLeadProduct = new Lead_Product__c(Product__c=oProduct.Id);
		    	oExtController.listLeadProducts.add(oLeadProduct);
		    	
		    	//Submit with Product and no Quantity
				system.assertEquals(null,oExtController.submitDealReg());
			Test.stopTest(); 	
		}
	}
}