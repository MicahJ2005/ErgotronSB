/*
	Test class for Lead_Product_Override.cls.

	MOD DATE		Who						Description
	1/29/2015		Chris Noe				Initial Release
*/

//@isTest(seeAllData=true)
@isTest
private class Lead_Product_Override_Test {
	static testmethod void testViewRedirect() {
    	//Create lead for test
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
    	oLead.Expiration_Date__c = Date.today()+120;
        oLead.Expected_Ship_Date__c = Date.today()+30;
    	oLead.Date_Approved__c = Date.today();
    	oLead.Rebate__c = String.valueOf(math.random()).left(20);
    	oLead.Status='Registration Approved - Priced';
    	oLead.Registration_Approval_Status__c='PM Approved - Priced';
    	oLead.Phone='8888888888';
    	oLead.Email= String.valueOf(math.random()).left(20) + '@test.com';
    	oLead.Total_Quantity__c=100;

    	insert oLead;

        // Switching from SeeAllData to building Products; Product Table is too large
        Product2 soProduct = new Product2(
            Name = 'Test Product',
            ProductCode = 'ABC123',
            IsActive = true,
            Item_Type__c = 'E-FG',
            Inventory_Item_Status_Code__c = 'MASTER',
            MSRP_US_STANDARD_USD__c = 100,
            Costing_Inventory__c = 'F'
        ); insert soProduct;

        Id soStdPricebook = Test.getStandardPricebookId();

        PricebookEntry soStdPBE = new PricebookEntry(
            Pricebook2Id = soStdPricebook,
            Product2Id = soProduct.Id,
            UnitPrice = 100,
            IsActive = true
        ); insert soStdPBE;

        Pricebook2 soUSPricelist = new Pricebook2(
            Name='US STANDARD PRICE LIST',
            IsActive = true
        ); insert soUSPricelist;

        PricebookEntry soUSPBPBE = new PricebookEntry(
            Pricebook2Id = soUSPricelist.Id,
            Product2Id = soProduct.Id,
            UnitPrice = 100,
            IsActive = true
        ); insert soUSPBPBE;

        //Retrieve web service details from custom setting
        //Create web service details record record by lead assignment callout
        Test_Environment_Utility.createInsertWebServiceDetails('Territory Lookup');

    	//Find a product that is active in the US STANDARD PRICE LIST
    	//Id idProductId = [select Product2Id from PricebookEntry where Pricebook2.Name='US STANDARD PRICE LIST' and IsActive=true and Product2.IsActive=true and Product2.Item_Type__c='E-FG' and
    	//					Product2.Inventory_Item_Status_Code__c='MASTER' and Product2.MSRP_US_STANDARD_USD__c>0 and Product2.Costing_Inventory__c='F' limit 1].Product2Id;

    	//Create Lead_Product__c record
    	//Lead_Product__c oLeadProduct = new Lead_Product__c(Product__c=idProductId, Quantity__c=100, Lead__c=oLead.Id);
        Lead_Product__c oLeadProduct = new Lead_Product__c(Name='TestLP', Product__c=soProduct.Id, Quantity__c=100, Lead__c=oLead.Id);
    	insert oLeadProduct;

		Test.startTest();
			PageReference oPageRef = Page.overrideLeadProductView;
			Test.setCurrentPage(oPageRef);

			ApexPages.StandardController oStdController = new ApexPages.StandardController(oLeadProduct);
			oPageRef.getParameters().put('id',String.valueOf(oLeadProduct.Id));
			Lead_Product_Override oExtController = new Lead_Product_Override(oStdController);
			
			PageReference oReturnPageRef = oExtController.RedirectLead();
			
			system.assertEquals('/' + oLead.Id, oReturnPageRef.getUrl());	
		Test.stopTest();
	}
}