/*
    Controller class for the Lead_Convert_Reg_Cntrl.cls.

    MOD DATE        Who                     Description
    12/09/2014      Chris Noe               Initial Release
	20180517		Andy Boettcher DCS		Refactored to remove SeeAllData
*/

@IsTest()	//required for pricebook entries and custom settings
private class Lead_Convert_Reg_Cntrl_Test {
    
    @testSetup static void setupData() {
		
        Web_Service_Details__c oWebService = Test_Environment_Utility.createInsertWebServiceDetails('Territory Lookup');
        
        //We need a cc_acct_group created...
        ccrz__E_AccountGroup__c cAG = new ccrz__E_AccountGroup__c ();
        cAG.Name = 'Replacement Parts';
        insert cAG;

		Product2 objProduct = Test_Environment_Utility.createInsertProduct();
        Test_Environment_Utility.createServicePricebookWithProduct(objProduct);

		// Create Pricebooks
		List<Pricebook2> lstPricebooks = new List<Pricebook2>();
		lstPricebooks.add(new Pricebook2(Name='US STANDARD PRICE LIST',IsActive=true,CurrencyIsoCode='USD'));
		lstPricebooks.add(new Pricebook2(Name='EUROPE GBP SRP PRICE LIST',IsActive=true,CurrencyIsoCode='GBP'));
		lstPricebooks.add(new Pricebook2(Name='EUROPE EURO SRP PRICE LIST',IsActive=true,CurrencyIsoCode='EUR'));
		lstPricebooks.add(new Pricebook2(Name='EMEA-APAC USD STANDARD PRICE LIST',IsActive=true,CurrencyIsoCode='USD'));
		insert lstPricebooks;

		// Create PBEs
		List<PricebookEntry> lstPBEs = new List<PricebookEntry>();
		for(Pricebook2 objPB : lstPricebooks) {
			lstPBEs.add(
				new PricebookEntry(
					Product2Id = objProduct.Id,
					Pricebook2Id = objPB.Id,
					UnitPrice = 0,
					IsActive = true,
					CurrencyIsoCode = objPB.CurrencyIsoCode
				)
			);
		}

		insert lstPBEs;

    }

    static testmethod void testConvertReg() {
    	//Create user for test
    	User oUser = Test_Environment_Utility.createInsertUserSalesProfile();

      	//Create Account for test
        Account oEndUserAccount = Test_Environment_Utility.createInsertAccountUS('test-9999');
          Account oResellerAccount = Test_Environment_Utility.createInsertAccountUS('test-8888');
          oResellerAccount.Authorized_Reseller__c = True;
          update oResellerAccount;
      	Contact oResellerContact = Test_Environment_Utility.createInsertContact(oResellerAccount);

      	//Create Lead for test
    	Lead oLead = new Lead();
    	oLead.Company='Test';
    	oLead.FirstName='Test';
    	oLead.LastName='Test';
    	oLead.Ergotron_Vertical_Market__c='Enterprise';
    	oLead.Street='Test';
    	oLead.City='Test';
    	oLead.StateCode='MN';
    	oLead.PostalCode='55121';
    	oLead.CountryCode='US';
    	oLead.Territory_Account_Manager__c=oUser.Id;
    	oLead.Expiration_Date__c = Date.today()+120;
        oLead.Expected_Ship_Date__c = Date.today()+30;
    	oLead.Date_Approved__c = Date.today();
    	oLead.End_User_Account__c = oEndUserAccount.Id;
    	oLead.Rebate__c = String.valueOf(math.random()).left(20);
    	oLead.Partner_Account__c = oResellerAccount.Id;
    	oLead.Partner_Contact__c = oResellerContact.Id;
    	oLead.Status='Registration Approved - Priced';
    	oLead.Registration_Approval_Status__c='PM Approved - Priced';
    	oLead.Phone='8888888888';
    	oLead.Email= String.valueOf(math.random()).left(20) + '@test.com';
    	oLead.Total_Quantity__c=100;
        oLead.CurrencyIsoCode='USD';

    	insert oLead;

        //Get pricebook id for US STANDARD PRICE LIST
        Id idPricebookId = [select Id from Pricebook2 where Name='US STANDARD PRICE LIST'].Id;

    	//Find a product that is active in the US STANDARD PRICE LIST
    	Id idProductId = [select Product2Id from PricebookEntry where Pricebook2Id=:idPricebookId and IsActive=true and Product2.IsActive=true and Product2.Item_Type__c='E-FG' and
    						Product2.Inventory_Item_Status_Code__c='MASTER' and Product2.MSRP_US_STANDARD_USD__c>0 and Product2.Costing_Inventory__c='F' limit 1].Product2Id;

    	//Create Lead_Product__c record
    	Lead_Product__c oLeadProduct = new Lead_Product__c(Name='Product', Product__c=idProductId, Quantity__c=100, Lead__c=oLead.Id);
    	insert oLeadProduct;

        Test.startTest();
            PageReference oPageRef = Page.LeadConvertRegistration;
            Test.setCurrentPage(oPageRef);

            //Instantiate standard controller and controller extension
        	ApexPages.StandardController oStdController = new ApexPages.StandardController(oLead);
            oPageRef.getParameters().put('id',String.valueOf(oLead.Id));
            oPageRef.getParameters().put('type','dealreg');
        	Lead_Convert_Reg_Cntrl oExtController = new Lead_Convert_Reg_Cntrl(oStdController);

        	//Assert required fields
        	system.assertEquals(true,oExtController.bRequiredFields);

        	//Convert the registration
        	oPageRef = oExtController.convertRegistration();
        	String sURL = oPageRef.getUrl();
        	system.assertEquals(true,sURL.contains('leadconvertregistrationsummary'));
        Test.stopTest();
    }

    static testmethod void testConvertRegAlreadyConverted() {
    	//Create user for test
    	User oUser = Test_Environment_Utility.createInsertUserSalesProfile();

      	//Create Accounts for test
      	Account oEndUserAccount = Test_Environment_Utility.createInsertAccountUS('test-9998');
      	Account oResellerAccount = Test_Environment_Utility.createInsertAccountUS('test-8887');
      	Contact oResellerContact = Test_Environment_Utility.createInsertContact(oResellerAccount);
      	//Create Opportunity for test
      	Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oEndUserAccount, 'Proposal/Price Quote', Date.today());

      	//Create Lead for test
    	Lead oLead = new Lead();
    	oLead.Company='Test';
    	oLead.FirstName='Test';
    	oLead.LastName='Test';
    	oLead.Ergotron_Vertical_Market__c='Enterprise';
    	oLead.Street='Test';
    	oLead.City='Test';
    	oLead.StateCode='MN';
    	oLead.PostalCode='55121';
    	oLead.CountryCode='US';
    	oLead.Territory_Account_Manager__c=oUser.Id;
    	oLead.Expiration_Date__c = Date.today()+120;
        oLead.Expected_Ship_Date__c = Date.today()+30;
    	oLead.Date_Approved__c = Date.today();
    	oLead.End_User_Account__c = oEndUserAccount.Id;
    	oLead.Rebate__c = String.valueOf(math.random()).left(20);
    	oLead.Partner_Account__c = oResellerAccount.Id;
    	oLead.Partner_Contact__c = oResellerContact.Id;
    	oLead.Status = 'Registration Approved - Priced';
    	oLead.Registration_Approval_Status__c = 'PM Approved - Priced';
    	oLead.Phone = '8888888888';
    	oLead.Email = 'test@test.com';
    	oLead.Total_Quantity__c = 100;
    	oLead.Deal_Registration_Opportunity__c = oOpportunity.Id;

    	insert oLead;

        Test.startTest();
            PageReference oPageRef = Page.LeadConvertRegistration;
            Test.setCurrentPage(oPageRef);

            //Instantiate standard controller and controller extension
        	ApexPages.StandardController oStdController = new ApexPages.StandardController(oLead);
            oPageRef.getParameters().put('id',String.valueOf(oLead.Id));
            oPageRef.getParameters().put('type','dealreg');
        	Lead_Convert_Reg_Cntrl oExtController = new Lead_Convert_Reg_Cntrl(oStdController);

        	//Assert already converted
        	system.assertEquals(true,oExtController.bAlreadyConverted);
        Test.stopTest();
    }

    static testmethod void testConvertRegSPR() {
        //Create user for test
        User oUser = Test_Environment_Utility.createInsertUserSalesProfile();

        //Create Account for test
        Account oEndUserAccount = Test_Environment_Utility.createInsertAccountUS('test-9997');
        Account oResellerAccount = Test_Environment_Utility.createInsertAccountUS('test-8886');
        oResellerAccount.Authorized_Reseller__c = True;
        update oResellerAccount;
        Contact oResellerContact = Test_Environment_Utility.createInsertContact(oResellerAccount);

        //Create Lead for test
        Lead oLead = new Lead();
        oLead.Company='Test';
        oLead.FirstName='Test';
        oLead.LastName='Test';
        oLead.Ergotron_Vertical_Market__c='Enterprise';
        oLead.Street='Test';
        oLead.City='Test';
        oLead.StateCode='MN';
        oLead.PostalCode='55121';
        oLead.CountryCode='US';
        oLead.Territory_Account_Manager__c=oUser.Id;
        oLead.Expected_Ship_Date__c = Date.today()+30;
        oLead.End_User_Account__c = oEndUserAccount.Id;
        oLead.Partner_Account__c = oResellerAccount.Id;
        oLead.Partner_Contact__c = oResellerContact.Id;
        oLead.Status='Registration Rejected';
        oLead.Registration_Approval_Status__c='PM Rejected';
        oLead.Deal_Registration_Rejection_Reason__c='Moved To Special Pricing';
        oLead.Phone='8888888888';
        oLead.Email= String.valueOf(math.random()).left(20) + '@test.com';
        oLead.Total_Quantity__c=100;
        oLead.CurrencyIsoCode='USD';

        insert oLead;

        //Get pricebook id for US STANDARD PRICE LIST
        Id idPricebookId = [select Id from Pricebook2 where Name='US STANDARD PRICE LIST'].Id;

        //Find a product that is active in the US STANDARD PRICE LIST
        Id idProductId = [select Product2Id from PricebookEntry where Pricebook2Id=:idPricebookId and IsActive=true and Product2.IsActive=true and Product2.Item_Type__c='E-FG' and
                            Product2.Inventory_Item_Status_Code__c='MASTER' and Product2.MSRP_US_STANDARD_USD__c>0 and Product2.Costing_Inventory__c='F' limit 1].Product2Id;

        //Create Lead_Product__c record
        Lead_Product__c oLeadProduct = new Lead_Product__c(Product__c=idProductId, Quantity__c=100, Lead__c=oLead.Id);
        insert oLeadProduct;

        Test.startTest();
            PageReference oPageRef = Page.LeadConvertRegistration;
            Test.setCurrentPage(oPageRef);

            //Instantiate standard controller and controller extension
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oLead);
            oPageRef.getParameters().put('id',String.valueOf(oLead.Id));
            oPageRef.getParameters().put('type','spr');
            Lead_Convert_Reg_Cntrl oExtController = new Lead_Convert_Reg_Cntrl(oStdController);

            //Assert required fields
            system.assertEquals(true,oExtController.bRequiredFields);

            //Convert the registration
            oPageRef = oExtController.convertRegistration();
            String sURL = oPageRef.getUrl();
            system.assertEquals(true,sURL.contains('leadconvertregistrationsummary'));
        Test.stopTest();
    }

    static testmethod void testConvertRegEMEAEURO() {
        //Create user for test
        User oUser = Test_Environment_Utility.createInsertUserSalesProfileEMEA();

        //Create Account for test
        Account oEndUserAccount = Test_Environment_Utility.createInsertAccountUS('test-9996');
        Account oResellerAccount = Test_Environment_Utility.createInsertAccountUS('test-8885');
        Contact oResellerContact = Test_Environment_Utility.createInsertContact(oResellerAccount);

        //Create Lead for test
        Lead oLead = new Lead();
        oLead.Company='Test';
        oLead.FirstName='Test';
        oLead.LastName='Test';
        oLead.Ergotron_Vertical_Market__c='Enterprise';
        oLead.Street='Test';
        oLead.City='Test';
        oLead.StateCode='MN';
        oLead.PostalCode='55121';
        oLead.CountryCode='US';
        oLead.Territory_Account_Manager__c=oUser.Id;
        oLead.Expiration_Date__c = Date.today()+120;
        oLead.Expected_Ship_Date__c = Date.today()+30;
        oLead.Date_Approved__c = Date.today();
        oLead.End_User_Account__c = oEndUserAccount.Id;
        oLead.Rebate__c = String.valueOf(math.random()).left(20);
        oLead.Partner_Account__c = oResellerAccount.Id;
        oLead.Partner_Contact__c = oResellerContact.Id;
        oLead.Status='Registration Approved - Priced';
        oLead.Registration_Approval_Status__c='PM Approved - Priced';
        oLead.Phone='8888888888';
        oLead.Email= String.valueOf(math.random()).left(20) + '@test.com';
        oLead.Total_Quantity__c=100;
        oLead.CurrencyIsoCode='EUR';

        insert oLead;

        //Get pricebook id for EUROPE EURO SRP PRICE LIST
        Id idPricebookId = [select Id from Pricebook2 where Name='EUROPE EURO SRP PRICE LIST'].Id;

        //Find a product that is active in the EUROPE EURO SRP PRICE LIST
        Id idProductId = [select Product2Id from PricebookEntry where Pricebook2Id=:idPricebookId and IsActive=true and Product2.IsActive=true and Product2.Item_Type__c='E-FG' and
                            Product2.Inventory_Item_Status_Code__c='MASTER' and Product2.MSRP_EMEA_EUR__c>0 and Product2.Costing_Inventory__c='F' limit 1].Product2Id;

        //Create Lead_Product__c record
        Lead_Product__c oLeadProduct = new Lead_Product__c(Product__c=idProductId, Quantity__c=100, Lead__c=oLead.Id);
        insert oLeadProduct;

        Test.startTest();
            PageReference oPageRef = Page.LeadConvertRegistration;
            Test.setCurrentPage(oPageRef);

            //Instantiate standard controller and controller extension
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oLead);
            oPageRef.getParameters().put('id',String.valueOf(oLead.Id));
            oPageRef.getParameters().put('type','dealreg');
            Lead_Convert_Reg_Cntrl oExtController = new Lead_Convert_Reg_Cntrl(oStdController);

            //Assert required fields
            system.assertEquals(true,oExtController.bRequiredFields);

            //Convert the registration
            oPageRef = oExtController.convertRegistration();
            String sURL = oPageRef.getUrl();
            system.assertEquals(true,sURL.contains('leadconvertregistrationsummary'));
        Test.stopTest();
    }

    static testmethod void testConvertRegEMEAGBP() {
        //Create user for test
        User oUser = Test_Environment_Utility.createInsertUserSalesProfileEMEA();

        //Create Account for test
        Account oEndUserAccount = Test_Environment_Utility.createInsertAccountUS('test-9995');
        Account oResellerAccount = Test_Environment_Utility.createInsertAccountUS('test-8884');
        Contact oResellerContact = Test_Environment_Utility.createInsertContact(oResellerAccount);

        //Create Lead for test
        Lead oLead = new Lead();
        oLead.Company='Test';
        oLead.FirstName='Test';
        oLead.LastName='Test';
        oLead.Ergotron_Vertical_Market__c='Enterprise';
        oLead.Street='Test';
        oLead.City='Test';
        oLead.StateCode='MN';
        oLead.PostalCode='55121';
        oLead.CountryCode='US';
        oLead.Territory_Account_Manager__c=oUser.Id;
        oLead.Expiration_Date__c = Date.today()+120;
        oLead.Expected_Ship_Date__c = Date.today()+30;
        oLead.Date_Approved__c = Date.today();
        oLead.End_User_Account__c = oEndUserAccount.Id;
        oLead.Rebate__c = String.valueOf(math.random()).left(20);
        oLead.Partner_Account__c = oResellerAccount.Id;
        oLead.Partner_Contact__c = oResellerContact.Id;
        oLead.Status='Registration Approved - Priced';
        oLead.Registration_Approval_Status__c='PM Approved - Priced';
        oLead.Phone='8888888888';
        oLead.Email= String.valueOf(math.random()).left(20) + '@test.com';
        oLead.Total_Quantity__c=100;
        oLead.CurrencyIsoCode='GBP';

        insert oLead;

        //Get pricebook id for EUROPE GBP SRP PRICE LIST
        Id idPricebookId = [select Id from Pricebook2 where Name='EUROPE GBP SRP PRICE LIST'].Id;

        //Find a product that is active in the EUROPE GBP SRP PRICE LIST
        Id idProductId = [select Product2Id from PricebookEntry where Pricebook2Id=:idPricebookId and IsActive=true and Product2.IsActive=true and Product2.Item_Type__c='E-FG' and
                            Product2.Inventory_Item_Status_Code__c='MASTER' and Product2.MSRP_EMEA_GBP__c>0 and Product2.Costing_Inventory__c='F' limit 1].Product2Id;

        //Create Lead_Product__c record
        Lead_Product__c oLeadProduct = new Lead_Product__c(Product__c=idProductId, Quantity__c=100, Lead__c=oLead.Id);
        insert oLeadProduct;

        Test.startTest();
            PageReference oPageRef = Page.LeadConvertRegistration;
            Test.setCurrentPage(oPageRef);

            //Instantiate standard controller and controller extension
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oLead);
            oPageRef.getParameters().put('id',String.valueOf(oLead.Id));
            oPageRef.getParameters().put('type','dealreg');
            Lead_Convert_Reg_Cntrl oExtController = new Lead_Convert_Reg_Cntrl(oStdController);

            //Assert required fields
            system.assertEquals(true,oExtController.bRequiredFields);

            //Convert the registration
            oPageRef = oExtController.convertRegistration();
            String sURL = oPageRef.getUrl();
            system.assertEquals(true,sURL.contains('leadconvertregistrationsummary'));
        Test.stopTest();
    }

    static testmethod void testConvertRegEMEAUSD() {
        //Create user for test
        User oUser = Test_Environment_Utility.createInsertUserSalesProfileEMEA();

        //Create Account for test
        Account oEndUserAccount = Test_Environment_Utility.createInsertAccountUS('test-9994');
        Account oResellerAccount = Test_Environment_Utility.createInsertAccountUS('test-8883');
        Contact oResellerContact = Test_Environment_Utility.createInsertContact(oResellerAccount);

        //Create Lead for test
        Lead oLead = new Lead();
        oLead.Company='Test';
        oLead.FirstName='Test';
        oLead.LastName='Test';
        oLead.Ergotron_Vertical_Market__c='Enterprise';
        oLead.Street='Test';
        oLead.City='Test';
        oLead.StateCode='MN';
        oLead.PostalCode='55121';
        oLead.CountryCode='US';
        oLead.Territory_Account_Manager__c=oUser.Id;
        oLead.Expiration_Date__c = Date.today()+120;
        oLead.Expected_Ship_Date__c = Date.today()+30;
        oLead.Date_Approved__c = Date.today();
        oLead.End_User_Account__c = oEndUserAccount.Id;
        oLead.Rebate__c = String.valueOf(math.random()).left(20);
        oLead.Partner_Account__c = oResellerAccount.Id;
        oLead.Partner_Contact__c = oResellerContact.Id;
        oLead.Status='Registration Approved - Priced';
        oLead.Registration_Approval_Status__c='PM Approved - Priced';
        oLead.Phone='8888888888';
        oLead.Email= String.valueOf(math.random()).left(20) + '@test.com';
        oLead.Total_Quantity__c=100;
        oLead.CurrencyIsoCode='USD';

        insert oLead;

        //Get pricebook id for EUROPE GBP SRP PRICE LIST
        Id idPricebookId = [select Id from Pricebook2 where Name='EUROPE GBP SRP PRICE LIST'].Id;

        //Find a product that is active in the EUROPE GBP SRP PRICE LIST
        Id idProductId = [select Product2Id from PricebookEntry where Pricebook2Id=:idPricebookId and IsActive=true and Product2.IsActive=true and Product2.Item_Type__c='E-FG' and
                            Product2.Inventory_Item_Status_Code__c='MASTER' and Product2.MSRP_EMEA_GBP__c>0 and Product2.Costing_Inventory__c='F' limit 1].Product2Id;

        //Create Lead_Product__c record
        Lead_Product__c oLeadProduct = new Lead_Product__c(Product__c=idProductId, Quantity__c=100, Lead__c=oLead.Id);
        insert oLeadProduct;

        Test.startTest();
            PageReference oPageRef = Page.LeadConvertRegistration;
            Test.setCurrentPage(oPageRef);

            //Instantiate standard controller and controller extension
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oLead);
            oPageRef.getParameters().put('id',String.valueOf(oLead.Id));
            oPageRef.getParameters().put('type','dealreg');
            Lead_Convert_Reg_Cntrl oExtController = new Lead_Convert_Reg_Cntrl(oStdController);

            //Assert required fields
            system.assertEquals(true,oExtController.bRequiredFields);

            //Convert the registration
            oPageRef = oExtController.convertRegistration();
            String sURL = oPageRef.getUrl();
            system.assertEquals(true,sURL.contains('leadconvertregistrationsummary'));
        Test.stopTest();
    }

    static testmethod void testConvertRegAPAC() {
        //Create user for test
        User oUser = Test_Environment_Utility.createInsertUserSalesProfileAPAC();

        //Create Account for test
        Account oEndUserAccount = Test_Environment_Utility.createInsertAccountUS('test-9993');
        Account oResellerAccount = Test_Environment_Utility.createInsertAccountUS('test-8882');
        Contact oResellerContact = Test_Environment_Utility.createInsertContact(oResellerAccount);

        //Create Lead for test
        Lead oLead = new Lead();
        oLead.Company='Test';
        oLead.FirstName='Test';
        oLead.LastName='Test';
        oLead.Ergotron_Vertical_Market__c='Enterprise';
        oLead.Street='Test';
        oLead.City='Test';
        oLead.StateCode='MN';
        oLead.PostalCode='55121';
        oLead.CountryCode='US';
        oLead.Territory_Account_Manager__c=oUser.Id;
        oLead.Expiration_Date__c = Date.today()+120;
        oLead.Expected_Ship_Date__c = Date.today()+30;
        oLead.Date_Approved__c = Date.today();
        oLead.End_User_Account__c = oEndUserAccount.Id;
        oLead.Rebate__c = String.valueOf(math.random()).left(20);
        oLead.Partner_Account__c = oResellerAccount.Id;
        oLead.Partner_Contact__c = oResellerContact.Id;
        oLead.Status='Registration Approved - Priced';
        oLead.Registration_Approval_Status__c='PM Approved - Priced';
        oLead.Phone='8888888888';
        oLead.Email= String.valueOf(math.random()).left(20) + '@test.com';
        oLead.Total_Quantity__c=100;
        oLead.CurrencyIsoCode='USD';

        insert oLead;

        //Get pricebook id for EMEA-APAC USD STANDARD PRICE LIST
        Id idPricebookId = [select Id from Pricebook2 where Name='EMEA-APAC USD STANDARD PRICE LIST'].Id;

        //Find a product that is active in the EMEA-APAC USD STANDARD PRICE LIST'
        Id idProductId = [select Product2Id from PricebookEntry where Pricebook2Id=:idPricebookId and IsActive=true and Product2.IsActive=true and Product2.Item_Type__c='E-FG' and
                            Product2.Inventory_Item_Status_Code__c='MASTER' and Product2.MSRP_EMEA_APAC_USD__c>0 and Product2.Costing_Inventory__c='F' limit 1].Product2Id;

        //Create Lead_Product__c record
        Lead_Product__c oLeadProduct = new Lead_Product__c(Product__c=idProductId, Quantity__c=100, Lead__c=oLead.Id);
        insert oLeadProduct;

        Test.startTest();
            PageReference oPageRef = Page.LeadConvertRegistration;
            Test.setCurrentPage(oPageRef);

            //Instantiate standard controller and controller extension
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oLead);
            oPageRef.getParameters().put('id',String.valueOf(oLead.Id));
            oPageRef.getParameters().put('type','dealreg');
            Lead_Convert_Reg_Cntrl oExtController = new Lead_Convert_Reg_Cntrl(oStdController);

            //Assert required fields
            system.assertEquals(true,oExtController.bRequiredFields);

            //Convert the registration
            oPageRef = oExtController.convertRegistration();
            String sURL = oPageRef.getUrl();
            system.assertEquals(true,sURL.contains('leadconvertregistrationsummary'));
        Test.stopTest();
    }
}