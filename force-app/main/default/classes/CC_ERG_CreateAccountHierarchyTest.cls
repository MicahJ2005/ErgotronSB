@isTest
public class CC_ERG_CreateAccountHierarchyTest {
    
    public static Map<String, Object> testData;
    public static void setupTestData(Boolean createParentAccount, String name) {
        SmartyStreets_API__c ss = new SmartyStreets_API__c();
        ss.Name = name;
        ss.auth_id__c = 'adsmfqmwepm09daasd';
        ss.auth_token__c = '23240kfir8fj8f8';
        insert ss;           
        ccrz__E_Configuration__c theConfig = new ccrz__E_Configuration__c();
        testData = CC_ERG_TestData.setupAccountContactUser(createParentAccount,true);
    }
    
    @isTest
    static void checkCCOrderBillToShipToTest() {
        setupTestData(true, 'SeedUnitAddressVerify');
        
        ccrz__E_ContactAddr__c contactAddress = new ccrz__E_ContactAddr__c();
        contactAddress.ccrz__CompanyName__c = 'Test Account';
        contactAddress.ccrz__AddressFirstline__c = 'Address line one';
        contactAddress.ccrz__AddressSecondline__c ='Address line one1';
        contactAddress.ccrz__AddressThirdline__c ='Address line one2';
        contactAddress.ccrz__City__c = 'Metropolis';
        contactAddress.ccrz__State__c = 'Georgia';
        contactAddress.ccrz__StateISOCode__c='GA';
        contactAddress.ccrz__Country__c = 'United States';
        contactAddress.ccrz__CountryISOCode__c='US';
        contactAddress.ccrz__PostalCode__c = '78666';
        contactAddress.ccrz__FirstName__c = 'Test';
        contactAddress.ccrz__LastName__c = 'Singh';
        contactAddress.ccrz__Partner_Id__c = '123456-543210';
        insert contactAddress;
        
        ccrz__E_Cart__c ccCartObj = new ccrz__E_Cart__c();
        ccCartObj.ccrz__CartStatus__c = 'Open';
        ccCartObj.ccrz__ActiveCart__c = True;
        ccCartObj.ccrz__BuyerCompanyName__c = 'TestCompany';
        ccCartObj.cc_FreightCarrierActNbr__c= 'FCA234234';
        ccCartObj.ccrz__ShipTo__c = contactAddress.Id;
        Insert ccCartObj;
        
        
        
        ccrz__E_ContactAddr__c contactAddress1 = new ccrz__E_ContactAddr__c();
        contactAddress1.ccrz__CompanyName__c = 'Test Account1';
        contactAddress1.ccrz__AddressFirstline__c = 'Address line one';
        contactAddress1.ccrz__AddressSecondline__c ='Address line one1';
        contactAddress1.ccrz__AddressThirdline__c ='Address line one2';
        contactAddress1.ccrz__City__c = 'Metropolis';
        contactAddress1.ccrz__State__c = 'Georgia';
        contactAddress1.ccrz__StateISOCode__c='GA';
        contactAddress1.ccrz__Country__c = 'United States';
        contactAddress1.ccrz__CountryISOCode__c='US';
        contactAddress1.ccrz__PostalCode__c = '78667';
        contactAddress1.ccrz__FirstName__c = 'Test1';
        contactAddress1.ccrz__LastName__c = 'Singh1';
        contactAddress1.ccrz__Partner_Id__c = '123456-543210';
        insert contactAddress1;
        
        Case caseObj = new case();
        caseObj.Subject='Test Case';
        caseObj.Status ='New';
        caseObj.Origin ='Phone';
        caseObj.CC_CartId__c = ccCartObj.id;
        insert caseObj;
        
        ccrz__E_Order__c  ccOrderObj = new ccrz__E_Order__c();
        ccOrderObj.ccrz__OriginatedCart__c = ccCartObj.id;
        ccOrderObj.ccrz__OrderStatus__c = 'Open';
        ccOrderObj.ccrz__BillTo__c = contactAddress.Id;
        ccOrderObj.ccrz__ShipTo__c = contactAddress1.Id;
        ccOrderObj.ccrz__BuyerLastName__c = 'Test';
        ccOrderObj.ccrz__BuyerFirstName__c = 'Singh';
        insert ccOrderObj;
        
        ccrz__E_Product__c ccProductObj = new ccrz__E_Product__c();
        ccProductObj.Name = 'Test Prod';
        ccProductObj.ccrz__StartDate__c = Date.Today();
        ccProductObj.ccrz__EndDate__c = Date.today().addDays(10);
        ccProductObj.ccrz__SKU__c ='35-341-200';
        ccProductObj.ccrz__ProductStatus__c ='Released';
        ccProductObj.ccrz__Quantityperunit__c =1.000000;
        insert ccProductObj;
        
        
        ccrz__E_OrderItem__c  ccOrderItemObj = new ccrz__E_OrderItem__c();
        ccOrderItemObj.ccrz__Order__c = ccOrderObj.Id;
        ccOrderItemObj.ccrz__Quantity__c = 4;
        ccOrderItemObj.ccrz__Product__c = ccProductObj.Id;
        ccOrderItemObj.ccrz__Price__c = 501.00;
        ccOrderItemObj.ccrz__SubAmount__c = 501.00;
        insert ccOrderItemObj; 
        List<string> eventData= new List<string>();
        string ccOrder= JSON.serialize(ccOrderObj);
        eventData.add(ccOrder);
        Test.startTest();
        CC_ERG_CreateAccountHierarchy.checkCCOrderBillToShipTo(eventData);
     
        Test.stopTest();
    }
       @isTest
    static void checkCCOrderBillToShipToTest1() {
        setupTestData(true, 'SeedUnitAddressVerify');
        
        ccrz__E_ContactAddr__c contactAddress = new ccrz__E_ContactAddr__c();
        contactAddress.ccrz__CompanyName__c = 'Test Account';
        contactAddress.ccrz__AddressFirstline__c = 'Address line one';
        contactAddress.ccrz__AddressSecondline__c ='Address line one1';
        contactAddress.ccrz__AddressThirdline__c ='Address line one2';
        contactAddress.ccrz__City__c = 'Metropolis';
        contactAddress.ccrz__State__c = 'Georgia';
        contactAddress.ccrz__StateISOCode__c='GA';
        contactAddress.ccrz__Country__c = 'United States';
        contactAddress.ccrz__CountryISOCode__c='US';
        contactAddress.ccrz__PostalCode__c = '78666';
        contactAddress.ccrz__FirstName__c = 'Test';
        contactAddress.ccrz__LastName__c = 'Singh';
        contactAddress.ccrz__Partner_Id__c = '123456-543210';
        insert contactAddress;


        ccrz__E_Cart__c ccCartObj = new ccrz__E_Cart__c();
        ccCartObj.ccrz__CartStatus__c = 'Open';
        ccCartObj.ccrz__ActiveCart__c = True;
        ccCartObj.ccrz__BuyerCompanyName__c = 'TestCompany';
        ccCartObj.cc_FreightCarrierActNbr__c= 'FCA234234';
        ccCartObj.ccrz__ShipTo__c = contactAddress.Id;
        Insert ccCartObj;
        
        
        ccrz__E_ContactAddr__c contactAddress1 = new ccrz__E_ContactAddr__c();
        contactAddress1.ccrz__CompanyName__c = 'Test Account';
        contactAddress1.ccrz__AddressFirstline__c = 'Address line one';
        contactAddress1.ccrz__AddressSecondline__c ='Address line one1';
        contactAddress1.ccrz__AddressThirdline__c ='Address line one2';
        contactAddress1.ccrz__City__c = 'Metropolis';
        contactAddress1.ccrz__State__c = 'Georgia';
        contactAddress1.ccrz__StateISOCode__c='GA';
        contactAddress1.ccrz__Country__c = 'United States';
        contactAddress1.ccrz__CountryISOCode__c='US';
        contactAddress1.ccrz__PostalCode__c = '78666';
        contactAddress1.ccrz__FirstName__c = 'Test';
        contactAddress1.ccrz__LastName__c = 'Singh';
        contactAddress1.ccrz__Partner_Id__c = '123456-543210';
        insert contactAddress1;
        
        Case caseObj = new case();
        caseObj.Subject='Test Case';
        caseObj.Status ='New';
        caseObj.Origin ='Phone';
        caseObj.CC_CartId__c = ccCartObj.id;
        insert caseObj;
        
        ccrz__E_Order__c  ccOrderObj = new ccrz__E_Order__c();
        ccOrderObj.ccrz__OriginatedCart__c = ccCartObj.id;
        ccOrderObj.ccrz__OrderStatus__c = 'Open';
        ccOrderObj.ccrz__BillTo__c = contactAddress.Id;
        ccOrderObj.ccrz__ShipTo__c = contactAddress1.Id;
        ccOrderObj.ccrz__BuyerLastName__c = 'Test';
        ccOrderObj.ccrz__BuyerFirstName__c = 'Singh';
        insert ccOrderObj;
        
        ccrz__E_Product__c ccProductObj = new ccrz__E_Product__c();
        ccProductObj.Name = 'Test Prod';
        ccProductObj.ccrz__StartDate__c = Date.Today();
        ccProductObj.ccrz__EndDate__c = Date.today().addDays(10);
        ccProductObj.ccrz__SKU__c ='35-341-200';
        ccProductObj.ccrz__ProductStatus__c ='Released';
        ccProductObj.ccrz__Quantityperunit__c =1.000000;
        insert ccProductObj;
        
        
        ccrz__E_OrderItem__c  ccOrderItemObj = new ccrz__E_OrderItem__c();
        ccOrderItemObj.ccrz__Order__c = ccOrderObj.Id;
        ccOrderItemObj.ccrz__Quantity__c = 4;
        ccOrderItemObj.ccrz__Product__c = ccProductObj.Id;
        ccOrderItemObj.ccrz__Price__c = 501.00;
        ccOrderItemObj.ccrz__SubAmount__c = 501.00;
        insert ccOrderItemObj; 
        List<string> eventData= new List<string>();
        string ccOrder= JSON.serialize(ccOrderObj);
        eventData.add(ccOrder);
        Test.startTest();
        CC_ERG_CreateAccountHierarchy.checkCCOrderBillToShipTo(eventData);
      
        Test.stopTest();
    }
    @isTest
    static void updateOrderAccount_Test(){
        
        Account acct = new Account(Name = 'Test Account'); 
        insert acct;
        
        Contact cont = new Contact(FirstName = 'firstName', LastName ='lastContact', AccountId = acct.Id,Email = 'testdata@drtest.com');
        insert cont;
        
        
        ccrz__E_ContactAddr__c contactAddress = new ccrz__E_ContactAddr__c();
        contactAddress.ccrz__CompanyName__c = 'Test Account';
        contactAddress.ccrz__AddressFirstline__c = 'Address line one';
        contactAddress.ccrz__AddressSecondline__c = 'Address line one12';
        contactAddress.ccrz__City__c = 'Metropolis';
        contactAddress.ccrz__State__c = 'Georgia';
        contactAddress.ccrz__StateISOCode__c='GA';
        contactAddress.ccrz__Country__c = 'United States';
        contactAddress.ccrz__CountryISOCode__c='US';
        contactAddress.ccrz__PostalCode__c = '78666';
        contactAddress.ccrz__FirstName__c = 'Test';
        contactAddress.ccrz__LastName__c = 'Singh';
        contactAddress.ccrz__Partner_Id__c = '123456-543210';
        insert contactAddress;

        ccrz__E_Cart__c ccCartObj = new ccrz__E_Cart__c();
        ccCartObj.ccrz__CartStatus__c = 'Open';
        ccCartObj.ccrz__ActiveCart__c = True;
        ccCartObj.ccrz__BuyerCompanyName__c = 'TestCompany';
        ccCartObj.cc_FreightCarrierActNbr__c= 'FCA234234';
        ccCartObj.ccrz__ShipTo__c = contactAddress.Id;
        Insert ccCartObj;
        
        ccrz__E_ContactAddr__c contactAddress1 = new ccrz__E_ContactAddr__c();
        contactAddress1.ccrz__CompanyName__c = 'Test Account1';
        contactAddress1.ccrz__AddressFirstline__c = 'Address line one1';
        contactAddress1.ccrz__AddressSecondline__c = 'Address line one21';
        contactAddress1.ccrz__City__c = 'Metropolis';
        contactAddress1.ccrz__State__c = 'Georgia';
        contactAddress1.ccrz__StateISOCode__c='GA';
        contactAddress1.ccrz__Country__c = 'United States';
        contactAddress1.ccrz__CountryISOCode__c='US';
        contactAddress1.ccrz__PostalCode__c = '78667';
        contactAddress1.ccrz__FirstName__c = 'Test1';
        contactAddress1.ccrz__LastName__c = 'Singh1';
        contactAddress1.ccrz__Partner_Id__c = '123456-543210';
        insert contactAddress1;
        
        ccrz__E_Order__c  ccOrderObj = new ccrz__E_Order__c();
        ccOrderObj.ccrz__OriginatedCart__c = ccCartObj.id;
        ccOrderObj.ccrz__OrderStatus__c = 'Open';
        ccOrderObj.ccrz__BillTo__c = contactAddress.Id;
        ccOrderObj.ccrz__ShipTo__c = contactAddress.Id;
        ccOrderObj.ccrz__BuyerLastName__c = 'Test';
        ccOrderObj.ccrz__BuyerFirstName__c = 'Singh';
        insert ccOrderObj;
        
        ccrz__E_Order__c order = [select ccrz__OriginatedCart__c,ccrz__OrderStatus__c,ccrz__BillTo__c,ccrz__ShipTo__c,ccrz__BuyerLastName__c,ccrz__BuyerFirstName__c from ccrz__E_Order__c where id =:ccOrderObj.id];
        
        
        CC_ERG_CreateAccountHierarchy.updateOrderAccount(order, acct.id, cont.id);
        ccrz__E_Order__c updatedOrder = [select ccrz__Contact__c,ccrz__Account__c from ccrz__E_Order__c where id =:ccOrderObj.id ];
        System.assertEquals(cont.id,updatedOrder.ccrz__Contact__c);
        System.assertEquals(acct.id,updatedOrder.ccrz__Account__c);
    }
    
    @isTest
    static void createAccounts_Test(){
        setupTestData(true, 'SeedUnitAddressVerify');
        
        Account partyAcc = new Account(Name = 'Parent Account'); 
        insert partyAcc;
        
        Account acct = new Account(Name = 'Test Account'); 
        insert acct;
        
        Contact cont = new Contact(FirstName = 'firstName', LastName ='lastContact', AccountId = acct.Id,Email = 'testdata@drtest.com');
        insert cont;
        
        acct.ParentId = partyAcc.Id;
        update acct;
        
        
        ccrz__E_ContactAddr__c contactAddress = new ccrz__E_ContactAddr__c();
        contactAddress.ccrz__CompanyName__c = 'Test Account';
        contactAddress.ccrz__AddressFirstline__c = 'Address line one';
        contactAddress.ccrz__City__c = 'Metropolis';
        contactAddress.ccrz__State__c = 'Georgia';
        contactAddress.ccrz__StateISOCode__c='GA';
        contactAddress.ccrz__Country__c = 'United States';
        contactAddress.ccrz__CountryISOCode__c='US';
        contactAddress.ccrz__PostalCode__c = '78666';
        contactAddress.ccrz__FirstName__c = 'Test';
        contactAddress.ccrz__LastName__c = 'Singh';
        contactAddress.ccrz__Partner_Id__c = '123456-543210';
        insert contactAddress;

        ccrz__E_Cart__c ccCartObj = new ccrz__E_Cart__c();
        ccCartObj.ccrz__CartStatus__c = 'Open';
        ccCartObj.ccrz__ActiveCart__c = True;
        ccCartObj.ccrz__BuyerCompanyName__c = 'TestCompany';
        ccCartObj.cc_FreightCarrierActNbr__c= 'FCA234234';
        ccCartObj.ccrz__ShipTo__c = contactAddress.Id;
        Insert ccCartObj;
        
        ccrz__E_ContactAddr__c contactAddress1 = new ccrz__E_ContactAddr__c();
        contactAddress1.ccrz__CompanyName__c = 'Test Account';
        contactAddress1.ccrz__AddressFirstline__c = 'Address line one';
        contactAddress1.ccrz__City__c = 'Metropolis';
        contactAddress1.ccrz__State__c = 'Georgia';
        contactAddress1.ccrz__StateISOCode__c='GA';
        contactAddress1.ccrz__Country__c = 'United States';
        contactAddress1.ccrz__CountryISOCode__c='US';
        contactAddress1.ccrz__PostalCode__c = '78666';
        contactAddress1.ccrz__FirstName__c = 'Test';
        contactAddress1.ccrz__LastName__c = 'Singh';
        contactAddress1.ccrz__Partner_Id__c = '123456-543210';
        insert contactAddress1;
        
        ccrz__E_Order__c  ccOrderObj = new ccrz__E_Order__c();
        ccOrderObj.ccrz__OriginatedCart__c = ccCartObj.id;
        ccOrderObj.ccrz__OrderStatus__c = 'Open';
        ccOrderObj.ccrz__BuyerLastName__c = 'Test';
        ccOrderObj.ccrz__BuyerFirstName__c = 'Singh';
        insert ccOrderObj;
        ccrz.cc_CallContext.isGuest = true;

        ccrz__E_Order__c order = [select ccrz__OriginatedCart__c,ccrz__OrderStatus__c,ccrz__BuyerLastName__c,ccrz__BuyerFirstName__c from ccrz__E_Order__c where id =:ccOrderObj.id];       
        String accountId = CC_ERG_CreateAccountHierarchy.createAccounts(acct.id, order);
        System.assertNotEquals(null, accountId);
    }
    
}