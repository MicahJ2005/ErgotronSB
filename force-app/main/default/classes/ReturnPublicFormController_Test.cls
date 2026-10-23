@isTest
public with sharing class ReturnPublicFormController_Test {
    @testSetup
    private static void testSetup() {
        ccrz__E_Cart__c cart = new ccrz__E_Cart__c();
        cart.Source__c = 'Ergotron';
        insert cart;


        Contact c = new Contact();
        c.email = 'test@test.com';
        c.FirstName = 'test';
        c.LastName = 'test';
        insert c;

        Account a = new Account();
        a.name = 'test account';
        insert a;

        Sales_Order__c so = new Sales_Order__c();
        so.Billl_To_Contact__c = c.Id;
        so.Credit_Card_Approval_Code__c = 'conde';
        so.Customer_PO_Number__c = 'conde';
        so.Ship_To_Contact__c = c.Id;
        so.Ship_To_Customer__c = a.Id;
        insert so;

        Sales_Order_Line__c sol = new Sales_Order_Line__c();
        sol.Sales_Order__c = so.Id;
        sol.Quantity__c = 2;
        insert sol;

        ccrz__E_Order__c ccrzOrder = new ccrz__E_Order__c();
        ccrzOrder.Sales_Order__c = so.Id;
        ccrzOrder.ccrz__Contact__c = c.Id;
        ccrzOrder.ccrz__Account__c = a.Id;
        ccrzOrder.ccrz__OrderNumber__c = 8888;
        ccrzOrder.ccrz__BuyerEmail__c = 'email@email.com';
        ccrzOrder.ccrz__OriginatedCart__c = cart.id;
        insert ccrzOrder;
       
        Order__c o = new Order__c();
        o.Salesforce_Sales_Order__c = so.Id;
        insert o;

        Order_Line_Item__c oli = new Order_Line_Item__c();
        oli.Order__c = o.Id;
        insert oli;


        Oracle_Return_Reason__c reason1 = new Oracle_Return_Reason__c();
        reason1.Name = 'Positive';
        reason1.Description__c = 'Positive';
        reason1.Meaning__c	 = 'Positive';
        reason1.Lookup_Code__c = 'POSITIVE';
        reason1.Start_Date_Active__c = date.today();
        reason1.External_Valid_Reason__c = true;
        reason1.External__c = true;
        reason1.Enabled_Flag__c = true;
        insert reason1;

        Oracle_Return_Reason__c reason2 = new Oracle_Return_Reason__c();
        reason2.Name = 'Negative';
        reason2.Description__c = 'Negative';
        reason2.Meaning__c	 = 'Negative';
        reason2.Lookup_Code__c = 'NEGATIVE';
        reason2.Start_Date_Active__c = date.today();
        reason2.External_Valid_Reason__c = false;
        reason2.External__c = true;
        reason2.Enabled_Flag__c = true;
        insert reason2;

    }


    @isTest
    public static void getReasons_Test() {
        Test.startTest();
        List<Oracle_Return_Reason__c> rrm = ReturnPublicFormController.getReasons();
        Test.stopTest();

    }

    @isTest
    public static void getReturnObject_Valid_Test() {
        ccrz__E_Order__c o = [SELECT ID, ccrz__BuyerEmail__c, Order_Number_Txt__c FROM ccrz__E_Order__c limit 1];
        Test.startTest();
        ReturnPublicFormController.returnObject rrm = ReturnPublicFormController.getReturnObject(o.ccrz__BuyerEmail__c, o.Order_Number_Txt__c);
        Test.stopTest();

    }

    @isTest
    public static void getReturnObject_No_Data() {
        delete [SELECT Id FROM Sales_Order_Line__c];
        ccrz__E_Order__c o = [SELECT ID, ccrz__BuyerEmail__c, Order_Number_Txt__c FROM ccrz__E_Order__c limit 1];
        Test.startTest();
        ReturnPublicFormController.returnObject rrm = ReturnPublicFormController.getReturnObject(o.ccrz__BuyerEmail__c, o.Order_Number_Txt__c);
        Test.stopTest();

        System.assertEquals(false, rrm.success);

    }

    @isTest
    public static void getReturnObject_Wrong_Test() {
        ccrz__E_Order__c o = [SELECT ID, ccrz__BuyerEmail__c, Order_Number_Txt__c FROM ccrz__E_Order__c limit 1];
        Test.startTest();
        ReturnPublicFormController.returnObject rrm = ReturnPublicFormController.getReturnObject('wrong name', o.Order_Number_Txt__c);
        Test.stopTest();

    }

    @isTest
    public static void Save_Test_Happy_Path() {
        ccrz__E_Order__c o = [SELECT ID, ccrz__BuyerEmail__c, Order_Number_Txt__c FROM ccrz__E_Order__c limit 1];
        ReturnPublicFormController.returnObject rrm = ReturnPublicFormController.getReturnObject(o.Order_Number_Txt__c, o.ccrz__BuyerEmail__c);

        for(ReturnPublicFormController.returnLines lines : rrm.lines){
            lines.reason = 'POSITIVE';
            lines.haspackaging = true;
            lines.returning = true;
            lines.returnquantity = 1;
        }

        Test.startTest();
        ReturnPublicFormController.save_result result = ReturnPublicFormController.save(Json.serialize(rrm));
        Test.stopTest();

        System.assertEquals(true, result.success);
        System.assertEquals('option 1', result.message);

    }

    @isTest
    public static void Save_Test_No_Packaging() {
        ccrz__E_Order__c o = [SELECT ID, ccrz__BuyerEmail__c, Order_Number_Txt__c FROM ccrz__E_Order__c limit 1];
        ReturnPublicFormController.returnObject rrm = ReturnPublicFormController.getReturnObject(o.Order_Number_Txt__c, o.ccrz__BuyerEmail__c);
        for(ReturnPublicFormController.returnLines lines : rrm.lines){
            lines.reason = ReturnPublicFormController.getReasons()[0].Lookup_Code__c;
            lines.haspackaging = false;
            lines.returning = true;
            lines.returnquantity = 1;
        }

        Test.startTest();
        ReturnPublicFormController.save_result result = ReturnPublicFormController.save(Json.serialize(rrm));
        Test.stopTest();

        System.assertEquals(true, result.success);
        System.assertEquals('option 2', result.message);

    }

    @isTest
    public static void Save_Test_Invalid_Reason() {
        ccrz__E_Order__c o = [SELECT ID, ccrz__BuyerEmail__c, Order_Number_Txt__c FROM ccrz__E_Order__c limit 1];
        ReturnPublicFormController.returnObject rrm = ReturnPublicFormController.getReturnObject(o.Order_Number_Txt__c, o.ccrz__BuyerEmail__c);

        for(ReturnPublicFormController.returnLines lines : rrm.lines){
            lines.reason = 'NEGATIVE';
            lines.haspackaging = true;
            lines.returning = true;
            lines.returnquantity = 1;
        }

        Test.startTest();
        ReturnPublicFormController.save_result result = ReturnPublicFormController.save(Json.serialize(rrm));
        Test.stopTest();

        System.assertEquals(true, result.success);
        System.assertEquals('option 2', result.message);
    }

    @isTest
    public static void Save_Test_Null() {
        ccrz__E_Order__c o = [SELECT ID, ccrz__BuyerEmail__c, Order_Number_Txt__c FROM ccrz__E_Order__c limit 1];
        ReturnPublicFormController.returnObject rrm = ReturnPublicFormController.getReturnObject(o.Order_Number_Txt__c, o.ccrz__BuyerEmail__c);

        Test.startTest();
        ReturnPublicFormController.save_result result = ReturnPublicFormController.save(null);
        Test.stopTest();

        System.assertEquals(false, result.success);
        System.assertEquals('null', result.message);

    }

    @isTest
    public static void Save_Test_No_Lines() {
        ccrz__E_Order__c o = [SELECT ID, ccrz__BuyerEmail__c, Order_Number_Txt__c FROM ccrz__E_Order__c limit 1];
        ReturnPublicFormController.returnObject rrm = ReturnPublicFormController.getReturnObject(o.Order_Number_Txt__c, o.ccrz__BuyerEmail__c);

        for(ReturnPublicFormController.returnLines lines : rrm.lines){
            lines.reason = ReturnPublicFormController.getReasons()[0].Lookup_Code__c;
            lines.returnquantity = 0;
            lines.haspackaging = true;
            lines.returning = false;
            lines.returnquantity = 1;
        }

        Test.startTest();
        ReturnPublicFormController.save_result result = ReturnPublicFormController.save(Json.serialize(rrm));
        Test.stopTest();

        System.assertEquals(false, result.success);
        System.assertEquals('no lines', result.message);

    }

    @isTest
    public static void Save_Test_Exception() {
        ccrz__E_Order__c o = [SELECT ID, ccrz__BuyerEmail__c, Order_Number_Txt__c FROM ccrz__E_Order__c limit 1];
        ReturnPublicFormController.returnObject rrm = ReturnPublicFormController.getReturnObject(o.Order_Number_Txt__c, o.ccrz__BuyerEmail__c);
        rrm.Contact_Id = 'fakeID';
        for(ReturnPublicFormController.returnLines lines : rrm.lines){
            lines.reason = ReturnPublicFormController.getReasons()[0].Lookup_Code__c;
            lines.haspackaging = true;
            lines.returning = true;
            lines.returnquantity = 1;
        }

        Test.startTest();
        ReturnPublicFormController.save_result result = ReturnPublicFormController.save(Json.serialize(rrm));
        Test.stopTest();

        System.assertEquals(false, result.success);
        System.assertEquals('unknown error occured', result.message);

    }
}