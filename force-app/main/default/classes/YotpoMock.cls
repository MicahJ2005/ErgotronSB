@isTest
global class YotpoMock implements HttpCalloutMock {
  global enum ResponseType {
    AUTH_SUCCESS,
    ORDER_CREATE_SUCCESS,
    ORDER_GET,
    PRODUCT_CREATE,
    PRODUCT_GET
  }

  private HttpResponse response;

  global YotpoMock(ResponseType type) {
    setResponse(type);
  }

  global HttpResponse respond(HttpRequest req) {
    return response;
  }

  private void setResponse(ResponseType type) {
    response = new HttpResponse();
    response.setHeader('Content-Type', 'application/json');
    switch on type {
      when AUTH_SUCCESS {
        response.setStatusCode(200);
        response.setBody('{"access_token": "myTestToken"}');
      }
      when ORDER_CREATE_SUCCESS {
        response.setStatusCode(201);
        response.setBody('{"order":{ "yotpo_id": "1"}}');
      }
      when ORDER_GET {
        response.setStatusCode(200);
        response.setBody('{ "orders": [ { "yotpo_id": 12345 } ] }');
      }
      when PRODUCT_CREATE {
        response.setStatusCode(201);
        response.setBody('{ "product": { "yotpo_id": 8675309 } }');
      }
      when PRODUCT_GET {
        response.setStatusCode(200);
        response.setBody('{ "products": [{ "yotpo_id": 42 }] }');
      }
    }
  }
}