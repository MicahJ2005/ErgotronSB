@isTest
public class YotpoTest {
  @isTest
  static void canSetAuthToken() {
    Test.setMock(
      HttpCalloutMock.class,
      new YotpoMock(YotpoMock.ResponseType.AUTH_SUCCESS)
    );
    YotpoAuthenticationHandler handler = YotpoAuthenticationHandler.getInstance();
    System.assertEquals('myTestToken', handler.accessToken);
  }

  @isTest
  static void canPostOrder() {
    //Callout to Auth Endpoint to set access token
    Test.setMock(
      HttpCalloutMock.class,
      new YotpoMock(YotpoMock.ResponseType.AUTH_SUCCESS)
    );
    YotpoAuthenticationHandler.getInstance();

    //then set response to order create success
    Test.setMock(
      HttpCalloutMock.class,
      new YotpoMock(YotpoMock.ResponseType.ORDER_CREATE_SUCCESS)
    );
    makeOrderData();

    Test.startTest();
    String query = BatchYotpoOrderCreate.query;
    List<ccrz__E_Order__c> orders = Database.Query(query);
    System.assert(!orders.isEmpty());
    YotpoOrderController controller = new YotpoOrderController(orders);
    controller.sendOrders();
    update controller.updateOrders;
    update controller.updateOrderItems;
    Test.stopTest();

    List<ccrz__E_Order__c> resultOrders = [
      SELECT
        Id,
        Yotpo_Order_Id__c,
        YotpoPendingFulfillments__c,
        (SELECT Id, YotpoFulFillmentId__c FROM ccrz__E_OrderItems__r)
      FROM ccrz__E_Order__c
    ];

    System.assert(resultOrders[0].Yotpo_Order_Id__c == '1');
  }

  @isTest
  static void canExecuteBatch() {
    //Callout to Auth Endpoint to set access token
    Test.setMock(
      HttpCalloutMock.class,
      new YotpoMock(YotpoMock.ResponseType.AUTH_SUCCESS)
    );
    YotpoAuthenticationHandler.getInstance();
    makeOrderData();

    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new YotpoMock(YotpoMock.ResponseType.ORDER_CREATE_SUCCESS)
    );
    BatchYotpoOrderCreate batchable = new BatchYotpoOrderCreate();
    batchable.errors.put('test', 'test');
    batchable.createdProducts.put(null, new Product2());
    Database.executeBatch(batchable, 10);
    Test.stopTest();

    List<ccrz__E_Order__c> resultOrders = [
      SELECT
        Id,
        Yotpo_Order_Id__c,
        YotpoPendingFulfillments__c,
        (SELECT Id, YotpoFulFillmentId__c FROM ccrz__E_OrderItems__r)
      FROM ccrz__E_Order__c
    ];

    System.assertEquals(1, resultOrders.size());
    System.assertEquals('1', resultOrders[0].Yotpo_Order_Id__c);
  }

  @isTest
  static void canScheduleJob() {
    Test.setMock(
      HttpCalloutMock.class,
      new YotpoMock(YotpoMock.ResponseType.AUTH_SUCCESS)
    );
    Id jobId = BatchYotpoOrderCreate.scheduleBatch();
    System.assert(jobId != null);
  }

  @isTest
  static void canGetYotpoOrderId() {
    Test.setMock(
      HttpCalloutMock.class,
      new YotpoMock(YotpoMock.ResponseType.AUTH_SUCCESS)
    );
    YotpoAuthenticationHandler.getInstance();

    Test.setMock(
      HttpCalloutMock.class,
      new YotpoMock(YotpoMock.ResponseType.ORDER_GET)
    );
    ccrz__E_Order__c order = new ccrz__E_Order__c();
    order.Id = 'a5s000000000000000';
    YotpoOrderController controller = new YotpoOrderController(
      new List<ccrz__E_Order__c>{ order }
    );

    controller.getYotpoOrderIdFromSalesforceId(order);
    System.assertEquals('12345', order.Yotpo_Order_Id__c);
  }

  @isTest
  static void canCreateProduct() {
    Test.setMock(
      HttpCalloutMock.class,
      new YotpoMock(YotpoMock.ResponseType.AUTH_SUCCESS)
    );
    YotpoAuthenticationHandler.getInstance();
    makeOrderData();

    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new YotpoMock(YotpoMock.ResponseType.PRODUCT_CREATE)
    );

    List<ccrz__E_Order__c> orders = Database.query(BatchYotpoOrderCreate.query);
    YotpoOrderController controller = new YotpoOrderController(orders);
    controller.createProductsInYotpo();
    Test.stopTest();

    System.assertEquals(
      '8675309',
      controller.createProducts.values()[0].YotpoProductId__c
    );
  }

  @isTest
  static void canGetProduct() {
    Test.setMock(
      HttpCalloutMock.class,
      new YotpoMock(YotpoMock.ResponseType.AUTH_SUCCESS)
    );
    YotpoAuthenticationHandler.getInstance();
    makeOrderData();

    ccrz__E_Product__c testProduct = [
      SELECT Id, ccrz__sku__c, Product__c
      FROM ccrz__E_Product__c
      LIMIT 1
    ];

    Test.startTest();

    Test.setMock(
      HttpCalloutMock.class,
      new YotpoMock(YotpoMock.ResponseType.PRODUCT_GET)
    );
    ccrz__E_Order__c order = new ccrz__E_Order__c();
    order.Id = 'a5s000000000000000';
    YotpoOrderController controller = new YotpoOrderController(
      new List<ccrz__E_Order__c>{ order }
    );

    Test.stopTest();

    String result = controller.getYotpoProductIdFromSalesforceId(testProduct);
    System.assertEquals('42', result);
  }

  public static void makeOrderData() {
    Account a = new Account();
    a.Name = 'Test Account';
    insert a;

    Contact c = new Contact();
    c.FirstName = 'Testy';
    c.LastName = 'McTesterson';
    c.AccountId = a.Id;
    c.email = 'test123@test.com';
    c.et4ae5__HasOptedOutOfMobile__c = false;
    c.HasOptedOutOfEmail = false;
    insert c;

    Product2 newProduct2 = new Product2();
    newProduct2.name = 'Product0';
    newProduct2.External_URL__c = 'https://www.testing.test';
    insert newProduct2;

    ccrz__E_Product__c testProduct = new ccrz__E_Product__c();
    testProduct.Name = 'Product0';
    testProduct.ccrz__SKU__c = '000-000';
    testProduct.Product__c = newProduct2.Id;
    insert testProduct;

    ccrz__E_ContactAddr__c cAddr = new ccrz__E_ContactAddr__c();
    cAddr.ccrz__AddressFirstline__c = '123 Test Street';
    cAddr.ccrz__AddressSecondline__c = '#200';
    cAddr.ccrz__City__c = 'TestLand';
    cAddr.ccrz__CompanyName__c = 'ACME';
    cAddr.ccrz__State__c = 'New York';
    cAddr.ccrz__PostalCode__c = '00224';
    cAddr.ccrz__StateISOCode__c = 'NY';
    cAddr.ccrz__CountryISOCode__c = 'US';
    insert cAddr;

    Sales_Order__c soObj = new Sales_Order__c();
    soObj.Order_Sub_Type__c = 'Product';
    soObj.Customer_PO_Number__c = '12345';
    insert soObj;

    ccrz__E_Cart__c ccCartObj = new ccrz__E_Cart__c();
    ccCartObj.ccrz__CartStatus__c = 'Open';
    ccCartObj.ccrz__ActiveCart__c = true;
    ccCartObj.ccrz__BuyerCompanyName__c = 'TestCompany';
    ccCartObj.cc_FreightCarrierActNbr__c = 'FCA234234';
    ccCartObj.Source__c = 'Ergotron';
    insert ccCartObj;

    //Test Order Insert
    ccrz__E_Order__c order = new ccrz__E_Order__c();
    order.ccrz__Name__c = 'Test Order ';
    order.ccrz__OrderStatus__c = 'Shipped';
    order.ccrz__Account__c = a.Id;
    order.ccrz__BillTo__c = cAddr.Id;
    order.ccrz__ShipTo__c = cAddr.Id;
    order.ccrz__BuyerPhone__c = '+1 555 555 5555';
    order.ccrz__OriginatedCart__c = ccCartObj.Id;
    order.ccrz__Contact__c = c.Id;
    order.ccrz__OrderDate__c = Date.today().addDays(-2);
    insert order;

    ccrz__E_OrderItem__c orderItem = new ccrz__E_OrderItem__c();
    orderItem.ccrz__Product__c = testProduct.Id;
    orderItem.ccrz__Quantity__c = 10;
    orderItem.YotpoShippedDate__c = Date.today().addDays(-1);
    orderItem.ccrz__Order__c = order.Id;
    orderItem.ccrz__Price__c = 100.0;
    orderItem.ccrz__SubAmount__c = 100.0;
    orderItem.ccrz__OrderItemStatus__c = 'Shipped';
    insert orderItem;

    ccrz__E_OrderItem__c orderItem2 = new ccrz__E_OrderItem__c();
    orderItem2.ccrz__Product__c = testProduct.Id;
    orderItem2.ccrz__Quantity__c = 10;
    orderItem2.YotpoShippedDate__c = null;
    orderItem2.ccrz__Order__c = order.Id;
    orderItem2.ccrz__Price__c = 100.0;
    orderItem2.ccrz__SubAmount__c = 100.0;
    orderItem2.ccrz__OrderItemStatus__c = 'Shipped';
    insert orderItem2;
  }
}