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
global without sharing class CC_ERG_ProductHelper {
    
    
    private final static String PRODUCT_CATEGORIES_FIELDS = ' Id, Name,  ccrz__Category__r.Id,ccrz__Category__r.Name,ccrz__Product__c, ' +
                                                                        'ccrz__Category__r.ccrz__StartDate__c, ccrz__Category__r.ccrz__EndDate__c,' +
                                                                        'ccrz__Sequence__c ';
    private final static String INNER_QUERY_PRODUCT_CATEGORIES =' (SELECT '+PRODUCT_CATEGORIES_FIELDS+' FROM ccrz__Product_Categories__r ' +
                                                                ' WHERE ccrz__Category__r.ccrz__StartDate__c<= TODAY AND ' +
                                                                ' ccrz__Category__r.ccrz__EndDate__c>TODAY ORDER BY ccrz__Sequence__c ASC)';

    private final static String PRODUCT_SPECS_FIELDS = ' Id,Name, ccrz__SpecValue__c, ccrz__Spec__c,ccrz__Spec__r.Name, ' +
                                                            'ccrz__Spec__r.ccrz__Locale__c, ccrz__Spec__r.ccrz__Sequence__c ';

    private final static String INNER_QUERY_PRODUCT_SPECS = '(SELECT  ' +PRODUCT_SPECS_FIELDS+' FROM '+
                                                            ' ccrz__Product_Specs__r ORDER BY ccrz__Spec__r.ccrz__Sequence__c ASC)';

    private final static String INNER_QUERY_PRODUCT_MEDIAS = '(SELECT Id,Name,ccrz__URI__c,ccrz__StartDate__c,ccrz__EndDate__c,' +
                                                            'ccrz__Enabled__c,ccrz__Sequence__c,ccrz__ProductMediaId__c,ccrz__FilePath__c,ccrz__Locale__c,' +
                                                            'ccrz__MediaType__c, ccrz__StaticResourceName__c,ccrz__ProductMediaSource__c,ccrz__ProductDescription__c ' +
                                                            'FROM ccrz__E_ProductMedias__r WHERE ccrz__Enabled__c=TRUE AND ccrz__StartDate__c <= TODAY AND ' +
                                                            'ccrz__EndDate__c>TODAY ORDER BY ccrz__Sequence__c ASC)';

    private final static String INNER_QUERY_COMPOSITE_PRODUCTS = '(SELECT Id,ccrz__Quantity__c,ccrz__Sequence__c,ccrz__Component__r.Id, ccrz__Component__r.ccrz__SKU__c, ' +
                                                                                                                'ccrz__Component__r.ccrz__AlternateName__c,ccrz__Component__r.Name, ccrz__Component__r.ccrz__ProductId__c,' +
                                                                                                                'ccrz__Component__r.ccrz__ProductType__c,ccrz__Component__r.ccrz__Storefront__c,ccrz__Component__r.ccrz__StartDate__c,' +
                                                                                                                'ccrz__Component__r.ccrz__EndDate__c,ccrz__Component__r.ccrz__ProductStatus__c,ccrz__Component__r.ccrz__ShortDescRT__c,' +
                                                                                                                'ccrz__Component__r.ccrz__LongDescRT__c,ccrz__Component__r.ccrz__Sequence__c FROM ccrz__CompositeProducts__r ' +
                                                                                                                ' WHERE ccrz__Component__r.ccrz__StartDate__c<= TODAY ' +
                                                                                                                'AND ccrz__Component__r.ccrz__EndDate__c>TODAY ORDER BY ccrz__Sequence__c ASC)';

    private final static String INNER_QUERY_RELATED_PRODUCTS = '(SELECT Id,Name,ccrz__Sequence__c,ccrz__StartDate__c,ccrz__EndDate__c,ccrz__Enabled__c,ccrz__RelatedProductType__c,' +
                                                                                                        'ccrz__RelatedProduct__r.Id, ccrz__RelatedProduct__r.ccrz__SKU__c, ccrz__RelatedProduct__r.ccrz__AlternateName__c,' +
                                                                                                        'ccrz__RelatedProduct__r.Name, ccrz__RelatedProduct__r.ccrz__ProductId__c,ccrz__RelatedProduct__r.ccrz__ProductType__c,' +
                                                                                                        'ccrz__RelatedProduct__r.ccrz__Storefront__c,ccrz__RelatedProduct__r.ccrz__StartDate__c,ccrz__RelatedProduct__r.ccrz__EndDate__c,' +
                                                                                                        'ccrz__RelatedProduct__r.ccrz__ProductStatus__c,ccrz__RelatedProduct__r.ccrz__ShortDescRT__c,ccrz__RelatedProduct__r.ccrz__LongDescRT__c, ' +
                                                                                                        'ccrz__RelatedProduct__r.ccrz__Sequence__c FROM ccrz__E_RelatedProducts__r ' +
                                                                                                        'WHERE ccrz__Enabled__c=TRUE AND ccrz__RelatedProduct__r.ccrz__StartDate__c<=TODAY AND ' +
                                                                                                        'ccrz__RelatedProduct__r.ccrz__EndDate__c>TODAY AND ccrz__StartDate__c<=TODAY AND ccrz__EndDate__c>TODAY ORDER BY ccrz__Sequence__c ASC)';
    
    
    global static  Map<String,Object> retrieveProductsBySearchTerm(Map<String,Object> mapParams){
        String [] inventoryToCheck = CustomMetadataUtility.fetchInventoryToCheck()?.split(',');
        List<String> inventroyLocation = new List<String>();
        String INNER_QUERY_INVENTORY = '(SELECT ccrz__QtyAvailable__c, ccrz__InventoryLocationCode__c '+
        'FROM ccrz__Product_Inventory_Items__r';

        string condition = '';
        for(String inventoryCode: inventoryToCheck){
            if(condition == ''){
                condition = ' WHERE ccrz__InventoryLocationCode__c = \''+inventoryCode.trim()+'\'';
            } else {
                condition = condition + ' OR ccrz__InventoryLocationCode__c = \''+inventoryCode.trim()+'\'';
            }
        }
        if(condition != ''){
            INNER_QUERY_INVENTORY = INNER_QUERY_INVENTORY + condition +')';
        } else {
            INNER_QUERY_INVENTORY = INNER_QUERY_INVENTORY + ')';
        }

        Map<Id, ccrz__E_Product__c> mapProducts = null;
        String methodName = 'retrieveProductsBySearchTerm';
        Set<String> setProductSKUs = new Set<String>();
        String supportData = '';
        String strSearchQuery = '';
        String strSearchType = null;
        Boolean productSearchByIdSKU = false;
        try {
            system.debug('map params in helper'+JSON.serialize(mapParams));
            //Creating Search Query
            if(mapParams!=null && mapParams.containsKey(CC_ERG_Constant.STOREFRONT_NAME) &&
                    String.isNotBlank((String)mapParams.get(CC_ERG_Constant.STOREFRONT_NAME)))
            {
                String strStorefrontName = (String)mapParams.get(CC_ERG_Constant.STOREFRONT_NAME);
                List<String> productStatus = new List<String>{CC_ERG_Constant.PRODUCT_RELEASED , CC_ERG_Constant.PRODUCT_NOT_ORDERABLE};
                String selectQueryFields = 'SELECT Id, ccrz__SKU__c, ccrz__AlternateName__c,Name, ccrz__ProductId__c,ccrz__ProductType__c,ccrz__Storefront__c,' +
                        'ccrz__StartDate__c,ccrz__EndDate__c,ccrz__ProductStatus__c,ccrz__ShortDescRT__c,ccrz__LongDescRT__c,' +
                        'ccrz__Sequence__c,' +
                        INNER_QUERY_PRODUCT_CATEGORIES + ',' +
                        INNER_QUERY_PRODUCT_SPECS +  ',' +
                        INNER_QUERY_COMPOSITE_PRODUCTS + ',' +
                        INNER_QUERY_RELATED_PRODUCTS + ',' +
                        INNER_QUERY_PRODUCT_MEDIAS + ',' +
                        INNER_QUERY_INVENTORY +
                        ' FROM ccrz__E_Product__c ';
                Set<String> setSearchStrings = mapParams.containsKey(CC_ERG_Constant.PRODUCT_SEARCH_STRING)?
                                                                (Set<String>) mapParams.get(CC_ERG_Constant.PRODUCT_SEARCH_STRING) : null;
                List<String> lstProdIds = mapParams.containsKey(CC_ERG_Constant.PRODUCT_SEARCH_IDS)?
                                                        (List<String>) mapParams.get(CC_ERG_Constant.PRODUCT_SEARCH_IDS) : null;
                ccrz.ccLog.log(LoggingLevel.DEBUG, 'M:X:product retrieveProductsBySearchTerm search type : ',
                                            mapParams.get(CC_ERG_Constant.PRODUCT_SKU_SEARCH_TYPE));
                ccrz.ccLog.log(LoggingLevel.DEBUG, 'M:X:product retrieveProductsBySearchTerm setSearchStrings : ', setSearchStrings);
                if (setSearchStrings!=null && setSearchStrings.size()>0)
                {
                    for(String strSearchParam : setSearchStrings)
                    {
                        String strTempProductSKU = strSearchParam;
                        setProductSKUs.add(strTempProductSKU);
                        strSearchQuery = '%'+String.escapeSingleQuotes(strSearchParam) + '%';
                    }
                }
                ccrz.ccLog.log(LoggingLevel.DEBUG, 'M:X:product retrieveProductsBySearchTerm lstProdIds : ', lstProdIds);
                ccrz.ccLog.log(LoggingLevel.DEBUG, 'M:X:product retrieveProductsBySearchTerm strSearchQuery : ', strSearchQuery);
                ccrz.ccLog.log(LoggingLevel.DEBUG, 'M:X:product retrieveProductsBySearchTerm setProductSKUs : ', setProductSKUs);
                Boolean isProductIdExist = false;
                // Form the WHERE clause based on inputs
                String whereClause = ' WHERE ';
                if (lstProdIds != null && lstProdIds.size() > 0)
                {
                    productSearchByIdSKU = true;
                    isProductIdExist = true;
                    whereClause += ' ( Id IN : lstProdIds ';
                }
                if (setProductSKUs!=null && setProductSKUs.size()>0)
                {
                    if(isProductIdExist)
                    {
                        whereClause += ' OR ';
                    }else
                    {
                        productSearchByIdSKU = true;
                        whereClause += ' ( ';
                    }
                    if(mapParams.containsKey(CC_ERG_Constant.PRODUCT_SKU_SEARCH_TYPE))
                    {
                        strSearchType = (String)mapParams.get(CC_ERG_Constant.PRODUCT_SKU_SEARCH_TYPE);
                    }
                    ccrz.ccLog.log(LoggingLevel.DEBUG, 'M:X:product retrieveProductsBySearchTerm strSearchType : ', strSearchType);
                    if((String.isNotBlank(strSearchType) && strSearchType == CC_ERG_Constant.PRODUCT_SKU_ADD_TO_CART)
                            || (setProductSKUs!=null && setProductSKUs.size()>1))
                    {
                        whereClause += ' ccrz__SKU__c IN : setProductSKUs';
                    }
                    else
                    {
                        ccrz.ccLog.log(LoggingLevel.DEBUG, 'M:X:product mapParams: ', mapParams);
                        whereClause += ' ccrz__SKU__c LIKE : strSearchQuery ';
                    }
                }
                if(productSearchByIdSKU)
                {
                    whereClause += ' ) AND';
                }
                if(mapParams.containsKey(CC_ERG_Constant.PRODUCT_TYPE))
                {
                    Set<String> setProductType = (Set<String>)mapParams.get(CC_ERG_Constant.PRODUCT_TYPE);
                    whereClause += ' (ccrz__ProductType__c IN : setProductType) AND ';
                }
                String prodFamily = '';
               /* if(mapParams.containsKey(ccErg_Constant.PRODUCT_FAMILY))
                {
                    prodFamily = (String)mapParams.get(ccErg_Constant.PRODUCT_FAMILY);
                    whereClause += ' ( Product_Family__c =: prodFamily AND Source_Product__r.SBQQ__Component__c = false ) AND ';
                }*/
                whereClause += ' (ccrz__ProductStatus__c in : productStatus ) AND  (ccrz__StartDate__c = null OR ccrz__StartDate__c <= TODAY) ' +
                        'AND (ccrz__EndDate__c = null OR ccrz__EndDate__c >= TODAY) AND ccrz__Storefront__c=\''+strStorefrontName+'\' ORDER BY LastModifiedDate DESC LIMIT 500';

                ccrz.ccLog.log(LoggingLevel.DEBUG, 'M:X:product lstProdIds: ', lstProdIds);
                ccrz.ccLog.log(LoggingLevel.DEBUG, 'M:X:product strSearchQuery: ', strSearchQuery);
                ccrz.ccLog.log(LoggingLevel.DEBUG, 'M:X:product Search Query: ', selectQueryFields + whereClause);

                System.debug(' Product strSearchQuery : '+JSON.serialize(selectQueryFields + whereClause));
                mapParams.put(CC_ERG_Constant.PRODUCT_SEARCH_QUERY , selectQueryFields + whereClause);
                List<ccrz__E_Product__c> pList = Database.query(String.valueOf(mapParams.get(CC_ERG_Constant.PRODUCT_SEARCH_QUERY)));
                ccrz.ccLog.log(LoggingLevel.DEBUG, 'M:X:product pList: ', JSON.serialize(pList));
                mapProducts = new Map<Id, ccrz__E_Product__c>(pList);
                mapParams.put(CC_ERG_Constant.PRODUCT_SEARCH_RESULTS , mapProducts);

                Set<String> setProductSKU = new Set<String>();
                Map<String, Object> mapProductSKU = fetchProductSKU(pList);
                for (ccrz__E_Product__c pr : pList)
                {
                    setProductSKU.add(pr.ccrz__SKU__c);
                }
                System.debug(' Product SKU : '+JSON.serialize(mapProductSKU.keySet()));
                mapParams.put(CC_ERG_Constant.PRODUCT_SKU_LIST, mapProductSKU.keySet());
                mapParams.put(CC_ERG_Constant.PRODUCT_SKU_LIST, mapProductSKU.keySet());
                ccrz.ccLog.log(LoggingLevel.DEBUG, 'M:X:product fetching entitlement setProductSKU: ', JSON.serialize(setProductSKU));
                Map<String, ccrz__E_PriceListItem__c> mapEPriceListItemsByStrings = CC_ERG_PricingService.fetchPriceListItemsBySKU(mapParams);
                Map<String, List<ccrz__E_PriceListItem__c>> mapAllEPriceListItemsByStrings = CC_ERG_PricingService.fetchAllPriceListItemsBySKU(mapParams);
System.debug(' mapEPriceListItemsByStrings in helper '+mapEPriceListItemsByStrings);
                Map<String, ccrz__E_ProductMedia__c> productImages = fetchProductImages(mapParams);
               // ccrz.ccLog.log(LoggingLevel.DEBUG, 'M:X:product fetching entitlement mapEPriceListItemsByStrings: ', JSON.serialize(mapEPriceListItemsByStrings));
                mapParams.put(CC_ERG_Constant.PRODUCT_SEARCH_PRICE_LIST_RESULTS , mapEPriceListItemsByStrings);
                mapParams.put(CC_ERG_Constant.PRODUCT_SEARCH_ALL_PRICE_LIST_RESULTS , mapAllEPriceListItemsByStrings);
                mapParams.put(CC_ERG_Constant.PRODUCT_SEARCH_ALL_PRODUCT_IMAGES , productImages);
            }
        } catch (Exception expObject)
        {
            system.debug('Exception in product helper'+expObject.getMessage());
            ccrz.ccLog.log(LoggingLevel.INFO, 'Custom:Exception ', expObject.getStackTraceString() );
            ccrz.ccLog.log(LoggingLevel.INFO, 'Custom::Exception ', expObject.getMessage());
            ccrz.ccLog.log(LoggingLevel.INFO, 'Custom:Exception ', expObject.getLineNumber());
            ccrz.ccLog.log(LoggingLevel.INFO, 'Custom:Exception ', expObject.getTypeName());
            //dcm_CustomException.storeExceptionLog(expObject, STOREFRONT , MODULE_NAME, CLASSNAME , methodName , supportData );
        }
        return mapParams;
    }

   /* global static Set<String> getRelatedProductByType(Map<String, Object> requestMap,String type)
    {
        Set<String> returnSet  =new Set<String>();
        String pSku = '';
        String selectClause = ' SELECT Id,ccrz__RelatedProduct__c,ccrz__RelatedProduct__r.ccrz__SKU__c FROM ccrz__E_RelatedProduct__c ';
        String whereClause = ' WHERE ccrz__RelatedProductType__c=:type AND ccrz__Enabled__c=TRUE AND ccrz__RelatedProduct__r.ccrz__StartDate__c<=TODAY ' +
                                        'AND ccrz__RelatedProduct__r.ccrz__EndDate__c>TODAY AND ccrz__StartDate__c<=TODAY AND ccrz__EndDate__c>TODAY  ';
        if(requestMap.containsKey(ccErg_Constant.PRODUCT_SKU)){
            pSku = (String)requestMap.get(ccErg_Constant.PRODUCT_SKU);
            whereClause += ' AND ccrz__Product__r.ccrz__SKU__c=:pSku ';
        }
        String orderClause = ' ORDER BY ccrz__Sequence__c ASC ';
        for(ccrz__E_RelatedProduct__c rp: Database.query(selectClause+whereClause+orderClause)){
            returnSet.add(rp.ccrz__RelatedProduct__r.ccrz__SKU__c);
        }
        return returnSet;

    } */


    global static Map<String, Object> fetchProductSKU(List<ccrz__E_Product__c> pList) {
        Map<String, Object> mapProductSKU = new Map<String, Object>();
        if(pList!=null && pList.size()>0)
        {
            for(ccrz__E_Product__c ccProduct : pList)
            {
                mapProductSKU.put(ccProduct.ccrz__SKU__c , ccProduct);
                if(ccProduct.ccrz__E_RelatedProducts__r!=null && ccProduct.ccrz__E_RelatedProducts__r.size()>0)
                {
                    List<ccrz__E_RelatedProduct__c> lstRelatedProducts = ccProduct.ccrz__E_RelatedProducts__r;
                    for(ccrz__E_RelatedProduct__c ccRelatedProduct : lstRelatedProducts)
                    {
                        if(ccRelatedProduct.ccrz__RelatedProduct__r!=null)
                        {
                            mapProductSKU.put(ccRelatedProduct.ccrz__RelatedProduct__r.ccrz__SKU__c , ccRelatedProduct.ccrz__RelatedProduct__r);
                        }
                    }
                }
                //ccProduct.ccrz__CompositeProducts__r;
            }
        }
        return mapProductSKU;
    }

    global static Map<String, ccrz__E_ProductMedia__c> fetchProductImages(Map<String,Object> mapRequestParams) {
        Map<String, ccrz__E_ProductMedia__c> mapProductImages = new Map<String, ccrz__E_ProductMedia__c>();
        String strLocale = null;
        if(mapRequestParams!=null && mapRequestParams.size()>0 &&
                mapRequestParams.containsKey(CC_ERG_Constant.PRODUCT_SKU_LIST))
        {
            Set<String> setProductSKU = (Set<String>)mapRequestParams.get(CC_ERG_Constant.PRODUCT_SKU_LIST);
            if(mapRequestParams.containsKey(CC_ERG_Constant.STOREFRONT_LOCALE))
            {
                strLocale = (String)mapRequestParams.get(CC_ERG_Constant.STOREFRONT_LOCALE);
            }else {
                strLocale = CC_ERG_Constant.LOCALE_US;
            }
            List<ccrz__E_ProductMedia__c> lstProductMedias = [SELECT Id,Name,ccrz__URI__c,ccrz__StartDate__c,ccrz__EndDate__c,
                                                            ccrz__Enabled__c,ccrz__Sequence__c,ccrz__ProductMediaId__c,ccrz__FilePath__c,ccrz__Locale__c,
                                                            ccrz__MediaType__c, ccrz__StaticResourceName__c,ccrz__ProductMediaSource__c,ccrz__ProductDescription__c,
                                                            ccrz__Product__r.ccrz__SKU__c
                                                            FROM ccrz__E_ProductMedia__c WHERE ccrz__Product__r.ccrz__SKU__c IN : setProductSKU AND
                                                            ccrz__Enabled__c=TRUE AND ccrz__StartDate__c <= TODAY AND ccrz__EndDate__c>TODAY AND
                                                            ccrz__MediaType__c =:CC_ERG_Constant.PRODUCT_IMAGE_NAME AND ccrz__Locale__c=:strLocale
                                                            ORDER BY ccrz__Sequence__c ASC ];
            if(lstProductMedias!=null && lstProductMedias.size()>0)
            {
                for(ccrz__E_ProductMedia__c ccProductMedia : lstProductMedias)
                {
                    mapProductImages.put(ccProductMedia.ccrz__Product__r.ccrz__SKU__c , ccProductMedia);
                }
            }
        }
        return mapProductImages;
    }

   /* global static Set<String> getAllFeaturedProduct(Map<String, Object> requestMap)
    {
        Set<String> returnSet  =new Set<String>();
        String pSku = '';
        String selectClause = ' SELECT Id,ccrz__Product__c,ccrz__Product__r.ccrz__SKU__c FROM ccrz__E_FeaturedProduct__c ';
        String whereClause = ' WHERE  ccrz__Enabled__c=TRUE AND ccrz__Product__r.ccrz__StartDate__c<=TODAY AND ccrz__Product__r.ccrz__EndDate__c>TODAY  ';
        String orderClause = ' ORDER BY ccrz__Sequence__c ASC ';
        for(ccrz__E_FeaturedProduct__c rp: Database.query(selectClause+whereClause+orderClause)){
            returnSet.add(rp.ccrz__Product__r.ccrz__SKU__c);
        }
        return returnSet;

    }

    global static ccrz__E_Category__c insertRootCategory(){
        String rootCategoryName = getRootCategoryName() ;
        ccrz__E_Category__c rCat = new ccrz__E_Category__c();
        rCat.Name = rootCategoryName;
        rCat.ccrz__CategoryID__c = rootCategoryName;
        rCat.Name = rootCategoryName;
        rCat.ccrz__Sequence__c = 0 ;
        insert rCat ;
        return rCat;
    }

    global static String getRootCategoryName(){
        String rootCategory = ccErg_Utilities.fetchVONConstantValue(ccErg_Constant.B2B_PRODUCT_MODULE , ccErg_Constant.B2B_ROOT_CATEGORY);  //'VONAGE_ROOT' ;
        return rootCategory;
    }
    
    global static ccrz__E_Category__c getParentCategory(){
        String rootCategory = getRootCategoryName() ;
        ccrz__E_Category__c cat;
        List<ccrz__E_Category__c> categoryList = [SELECT Id,Name,ccrz__CategoryID__c,ccrz__Sequence__c FROM ccrz__E_Category__c WHERE ccrz__CategoryID__c=:rootCategory ];
        if(!categoryList.isEmpty()){
            cat = categoryList.get(0);
        }
        return cat;
    }
    
    
    global static ccErg_ProductResponse fetchAllCategory(ccErg_ProductRequest request)
    {
        String storefront = request.storefrontName ;
        String rootCategoryName = getRootCategoryName() ;
        ccErg_ProductResponse productResponse = new ccErg_ProductResponse();
        productResponse.success = false;
        productResponse.message = 'error';
        
        String selectClause = ' SELECT Id, Name, ccrz__CategoryID__c, ccrz__ChildCategoryCount__c, ccrz__DataId__c, ccrz__EndDate__c, ccrz__LongDescRT__c, ' +
                                        'ccrz__LongDesc__c, ccrz__ParentCategory__c, ccrz__SEOId__c, ccrz__Sequence__c, ccrz__ShortDescRT__c, ccrz__ShortDesc__c, ' +
                                        'ccrz__StartDate__c, ccrz__ProductCount__c FROM ccrz__E_Category__c ';
        String whereClause = ' WHERE ccrz__StartDate__c <= TODAY AND ccrz__EndDate__c>TODAY AND ccrz__ParentCategory__r.Name=:rootCategoryName ';
        String orderClause = ' ORDER BY ccrz__Sequence__c ASC ';
        List<ccErg_ProductResponse.B2BCategories> catList = new List<ccErg_ProductResponse.B2BCategories>();
        for(ccrz__E_Category__c cat : Database.query(selectClause+whereClause+orderClause)){
            ccErg_ProductResponse.B2BCategories b2bCat = new ccErg_ProductResponse.B2BCategories();
            b2bCat.name = cat.Name;
            b2bCat.categoryId = cat.Id ;
            catList.add(b2bCat);
        }                              
        if(!catList.isEmpty()){
            productResponse.categories = catList ;
            productResponse.success = true;
            productResponse.message = 'Success';
        }
        return productResponse;
    }

    global static ccErg_ProductResponse fetchAllSpecsBasedOnCategories(ccErg_ProductRequest request)
    {
        ccErg_ProductResponse productResponse = new ccErg_ProductResponse();
        productResponse.success = false;
        productResponse.message = 'error';
        String storefront = request.storefrontName ;
        System.debug('Ammy=>'+request.specType);
        List<String> selectedCategories = request.specType ;
        Set<String> catogoryProductSet = fetchProductInCatgory(selectedCategories);
        System.debug('Vannnn=>'+catogoryProductSet);
        List<ccErg_ProductResponse.B2BSpecs> specList = fetchSpecFromProductSpec(catogoryProductSet);
        if(!specList.isEmpty()){
            productResponse.specs = specList ;
            productResponse.success = true;
            productResponse.message = 'Success';
        }
        return productResponse;
    }

    global static Set<String> fetchProductInCatgory(List<String> selectedCategories ){
        Set<String> returnSet  = new Set<String>();
        String rootCategoryName = getRootCategoryName() ;
        String selectClause = ' SELECT '+PRODUCT_CATEGORIES_FIELDS+' FROM ccrz__E_ProductCategory__c ';
        String whereClause = ' WHERE ccrz__Category__r.ccrz__StartDate__c <= TODAY AND ccrz__Category__r.ccrz__EndDate__c>TODAY AND ccrz__Category__r.ccrz__ParentCategory__r.Name=:rootCategoryName AND ccrz__Category__r.Name IN:selectedCategories  ';
        String orderClause = ' ORDER BY ccrz__Category__r.ccrz__Sequence__c ASC ';
        for(ccrz__E_ProductCategory__c pcat : Database.query(selectClause+whereClause+orderClause)){
            returnSet.add(pcat.ccrz__Product__c);
        }
        return returnSet;
    }
    global static List<ccErg_ProductResponse.B2BSpecs> fetchSpecFromProductSpec(Set<String> productIdSet ){
        List<ccErg_ProductResponse.B2BSpecs>  returnList  = new List<ccErg_ProductResponse.B2BSpecs>();
        String rootCategoryName = getRootCategoryName() ;
        String selectClause = ' SELECT '+PRODUCT_SPECS_FIELDS+' FROM ccrz__E_ProductSpec__c ';
        String whereClause = ' WHERE ccrz__Product__c IN :productIdSet ';
        String orderClause = ' ORDER BY ccrz__Spec__r.ccrz__Sequence__c ASC ';
        Set<String> existingSpecSet = new Set<String>();
        for(ccrz__E_ProductSpec__c pcat : Database.query(selectClause+whereClause+orderClause)){
            if(!existingSpecSet.contains(pcat.ccrz__Spec__r.Name)){
                ccErg_ProductResponse.B2BSpecs b2BSpecs = new ccErg_ProductResponse.B2BSpecs();
                b2BSpecs.specId = pcat.Id;
                b2BSpecs.name = pcat.ccrz__Spec__r.Name;
                b2BSpecs.locale = pcat.ccrz__Spec__r.ccrz__Locale__c;
                returnList.add(b2BSpecs);
                existingSpecSet.add(pcat.ccrz__Spec__r.Name);
            }
        }
        return returnList;
    }

    /*
    global static Set<String> fetchcategoryInProductCatgory(){
        Set<String> returnSet  = new Set<String>();
        String rootCategory = 'VONAGE_ROOT' ;
        String selectClause = ' SELECT '+PRODUCT_CATEGORIES_FIELDS+' FROM ccrz__E_ProductCategory__c ';
        String whereClause = ' WHERE ccrz__Category__r.ccrz__StartDate__c <= TODAY AND ccrz__Category__r.ccrz__EndDate__c>TODAY AND ccrz__Category__r.ccrz__ParentCategory__r.Name=:rootCategoryName AND ccrz__Category__r.Name IN:selectedCategories  ';
        String orderClause = ' ORDER BY ccrz__Category__r.ccrz__Sequence__c ASC ';
        for(ccrz__E_ProductCategory__c pcat : database.query(selectClause+whereClause+orderClause)){
            returnSet.add(pcat.ccrz__Product__c);
        }
        return returnSet;
    }
    */

    
   /* global static ccrz__E_CompositeProduct__c prepareCCCompositeProduct(ccrz__E_Product__c ccChildProd,SBQQ__ProductOption__c pOption,ccrz__E_Product__c ccProd){
        ccrz__E_CompositeProduct__c comProduct = new ccrz__E_CompositeProduct__c();
        comProduct.ccrz__Composite__c = ccProd.Id ;
        comProduct.ccrz__Quantity__c =  pOption.SBQQ__Quantity__c;
        comProduct.ccrz__Component__c = ccChildProd.Id ;
        comProduct.ccrz__Sequence__c = pOption.SBQQ__Number__c ;
        comProduct.ccrz__CompositeProductId__c = comProduct.ccrz__Composite__c+'_'+comProduct.ccrz__Component__c ;
        return comProduct;
    }

    global static ccrz__E_RelatedProduct__c prepareCCRelatedProduct(ccrz__E_Product__c ccChildProd,SBQQ__ProductOption__c pOption,ccrz__E_Product__c ccProd,String type){
        ccrz__E_RelatedProduct__c relProduct = new ccrz__E_RelatedProduct__c();
        relProduct.ccrz__Product__c =  ccProd.Id;
        relProduct.ccrz__RelatedProductType__c = type ;
        relProduct.ccrz__Sequence__c = pOption!=null?pOption.SBQQ__Number__c : 1000 ;      
        relProduct.ccrz__RelatedProduct__c = ccChildProd.Id ;
        if(pOption!=null){
            relProduct.Max_Quantity__c = pOption.SBQQ__MaxQuantity__c ;
            relProduct.Min_Quantity__c = pOption.SBQQ__MinQuantity__c ;
        }
        relProduct.ccrz__RelatedProductId__c = relProduct.ccrz__Product__c+'_'+relProduct.ccrz__RelatedProduct__c+'_'+relProduct.ccrz__RelatedProductType__c ;

        return relProduct;
    }

    global static void rebuildProductIndexed()
    {
        Map<String,Object> mapScopeValue = new Map<String, Object> {
                ccrz.ccProductIndexBuilder.NUMBER_OF_SCOPE_KEY_PAIRS => 5,
                ccrz.ccProductIndexBuilder.IS_FULL_REFRESH => false
        };
        Map<Integer, Map<String, String>> mapIntegerScopeResults =  ccrz.ccProductIndexBuilder.getBatchScopeValues(mapScopeValue);
        if(mapIntegerScopeResults!=null && mapIntegerScopeResults.size()>0)
        {
            for(Integer startPoint : mapIntegerScopeResults.keySet())
            {
                Map<String,Object> mapScopeResults = new Map<String,Object>();
                Map<String,String> mapScopedProductIds = mapIntegerScopeResults.get(startPoint);
                for(String strScopedKey : mapScopedProductIds.keySet())
                {
                    mapScopeResults.put(strScopedKey , mapScopedProductIds.get(strScopedKey));
                }
                Map<String,Object> mapCleanAndBuildInput = new Map<String, Object> {
                        ccrz.ccAPIProductIndex.CLEAN_ONLY => false,
                        ccrz.ccProductIndexBuilder.BATCH_JOB_PRODUCT_SCOPE => mapScopeResults
                };
                ccrz.ccProductIndexBuilder.cleanAndBuild(mapCleanAndBuildInput);
            }
        }
    }

    global static   ccrz__E_ProductMedia__c createCCProductMedia(Product2 product,ccrz__E_Product__c ccProd,String type,String imgUrl){
        ccrz__E_ProductMedia__c prodMedia = new ccrz__E_ProductMedia__c();
        prodMedia.ccrz__Product__c = ccProd.Id ;
        prodMedia.ccrz__Locale__c = 'en_US' ;
        prodMedia.ccrz__Enabled__c = true ;
        prodMedia.ccrz__MediaType__c = type ;
        prodMedia.ccrz__ProductDescription__c = URL.getSalesforceBaseUrl().toExternalForm()+imgUrl ;
        prodMedia.ccrz__ProductMediaId__c = product.Id+'_'+ccProd.Id+'_'+type.replace(' ','_');
        return prodMedia;
    }

    global static String getDocumentUrl(){
       String url = '';
       String devName = ccErg_Utilities.fetchVONConstantValue(ccErg_Constant.B2B_PRODUCT_MODULE , ccErg_Constant.DEFAULT_IMG_NAME);
       List<Document> documentList = [SELECT Id FROM Document where DeveloperName=:devName LIMIT 1];
       if(!documentList.isEmpty()){
        Document doc = documentList.get(0);
        url = '/servlet/servlet.ImageServer?id='+doc.Id+'&oid='+UserInfo.getOrganizationId() ;
       }
       return url;
    }*/


}