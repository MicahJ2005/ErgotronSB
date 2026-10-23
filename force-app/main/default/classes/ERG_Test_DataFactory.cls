@isTest
public with sharing class ERG_Test_DataFactory {
    public static final String TEST_STOREFRONT = 'DefaultStore';

    // Parent Billing Address
    public static final String PARENT_BILL_STREET = 'Parent Billing Address';
    public static final String PARENT_BILL_CITY = 'New York';
    public static final String PARENT_BILL_STATE = 'New York';
    public static final String PARENT_BILL_COUNTRY = 'United States';
    public static final String PARENT_BILL_POSTAL_CODE = '67890';

    // Parent Shipping Address
    public static final String PARENT_SHIP_STREET = 'Parent Shipping Address';
    public static final String PARENT_SHIP_CITY = 'New York';
    public static final String PARENT_SHIP_STATE = 'New York';
    public static final String PARENT_SHIP_COUNTRY = 'United States';
    public static final String PARENT_SHIP_POSTAL_CODE = '67890';

    // Child billing address
    public static final String CHILD_BILL_STREET = 'Child Billing Address';
    public static final String CHILD_BILL_CITY = 'Chicago';
    public static final String CHILD_BILL_STATE = 'Illinois';
    public static final String CHILD_BILL_COUNTRY = 'United States';
    public static final String CHILD_BILL_POSTAL_CODE = '91001';

    // Child shipping address
    public static final String CHILD_SHIP_STREET = 'Child Shipping Address';
    public static final String CHILD_SHIP_CITY = 'Chicago';
    public static final String CHILD_SHIP_STATE = 'Illinois';
    public static final String CHILD_SHIP_COUNTRY = 'United States';
    public static final String CHILD_SHIP_POSTAL_CODE = '91001';

    // CC Contact Address
    public static final String ADDRESS_FIRSTLINE = 'addressFirstline';
    public static final String CITY = 'city';
    public static final String STATE = 'state';
    public static final String COUNTRY = 'country';
    public static final String POSTAL_CODE = 'postalCode';
    public static final String DAYTIME_PHONE = 'daytimePhone';

    // Random test address
    public static final String TEST_STREET = 'Testing Address';
    public static final String TEST_CITY = 'Chicago';
    public static final String TEST_STATE = 'Pennsylvania';
    public static final String TEST_COUNTRY = 'United States';
    public static final String TEST_POSTAL_CODE = '91001';

    public static final String TEST_ACC_FIRSTNAME = 'Test';
    public static final String TEST_ACC_LASTNAME = 'Account';

    public static final String PRODUCT_TYPE_PRODUCT = 'Product';
    public static final String PRODUCT_STATUS_RELEASED = 'Released';
    public static final String CART_STATUS_OPEN = 'Open';
    public static final String CART_TYPE = 'Cart';
    public static final String TEST_CURRENCY_CODE = 'USD';
    public static final String TEST_ENCRYPTED_ID_CART = 'encid-';

    public static final String TEST_PARENT_ACC_USER = 'TestParentUser';
    public static final String TEST_CHILD_ACC_USER = 'TestUser';
    public static final String TEST_PARENT_ACCOUNT = 'TestParentAccount';
    public static final String TEST_CHILD_ACCOUNT = 'TestChildAccount';
    public static final String TEST_PRODUCTS = 'TestProducts';
    public static final String TEST_CONTACT = 'TestContact';
    public static final String TEST_SKU = 'TestSKU';
    public static final String TEST_SKU_CAT = '1000';
    public static final String TEST_SKU_ALLPRODCAT = 'ALL-PRODUCTS';    
    public static final String TEST_CASE = 'TestCase';
    public static final Integer TEST_PRODUCT_PRICE = 50;
    public static final String TEST_ORACLE_ORDER_TYPE = 'TestOraOrdType';
    public static final String TEST_ORACLE_ORDER_TYPE_NAME = 'OMNI TRADE SHOW';

    private static final Decimal TEST_ACCOUNT_CREDIT_LIMIT = 100;
    

    /**
     * @description Setups a test storefront.
     */
    public static void initCCSettings() {
        ccrz.cc_util_Reflection.createStorefrontSetting(TEST_STOREFRONT);
        Map<String, Map<String, Object>> ccSettings = new Map<String, Map<String, Object>>{
                ccrz.ccApiTestData.SERVICE_SETTINGS => new Map<String, Object>{
                        TEST_STOREFRONT => new Map<String, Object>{
                                'ccServicePL' => 'c.CC_ERG_servicePL',
                                'ccServiceAddressBook' => 'c.ccErgoServiceAddressBook',
                                'ccServiceCart' => 'c.ccErgServiceCart',
                                'ccServiceOrder' => 'c.ccErgServiceOrder'
                        }
                },
                ccrz.ccApiTestData.LOGIC_SETTINGS => new Map<String, Object>{
                        TEST_STOREFRONT => new Map<String, Object>{
                                'ccLogicCartCreate' => 'c.ccErgoLogicCartCreate',
                                'ccLogicCartValidate' => 'c.CC_ERG_LogicCartValidate',
                                'ccLogicPIFetchEntitled' => 'c.CC_ERG_LogicPIFetchEntitled'
                        }
                },
                ccrz.ccApiTestData.HOOK_SETTINGS => new Map<String, Object>{
                        TEST_STOREFRONT => new Map<String, Object>{
                                ccrz.cc_hk_Payment.HK_ID => 'c.cc_erg_hk_payment',
                                ccrz.cc_hk_Order.HK_ID => 'c.ccErg_hk_Order'
                        }
                }
        };
        ccrz.ccApiTestData.setupData(ccSettings);

        // custom configs -- min data needed
        ccrz__E_ConfigurationMeta__c emailtmplmeta = new ccrz__E_ConfigurationMeta__c(name='Approver Email Template', ccrz__APIName__c='emailtmpl');
        ccrz__E_ConfigurationMeta__c casenumbertagmeta = new ccrz__E_ConfigurationMeta__c(name='Case Number Tag', ccrz__APIName__c='casenumbertag');
        ccrz__E_ConfigurationMeta__c linknamemeta = new ccrz__E_ConfigurationMeta__c(name='Link Name', ccrz__APIName__c='linkname');
        ccrz__E_ConfigurationMeta__c serverurlmeta = new ccrz__E_ConfigurationMeta__c(name='Server URL', ccrz__APIName__c='serverurl');
        ccrz__E_ConfigurationMeta__c fromemailmeta = new ccrz__E_ConfigurationMeta__c(name='From Email', ccrz__APIName__c='fromemail');
        ccrz__E_ConfigurationMeta__c erglinktagmeta = new ccrz__E_ConfigurationMeta__c(name='Approver Link Tag', ccrz__APIName__c='erglinktag');
        ccrz__E_ConfigurationMeta__c fromnamemeta = new ccrz__E_ConfigurationMeta__c(name='From Name', ccrz__APIName__c='fromname');
        ccrz__E_ConfigurationMeta__c username_suffixmeta = new ccrz__E_ConfigurationMeta__c(name='UserName Suffix', ccrz__APIName__c='username_suffix');
        ccrz__E_ConfigurationMeta__c Credit_Card_Allowed_Countriesmeta = new ccrz__E_ConfigurationMeta__c(name='Credit Card Allowed Countries', ccrz__APIName__c='Credit_Card_Allowed_Countries');
        List<ccrz__E_ConfigurationMeta__c> metasToInsert = new List<ccrz__E_ConfigurationMeta__c>{emailtmplmeta, casenumbertagmeta, linknamemeta, serverurlmeta, 
                                                                                                  fromemailmeta, erglinktagmeta, fromnamemeta, username_suffixmeta,  
            																					  Credit_Card_Allowed_Countriesmeta};
        insert metasToInsert;
        
        ccrz__E_Configuration__c emailtmplName = new ccrz__E_Configuration__c(ccrz__TextValue__c='CC_Approval_Email', ccrz__Storefront__c='DefaultStore', ccrz__PageName__c='all', ccrz__ConfigurationMeta__c = emailtmplmeta.Id);
        ccrz__E_Configuration__c casenumbertagName = new ccrz__E_Configuration__c(ccrz__TextValue__c='#casenumber#', ccrz__Storefront__c='DefaultStore', ccrz__PageName__c='all', ccrz__ConfigurationMeta__c = casenumbertagmeta.Id);
        ccrz__E_Configuration__c linknameName = new ccrz__E_Configuration__c(ccrz__TextValue__c='Click Here To Approve', ccrz__Storefront__c='DefaultStore', ccrz__PageName__c='all', ccrz__ConfigurationMeta__c = linknamemeta.Id);
        ccrz__E_Configuration__c serverurlName = new ccrz__E_Configuration__c(ccrz__TextValue__c='https://full-ergotron.cs93.force.com', ccrz__Storefront__c='DefaultStore', ccrz__PageName__c='all', ccrz__ConfigurationMeta__c = serverurlmeta.Id);
        ccrz__E_Configuration__c fromemailName = new ccrz__E_Configuration__c(ccrz__TextValue__c='noreply@ergotron.com', ccrz__Storefront__c='DefaultStore', ccrz__PageName__c='all', ccrz__ConfigurationMeta__c = fromemailmeta.Id);
        ccrz__E_Configuration__c erglinktagName = new ccrz__E_Configuration__c(ccrz__TextValue__c='#link#', ccrz__Storefront__c='DefaultStore', ccrz__PageName__c='all', ccrz__ConfigurationMeta__c = erglinktagmeta.Id);
        ccrz__E_Configuration__c fromnameName = new ccrz__E_Configuration__c(ccrz__TextValue__c='Ergotron Parts Store', ccrz__Storefront__c='DefaultStore', ccrz__PageName__c='all', ccrz__ConfigurationMeta__c = fromnamemeta.Id);
        ccrz__E_Configuration__c username_suffixName = new ccrz__E_Configuration__c(ccrz__TextValue__c='.ergotron', ccrz__Storefront__c='DefaultStore', ccrz__PageName__c='all', ccrz__ConfigurationMeta__c = username_suffixmeta.Id);
        ccrz__E_Configuration__c Credit_Card_Allowed_CountriesName = new ccrz__E_Configuration__c(ccrz__TextValue__c='US', ccrz__Storefront__c='DefaultStore', ccrz__PageName__c='all', ccrz__ConfigurationMeta__c = Credit_Card_Allowed_Countriesmeta.Id);
        List<ccrz__E_Configuration__c> configsToInsert = new List<ccrz__E_Configuration__c>{emailtmplName, casenumbertagName, linknameName, 
                                                                                            serverurlName, fromemailName,
                                                                                            erglinktagName, fromnameName, username_suffixName, 
                                                                                            Credit_Card_Allowed_CountriesName};
                                                                                            
        insert configsToInsert;
        
        //Added by JLL to test payment hook
		List<ccrz__E_ConfigurationModule__c> configurationModules = new List<ccrz__E_ConfigurationModule__c>();
		configurationModules.add(new ccrz__E_ConfigurationModule__c(Name='wlt', ccrz__APIName__c='wlt'));
		configurationModules.add(new ccrz__E_ConfigurationModule__c(Name='co', ccrz__APIName__c='co'));
		configurationModules.add(new ccrz__E_ConfigurationModule__c(Name='inv', ccrz__APIName__c='inv'));
		configurationModules.add(new ccrz__E_ConfigurationModule__c(Name='pmt_po', ccrz__APIName__c='pmt_po'));
		
		// 2020.10.25 gvansteeter added for guest user checkout enablement
		configurationModules.add(new ccrz__E_ConfigurationModule__c(Name='User Profile(Registration', ccrz__APIName__c='ur'));
		INSERT configurationModules;

		List<ccrz__E_ConfigurationMeta__c> configurationMetas = new List<ccrz__E_ConfigurationMeta__c>();
		configurationMetas.add(new ccrz__E_ConfigurationMeta__c(ccrz__Description__c='Payment page whitelist', ccrz__APIName__c='pmts', ccrz__ExternallySafe__c=TRUE, ccrz__ConfigurationModule__c=configurationModules[0].Id));
		configurationMetas.add(new ccrz__E_ConfigurationMeta__c(ccrz__Description__c='Payment error page', ccrz__APIName__c='pmts', ccrz__ExternallySafe__c=TRUE, ccrz__ConfigurationModule__c=configurationModules[1].Id));
		configurationMetas.add(new ccrz__E_ConfigurationMeta__c(ccrz__Description__c='Payment error page', ccrz__APIName__c='pmts', ccrz__ExternallySafe__c=TRUE, ccrz__ConfigurationModule__c=configurationModules[2].Id));
		configurationMetas.add(new ccrz__E_ConfigurationMeta__c(ccrz__Description__c='Payment error page', ccrz__APIName__c='dspname', ccrz__ExternallySafe__c=TRUE, ccrz__ConfigurationModule__c=configurationModules[3].Id));
		configurationMetas.add(new ccrz__E_ConfigurationMeta__c(ccrz__Description__c='Payment error page', ccrz__APIName__c='newvf', ccrz__ExternallySafe__c=TRUE, ccrz__ConfigurationModule__c=configurationModules[3].Id));
		configurationMetas.add(new ccrz__E_ConfigurationMeta__c(ccrz__Description__c='Payment error page', ccrz__APIName__c='editvf', ccrz__ExternallySafe__c=TRUE, ccrz__ConfigurationModule__c=configurationModules[3].Id));
		configurationMetas.add(new ccrz__E_ConfigurationMeta__c(ccrz__Description__c='Payment error page', ccrz__APIName__c='delvf', ccrz__ExternallySafe__c=TRUE, ccrz__ConfigurationModule__c=configurationModules[3].Id));
		configurationMetas.add(new ccrz__E_ConfigurationMeta__c(ccrz__Description__c='Payment error page', ccrz__APIName__c='entryvf', ccrz__ExternallySafe__c=TRUE, ccrz__ConfigurationModule__c=configurationModules[3].Id));
		configurationMetas.add(new ccrz__E_ConfigurationMeta__c(ccrz__Description__c='Payment error page', ccrz__APIName__c='dspname', ccrz__ExternallySafe__c=TRUE, ccrz__ConfigurationModule__c=configurationModules[3].Id));
		configurationMetas.add(new ccrz__E_ConfigurationMeta__c(ccrz__Description__c='Payment error page', ccrz__APIName__c='newvf', ccrz__ExternallySafe__c=TRUE, ccrz__ConfigurationModule__c=configurationModules[3].Id));
		configurationMetas.add(new ccrz__E_ConfigurationMeta__c(ccrz__Description__c='Payment error page', ccrz__APIName__c='editvf', ccrz__ExternallySafe__c=TRUE, ccrz__ConfigurationModule__c=configurationModules[3].Id));
		configurationMetas.add(new ccrz__E_ConfigurationMeta__c(ccrz__Description__c='Payment error page', ccrz__APIName__c='delvf', ccrz__ExternallySafe__c=TRUE, ccrz__ConfigurationModule__c=configurationModules[3].Id));
		configurationMetas.add(new ccrz__E_ConfigurationMeta__c(ccrz__Description__c='Payment error page', ccrz__APIName__c='entryvf', ccrz__ExternallySafe__c=TRUE, ccrz__ConfigurationModule__c=configurationModules[3].Id));
		// 2020.10.25 gvansteeter added for guest user checkout enablement
		configurationMetas.add(new ccrz__E_ConfigurationMeta__c(ccrz__Description__c='The ID of the user who is the default owner of records that guest users create, such as carts and orders. The default owner has access to all new records that guest users create.',
																Name='Default Record Owner', ccrz__APIName__c='groid', ccrz__ExternallySafe__c=FALSE, ccrz__ConfigurationModule__c=configurationModules[4].Id));
		
		INSERT configurationMetas;

		List<ccrz__E_Configuration__c> configurations = new List<ccrz__E_Configuration__c>();
		configurations.add(new ccrz__E_Configuration__c(ccrz__Storefront__c='global', ccrz__PageName__c='all', ccrz__TextValue__c='po,cc', ccrz__ConfigurationMeta__c=configurationMetas[0].Id));
		configurations.add(new ccrz__E_Configuration__c(ccrz__Storefront__c='global', ccrz__PageName__c='all', ccrz__TextValue__c='po,cc', ccrz__ConfigurationMeta__c=configurationMetas[1].Id));
		configurations.add(new ccrz__E_Configuration__c(ccrz__Storefront__c='global', ccrz__PageName__c='all', ccrz__TextValue__c='po,cc', ccrz__ConfigurationMeta__c=configurationMetas[2].Id));
		configurations.add(new ccrz__E_Configuration__c(ccrz__Storefront__c='global', ccrz__PageName__c='all', ccrz__TextValue__c='PaymentType_PO', ccrz__ConfigurationMeta__c=configurationMetas[3].Id));
		configurations.add(new ccrz__E_Configuration__c(ccrz__Storefront__c='global', ccrz__PageName__c='all', ccrz__TextValue__c='cc_pmt_PO_New', ccrz__ConfigurationMeta__c=configurationMetas[4].Id));
		configurations.add(new ccrz__E_Configuration__c(ccrz__Storefront__c='global', ccrz__PageName__c='all', ccrz__TextValue__c='cc_pmt_PO_Edit', ccrz__ConfigurationMeta__c=configurationMetas[5].Id));
		configurations.add(new ccrz__E_Configuration__c(ccrz__Storefront__c='global', ccrz__PageName__c='all', ccrz__TextValue__c='cc_pmt_PO_Del', ccrz__ConfigurationMeta__c=configurationMetas[6].Id));
		configurations.add(new ccrz__E_Configuration__c(ccrz__Storefront__c='global', ccrz__PageName__c='all', ccrz__TextValue__c='cc_pmt_PO_Entry', ccrz__ConfigurationMeta__c=configurationMetas[7].Id));
		configurations.add(new ccrz__E_Configuration__c(ccrz__Storefront__c='global', ccrz__PageName__c='all', ccrz__TextValue__c='PaymentType_CC', ccrz__ConfigurationMeta__c=configurationMetas[8].Id));
		configurations.add(new ccrz__E_Configuration__c(ccrz__Storefront__c='global', ccrz__PageName__c='all', ccrz__TextValue__c='cc_pmt_CC_New', ccrz__ConfigurationMeta__c=configurationMetas[9].Id));
		configurations.add(new ccrz__E_Configuration__c(ccrz__Storefront__c='global', ccrz__PageName__c='all', ccrz__TextValue__c='cc_pmt_CC_Edit', ccrz__ConfigurationMeta__c=configurationMetas[10].Id));
		configurations.add(new ccrz__E_Configuration__c(ccrz__Storefront__c='global', ccrz__PageName__c='all', ccrz__TextValue__c='cc_pmt_CC_Del', ccrz__ConfigurationMeta__c=configurationMetas[11].Id));
		configurations.add(new ccrz__E_Configuration__c(ccrz__Storefront__c='global', ccrz__PageName__c='all', ccrz__TextValue__c='cc_pmt_CC_Entry', ccrz__ConfigurationMeta__c=configurationMetas[12].Id));
		//2020.10.25 gvansteeter added for guest user checkout enablement
		configurations.add(new ccrz__E_Configuration__c(ccrz__Storefront__c='Global', ccrz__PageName__c='all', ccrz__TextValue__c=null, ccrz__ConfigurationMeta__c=configurationMetas[13].Id));
		// note, this record will need to be updated with a ccrz__TextValue__c corresponding to a userId prior to running tests.
		configurations.add(new ccrz__E_Configuration__c(ccrz__Storefront__c=TEST_STOREFRONT, ccrz__PageName__c='all', ccrz__TextValue__c=null, ccrz__ConfigurationMeta__c=configurationMetas[13].Id)); 
		
		INSERT configurations;
    }
    
    /**
     * @description Returns a test Account.
     */
    public static Account createInsertTestAccount(ccrz__E_AccountGroup__c accountGroup, Boolean isParent, Account parentAccount) {
        Account testAcc = new Account();
        if (isParent) {
            testAcc.Name = 'Parent Account';
            testAcc.BillingStreet = PARENT_BILL_STREET;
            testAcc.BillingCity = PARENT_BILL_CITY;
            testAcc.BillingState = PARENT_BILL_STATE;
            testAcc.BillingCountry = PARENT_BILL_COUNTRY;
            testAcc.BillingPostalCode = PARENT_BILL_POSTAL_CODE;

            testAcc.ShippingStreet = PARENT_SHIP_STREET;
            testAcc.ShippingCity = PARENT_SHIP_CITY;
            testAcc.ShippingState = PARENT_SHIP_STATE;
            testAcc.ShippingCountry = PARENT_SHIP_COUNTRY;
            testAcc.ShippingPostalCode = PARENT_SHIP_POSTAL_CODE;
            testAcc.IsAddressValidated__c=TRUE;
        } else {
            testAcc.Name = 'Child Account';
            testAcc.BillingStreet = CHILD_BILL_STREET;
            testAcc.BillingCity = CHILD_BILL_CITY;
            testAcc.BillingState = CHILD_BILL_STATE;
            testAcc.BillingCountry = CHILD_BILL_COUNTRY;
            testAcc.BillingPostalCode = CHILD_BILL_POSTAL_CODE;

            testAcc.ShippingStreet = CHILD_SHIP_STREET;
            testAcc.ShippingCity = CHILD_SHIP_CITY;
            testAcc.ShippingState = CHILD_SHIP_STATE;
            testAcc.ShippingCountry = CHILD_SHIP_COUNTRY;
            testAcc.ShippingPostalCode = CHILD_SHIP_POSTAL_CODE;
            if (parentAccount != null) {
                testAcc.ParentId = parentAccount.Id;
            }
        }
        testAcc.ccrz__E_AccountGroup__c = accountGroup.Id;
        insert testAcc;
        return testAcc;
    }
	

    /**
     * @description Creates a test account group.
     */
    public static ccrz__E_AccountGroup__c createInsertTestAccountGroup() {
        ccrz__E_AccountGroup__c accGroup = new ccrz__E_AccountGroup__c(
                Name = 'Default Account Group',
                ccrz__PriceListSelectionMethod__c = 'Best Price'
        );
        insert accGroup;
        return accGroup;
    }
	
    /**
     * @description Creates and returns a test price list.
     */
    public static ccrz__E_PriceList__c createInsertTestPricelist() {
        ccrz__E_PriceList__c priceList = new ccrz__E_PriceList__c(
                Name = 'Test Price List',
                ccrz__CurrencyISOCode__c = TEST_CURRENCY_CODE,
                ccrz__Enabled__c = true,
                ccrz__Storefront__c = TEST_STOREFRONT,
                ccrz__StartDate__c = System.today().addYears(-1)
        );
        insert priceList;
        return priceList;
    }

    /**
     * @description Associates the pricelist to an account group.
     */
    public static ccrz__E_AccountGroupPriceList__c createInsertTestAccountGroupPriceList(ccrz__E_AccountGroup__c accountGroup, ccrz__E_PriceList__c priceList) {
        ccrz__E_AccountGroupPriceList__c accountGroupPriceList = new ccrz__E_AccountGroupPriceList__c(
                ccrz__AccountGroup__c = accountGroup.Id,
                ccrz__Pricelist__c = priceList.Id,
                ccrz__StartDate__c = System.today().addYears(-1),
                ccrz__Enable__c = true

        );
        insert accountGroupPriceList;
        return accountGroupPriceList;
    }

    /**
     * @description Creates and inserts price list items.
     */
    public static void createInsertPriceListItems(List<ccrz__E_Product__c> products, ccrz__E_PriceList__c pricelist) {

        List<ccrz__E_PriceListItem__c> items = new List<ccrz__E_PriceListItem__c>();

        for (ccrz__E_Product__c product : products) {
            ccrz__E_PriceListItem__c priceListItem = new ccrz__E_PriceListItem__c(
                    ccrz__Price__c = TEST_PRODUCT_PRICE,
                    ccrz__Product__c = product.Id,
                    ccrz__Pricelist__c = pricelist.Id,
                    ccrz__StartDate__c = System.today().addYears(-1)
            );
            items.add(priceListItem);

        }
        insert items;
    }

    /**
     * @description Creates and Returns the specified number of CC products.
     */
    public static List<ccrz__E_Product__c> createInsertTestProducts(Integer size) {
        List<ccrz__E_Product__c> products = new List<ccrz__E_Product__c>();

        for (Integer i = 0; i < size; i++) {
            ccrz__E_Product__c product = new ccrz__E_Product__c(
                    Name = TEST_SKU + i,
                    ccrz__SKU__c = TEST_SKU + i,
                    ccrz__ProductStatus__c = PRODUCT_STATUS_RELEASED,
                    ccrz__ProductType__c = PRODUCT_TYPE_PRODUCT,
                    ccrz__Storefront__c = TEST_STOREFRONT,
                    ccrz__ShortDesc__c = TEST_SKU,
                    ccrz__ShortDescRT__c = TEST_SKU,
                    ccrz__StartDate__c = System.today().addYears(-1),
                    ccrz__EndDate__c = System.today().addYears(+1),
                    ccrz__ShippingWeight__c = 1
            );

            products.add(product);

        }
        insert products;
        return products;
    }

    /**
     * @description Creates a test user.
     */
    public static User createDefaultUser(Contact contact) {
       User u;
       User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
       system.runAs(thisUser){
        
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'B2B Storefront' LIMIT 1];
         u = new User(
                LastName = 'SMITH',
                FirstName = 'JOHN',
                Alias = 'main',
                Email = 'testuser@testfactory.com',
                Phone = '1234567890',
                Username = 'testuser@testfactory.com.' + Math.random(),
                TimeZoneSidKey = 'Europe/Berlin',
                LanguageLocaleKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LocaleSidKey = 'en_US',
                ContactId = contact.Id,
                ProfileId = profile.Id
        );
        insert u;
       }
        return u;
    }
	
    
    /**
     * @description Creates test categories
     */
     public static List<ccrz__E_Category__c> createInsertTestCategory(){
     	List<ccrz__E_Category__c> listCat = new List<ccrz__E_Category__c>();
     	ccrz__E_Category__c theCategory = new ccrz__E_Category__c(
			Name = 'Test Category',
			ccrz__CategoryId__c = TEST_SKU_CAT,
			ccrz__StartDate__c = Date.Today(),
			ccrz__EndDate__c = Date.parse('12/31/2099'),
			ccrz__Sequence__c = 500
     	);
     	listCat.add(theCategory);

     	ccrz__E_Category__c theAllProdCategory = new ccrz__E_Category__c(
			Name = 'All Products',
			ccrz__CategoryId__c = TEST_SKU_ALLPRODCAT,
			ccrz__StartDate__c = Date.Today(),
			ccrz__EndDate__c = Date.parse('12/31/2099'),
			ccrz__Sequence__c = 500
     	);
     	listCat.add(theAllProdCategory);

     	
     	insert listCat;
     	return listCat;
     }    

    /**
     * @description Creates a test contact.
     */
    public static Contact createInsertDefaultContact(Account account) {

        Contact contact = new Contact(
                AccountId = account.Id,
                FirstName = 'Default Contact',
                LastName = 'Default Contact',
                Email = 'defaultcontact@domain.com',
                MailingStreet = 'testMailingStreet',
                MailingPostalCode = '90210',
                MailingCity = 'testMailingCity'
        );
        insert contact;
        return contact;
    }
	

    /**
     * @description Creates Account, Account group, Users, PriceLists, Products, PriceListItems.
     */
    public static Map<String, Object> setupAccountContactUser(Boolean createParentAccount, Boolean createActiveUser) {

        initCCSettings();

        Account parentAccount;
        Contact parentContact;
        User parentUser;

        Account childAccount;
        Contact childContact;
        User childUser;

        //Account/Contact/User details
        ccrz__E_AccountGroup__c accountGroup = createInsertTestAccountGroup();


        if (createParentAccount) {
            parentAccount = createInsertTestAccount(accountGroup, true, null);
            childAccount = createInsertTestAccount(accountGroup, false, parentAccount);

            parentContact = createInsertDefaultContact(parentAccount);
            if(createActiveUser){
	            parentUser = createDefaultUser(parentContact);
            }
        } else {
            childAccount = createInsertTestAccount(accountGroup, false, null);
        }

        childContact = createInsertDefaultContact(childAccount);
        if(createActiveUser){
        	childUser = createDefaultUser(childContact);
    	}

        // 2020.10.25 gvansteeter: update configuration to use the DRO user ID.
		User DroUser = [SELECT Id FROM User WHERE lastName = 'B2B Storefront' AND firstName = 'Owner'];
        ccrz__E_Configuration__c DroConfig = [SELECT Id, ccrz__TextValue__c FROM ccrz__E_Configuration__c WHERE ccrz__ConfigurationMeta__r.Name = 'Default Record Owner' AND ccrz__Storefront__c = :TEST_STOREFRONT];
        DroConfig.ccrz__TextValue__c = DroUser.Id;
        update DroConfig;
		// 2020.10.25 end for guest user checkout enablement

        //PriceLists
        ccrz__E_PriceList__c pricelist = createInsertTestPricelist();
        createInsertTestAccountGroupPriceList(accountGroup, pricelist);
        
        // Create a CC Product Category
        List<ccrz__E_Category__c> listTestCategory = createInsertTestCategory();        

        //Products and PriceListItems
        List<ccrz__E_Product__c> products = createInsertTestProducts(2);
        createInsertPriceListItems(products, pricelist);

      /**
       * @description Inserts a case tied to an account and contact.
       */
        // need a CASE "Product" record type.
        RecordType theRecordType = [SELECT Id FROM RecordType r WHERE r.SobjectType = 'Case' AND r.DeveloperName = 'Product' LIMIT 1];
        String caseSubType = 'Parts/Labor';
		Case aCase = new Case(
        	ContactId = parentContact.Id,
            AccountId = parentAccount.Id,
            RecordTypeId = theRecordType.Id,
            Sub_Type__c = caseSubType
        );
        insert aCase;

      /**
       * @description Inserts a custom Oracle_Order_Type__c record (Oracle Order Type)
       */
		Oracle_Order_Type__c oraOrdType = new Oracle_Order_Type__c(
			Name = TEST_ORACLE_ORDER_TYPE_NAME,
            Order_Type_Id__c = '2655',
            Salesforce_Order_Type__c = true,
            Domestic__c = true
        );
        insert oraOrdType;
		        
        return new Map<String, Object>{
                TEST_PARENT_ACCOUNT => parentAccount,
                TEST_CHILD_ACCOUNT => childAccount,
                TEST_CONTACT => childContact,
                TEST_PARENT_ACC_USER => parentUser,
                TEST_CHILD_ACC_USER => childUser,
                TEST_PRODUCTS => products,
                TEST_CASE => aCase,
                TEST_ORACLE_ORDER_TYPE => oraOrdType
        };
    }
    

    /**
     * @description Creates a cart along with shipping and billing addresses.
     */
    public static ccrz__E_Cart__c createCart(Boolean setBillingAndShippingAddress, Boolean sameAddressAsAccount, Map<String, Object> testData) {

        ccrz__E_Cart__c cart = new ccrz__E_Cart__c();

        if (setBillingAndShippingAddress) {
            Map<String, Object> billingAddress = new Map<String, Object> ();
            Map<String, Object> shippingAddress = new Map<String, Object> ();

            if (sameAddressAsAccount) {
                billingAddress.put(ADDRESS_FIRSTLINE, PARENT_BILL_STREET);
                billingAddress.put(CITY, PARENT_BILL_CITY);
                billingAddress.put(STATE, PARENT_BILL_STATE);
                billingAddress.put(COUNTRY, PARENT_BILL_COUNTRY);
                billingAddress.put(POSTAL_CODE, PARENT_BILL_POSTAL_CODE);

                shippingAddress.put(ADDRESS_FIRSTLINE, CHILD_SHIP_STREET);
                shippingAddress.put(CITY, CHILD_SHIP_CITY);
                shippingAddress.put(STATE, CHILD_SHIP_STATE);
                shippingAddress.put(COUNTRY, CHILD_SHIP_COUNTRY);
                shippingAddress.put(POSTAL_CODE, CHILD_SHIP_POSTAL_CODE);
            } else {
                billingAddress.put(ADDRESS_FIRSTLINE, TEST_STREET);
                billingAddress.put(CITY, TEST_CITY);
                billingAddress.put(STATE, TEST_STATE);
                billingAddress.put(COUNTRY, TEST_COUNTRY);
                billingAddress.put(POSTAL_CODE, TEST_POSTAL_CODE);

                shippingAddress.put(ADDRESS_FIRSTLINE, TEST_STREET);
                shippingAddress.put(CITY, TEST_CITY);
                shippingAddress.put(STATE, TEST_STATE);
                shippingAddress.put(COUNTRY, TEST_COUNTRY);
                shippingAddress.put(POSTAL_CODE, TEST_POSTAL_CODE);
            }
            String billingAddressSFID = insertContactAddress(billingAddress);
            String shippingAddressSFID = insertContactAddress(shippingAddress);

            cart.ccrz__Account__c = ((Account) testData.get(ERG_Test_DataFactory.TEST_CHILD_ACCOUNT)).Id;
            cart.ccrz__Contact__c = ((Contact) testData.get(ERG_Test_DataFactory.TEST_CONTACT)).Id;
            cart.ccrz__User__c = ((User) testData.get(ERG_Test_DataFactory.TEST_CHILD_ACC_USER)).Id;
            cart.ccrz__Storefront__c = TEST_STOREFRONT;
            cart.ccrz__CurrencyISOCode__c = TEST_CURRENCY_CODE;
            cart.ccrz__BillTo__c = billingAddressSFID;
            cart.ccrz__ShipTo__c = shippingAddressSFID;
        }

        insert cart;
        return cart;
    }

    /**
     * @description Inserts a CC Contact address.
     */
    public static String insertContactAddress(Map<String, Object> address) {
        String addressSFID;
        Map<String, Object> addressCreateResult = ccrz.ccAPIAddress.createAddress(new Map<String, Object>{
                ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                ccrz.ccApiAddress.ADDRESSLIST => new List<Map<String, Object>>{
                        address
                }
        });

        if (addressCreateResult != null && (Boolean) addressCreateResult.get(ccrz.ccApi.SUCCESS)) {
            List<String> addressList = (List<String>) addressCreateResult.get(ccrz.ccApiAddress.ADDRESSIDLIST);
            if (addressList != null && addressList.size() > 0) {
                addressSFID = addressList[0];
            }
        }
        return addressSFID;
    }

    /**
     * @description Creates and inserts a storedPayment record associated with the passed in Account.
     */
    public static ccrz__E_StoredPayment__c createInsertStoredPayment(Account currAccount) {
        ccrz__E_StoredPayment__c newStoredPayment = new ccrz__E_StoredPayment__c();
        newStoredPayment.Name = 'Test payment';
        newStoredPayment.ccrz__DisplayName__c = 'ACH Net 30';
        newStoredPayment.ccrz__StartDate__c = System.today();
        newStoredPayment.ccrz__EndDate__c = System.today().addDays(3);
        newStoredPayment.ccrz__AccountType__c = 'po';
        newStoredPayment.ccrz__Account__c = currAccount.Id;
        newStoredPayment.ccrz__Enabled__c = true;
        newStoredPayment.ccrz__Storefront__c = TEST_STOREFRONT;

        insert newStoredPayment;

        return newStoredPayment;
    }

    /**
     * @description Creates an opportunity that can be convered into a CC Order
     */
    public static Opportunity createOrderOpportunity(String accountId, String shipMethod, String billingOption) {
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Oppty';
        opp.StageName = 'New';
        opp.AccountId = accountId;
        opp.CloseDate = System.today();
        opp.Pricebook2Id = Test.getStandardPricebookId();

        insert opp;
        return opp;
    }

    /**
     * @description Creates Product2 records for all CC Products along with price book and price book entry.
     */
    public static List<Product2> createInsertProduct2Catalog(List<ccrz__E_Product__c> testCCProducts) {

        // Product2
        List<Product2> testProduct2List = new List<Product2>();
        for (ccrz__E_Product__c prod : testCCProducts) {
            Product2 currProduct = new Product2();
            currProduct.Name = prod.Name;
            testProduct2List.add(currProduct);
        }
        insert testProduct2List;

        // PriceBook Entry
        List<PricebookEntry> product2Prices = new List<PricebookEntry>();
        for (Product2 prod : testProduct2List) {
            PricebookEntry pli = new PricebookEntry();
            pli.Product2Id = prod.Id;
            pli.Pricebook2Id = Test.getStandardPricebookId();
            pli.UnitPrice = 100;
            pli.IsActive = true;

            product2Prices.add(pli);
        }
        insert product2Prices;

        return testProduct2List;
    }

    /**
     * @description Creates LineItems for the opportunity.
     */
    public static List<OpportunityLineItem> createOpptyLines(String opportunitySfid, List<Product2> products) {
        List<OpportunityLineItem> opptyLines = new List<OpportunityLineItem>();

        for (Product2 prod : products) {
            OpportunityLineItem currLine = new OpportunityLineItem();
            currLine.Product2Id = prod.Id;
            currLine.Quantity = 2;
            currLine.UnitPrice = 100;
            currLine.OpportunityId = opportunitySfid;
            opptyLines.add(currLine);
        }
        insert opptyLines;
        return opptyLines;
    }

    public static List<ccrz__E_ShippingRate__c> createInsertShippingRates() {
        List<ccrz__E_ShippingRate__c> testShippingRateList = new List<ccrz__E_ShippingRate__c>();

        ccrz__E_ShippingRate__c shipRate1 = new ccrz__E_ShippingRate__c();
        shipRate1.ccrz__Shipper__c = 'Shipper1';
        shipRate1.Name = 'Ground';
        shipRate1.ccrz__Ground__c = true;
        shipRate1.ccrz__ShippingRate__c = 10;
        shipRate1.ccrz__Storefront__c = TEST_STOREFRONT;
        shipRate1.ccrz__MinWeight__c = 0;
        shipRate1.ccrz__MaxWeight__c = 9999;
        shipRate1.ccrz__CurrencyISOCode__c = TEST_CURRENCY_CODE;
        shipRate1.ccrz__Sequence__c = 1;

        ccrz__E_ShippingRate__c shipRate2 = new ccrz__E_ShippingRate__c();
        shipRate2.ccrz__Shipper__c = 'Shipper2';
        shipRate2.Name = 'Ground';
        shipRate2.ccrz__ShippingRate__c = 10;
        shipRate2.ccrz__Storefront__c = TEST_STOREFRONT;
        shipRate2.ccrz__MinWeight__c = 0;
        shipRate2.ccrz__MaxWeight__c = 9999;
        shipRate2.ccrz__CurrencyISOCode__c = TEST_CURRENCY_CODE;
        shipRate2.ccrz__Sequence__c = 2;

        testShippingRateList.add(shipRate1);
        testShippingRateList.add(shipRate2);

        insert testShippingRateList;
        return testShippingRateList;
    }

}