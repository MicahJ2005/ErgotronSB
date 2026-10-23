/**
 * @description       : 
 * @author            : Nandika Sharma
 * @group             : Docmation LLC
 * @last modified on  : 07-19-2022
**/
public without sharing class ERGB2B_CreateOrderBatch implements Database.Batchable<sObject>, Schedulable,Database.Stateful,database.allowscallouts {
    
    public String cartId{get;set;}
    public Integer lastModifiedDate {get;set;}
    public Integer retryCount{get;set;}
    public Integer lastModifiedTime{get;set;}

    List<String> successOrderList = new List<String>();
    public List<ccrz__E_Cart__c> failedCartList = new List<ccrz__E_Cart__c>(); 
    public Map<String,String> errMsgMap = new Map<String,String>();


    public void execute(SchedulableContext sc) {
        ERGB2B_CreateOrderBatch batch = new ERGB2B_CreateOrderBatch();
        Database.executeBatch(batch,1);
    }



    public Database.QueryLocator start(Database.BatchableContext bc){
        String source = 'Ergotron';
        String openStatus = 'Open';
        String drStatus = 'Successful';
        Set<Id> notInCartIds = new Set<Id>();
        lastModifiedDate =(Integer) B2B_Constants__mdt.getInstance('B2B_Constant').query_last_modified_date__c ;
        lastModifiedTime = (Integer) B2B_Constants__mdt.getInstance('B2B_Constant'). query_last_modified_time__c ; 
        retryCount =(Integer) B2B_Constants__mdt.getInstance('B2B_Constant').Create_Order_Process_Retry_Count__c ;
        retryCount = retryCount == null ? 1: retryCount;
        for(ERG_Data_Fix_Log__c eg : [SELECT Refernce_Id__c FROM ERG_Data_Fix_Log__c WHERE Reference_Object__c='Cart' AND Refernce_Id__c!=null  AND Status__c='Failed' AND Retry_Count__c>=:retryCount LIMIT 45000]){
            notInCartIds.add(eg.Refernce_Id__c);
        }
        lastModifiedDate = lastModifiedDate == null ? 1 : lastModifiedDate ;
        lastModifiedTime = lastModifiedTime == null ? 5 : lastModifiedTime ;
        Datetime cartUpdatedTime = Datetime.now().addMinutes(-lastModifiedTime);
        String query = '';
        if(!Test.isRunningTest()){
            query += 'SELECT Id, Name, ccrz__CartStatus__c,ccrz__Account__c,ccrz__Account__r.Name,digitalriverb2b__DR_Cart_Id__c,ccrz__Storefront__c,ccrz__User__c,ccrz__User__r.Name,ccrz__Contact__c FROM ccrz__E_Cart__c WHERE Source__c=:source AND ccrz__CartStatus__c=:openStatus AND digitalriverb2b__DR_Payment_State__c=:drStatus  AND LastModifiedDate= LAST_N_DAYS:'+lastModifiedDate+' AND lastModifiedDate <:cartUpdatedTime';//AND ccrz__ActiveCart__c = false 
        }
        else{
            query += 'SELECT Id, Name, ccrz__CartStatus__c,ccrz__Account__c,ccrz__Account__r.Name,digitalriverb2b__DR_Cart_Id__c,ccrz__Storefront__c,ccrz__User__c,ccrz__User__r.Name,ccrz__Contact__c FROM ccrz__E_Cart__c WHERE Source__c=:source AND ccrz__CartStatus__c=:openStatus AND digitalriverb2b__DR_Payment_State__c=:drStatus AND ccrz__ActiveCart__c = false  ';
        }
        
        query += String.isNotBlank(cartId) ? ' AND Id = :cartId' : '';
        query += notInCartIds.isEmpty() ? '' :' AND Id NOT in: notInCartIds ';
        return Database.getQueryLocator(query+' ORDER BY LASTMODIFIEDDATE ');
    }

    public void execute(Database.BatchableContext bc, List<ccrz__E_Cart__c> scope){
        ccrz__E_Cart__c cart = scope.get(0);
        processCart(cart);
    }


    public void processCart(ccrz__E_Cart__c cart){
        Savepoint sp ;
        ERG_Data_Fix_Log__c eg = new ERG_Data_Fix_Log__c(Reference_Object__c='Cart',Retry_Count__c=1);
        try{
            eg.Refernce_Id__c = cart.Id ;
            List<ERG_Data_Fix_Log__c> egList = [SELECT Id,Refernce_Id__c,Reference_Object__c,Retry_Count__c,Status__c FROM ERG_Data_Fix_Log__c WHERE Refernce_Id__c=:cart.Id AND Reference_Object__c='Cart' ORDER BY LASTMODIFIEDDATE LIMIT 1];
            if(!egList.isEmpty()){
                eg = egList.get(0);
                if( (eg.Retry_Count__c>=retryCount  && eg.Status__c == 'Failed' ) ||  eg.Status__c == 'Success' ){
                    return ;
                }
                eg.Retry_Count__c = eg.Retry_Count__c + 1 ;
            }
            List<ccrz__E_Order__c> existingOrderList = [SELECT Id FROM ccrz__E_Order__c WHERE ccrz__OriginatedCart__c=: cart.Id LIMIT 1];
            if(existingOrderList.isEmpty()){
                ERGB2B_OrderWrapper ordWrap = getDRDetails(cart);
                sp = Database.setSavepoint();
                if(ordWrap != null){
                    Map<String, Object> mapResults = initCreateOrder(cart);
                    system.debug(JSON.serialize(mapResults));
                    if(Boolean.valueOf(mapResults.get('success'))){
                        String orderId = String.valueOf(mapResults.get('orderId'));
                        //CREATE TRANSACTION PAYMENT
                        createTransactionPayment(cart,orderId, ordWrap);
                        eg.Status__c = 'Success';
                        successOrderList.add(orderId);
                    }else{
                        Database.rollback(sp);
                        eg.Status__c = 'Failed';
                        eg.Error_Message__c = 'Error in creating Order';
                    }
                }else{
                    eg.Status__c = 'Failed';
                    eg.Error_Message__c = 'Not able to retrive DR Order Data';
                }
            }else{
                eg.Status__c = 'Failed';
                eg.Error_Message__c = 'Order Already Exist.';
            }
        }
        catch(Exception ex){
            if(sp!=null){
                Database.rollback(sp);
            }
            system.debug(ex.getMessage());
            system.debug(ex.getStackTraceString());
            system.debug(ex.getLineNumber());
            eg.Status__c = 'Failed';
            eg.Error_Message__c = ex.getMessage() +' '+ex.getLineNumber() ;
        }
        if(eg !=null){
            if(eg.Status__c == 'Failed' && cart!=null){
                failedCartList.add(cart); //TODO to send failed cart in email
                errMsgMap.put(cart.id,eg.Error_Message__c);
            }
            upsert eg;
        }
    }

    public ccrz__E_TransactionPayment__c createTransactionPayment(ccrz__E_Cart__c cart,String orderId,ERGB2B_OrderWrapper ordWrap){
        System.debug(JSON.serialize(ordWrap));
        System.debug(JSON.serialize(ordWrap.order.paymentMethod));
        ccrz__E_TransactionPayment__c transactionPayment = new ccrz__E_TransactionPayment__c();
        if(ordWrap.order.paymentMethod.type == 'paypal'){
            transactionPayment.ccrz__CCOrder__c = orderId;
            transactionPayment.ccrz__AccountNumber__c = ordWrap.order.paymentMethod.type;
            transactionPayment.ccrz__AccountType__c = 'pp';
            transactionPayment.ccrz__Amount__c = ordWrap.order.pricing.total.value ;
            transactionPayment.ccrz__RequestAmount__c = ordWrap.order.pricing.total.value ;
            transactionPayment.ccrz__CurrencyISOCode__c = ordWrap.order.pricing.total.currency_Z ;
            transactionPayment.ccrz__TransactionType__c = 'AUTH' ;
            transactionPayment.ccrz__VerificationCode__c = ordWrap.order.paymentMethod.payPal.payerId ;
            transactionPayment.ccrz__TransactionTS__c = Datetime.now();
            transactionPayment.ccrz__Storefront__c = cart.ccrz__Storefront__c ;
            transactionPayment.ccrz__PaymentType__c = ordWrap.order.paymentMethod.type;
            transactionPayment.ccrz__Token__c = ordWrap.order.paymentMethod.payPal.token ;
            transactionPayment.ccrz__TransactionCode__c = String.valueOf(ordWrap.order.id);
            transactionPayment.ccrz__BillTo__c = cart.ccrz__Account__c;
            transactionPayment.ccrz__SoldTo__c = cart.ccrz__Account__c;
            transactionPayment.ccrz__Account__c = cart.ccrz__Account__c ;
            transactionPayment.ccrz__Contact__c = cart.ccrz__Contact__c;
            transactionPayment.ccrz__User__c = cart.ccrz__User__c;
        }else{
            transactionPayment.ccrz__CCOrder__c = orderId;
            transactionPayment.ccrz__AccountNumber__c = 'xxxx-xxxx-xxxx-'+ordWrap.order.paymentMethod.creditCard.lastFourDigits;
            transactionPayment.ccrz__AccountType__c = 'cc';
            transactionPayment.ccrz__Amount__c = ordWrap.order.pricing.total.value ;
            transactionPayment.ccrz__RequestAmount__c = ordWrap.order.pricing.total.value ;
            transactionPayment.ccrz__CurrencyISOCode__c = ordWrap.order.pricing.total.currency_Z ;
            transactionPayment.ccrz__TransactionType__c = 'AUTH' ;
            transactionPayment.ccrz__TransactionTS__c = Datetime.now();
            transactionPayment.ccrz__Storefront__c = cart.ccrz__Storefront__c ;
            transactionPayment.ccrz__PaymentType__c = ordWrap.order.paymentMethod.creditCard.brand;
            transactionPayment.ccrz__Token__c = ordWrap.order.paymentMethod.sourceId ;
            transactionPayment.ccrz__TransactionCode__c = String.valueOf(ordWrap.order.id);
            transactionPayment.ccrz__BillTo__c = cart.ccrz__Account__c;
            transactionPayment.ccrz__SoldTo__c = cart.ccrz__Account__c;
            transactionPayment.ccrz__Account__c = cart.ccrz__Account__c ;
            transactionPayment.ccrz__Contact__c = cart.ccrz__Contact__c;
            transactionPayment.ccrz__User__c = cart.ccrz__User__c;
        }
        Database.insert(transactionPayment);
        //insert transactionPayment; 
        return transactionPayment;

    }

    public void finish(Database.BatchableContext bc){
        String toEmailAddressStr =(String) B2B_Constants__mdt.getInstance('B2B_Constant').Order_Admin_Email_Address__c ;
        String htmlBody = '';
        System.debug('success order list >>' + successOrderList);
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm() ;
        if( (!successOrderList.isEmpty() || !failedCartList.isEmpty())  && String.isNotBlank(toEmailAddressStr)){
            //send EMAIL
            htmlBody += '<div style="padding:10px;">';
            if(!successOrderList.isEmpty()){
                htmlBody += '<div><span>Order Successfully Process</span></div>';
                htmlBody += '<table border="1">';
                htmlBody += '<thead>';
                htmlBody += '<tr>';
                htmlBody += '<th><span style="font-weight:bold;">Order No.</span></th>';
                htmlBody += '<th><span style="font-weight:bold;">Cart No</span></th>';
                htmlBody += '<th><span style="font-weight:bold;">Account Name</span></th>';
                htmlBody += '<th><span style="font-weight:bold;">Customer Name</span></th>';
                htmlBody += '</tr>';
                htmlBody += '</thead>';
                htmlBody += '<tbody>';
                for(ccrz__E_Order__c order : [SELECT Id,Name,ccrz__OriginatedCart__c,ccrz__OriginatedCart__r.Name,ccrz__Account__c,ccrz__Account__r.Name,ccrz__User__c,ccrz__User__r.Name from ccrz__E_Order__c where Id IN:successOrderList ])
                {
                    htmlBody += '<tr>';
                    htmlBody += '<td><span style=""><a href="'+baseUrl+'/'+order.Id+'">'+ order.Name +'</a></span></td>';
                    htmlBody += '<td><span style=""><a href="'+baseUrl+'/'+order.ccrz__OriginatedCart__c+'">'+ order.ccrz__OriginatedCart__r.Name +'</a></span></td>';
                    htmlBody += '<td><span style="">'+ order.ccrz__Account__r.Name +'</span></td>';
                    htmlBody += '<td><span style="">'+ order.ccrz__User__r.Name +'</span></td>';
                    htmlBody += '</tr>';
                }
                htmlBody += '</tbody>';
                htmlBody += '</table>'; 
            }
             
            if(!failedCartList.isEmpty()){
                htmlBody = getFailedCartHtml(htmlBody,baseUrl,failedCartList);
            }
            htmlBody += '</div>';         
            System.debug('htmlbody >>>> ' + htmlBody);
            if(String.isNotBlank(htmlBody))
            {
                sendOrderListEmail(htmlBody , toEmailAddressStr);
            }
        }
        
    }

    public String getFailedCartHtml(String htmlBody,String baseUrl,List<ccrz__E_Cart__c> failedCartList){
        htmlBody += '<br/><div><span>Failed carts</span></div';
        htmlBody += '<table border="1">';
        htmlBody += '<thead>';
        htmlBody += '<tr>';
        htmlBody += '<th><span style="font-weight:bold;">Cart No</span></th>';
        htmlBody += '<th><span style="font-weight:bold;">Account Name</span></th>';
        htmlBody += '<th><span style="font-weight:bold;">Customer Name</span></th>';
        htmlBody += '<th><span style="font-weight:bold;">Error Message</span></th>';
        htmlBody += '</tr>';
        htmlBody += '</thead>';
        htmlBody += '<tbody>';
        htmlBody += '<tr>';  
        for(ccrz__E_Cart__c failedCart : failedCartList)
        {
            htmlBody += '<tr>';
            htmlBody += '<td><span style=""><a href="'+baseUrl+'/'+failedCart.Id+'">'+ failedCart.Name +'</a></span></td>';
            htmlBody += '<td><span style="">'+ failedCart.ccrz__Account__r.Name +'</span></td>';
            htmlBody += '<td><span style="">'+ failedCart.ccrz__User__r.Name +'</span></td>';
            htmlBody += '<td><span style="">'+ errMsgMap.get(failedCart.Id)+'</span></td>';
            htmlBody += '</tr>';
        } 
        htmlBody += '</tbody>';
        htmlBody += '</table>';
        return htmlBody;
    }

    public static void sendOrderListEmail(String htmlBodyStr , String toEmailAddressStr){
        Map<String, String> mapEmailRequest = new  Map<String, String>();
        if(String.isNotBlank(toEmailAddressStr))
        {        
            List<String> lstToAddress = toEmailAddressStr.split(';');
            String htmlBody = htmlBodyStr;
            Map<String, Object> registrationMap = new Map<String, Object>();
            registrationMap.put(Erg_Constants.EMAIL_HTML_BODY, htmlBody);
            registrationMap.put(Erg_Constants.EMAIL_TO_ADDRESS, lstToAddress);
            registrationMap.put(Erg_Constants.EMAIL_SAVE_AS_ACTIVITY, false);
            registrationMap.put(Erg_Constants.EMAIL_SUBJECT, 'Order Emails');
            Map<String, Object> mapEmail = CC_ERG_static_utils.createMailData(registrationMap);
            if (lstToAddress != null && !lstToAddress.isEmpty() && mapEmail != null)
            {
                Messaging.SingleEmailMessage emailObj = (Messaging.SingleEmailMessage)mapEmail.get(Erg_Constants.EMAIL_DATA);
                mapEmail.put(Erg_Constants.EMAIL_LIST_DATA , new List<Messaging.SingleEmailMessage>{emailObj});
                CC_ERG_static_utils.sendEmail(mapEmail);
            }
        }
    }


    public static ERGB2B_OrderWrapper getDRDetails(ccrz__E_Cart__c cart){
        ERGB2B_OrderWrapper ordWrap;
        String namedCred = 'callout:'+digitalriverb2b__DR_Connector_Configuration__mdt.getInstance('Full_Access_Token_Named_Credential').digitalriverb2b__Key__c+'/' ;
        String accessToken = getAccessToken(namedCred+'token?format=json',cart);
        if(String.isNotBlank(accessToken)){
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setHeader('content-type', 'application/json');
            req.setHeader('Authorization', 'Bearer '+accessToken);
            namedCred = 'callout:'+digitalriverb2b__DR_Connector_Configuration__mdt.getInstance('DR_URL_Named_Credential').digitalriverb2b__Key__c+'/' ;
            req.setEndpoint(namedCred+'v1/shoppers/me/orders/'+cart.digitalriverb2b__DR_Cart_Id__c+'?format=json');
            Http http = new Http();
            if(Test.isRunningtest())
            {
                ordWrap = String.isBlank(ERGB2B_OrderWrapperTest.ORDER_JSON)? null : ERGB2B_OrderWrapper.parse(ERGB2B_OrderWrapperTest.ORDER_JSON) ;
            }else{
                HTTPResponse res = http.send(req); 
                String responseStr = res.getBody();
                cart.ccrz__CCEmailAddress__c = responseStr;
                update cart;
                System.debug('responseStr '+JSON.serialize(responseStr));
                if( res.getStatusCode() == 200) {
                    ordWrap =  ERGB2B_OrderWrapper.parse(responseStr);
                }
            }
        }
        return ordWrap ;
    }

    public static String  getAccessToken(String endPoint,ccrz__E_Cart__c cart){
        String accessToken = '';
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('content-type', 'application/x-www-form-urlencoded');
        req.setEndpoint(endPoint);
        String body = 'dr_external_reference_id='+cart.ccrz__Account__c+'&grant_type=client_credentials';
        req.setBody(body);
        Http http = new Http();
        if (Test.isRunningtest())
        {
            accessToken = 'test';
        }else{
            HTTPResponse res = http.send(req); 
            if ( res.getStatusCode() == 200) {
                if(String.isNotBlank(res.getBody())){
                    Map<String,Object> resMap =  (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
                    accessToken = String.valueOf(resMap.get('access_token'));
                }
            }
        }
        return accessToken;
    }

    public static Map<String, Object> initCreateOrder(ccrz__E_Cart__c cart){
        if(cart.ccrz__CartStatus__c != 'Open'){
            cart.ccrz__CartStatus__c = 'Open';
            update cart;
        }
        //Set User Context
        Map<String, Object> mapCartRequest = new Map<String, Object>{
            ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
            ccrz.ccApiCart.CART_ID => cart.Id, 
            ccrz.ccApiCart.SKIP_VALID_CHECK => true
        };
        if(Test.isRunningTest()){
            return new Map<String,Object>{'success'=>true,'orderId'=>null};
        }else{
            return ccrz.ccApiCart.place(mapCartRequest);
        }
        
    }

}