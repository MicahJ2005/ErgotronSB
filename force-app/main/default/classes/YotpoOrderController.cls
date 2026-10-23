/** {Purpose} Controller for interacting with the Yotpo API
 *            Depends on YotpoAuthenticationHandler for authorization
 *   Jonathan Flatt        Author
 *   2021-08-07            Initial creation
 *   =============================================================================
 */

public without sharing class YotpoOrderController {
  public Map<Id, Product2> updateProducts;
  public List<ccrz__E_Order__c> updateOrders;
  private YotpoAuthenticationHandler authInstance;
  public List<ccrz__E_OrderItem__c> updateOrderItems;
  private Map<Id, List<YotpoModels.OrderFulfillmentModel>> fufillments;
  public Map<String, String> errors = new Map<String, String>();
  public Map<Id, Product2> createProducts = new Map<Id, Product2>();
  private List<ccrz__E_Order__c> orders;

  public YotpoOrderController(List<ccrz__E_Order__c> orders) {
    this.authInstance = YotpoAuthenticationHandler.getInstance();
    this.orders = orders;
  }

  public void sendOrders() {
    this.updateOrders = new List<ccrz__E_Order__c>();
    this.updateOrderItems = new List<ccrz__E_OrderItem__c>();
    this.fufillments = getFulfillmentModels();

    for (ccrz__E_Order__c order : this.orders) {
      try {
        yotpoSendOrder(order);
      } catch (Exception e) {
        this.errors.put(order.Id, e.getMessage() + e.getStackTraceString());
        throw e;
      }
    }
  }

  public void createProductsInYotpo() {
    this.updateProducts = new Map<Id, Product2>();
    for (ccrz__E_Order__c order : this.orders) {
      for (ccrz__E_OrderItem__c orderItem : order.ccrz__E_OrderItems__r) {
        if (
          String.isBlank(
            orderItem.ccrz__Product__r.Product__r.YotpoProductId__c
          )
        ) {
          createProduct(orderItem);
        }
      }
    }
  }

  private void yotpoSendOrder(ccrz__E_Order__c order) {
    YotpoModels.YotpoOrderCreateModel orderModel = new YotpoModels.YotpoOrderCreateModel(
      order,
      fufillments.get(order.Id)
    );
    String body = orderModel.getOrderBody();
    //if order has an Yotpo Order Id, PATCH order, else POST
    Boolean isCreate = String.isEmpty(order.Yotpo_Order_Id__c);
    String method = isCreate ? 'POST' : 'PATCH';
    String uri = isCreate
      ? authInstance.orderEndpoint
      : authInstance.orderEndpoint + '/' + order.Yotpo_Order_Id__c;
    HttpResponse objRes = YotpoAuthenticationHandler.callout(body, uri, method);
    Integer statusCode = objRes.getStatusCode();
    if (statusCode == 201) {
      YotpoModels.OrderResponse orderResponse = (YotpoModels.OrderResponse) JSON.deserialize(
        objRes.getBody(),
        YotpoModels.OrderResponse.class
      );
      order.Yotpo_Order_Id__c = orderResponse.order.yotpo_id;
      updateOrders.add(order);
      updateOrderItems.addAll(setFulfillmentIds(order.ccrz__E_OrderItems__r));
    } else if (statusCode == 200) {
      //patch response will have no body, just a success code
      updateOrderItems.addAll(setFulfillmentIds(order.ccrz__E_OrderItems__r));
    } else if (statusCode == 409) {
      //if for some reason the order already exsists in Yotpo,
      //we query the order GET endpoint with the external Id (salesforce Order Id)
      //to get the Yotpo Order Id, then we retry once
      getYotpoOrderIdFromSalesforceId(order);
      updateOrders.add(order);
      yotpoSendOrder(order);
    }
  }

  private List<ccrz__E_OrderItem__c> setFulfillmentIds(
    List<ccrz__E_OrderItem__c> successOrderItems
  ) {
    for (ccrz__E_OrderItem__c orderItem : successOrderItems) {
      orderItem.YotpoFulfillmentId__c = YotpoModels.getFulfillmentId(
        orderItem.ccrz__Order__c,
        orderItem.YotpoShippedDate__c
      );
    }
    return successOrderItems;
  }

  @TestVisible
  private void getYotpoOrderIdFromSalesforceId(ccrz__E_Order__c order) {
    if (!String.isEmpty(order.Yotpo_Order_Id__c)) {
      return;
    }

    String uri = authInstance.orderEndpoint + '?external_ids=' + order.Id;
    String method = 'GET';
    HttpResponse objRes = YotpoAuthenticationHandler.Callout('', uri, method);
    if (objRes.getStatusCode() == 200) {
      YotpoModels.OrderResponses responses = (YotpoModels.OrderResponses) JSON.deserialize(
        objRes.getBody(),
        YotpoModels.OrderResponses.class
      );
      order.Yotpo_Order_Id__c = responses.orders[0].yotpo_id;
    } else {
      handleError(order.Id, objRes);
    }
  }

  private Map<Id, List<YotpoModels.OrderFulfillmentModel>> getFulfillmentModels() {
    //for each order we need a list of fulfillments grouped by shipping date
    //return a map of OrderId => List of Yotpo Fulfillments
    Map<Id, Map<Id, ccrz__E_OrderItem__c>> orderOrderItemMap = new Map<Id, Map<Id, ccrz__E_OrderItem__c>>();
    Map<Id, List<YotpoModels.OrderFulfillmentModel>> fulfillmentModels = new Map<Id, List<YotpoModels.OrderFulfillmentModel>>();

    for (ccrz__E_Order__c order : orders) {
      fulfillmentModels.put(
        order.Id,
        new List<YotpoModels.OrderFulfillmentModel>()
      );
      //get map of Orders to Order Items
      Map<Id, ccrz__E_OrderItem__c> orderItemMap = new Map<Id, ccrz__E_OrderItem__c>(
        order.ccrz__E_OrderItems__r
      );
      Map<Date, List<YotpoModels.LineItemModel>> dateMap = new Map<Date, List<YotpoModels.LineItemModel>>();
      for (ccrz__E_OrderItem__c orderItem : order.ccrz__E_OrderItems__r) {
        if (dateMap.containsKey(orderItem.YotpoShippedDate__c)) {
          dateMap.get(orderItem.YotpoShippedDate__c)
            .add(new YotpoModels.LineItemModel(orderItem));
        } else {
          dateMap.put(
            orderItem.YotpoShippedDate__c,
            new List<YotpoModels.LineItemModel>{
              new YotpoModels.LineItemModel(orderItem)
            }
          );
        }
      }
      for (Date shippedDate : dateMap.keySet()) {
        if (shippedDate != null) {
          fulfillmentModels.get(order.Id)
            .add(
              new YotpoModels.OrderFulfillmentModel(
                order.Id,
                shippedDate,
                dateMap.get(shippedDate)
              )
            );
        }
      }
    }
    return fulfillmentModels;
  }

  private void createProduct(ccrz__E_OrderItem__c orderItem) {
    ccrz__E_Product__c product = orderItem.ccrz__Product__r;
    String newYotpoProductId;
    String body = JSON.serialize(new YotpoModels.ProductModel(product));
    String uri = authInstance.baseUrl + 'products';
    String method = 'POST';
    HttpResponse objRes = YotpoAuthenticationHandler.Callout(body, uri, method);
    Integer statusCode = objRes.getStatusCode();

    if (statusCode == 409) {
      //external Id already exists in Yotpo, callout to Yotpo to retrieve the Yotpo Product Id
      //update collection will not alert for newly created products
      Product2 p = updateProduct(
        orderItem,
        getYotpoProductIdFromSalesforceId(product)
      );
      this.updateProducts.put(p.id, p);
    } else if (statusCode == 200 || statusCode == 201) {
      YotpoModels.ProductResponse response = (YotpoModels.ProductResponse) JSON.deserialize(
        objRes.getBody(),
        YotpoModels.ProductResponse.class
      );
      //Newly created products will send email alert
      Product2 p = updateProduct(orderItem, response?.product?.yotpo_id);
      this.createProducts.put(p.id, p);
    } else {
      handleError(orderItem.Id, objRes);
    }
  }

  private Product2 updateProduct(
    ccrz__E_OrderItem__c orderItem,
    String newYotpoProductId
  ) {
    return new Product2(
      Id = orderItem.ccrz__Product__r.Product__c,
      Name = orderItem.ccrz__Product__r.Product__r.Name,
      YotpoProductId__c = newYotpoProductId
    );
  }

  @TestVisible
  private String getYotpoProductIdFromSalesforceId(ccrz__E_Product__c product) {
    if (String.isEmpty(product.Product__c)) {
      return null;
    }
    String newYotpoProductId = null;
    String body;
    String method = 'GET';
    String uri =
      authInstance.baseUrl +
      'products?external_ids=' +
      product.ccrz__sku__c;
    HttpResponse objRes = YotpoAuthenticationHandler.callout(body, uri, method);
    if (objRes.getStatusCode() == 200) {
      YotpoModels.ProductResponses responses = (YotpoModels.ProductResponses) JSON.deserialize(
        objRes.getBody(),
        YotpoModels.ProductResponses.class
      );
      newYotpoProductId = responses.products[0].yotpo_id;
    } else {
      handleError(product.Product__c, objRes);
    }
    return newYotpoProductId;
  }

  public void handleError(String objectId, HttpResponse errorResponse) {
    String errorMessage =
      'Unexpected status code: ' +
      errorResponse.getStatusCode() +
      ' ' +
      errorResponse.getStatus() +
      ' ' +
      errorResponse.getBody();
    System.debug(LoggingLevel.ERROR, errorMessage);
    this.errors.put(objectId, errorMessage);
  }
}