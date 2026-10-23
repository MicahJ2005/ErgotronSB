/*
  @description       : Controller for Stripe payment page
  @author            : R1
  @last modified on  : 25-04-2025
  @last modified by  : 
  Modifications Log 
  Ver   Date         Author         Modification

*/
global class PaymentController {
    public static final String CUSTOMERS = 'customers';
    public static final String PAYMENT_INTENTS = 'payment_intents';
    public static final String PAYMENT_METHODS = 'payment_methods';
    public static final String CAPTURE = 'capture';
    public static final String STRIPE_MODULE_SANDBOX = 'Stripe_SB';
    public static final String STRIPE_MODULE_PRODUCTION = 'Stripe_PROD';
    public static Payment_Gateway_Configuration__mdt paymentGateway;
    
    /**
     * @description Handles the initial call for creating customer account in Stripe
     * @param cartEncryptedId String
     * @return Map<String,Object>
    **/
	@RemoteAction
    global static Map<String,Object> setupStripeTransaction(String cartEncryptedId)
    {
        Map<String,Object> respMap = new Map<String,Object>();
        try{
            Nebula.logger.info('Customer/Account Stripe API callout');
            respMap.put('success',true);            
            Map<String, Object> custReqMap = new Map<String, Object>();
            paymentGateway = getPaymentGateway();
            respMap.put('publicKey',paymentGateway.PUBLIC_KEY__c);
            String recordIdToUpdate;
            if(!ccrz.cc_callContext.isGuest){
                String userId = ccrz.cc_callContext.currUserId;
                Nebula.logger.info('User Id: '+userId);
                Nebula.logger.info('cartEncryptedId: '+cartEncryptedId);
                User user = [SELECT Name,Email,AccountId,ContactId,Contact.Stripe_Customer_Id__c FROM User WHERE Id =:userId];
                String descr = 'SF User: '+user.Name +' ('+userId+')';
                if(String.isNotBlank(user.Contact.Stripe_Customer_Id__c)){
                    respMap.put('id',user.Contact.Stripe_Customer_Id__c);
                    respMap.put('PaymentIntent',createPaymentIntent(user.Contact.Stripe_Customer_Id__c,cartEncryptedId));
                    return respMap;
                }
                descr += ', Account Id: '+user.AccountId;
                custReqMap.put('name',EncodingUtil.urlEncode(user.Name, 'UTF-8'));
                custReqMap.put('email',EncodingUtil.urlEncode(user.Email, 'UTF-8'));
                custReqMap.put('description',EncodingUtil.urlEncode(descr, 'UTF-8'));
                recordIdToUpdate = user.ContactId;
            }
            else{
                ccrz__E_Cart__c cart = [SELECT Id,ccrz__TotalAmount__c,ccrz__CurrencyISOCode__c,ccrz__Account__c,
                                        Stripe_Guest_Customer_Id__c,ccrz__BuyerFirstName__c,ccrz__BuyerLastName__c,
                                        ccrz__BuyerEmail__c
                                    	FROM ccrz__E_Cart__c WHERE ccrz__EncryptedId__c = :cartEncryptedId LIMIT 1];
                if(String.isNotBlank(cart.Stripe_Guest_Customer_Id__c)){
                    respMap.put('id',cart.Stripe_Guest_Customer_Id__c);
                    respMap.put('PaymentIntent',createPaymentIntent(cart.Stripe_Guest_Customer_Id__c,cartEncryptedId));
                    return respMap;
                }
                String descr = cart.ccrz__BuyerEmail__c;
                custReqMap.put('name',EncodingUtil.urlEncode(cart.ccrz__BuyerFirstName__c+' '+cart.ccrz__BuyerLastName__c, 'UTF-8'));
                custReqMap.put('email',EncodingUtil.urlEncode(cart.ccrz__BuyerEmail__c,'UTF-8'));
                custReqMap.put('description',EncodingUtil.urlEncode(descr,'UTF-8'));
                recordIdToUpdate = cart.Id;
            }
            String authorizationHeader = 'Bearer '+paymentGateway.API_KEY__c;
            String stripeEndpoint = paymentGateway.ENDPOINT_URL__c+CUSTOMERS;
            String requestBody = prepareRequestFromMap(custReqMap);
            
            HttpResponse httpRes = new HttpResponse();
            httpRes = stripeRestAPICall(stripeEndpoint,authorizationHeader,requestBody,'POST');
            Nebula.logger.info('Customer/Account Stripe API Response : '+httpRes.getBody());
            Nebula.logger.info('API Status Code: '+httpRes.getStatusCode());
            respMap = (Map<String, Object>) JSON.deserializeUntyped( httpRes.getBody() );
            if(httpRes.getStatusCode()==200){
                if(respMap.get('id')!=null){
                    respMap.put('PaymentIntent',createPaymentIntent(String.valueOf(respMap.get('id')),cartEncryptedId));
                    if(!ccrz.cc_callContext.isGuest){
                        update new Contact(Id=recordIdToUpdate,Stripe_Customer_Id__c = String.valueOf(respMap.get('id')));
                    }
                    else{
                        update new ccrz__E_Cart__c(Id = recordIdToUpdate, Stripe_Guest_Customer_Id__c = String.valueOf(respMap.get('id')));
                    }
                }
                respMap.put('success',true);
            }
            else{
                respMap.put('success',false);
                Nebula.logger.error('Error: '+httpRes.getBody());
                Nebula.logger.saveLog();
            }
    	}
        catch(Exception ex){
            respMap.put('success',false);
            Nebula.logger.error(ex.getMessage() + ' ' + ex.getStackTraceString());
			Nebula.logger.saveLog();
    	}
    	return respMap;
    }
    
    /**
     * @description Logs error in the Authorization stage where User enters their card info
     * @param encryptedCartId String
     * @param response String
     * @return Map<String,Object>
    **/
    @RemoteAction
    global static Map<String,Object> logStripePMError(String encryptedCartId,String response){
        Map<String,Object> outputMap = new Map<String,Object>();
        ccrz__E_Cart__c cart = [SELECT Id FROM ccrz__E_Cart__c WHERE ccrz__EncryptedId__c = :encryptedCartId LIMIT 1];
        Nebula.logger.error('Stripe Payment Method Error Cart Id: '+cart.Id);
        Nebula.logger.error('Response: '+response);
        Nebula.logger.saveLog();
        outputMap.put('success',true);
        return outputMap;
    }
    
    /**
     * @description Handles the callout for creation of payment intent (Authorization)
     * @param customerId String
     * @param cartEncryptedId String
     * @return Map<String,Object>
    **/
    public static Map<String,Object> createPaymentIntent(String customerId, String encryptedCartId)
    {
        Map<String,Object> respMap = new Map<String,Object>();
        try{
            Nebula.logger.info('Stripe Payment Intent API Callout');
            Nebula.logger.info('Stripe Customer Id: '+customerId);
            Nebula.logger.info('EncryptedCartId: '+encryptedCartId);
            ccrz__E_Cart__c cart = [SELECT Id,ccrz__TotalAmount__c,ccrz__CurrencyISOCode__c,ccrz__Account__c 
                                    FROM ccrz__E_Cart__c WHERE ccrz__EncryptedId__c = :encryptedCartId LIMIT 1];
            String authorizationHeader = 'Bearer '+paymentGateway.API_KEY__c;
            String stripeEndpoint = paymentGateway.ENDPOINT_URL__c+PAYMENT_INTENTS;
            Map<String,Object> piReqMap = new Map<String,Object>();
            String descri = 'Cart Id: '+cart.Id;
            Nebula.logger.info('CartId: '+cart.Id);
            Integer chargeAmount = Integer.valueOf(cart.ccrz__TotalAmount__c*100); //Stripe accepting in cents
            piReqMap.put('amount', chargeAmount);
            piReqMap.put('description', descri);
            piReqMap.put('currency', String.valueOf(cart.ccrz__CurrencyISOCode__c));
            piReqMap.put('customer',customerId);
            piReqMap.put('capture_method','manual'); //for authentication and not capture
            String requestBody = prepareRequestFromMap(piReqMap);
            HttpResponse resp = new HttpResponse();
            resp = stripeRestAPICall(stripeEndpoint,authorizationHeader,requestBody,'POST');
            Nebula.logger.info('API Status Code: '+resp.getStatusCode());
            respMap = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
            if(resp.getStatusCode() == 200)
            {
                Nebula.logger.info('Stripe Payment Intent API Response: '+resp.getBody());
                if(respMap.containsKey('id') && respMap.get('id')!=null){
                    respMap.put('success',true);            
                    update new ccrz__E_Cart__c(Id=cart.Id,Payment_Reference__c = String.valueOf(respMap.get('id')));
                }
            }else
            {
                 Nebula.logger.error('Stripe Payment Intent API Response: '+resp.getBody());
                 respMap.put('success',false);            
                 Nebula.logger.saveLog();
            }
        }
        catch(Exception ex){
            respMap.put('success',false);            
            Nebula.logger.error(ex.getMessage() + ' ' + ex.getStackTraceString());
            Nebula.logger.saveLog();
        }
        return respMap;
    }
    
    /**
     * @description Method for fetching public key
     * @return Map<String,Object>
    **/
    @RemoteAction
    global static Map<String,Object> getPublicKey(){
        Map<String,Object> response = new Map<String,Object>();
        paymentGateway = getPaymentGateway();
        response.put('success',true);
        response.put('publicKey',paymentGateway.PUBLIC_KEY__c);
        return response;
    }
    
    
    /**
     * @description Util method for preparing request for Stripe callout
     * @param input Map<String,Object>
     * @return Map<String,Object>
    **/
    public static string prepareRequestFromMap(Map<String,Object> input)
    {
        String resp='';
        for(String key: input.keySet())
        {
            if(resp != null && resp !='')
                resp+='&';
            resp = resp + key +'='+input.get(key);
        }
        Nebula.logger.info('Payload: '+resp);
        return resp;
    }
    
    
    /**
     * @description Invocable method for capturing paymnt
     * @param orderIds List<String>
    **/
    @InvocableMethod(label='Capture Stripe Payment' description='Run capture for authorized payment' category='Apex')
    public static void capturePayment(List<String> orderIds){
        String orderId;
        String paymentIntentId;
        try{
            paymentGateway = getPaymentGateway();
            orderId = orderIds[0];
            Nebula.logger.info('orderId: '+orderId);
            ccrz__E_Order__c order = [SELECT Id,Stripe_Payment_Status__c,Payment_Reference__c,ccrz__Contact__c,ccrz__Account__c,ccrz__User__c,ccrz__TotalAmount__c 
                                      FROM ccrz__E_Order__c WHERE Id = :orderId LIMIT 1];
            paymentIntentId = order.Payment_Reference__c;
            Nebula.logger.info('Payment Reference: '+paymentIntentId);
            String authorizationHeader = 'Bearer '+paymentGateway.API_KEY__c;
            String stripeEndpoint = paymentGateway.ENDPOINT_URL__c + PAYMENT_INTENTS +'/' + paymentIntentId + '/'+CAPTURE;
            Map<String,Object> chargeMap = new Map<String,Object>();
            Integer chargeAmount = Integer.valueOf(order.ccrz__TotalAmount__c*100); //Stripe accepting in cents
            chargeMap.put('amount_to_capture', chargeAmount);
            if(String.isNotBlank(paymentIntentId)){
                HttpResponse resp = new HttpResponse();
                resp = stripeRestAPICall(stripeEndpoint,authorizationHeader,prepareRequestFromMap(chargeMap),'POST');
                Map<String,Object> respBody = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
                if(resp.getStatusCode()==200){
                    ccrz__E_TransactionPayment__c newTransact = new ccrz__E_TransactionPayment__c();
                    newTransact.ccrz__Storefront__c = 'DefaultStore';
                    newTransact.ccrz__CCOrder__c = orderId;
                    newTransact.ccrz__AccountType__c = 'Credit Card';
                    newTransact.ccrz__Contact__c = order.ccrz__Contact__c;
                    newTransact.ccrz__Account__c = order.ccrz__Account__c;
                    newTransact.ccrz__User__c = order.ccrz__User__c;
                    newTransact.ccrz__Amount__c = Decimal.valueOf(Integer.valueOf(respBody.get('amount'))) / 100;
                    insert newTransact;
                    update new ccrz__E_Order__c(Id = orderId,Stripe_Payment_Status__c='Captured');
                }
                else{
                    Nebula.logger.Error('Response during Capture API callout: '+resp.getBody());
                    Nebula.logger.saveLog();
                    Map<String, Object> errorMap = (Map<String, Object>)respBody.get('error');
                    if (errorMap != null) {
                        Map<String, Object> paymentIntent = (Map<String, Object>)errorMap.get('payment_intent');
                        if (paymentIntent != null && String.valueOf(paymentIntent.get('status')) == 'canceled') {
                            update new ccrz__E_Order__c(Id = orderId, Stripe_Payment_Status__c = 'Cancelled');
                        } else {
                            update new ccrz__E_Order__c(Id = orderId, Stripe_Payment_Status__c = 'Payment Failed');
                        }
                    } else {
                        update new ccrz__E_Order__c(Id = orderId, Stripe_Payment_Status__c = 'Payment Failed');
                    }
                    
                }
            }
        }
        catch(Exception ex){
            Nebula.logger.error(ex.getMessage() + ' ' + ex.getStackTraceString());
            Nebula.logger.info('Payment Type: Credit Card');
            Nebula.logger.info('Payment Intent: '+paymentIntentId);
            Nebula.logger.info('Order Id: '+orderId);
            Nebula.logger.saveLog();
        }
    }
    
    /**
     * @description Utility method to get PaymentGateway details
     * @return Payment_Gateway_Configuration__mdt
    **/
    public static Payment_Gateway_Configuration__mdt getPaymentGateway(){
        if(paymentGateway==null){
            Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            String masterLabel = IsSandbox ? STRIPE_MODULE_SANDBOX : STRIPE_MODULE_PRODUCTION;
            paymentGateway = [SELECT MasterLabel,API_KEY__c,ENDPOINT_URL__c,PUBLIC_KEY__c,STOREFRONT__c
                              FROM Payment_Gateway_Configuration__mdt WHERE MasterLabel = :masterLabel];
        }
        return paymentGateway;
    }
    
    /**
     * @description Generic method for HTTP Callouts
     * @param stripeEndpoint String
     * @param authorizationHeader String
     * @param requestBody String
     * @param method String
     * @return HttpResponse
    **/
    public static HttpResponse stripeRestAPICall(String stripeEndpoint, 
                                                 String authorizationHeader,
                                                 String requestBody,
                                                 String method
                                                )
    {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        req.setEndpoint(stripeEndpoint);
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setMethod(method);
        req.setBody(requestBody);
        req.setTimeout(40000);
        
        return http.send(req);
    }
}