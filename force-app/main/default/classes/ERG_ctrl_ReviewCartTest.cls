/**
 * @description       : 
 * @author            : Rajesh Kumar
 * @group             : 
 * @last modified on  : 09-11-2020
 * @last modified by  : Rajesh Kumar
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   09-11-2020   Rajesh Kumar   Initial Version
**/
@isTest
public with sharing class ERG_ctrl_ReviewCartTest {
	/*
	 * Salesforce 2020
	 *  Author: gvansteeter
	 *    Date: 2020.05.12
	 * Purpose: Test class to cover functionality of the ERG_ctrl_ReviewCart controller class.
	 */    
    public static Map<String, Object> testData;

    public static void setupTestData(Boolean createParentAccount) {
		
		SmartyStreets_API__c ss = new SmartyStreets_API__c();
            ss.Name = 'SeedUnitAddressVerify';
            ss.auth_id__c = 'adsmfqmwepm09daasd';
            ss.auth_token__c = '23240kfir8fj8f8';
        insert ss;           
        
        ccrz__E_Configuration__c theConfig = new ccrz__E_Configuration__c(
        	
        );
        testData = ERG_Test_DataFactory.setupAccountContactUser(createParentAccount,true);

    }// end of generate test data  

	@isTest
	public static void storeMember(){
		setupTestData(true);
        
		CC_ERG_ctrl_ReviewCart controller = new CC_ERG_ctrl_ReviewCart();
        
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = (String) testData.get(ERG_Test_DataFactory.TEST_STOREFRONT);
        ctx.portalUserId = ((User) testData.get(ERG_Test_DataFactory.TEST_CHILD_ACC_USER)).Id;
        ctx.effAccountId = ((Account) testData.get(ERG_Test_DataFactory.TEST_CHILD_ACCOUNT)).Id;
        ccrz.cc_CallContext.init(ctx);  
            
        //2020.10.25 gvansteeter debug code...get contact for user.
        User refetchUser = [SELECT Id, ContactId FROM User WHERE Id = :ctx.portalUserId];
        Contact refetchContact = [SELECT Id, Store_Member__c FROM Contact WHERE Id = :refetchUser.ContactId];
        
        if(!refetchContact.Store_Member__c){
            refetchContact.Store_Member__c = true;
            update refetchContact;
        }
/*        
		// 2020.10.25 gvansteeter: update configuration to use the DRO user ID.
		User DroUser = [SELECT Id FROM User WHERE lastName = 'B2B Storefront' AND firstName = 'Owner'];
        ccrz__E_Configuration__c DroConfig = [SELECT Id, ccrz__TextValue__c FROM ccrz__E_Configuration__c WHERE ccrz__ConfigurationMeta__r.Name = 'Default Record Owner' AND ccrz__Storefront__c = :ERG_Test_DataFactory.TEST_STOREFRONT];
        DroConfig.ccrz__TextValue__c = DroUser.Id;
        update DroConfig;
		// 2020.10.25 end for guest user checkout enablement        
*/        
        String currCartENCID;
        Map<String, Object> addToCartResult = ccrz.ccApiCart.addTo(new Map<String, Object>{
                ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                ccrz.ccApiCart.LINE_DATA => new List<Map<String, Object>>{
                        new Map<String, Object>{
                                ccrz.ccApiCart.LINE_DATA_SKU => ERG_Test_DataFactory.TEST_SKU + 1,
                                ccrz.ccApiCart.LINE_DATA_QUANTITY => 3
                        }
                }
        });

        currCartENCID = (String) addToCartResult.get(ccrz.ccApiCart.CART_ENCID);
        ccrz.cc_CallContext.currCartId = currCartENCID;
        ctx.currentCartId = currCartENCID;
        //2020.10.25 gvansteeter - add billing/shipping addresses to cart
        Map<String, Object> billingAddress = new Map<String, Object> ();
        Map<String, Object> shippingAddress = new Map<String, Object> ();
        
        billingAddress.put(ERG_Test_DataFactory.ADDRESS_FIRSTLINE, ERG_Test_DataFactory.PARENT_BILL_STREET);
        billingAddress.put(ERG_Test_DataFactory.CITY, ERG_Test_DataFactory.PARENT_BILL_CITY);
        billingAddress.put(ERG_Test_DataFactory.STATE, ERG_Test_DataFactory.PARENT_BILL_STATE);
        billingAddress.put(ERG_Test_DataFactory.COUNTRY, ERG_Test_DataFactory.PARENT_BILL_COUNTRY);
        billingAddress.put(ERG_Test_DataFactory.POSTAL_CODE, ERG_Test_DataFactory.PARENT_BILL_POSTAL_CODE);
        
        shippingAddress.put(ERG_Test_DataFactory.ADDRESS_FIRSTLINE, ERG_Test_DataFactory.CHILD_SHIP_STREET);
        shippingAddress.put(ERG_Test_DataFactory.CITY, ERG_Test_DataFactory.CHILD_SHIP_CITY);
        shippingAddress.put(ERG_Test_DataFactory.STATE, ERG_Test_DataFactory.CHILD_SHIP_STATE);
        shippingAddress.put(ERG_Test_DataFactory.COUNTRY, ERG_Test_DataFactory.CHILD_SHIP_COUNTRY);
        shippingAddress.put(ERG_Test_DataFactory.POSTAL_CODE, ERG_Test_DataFactory.CHILD_SHIP_POSTAL_CODE);

        String billingAddressSFID = ERG_Test_DataFactory.insertContactAddress(billingAddress);
        String shippingAddressSFID = ERG_Test_DataFactory.insertContactAddress(shippingAddress);        
             
        ccrz__E_Cart__c currCart = [SELECT Id, Ergotron_Order_Type__c, pricelistOverride__c, ccrz__BillTo__c, ccrz__ShipTo__c FROM ccrz__E_Cart__c WHERE ccrz__EncryptedId__c = :currCartENCID LIMIT 1];        
        
        currCart.ccrz__BillTo__c = billingAddressSFID;
        currCart.ccrz__ShipTo__c = shippingAddressSFID;
        
        update currCart;
        
        ccrz.cc_RemoteActionResult myRAR;      
        
        String strResponse = controller.getJumpToServer();
        controller.setdfltPONumber('PO-0000000001');
        strResponse = controller.getdfltPONumber();
        controller.setFreightCarrierActNbr('FEDEX-00001-001');
        strResponse = controller.getFreightCarrierActNbr();
        
        Case theCase = [SELECT Id, CC_CartId__c FROM Case LIMIT 1]; // there should only be one case
        theCase.CC_CartId__c = currCart.Id;
        update theCase;

        //myRAR = ERG_ctrl_ReviewCart.sendOrderToCustomer(ctx);
        
        String searchString = ((Account) testData.get(ERG_Test_DataFactory.TEST_PARENT_ACCOUNT)).Name;
        myRAR = ERG_ctrl_ReviewCart.updatesAccountList(ctx, 'BillTo', searchString);
        myRAR = ERG_ctrl_ReviewCart.updatesAccountList(ctx, 'ShipTo', searchString);//2020.10.25 gvansteeter changed from "BillTo" to "ShipTo"
/*
        System.debug('GLENDEBUG(2): currCart: Id='+currCart.Id+'; Ergotron_Order_Type__c='+currCart.Ergotron_Order_Type__c
                     +'; pricelistOverride__c='+currCart.pricelistOverride__c+': ccrz__BillTo__c='+currCart.ccrz__BillTo__c
                     +'; ccrz__ShipTo__c='+currCart.ccrz__ShipTo__c+'; searchString='+searchString);
*/        
        
        myRAR = ERG_ctrl_ReviewCart.sendOrderToCustomer(ctx);//2020.10.25 gvansteeter moved here AFTER addresses have been modified.
        ctx.currentCartId = currCartENCID;
        ERG_ctrl_ReviewCart.setSelectedContact(ctx);
        ERG_ctrl_ReviewCart.populateManualAddressList(ctx,'');
        ERG_ctrl_ReviewCart.saveContactId(ctx,'');
                
	}// storeMember
    
	@isTest
	public static void nonStoreMember(){
		setupTestData(true);
		// create a cart
		/*
		ccrz__E_Cart__c theCart = ERG_Test_DataFactory.createCart(true, true, testData);
		ccrz.cc_CallContext.currCartId = theCart.ccrz__EncryptedId__c;
        */

        
		ERG_ctrl_ReviewCart controller = new ERG_ctrl_ReviewCart();
        
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = (String) testData.get(ERG_Test_DataFactory.TEST_STOREFRONT);
        ctx.portalUserId = ((User) testData.get(ERG_Test_DataFactory.TEST_CHILD_ACC_USER)).Id;
        ctx.effAccountId = ((Account) testData.get(ERG_Test_DataFactory.TEST_CHILD_ACCOUNT)).Id;
        ccrz.cc_CallContext.init(ctx);   

        //2020.10.25 gvansteeter debug code...get contact for user.
        User refetchUser = [SELECT Id, ContactId FROM User WHERE Id = :ctx.portalUserId];
        Contact refetchContact = [SELECT Id, Store_Member__c FROM Contact WHERE Id = :refetchUser.ContactId];
        
        if(refetchContact.Store_Member__c){
            refetchContact.Store_Member__c = false;
            update refetchContact;
        }

        
        String currCartENCID;
        Map<String, Object> addToCartResult = ccrz.ccApiCart.addTo(new Map<String, Object>{
                ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                ccrz.ccApiCart.LINE_DATA => new List<Map<String, Object>>{
                        new Map<String, Object>{
                                ccrz.ccApiCart.LINE_DATA_SKU => ERG_Test_DataFactory.TEST_SKU + 1,
                                ccrz.ccApiCart.LINE_DATA_QUANTITY => 3
                        }
                }
        });

        currCartENCID = (String) addToCartResult.get(ccrz.ccApiCart.CART_ENCID);
        ccrz.cc_CallContext.currCartId = currCartENCID;
        ctx.currentCartId = currCartENCID;
        //2020.10.25 gvansteeter - add billing/shipping addresses to cart
        Map<String, Object> billingAddress = new Map<String, Object> ();
        Map<String, Object> shippingAddress = new Map<String, Object> ();
        
        billingAddress.put(ERG_Test_DataFactory.ADDRESS_FIRSTLINE, ERG_Test_DataFactory.PARENT_BILL_STREET);
        billingAddress.put(ERG_Test_DataFactory.CITY, ERG_Test_DataFactory.PARENT_BILL_CITY);
        billingAddress.put(ERG_Test_DataFactory.STATE, ERG_Test_DataFactory.PARENT_BILL_STATE);
        billingAddress.put(ERG_Test_DataFactory.COUNTRY, ERG_Test_DataFactory.PARENT_BILL_COUNTRY);
        billingAddress.put(ERG_Test_DataFactory.POSTAL_CODE, ERG_Test_DataFactory.PARENT_BILL_POSTAL_CODE);
        
        shippingAddress.put(ERG_Test_DataFactory.ADDRESS_FIRSTLINE, ERG_Test_DataFactory.CHILD_SHIP_STREET);
        shippingAddress.put(ERG_Test_DataFactory.CITY, ERG_Test_DataFactory.CHILD_SHIP_CITY);
        shippingAddress.put(ERG_Test_DataFactory.STATE, ERG_Test_DataFactory.CHILD_SHIP_STATE);
        shippingAddress.put(ERG_Test_DataFactory.COUNTRY, ERG_Test_DataFactory.CHILD_SHIP_COUNTRY);
        shippingAddress.put(ERG_Test_DataFactory.POSTAL_CODE, ERG_Test_DataFactory.CHILD_SHIP_POSTAL_CODE);

        String billingAddressSFID = ERG_Test_DataFactory.insertContactAddress(billingAddress);
        String shippingAddressSFID = ERG_Test_DataFactory.insertContactAddress(shippingAddress);        
             
        ccrz__E_Cart__c currCart = [SELECT Id, Ergotron_Order_Type__c, pricelistOverride__c, ccrz__BillTo__c, ccrz__ShipTo__c FROM ccrz__E_Cart__c WHERE ccrz__EncryptedId__c = :currCartENCID LIMIT 1];        
        
        currCart.ccrz__BillTo__c = billingAddressSFID;
        currCart.ccrz__ShipTo__c = shippingAddressSFID;
        
        update currCart;
        
        ccrz.cc_RemoteActionResult myRAR;      
        
        String strResponse = controller.getJumpToServer();
        controller.setdfltPONumber('PO-0000000001');
        strResponse = controller.getdfltPONumber();
        controller.setFreightCarrierActNbr('FEDEX-00001-001');
        strResponse = controller.getFreightCarrierActNbr();
        
        Case theCase = [SELECT Id, CC_CartId__c FROM Case LIMIT 1]; // there should only be one case
        theCase.CC_CartId__c = currCart.Id;
        update theCase;

        //myRAR = ERG_ctrl_ReviewCart.sendOrderToCustomer(ctx);
        
        String searchString = ((Account) testData.get(ERG_Test_DataFactory.TEST_PARENT_ACCOUNT)).Name;
        myRAR = ERG_ctrl_ReviewCart.updatesAccountList(ctx, 'BillTo', searchString);
        myRAR = ERG_ctrl_ReviewCart.updatesAccountList(ctx, 'ShipTo', searchString);//2020.10.25 gvansteeter changed from "BillTo" to "ShipTo"

        myRAR = ERG_ctrl_ReviewCart.sendOrderToCustomer(ctx);//2020.10.25 gvansteeter moved here AFTER addresses have been modified.
        ctx.currentCartId = currCartENCID;
        ERG_ctrl_ReviewCart.setSelectedContact(ctx);
        ERG_ctrl_ReviewCart.populateManualAddressList(ctx,'');
        ERG_ctrl_ReviewCart.saveContactId(ctx,'');
        
	}// nonStoreMember    
    
	
}// end class