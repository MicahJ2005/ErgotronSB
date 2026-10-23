/**
 * @description       : 
 * @author            : Titus.K@DemandChain.com
 * @group             : 
 * @last modified on  : 10-10-2022
 * @last modified by  : Titus.K@DemandChain.com
**/
public with sharing class ccCartItemController {
    public List<Item> lstItems;
    public string recordID {
        get {
            if (Test.isRunningTest()) {
                return [SELECT ccrz__Cart__c FROM ccrz__E_CartItem__c].ccrz__Cart__c;
            }
            return recordID;
        }
        set;
    }

    public List<Item> getlstItems() {
        Set<String> setProdID = new Set<String>();
        List<Item> lstItems = new List<Item>();
        List<ccrz__E_CartItem__c> lstCartItem = [SELECT ccrz__Product__c, ccrz__Product__r.name, ccrz__Quantity__c
                                                FROM ccrz__E_CartItem__c 
                                                WHERE ccrz__Cart__c = :recordID];
        System.debug(lstCartItem.size());
        if (lstCartItem != null && lstCartItem.size() > 0) {
            for (ccrz__E_CartItem__c c :lstCartItem) {
                setProdID.add(c.ccrz__Product__c);
            }

            List<ccrz__E_ProductMedia__c> lstProdMedia = [SELECT ccrz__URI__c, ccrz__Product__c FROM ccrz__E_ProductMedia__c 
                                                          WHERE ccrz__Product__c IN :setProdID
                                                          AND ccrz__Enabled__c = true
                                                          AND ccrz__StartDate__c <= TODAY
                                                          AND ccrz__EndDate__c >= TODAY];
            for (ccrz__E_CartItem__c c :lstCartItem) {
                Item i = new Item();
                i.productID = c.ccrz__Product__c;
                i.productName = c.ccrz__Product__r.name;
                i.cartItemQuantity = String.valueOf(c.ccrz__Quantity__c);
                for (ccrz__E_ProductMedia__c p :lstProdMedia) {
                    if (p.ccrz__Product__c == c.ccrz__Product__c) {
                        i.imgUrl = p.ccrz__URI__c;
                    }
                }
                lstItems.add(i);
            }
        }
        return lstItems;
    }

    public Class Item {
        public String productID {get;set;}
        public String productName {get;set;}
        public String cartItemQuantity {get;set;}
        public String imgUrl {get;set;}
    }
}