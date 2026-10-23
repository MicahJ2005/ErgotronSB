/*
    Test class utility used by all test classes

    MOD DATE        Who                     Description
    4/23/2014       Chris Noe               Initial Release
    5/20/2014       Chris Noe               Added createOpportunity method
    6/24/2014       Chris Noe               Updated createInsertAccount method to support new corporate address validation rule
    10/9/2014       Chris Noe               Updates related to FB-00368.  Added method "createInsertAccountCN", "createInsertIntegrationId", and
                                            "createInsertWebServiceDetails".  Updated method "createInsertContact" to include Email and Phone.
    20160118        Andy Boettcher          Added "setupCustomSettings" to help move UTs off of "seeAllData=true"
*/

@isTest
public class Test_Environment_Utility {
    
    public static void setupCustomSettings() {
        
        Customer_Service_Flow_Variables__c csVariables = new Customer_Service_Flow_Variables__c(Name='Current');
        csVariables.Contract_Days__c = 30;
        insert csVariables;
        
        PricebookBatch__c pbBatch = PricebookBatch__c.getOrgDefaults();
        pbBatch.Batch_Size__c = 10;
        pbBatch.Last_Run_Time__c = DateTime.now().addMinutes(-2);
        insert pbBatch;
        
        
    }

	public static void createWarrantyBHBusinessHours() {
		//BusinessHours objBH = new BusinessHours(
			//Name='WarrantyBH',
			//IsActive = true,
			//MondayEndTime = Time.newInstance(0,0,0,0),
			//TuesdayEndTime = Time.newInstance(0,0,0,0),
			//WednesdayEndTime = Time.newInstance(0,0,0,0),
			//ThursdayEndTime = Time.newInstance(0,0,0,0),
			//FridayEndTime = Time.newInstance(0,0,0,0),
			//SaturdayEndTime = Time.newInstance(0,0,0,0),
			//SundayEndTime = Time.newInstance(0,0,0,0),
			//MondayStartTime = Time.newInstance(0,0,0,0),
			//TuesdayStartTime = Time.newInstance(0,0,0,0),
			//WednesdayStartTime = Time.newInstance(0,0,0,0),
			//ThursdayStartTime = Time.newInstance(0,0,0,0),
			//FridayStartTime = Time.newInstance(0,0,0,0),
			//SaturdayStartTime = Time.newInstance(0,0,0,0),
			//SundayStartTime = Time.newInstance(0,0,0,0),
			//TimeZoneSidKey = 'America/Chicago'
		//);

		//insert objBH;
	}

    //Create and insert new account - United States
    public static Account createInsertAccountUS(){
        
        return createInsertAccountUS(null);
        
    }
    
    public static Account createInsertAccountUS(String strOracleAccountNumber) {
        
        Id rtStandard = Schema.SObjectType.Account.RecordTypeInfosByName.get('Site').RecordTypeId;
        
        Account oNewAccount = new Account(
            Name='CODE UNIT TEST' + Test_Environment_Utility.generateRandomString(10), 
            BillingStreet=Test_Environment_Utility.generateRandomString(10) + ' UNIT TEST JUMP STREET', 
            BillingCity='Boston', 
            BillingState='Massachusetts', 
            BillingPostalCode='02201', 
            BillingCountry='United States', 
            BillingCountryCode='US',
            RecordTypeId = rtStandard,
            Customer_Account_Id__c='ERGO' + String.valueOf(getRandomInt(1, 999)),
            Oracle_Party_Number__c = strOracleAccountNumber,
            Oracle_Party_Status__c = 'A',
            Discount_Class__c='BROADLINE US DISCOUNT',
            Account_Number__c='ERGO' + String.valueOf(getRandomInt(1, 999)),
			IsAddressValidated__c=TRUE
        );
        insert oNewAccount;
        return oNewAccount;
    }

    //Create and insert new account - Canada
    public static Account createInsertAccountCA(){
        Account oNewAccount = new Account(
			Name='CODE UNIT TEST' + Test_Environment_Utility.generateRandomString(10), 
			BillingStreet=Test_Environment_Utility.generateRandomString(10) + ' UNIT TEST JUMP STREET', 
			BillingCity='Winnipeg', 
			BillingState='Manitoba', 
			BillingPostalCode='R3C 3P2', 
			BillingCountry='Canada', 
			BillingCountryCode='CA', 
			IsAddressValidated__c=TRUE
		);
        insert oNewAccount;
        return oNewAccount;
    }

    //Create and insert new account - China
    public static Account createInsertAccountCN(){
        Account oNewAccount = new Account(Name='TEST', BillingStreet='52 Rue de Rivoli', BillingState='Beijing', BillingCity='Beijing', BillingPostalCode='75004', BillingCountry='China', BillingCountryCode='CN', IsAddressValidated__c=TRUE);
        insert oNewAccount;
        return oNewAccount;
    }

    public static Opportunity createInsertOpportunity(String sRecordType, Account oAccount, String sStageName, Date oCloseDate) {
        //Get record type id
        Id idRecordType = Opportunity.SObjectType.getDescribe().getRecordTypeInfosByName().get(sRecordType).getRecordTypeId();
        
        Opportunity oNewOpportunity = new Opportunity(
            Name='Test', 
            RecordTypeId=idRecordType, 
            AccountId=oAccount.Id, 
            StageName=sStageName, 
            CloseDate=oCloseDate,
            Is_this_a_rollout__c='Yes',
            Business_Justification__c='Unit Test Justification',
            SPR_Type__c='Special Pricing'
        );
        insert oNewOpportunity;
        return oNewOpportunity;
    }

    public static Opportunity createOpportunity(String sRecordType, Account oAccount, String sStageName, Date oCloseDate) {
        //Get record type id
        Id idRecordType = Opportunity.SObjectType.getDescribe().getRecordTypeInfosByName().get(sRecordType).getRecordTypeId();
        
        Opportunity oNewOpportunity = new Opportunity(Name='Test', RecordTypeId=idRecordType, AccountId=oAccount.Id, StageName=sStageName, CloseDate=oCloseDate);
        return oNewOpportunity;
    }
    
    public static Seed_Unit_Order__c createInsertSeedUnitOrder(Opportunity oOpportunity, String sSeedLocationType, Account oShipToAccount, Contact oShipToContact) {
        Seed_Unit_Order__c oNewSeedUnitOrder = new Seed_Unit_Order__c(Opportunity__c=oOpportunity.Id, Seed_Unit_Location_Type__c=sSeedLocationType, Ship_To_Account__c=oShipToAccount.Id,
            Ship_To_Contact__c=oShipToContact.Id);
        insert oNewSeedUnitOrder;
        return oNewSeedUnitOrder;
    }
    
    public static Seed_Unit_Product__c createInsertSeedUnitProduct(Seed_Unit_Order__c oSeedUnitOrder, Product2 oProduct, Integer iQuantity) {
        Seed_Unit_Product__c oSeedUnitProduct = new Seed_Unit_Product__c(Seed_Unit_Order__c=oSeedUnitOrder.Id, Product__c=oProduct.Id, Quantity__c=iQuantity);
        insert oSeedUnitProduct;
        return oSeedUnitProduct;
    }
    
    public static Product2 createInsertProduct(Boolean doInsert){
        Product2 oNewProduct = new Product2(Name='TEST', ProductCode='TEST', Costing_Inventory__c='F'
                                            , Item_Type__c='E-FG', Inventory_Item_Status_Code__c='MASTER'
                                            , isActive=true, MSRP_EMEA_APAC_USD__c=10, MSRP_EMEA_EUR__c=10
                                            , MSRP_EMEA_GBP__c=10, MSRP_US_STANDARD_USD__c=10
                                            //02.05.2020 - Added by Sophia Murphy (Demand Chain)
                                            //without it - the Product process builder was failing
                                           , Oracle_Part_Number__c = '2342432'
                                            , QuantityInstallmentPeriod = 'Monthly', QuantityScheduleType = 'Divide'
                                            , CanUseQuantitySchedule = true
                                           );
        if(doInsert) {
            insert oNewProduct;
        }
        return oNewProduct;
    }
    
    //sophia Murphy - Added "doInsert" param above, but kept this method definition
    //so as not to break other unit tests
    public static Product2 createInsertProduct(){
        Product2 oNewProduct = createInsertProduct(true);
        return oNewProduct;
    }
    
    public static Customer_Account__c createInsertCustomerAccount(Account oAccount) {
      Customer_Account__c oCustomerAccount = new Customer_Account__c(Party__c=oAccount.Id, Account_Status__c='A', Discount_Class__c='BROADLINE US DISCOUNT', Account_Number__c='ERGO' + String.valueOf(getRandomInt(1, 999)), Customer_Account_Id__c='ERGO' + String.valueOf(getRandomInt(1, 999)));
      insert oCustomerAccount;
      return oCustomerAccount;
    }
    
    
    public static Integer getRandomInt (Integer lower, Integer upper) {
        return (Integer) (Math.floor(Math.random() * (upper - lower)) + lower);
    }
    
    public static User createInsertUser() {
        
        Profile oProfile = [select id, name from Profile where name = 'Standard User'];
        User oUser = new User(alias='tst3', email=String.valueOf(math.random()).left(20) + '@ergotron.com', emailencodingkey='UTF-8', firstname='Test3', lastname='Testing3', languagelocalekey='en_US', 
        localesidkey='en_US', profileid = oProfile.Id, timezonesidkey='America/Los_Angeles', username=String.valueOf(math.random()).left(20) + '@ergotron.com', User_Region__c='Americas');
        insert oUser;
        return oUser;
    }

    public static User createInsertCommunityUser(String sUserName, String sEmail, String sContactId) {
        
        User oUser = new User(alias='tst3', email=sEmail, emailencodingkey='UTF-8', firstname='Test3', lastname='Testing3', languagelocalekey='en_US', 
        localesidkey='en_US', profileid = '00eG0000000g7Ph', timezonesidkey='America/Los_Angeles', username=sUserName, ContactId=sContactId);
        insert oUser;
        return oUser;
    }

    public static User createInsertUserSalesProfile() {
        
        Profile oProfile = [select id, name from Profile where name = 'Ergotron Sales Profile'];
        User oUser = new User(alias='tst3', email=String.valueOf(math.random()).left(20) + '@ergotron.com', emailencodingkey='UTF-8', firstname='Test3', lastname='Testing3', languagelocalekey='en_US', 
        localesidkey='en_US', profileid = oProfile.Id, timezonesidkey='America/Los_Angeles', username=String.valueOf(math.random()).left(20) + '@ergotron.com', User_Region__c='Americas'); 
        insert oUser;
        return oUser;
    }

    public static User createInsertUserSalesProfileEMEA() {
        
        Profile oProfile = [select id, name from Profile where name = 'Ergotron EMEA Sales Profile'];
        User oUser = new User(alias='tst3', email=String.valueOf(math.random()).left(20) + '@ergotron.com', emailencodingkey='UTF-8', firstname='Test3', lastname='Testing3', languagelocalekey='en_US', 
        localesidkey='en_US', profileid = oProfile.Id, timezonesidkey='America/Los_Angeles', username=String.valueOf(math.random()).left(20) + '@ergotron.com', User_Region__c='EMEA'); 
        insert oUser;
        return oUser;
    }

    public static User createInsertUserSalesProfileAPAC() {
        
        Profile oProfile = [select id, name from Profile where name = 'Ergotron APAC Sales Profile'];
        User oUser = new User(alias='tst3', email=String.valueOf(math.random()).left(20) + '@ergotron.com', emailencodingkey='UTF-8', firstname='Test3', lastname='Testing3', languagelocalekey='en_US', 
        localesidkey='en_US', profileid = oProfile.Id, timezonesidkey='America/Los_Angeles', username=String.valueOf(math.random()).left(20) + '@ergotron.com', User_Region__c='APAC');
        insert oUser;
        return oUser;
    }

    public static Action_List__c createInsertActionList(Account oAccount, User oAssignedToUser) {
        Action_List__c oActionList = new Action_List__c(Name='Test Action List', Assigned_To__c=oAssignedToUser.Id, Account__c=oAccount.Id, Status__c='New',
            Due_Date__c=Date.today(), Action__c='Test Action', Next_Steps__c='Test Next Steps');
        insert oActionList;
        return oActionList;
    }

    public static Contact createInsertContact(Account oAccount) {
        Contact oContact = new Contact(FirstName='Test First', LastName='Test Last', AccountId=oAccount.Id, Email=String.valueOf(math.random()).left(20) + '@ergotron.com', Phone='8888888888', MailingStreet='1234 MyStreet', MailingCountry='United States');
        insert oContact;
        return oContact;
    }

    public static Contact createInsertPartnerContact(Account oAccount, String sEmail) {
        Contact oContact = new Contact(FirstName='Test First', LastName='Test Last', AccountId=oAccount.Id, Email=sEmail, Phone='8888888888');
        insert oContact;
        return oContact;
    }

    public static Integration_Id__c createInsertIntegrationId() {
        Integration_Id__c oIntegrationId = new Integration_Id__c(Name='Testing');
        insert oIntegrationId;
        return oIntegrationId;
    }

    public static Web_Service_Details__c createInsertWebServiceDetails(String sName) {
        Web_Service_Details__c oWebServiceDetail = new Web_Service_Details__c();
        oWebServiceDetail.Name=sName;
        oWebServiceDetail.Description_Where_Used__c='Testing';
        oWebServiceDetail.Endpoint__c='www.google.com';
        oWebServiceDetail.Exception_Email__c='test@test.com';
        oWebServiceDetail.Password__c='TestPassword';
        oWebServiceDetail.Username__c='TestUsername';
        insert oWebServiceDetail;
        return oWebServiceDetail;
    }

    public static Community_Detail__c createInsertCommunityDetails(){
        Community_Detail__c oCommunityDetail = new Community_Detail__c();
        oCommunityDetail.Name='Ergotron Deal Registration Community';
        oCommunityDetail.Sub_Domain__c='dealreg.ergotron.com';
        oCommunityDetail.Default_Account_Id__c='001G000001E57jL';
        oCommunityDetail.Default_Profile_Id__c='00eG0000000g7Ph';
        oCommunityDetail.Exception_Email__c='salesforce@ergotron.com';
        insert oCommunityDetail;
        return oCommunityDetail;
    }

    public static Campaign createInsertCampaign(String sRecordType, String sParentId) {
        //Get record type id
        Id idRecordType = Campaign.SObjectType.getDescribe().getRecordTypeInfosByName().get(sRecordType).getRecordTypeId();
        
        Campaign oCampaign = new Campaign(Name='Test', RecordTypeId=idRecordType, ParentId=sParentId, StartDate=Date.today(), EndDate=Date.today());
        insert oCampaign;
        return oCampaign;
    }

    //public static Installed_Product__c createInsertInstalledProductOracle(String sName, Account oAccount, Product2 oProduct){
        //Installed_Product__c oInstalledProduct = new Installed_Product__c();
        //oInstalledProduct.Name=sName;
        //oInstalledProduct.Customer_Name__c=oAccount.Id;
        //oInstalledProduct.Oracle_Instance_Number__c=String.valueOf(math.random()).left(20);
        //oInstalledProduct.Oracle_Order_Number__c=String.valueOf(math.random()).left(20);
        //oInstalledProduct.Oracle_Status__c='CREATED';
        //oInstalledProduct.Product__c=oProduct.Id;
        //oInstalledProduct.Product_Location__c=String.valueOf(math.random()).left(20);
        //oInstalledProduct.Shipped_Date__c=Date.today();
        //oInstalledProduct.Shipped_To_Location__c=String.valueOf(math.random()).left(20);
        //insert oInstalledProduct;

        //return oInstalledProduct;
    //}

	public static Asset createInsertInstalledProductOracle(String sName, Account oAccount, Product2 oProduct){
        Asset oInstalledProduct = new Asset();
        oInstalledProduct.Name=sName;
		oInstalledProduct.SerialNumber = sName;
        oInstalledProduct.AccountId=oAccount.Id;
        oInstalledProduct.Oracle_Instance_Number__c=String.valueOf(math.random()).left(20);
        oInstalledProduct.Oracle_Order_Number__c=String.valueOf(math.random()).left(20);
        oInstalledProduct.Oracle_Status__c='CREATED';
        oInstalledProduct.Product2Id=oProduct.Id;
        oInstalledProduct.Product_Location__c=String.valueOf(math.random()).left(20);
        oInstalledProduct.Shipped_Date__c=Date.today();
        oInstalledProduct.ORACLE_SHIPPED_TO_LOCATION__C=String.valueOf(math.random()).left(20);
		oInstalledProduct.Status = 'Installed';
		oInstalledProduct.Warranty_Terms_in_Months__c = 60;
		oInstalledProduct.GetWOData__c = false;
        insert oInstalledProduct;

        return oInstalledProduct;
    }

    //public static Service_Contract__c createInsertServiceContract(String sName, Account oAccountEndUser, Account oAccountDistributor, Account oAccountReseller, 
                                                                    //Product2 oProduct, Contact oContact){
        //Service_Contract__c oServiceContract = new Service_Contract__c();
        //oServiceContract.Name=sName;
        //oServiceContract.Contact__c=oContact.Id;
        //oServiceContract.Customer_Name__c=oAccountEndUser.Id;
        //oServiceContract.Customer_Number__c=String.valueOf(math.random()).left(20);
        //oServiceContract.Distribution_PO__c=String.valueOf(math.random()).left(20);
        //oServiceContract.Distributor__c=oAccountDistributor.Id;
        //oServiceContract.End_Date__c=Date.today();
        //oServiceContract.End_User_PO__c=String.valueOf(math.random()).left(20);
        //oServiceContract.Quantity_Ordered__c=10;
        //oServiceContract.Reseller__c=oAccountReseller.Id;
        //oServiceContract.Reseller_PO__c=String.valueOf(math.random()).left(20);
        //oServiceContract.Service_SKU__c=oProduct.Id;
        //oServiceContract.Start_Date__c=Date.today();
        //insert oServiceContract;
        
        //return oServiceContract;
    //}

	public static ServiceContract createInsertServiceContract(String sName, Account oAccountEndUser, Account oAccountDistributor, Account oAccountReseller, 
                                                                    Product2 oProduct, Contact oContact, Pricebook2 oServicePB){
		ServiceContract oServiceContract = new ServiceContract();
		oServiceContract.Name=sName;
        oServiceContract.ContactId=oContact.Id;
        oServiceContract.AccountId=oAccountEndUser.Id;
        oServiceContract.Customer_Number__c=String.valueOf(math.random()).left(20);
        oServiceContract.Distribution_PO__c=String.valueOf(math.random()).left(20);
        oServiceContract.Distributor__c=oAccountDistributor.Id;
        oServiceContract.EndDate=Date.today();
        oServiceContract.End_User_PO__c=String.valueOf(math.random()).left(20);
        oServiceContract.Quantity_Ordered__c=10;
        oServiceContract.Reseller__c=oAccountReseller.Id;
        oServiceContract.Reseller_PO__c=String.valueOf(math.random()).left(20);
        oServiceContract.Service_SKU__c=oProduct.Id;
        oServiceContract.StartDate=Date.today();
		oServiceContract.Pricebook2Id = oServicePB.Id;
		insert oServiceContract;
        
        return oServiceContract;																
	}

	public static Pricebook2 createServicePricebookWithProduct(Product2 objProduct) {
		
		Pricebook2 objPB = new Pricebook2(
			Name='SERVICE PRICE BOOK (Creating Service Contracts Only)',
			IsActive=true,
			CurrencyIsoCode = 'USD'
		);

		insert objPB;

		// Set Standard Pricebook Entry - USD/EUR/GBP
		List<PricebookEntry> lstPBEs = new List<PricebookEntry>();
		lstPBEs.add(new PricebookEntry(
			Product2Id = objProduct.Id,
			Pricebook2Id = Test.getStandardPricebookId(),
			UnitPrice = 0,
			IsActive = true,
			CurrencyIsoCode = 'USD'
		));
		lstPBEs.add(new PricebookEntry(
			Product2Id = objProduct.Id,
			Pricebook2Id = Test.getStandardPricebookId(),
			UnitPrice = 0,
			IsActive = true,
			CurrencyIsoCode = 'EUR'
		));
		lstPBEs.add(new PricebookEntry(
			Product2Id = objProduct.Id,
			Pricebook2Id = Test.getStandardPricebookId(),
			UnitPrice = 0,
			IsActive = true,
			CurrencyIsoCode = 'GBP'
		));

		// Set Service Pricebook Entry
		lstPBEs.add(new PricebookEntry(
			Product2Id = objProduct.Id,
			Pricebook2Id = objPB.Id,
			UnitPrice = 0,
			IsActive = true,
			CurrencyIsoCode = 'USD'
		));

		insert lstPBEs;

		return objPB;

	}

    public static Integration_Project__c createInsertIntegrationProject(String sName, Account oAccountEndUser, Account oAccountDistributor, Account oAccountReseller, 
                                                                    Product2 oProduct, Contact oContact){
        Integration_Project__c oIntProject = new Integration_Project__c();
        oIntProject.Name=sName;
        oIntProject.End_User_Contact__c=oContact.Id;
        oIntProject.End_User_Customer__c=oAccountEndUser.Id;
        oIntProject.Distributor_PO__c=String.valueOf(math.random()).left(20);
        oIntProject.Distributor_Account__c=oAccountDistributor.Id;
        oIntProject.Scheduled_Date__c=Date.today();
        oIntProject.End_User_PO__c=String.valueOf(math.random()).left(20);
        oIntProject.Ordered_Quantity__c=10;
        oIntProject.Reseller_Account__c=oAccountReseller.Id;
        oIntProject.Reseller_PO__c=String.valueOf(math.random()).left(20);
        oIntProject.Service_Part_Number__c=oProduct.Id;

        insert oIntProject;
        
        return oIntProject;
    }

    public static List<PricebookEntry> generatePricebookEntries(Map<Id,Decimal> mapProductPrices, Id idPricebook, Boolean bDoInsert) {
        List<PricebookEntry>  listPricebookEntries = new List<PricebookEntry> ();

        for(Id idProduct :mapProductPrices.keySet()) {
            listPricebookEntries.add(new PricebookEntry(
                                                    Product2Id = idProduct,
                                                    Pricebook2Id = idPricebook,
                                                    UnitPrice = mapProductPrices.get(idProduct),
                                                    IsActive = true));
        }

        if(bDoInsert) {
            insert listPricebookEntries;
        }

        return listPricebookEntries;
    }

    public static List<Pricebook2> generatePricebooks(Integer iNumPricebooks, Boolean bDoInsert) {
        ccrz__E_AccountGroup__c ccActGroup = new ccrz__E_AccountGroup__c();
        ccActGroup.Name = 'Replacement Parts';
        insert ccActGroup;
        
        List<Pricebook2> listPricebooks = new List<Pricebook2>();

        for(Integer i = 0; i < iNumPricebooks; i++) {
            listPricebooks.add(new Pricebook2(
                                        IsActive = true,
                                        Name = 'UNIT TEST ' + i));
        }

        if(bDoInsert) {
            insert listPricebooks;
        }

        return listPricebooks;
    }

    public static List<Product2> generateFGProducts(Integer iNumProducts, Boolean bDoInsert){
        //Creates a list of Finished Good products
        
        List<Product2> listProducts = new List<Product2>();

        for(Integer i = 0; i < iNumProducts; i++) {
            listProducts.add(new Product2(
                                        Name='TEST ' + i,
                                        ProductCode='TEST ' + i,
                                        Costing_Inventory__c='F',
                                        Item_Type__c='E-FG',
                                        Inventory_Item_Status_Code__c='MASTER',
                                        IsActive=true,
                                        MSRP_EMEA_APAC_USD__c=10, 
                                        MSRP_EMEA_EUR__c=10, 
                                        MSRP_EMEA_GBP__c=10, 
                                        MSRP_US_STANDARD_USD__c=10));
        }
        
        if(bDoInsert) {
            insert listProducts;
        }
        
        return listProducts;
    }

    public static Map<Id, Decimal> generateProductPrices(List<Product2> listProducts, Decimal dBaseAmount) {
        Map<Id, Decimal> mapProductPrices = new Map<Id, Decimal>();

        for(Integer i = 0; i<listProducts.size(); i++) {
            mapProductPrices.put(listProducts[i].Id, dBaseAmount + 1);
        }

        return mapProductPrices;
    }

    public static Opportunity_Partner__c createInsertOpportunityPartner(Id idOpportunityId, Id idPartnerAccountId, String sPartnerRole) {
        Opportunity_Partner__c oOpptyPartner = new Opportunity_Partner__c();
        oOpptyPartner.Opportunity__c=idOpportunityId;
        oOpptyPartner.Partner_Account__c=idPartnerAccountId;
        oOpptyPartner.Partner_Role__c=sPartnerRole;

        insert oOpptyPartner;

        return oOpptyPartner;
    }

    public static Case createInsertCase(Account oAccount, Contact oContact, Installed_Product__c oInstalledProduct, id rtCaseId){
        Case oCase = new Case();
        oCase.AccountId = oAccount.Id;
        oCase.ContactId = oContact.Id;
		oCase.Subject = 'Test Case!';
        If(oInstalledProduct != null) {oCase.Serial_Number__c = oInstalledProduct.Id;}
        If(rtCaseId != null) {oCase.RecordTypeId = rtCaseId;}
        oCase.Oracle_Group_Assignment__c = 'Unassigned';
        insert oCase;

        return oCase;
    }

    public static Order__c createInsertOrder(Account oAccount, Account oCustomerAccount) {
    //public static Order__c createInsertOrder(Account oAccount, Customer_Account__c oCustomerAccount) {
        Order__c oOrder = new Order__c();
        oOrder.Customer__c=oAccount.Id;
        oOrder.Customer_Account_New__c=oCustomerAccount.Id;
        //oOrder.Customer_Account__c=oCustomerAccount.Id;
        oOrder.Name=String.valueOf(math.random()).left(20);

        insert oOrder;

        return oOrder;
    }

    public static Purchase_Order_Detail_OE__c createInsertPurchaseOrder(Order__c oOrder){
        Purchase_Order_Detail_OE__c oPO = new Purchase_Order_Detail_OE__c();
        oPO.Order__c=oOrder.Id;
        oPO.Vendor_Name__c='TEST';
        oPO.Quantity__c=1;
        oPO.Status__c='APPROVED';
        oPO.Drop_Ship_Source_Id__c=String.valueOf(math.random()).left(20);

        insert oPO;

        return oPO;
    }

    public static Integration_Project__c createInsertIntegrationProject(Order__c oOrder){
        Integration_Project__c oIP = new Integration_Project__c();
        oIP.Name='TEST';
        oIP.Sales_Order__c=oOrder.Id;

        insert oIP;

        return oIP;
    }

    public static List<Oracle_Order_Type__c> createInsertOrderTypes(Set<String> setOrderTypes){
        List<Oracle_Order_Type__c> listOrderTypes = new List<Oracle_Order_Type__c>();

        for(String sOrderType :setOrderTypes){
            Oracle_Order_Type__c oOrderType = new Oracle_Order_Type__c();

            oOrderType.Name=sOrderType;
            oOrderType.Description__c=sOrderType;
            oOrderType.Order_Type_Id__c=sOrderType;
            oOrderType.Start_Date_Active__c=Date.today()-1;
            oOrderType.Salesforce_Order_Type__c=true;   

            listOrderTypes.add(oOrderType);     
        }

        insert listOrderTypes;

        return listOrderTypes;
    }

    public static List<Oracle_Return_Reason__c> createInsertReturnReasons(Set<String> setReturnReasons){
        List<Oracle_Return_Reason__c> listReturnReasons = new List<Oracle_Return_Reason__c>();

        for(String sReturnReason :setReturnReasons){
            Oracle_Return_Reason__c oReturnReason = new Oracle_Return_Reason__c();

            oReturnReason.Name=sReturnReason;
            oReturnReason.Lookup_Code__c=sReturnReason;
            oReturnReason.Meaning__c=sReturnReason;
            oReturnReason.Description__c=sReturnReason;
            oReturnReason.Enabled_Flag__c=true;
            oReturnReason.Start_Date_Active__c=Date.today()-1;

            listReturnReasons.add(oReturnReason);       
        }
        
        insert listReturnReasons;

        return listReturnReasons;
    }

    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
}