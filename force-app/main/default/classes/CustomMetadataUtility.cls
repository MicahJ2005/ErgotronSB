public with sharing class CustomMetadataUtility {
    static B2B_Constants__mdt fetchCustomMetadataRecord() {
        B2B_Constants__mdt b2bConstant = [SELECT DeveloperName, Inventory_Code_To_Check__c, B2B_Constants_Base_Price_List__c, 
        B2B_Constants_Current_Price_List__c, Order_Type_Id__c, Storefront_User_Name__c 
        FROM B2B_Constants__mdt WHERE DeveloperName = 'B2B_Constant' LIMIT 1];
        return b2bConstant;
    }

    public static String fetchCurrentPriceListName( ) {
        B2B_Constants__mdt b2bConstant = fetchCustomMetadataRecord();
        if(b2bConstant != null) {
            return b2bConstant.B2B_Constants_Current_Price_List__c;
        } 
        return null;
    }

    public static String fetchBasePriceListName( ) {
        B2B_Constants__mdt b2bConstant = fetchCustomMetadataRecord();
        if(b2bConstant != null) {
            return b2bConstant.B2B_Constants_Base_Price_List__c;
        } 
        return null;
    }

    public static String fetchStorefrontUserName( ) {
        B2B_Constants__mdt b2bConstant = fetchCustomMetadataRecord();
        if(b2bConstant != null) {
            return b2bConstant.Storefront_User_Name__c;
        } 
        return null;
    }

    public static String fetchInventoryToCheck( ) {
        B2B_Constants__mdt b2bConstant = fetchCustomMetadataRecord();
        if(b2bConstant != null) {
            return b2bConstant.Inventory_Code_To_Check__c;
        } 
        return null;
    }

    public static String fetchOrderTypeId( ) {
        B2B_Constants__mdt b2bConstant = fetchCustomMetadataRecord();
        if(b2bConstant != null) {
            return b2bConstant.Order_Type_Id__c;
        } 
        return null;
    }
}