global with sharing class CC_ERG_ServiceCart extends ccrz.ccServiceCart{

    global virtual override Map<String,Object> getFieldsMap(Map<String,Object> inputData) {
        inputData = super.getFieldsMap(inputData);
        String objectFields = (String)inputData.get(ccrz.ccService.OBJECTFIELDS);
        objectFields += ',cc_FreightCarrierActNbr__c,Source__c';
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:X', 'ccErgServiceCart:getFieldsMap:'+objectFields);
        return new Map<String,Object> {ccrz.ccService.OBJECTFIELDS => objectFields};
      
    }
    
}