@isTest
public class CC_ERG_LogicCartValidate_Test {
    
    @TestSetup
    static void setupData() {
        CC_ERG_TestData.initCCSettings();
    }
    
    @isTest
    static void processValidate_Test(){
        Map<String, Object> inputData = new Map<String, Object>();
        // create cart
        //ccrz__E_Cart__c newCart = new ccrz__E_Cart__c(ccrz__ActiveCart__c = true,ccrz__EncryptedId__c= 'd548c62c-e1fa-4f42-8b2e-e29bf8de3b10',OwnerId = '0053C000003lJZiQAM',
        //                                            Source__c = 'Ergotron');
        ccrz__E_Cart__c newCart = new ccrz__E_Cart__c( ccrz__ActiveCart__c = true,ccrz__BuyerCompanyName__c = 'TestCompany',
          ccrz__CartStatus__c = 'Open',cc_FreightCarrierActNbr__c= 'FCA234234',Source__c = 'Ergotron');  
        insert newCart;
        
        ccrz__E_Product__c ccrzProduct = new ccrz__E_Product__c( 
            ccrz__SKU__c = 'totally-a-sku', 
            ccrz__ShortDesc__c = 'Fancy Ketchup',
            ccrz__Taxable__c = true,
            ccrz__Storefront__c = 'DefaultStore',
            ccrz__StartDate__c = System.today(),
            ccrz__EndDate__c = System.today() + 20,
            ccrz__ProductStatus__c = 'Released',
            cc_NonInventory_Fl__c = false
        ); 
        insert ccrzProduct;
        
        ccrz__E_ProductInventoryItem__c productInventory = new ccrz__E_ProductInventoryItem__c(
            ccrz__QtyAvailable__c = 10,
            ccrz__ProductItem__c = ccrzProduct.Id
        );
        insert productInventory;
        
        ccrz__E_CartItem__c ccrzCartItem = new ccrz__E_CartItem__c( 
            ccrz__ItemLabel__c = 'buycartitem', 
            ccrz__Cart__c = newCart.id, 
            ccrz__Product__c = ccrzProduct.Id, 
            ccrz__Price__c = 24.99,
            ccrz__SubAmount__c = 5.00, 
            ccrz__PricingType__c = 'auto',  
            ccrz__RequestDate__c = Date.newInstance( 2015, 12, 8 ),
            ccrz__ProductType__c = 'Product',
            ccrz__UnitOfMeasure__c = 'Each',
            ccrz__cartItemType__c = 'Major',
            ccrz__Quantity__c = 1
        );
        insert ccrzCartItem;
        
        Map<String, Object> cartDetails = new Map<String, Object>();
        cartDetails.put('activeCart', true);
        cartDetails.put('encryptedId', 'd548c62c-e1fa-4f42-8b2e-e29bf8de3b10');
        cartDetails.put('ownerId', '0053C000003lJZiQAM');
        cartDetails.put('sfdcCurrencyISOCode', 'USD');
        cartDetails.put('sfdcName', '00006845');
        cartDetails.put('sfid', newCart.id);
        
        List<ccrz.cc_bean_Message> messages = new List<ccrz.cc_bean_Message>();
        List<Map<String, Object>> theJsonMapList = new List<Map<String, Object>>();
        theJsonMapList.add(cartDetails);
        inputData.put('allowCheckout', true);
        inputData.put('cartId', newCart.id);
        inputData.put(ccrz.ccApiCart.CART_OBJLIST,theJsonMapList);
        inputData.put('messages', messages);
        inputData.put('version', 10);
        inputData.put('storefront', 'DefaultStore');
        CC_ERG_LogicCartValidate validateCart = new CC_ERG_LogicCartValidate();
        Map<String, Object> outputData = validateCart.processValidate(inputData); 
        System.assertEquals(true,outputData.get('allowCheckout'));
    }
    
    @isTest
    static void processValidate_NegativeTest(){
        Map<String, Object> inputData = new Map<String, Object>();
        // create cart
        //ccrz__E_Cart__c newCart = new ccrz__E_Cart__c( ccrz__ActiveCart__c = true,
          //                                         ccrz__EncryptedId__c= 'd548c62c-e1fa-4f42-8b2e-e29bf8de3b10',OwnerId = '0053C000003lJZiQAM',
            //                                        Source__c = 'salesforce');
            ccrz__E_Cart__c newCart = new ccrz__E_Cart__c( ccrz__ActiveCart__c = true,ccrz__BuyerCompanyName__c = 'TestCompany',
          ccrz__CartStatus__c = 'Open',cc_FreightCarrierActNbr__c= 'FCA234234',Source__c = 'salesforce');  
        insert newCart;
        
        ccrz__E_Product__c ccrzProduct = new ccrz__E_Product__c( 
            ccrz__SKU__c = 'totally-a-sku', 
            ccrz__ShortDesc__c = 'Fancy Ketchup',
            ccrz__Taxable__c = true,
            ccrz__Storefront__c = 'DefaultStore',
            ccrz__StartDate__c = System.today(),
            ccrz__EndDate__c = System.today() + 20,
            ccrz__ProductStatus__c = 'Released',
            cc_NonInventory_Fl__c = false
        ); 
        insert ccrzProduct;
        
        ccrz__E_ProductInventoryItem__c productInventory = new ccrz__E_ProductInventoryItem__c(
            ccrz__QtyAvailable__c = 10,
            ccrz__ProductItem__c = ccrzProduct.Id
        );
        insert productInventory;
        
        ccrz__E_CartItem__c ccrzCartItem = new ccrz__E_CartItem__c(  
            ccrz__Cart__c = newCart.id, 
            ccrz__Product__c = ccrzProduct.Id, 
            ccrz__Price__c = 24.99,
            ccrz__SubAmount__c = 5.00, 
            ccrz__PricingType__c = 'auto',  
            ccrz__RequestDate__c = Date.newInstance( 2015, 12, 8 ),
            ccrz__ProductType__c = 'Product',
            ccrz__UnitOfMeasure__c = 'Each',
            ccrz__cartItemType__c = 'Major',
            ccrz__Quantity__c = 1,
            ergo_wh_location__c = null
        );
        insert ccrzCartItem;
        
        Map<String, Object> cartDetails = new Map<String, Object>();
        cartDetails.put('activeCart', true);
        cartDetails.put('encryptedId', 'd548c62c-e1fa-4f42-8b2e-e29bf8de3b10');
        cartDetails.put('ownerId', '0053C000003lJZiQAM');
        cartDetails.put('sfdcCurrencyISOCode', 'USD');
        cartDetails.put('sfdcName', '00006845');
        cartDetails.put('sfid', newCart.id);
        
        List<ccrz.cc_bean_Message> messages = new List<ccrz.cc_bean_Message>();
        List<Map<String, Object>> theJsonMapList = new List<Map<String, Object>>();
        theJsonMapList.add(cartDetails);
        inputData.put('allowCheckout', true);
        inputData.put('cartId',  newCart.id);
        inputData.put(ccrz.ccApiCart.CART_OBJLIST,theJsonMapList);
        inputData.put('messages', messages);
        inputData.put('version', 10);
        inputData.put('storefront', 'DefaultStore');
        CC_ERG_LogicCartValidate validateCart = new CC_ERG_LogicCartValidate();
        Map<String, Object> outputData = validateCart.processValidate(inputData); 
        System.assertEquals(false,outputData.get('allowCheckout'));
    }
    
    @isTest
    static void whenAvailableInventoryLess_Test(){
        Map<String, Object> inputData = new Map<String, Object>();
        // create cart
        //ccrz__E_Cart__c newCart = new ccrz__E_Cart__c( ccrz__ActiveCart__c = true,
          //                                         ccrz__EncryptedId__c= 'd548c62c-e1fa-4f42-8b2e-e29bf8de3b10',OwnerId = '0053C000003lJZiQAM',
            //                                        Source__c = 'Ergotron');
          ccrz__E_Cart__c newCart = new ccrz__E_Cart__c( ccrz__ActiveCart__c = true,ccrz__BuyerCompanyName__c = 'TestCompany',
          ccrz__CartStatus__c = 'Open',cc_FreightCarrierActNbr__c= 'FCA234234',Source__c = 'Ergotron');  
        insert newCart;
        
        ccrz__E_Product__c ccrzProduct = new ccrz__E_Product__c( 
            ccrz__SKU__c = 'totally-a-sku', 
            ccrz__ShortDesc__c = 'Fancy Ketchup',
            ccrz__Taxable__c = true,
            ccrz__Storefront__c = 'DefaultStore',
            ccrz__StartDate__c = System.today(),
            ccrz__EndDate__c = System.today() + 20,
            ccrz__ProductStatus__c = 'Released',
            cc_NonInventory_Fl__c = false
        ); 
        insert ccrzProduct;
        
        ccrz__E_ProductInventoryItem__c productInventory = new ccrz__E_ProductInventoryItem__c(
            ccrz__QtyAvailable__c = 2,
            ccrz__ProductItem__c = ccrzProduct.Id
        );
        insert productInventory;
        
        ccrz__E_CartItem__c ccrzCartItem = new ccrz__E_CartItem__c(  
            ccrz__Cart__c = newCart.id, 
            ccrz__Product__c = ccrzProduct.Id, 
            ccrz__Price__c = 24.99,
            ccrz__SubAmount__c = 5.00, 
            ccrz__PricingType__c = 'auto',  
            ccrz__RequestDate__c = Date.newInstance( 2015, 12, 8 ),
            ccrz__ProductType__c = 'Product',
            ccrz__UnitOfMeasure__c = 'Each',
            ccrz__cartItemType__c = 'Major',
            ccrz__Quantity__c = 1,
            ergo_wh_location__c = null
        );
        insert ccrzCartItem;
        
        Map<String, Object> cartDetails = new Map<String, Object>();
        cartDetails.put('activeCart', true);
        cartDetails.put('encryptedId', 'd548c62c-e1fa-4f42-8b2e-e29bf8de3b10');
        cartDetails.put('ownerId', '0053C000003lJZiQAM');
        cartDetails.put('sfdcCurrencyISOCode', 'USD');
        cartDetails.put('sfdcName', '00006845');
        cartDetails.put('sfid', newCart.id);
        
        List<ccrz.cc_bean_Message> messages = new List<ccrz.cc_bean_Message>();
        List<Map<String, Object>> theJsonMapList = new List<Map<String, Object>>();
        theJsonMapList.add(cartDetails);
        inputData.put('allowCheckout', true);
        inputData.put('cartId',  newCart.id);
        inputData.put(ccrz.ccApiCart.CART_OBJLIST,theJsonMapList);
        inputData.put('messages', messages);
        inputData.put('version', 10);
        inputData.put('storefront', 'DefaultStore');
        CC_ERG_LogicCartValidate validateCart = new CC_ERG_LogicCartValidate();
        Map<String, Object> outputData = validateCart.processValidate(inputData); 
        System.assertEquals(false,outputData.get('allowCheckout'));
    }
    
}