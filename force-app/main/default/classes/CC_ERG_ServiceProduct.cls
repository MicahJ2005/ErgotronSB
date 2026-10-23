global with sharing class CC_ERG_ServiceProduct extends ccrz.ccServiceProduct{

    global virtual override Map<String,Object> getFieldsMap(Map<String,Object> inputData) {
        inputData = super.getFieldsMap(inputData);
        String objectFields = (String)inputData.get(ccrz.ccService.OBJECTFIELDS);
        objectFields += ',External_URL__c';
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:X', 'ccErgServiceCart:getFieldsMap:'+objectFields);
        return new Map<String,Object> {ccrz.ccService.OBJECTFIELDS => objectFields};
      
    }
    
}