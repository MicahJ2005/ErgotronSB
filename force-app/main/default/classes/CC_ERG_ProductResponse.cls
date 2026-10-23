global without sharing class CC_ERG_ProductResponse extends CC_ERG_BaseResponse {
    

    global List<B2BProduct> products{set;get;}
    global List<B2BCategories> categories{set;get;}
    global List<B2BSpecs> specs{set;get;}
   // global List<ProductRequest> productRequest{get;set;}
   // global String zipCode{get;set;}
   // global String jurisdictionCode{get;set;}
   // global Integer quantity{set;get;}
   // global List<String> specType{set;get;}
   // global List<String> features{set;get;}
   // global String storefrontName{get;set;}
   // global String userCurrency{get;set;}
   // global String countryCode{get;set;}

    global class B2BProduct implements Comparable{
        global String sku{set;get;}
        global String productId{set;get;}
        global String name{set;get;}
        global String type{set;get;}
        global String alternateName{set;get;}
        global String status{set;get;}
        global String shortDesc{set;get;}
        global String longDesc{set;get;}
        global String sequence{set;get;}
        global String productFamily{set;get;}
        global Boolean isRecurringProduct{set;get;}
        global Boolean accountLevel{set;get;}
        global String imageURL{set;get;}
        global Boolean isProductAvailable{set;get;}
        global List<B2BCategories> categories{set;get;}
        global List<B2BSpecs> specs{set;get;}
        global List<B2BProduct> components{set;get;}
        global List<B2BProduct> requiredProducts{set;get;}
        global List<B2BProduct> addOnProducts{set;get;}
        global List<B2BProduct> crossSellProducts{set;get;}
        global List<B2BProduct> hardwareProducts{set;get;}
        global List<B2BProduct> shippingProducts{set;get;}
        global CC_ERG_PricingVO price{set;get;}

        global Integer compareTo(Object objToCompare) {
            return name.compareTo(((B2BProduct)objToCompare).name);
        }     
    }

    global class B2BCategories
    {
        global String name{set;get;}
        global String categoryId{set;get;}
    }

    global class B2BSpecs
    {
        global String name{set;get;}
        global String specId{set;get;}
        global String locale{set;get;}
    }
    
    // global class ProductRequest
    // {
    //     global String storefrontName{set;get;}
    //     global String locale{set;get;}
    //     global String userCurrency{set;get;}
    //     global String priceBook{set;get;}
    //     global String countryCode{set;get;}
    //     global List<String> specType{get;set;}
    //     global List<String> features{get;set;}
    //     global Integer quantity{set;get;}
    //     global String zipCode{set;get;}
    //     global String jurisdictionCode{set;get;}
    // }
}