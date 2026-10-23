/**
 * @description       : 
 * @author            : Raziya Gurramkonda
 * @group             : 
 * @last modified on  : 11-17-2020
 * @last modified by  : Raziya Gurramkonda
 * Modifications Log 
 * Ver   Date         Author               Modification
 * 1.0   11-17-2020   Raziya Gurramkonda   Initial Version
**/
global without sharing class CC_ERG_ProductManager {
    
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
            checkPriceListProductsAvailability(mapRequestParams);
            if(mapRequestParams.containsKey(CC_ERG_Constant.BASE_PRICE_LIST_NAME) 
                && mapRequestParams.get(CC_ERG_Constant.BASE_PRICE_LIST_NAME) != null) {
                populateSalePriceList(mapRequestParams);
                populateSalePriceListProducts(mapRequestParams);
            }
            //fetch metadata to add a inventory check
             B2B_Constants__mdt b2bConstant = [SELECT DeveloperName, Inventory_Code_To_Check__c, B2B_Constants_Base_Price_List__c, 
                B2B_Constants_Current_Price_List__c, Order_Type_Id__c, Storefront_User_Name__c,Inventory_threshold__c 
                FROM B2B_Constants__mdt WHERE DeveloperName = 'B2B_Constant' LIMIT 1];

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
                Map<Id, ccrz__E_Product__c> mapProductsByIds = (Map<Id, ccrz__E_Product__c>) mapResponse.get(CC_ERG_Constant.PRODUCT_SEARCH_RESULTS);
                Map<String, Decimal> mapSaleSkuPrice;
                Map<String, Decimal> mapOfProductsCountSku;
                if(mapResponse.containsKey(CC_ERG_Constant.BASE_PRICE_SKU_MAP) &&
                    mapResponse.get(CC_ERG_Constant.BASE_PRICE_SKU_MAP)!=null) {
                        mapSaleSkuPrice = (Map<String, Decimal>) mapResponse.get(CC_ERG_Constant.BASE_PRICE_SKU_MAP);
                }
                if (mapRequestParams.containsKey(CC_ERG_Constant.INVENTORY_SKU_MAP) 
                    && mapRequestParams.get(CC_ERG_Constant.INVENTORY_SKU_MAP) != null) {
                    mapOfProductsCountSku = (Map<String, Decimal>) mapResponse.get(CC_ERG_Constant.INVENTORY_SKU_MAP);
                }
                for (String productId : mapProductsByIds.keySet())
                {
                    ccrz__E_Product__c ccProduct = mapProductsByIds.get(productId);
                    CC_ERG_ProductResponse.B2BProduct b2BProductObject = populateB2BProduct(ccProduct);
                    if (b2BProductObject != null)
                    {
                        populatePricing(allPriceListItemMap , mapResponse , b2BProductObject);
                        /* if(b2BProductObject.requiredProducts!=null && b2BProductObject.requiredProducts.size()>0)
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
                        } */

                        if(mapSaleSkuPrice?.get(b2BProductObject.sku) !=null) {
                            System.debug(' 123### saleprice  ==> '+ mapSaleSkuPrice?.get(b2BProductObject.sku));
                            b2BProductObject.price.salePrice = mapSaleSkuPrice?.get(b2BProductObject.sku);
                        }

                        if(mapOfProductsCountSku?.get(b2BProductObject.sku) !=null) {
                            System.debug(' 123### quantity  ==> '+ mapOfProductsCountSku?.get(b2BProductObject.sku));
                            integer invLimit = 0 ;
                            if(b2bConstant.Inventory_threshold__c != null){
                                invLimit = integer.valueOf(b2bConstant.Inventory_threshold__c);
                            }
                            if(mapOfProductsCountSku?.get(b2BProductObject.sku) > invLimit){
                                b2BProductObject.isProductAvailable = true;
                            }
                        }

                        lstProducts.add(b2BProductObject);
                    }
                }
                system.debug('**** lstProducts'+lstProducts);
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
            system.debug('*** allPriceListItemList'+allPriceListItemList);
            b2BProductObject.price = CC_ERG_PricingService.populateProductPricing(allPriceListItemList,mapResponse);
        }
    }

/*     global static void populateProductImages(Map<String,ccrz__E_ProductMedia__c> mapProductImageSKU, CC_ERG_ProductResponse.B2BProduct b2BProductObject)
    {
        if(mapProductImageSKU!=null && b2BProductObject!=null && mapProductImageSKU.containsKey( b2BProductObject.sku))
        {
            ccrz__E_ProductMedia__c productEMediaObject = (ccrz__E_ProductMedia__c)mapProductImageSKU.get( b2BProductObject.sku);
            if(productEMediaObject!=null && String.isNotBlank(productEMediaObject.ccrz__ProductDescription__c))
            {
                b2BProductObject.imageURL = productEMediaObject.ccrz__ProductDescription__c;
            }
        }
    } */

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
            b2BProduct.isProductAvailable = false;
           // b2BProduct.productFamily = ccProduct.Product_Family__c;
           // b2BProduct.isRecurringProduct = ccProduct.Recurring_Price__c;
           // b2BProduct.accountLevel = ccProduct.Account_Level__c;
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
            List<ccrz__E_CompositeProduct__c> bundleComponents = ccProduct.ccrz__CompositeProducts__r;
            if(bundleComponents!=null && bundleComponents.size()>0)
            {
                /* List<ccrz__E_Product__c> bundleProductComponents = new List<ccrz__E_Product__c>();
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
                } */
            }

            List<ccrz__E_ProductMedia__c> lstProductMedias = ccProduct.ccrz__E_ProductMedias__r;
            if(lstProductMedias!=null && lstProductMedias.size()>0)
            {
                for(ccrz__E_ProductMedia__c productMediaObject : lstProductMedias)
                {
                    if(productMediaObject.ccrz__MediaType__c == CC_ERG_Constant.PRODUCT_IMAGE_NAME)
                    {
                        b2BProduct.imageURL =productMediaObject.ccrz__ProductDescription__c;
                    }
                }
            }

            List<ccrz__E_RelatedProduct__c> lstRelatedProducts = ccProduct.ccrz__E_RelatedProducts__r;
            if(lstRelatedProducts!=null && lstRelatedProducts.size()>0)
            {
                /* List<ccrz__E_RelatedProduct__c> requiredProducts = new List<ccrz__E_RelatedProduct__c>();
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
                } */
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

/*     global static List<CC_ERG_ProductResponse.B2BProduct> populateB2BBundleComponents(List<ccrz__E_Product__c> b2bProducts)
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
    } */

   /*  global static List<CC_ERG_ProductResponse.B2BProduct> populateRelatedProductComponents(List<ccrz__E_RelatedProduct__c> b2bRelatedProducts)
    {
        List<CC_ERG_ProductResponse.B2BProduct> lstProductComponents = new List<CC_ERG_ProductResponse.B2BProduct>();
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
    } */
    /*
    global static CC_ERG_ProductResponse fetchAddOnProducts(CC_ERG_ProductResponse productResponse)
    {
        CC_ERG_ProductResponse hardWareProducts = new CC_ERG_ProductResponse();
        List<CC_ERG_ProductResponse.B2BProduct> lstAddOnProducts = new List<CC_ERG_ProductResponse.B2BProduct>();
        if(productResponse!=null && productResponse.products!=null && productResponse.products.size()>0)
        {
            for(CC_ERG_ProductResponse.B2BProduct b2bProduct : productResponse.products)
            {
                if(b2bProduct.addOnProducts!=null && b2bProduct.addOnProducts.size()>0)
                {
                    for(CC_ERG_ProductResponse.B2BProduct addOnProducts : b2bProduct.addOnProducts)
                    {
                        lstAddOnProducts.add(addOnProducts);
                    }
                }
            }
            hardWareProducts.products = lstAddOnProducts;
        }
        return hardWareProducts;
    }

    global static CC_ERG_ProductResponse fetchShippingProducts(CC_ERG_ProductResponse productResponse)
    {
        CC_ERG_ProductResponse shippingProducts = new CC_ERG_ProductResponse();
        List<CC_ERG_ProductResponse.B2BProduct> lstShipProducts = new List<CC_ERG_ProductResponse.B2BProduct>();
        if(productResponse!=null && productResponse.products!=null && productResponse.products.size()>0)
        {
            for(CC_ERG_ProductResponse.B2BProduct b2bProduct : productResponse.products)
            {
                if(b2bProduct.shippingProducts!=null && b2bProduct.shippingProducts.size()>0)
                {
                    for(CC_ERG_ProductResponse.B2BProduct shipProducts : b2bProduct.shippingProducts)
                    {
                        //if(shipProducts.price.salePrice>0){
                            lstShipProducts.add(shipProducts);
                        //}
                        
                    }
                }
            }
            shippingProducts.products = lstShipProducts;
        }
        return shippingProducts;
    }

    global static CC_ERG_ProductResponse fetchHardWareProducts(CC_ERG_ProductResponse productResponse)
    {
        CC_ERG_ProductResponse hardWareProducts = new CC_ERG_ProductResponse();
        List<CC_ERG_ProductResponse.B2BProduct> lstHardWareProducts = new List<CC_ERG_ProductResponse.B2BProduct>();
        if(productResponse!=null && productResponse.products!=null && productResponse.products.size()>0)
        {
            for(CC_ERG_ProductResponse.B2BProduct b2bProduct : productResponse.products)
            {
                if(b2bProduct.addOnProducts!=null && b2bProduct.addOnProducts.size()>0)
                {
                    for(CC_ERG_ProductResponse.B2BProduct addOnProducts : b2bProduct.addOnProducts)
                    {
                        if(addOnProducts.productFamily == CC_ERG_Constant.PRODUCT_FAMILY_PHONES)
                        {
                            lstHardWareProducts.add(addOnProducts);
                        }
                    }
                }
            }
            hardWareProducts.products = lstHardWareProducts;
        }
        return hardWareProducts;
    }
    */
    global static void populatePriceList(Map<String,Object> mapRequestParams)
    {
        if( !mapRequestParams.containsKey(CC_ERG_Constant.PRICE_LIST_NAME) ||
                (mapRequestParams.containsKey(CC_ERG_Constant.PRICE_LIST_NAME) &&  String.isBlank((String)mapRequestParams.get(CC_ERG_Constant.PRICE_LIST_NAME))))
        {
            
            
          //  String strDefaultPriceList = ccErg_Utilities.fetchVONConstantValue(ccErg_Constant.STOREFRONT_MODULE,ccErg_Constant.STOREFRONT_DEFAULT_PRICE_LIST);
            
            String strDefaultPriceList='';
            if(String.isNotBlank(strDefaultPriceList))
            {
                mapRequestParams.put(CC_ERG_Constant.PRICE_LIST_NAME , strDefaultPriceList );
            }
        }
        System.debug('>>>>mapRequestParams>>>>'+JSON.serialize(mapRequestParams));
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
            if(lstPriceItemLists?.size() > 0){
                for(ccrz__E_PriceListItem__c priceLstItem:lstPriceItemLists){
                    prodSku.add(priceLstItem.ccrz__Product__r.ccrz__SKU__c);
                }
                mapRequestParams.put(CC_ERG_Constant.PRODUCT_SEARCH_STRING, prodSku);
            }
        }
    }

    global static void populateSalePriceList(Map<String,Object> mapRequestParams)
    {
        if( !mapRequestParams.containsKey(CC_ERG_Constant.BASE_PRICE_LIST_NAME) ||
                (mapRequestParams.containsKey(CC_ERG_Constant.BASE_PRICE_LIST_NAME) &&  String.isBlank((String)mapRequestParams.get(CC_ERG_Constant.BASE_PRICE_LIST_NAME))))
        {
            //TODO set default Pricebook value from Metadata
            mapRequestParams.put(CC_ERG_Constant.BASE_PRICE_LIST_NAME ,'US Non-Standard' );
        }
        List<ccrz__E_PriceList__c> lstPriceLists = CC_ERG_PricingService.retrievePriceList(mapRequestParams);
        if(lstPriceLists!=null && lstPriceLists.size()>0)
        {
            mapRequestParams.put(CC_ERG_Constant.BASE_PRICE_LIST_ID , lstPriceLists[0].Id);
        }
    }

    global static void populateSalePriceListProducts(Map<String,Object> mapRequestParams)
    {
        if( mapRequestParams!=null && mapRequestParams.size()>0)
        {
            Map<String, Decimal> priceSkuMap = new Map<String, Decimal>();
            List<ccrz__E_PriceListItem__c> lstPriceItemLists = CC_ERG_PricingService.fetchPriceListItemAndProducts(mapRequestParams);
            if(lstPriceItemLists?.size() >0){
                for(ccrz__E_PriceListItem__c priceLstItem:lstPriceItemLists){
                    priceSkuMap.put(priceLstItem.ccrz__Product__r.ccrz__SKU__c, priceLstItem.ccrz__Price__c);
                }
                mapRequestParams.put(CC_ERG_Constant.BASE_PRICE_SKU_MAP, priceSkuMap);
            }
        }
    }

    global static void checkPriceListProductsAvailability(Map<String,Object> mapRequestParams) {
        if (mapRequestParams.containsKey(CC_ERG_Constant.PRODUCT_SEARCH_STRING) 
            && mapRequestParams.get(CC_ERG_Constant.PRODUCT_SEARCH_STRING) != null) {
                Map<String, Decimal> mapOfSku = new Map<String, Decimal>();
                string [] inventoryToCheck = CustomMetadataUtility.fetchInventoryToCheck()?.split(',');
                string query = 'SELECT ccrz__ProductItem__r.ccrz__SKU__c, ccrz__InventoryLocationCode__c, '+
                    +'SUM(ccrz__QtyAvailable__c) quantity FROM ccrz__E_ProductInventoryItem__c '
                    +'GROUP BY ccrz__ProductItem__r.ccrz__SKU__c,  ccrz__InventoryLocationCode__c '
                    +'HAVING ccrz__ProductItem__r.ccrz__SKU__c =: prodSku';

                string condition = '';
                for(String inventoryCode: inventoryToCheck){
                    if(condition == ''){
                        condition = ' AND (ccrz__InventoryLocationCode__c = \''+inventoryCode.trim()+'\'';
                    } else {
                        condition = condition + ' OR ccrz__InventoryLocationCode__c = \''+inventoryCode.trim()+'\'';
                    }
                }
                if(condition != ''){
                    query = query + condition +')';
                }
                Set<String> prodSku = (Set<String>) mapRequestParams.get(CC_ERG_Constant.PRODUCT_SEARCH_STRING);

                System.debug(' qqq==> '+query);
                System.debug(' qqq==> '+prodSku);

                List<AggregateResult> aggResult = Database.query(query);
                
                System.debug(' qqq==> '+aggResult);

                for(AggregateResult aggResultObj: aggResult) {
                    if(mapOfSku.containsKey((String) aggResultObj.get('ccrz__SKU__c'))){
                        Decimal count = mapOfSku.get((String) aggResultObj.get('ccrz__SKU__c'));
                        count += (Decimal) aggResultObj.get('quantity');
                        mapOfSku.put((String) aggResultObj.get('ccrz__SKU__c'), count);
                    } else {
                        mapOfSku.put((String) aggResultObj.get('ccrz__SKU__c'), (Decimal) aggResultObj.get('quantity'));
                    }
                }
                if(mapOfSku?.size() > 0){
                    mapRequestParams.put(CC_ERG_Constant.INVENTORY_SKU_MAP, mapOfSku);
                }
        }
    }
}