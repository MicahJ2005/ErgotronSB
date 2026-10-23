global without sharing class Salesrep_Display_Ctrl {
	
    @AuraEnabled public static HelperSalesRepData getRepData(String strStateCode, String strPostalCode, String strCountryCode) {
        return Informatica_Callouts.SalesRepCallout(strStateCode, strPostalCode, strCountryCode);
    }
        
}