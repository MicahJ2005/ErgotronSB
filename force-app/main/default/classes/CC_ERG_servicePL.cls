global class CC_ERG_servicePL extends ccrz.ccServicePL{
    
    global override Map<String,Object> fetch(Map<String,Object> inputData){
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'CC_ERG_servicePL:fetch:inputData: ', inputData);
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'CC_ERG_servicePL:fetch:currCartId: ', ccrz.cc_CallContext.currCartId);
        if(!String.isBlank(getPLID())){
            inputData.put(ccrz.ccApiPriceList.IDS, new Set<String>{getPLID()});
            Map<String, Object> agplids = new Map<String, Object>();
            agplids.put(ccrz.ccApiPriceList.ACCTGRPPLIDS, new Set<String>{getPLID()});
            inputData.put(ccrz.ccApiPriceList.PLIDS, agplids);
            ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'CC_ERG_servicePL:fetch:inputData2: ', inputData);
        }
        return super.fetch(inputData);
    }
    
    global override Map<String,Object> getFilterMap(Map<String,Object> inputData){
        Map<String,Object> localizedFilterMap = super.getFilterMap(inputData);
        if(!String.isBlank(getPLID())){
            localizedFilterMap = CC_ERG_static_utils.accFilter(localizedFilterMap, ccrz.ccApiPriceList.IDS,'Id IN :' + ccrz.ccApiPriceList.IDS + '', 'AND');
        }
        return localizedFilterMap;
    }
    
    private static String getPLID(){
        return CC_ERG_static_utils.pricelistId;
    }
}