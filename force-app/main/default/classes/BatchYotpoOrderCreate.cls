/** {Purpose} Batch job for creating Orders in Yotpo.  When an order is shipped,
 *  send Order Fulfillment info to Yotpo.
 *  By default, runs at 1 am every day
 *   Date    	Name / Description 08.05.2021 Jonathan Flatt (Demand Chain)
 *               Initial creation
 *   =============================================================================
 *
 */

global class BatchYotpoOrderCreate implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful, Schedulable {
  public static String CRON_EXP = '0 0 1 * * ?';
  public static Integer BATCH_SIZE = 10;

  public static Id scheduleBatch() {
    String jobName = 'YotpoOrderCreate[' + DateTime.now().format() + ']';
    BatchYotpoOrderCreate schedulableInstance = new BatchYotpoOrderCreate();
    return System.schedule(jobName, CRON_EXP, schedulableInstance);
  }

  global void execute(SchedulableContext SC) {
    System.debug('execute scheduleable');
    Id batchId = Database.executeBatch(new BatchYotpoOrderCreate(), BATCH_SIZE);
    System.debug('batchId: ' + batchId);
  }
  public Map<String, String> errors = new Map<String, String>();
  public Map<Id, Product2> createdProducts = new Map<Id, Product2>();

  public static String query =
    'SELECT Id,' +
    ' ccrz__Account__c,' +
    ' ccrz__OrderStatus__c,' +
    ' ccrz__OriginatedCart__c,' +
    ' ccrz__Contact__r.email, ' +
    ' ccrz__Contact__r.Id, ' +
    ' ccrz__Contact__r.FirstName, ' +
    ' ccrz__Contact__r.LastName,' +
    ' ccrz__Contact__r.et4ae5__HasOptedOutOfMobile__c, ' +
    ' ccrz__Contact__r.HasOptedOutOfEmail,' +
    ' ccrz__E_Order__c.ccrz__OrderDate__c, ' +
    ' Yotpo_Order_Id__c, ' +
    ' ccrz__BuyerPhone__c,' +
    ' ccrz__BillTo__r.ccrz__AddressFirstline__c, ' +
    ' ccrz__BillTo__r.ccrz__AddressSecondline__c,' +
    ' ccrz__BillTo__r.ccrz__City__c,' +
    ' ccrz__BillTo__r.ccrz__CompanyName__c,' +
    ' ccrz__BillTo__r.ccrz__State__c, ' +
    ' ccrz__BillTo__r.ccrz__PostalCode__c,' +
    ' ccrz__BillTo__r.ccrz__StateISOCode__c,' +
    ' ccrz__BillTo__r.ccrz__CountryISOCode__c,' +
    ' ccrz__ShipTo__r.ccrz__AddressFirstline__c,' +
    ' ccrz__ShipTo__r.ccrz__AddressSecondline__c,' +
    ' ccrz__ShipTo__r.ccrz__City__c,' +
    ' ccrz__ShipTo__r.ccrz__CompanyName__c,' +
    ' ccrz__ShipTo__r.ccrz__State__c,' +
    ' ccrz__ShipTo__r.ccrz__PostalCode__c,' +
    ' ccrz__ShipTo__r.ccrz__StateISOCode__c,' +
    ' ccrz__ShipTo__r.ccrz__CountryISOCode__c,' +
    ' (SELECT Id,' +
    ' ccrz__Order__c,' +
    ' ccrz__Product__c,' +
    ' ccrz__Product__r.Product__c,' +
    ' ccrz__Product__r.Product__r.External_URL__c,' +
    ' ccrz__Product__r.Product__r.Name,' +
    ' ccrz__Product__r.Product__r.YotpoProductId__c,' +
    ' ccrz__Product__r.Name,' +
    ' ccrz__Product__r.ccrz__SKU__c,' +
    ' ccrz__Quantity__c,' +
    ' YotpoShippedDate__c' +
    ' FROM ccrz__E_OrderItems__r' +
    ' WHERE ccrz__OrderItemStatus__c = \'Shipped\'' +
    ' AND YotpoShippedDate__c != null)' +
    ' FROM ccrz__E_Order__c WHERE' +
    ' ccrz__OrderStatus__c IN' +
    '  (\'Shipped\', \'Partial Shipped\', \'Completed\')' +
    ' AND YotpoPendingFulfillments__c > 0' +
    ' AND ccrz__OriginatedCart__r.Source__c = \'Ergotron\'';

  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(query);
  }

  global void execute(
    Database.BatchableContext BC,
    List<ccrz__E_Order__c> orders
  ) {
    System.debug('Execute batchable');
    YotpoOrderController controller = new YotpoOrderController(orders);
    controller.createProductsInYotpo();
    controller.sendOrders();
    this.createdProducts.putAll(controller.createProducts);
    this.errors.putAll(controller.errors);
    try {
      update controller.updateOrders;
      update controller.updateOrderItems;
      update controller.updateProducts.values();
      update controller.createProducts.values();
    } catch (exception e) {
      this.errors.put(
        'DML Error see exception',
        e.getMessage() + e.getStackTraceString()
      );
    }
  }

  global void finish(Database.BatchableContext BC) {
    AsyncApexJob a = [
      SELECT
        Id,
        Status,
        NumberOfErrors,
        JobItemsProcessed,
        TotalJobItems,
        CreatedBy.Email
      FROM AsyncApexJob
      WHERE Id = :BC.getJobId()
    ];
    System.debug('FINISH ERRORS: ' + this.errors.size());
    if (
      this.errors.size() > 0 ||
      a.NumberOfErrors >= 1 ||
      Test.isRunningTest()
    ) {
      Messaging.SingleEmailMessage errorMail = new Messaging.SingleEmailMessage();
      String baseUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/';
      errorMail.setToAddresses(
        YotpoAuthenticationHandler.getInstance().errorReportMailAddresses
      );
      errorMail.setSubject('Batch Yotpo Order Create Error Report');
      String body = '';
      if (a.NumberOfErrors > 0 || Test.isRunningTest()) {
        body +=
          'Apex job status: The batch Apex job processed ' +
          a.TotalJobItems +
          ' batches with ' +
          a.NumberOfErrors +
          ' failures.\n';
      }
      if (this.errors.size() > 0 || Test.isRunningTest()) {
        body += '<style>table, th, td { border:1px solid black; } </style>';
        body += '<h2>Yotpo Api errors</h2><br/>';
        body += '<table style="width:100%"><tr><th>Record Link</th><th>Error</th></tr>';

        for (String orderId : errors.keySet()) {
          body +=
            '<tr><td><a href=' +
            baseUrl +
            orderId +
            '>' +
            orderId +
            '</a>' +
            '</td>' +
            '<td>' +
            errors.get(orderId) +
            '</td></tr>';
        }
        body += '</table>';
      }
      errorMail.setHtmlBody(body);
      Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ errorMail });
    }

    if (!this.createdProducts.isEmpty() || Test.isRunningTest()) {
      Messaging.SingleEmailMessage productCreationMail = new Messaging.SingleEmailMessage();
      String baseUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/';
      productCreationMail.setToAddresses(
        YotpoAuthenticationHandler.getInstance()
          .productCreationAlertMailAddresses
      );
      productCreationMail.setSubject('Products created in the Yotpo Store');
      String body = '<style>table, th, td { border:1px solid black; } </style>';
      body += '<h2>Products created in the Yotpo Store</h2><br/>';
      body += '<table style="width:100%"><tr><th>Product Link</th><th>Yotpo Product Id</th></tr>';

      for (Product2 product : createdProducts.values()) {
        body +=
          '<tr><td><a href=' +
          baseUrl +
          product.Id +
          '>' +
          product.Name +
          '</a>' +
          '</td>' +
          '<td>' +
          product.YotpoProductId__c +
          '</td>' +
          '</tr>';
      }
      body += '</table>';

      productCreationMail.setHtmlBody(body);
      Messaging.sendEmail(
        new List<Messaging.SingleEmailMessage>{ productCreationMail }
      );
    }
  }
}