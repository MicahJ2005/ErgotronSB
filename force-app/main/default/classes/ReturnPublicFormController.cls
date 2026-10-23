public without sharing class ReturnPublicFormController {
	private static final String SALES_ORDER_PRODUCT = 'Product';
	private static final String SALES_ORDER_ORDER_TYPE = 'ECOMMERCE RETURN';
	private static final String SALES_ORDER_ORDER_TYPE_ID = '3068';
	private static final String SALES_ORDER_SEED_PRICE = '283168';
	private static final String SALES_ORDER_ORDER_SOURCE = 'B2BCommerce';
	private static final String CASE_SUB_TYPE = 'Return';
	private static final String CASE_ECOMMERCE_CASE = 'Yes eStore';
	private static final String CASE_SUBJECT_BOTH = 'RETURN - Missing Packaging and Invalid Reason';
	private static final String CASE_SUBJECT_MISSING_PACKAGE = 'RETURN - Missing Packaging';
	private static final String CASE_SUBJECT_INVALID_REASON = 'RETURN - Invalid Reason';
	private static final String CASE_SUBJECT_PART_STORE = 'RETURN - From Part Store';
 

    /*
     * returns reasons from the metadata Return_Reason__mdt.
     *
     * @author Matthew J Lennington -- (Demand Chain)
     * @date 2022-08-16
     *
    */
    @AuraEnabled(cacheable=true)
    public static List<Oracle_Return_Reason__c> getReasons() {
        //return [select label, valid__c from Return_Reason__mdt];
        List<Oracle_Return_Reason__c> orr = [SELECT Description__c, Lookup_Code__c, External_Valid_Reason__c FROM Oracle_Return_Reason__c WHERE External__c =: true AND Enabled_Flag__c	=: true ORDER BY Description__c ASC];

        for(Oracle_Return_Reason__c o : orr){
            o.Description__c = toTitleCase(o.Description__c);
        }
        return orr;
      
    }

    /*
     * converts a given string to Title Case where the first letter of every word
     * is uppercase and the rest are lowercase.
     *
     * @author Matthew J Lennington -- (Demand Chain)
     * @date 2022-08-26
     *
    */
    private static String toTitleCase(String phrase){
        String titlePhrase = '';
        //a set of words that should always (or at least, almost always) be in lower case when in Title Case
        //eg The Day of the Jackal.  First and last word of a phrase should always be Capped though.
        Set<String> forceLower = new Set<String>{'of', 'the', 'for', 'and', 'a', 'to', 'at' ,'an', 'but', 'if', 'or', 'nor', 'in', 'with', 'as'};
    
        if(phrase != null && phrase.length() > 0){
        String[] splitPhrase = phrase.trim().split(' ');
                
        for(integer i = 0; i < splitPhrase.size(); i++){
            if(!forceLower.contains(splitPhrase[i].toLowerCase()) || i == 0 || i == (splitPhrase.size()-1) ){
                titlePhrase += (splitPhrase[i].substring(0,1).toUpperCase())+(splitPhrase[i].substring(1).toLowerCase())+' ';
            } else {
                titlePhrase += splitPhrase[i].toLowerCase()+' ';
            }
        }
        }
        return titlePhrase.trim();
    }

    /*
     * returns the Salesorder if one is found.
     *
     * @author Matthew J Lennington -- (Demand Chain)
     * @date 2022-08-16
     *
    */
    @AuraEnabled
    public static returnObject getReturnObject(String orderNumber, String email) {
        return new returnObject(orderNumber, email);
    }

    /*
     * Save
     * 
     * @author Matthew J Lennington -- (Demand Chain)
     * @date 2022-08-10
     *
    */
    @AuraEnabled
    public static save_result save(string returnobj_string) {
        if(returnobj_string ==  null){
            return new save_result('null', false);
        }

        returnObject returnobj =  (returnObject) JSON.deserialize(returnobj_string, returnObject.class);

        //no lines with a quanity above 0.
        Boolean noReturnableLines = true;
        for(returnLines line : returnobj.lines){
            if(line.returning){
                noReturnableLines = false;
            }
        }
        if(noReturnableLines){
            return new save_result('no lines', false);
        }

        Map<String, Boolean> reasonMap = getReasonsMap();
        Boolean SalesforceStore = (returnobj.Store == 'Salesforce');
        Boolean noPackaging = false;
        Boolean invalidReason = false;
        for(returnLines line : returnobj.lines){
            if(line.returning && !line.haspackaging){
                noPackaging = true;
            }
            if(line.returning && !reasonMap?.get(line.reason)){
                invalidReason = true;
            }
        }
       
        Savepoint sp = Database.setSavepoint();
        try{
            //create records
            if(noPackaging || invalidReason || SalesforceStore){
                //create case
                createCase(returnobj, noPackaging, invalidReason, SalesforceStore);
                return new save_result('option 2', true);
            }
            //create salesorder
            Id soId = createSalesOrder(returnobj);
            //make call to Oracle

            if(!Test.isRunningTest()){
                ICRT_TransmitOrder.singleIdToSubmitOrderToICRT(soId);
            }
            


            return new save_result('option 1', true, soId);
        } catch(Exception ex){
            Database.rollback( sp );
            return new save_result('unknown error occured', false);
        }   

      

    }


    /*
     * Creates a Sales Order
     *
     * @author Matthew J Lennington -- (Demand Chain)
     * @date 2022-08-16
     *
    */
    private static Id createSalesOrder(returnObject returnobj){
        //get owner...0051M00000AvUZV
        Id ownerId = [SELECT Id FROM User WHERE Name =: 'Ergotron-System'].Id;

        Sales_Order__c so = new Sales_Order__c();
        so.Bill_To_Customer__c = returnobj.Account_Id;
        so.Billl_To_Contact__c = returnobj.Contact_Id;
        so.CC_Order_Number__c = returnobj.ccrz_E_Order_Number;
        so.Credit_Card_Approval_Code__c = returnobj.Credit_Card_Approval_Code;
        so.Customer_PO_Number__c = returnobj.Customer_PO_Number;
        so.Original_Order__c = returnobj.Sales_Order_Id;
        so.Ship_To_Contact__c = returnobj.Ship_To_Contact;
        so.Ship_To_Customer__c = returnobj.Ship_To_Customer;
        so.Order_Sub_Type__c = SALES_ORDER_PRODUCT;
        so.Order_Type__c = SALES_ORDER_ORDER_TYPE;
        so.Order_Type_Id__c = SALES_ORDER_ORDER_TYPE_ID;
        so.Seed_Price_List__c = SALES_ORDER_SEED_PRICE;
        so.Source__c = SALES_ORDER_ORDER_SOURCE;
        so.ownerId = ownerId;
        insert so;

        for(returnLines line : returnobj.lines){
            // if(line.returnquantity > 0){
            //     createSalesOrderLines(line, so.Id);
            // }
            if(line.returning){
                createSalesOrderLines(line, so.Id);
            }
        }

        return so.Id;
    }

    /*
     * Creates sales order lines.
     *
     * @author Matthew J Lennington -- (Demand Chain)
     * @date 2022-08-16
     *
    */
    private static void createSalesOrderLines(returnLines line, Id salesOrderIds){
        Sales_Order_Line__c so = new Sales_Order_Line__c();
        so.Price__c = line.price;
        so.Quantity__c = line.returnquantity;
        so.TRF_Reason__c = null;
        so.Part_Number__c = line.productId;
        so.Sales_Order__c = salesOrderIds;
        so.Calculate_Price__c = 'N';
        so.Return_Reason_Code__c = line.reason;
        so.Warehouse__c = 'TN1';
        insert so;
    }


    /*
     * Creates a case.
     *
     * @author Matthew J Lennington -- (Demand Chain)
     * @date 2022-08-16
     *
    */
    private static void createCase(returnObject returnobj, boolean missingPackaging, boolean invalidReason, boolean SalesforceStore){
        //Owner = Customer_Engagement_Queue

        Case c = new Case();
        c.OwnerId = [SELECT Id FROM Group where Type =: 'Queue' AND DeveloperName =: 'Customer_Engagement_Queue' LIMIT 1].Id;
        c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Product').getRecordTypeId();
        c.Sub_Type__c = CASE_SUB_TYPE;
        c.eCommerce_Case__c = CASE_ECOMMERCE_CASE;
        c.ProductId = returnobj.lines[0].productId;
        c.OrderNumber__c = returnobj.OracleSalesOrderRefNumber;
        c.AccountId = returnobj.Account_Id;
        c.ContactId = returnobj.Contact_Id;
        c.SuppliedEmail = returnobj.ccrz_BuyerEmail;
        c.Description =  cleanObject(returnobj);
        if(SalesforceStore){
            c.Subject = CASE_SUBJECT_PART_STORE;
        } else if(missingPackaging && invalidReason){
            c.Subject = CASE_SUBJECT_BOTH;
        } else if (missingPackaging){
            c.Subject = CASE_SUBJECT_MISSING_PACKAGE;
        } else {
            c.Subject =CASE_SUBJECT_INVALID_REASON;
        }
        insert c;
    }

    private static string cleanObject(returnObject returnobj){
        for (Integer i = (returnobj.lines.size()-1) ; i>= 0 ; i--){
            if(!returnobj.lines[i].returning){
                returnobj.lines.remove(i);
            }
        } 
        return Json.serializePretty(returnobj);

    }

    /*
     * Get a Reasons Map
     *
     * @author Matthew J Lennington -- (Demand Chain)
     * @date 2022-08-16
     *
    */
    private static Map<String, Boolean> getReasonsMap() {
        // Map<String, Boolean> returnMap = new Map<String, Boolean>();
        // for(Return_Reason__mdt mdt : [select label, valid__c from Return_Reason__mdt]){
        //     returnMap.put(mdt.label, mdt.valid__c);
        // }
        // return returnMap;

        Map<String, Boolean> returnMap = new Map<String, Boolean>();
        for(Oracle_Return_Reason__c orr : [SELECT Lookup_Code__c, External_Valid_Reason__c FROM Oracle_Return_Reason__c WHERE External__c =: true AND Enabled_Flag__c	=: true]){
            returnMap.put(orr.Lookup_Code__c, orr.External_Valid_Reason__c);
        }
        return returnMap;

    }


    public class returnObject {
        @auraEnabled
        public string OracleSalesOrderRefNumber {get;set;}
        @auraEnabled
        public string ccrz_E_Order_Id {get;set;}
        @auraEnabled
        public string ccrz_E_Order_Number {get;set;}
        @auraEnabled
        public string ccrz_BuyerEmail {get;set;}
        @auraEnabled
        public string Order_Line_Id {get;set;}
        @AuraEnabled
        public string Sales_Order_Id {get;set;}
        @AuraEnabled
        public string Contact_Id {get;set;}
        @AuraEnabled
        public string Account_Id {get;set;}
        @AuraEnabled
        public string Ship_To_Customer {get;set;}
        @AuraEnabled
        public string Ship_To_Contact {get;set;}
        @AuraEnabled
        public string Credit_Card_Approval_Code {get;set;}
        @AuraEnabled
        public string Customer_PO_Number {get;set;}
        @auraEnabled
        public string Store {get;set;}
        @auraEnabled
        public Date Actual_Shipment_Date {get;set;}
        @auraEnabled
        public Date Scheduled_Ship_Date {get;set;}
        @auraEnabled
        public boolean eligibleReturn {get;set;}
        @AuraEnabled
        public List<returnLines> lines {get;set;}
        @AuraEnabled
        public string status {get;set;}
        @AuraEnabled
        public boolean success {get;set;}

        returnObject(){
            this.OracleSalesOrderRefNumber = '';
            this.ccrz_E_Order_Id = '';
            this.ccrz_E_Order_Number = '';
            this.ccrz_BuyerEmail = '';
            this.Order_Line_Id = '';
            this.Sales_Order_Id = '';
            this.Contact_Id = '';
            this.Account_Id = '';
            this.Ship_To_Customer = '';
            this.Ship_To_Contact = '';
            this.Credit_Card_Approval_Code = '';
            this.Customer_PO_Number = '';
            this.Store = '';
            this.Actual_Shipment_Date = Date.today();
            this.Scheduled_Ship_Date = Date.today();
            this.status = '';
            this.success = false;
            this.lines = new List<returnLines>();
            this.eligibleReturn = true;
        }

        returnObject(string orderNumber, string email){
            try {
                this();
                //get ccrz Order
                ccrz__E_Order__c ccrzOrder = [SELECT Id, Sales_Order__c, ccrz__Contact__c, Sales_Order__r.Bill_To_Customer__c, Order_Number_Txt__c, Sales_Order__r.Credit_Card_Approval_Code__c, Sales_Order__r.Customer_PO_Number__c, Sales_Order__r.Ship_To_Contact__c, Sales_Order__r.Ship_To_Customer__c,
                ccrz__BuyerEmail__c, Sales_Order__r.OracleSalesOrderRefNumber__c, ccrz__OriginatedCart__r.Source__c FROM ccrz__E_Order__c WHERE Order_Number_Txt__c =: orderNumber.trim() AND ccrz__BuyerEmail__c =: email.trim() Limit 1];

                this.OracleSalesOrderRefNumber = ccrzOrder.Sales_Order__r.OracleSalesOrderRefNumber__c;
                this.ccrz_E_Order_Id = ccrzOrder.Id;
                this.ccrz_E_Order_Number = ccrzOrder.Order_Number_Txt__c;
                this.ccrz_BuyerEmail = ccrzOrder.ccrz__BuyerEmail__c;
                this.Credit_Card_Approval_Code = ccrzOrder.Sales_Order__r.Credit_Card_Approval_Code__c;
                this.Customer_PO_Number = ccrzOrder.Sales_Order__r.Customer_PO_Number__c;
                this.Store = ccrzOrder?.ccrz__OriginatedCart__r?.Source__c;
                this.Sales_Order_Id = ccrzOrder.Sales_Order__c;
                this.Contact_Id = ccrzOrder.ccrz__Contact__c;
                this.Account_Id = ccrzOrder.Sales_Order__r.Bill_To_Customer__c;
                this.Ship_To_Contact = ccrzOrder.Sales_Order__r.Ship_To_Contact__c;
                this.Ship_To_Customer = ccrzOrder.Sales_Order__r.Ship_To_Customer__c;
                
                //get order lines for date
                Order_Line_Item__c orderLine = [SELECT ID, Actual_Shipment_Date__c, Scheduled_Ship_Date__c FROM Order_Line_Item__c WHERE Order__r.Salesforce_Sales_Order__c =: ccrzOrder.Sales_Order__c ORDER BY Actual_Shipment_Date__c DESC, Scheduled_Ship_Date__c DESC LIMIT 1];

                this.Order_Line_Id = orderLine.Id;
                this.Actual_Shipment_Date = orderLine.Actual_Shipment_Date__c;
                this.Scheduled_Ship_Date = orderLine.Scheduled_Ship_Date__c;

                Date limitDate = Date.today().addDays(-50);
                this.eligibleReturn = ((Actual_Shipment_Date != null && Actual_Shipment_Date >= limitDate) || 
                       (Scheduled_Ship_Date != null && Scheduled_Ship_Date >= limitDate ));  

                //get sales order lines
                List<Sales_Order_Line__c> lines = [SELECT ID, Part_Number__c, Part_Number__r.Name, Part_Number__r.Oracle_Part_Name__c, Part_Number__r.ProductCode, Quantity__c, Sales_Order__c, Sales_Order__r.Bill_To_Customer__c, Price__c FROM Sales_Order_Line__c WHERE Sales_Order__c =: ccrzOrder.Sales_Order__c AND Part_Number__r.ProductCode != 'FREIGHT-CHARGE'];

                //create product id set
                Set<Id> productIdSet = new Set<Id>();
                for(Sales_Order_Line__c line : lines){
                    productIdSet.add(line.Part_Number__c);
                }

                //get images
                Map<Id, string> imageMap = new Map<Id, String>();
                for(ccrz__E_ProductMedia__c media : [SELECT Id, ccrz__URI__c, ccrz__Product__r.Product__c FROM ccrz__E_ProductMedia__c WHERE ccrz__Product__r.Product__c in: productIdSet]){
                    imageMap.put(media.ccrz__Product__r.Product__c, media.ccrz__URI__c.replace('65x65', '400x200').replace('orig.jpg', '400x200.jpg'));   

                }

                if(!lines.isEmpty()){
                    this.success = true;
                    for(Sales_Order_Line__c sol : lines){
                        returnLines rl = new returnLines();
                        //rl.productName = sol.Part_Number__r.Name;
                        rl.returning = false;
                        rl.productName = sol.Part_Number__r.Oracle_Part_Name__c;
                        rl.productCode = sol.Part_Number__r.ProductCode;
                        rl.productId = sol.Part_Number__c;
                        rl.productImage = imageMap?.get(sol.Part_Number__c);
                        rl.quantity = sol.Quantity__c;
                        rl.returnquantity = sol.Quantity__c;
                        rl.reason = '';
                        rl.haspackaging = false;
                        rl.price = sol.Price__c;
                        this.lines.add(rl);
                    }
                } else {
                    this.success = false;
                    this.status = 'No Data Found';
                }
            } catch (Exception ex){
                System.debug(ex);
                this.success = false;
                    this.status = 'No Data Found';
            }
        }
    }

    public class returnLines {
        @AuraEnabled
        public boolean returning {get;set;}
        @AuraEnabled
        public string productName {get;set;}
        @AuraEnabled
        public string productCode {get;set;}
        @AuraEnabled
        public Id productId {get;set;}
        @AuraEnabled
        public string productImage {get;set;}
        @AuraEnabled
        public decimal quantity {get;set;}
        @AuraEnabled
        public decimal returnquantity {get;set;}
        @AuraEnabled
        public string reason {get;set;}
        @AuraEnabled
        public boolean haspackaging {get;set;}
        @AuraEnabled
        public decimal price {get;set;}
    }

    public class save_result {
        @AuraEnabled
        public string message {get;set;}
        @AuraEnabled
        public boolean success {get;set;}
        @AuraEnabled
        public string sales_order_id {get;set;}

        save_result(string m, boolean s){
            this.message = m;
            this.success = s;
        }

        save_result(string m, boolean s, string soi){
            this.message = m;
            this.success = s;
            this.sales_order_id = soi;
        }
    }

}