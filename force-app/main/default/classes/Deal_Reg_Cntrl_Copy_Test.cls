@isTest
private class Deal_Reg_Cntrl_Copy_Test {
    
    static testmethod void testGetPartners(){
        Test.startTest();
        Map<String,String> m = Deal_Reg_Cntrl_Copy.getPartners();
        Test.stopTest();
        System.assertEquals(false, m.values().isEmpty());
    }
    
    static testmethod void testGetUserCountry(){
        Test.startTest();
        String country = Deal_Reg_Cntrl_Copy.getUserCountry();
        System.assertNotEquals(null, country);
        Test.stopTest();
    }
    static testmethod void testGetProductsByLead(){
        //Create web service details record record by lead assignment callout
		Web_Service_Details__c oWebService = Test_Environment_Utility.createInsertWebServiceDetails('Territory Lookup');
        
        Id productId = createProduct();
        
        Lead l = new Lead(
            Firstname='Test',
            Lastname='Test',
        	Street='Test',
        	State='Minnesota',
        	City='Eden Prairie',
        	Country='United States',
        	PostalCode='55344',
        	Expected_Ship_Date__c=Date.today(),
			Description='TEST DESCRIPTION',
			Ergotron_Vertical_Market__c='Enterprise'
        );
        insert l;
        
        List<Lead_Product__c> products = new List<Lead_Product__c>();
        products.add(
            new Lead_Product__c(
        		Product__c = productId,
            	Quantity__c = 1,
                Lead__c = l.Id
        	)
        );
        insert products;
        
        Test.startTest();
        List<Lead_Product__c> result = Deal_Reg_Cntrl_Copy.getProducts(l.Id);
        Test.stopTest();
        System.assertEquals(1,result.size());
    }
    
    
        
    static testmethod void testUpdateLead(){
        //Create web service details record record by lead assignment callout
		Web_Service_Details__c oWebService = Test_Environment_Utility.createInsertWebServiceDetails('Territory Lookup');
        
        Id productId = createProduct();
        
        Lead l = new Lead(
            Firstname='Test',
            Lastname='Test',
        	Street='Test',
        	State='Minnesota',
        	City='Eden Prairie',
        	Country='United States',
        	PostalCode='55344',
        	Expected_Ship_Date__c=Date.today(),
			Description='TEST DESCRIPTION',
			Ergotron_Vertical_Market__c='Enterprise'
        );
        insert l;
        
        List<Lead_Product__c> products = new List<Lead_Product__c>();
        products.add(
            new Lead_Product__c(
        		Product__c = productId,
            	Quantity__c = 1
        	)
        );
        
        Test.startTest();
        Deal_Reg_Cntrl_Copy.updateLead(l,products);
        Lead result = Deal_Reg_Cntrl_Copy.getLead(l.Id);
        Test.stopTest();
        System.assertNotEquals(null,result);
    }
    
    static testmethod void testGetProductsById(){
        Id productId = createProduct();
    	Test.startTest();
        List<Product2> products = Deal_Reg_Cntrl_Copy.getProductsById(new List<Id>{ productId });
        Test.stopTest();
        System.assertEquals(1,products.size(),'Should have had 1 product returned, but did not.');
    }
    
    static testmethod void testSaveAndSubmit(){
        //Create web service details record record by lead assignment callout
		Web_Service_Details__c oWebService = Test_Environment_Utility.createInsertWebServiceDetails('Territory Lookup');
        
        Id productId = createProduct();
        
        Lead l = new Lead(
            Firstname='Test',
            Lastname='Test',
        	Street='Test',
        	State='Minnesota',
        	City='Eden Prairie',
        	Country='United States',
        	PostalCode='55344',
        	Expected_Ship_Date__c=Date.today(),
			Description='TEST DESCRIPTION',
			Ergotron_Vertical_Market__c='Enterprise'
        );
        
        List<Lead_Product__c> products = new List<Lead_Product__c>();
        products.add(
            new Lead_Product__c(
        		Product__c = productId,
            	Quantity__c = 1
        	)
        );
        
        Test.startTest();
        Deal_Reg_Cntrl_Copy.saveAndSubmit(l,products);
        Lead result = Deal_Reg_Cntrl_Copy.getLead(l.Id);
        Test.stopTest();
        System.assertNotEquals(null,result);
    }
    
    static testmethod void testSaveAndSubmitException(){
        //Create web service details record record by lead assignment callout
		Web_Service_Details__c oWebService = Test_Environment_Utility.createInsertWebServiceDetails('Territory Lookup');
        
        Id productId = createProduct();
        
        Lead l = new Lead(
            Firstname='Test',
            Lastname='Test',
        	Street='Test',
        	State='Minnesota',
        	City='Eden Prairie',
        	Country='United States',
        	PostalCode='55344',
        	Expected_Ship_Date__c=Date.today(),
			Description='TEST DESCRIPTION',
			Ergotron_Vertical_Market__c='Enterprise'
        );
        
        List<Lead_Product__c> products = new List<Lead_Product__c>();
        products.add(
            new Lead_Product__c(
        		Product__c = productId,
            	Quantity__c = null
        	)
        );
        
        Test.startTest();
        
        boolean result = false;
        try{
        	Deal_Reg_Cntrl_Copy.saveAndSubmit(l,products);
        }catch(Exception ex){
            result = true;
        }
        Test.stopTest();
        System.assert(result,'No exception thrown, when there should have been because of a null quantity lead product.');
    }
    
    static testmethod void testGetDealRegProducts(){
        createProduct();
        Test.startTest();
        List<Product2> products = Deal_Reg_Cntrl_Copy.getDealRegProducts();
        Test.stopTest();
        System.assertEquals(1,products.size());
    }
    
    private static Id createProduct(){
        //Create product for test
        Product2 p = new Product2(
            Name='TEST',
            ProductCode='TEST',
            Costing_Inventory__c='F',
            Item_Type__c='E-FG',
            Inventory_Item_Status_Code__c='MASTER',
            IsActive=true,
            MSRP_EMEA_APAC_USD__c=10,
            MSRP_EMEA_EUR__c=10,
            MSRP_EMEA_GBP__c=10,
            MSRP_US_STANDARD_USD__c=10
        );
        insert p;
        return p.Id;
    }
}