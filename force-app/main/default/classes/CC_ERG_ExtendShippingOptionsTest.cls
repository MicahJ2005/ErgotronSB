@isTest
public class CC_ERG_ExtendShippingOptionsTest {
    
    static TestMethod void CC_ERG_ExtendShippingOptions(){
        
        ccrz__E_ShippingRate__c shippingRate= new  ccrz__E_ShippingRate__c();
        shippingRate.Name ='GROUND';
        shippingRate.ccrz__MinWeight__c=0;
        shippingRate.ccrz__MaxWeight__c=10;
        shippingRate.ccrz__Storefront__c='DefaultStore';
        shippingRate.ccrz__ShippingRate__c=10;
        shippingRate.ccrz__Shipper__c='UPS';
        insert shippingRate;
        
        ccrz__E_ShippingRate__c shippingRate1= new  ccrz__E_ShippingRate__c();
        shippingRate1.Name ='Next Day Air';
        shippingRate1.ccrz__MinWeight__c=0;
        shippingRate1.ccrz__MaxWeight__c=10;
        shippingRate1.ccrz__Storefront__c='DefaultStore';
        shippingRate1.ccrz__ShippingRate__c=10;
        shippingRate1.ccrz__Shipper__c='UPS';
        insert shippingRate1;
        
        ccrz__E_ShippingRate__c shippingRate2= new  ccrz__E_ShippingRate__c();
        shippingRate2.Name ='2 Day Air';
        shippingRate2.ccrz__MinWeight__c=10;
        shippingRate2.ccrz__MaxWeight__c=35;
        shippingRate2.ccrz__Storefront__c='DefaultStore';
        shippingRate2.ccrz__ShippingRate__c=10;
        shippingRate2.ccrz__Shipper__c='UPS';
        insert shippingRate2;
        
        
        ccrz__E_ShippingRate__c shippingRate3= new  ccrz__E_ShippingRate__c();
        shippingRate3.Name ='3 Day Select';
        shippingRate3.ccrz__MinWeight__c=50;
        shippingRate3.ccrz__MaxWeight__c=54;
        shippingRate3.ccrz__Storefront__c='DefaultStore';
        shippingRate3.ccrz__ShippingRate__c=10;
        shippingRate3.ccrz__Shipper__c='UPS';
        insert shippingRate3;
        
        ccrz__E_ShippingRate__c shippingRate4= new  ccrz__E_ShippingRate__c();
        shippingRate4.Name ='2 Day Air';
        shippingRate4.ccrz__MinWeight__c=35;
        shippingRate4.ccrz__MaxWeight__c=50;
        shippingRate4.ccrz__Storefront__c='DefaultStore';
        shippingRate4.ccrz__ShippingRate__c=10;
        shippingRate4.ccrz__Shipper__c='UPS';
        insert shippingRate4;
        
        ccrz__E_ShippingRate__c shippingRate5= new  ccrz__E_ShippingRate__c();
        shippingRate5.Name ='Next Day Air';
        shippingRate5.ccrz__MinWeight__c=10;
        shippingRate5.ccrz__MaxWeight__c=35;
        shippingRate5.ccrz__Storefront__c='DefaultStore';
        shippingRate5.ccrz__ShippingRate__c=10;
        shippingRate5.ccrz__Shipper__c='UPS';
        insert shippingRate5;
        
        ccrz__E_ShippingRate__c shippingRate6= new  ccrz__E_ShippingRate__c();
        shippingRate6.Name ='Next Day Air';
        shippingRate6.ccrz__MinWeight__c=35;
        shippingRate6.ccrz__MaxWeight__c=50;
        shippingRate6.ccrz__Storefront__c='DefaultStore';
        shippingRate6.ccrz__ShippingRate__c=10;
        shippingRate6.ccrz__Shipper__c='UPS';
        shippingRate6.Erg_StateIsoCode__c = 'AK';
        insert shippingRate6;
        
        ccrz__E_ShippingRate__c shippingRate7= new  ccrz__E_ShippingRate__c();
        shippingRate7.Name ='Next Day Air';
        shippingRate7.ccrz__MinWeight__c=50;
        shippingRate7.ccrz__MaxWeight__c=54;
        shippingRate7.ccrz__Storefront__c='DefaultStore';
        shippingRate7.ccrz__ShippingRate__c=10;
        shippingRate7.ccrz__Shipper__c='UPS';
        insert shippingRate7;
        
        ccrz__E_Cart__c ccCart = new ccrz__E_Cart__c();
        ccCart.ccrz__CartStatus__c = 'Open';
        ccCart.ccrz__ActiveCart__c = True;
        ccCart.ccrz__BuyerCompanyName__c = 'TestCompany';
        ccCart.cc_FreightCarrierActNbr__c= 'FCA234234';
        insert ccCart;
        
        ccrz__E_Product__c ccProduct = new ccrz__E_Product__c();
        ccProduct.Name = 'Test Prod';
        ccProduct.ccrz__StartDate__c = Date.Today();
        ccProduct.ccrz__EndDate__c = Date.today().addDays(10);
        ccProduct.ccrz__SKU__c ='35-341-200';
        ccProduct.ccrz__ProductStatus__c ='Released';
        ccProduct.ccrz__Quantityperunit__c =1.000000;
        ccProduct.ccrz__ShippingWeight__c= 10;
        insert ccProduct;
        
        ccrz__E_Product__c ccProduct1 = new ccrz__E_Product__c(Name = 'Test Prod1',ccrz__StartDate__c = Date.Today(),ccrz__EndDate__c = Date.today().addDays(10),ccrz__SKU__c ='35-341-201',ccrz__ProductStatus__c ='Released',
                                                               ccrz__Quantityperunit__c =1.000000,ccrz__ShippingWeight__c= 51);
        insert ccProduct1;
        
        ccrz__E_Product__c ccProduct2 = new ccrz__E_Product__c(Name = 'Test Prod2',ccrz__StartDate__c = Date.Today(),ccrz__EndDate__c = Date.today().addDays(10),ccrz__SKU__c ='35-341-202',ccrz__ProductStatus__c ='Released',
                                                               ccrz__Quantityperunit__c =1.000000,ccrz__ShippingWeight__c= 34);
        insert ccProduct2;
        
        ccrz__E_Product__c ccProduct3 = new ccrz__E_Product__c(Name = 'Test Prod3',ccrz__StartDate__c = Date.Today(),ccrz__EndDate__c = Date.today().addDays(10),ccrz__SKU__c ='35-341-203',ccrz__ProductStatus__c ='Released',
                                                               ccrz__Quantityperunit__c =1.000000,ccrz__ShippingWeight__c= 40);
        insert ccProduct3;
        ccrz__E_Product__c ccProduct4 = new ccrz__E_Product__c(Name = 'Test Prod4',ccrz__StartDate__c = Date.Today(),ccrz__EndDate__c = Date.today().addDays(10),ccrz__SKU__c ='35-341-204',ccrz__ProductStatus__c ='Released',
                                                               ccrz__Quantityperunit__c =1.000000,ccrz__ShippingWeight__c= 40);
        insert ccProduct4;    
        
        ccrz__E_Product__c ccProduct5 = new ccrz__E_Product__c(Name = 'Test Prod5',ccrz__StartDate__c = Date.Today(),ccrz__EndDate__c = Date.today().addDays(10),ccrz__SKU__c ='35-341-205',ccrz__ProductStatus__c ='Released',
                                                               ccrz__Quantityperunit__c =1.000000,ccrz__ShippingWeight__c= 35);
        insert ccProduct5; 
        
        ccrz__E_Product__c ccProduct6 = new ccrz__E_Product__c(Name = 'Test Prod6',ccrz__StartDate__c = Date.Today(),ccrz__EndDate__c = Date.today().addDays(10),ccrz__SKU__c ='35-341-206',ccrz__ProductStatus__c ='Released',
                                                               ccrz__Quantityperunit__c =1.000000,ccrz__ShippingWeight__c= 52);
        insert ccProduct6;   
        ccrz__E_CartItem__c ccCartItem = new ccrz__E_CartItem__c(ccrz__Cart__c = ccCart.id,ccrz__Quantity__c = 4,ccrz__Product__c = ccProduct.Id,
                                                                 ccrz__Price__c = 501.00,ccrz__SubAmount__c = 501.00);
        insert ccCartItem;
        ccrz__E_CartItem__c ccCartItem1 = new ccrz__E_CartItem__c(ccrz__Cart__c = ccCart.id,ccrz__Quantity__c = 4,ccrz__Product__c = ccProduct1.Id,
                                                                  ccrz__Price__c = 501.00,ccrz__SubAmount__c = 501.00);
        insert ccCartItem1;
        
        ccrz__E_CartItem__c ccCartItem2 = new ccrz__E_CartItem__c(ccrz__Cart__c = ccCart.id,ccrz__Quantity__c = 4,ccrz__Product__c = ccProduct2.Id,
                                                                  ccrz__Price__c = 501.00,ccrz__SubAmount__c = 501.00);
        insert ccCartItem2;
        
        ccrz__E_CartItem__c ccCartItem3 = new ccrz__E_CartItem__c(ccrz__Cart__c = ccCart.id,ccrz__Quantity__c = 4,ccrz__Product__c = ccProduct3.Id,
                                                                  ccrz__Price__c = 501.00,ccrz__SubAmount__c = 501.00);
        insert ccCartItem3;
        
        ccrz__E_CartItem__c ccCartItem4 = new ccrz__E_CartItem__c(ccrz__Cart__c = ccCart.id,ccrz__Quantity__c = 4,ccrz__Product__c = ccProduct4.Id,
                                                                  ccrz__Price__c = 501.00,ccrz__SubAmount__c = 501.00);
        insert ccCartItem4;
        
        ccrz__E_CartItem__c ccCartItem5 = new ccrz__E_CartItem__c(ccrz__Cart__c = ccCart.id,ccrz__Quantity__c = 4,ccrz__Product__c = ccProduct5.Id,
                                                                  ccrz__Price__c = 501.00,ccrz__SubAmount__c = 501.00);
        insert ccCartItem5;
        
        ccrz__E_CartItem__c ccCartItem6 = new ccrz__E_CartItem__c(ccrz__Cart__c = ccCart.id,ccrz__Quantity__c = 4,ccrz__Product__c = ccProduct6.Id,
                                                                  ccrz__Price__c = 501.00,ccrz__SubAmount__c = 501.00);
        insert ccCartItem6;
        
        
        Test.startTest();
        CC_ERG_ExtendShippingOptions aa= new CC_ERG_ExtendShippingOptions();
        List<ccrz.cc_ctrl_hlpr_ShippingOption> getShippingOptions= aa.getShippingOptions('', '', '', ccCart.Id, 'DefaultStore');
        List<ccrz.cc_ctrl_hlpr_ShippingOption> getShippingOptions1= aa.getShippingOptions('', 'AK', '', ccCart.Id, 'DefaultStore');
        Test.stopTest();
    }
}