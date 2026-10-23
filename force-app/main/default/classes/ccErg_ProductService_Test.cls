@isTest
public class ccErg_ProductService_Test {
	@TestSetup
    static void setupData() {
        CC_ERG_TestData.initCCSettings();
    }

	@isTest
    public static void fetchProductsService_Test() {
        ccrz__E_Cart__c cart = new ccrz__E_Cart__c();
        cart.ccrz__CartStatus__c = 'Open';
        cart.ccrz__ActiveCart__c = True;
        cart.ccrz__BuyerCompanyName__c = 'testCompany';
        Insert cart;
        //Account/Contact/User details
        ccrz__E_AccountGroup__c accountGroup = CC_ERG_Test_DataFactory.createInsertTestAccountGroup();
        //PriceLists
        ccrz__E_PriceList__c pricelist = CC_ERG_Test_DataFactory.createInsertTestPricelist('Ergotron Employee');
        CC_ERG_Test_DataFactory.createInsertTestAccountGroupPriceList(accountGroup, pricelist);
        
        // Create a CC Product Category
        List<ccrz__E_Category__c> listTestCategory = CC_ERG_Test_DataFactory.createInsertTestCategory();        

        //Products and PriceListItems
        List<ccrz__E_Product__c> products = CC_ERG_Test_DataFactory.createInsertTestProducts(2, 0);
        CC_ERG_Test_DataFactory.createInsertPriceListItems(products, pricelist);
        List<ccrz__E_PriceListItem__c> items  = [Select Id,ccrz__Product__c  from ccrz__E_PriceListItem__c where ccrz__Pricelist__c  =:pricelist.Id];
        Map<Id, ccrz__E_Product__c> mapProducts = new Map<Id, ccrz__E_Product__c>(products);
        Map<String, ccrz__E_PriceListItem__c> mapPriceList = new Map<String, ccrz__E_PriceListItem__c>(items);
        System.debug('mapProducts : '+mapProducts);
    	Map<String, Object> inputData = new Map<String, Object>();
        inputData.put(CC_ERG_Constant.PRICE_LIST_NAME,'');
        inputData.put(CC_ERG_Constant.STOREFRONT_NAME,'DefaultStore');
        inputData.put(CC_ERG_Constant.PRICE_LIST_ID,pricelist.Id);
        inputData.put(CC_ERG_Constant.PRODUCT_SEARCH_RESULTS,mapProducts);
        inputData.put(CC_ERG_Constant.PRODUCT_SEARCH_PRICE_LIST_RESULTS,mapPriceList);
        CC_ERG_ProductResponse response = ccErg_ProductService.fetchProductsService(inputData);
    }
    
    @isTest
    public static void populateRelatedProductComponents_Test() {
        ccrz__E_Cart__c cart = new ccrz__E_Cart__c();
        cart.ccrz__CartStatus__c = 'Open';
        cart.ccrz__ActiveCart__c = True;
        cart.ccrz__BuyerCompanyName__c = 'testCompany';
        Insert cart;
        //Account/Contact/User details
        ccrz__E_AccountGroup__c accountGroup = CC_ERG_Test_DataFactory.createInsertTestAccountGroup();
        //PriceLists
        ccrz__E_PriceList__c pricelist = CC_ERG_Test_DataFactory.createInsertTestPricelist('Ergotron Employee');
        CC_ERG_Test_DataFactory.createInsertTestAccountGroupPriceList(accountGroup, pricelist);
        
        // Create a CC Product Category
        List<ccrz__E_Category__c> listTestCategory = CC_ERG_Test_DataFactory.createInsertTestCategory();        

        //Products and PriceListItems
        List<ccrz__E_Product__c> products = CC_ERG_Test_DataFactory.createInsertTestProducts(2, 0);
        CC_ERG_Test_DataFactory.createInsertPriceListItems(products, pricelist);
        
        Map<Id, ccrz__E_Product__c> mapProducts = new Map<Id, ccrz__E_Product__c>(products);
        System.debug('mapProducts : '+mapProducts);
    	Map<String, Object> inputData = new Map<String, Object>();
        inputData.put(CC_ERG_Constant.PRICE_LIST_NAME,'');
        inputData.put(CC_ERG_Constant.STOREFRONT_NAME,'DefaultStore');
        inputData.put(CC_ERG_Constant.PRICE_LIST_ID,pricelist.Id);
        inputData.put(CC_ERG_Constant.PRODUCT_SEARCH_RESULTS,mapProducts);
        ccrz__E_RelatedProduct__c relatedProduct = new ccrz__E_RelatedProduct__c();
        relatedProduct.ccrz__RelatedProduct__c = products.get(0).Id;
        relatedProduct.ccrz__Product__c = products.get(1).Id;
        insert relatedProduct;
        List<CC_ERG_ProductResponse.B2BProduct> response = ccErg_ProductService.populateRelatedProductComponents(new List<ccrz__E_RelatedProduct__c>{relatedProduct});
    }
    
    @isTest
    public static void populateB2BBundleComponents_Test() {
        ccrz__E_Cart__c cart = new ccrz__E_Cart__c();
        cart.ccrz__CartStatus__c = 'Open';
        cart.ccrz__ActiveCart__c = True;
        cart.ccrz__BuyerCompanyName__c = 'testCompany';
        Insert cart;
        //Account/Contact/User details
        ccrz__E_AccountGroup__c accountGroup = CC_ERG_Test_DataFactory.createInsertTestAccountGroup();
        //PriceLists
        ccrz__E_PriceList__c pricelist = CC_ERG_Test_DataFactory.createInsertTestPricelist('Ergotron Employee');
        CC_ERG_Test_DataFactory.createInsertTestAccountGroupPriceList(accountGroup, pricelist);
        
        // Create a CC Product Category
        List<ccrz__E_Category__c> listTestCategory = CC_ERG_Test_DataFactory.createInsertTestCategory();        

        //Products and PriceListItems
        List<ccrz__E_Product__c> products = CC_ERG_Test_DataFactory.createInsertTestProducts(2, 0);
        CC_ERG_Test_DataFactory.createInsertPriceListItems(products, pricelist);
        
        Map<Id, ccrz__E_Product__c> mapProducts = new Map<Id, ccrz__E_Product__c>(products);
        System.debug('mapProducts : '+mapProducts);
        ccrz__E_RelatedProduct__c relatedProduct = new ccrz__E_RelatedProduct__c();
        relatedProduct.ccrz__RelatedProduct__c = products.get(0).Id;
        relatedProduct.ccrz__Product__c = products.get(1).Id;
        insert relatedProduct;
        List<CC_ERG_ProductResponse.B2BProduct> response = ccErg_ProductService.populateB2BBundleComponents(products);
    }
    
    @isTest
    public static void populateB2BProduct_Test() {
        ccrz__E_Cart__c cart = new ccrz__E_Cart__c();
        cart.ccrz__CartStatus__c = 'Open';
        cart.ccrz__ActiveCart__c = True;
        cart.ccrz__BuyerCompanyName__c = 'testCompany';
        Insert cart;
        //Account/Contact/User details
        ccrz__E_AccountGroup__c accountGroup = CC_ERG_Test_DataFactory.createInsertTestAccountGroup();
        //PriceLists
        ccrz__E_PriceList__c pricelist = CC_ERG_Test_DataFactory.createInsertTestPricelist('Ergotron Employee');
        CC_ERG_Test_DataFactory.createInsertTestAccountGroupPriceList(accountGroup, pricelist);
        
        // Create a CC Product Category
        List<ccrz__E_Category__c> listTestCategory = CC_ERG_Test_DataFactory.createInsertTestCategory();        

        //Products and PriceListItems
        List<ccrz__E_Product__c> products = CC_ERG_Test_DataFactory.createInsertTestProducts(2, 0);
        CC_ERG_Test_DataFactory.createInsertPriceListItems(products, pricelist);
        
        Map<Id, ccrz__E_Product__c> mapProducts = new Map<Id, ccrz__E_Product__c>(products);
        System.debug('mapProducts : '+mapProducts);
        ccrz__E_RelatedProduct__c relatedProduct = new ccrz__E_RelatedProduct__c();
        relatedProduct.ccrz__RelatedProduct__c = products.get(0).Id;
        relatedProduct.ccrz__Product__c = products.get(0).Id;
        insert relatedProduct;
        ccrz__E_CompositeProduct__c compositeProduct = new ccrz__E_CompositeProduct__c();
        compositeProduct.ccrz__CompositeProductId__c= products.get(0).Id;
        insert compositeProduct;
        CC_ERG_ProductResponse.B2BProduct response = ccErg_ProductService.populateB2BProduct(products.get(0));
    }
    
    @isTest
    public static void populateProductImages_Test() {
        ccrz__E_Cart__c cart = new ccrz__E_Cart__c();
        cart.ccrz__CartStatus__c = 'Open';
        cart.ccrz__ActiveCart__c = True;
        cart.ccrz__BuyerCompanyName__c = 'testCompany';
        Insert cart;
        //Account/Contact/User details
        ccrz__E_AccountGroup__c accountGroup = CC_ERG_Test_DataFactory.createInsertTestAccountGroup();
        //PriceLists
        ccrz__E_PriceList__c pricelist = CC_ERG_Test_DataFactory.createInsertTestPricelist('Ergotron Employee');
        CC_ERG_Test_DataFactory.createInsertTestAccountGroupPriceList(accountGroup, pricelist);
        
        // Create a CC Product Category
        List<ccrz__E_Category__c> listTestCategory = CC_ERG_Test_DataFactory.createInsertTestCategory();        

        //Products and PriceListItems
        List<ccrz__E_Product__c> products = CC_ERG_Test_DataFactory.createInsertTestProducts(2, 0);
        CC_ERG_Test_DataFactory.createInsertPriceListItems(products, pricelist);
        
        Map<Id, ccrz__E_Product__c> mapProducts = new Map<Id, ccrz__E_Product__c>(products);
        System.debug('mapProducts : '+mapProducts);
        ccrz__E_RelatedProduct__c relatedProduct = new ccrz__E_RelatedProduct__c();
        relatedProduct.ccrz__RelatedProduct__c = products.get(0).Id;
        relatedProduct.ccrz__Product__c = products.get(0).Id;
        insert relatedProduct;
        ccrz__E_CompositeProduct__c compositeProduct = new ccrz__E_CompositeProduct__c();
        compositeProduct.ccrz__CompositeProductId__c= products.get(0).Id;
        insert compositeProduct;
        CC_ERG_TestData.createMedia(products);
        List<ccrz__E_ProductMedia__c> listOfProductsMedia = [Select Id,ccrz__Product__c  from ccrz__E_ProductMedia__c where ccrz__Product__c=:products.get(0).Id ];
        Map<String, ccrz__E_ProductMedia__c> mapPMedia = new Map<String, ccrz__E_ProductMedia__c>(listOfProductsMedia);
        CC_ERG_ProductResponse.B2BProduct b2bProduct= new CC_ERG_ProductResponse.B2BProduct();
        b2bProduct.productId =  products.get(0).Id;
        b2bProduct.sku = products.get(0).ccrz__SKU__c ;
        ccErg_ProductService.populateProductImages(mapPMedia,b2bProduct);
        Map<String, Object> inputData = new Map<String, Object>();
        inputData.put(CC_ERG_Constant.PRICE_LIST_NAME,'');
        inputData.put(CC_ERG_Constant.STOREFRONT_NAME,'DefaultStore');
        inputData.put(CC_ERG_Constant.PRICE_LIST_ID,pricelist.Id);
        inputData.put(CC_ERG_Constant.PRODUCT_SEARCH_RESULTS,mapProducts);
        //inputData.put(CC_ERG_Constant.PRODUCT_SEARCH_PRICE_LIST_RESULTS,mapPriceList);
        inputData.put(CC_ERG_Constant.PRODUCT_SEARCH_ALL_PRODUCT_IMAGES,mapPMedia);
        CC_ERG_ProductResponse response = ccErg_ProductService.fetchProductsService(inputData);
    }
    
    @isTest
    public static void populateB2BProductCategories_Test() {
        ccrz__E_Cart__c cart = new ccrz__E_Cart__c();
        cart.ccrz__CartStatus__c = 'Open';
        cart.ccrz__ActiveCart__c = True;
        cart.ccrz__BuyerCompanyName__c = 'testCompany';
        Insert cart;
        //Account/Contact/User details
        ccrz__E_AccountGroup__c accountGroup = CC_ERG_Test_DataFactory.createInsertTestAccountGroup();
        //PriceLists
        ccrz__E_PriceList__c pricelist = CC_ERG_Test_DataFactory.createInsertTestPricelist('Ergotron Employee');
        CC_ERG_Test_DataFactory.createInsertTestAccountGroupPriceList(accountGroup, pricelist);
        
        // Create a CC Product Category
        List<ccrz__E_Category__c> listTestCategory = CC_ERG_Test_DataFactory.createInsertTestCategory();        

        //Products and PriceListItems
        List<ccrz__E_Product__c> products = CC_ERG_Test_DataFactory.createInsertTestProducts(2, 0);
        CC_ERG_Test_DataFactory.createInsertPriceListItems(products, pricelist);
        
        Map<Id, ccrz__E_Product__c> mapProducts = new Map<Id, ccrz__E_Product__c>(products);
        System.debug('mapProducts : '+mapProducts);
        ccrz__E_ProductCategory__c pCat= new ccrz__E_ProductCategory__c();
        pCat.ccrz__Product__c = products.get(0).Id;
        pCat.ccrz__Category__c = listTestCategory.get(0).Id;
        insert pCat;
        List<ccrz__E_ProductCategory__c> productCategories = new List<ccrz__E_ProductCategory__c>();
        productCategories.add(pCat);
        List<CC_ERG_ProductResponse.B2BCategories>  pCataGoreies = ccErg_ProductService.populateB2BProductCategories(productCategories);
    }
    @isTest
    public static void populateB2BProductSpecs_Test() {
        ccrz__E_Cart__c cart = new ccrz__E_Cart__c();
        cart.ccrz__CartStatus__c = 'Open';
        cart.ccrz__ActiveCart__c = True;
        cart.ccrz__BuyerCompanyName__c = 'testCompany';
        Insert cart;
        //Account/Contact/User details
        ccrz__E_AccountGroup__c accountGroup = CC_ERG_Test_DataFactory.createInsertTestAccountGroup();
        //PriceLists
        ccrz__E_PriceList__c pricelist = CC_ERG_Test_DataFactory.createInsertTestPricelist('Ergotron Employee');
        CC_ERG_Test_DataFactory.createInsertTestAccountGroupPriceList(accountGroup, pricelist);
        
        // Create a CC Product Category
        List<ccrz__E_Category__c> listTestCategory = CC_ERG_Test_DataFactory.createInsertTestCategory();        

        //Products and PriceListItems
        List<ccrz__E_Product__c> products = CC_ERG_Test_DataFactory.createInsertTestProducts(2, 0);
        CC_ERG_Test_DataFactory.createInsertPriceListItems(products, pricelist);
        
        Map<Id, ccrz__E_Product__c> mapProducts = new Map<Id, ccrz__E_Product__c>(products);
        System.debug('mapProducts : '+mapProducts);
        ccrz__E_Spec__c specs = new ccrz__E_Spec__c();
        specs.Name = 'Speces';
        specs.ccrz__Desc__c = 'Desc';
        specs.ccrz__DisplayName__c = 'hfh';
        insert specs;
        List<ccrz__E_ProductSpec__c> productSpecs = new List<ccrz__E_ProductSpec__c>();
        ccrz__E_ProductSpec__c pSpec = new ccrz__E_ProductSpec__c();
        pSpec.ccrz__Product__c = products.get(0).Id;
        pSpec.ccrz__Spec__c = specs.Id;
        insert pSpec;
        productSpecs.add(pSpec);
        List<CC_ERG_ProductResponse.B2BSpecs>  pSpecList = ccErg_ProductService.populateB2BProductSpecs(productSpecs);
    }
    
    @isTest
    public static void fetchProductsService_ElseTest() {
        ccrz__E_Cart__c cart = new ccrz__E_Cart__c();
        cart.ccrz__CartStatus__c = 'Open';
        cart.ccrz__ActiveCart__c = True;
        cart.ccrz__BuyerCompanyName__c = 'testCompany';
        Insert cart;
        //Account/Contact/User details
        ccrz__E_AccountGroup__c accountGroup = CC_ERG_Test_DataFactory.createInsertTestAccountGroup();
        //PriceLists
        ccrz__E_PriceList__c pricelist = CC_ERG_Test_DataFactory.createInsertTestPricelist('Ergotron Employee');
        CC_ERG_Test_DataFactory.createInsertTestAccountGroupPriceList(accountGroup, pricelist);
        
        // Create a CC Product Category
        List<ccrz__E_Category__c> listTestCategory = CC_ERG_Test_DataFactory.createInsertTestCategory();        

        //Products and PriceListItems
        List<ccrz__E_Product__c> products = CC_ERG_Test_DataFactory.createInsertTestProducts(2, 0);
        CC_ERG_Test_DataFactory.createInsertPriceListItems(products, pricelist);
        List<ccrz__E_PriceListItem__c> items  = [Select Id,ccrz__Product__c  from ccrz__E_PriceListItem__c where ccrz__Pricelist__c  =:pricelist.Id];
        Map<Id, ccrz__E_Product__c> mapProducts = new Map<Id, ccrz__E_Product__c>(products);
        Map<String, ccrz__E_PriceListItem__c> mapPriceList = new Map<String, ccrz__E_PriceListItem__c>(items);
        System.debug('mapProducts : '+mapProducts);
    	Map<String, Object> inputData = new Map<String, Object>();
        inputData.put(CC_ERG_Constant.PRICE_LIST_NAME,'');
        //inputData.put(CC_ERG_Constant.STOREFRONT_NAME,'DefaultStore');
        inputData.put(CC_ERG_Constant.PRICE_LIST_ID,pricelist.Id);
        inputData.put(CC_ERG_Constant.PRODUCT_SEARCH_RESULTS,mapProducts);
        inputData.put(CC_ERG_Constant.PRODUCT_SEARCH_PRICE_LIST_RESULTS,mapPriceList);
        CC_ERG_ProductResponse response = ccErg_ProductService.fetchProductsService(inputData);
    }
}