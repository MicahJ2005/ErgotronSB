/**
 * @description       : 
 * @author            : Raziya Gurramkonda
 * @group             : 
 * @last modified on  : 11-11-2020
 * @last modified by  : Raziya Gurramkonda
 * Modifications Log 
 * Ver   Date         Author               Modification
 * 1.0   11-11-2020   Raziya Gurramkonda   Initial Version
**/
@RestResource(UrlMapping='/v1/addToCart')
global class CC_ERG_AddToCartService {
    
    global static final String STOREFRONT = 'DefaultStore';
    global static final String MODULE_NAME = 'Cart Module';
    global static final String CLASSNAME = 'CC_ERG_AddToCartService';

    @HttpPost
    global static void addToCart(CC_ERG_CartRequest cartRequest) {
        CC_ERG_CartModel cartModel = new CC_ERG_CartModel();
        RestResponse response = RestContext.response;
        String methodName = 'addToCart';
        String supportData = '';
        try
        {
            if(cartRequest!=null)
            {
                supportData += 'Rest Request : ' + cartRequest;
                supportData = 'Request Body :  ' + JSON.serialize(cartRequest);
                cartModel = processAddToCart(cartRequest);
                System.debug(' to return ==> '+ cartModel);
                if (!Test.isRunningTest() && cartModel!=null)
                {
                    RestContext.response.addHeader(CC_ERG_Constant.HTTP_CONTENT_TYPE, CC_ERG_Constant.HTTP_CONTENT_APP_JSON);
                    response.responseBody = Blob.valueOf(JSON.serialize(cartModel, true));
                    response.statusCode = 200;
                }
            }
        }catch (Exception expObject)
        {
            response.statusCode = 500;
            response.responseBody = Blob.valueOf(JSON.serialize(expObject.getStackTraceString() + expObject.getMessage()));
            ccErg_DCM_CustomException.storeExceptionLog(expObject, STOREFRONT, MODULE_NAME, CLASSNAME, methodName, supportData);
        } finally {
            Api_Log__c apiLog = new Api_Log__c();
            if(JSON.serialize(cartRequest)?.length() > 130700) {
                apiLog.Request_Body__c = JSON.serialize(cartRequest).substring(0, 130695);
            } else {
                apiLog.Request_Body__c = JSON.serialize(cartRequest);
            }
            if(JSON.serialize(cartModel, true)?.length() > 130700) {
                apiLog.Response_Body__c = JSON.serialize(cartModel, true).substring(0, 130695);
            } else {
                apiLog.Response_Body__c = JSON.serialize(cartModel, true);
            }
            if(cartRequest!=null){
                apiLog.Request_CartID__c = cartRequest.cartId;
            }
            if(cartModel!=null) {
                apiLog.Response_CartID__c = cartModel.cartId;
            }
            apiLog.Api_Endpoint_Name__c = 'addToCart';
            insert apiLog;
        }
    }

    global static CC_ERG_CartModel processAddToCart(CC_ERG_CartRequest cartRequest)
    {
        CC_ERG_CartModel cartModelObject = new CC_ERG_CartModel();
        cartModelObject =  CC_ERG_CartManager.processAddToCart(cartRequest);
        return cartModelObject;
    }

}