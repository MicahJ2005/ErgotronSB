@isTest
global class CC_ERG_ValidateAddress_extTest {
	
    public static void setupTestData() {
        SmartyStreets_API__c ss = new SmartyStreets_API__c();
        ss.Name = 'SeedUnitAddressVerify ';
        ss.auth_id__c = 'adsmfqmwepm09daasd';
        ss.auth_token__c = '23240kfir8fj8f8';
        insert ss;  
        
        ccrz__E_Cart__c ccCartObj = new ccrz__E_Cart__c();
        ccCartObj.ccrz__CartStatus__c = 'Open';
        ccCartObj.ccrz__ActiveCart__c = True;
        ccCartObj.ccrz__BuyerCompanyName__c = 'TestCompany';
        ccCartObj.cc_FreightCarrierActNbr__c= 'FCA234234';
        Insert ccCartObj;
    }
    
    @isTest
    static void verifyAddressTest() {
        setupTestData();
        ccrz__E_Cart__c ccCartObj = [Select Id from ccrz__E_Cart__c];
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new verifyAddressSuccessMock());
            CalloutClass calloutClass = new CalloutClass();
             HttpResponse res = calloutClass.getInfoFromExternalService();
            CC_ERG_ValidateAddress_ext.verifyAddress('street','city','state','candidate','secondary','Country','10011',ccCartObj.Id);
            System.assertNotEquals('Test', '10'); 
        Test.stopTest();
    }
    
    @isTest
    static void verifyAddressFailedTest() { 
        setupTestData();
        ccrz__E_Cart__c ccCartObj = [Select Id from ccrz__E_Cart__c];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new verifyAddressFailedMock());
            CalloutClass calloutClass = new CalloutClass();
             HttpResponse res = calloutClass.getInfoFromExternalService();
            CC_ERG_ValidateAddress_ext.verifyAddress('street','city','state','candidate','secondary','Country','10011',ccCartObj.Id);
            System.assertNotEquals('Test', '10');
        Test.stopTest();
    }
    global class verifyAddressSuccessMock implements HttpCalloutMock {
        // Implement this interface method
        global HTTPResponse respond(HTTPRequest req) {
            String authId = 'adsmfqmwepm09daasd';
            String token = '23240kfir8fj8f8';
    
            String addString = 'https://us-street.api.smartystreets.com/street-address?auth-id='+authId+'&auth-token='+token
                +'&street=street&city=city&state=state&secondary=secondary&country=Country&zipcode=10011&candidates=candidate';
            System.assertEquals('GET', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"example":"test"}]');
            res.setStatusCode(200);
            return res;
        }
    }
    global class verifyAddressFailedMock implements HttpCalloutMock {
        // Implement this interface method
        global HTTPResponse respond(HTTPRequest req) {
            String authId = 'adsmfqmwepm09daasd';
            String token = '23240kfir8fj8f8';
    
            String addString = 'https://us-street.api.smartystreets.com/street-address?auth-id='+authId+'&auth-token='+token
                +'&street=street&city=city&state=state&secondary=secondary&country=Country&zipcode=10011&candidates=candidate';
            System.assertEquals('GET', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"example":"test"}]');
            res.setStatusCode(400);
            return res;
        }
    }
    public class CalloutClass {
        public HttpResponse getInfoFromExternalService() {
            String authId = 'adsmfqmwepm09daasd';
            String token = '23240kfir8fj8f8';
    
            String addString = 'https://us-street.api.smartystreets.com/street-address?auth-id='+authId+'&auth-token='+token
                +'&street=street&city=city&state=state&secondary=secondary&country=Country&zipcode=10011&candidates=candidate';
            HttpRequest req = new HttpRequest();
            req.setEndpoint(addString);
            req.setMethod('GET');
            Http h = new Http();
            HttpResponse res = h.send(req);
            return res;
        }
    }
}