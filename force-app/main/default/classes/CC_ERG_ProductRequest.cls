global without sharing class CC_ERG_ProductRequest extends CC_ERG_BaseRequest {

    global Integer quantity{set;get;}
    global String sku{set;get;}
    global List<String> specType{set;get;}
    global List<String> features{get;set;}
    global String zipCode{get;set;}
    global String jurisdictionCode{get;set;}
//    global String productFamily{get;set;}
}