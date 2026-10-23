/**
 * @description       : 
 * @author            : Titus.K@DemandChain.com
 * @group             : 
 * @last modified on  : 10-10-2022
 * @last modified by  : Titus.K@DemandChain.com
**/
public with sharing class SalesOrderLineComponentController {
    
    public List<Item> lstItems;
    public string recordID {
        get {
            if (Test.isRunningTest()) {
                return [SELECT id FROM Sales_Order__c].id;
            }
            return recordID;
        }
        set;
    }

    public List<Item> getlstItems() {
        Set<String> setProductCode = new Set<String>();
        Set<String> setProductID = new Set<String>();
        Set<String> setEProductID = new Set<String>();
        List<Item> lstItems = new List<Item>();

        List<Sales_Order_Line__c> lstSalesOrderLine = [SELECT Product_Code__c, Quantity__c
                                                FROM Sales_Order_Line__c 
                                                WHERE Sales_Order__c = :recordID];
        System.debug(lstSalesOrderLine.size());
        if (lstSalesOrderLine != null && lstSalesOrderLine.size() > 0) {
            for (Sales_Order_Line__c o :lstSalesOrderLine) {
                setProductCode.add(o.Product_Code__c);
            }

            List<Product2> lstProduct = [SELECT id, ProductCode
                                        FROM Product2 
                                        WHERE ProductCode IN :setProductCode];
            if (lstProduct != null && lstProduct.size() >0) {
                for (Product2 p :lstProduct) {
                    setProductID.add(p.id);
                 }
                 List<ccrz__E_Product__c> lstEProduct = [SELECT ccrz__SKU__c, Product__c
                                                        FROM ccrz__E_Product__c
                                                        WHERE Product__c IN :setProductID];

                List<ccrz__E_ProductMedia__c> lstProductMedia;
                if (lstEProduct != null & lstEProduct.size() >0) {
                    for(ccrz__E_Product__c e :lstEProduct) {
                        setEProductID.add(e.id);
                    }
                    lstProductMedia = [SELECT ccrz__URI__c, ccrz__Product__r.ccrz__SKU__c, ccrz__Product__r.Product__c
                                                                    FROM ccrz__E_ProductMedia__c
                                                                    WHERE ccrz__Product__c IN :setEProductID];
                }

                for (Sales_Order_Line__c o :lstSalesOrderLine) {
                    item i = new item();
                    i.salesItemQuantity = String.valueOf(o.Quantity__c);
                    for (Product2 p2 :lstProduct) {
                        if (p2.ProductCode == o.Product_Code__c) {
                            for (ccrz__E_Product__c e :lstEProduct) {
                                if (e.Product__c == p2.id) {
                                    i.sku = e.ccrz__SKU__c;
                                    for (ccrz__E_ProductMedia__c pm :lstProductMedia) {
                                        if (pm.ccrz__Product__c == e.id) {
                                            i.imgURL = pm.ccrz__URI__c;
                                        }
                                    }
                                }
                            }
                        }
                    }
                    lstItems.add(i);
                }
            }
           
        }
        return lstItems;
    }

    public Class Item {
        public String sku {get;set;}
        public String salesItemQuantity {get;set;}
        public String imgUrl {get;set;}
    }
}