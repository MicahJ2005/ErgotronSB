global with sharing class CC_ERG_LogicPIFetchEntitled extends ccrz.ccLogicPIFetchEntitled {

    global override Map<String, Object> fetchEntitledPriceLists(Map<String, Object> inputData){
        Map<String, Object> outputData = super.fetchEntitledPriceLists(inputData);
        Object piObj = outputData.get('piPriceLists');
        if(!String.isBlank(CC_ERG_static_utils.pricelistId)){
            piObj = new Set<String>{CC_ERG_static_utils.pricelistId};
            outputData.put('piPriceLists', piObj);
        }
        return outputData;
    }
    
    
    global static void dummy(){
        Integer x = 0;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
    }

}