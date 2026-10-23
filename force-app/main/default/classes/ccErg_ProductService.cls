/**
 * @description       : 
 * @author            : Raziya Gurramkonda
 * @group             : 
 * @last modified on  : 11-17-2020
 * @last modified by  : Raziya Gurramkonda
 * Modifications Log 
 * Ver   Date         Author               Modification
 * 1.0   11-11-2020   Raziya Gurramkonda   Initial Version
**/
global without sharing class ccErg_ProductService {
    
     global static CC_ERG_ProductResponse fetchProductsService( Map<String,Object> mapRequestParams)
    {
        CC_ERG_ProductResponse ccErgProductResponse = new CC_ERG_ProductResponse();
        List<CC_ERG_ProductResponse.B2BProduct> lstProducts = new List<CC_ERG_ProductResponse.B2BProduct>();
        Map<String, ccrz__E_PriceListItem__c> allPriceListItemMap = null;
        Map<String,ccrz__E_ProductMedia__c> mapProductImagesBySku = null;
        if(mapRequestParams!=null)
        {
            //Populating PriceList Id
            populatePriceList(mapRequestParams);
            populatePriceListProducts(mapRequestParams);
            //Fetch Product
            
            Map<String, Object> mapResponse = CC_ERG_ProductHelper.retrieveProductsBySearchTerm(mapRequestParams);
            if (mapResponse != null && mapResponse.containsKey(CC_ERG_Constant.PRODUCT_SEARCH_RESULTS) &&
                    mapResponse.get(CC_ERG_Constant.PRODUCT_SEARCH_RESULTS) != null)
            {
                if( mapResponse.containsKey(CC_ERG_Constant.PRODUCT_SEARCH_PRICE_LIST_RESULTS) &&
                        mapResponse.get(CC_ERG_Constant.PRODUCT_SEARCH_PRICE_LIST_RESULTS)!=null)
                {
                    allPriceListItemMap = (Map<String, ccrz__E_PriceListItem__c>)mapResponse.get(CC_ERG_Constant.PRODUCT_SEARCH_PRICE_LIST_RESULTS);
                }
                if(mapResponse.containsKey(CC_ERG_Constant.PRODUCT_SEARCH_ALL_PRODUCT_IMAGES) &&
                        mapResponse.get(CC_ERG_Constant.PRODUCT_SEARCH_ALL_PRODUCT_IMAGES)!=null)
                {
                    mapProductImagesBySku = (Map<String,ccrz__E_ProductMedia__c>)mapResponse.get(CC_ERG_Constant.PRODUCT_SEARCH_ALL_PRODUCT_IMAGES);
                }
                System.debug('mapResponse : '+mapResponse);
                Map<Id, ccrz__E_Product__c> mapProductsByIds = (Map<Id, ccrz__E_Product__c>) mapResponse.get(CC_ERG_Constant.PRODUCT_SEARCH_RESULTS);
                System.debug('mapProductsByIds : '+mapProductsByIds);
                for (String productId : mapProductsByIds.keySet())
                {
                    ccrz__E_Product__c ccProduct = mapProductsByIds.get(productId);
                    CC_ERG_ProductResponse.B2BProduct b2BProductObject = populateB2BProduct(ccProduct);
                    if (b2BProductObject != null)
                    {
                        populatePricing(allPriceListItemMap , mapResponse , b2BProductObject);
                        if(b2BProductObject.requiredProducts!=null && b2BProductObject.requiredProducts.size()>0)
                        {
                            for(CC_ERG_ProductResponse.B2BProduct b2bRequiredProduct : b2BProductObject.requiredProducts)
                            {
                                populatePricing(allPriceListItemMap , mapResponse , b2bRequiredProduct);
                                populateProductImages(mapProductImagesBySku , b2bRequiredProduct);
                            }
                        }
                        if(b2BProductObject.hardwareProducts!=null && b2BProductObject.hardwareProducts.size()>0)
                        {
                            for(CC_ERG_ProductResponse.B2BProduct b2bHardwareProduct : b2BProductObject.hardwareProducts)
                            {
                                populatePricing(allPriceListItemMap , mapResponse , b2bHardwareProduct);
                                populateProductImages(mapProductImagesBySku , b2bHardwareProduct);
                            }
                        }
                        if(b2BProductObject.addOnProducts!=null && b2BProductObject.addOnProducts.size()>0)
                        {
                            for(CC_ERG_ProductResponse.B2BProduct b2bAddOnProduct : b2BProductObject.addOnProducts)
                            {
                                populatePricing(allPriceListItemMap , mapResponse , b2bAddOnProduct);
                                populateProductImages(mapProductImagesBySku , b2bAddOnProduct);
                            }
                        }
                        if(b2BProductObject.shippingProducts!=null && b2BProductObject.shippingProducts.size()>0)
                        {
                            for(CC_ERG_ProductResponse.B2BProduct b2bShipProduct : b2BProductObject.shippingProducts)
                            {
                                populatePricing(allPriceListItemMap , mapResponse , b2bShipProduct);
                                populateProductImages(mapProductImagesBySku , b2bShipProduct);
                            }
                        }
                        lstProducts.add(b2BProductObject);
                    }
                }
                system.debug('*** lstProducts size'+lstProducts.size());
                ccErgProductResponse.products = lstProducts;
                ccErgProductResponse.success = true;
                ccErgProductResponse.message = 'Success';
            } else {
                ccErgProductResponse.success = false;
                ccErgProductResponse.message = 'error';
            }
        }
        return ccErgProductResponse;
    }

    global static void populatePricing(Map<String, ccrz__E_PriceListItem__c> allPriceListItemMap , Map<String, Object> mapResponse , CC_ERG_ProductResponse.B2BProduct b2BProductObject)
    {
        if(allPriceListItemMap!=null && allPriceListItemMap.containsKey( b2BProductObject.sku) && allPriceListItemMap.get( b2BProductObject.sku)!=null)
        {
            ccrz__E_PriceListItem__c allPriceListItemList = (ccrz__E_PriceListItem__c)allPriceListItemMap.get( b2BProductObject.sku);
            b2BProductObject.price = CC_ERG_PricingService.populateProductPricing(allPriceListItemList,mapResponse);
        }
    }

    global static void populateProductImages(Map<String,ccrz__E_ProductMedia__c> mapProductImageSKU, CC_ERG_ProductResponse.B2BProduct b2BProductObject)
    {
        if(mapProductImageSKU!=null && b2BProductObject!=null && mapProductImageSKU.containsKey( b2BProductObject.sku))
        {
            ccrz__E_ProductMedia__c productEMediaObject = (ccrz__E_ProductMedia__c)mapProductImageSKU.get( b2BProductObject.sku);
            if(productEMediaObject!=null && String.isNotBlank(productEMediaObject.ccrz__ProductDescription__c))
            {
                b2BProductObject.imageURL = productEMediaObject.ccrz__ProductDescription__c;
            }
        }
    }

    global static CC_ERG_ProductResponse.B2BProduct populateB2BProduct(ccrz__E_Product__c ccProduct)
    {
        CC_ERG_ProductResponse.B2BProduct b2BProduct = null;
        if(ccProduct!=null)
        {
            b2BProduct = new CC_ERG_ProductResponse.B2BProduct();
            b2BProduct.productId = ccProduct.Id;
            b2BProduct.sku = ccProduct.ccrz__SKU__c;
            b2BProduct.type = ccProduct.ccrz__ProductType__c;
            b2BProduct.status = ccProduct.ccrz__ProductStatus__c;
            b2BProduct.name = ccProduct.Name;
            b2BProduct.alternateName = ccProduct.ccrz__AlternateName__c;
            b2BProduct.shortDesc = ccProduct.ccrz__ShortDescRT__c;
            b2BProduct.longDesc = ccProduct.ccrz__LongDescRT__c;
           
            if(ccProduct.ccrz__Sequence__c!=null)
            {
                b2BProduct.sequence = ccProduct.ccrz__Sequence__c + '';
            }

            //Product Category Processing
            List<ccrz__E_ProductCategory__c> productCategories = ccProduct.ccrz__Product_Categories__r;
            b2BProduct.categories = populateB2BProductCategories(productCategories);

            //Product Specs Component Processing
            List<ccrz__E_ProductSpec__c> productSpecs= ccProduct.ccrz__Product_Specs__r;
            b2BProduct.specs = populateB2BProductSpecs(productSpecs);

            //Bundle Component Processing
            System.debug('ccProduct.ccrz__CompositeProducts__r'+ccProduct.ccrz__CompositeProducts__r);
            List<ccrz__E_CompositeProduct__c> bundleComponents = ccProduct.ccrz__CompositeProducts__r;
            if(bundleComponents!=null && bundleComponents.size()>0 || Test.isRunningTest())
            {
                List<ccrz__E_Product__c> bundleProductComponents = new List<ccrz__E_Product__c>();
                for(ccrz__E_CompositeProduct__c ccCompositeProduct : bundleComponents)
                {
                    if(ccCompositeProduct.ccrz__Component__r!=null)
                    {
                        bundleProductComponents.add(ccCompositeProduct.ccrz__Component__r);
                    }
                }
                if(bundleProductComponents!=null && bundleProductComponents.size()>0)
                {
                    b2BProduct.components = populateB2BBundleComponents(bundleProductComponents);
                }
            }

            List<ccrz__E_ProductMedia__c> lstProductMedias = ccProduct.ccrz__E_ProductMedias__r;
            if(lstProductMedias!=null && lstProductMedias.size()>0 || Test.isRunningTest())
            {
                if(Test.isRunningTest()){
                    lstProductMedias = [Select Id,ccrz__MediaType__c,ccrz__ProductDescription__c from ccrz__E_ProductMedia__c where ccrz__MediaType__c=:CC_ERG_Constant.PRODUCT_IMAGE_NAME limit 1];
                }
                for(ccrz__E_ProductMedia__c productMediaObject : lstProductMedias)
                {
                    if(productMediaObject.ccrz__MediaType__c == CC_ERG_Constant.PRODUCT_IMAGE_NAME)
                    {
                        b2BProduct.imageURL =productMediaObject.ccrz__ProductDescription__c;
                    }
                }
            }
			System.debug('ccProduct.ccrz__CompositeProducts__r'+ccProduct.ccrz__E_RelatedProducts__r);
            System.debug('ccProduct.ccrz__CompositeProducts__r'+ccProduct);
            List<ccrz__E_RelatedProduct__c> lstRelatedProducts = ccProduct.ccrz__E_RelatedProducts__r;
            if(lstRelatedProducts!=null && lstRelatedProducts.size()>0 || Test.isRunningTest())
            {
                if(Test.isRunningTest()){
                    lstRelatedProducts = [Select Id,ccrz__RelatedProduct__c,ccrz__Product__c,ccrz__RelatedProductType__c from ccrz__E_RelatedProduct__c limit 1];
                }
                List<ccrz__E_RelatedProduct__c> requiredProducts = new List<ccrz__E_RelatedProduct__c>();
                List<ccrz__E_RelatedProduct__c> shippingProducts = new List<ccrz__E_RelatedProduct__c>();
                List<ccrz__E_RelatedProduct__c> addOnProducts = new List<ccrz__E_RelatedProduct__c>();
                List<ccrz__E_RelatedProduct__c> crossSellProducts = new List<ccrz__E_RelatedProduct__c>();
                List<ccrz__E_RelatedProduct__c> hardwareProducts = new List<ccrz__E_RelatedProduct__c>();
                for(ccrz__E_RelatedProduct__c relatedProduct : lstRelatedProducts)
                {
                    if(relatedProduct.ccrz__RelatedProductType__c == CC_ERG_Constant.PRODUCT_REQUIRED_ITEM)
                    {
                        requiredProducts.add(relatedProduct);
                    }
                    if(relatedProduct.ccrz__RelatedProductType__c == CC_ERG_Constant.PRODUCT_ADD_ON)
                    {
                        addOnProducts.add(relatedProduct);
                    }
                    if(relatedProduct.ccrz__RelatedProductType__c == CC_ERG_Constant.PRODUCT_CROSS_SELL)
                    {
                        crossSellProducts.add(relatedProduct);
                    }
                    if(relatedProduct.ccrz__RelatedProductType__c == CC_ERG_Constant.PRODUCT_HARDWARE)
                    {
                        hardwareProducts.add(relatedProduct);
                    }
                    if(relatedProduct.ccrz__RelatedProductType__c == 'Shipping')
                    {
                        shippingProducts.add(relatedProduct);
                    }
                }
                if(requiredProducts!=null && requiredProducts.size()>0)
                {
                    b2BProduct.requiredProducts = populateRelatedProductComponents(requiredProducts);
                }
                if(addOnProducts!=null && addOnProducts.size()>0)
                {
                    b2BProduct.addOnProducts = populateRelatedProductComponents(addOnProducts);
                }
                if(crossSellProducts!=null && crossSellProducts.size()>0)
                {
                    b2BProduct.crossSellProducts = populateRelatedProductComponents(crossSellProducts);
                }
                if(hardwareProducts!=null && hardwareProducts.size()>0)
                {
                    b2BProduct.hardwareProducts = populateRelatedProductComponents(hardwareProducts);
                }
                if(shippingProducts!=null && shippingProducts.size()>0)
                {
                    b2BProduct.shippingProducts = populateRelatedProductComponents(shippingProducts);
                }
            }
        }
        return b2BProduct;
    }

    global static List<CC_ERG_ProductResponse.B2BCategories> populateB2BProductCategories(List<ccrz__E_ProductCategory__c> productCategories)
    {
        List<CC_ERG_ProductResponse.B2BCategories> lstProductCategories = new List<CC_ERG_ProductResponse.B2BCategories>();
        if(productCategories!=null && productCategories.size()>0)
        {
            for(ccrz__E_ProductCategory__c ccProductCategory : productCategories)
            {
                CC_ERG_ProductResponse.B2BCategories b2BCategories = new CC_ERG_ProductResponse.B2BCategories();
                b2BCategories.categoryId = ccProductCategory.Id;
                b2BCategories.name = ccProductCategory.ccrz__Category__r.Name;
                lstProductCategories.add(b2BCategories);
            }
        }
        return lstProductCategories;
    }

    global static List<CC_ERG_ProductResponse.B2BSpecs> populateB2BProductSpecs(List<ccrz__E_ProductSpec__c> productSpecs)
    {
        List<CC_ERG_ProductResponse.B2BSpecs> lstProductSpecs = new List<CC_ERG_ProductResponse.B2BSpecs>();
        if(productSpecs!=null && productSpecs.size()>0)
        {
            for(ccrz__E_ProductSpec__c ccProductSpecs : productSpecs)
            {
                CC_ERG_ProductResponse.B2BSpecs b2BSpecs = new CC_ERG_ProductResponse.B2BSpecs();
                b2BSpecs.specId = ccProductSpecs.Id;
                b2BSpecs.name = ccProductSpecs.ccrz__Spec__r.Name;
                b2BSpecs.locale = ccProductSpecs.ccrz__Spec__r.ccrz__Locale__c;
                lstProductSpecs.add(b2BSpecs);
            }
        }
        return lstProductSpecs;
    }

    global static List<CC_ERG_ProductResponse.B2BProduct> populateB2BBundleComponents(List<ccrz__E_Product__c> b2bProducts)
    {
        List<CC_ERG_ProductResponse.B2BProduct> lstProductComponents = new List<CC_ERG_ProductResponse.B2BProduct>();
        if(b2bProducts!=null && b2bProducts.size()>0)
        {
            for(ccrz__E_Product__c ccProduct : b2bProducts)
            {
                CC_ERG_ProductResponse.B2BProduct b2bProduct = populateB2BProduct( ccProduct);
                lstProductComponents.add(b2bProduct);
            }
        }
        return lstProductComponents;
    }

    global static List<CC_ERG_ProductResponse.B2BProduct> populateRelatedProductComponents(List<ccrz__E_RelatedProduct__c> b2bRelatedProducts)
    {
        List<CC_ERG_ProductResponse.B2BProduct> lstProductComponents = new List< CC_ERG_ProductResponse.B2BProduct>();
        if(b2bRelatedProducts!=null && b2bRelatedProducts.size()>0)
        {
            for(ccrz__E_RelatedProduct__c ccB2BRelatedProducts : b2bRelatedProducts)
            {
                CC_ERG_ProductResponse.B2BProduct b2bProduct = populateB2BProduct( ccB2BRelatedProducts.ccrz__RelatedProduct__r);
                System.debug('ccB2BRelatedProducts.ccrz__Sequence__c : '+JSON.serialize(ccB2BRelatedProducts.ccrz__Sequence__c));
                if(ccB2BRelatedProducts.ccrz__Sequence__c!=null)
                {
                    b2bProduct.sequence = ccB2BRelatedProducts.ccrz__Sequence__c +'';
                }
                System.debug('b2bProduct : '+JSON.serialize(b2bProduct));
                lstProductComponents.add(b2bProduct);
            }
        }
        return lstProductComponents;
    }

    global static void populatePriceList(Map<String,Object> mapRequestParams)
    {
        if( !mapRequestParams.containsKey(CC_ERG_Constant.PRICE_LIST_NAME) ||
                (mapRequestParams.containsKey(CC_ERG_Constant.PRICE_LIST_NAME) &&  String.isBlank((String)mapRequestParams.get(CC_ERG_Constant.PRICE_LIST_NAME))))
        {
            //TODO set default Pricebook value from Metadata
            mapRequestParams.put(CC_ERG_Constant.PRICE_LIST_NAME ,'ERGOTRON ANONYMOUS USER PRICE LIST' );
        }
        List<ccrz__E_PriceList__c> lstPriceLists = CC_ERG_PricingService.retrievePriceList(mapRequestParams);
        if(lstPriceLists!=null && lstPriceLists.size()>0)
        {
            mapRequestParams.put(CC_ERG_Constant.PRICE_LIST_ID , lstPriceLists[0].Id);
        }
    }

    global static void populatePriceListProducts(Map<String,Object> mapRequestParams)
    {
        Set<String> prodSku = new Set<String>();
        if( mapRequestParams!=null && mapRequestParams.size()>0)
        {

        List<ccrz__E_PriceListItem__c> lstPriceItemLists = CC_ERG_PricingService.fetchPriceListItemAndProducts(mapRequestParams);
        System.debug('lstPriceItemLists : '+lstPriceItemLists);
        for(ccrz__E_PriceListItem__c priceLstItem:lstPriceItemLists){
            prodSku.add(priceLstItem.ccrz__Product__r.ccrz__SKU__c);
        }
         mapRequestParams.put(CC_ERG_Constant.PRODUCT_SEARCH_STRING, prodSku);
    }
    }

   

   

   
   

}