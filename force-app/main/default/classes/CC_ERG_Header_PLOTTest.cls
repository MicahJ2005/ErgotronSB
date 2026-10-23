@isTest
public class CC_ERG_Header_PLOTTest {
	public static Map<String, Object> testData;

    public static void setupTestData(Boolean createParentAccount) {
        
        SmartyStreets_API__c ss = new SmartyStreets_API__c();
            ss.Name = 'SeedUnitAddressVerify';
            ss.auth_id__c = 'adsmfqmwepm09daasd';
            ss.auth_token__c = '23240kfir8fj8f8';
        insert ss;           
        ccrz__E_Configuration__c theConfig = new ccrz__E_Configuration__c(
            
        );
        testData = CC_ERG_Test_DataFactory.setupAccountContactUser(createParentAccount,true);
    }
    
    @isTest
    static void getLogoURLTest() {
        CC_ERG_Header_PLOT headerPlot= new CC_ERG_Header_PLOT();
        System.assertNotEquals(null, CC_ERG_Header_PLOT.getLogoURL());
        System.assertNotEquals(null, headerPlot.getHeaderLinks());
        System.assertNotEquals(null, headerPlot.getTopHeaderLinks());
        headerPlot.cartTotalQuantity = 34.01;
        System.assertNotEquals(null, headerPlot.getCartTotalQuantity());
        headerPlot.theOrderType = 'Ergotron';
        System.assertNotEquals(null, headerPlot.gettheOrderType());
        headerPlot.thePriceList = 'USD Price List';
        System.assertNotEquals(null, headerPlot.getthePriceList());
    }
    
    @isTest
    static void getLogoURL_Test() {
        setupTestData(true);
        
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = (String) testData.get(CC_ERG_Test_DataFactory.TEST_STOREFRONT);
        ctx.portalUserId = ((User) testData.get(CC_ERG_Test_DataFactory.TEST_CHILD_ACC_USER)).Id;
        ctx.effAccountId = ((Account) testData.get(CC_ERG_Test_DataFactory.TEST_CHILD_ACCOUNT)).Id;
        ccrz.cc_CallContext.init(ctx);
        
        User refetchUser = [SELECT Id, ContactId FROM User WHERE Id = :ctx.portalUserId];
        Contact refetchContact = [SELECT Id, Store_Member__c,LastName,Email,FirstName FROM Contact WHERE Id = :refetchUser.ContactId];
        
        ccrz__E_ContactAddr__c ccrzContactAddress = new ccrz__E_ContactAddr__c(
            ccrz__LastName__c = refetchContact.LastName,
            ccrz__Email__c = refetchContact.Email,
            ccrz__FirstName__c = refetchContact.FirstName,
            ccrz__City__c = 'Waconia',
            ccrz__PostalCode__c = '05387',
            ccrz__CountryISOCode__c = 'US',
            ccrz__Country__c = 'United States',
            ccrz__AddressSecondline__c = 'street 1234',
            ccrz__AddressFirstline__c = 'Address second line',
            ccrz__StateISOCode__c = 'NY',
            ccrz__CompanyName__c = 'Docmation'
        );
        insert ccrzContactAddress;
        
        ccrz__E_Cart__c ccCart = CC_ERG_TestData.createCart(true,true,testData);
        
        ccrz__E_Order__c ccrzOrder = new ccrz__E_Order__c(
            ccrz__OriginatedCart__c =  ccCart.Id,
            ccrz__OrderStatus__c = 'Order Submitted',
            ccrz__OrderDate__c = System.today(),
            ccrz__Name__c = 'Cc Order',
            ccrz__CurrencyISOCode__c = 'USD',
            ccrz__Storefront__c = 'DefaultStore',
            ccrz__TaxAmount__c = 2,
            ccrz__ShipTo__c = ccrzContactAddress.Id,
            ccrz__BillTo__c = ccrzContactAddress.Id,
            ccrz__Account__c = ((Account) testData.get(CC_ERG_Test_DataFactory.TEST_CHILD_ACCOUNT)).Id,
            ccrz__Contact__c = refetchContact.Id,
            ccrz__ShipMethod__c = 'FedEx - 3DA'  
        );
        
        PageReference myVfPage = Page.ERG_Header;
        Test.setCurrentPage(myVfPage);
        ApexPages.currentPage().getParameters().put('cartId',ccCart.Id);
        ApexPages.currentPage().getParameters().put('o',ccrzOrder.Id);
        
        CC_ERG_Header_PLOT headerPlot= new CC_ERG_Header_PLOT();
        System.assertNotEquals(null, CC_ERG_Header_PLOT.getLogoURL());
        System.assertNotEquals(null, headerPlot.getHeaderLinks());
        System.assertNotEquals(null, headerPlot.getTopHeaderLinks());
        headerPlot.cartTotalQuantity = 34.01;
        System.assertNotEquals(null, headerPlot.getCartTotalQuantity());
        headerPlot.theOrderType = 'Ergotron';
        System.assertNotEquals(null, headerPlot.gettheOrderType());
        headerPlot.thePriceList = 'USD Price List';
        System.assertNotEquals(null, headerPlot.getthePriceList());
    }
    
    @isTest
    static void fetchOrderNumber_Test() {
        setupTestData(true);
        
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = (String) testData.get(CC_ERG_Test_DataFactory.TEST_STOREFRONT);
        ctx.portalUserId = ((User) testData.get(CC_ERG_Test_DataFactory.TEST_CHILD_ACC_USER)).Id;
        ctx.effAccountId = ((Account) testData.get(CC_ERG_Test_DataFactory.TEST_CHILD_ACCOUNT)).Id;
        ccrz.cc_CallContext.init(ctx);
        
        User refetchUser = [SELECT Id, ContactId FROM User WHERE Id = :ctx.portalUserId];
        Contact refetchContact = [SELECT Id, Store_Member__c,LastName,Email,FirstName FROM Contact WHERE Id = :refetchUser.ContactId];
        
        ccrz__E_ContactAddr__c ccrzContactAddress = new ccrz__E_ContactAddr__c(
            ccrz__LastName__c = refetchContact.LastName,
            ccrz__Email__c = refetchContact.Email,
            ccrz__FirstName__c = refetchContact.FirstName,
            ccrz__City__c = 'Waconia',
            ccrz__PostalCode__c = '05387',
            ccrz__CountryISOCode__c = 'US',
            ccrz__Country__c = 'United States',
            ccrz__AddressSecondline__c = 'street 1234',
            ccrz__AddressFirstline__c = 'Address second line',
            ccrz__StateISOCode__c = 'NY',
            ccrz__CompanyName__c = 'Docmation'
        );
        insert ccrzContactAddress;
        
        ccrz__E_Cart__c ccCart = CC_ERG_TestData.createCart(true,true,testData);
        
        ccrz__E_Order__c ccrzOrder = new ccrz__E_Order__c(
            ccrz__OriginatedCart__c =  ccCart.Id,
            ccrz__OrderStatus__c = 'Order Submitted',
            ccrz__OrderDate__c = System.today(),
            ccrz__Name__c = 'Cc Order',
            ccrz__CurrencyISOCode__c = 'USD',
            ccrz__Storefront__c = 'DefaultStore',
            ccrz__TaxAmount__c = 2,
            ccrz__ShipTo__c = ccrzContactAddress.Id,
            ccrz__BillTo__c = ccrzContactAddress.Id,
            ccrz__Account__c = ((Account) testData.get(CC_ERG_Test_DataFactory.TEST_CHILD_ACCOUNT)).Id,
            ccrz__Contact__c = refetchContact.Id,
            ccrz__ShipMethod__c = 'FedEx - 3DA'  
        );
        
        PageReference myVfPage = Page.ERG_Header;
        Test.setCurrentPage(myVfPage);
        ApexPages.currentPage().getParameters().put('cartId',ccCart.Id);
        ApexPages.currentPage().getParameters().put('source','ergotron');
        ApexPages.currentPage().getParameters().put('o',ccrzOrder.Id);
        
        CC_ERG_Header_PLOT headerPlot= new CC_ERG_Header_PLOT();
        CC_ERG_Header_PLOT.fetchOrderNumber(ccrzOrder.Id);

        ccrz__E_Product__c product = new ccrz__E_Product__c(
            Name = 'testprodSKU',
            ccrz__SKU__c = 'testprodSKU',
            ccrz__ProductStatus__c = 'Released',
            ccrz__ProductType__c = 'Product',
            ccrz__Storefront__c = 'DefaultStoreTest',
            ccrz__ShortDesc__c = 'testprodSKU',
            ccrz__ShortDescRT__c = 'testprodSKU',
            ccrz__StartDate__c = System.today().addYears(-1),
            ccrz__EndDate__c = System.today().addYears(+1),
            ccrz__ShippingWeight__c = 1
        );
        insert product;
        ccrz__E_Product__c product1 = new ccrz__E_Product__c(
            Name = 'testprodSKU1',
            ccrz__AlternateName__c = 'testprodSKU1',
            ccrz__SKU__c = 'testprodSKU1',
            ccrz__ProductStatus__c = 'Released',
            ccrz__ProductType__c = 'Product',
            ccrz__Storefront__c = 'DefaultStoreTest',
            ccrz__ShortDesc__c = 'testprodSKU1',
            ccrz__ShortDescRT__c = 'testprodSKU1',
            ccrz__StartDate__c = System.today().addYears(-1),
            ccrz__EndDate__c = System.today().addYears(+1),
            ccrz__ShippingWeight__c = 1
        );
        insert product1;

        ccrz__E_RelatedProduct__c relProd = new ccrz__E_RelatedProduct__c(
            ccrz__Enabled__c = true,
            ccrz__Product__c = product.Id,
            ccrz__RelatedProduct__c = product1.Id,
            ccrz__RelatedProductType__c = 'Accessories',
            ccrz__Sequence__c = 500,
            ccrz__StartDate__c = System.today().addYears(-1),
            ccrz__EndDate__c = System.today().addYears(+1)
        );
        insert relProd;

        ccrz__E_Product__c productDup = new ccrz__E_Product__c(
            Name = 'testprodsSKU',
            ccrz__SKU__c = 'testprodsSKU',
            ccrz__ProductStatus__c = 'Released',
            ccrz__ProductType__c = 'Product',
            ccrz__Storefront__c = 'DefaultStoreTest',
            ccrz__ShortDesc__c = 'testprodsSKU',
            ccrz__ShortDescRT__c = 'testprodsSKU',
            ccrz__StartDate__c = System.today().addYears(-1),
            ccrz__EndDate__c = System.today().addYears(+1),
            ccrz__ShippingWeight__c = 1
        );
        insert productDup;
        List<String> prodIds = new List<String>{productDup.Id};
        // List<ccrz__E_Product__c> products = CC_ERG_Test_DataFactory.createInsertTestProducts(10, 0);

        CC_ERG_Header_PLOT.addToCartRelProd('testprodsSKU', ccCart.Id);
        CC_ERG_Header_PLOT.fetchPliOfProd(String.valueOf(product.Id), prodIds);
    }
    
    /**
     * @author R1
     * @description test method for setOrderAsAuthorized method
    **/
    @isTest
    static void setOrderAsAuthorizedTest(){
        ccrz__E_Cart__c cart = new ccrz__E_Cart__c(ccrz__EncryptedId__c = 'test',Payment_Reference__c = 'test');
        insert cart;
        ccrz__E_Order__c  order = new ccrz__E_Order__c(ccrz__OriginatedCart__c = cart.id, ccrz__OrderStatus__c = 'Open'); 
        insert order;
        Test.startTest();
        Map<String,Object> response = CC_ERG_Header_PLOT.setOrderAsAuthorized(order.Id);
        Test.stopTest();
        Assert.areEqual(true,response.get('success'),'setOrderAsAuthorizedTest assertion failed');
    }
}