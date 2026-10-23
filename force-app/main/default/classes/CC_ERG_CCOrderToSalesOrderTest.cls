@isTest
public class CC_ERG_CCOrderToSalesOrderTest {

    
    // test data for order to sales trigger
    @TestSetUp
    private static void setupTestData() {
        Account account = Test_Environment_Utility.createInsertAccountUS();
        
        ccrz__E_Cart__c ccCart = new ccrz__E_Cart__c(ccrz__CartStatus__c = 'Open',ccrz__ActiveCart__c = True,ccrz__BuyerCompanyName__c = 'TestCompany',
                                                        cc_FreightCarrierActNbr__c= 'FCA234234',ergotron_order_type__c ='1234');
        insert ccCart;
        
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
        contactAddress.ccrz__Partner_Id__c = account.Id;
        insert contactAddress;
        
        ccrz__E_ContactAddr__c contactAddress1 = new ccrz__E_ContactAddr__c();
        contactAddress1.ccrz__CompanyName__c = 'Test Account1';
        contactAddress1.ccrz__AddressFirstline__c = 'Address line one1';
        contactAddress1.ccrz__City__c = 'Metropolis';
        contactAddress1.ccrz__State__c = 'Georgia';
        contactAddress1.ccrz__StateISOCode__c='GA';
        contactAddress1.ccrz__Country__c = 'United States';
        contactAddress1.ccrz__CountryISOCode__c='US';
        contactAddress1.ccrz__PostalCode__c = '78667';
        contactAddress1.ccrz__FirstName__c = 'Test1';
        contactAddress1.ccrz__LastName__c = 'Singh1';
        contactAddress1.ccrz__Partner_Id__c =account.Id;
        insert contactAddress1;
    
        ccrz__E_Order__c  ccOrder = new ccrz__E_Order__c(ccrz__OriginatedCart__c = ccCart.id, ccrz__OrderStatus__c = 'Open',
                                                            ccrz__BillTo__c = contactAddress.Id,ccrz__ShipTo__c = contactAddress1.Id); 
        insert ccOrder;
        
        ccrz__E_TransactionPayment__c payment = new ccrz__E_TransactionPayment__c(ccrz__AccountNumber__c='1111111',
                                                                                  ccrz__TransactionCode__c= '1111111', ccrz__Token__c='11111111',
                                                                                  ccrz__CCOrder__c = ccOrder.Id);
        insert payment;
        
        ccrz__E_Product__c ccProduct = new ccrz__E_Product__c(Name = 'Test Prod',ccrz__StartDate__c = Date.Today(),ccrz__EndDate__c = Date.today().addDays(10),ccrz__SKU__c ='35-341-200',ccrz__ProductStatus__c ='Released',
																ccrz__Quantityperunit__c =1.000000);
        insert ccProduct;
        
        ccrz__E_OrderItem__c  ccOrderItem = new ccrz__E_OrderItem__c(ccrz__Order__c = ccOrder.Id,ccrz__Quantity__c = 4,ccrz__Product__c = ccProduct.Id,
        																ccrz__Price__c = 501.00,ccrz__SubAmount__c = 501.00);
        insert ccOrderItem; 
        
        ccrz__E_CartItem__c ccCartItem = new ccrz__E_CartItem__c(ccrz__Cart__c = ccCart.id,ccrz__Quantity__c = 4,ccrz__Product__c = ccProduct.Id,
            													ccrz__Price__c = 501.00,ccrz__SubAmount__c = 501.00);
        insert ccCartItem;
        
        Oracle_Order_Type__c oraOrdType = new Oracle_Order_Type__c(Name = 'OMNI TRADE SHOW', Order_Type_Id__c =  ccCart.ergotron_order_type__c,
            														Salesforce_Order_Type__c = true, Domestic__c = true);
        insert oraOrdType;
    }
    
    static TestMethod void orderToSales(){
        List<ccrz__E_Order__c> ccOrders= [Select Id FROM ccrz__E_Order__c];
         List<string> eventData= new List<string>();
        for(ccrz__E_Order__c ccOrder : ccOrders){
            ccOrder.ccrz__OrderStatus__c = 'Order Submitted';
            ccOrder.ERG_Order_Sync_Status__c = 'Ready For Sales Order';
            ccOrder.ccrz__ShipAmount__c= 1;
            string ccOrderToSerialize= JSON.serialize(ccOrder);
            eventData.add(ccOrderToSerialize);
        }
        Test.startTest();
            update ccOrders;        
       CC_ERG_CCOrderToSalesOrder.CCOrderToSalesOrder(eventData);
        Test.stopTest();
    }
}