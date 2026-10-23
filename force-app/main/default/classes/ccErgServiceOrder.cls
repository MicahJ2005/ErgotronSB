/**
 * @description       : 
 * @author            : Rajesh Kumar
 * @group             : 
 * @last modified on  : 08-26-2020
 * @last modified by  : Rajesh Kumar
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   08-26-2020   Rajesh Kumar   Initial Version
**/
global with sharing class ccErgServiceOrder extends ccrz.ccServiceOrder{
    global virtual override Map<String,Object> getFieldsMap(Map<String,Object> inputData) {
        inputData = super.getFieldsMap(inputData);
        String objectFields = (String)inputData.get(ccrz.ccService.OBJECTFIELDS);
        objectFields += ',cc_FreightCarrierActNbr__c,Sales_Order__r.OracleSalesOrderRefNumber__c';
        return new Map<String,Object> {ccrz.ccService.OBJECTFIELDS => objectFields};
      
    }
}