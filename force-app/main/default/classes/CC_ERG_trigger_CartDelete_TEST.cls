@isTest
Private class CC_ERG_trigger_CartDelete_TEST {
    
    @TestSetup
    private static void setupTestData() {
        ccrz__E_Cart__c cart = new ccrz__E_Cart__c();
        cart.ccrz__CartStatus__c = 'Open';
        cart.ccrz__ActiveCart__c = True;
        cart.ccrz__BuyerCompanyName__c = 'testCompany';
        Insert cart;
        
        ccrz__E_Cart__c cart2 = new ccrz__E_Cart__c();
        cart2.ccrz__CartStatus__c = 'Open';
        cart2.ccrz__ActiveCart__c = True;
        cart2.ccrz__BuyerCompanyName__c = 'noCaseCart';
        Insert cart2;
        
        
        ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c();
        cartItem.ccrz__Cart__c = cart.Id;
        cartItem.ccrz__Price__c = 10;
        Insert cartItem;
        
        case c = new case(CC_CartId__c = cart.id);
        insert c;
    }
    
    @isTest
    private static void deleteCart(){
        ccrz__E_Cart__c cart = [select id from ccrz__E_Cart__c where ccrz__BuyerCompanyName__c = 'testCompany' limit 1];
        case c = [select id, sub_status__c from case where CC_CartId__c = :cart.Id];
        delete cart;
        system.assertEquals('Pending Open Cart', c.sub_status__c, 'Sub_status was not cleared');
    }
    
    @isTest
    private static void deleteCartWOCase(){
        ccrz__E_Cart__c cart2 = [select id from ccrz__E_Cart__c where ccrz__BuyerCompanyName__c = 'noCaseCart' limit 1];
        delete cart2;
    }
}