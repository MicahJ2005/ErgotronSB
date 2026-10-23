global with sharing class ccErgServiceCart extends ccrz.ccServiceCart{
    global virtual override Map<String,Object> getFieldsMap(Map<String,Object> inputData) {
        System.debug('inputDatainputData'+inputData);
        inputData = super.getFieldsMap(inputData);
        String objectFields = (String)inputData.get(ccrz.ccService.OBJECTFIELDS);
        objectFields += ',cc_FreightCarrierActNbr__c, Source__c';
        return new Map<String,Object> {ccrz.ccService.OBJECTFIELDS => objectFields};
    }
}