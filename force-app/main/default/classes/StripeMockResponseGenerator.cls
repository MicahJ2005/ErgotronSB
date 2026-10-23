/*
  @description       : Mock Generator class for PaymentController_Test
  @author            : gaurang.arora@rafter.one (R1)
  @last modified on  : 12-05-2025
  @last modified by  : Gaurang Arora
  Modifications Log 
  Ver   Date         Author         Modification

*/
@isTest
global class StripeMockResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"id":"testId"}');
        res.setStatusCode(200);
        return res;
    }
}