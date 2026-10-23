/** {Purpose} Models and mappings of Salesforce Objects to Yotpo Store Objects
 *   Jonathan Flatt        Author
 *   2021-08-07            Initial creation
 *   =============================================================================
 */

public without sharing class YotpoModels {
  public static string getFulfillmentId(Id orderId, Date shippedDate) {
    String dateString =
      '[' +
      shippedDate.year() +
      '.' +
      shippedDate.month() +
      '.' +
      shippedDate.day() +
      ']';
    return orderId + dateString;
  }

  public static String convertDateToIso8601(Date orderDate) {
    DateTime orderDateTime = DateTime.newInstanceGmt(
      orderDate.year(),
      orderDate.month(),
      orderDate.day()
    );
    return orderDateTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss') + 'Z';
  }

  public class YotpoOrderCreateModel {
    public YotpoOrderModel order;

    public YotpoOrderCreateModel(
      ccrz__E_Order__c order,
      List<OrderFulfillmentModel> fulfillments
    ) {
      this.order = new YotpoOrderModel(order, fulfillments);
    }
    public String getOrderBody() {
      //supress nulls
      String body = JSON.serialize(this, true);
      System.debug(body);
      return body;
    }
  }

  public class YotpoOrderModel {
    public String external_id;
    public String order_date; //endpoint accepts ISO 8601, so we need to convert
    public CustomerModel customer;
    public List<LineItemModel> line_items;
    public List<OrderFulfillmentModel> fulfillments;
    public AddressModel shipping_address;
    public AddressModel billing_address;

    public YotpoOrderModel(
      ccrz__E_Order__c order,
      List<OrderFulfillmentModel> fulfillments
    ) {
      this.external_id = order.Id;
      this.order_date = convertDateToIso8601(order.ccrz__OrderDate__c);
      this.customer = new CustomerModel(order.ccrz__Contact__r);
      this.line_items = getLineItemModels(order.ccrz__E_OrderItems__r);
      this.fulfillments = fulfillments;
      this.shipping_address = new AddressModel(order.ccrz__ShipTo__r);
      this.billing_Address = new AddressModel(order.ccrz__BillTo__r);
    }
  }

  public class CustomerModel {
    String external_id;
    String email;
    String first_name;
    String last_name;
    Boolean accepts_sms_marketing;
    Boolean accepts_email_marketing;

    public CustomerModel(Contact contact) {
      external_id = contact.Id;
      email = contact.email;
      first_name = contact.FirstName;
      last_name = contact.LastName;
      accepts_sms_marketing = !contact.et4ae5__HasOptedOutOfMobile__c;
      accepts_email_marketing = !contact.HasOptedOutOfEmail;
    }
  }

  public class LineItemModel {
    Integer quantity;
    String external_product_id;

    public LineItemModel(ccrz__E_OrderItem__c orderItem) {
      quantity = (Integer) orderItem.ccrz__Quantity__c;
      external_product_id = orderItem.ccrz__Product__r.ccrz__sku__c;
    }
  }

  public static List<LineItemModel> getLineItemModels(
    List<ccrz__E_OrderItem__c> orderItems
  ) {
    List<LineItemModel> lineItemModels = new List<LineItemModel>();
    for (ccrz__E_OrderItem__c oi : orderItems) {
      lineItemModels.add(new lineItemModel(oi));
    }
    return lineItemModels;
  }

  public class AddressModel {
    string address1;
    string address2;
    string city;
    string company;
    string state;
    string zip;
    string province_code;
    string country_code;

    public AddressModel(ccrz__E_ContactAddr__c addr) {
      this.address1 = addr?.ccrz__AddressFirstline__c;
      this.address2 = addr?.ccrz__AddressSecondline__c;
      this.city = addr?.ccrz__City__c;
      this.company = addr?.ccrz__CompanyName__c;
      this.state = addr?.ccrz__State__c;
      this.zip = addr?.ccrz__PostalCode__c;
      this.province_code = addr?.ccrz__StateISOCode__c;
      this.country_code = addr?.ccrz__CountryISOCode__c;
    }
  }

  public class OrderFulfillmentModel {
    String fulfillment_date;
    String external_id;
    String status;
    List<LineItemModel> fulfilled_items;

    public OrderFulfillmentModel(
      Id orderId,
      Date shippedDate,
      List<LineItemModel> lineItemModels
    ) {
      fulfillment_date = convertDateToIso8601(shippedDate);
      this.external_id = getFulfillmentId(orderId, shippedDate);
      this.status = 'success'; //only send fulfilled items
      this.fulfilled_items = lineItemModels;
    }
  }

  public class OrderResponse {
    public OrderResponseObject order;
  }

  public class OrderResponses {
    public List<OrderResponseObject> orders;
  }

  public class OrderResponseObject {
    public String yotpo_id;
  }

  public class ProductModel {
    Product product;

    public ProductModel(ccrz__E_Product__c product) {
      this.product = new Product(product);
    }
  }

  public class Product {
    String external_id;
    String name;
    String description;
    String url;
    Integer price;
    String sku;

    public Product(ccrz__E_Product__c product) {
      external_id = product.ccrz__SKU__c;
      name = product.name;
      description = '';
      url = product.Product__r.External_URL__c;
      price = 0;
      sku = product.ccrz__SKU__c;
    }
  }
  public class ProductResponse {
    public ProductResponseObject product;
  }

  public class ProductResponses {
    public List<ProductResponseObject> products;
  }

  public class ProductResponseObject {
    public String yotpo_id;
  }
}