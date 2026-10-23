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
@RestResource(UrlMapping='/v1/fetchProducts')
global without sharing class CC_ERG_FetchProduct {
    
     global static final String STOREFRONT = 'DefaultStore';
    global static final String MODULE_NAME = 'Product Module';
    global static final String CLASSNAME = 'CC_ERG_FetchProduct';
    @HttpPost
    global static void processRequest(CC_ERG_ProductRequest productRequest) {
        CC_ERG_ProductResponse productResponse = new CC_ERG_ProductResponse();
        RestResponse response = RestContext.response;
        String methodName = 'processFile';
        String supportData = '';
        try
        {
            supportData +='Rest Request : '+productRequest;
            System.debug('request : '+productRequest);
            if(CC_ERG_ErrorHandling.checkRequestParamsFetchAllProds(productRequest) != null && CC_ERG_ErrorHandling.checkRequestParamsFetchAllProds(productRequest) != 'Success')
            {
                System.debug('Validate');
                RestContext.response.addHeader('Content-Type', 'application/json');
                response.responseBody = Blob.valueOf(CC_ERG_ErrorHandling.checkRequestParamsFetchAllProds(productRequest));
                response.statusCode = 200;
            }
            if(CC_ERG_ErrorHandling.checkRequestParamsFetchAllProds(productRequest) != null && CC_ERG_ErrorHandling.checkRequestParamsFetchAllProds(productRequest) == 'Success')
            {
                System.debug('Non-Validate');
                productResponse = fetchAllProducts(productRequest);
            }
            
            if (!Test.isRunningTest() && CC_ERG_ErrorHandling.checkRequestParamsFetchAllProds(productRequest) == 'Success')
            {
                RestContext.response.addHeader('Content-Type', 'application/json');
                response.responseBody = Blob.valueOf(JSON.serialize(productResponse, true));
                response.statusCode = 200;
            }
        }catch (Exception expObject)
        {
            response.statusCode = 500;
            response.responseBody = Blob.valueOf(JSON.serialize(expObject.getStackTraceString() + expObject.getMessage()));
           // dcm_CustomException.storeExceptionLog(expObject, STOREFRONT, MODULE_NAME, CLASSNAME, methodName, supportData);
        }finally{
          //  dcm_ApplicationLogs.captureApplicationLogs(STOREFRONT+' - '+MODULE_NAME,String.valueOf(productRequest),JSON.serialize(productResponse, true),supportData,'');
        }
    }

    global static CC_ERG_ProductResponse fetchAllProducts(CC_ERG_ProductRequest request)
    {
        CC_ERG_ProductResponse productResponse = new CC_ERG_ProductResponse();
        if(request!=null)
        {
            Map<String, Object> mapRequesttParams = new Map<String, Object>();
            mapRequesttParams.put(CC_ERG_Constant.STOREFRONT_NAME, request.storefrontName);
            mapRequesttParams.put(CC_ERG_Constant.STOREFRONT_CURRENCY, request.userCurrency);
            mapRequesttParams.put(CC_ERG_Constant.STOREFRONT_LOCALE, request.locale);
            Set<String> setProductType = new Set<String>();
            setProductType.add(CC_ERG_Constant.PRODUCT_TYPE_BUNDLED);
            String currentPriceList = CustomMetadataUtility.fetchCurrentPriceListName();
            if(currentPriceList != null) {
                mapRequesttParams.put(CC_ERG_Constant.PRICE_LIST_NAME, currentPriceList); // use current price list
            }

            String basePriceList = CustomMetadataUtility.fetchBasePriceListName();
            if(basePriceList != null) {
                mapRequesttParams.put(CC_ERG_Constant.BASE_PRICE_LIST_NAME, basePriceList); // use base price list
            }
           // mapRequesttParams.put(CC_ERG_Constant.PRODUCT_TYPE, setProductType);
            Integer qty = 1;
            if(request.quantity != null && request.quantity > 0){
                qty = request.quantity;
            }
            mapRequesttParams.put(CC_ERG_Constant.PRODUCT_QTY, qty);
            productResponse = CC_ERG_ProductManager.fetchProductsService(mapRequesttParams);
        }
        return productResponse;
    }

}