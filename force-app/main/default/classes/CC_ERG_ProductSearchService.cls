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
@RestResource(UrlMapping='/v1/fetchProductBySKU')
global without sharing class CC_ERG_ProductSearchService {
    
    global static final String STOREFRONT = 'DefaultStore';
    global static final String MODULE_NAME = 'Product Module';
    global static final String CLASSNAME = 'ccErgProductSearchService';

    @HttpPost
    global static void processRequest(CC_ERG_ProductRequest productRequest) {
        CC_ERG_ProductResponse productResponse = new CC_ERG_ProductResponse();
        RestResponse response = RestContext.response;
        String methodName = 'processRequest';
        String supportData = '';
        try
        {
            supportData +='Rest Request : '+productRequest;
            System.debug('request : '+productRequest);
            if(CC_ERG_ErrorHandling.checkRequestParamsFetchAllProdCat(productRequest) != null && CC_ERG_ErrorHandling.checkRequestParamsFetchAllProdCat(productRequest) != 'Success')
            {
                System.debug('Validate');
                RestContext.response.addHeader('Content-Type', 'application/json');
                response.responseBody = Blob.valueOf(CC_ERG_ErrorHandling.checkRequestParamsFetchAllProdCat(productRequest));
                response.statusCode = 200;
            }
            if(CC_ERG_ErrorHandling.checkRequestParamsFetchAllProdCat(productRequest) != null && CC_ERG_ErrorHandling.checkRequestParamsFetchAllProdCat(productRequest) == 'Success')
            {
                System.debug('Non-Validate');
                productResponse = fetchProductBySKU(productRequest);
            }
            
            if (!Test.isRunningTest() && CC_ERG_ErrorHandling.checkRequestParamsFetchAllProdCat(productRequest) == 'Success')
            {
                system.debug('in success if');
                RestContext.response.addHeader('Content-Type', 'application/json');
                response.responseBody = Blob.valueOf(JSON.serialize(productResponse, true));
                response.statusCode = 200;
                system.debug('after response');
            }
        }catch (Exception expObject)
        {
            response.statusCode = 500;
            response.responseBody = Blob.valueOf(JSON.serialize(expObject.getStackTraceString() + expObject.getMessage()));
          //  dcm_CustomException.storeExceptionLog(expObject, STOREFRONT, MODULE_NAME, CLASSNAME, methodName, supportData);
        }finally{
           // dcm_ApplicationLogs.captureApplicationLogs(STOREFRONT+' - '+MODULE_NAME,String.valueOf(productRequest),JSON.serialize(productResponse, true),supportData,'');
        }
    }

    global static CC_ERG_ProductResponse fetchProductBySKU(CC_ERG_ProductRequest request)
    {
        CC_ERG_ProductResponse productResponse = new CC_ERG_ProductResponse();
        if(request!=null)
        {
            Map<String, Object> mapRequestParams = new Map<String, Object>();
            mapRequestParams.put(CC_ERG_Constant.STOREFRONT_NAME, request.storefrontName);
            mapRequestParams.put(CC_ERG_Constant.STOREFRONT_CURRENCY, request.userCurrency);
            mapRequestParams.put(CC_ERG_Constant.PRICE_LIST_NAME,'US LIST PRICE PRICE LIST');
            mapRequestParams.put(CC_ERG_Constant.BASE_PRICE_LIST_NAME, 'US Non-Standard');
            mapRequestParams.put(CC_ERG_Constant.STOREFRONT_LOCALE, request.locale);
            mapRequestParams.put(CC_ERG_Constant.PRODUCT_SEARCH_STRING, new Set<String>{request.sku});
            Integer qty = 1;
            if(request.quantity != null && request.quantity > 0){
                qty = request.quantity;
            }
            mapRequestParams.put(CC_ERG_Constant.PRODUCT_QTY, qty);
            productResponse = CC_ERG_ProductManager.fetchProductsService(mapRequestParams);
            system.debug('**** productResponse'+productResponse);
        }
        return productResponse;
    }
    
    
   

}