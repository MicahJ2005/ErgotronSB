global class CC_ERG_ctrl_atp {

    global static ccrz.cc_RemoteActionResult doATPForStore(ccrz.cc_RemoteActionContext ctx, String SKU) {
        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'CC_ERG_ctrl_atp:doATPForStore');

        result.success = false;
 
        try {
            Informatica_CallOuts.ATP_Data atpResult;
            if(!Test.isRunningTest()) atpResult = Informatica_CallOuts.ATPCalloutProcess(SKU);
            result.data = atpResult;
            result.success = true;
        } catch (Exception e) {
            result.success = false;
            ccrz.ccLog.log(System.LoggingLevel.ERROR, e.getMessage());
        } finally {
            ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:X', 'CC_ERG_ctrl_atp:doATPForStore'+result.data);
            ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:X', 'CC_ERG_ctrl_atp:doATPForStore');
            ccrz.ccLog.close(result);
        }

        return result;

    }
    
    
    
    
    
    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult updateFCAN(ccrz.cc_RemoteActionContext ctx,string account_number) {
/*
        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);    
        string curCartid = ccrz.cc_callContext.currCartId;
        string info = 'debug CC_ERG_ctrl_atp:updateFCAN account_number='+account_number+' '+curCartid;
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'debug', 'debug CC_ERG_ctrl_atp:updateFCAN account_number');
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, info); 
        ccrz.ccLog.close(result);
        result.data = 'this came from CC_ERG_ctrl_atp.apxc:updateFCAN ';
        return result;  
*/        
        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);        
//        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'CC_ERG_ctrl_PDP:updateFCAN');
        
        result.success = false;
  
        string ThisFCAN;          
        ThisFCAN =  account_number; 
        
        string cartID;
        cartID = ctx.currentCartId; 

 //       ccrz.cclog.log(System.LoggingLevel.DEBUG, 'CC_ERG_ctrl_PDP:updateFCAN account_number', account_number);
 //       ccrz.cclog.log(System.LoggingLevel.DEBUG, 'CC_ERG_ctrl_PDP:updateFCAN FCAN', ThisFCAN);
 //      ccrz.cclog.log(System.LoggingLevel.DEBUG, 'CC_ERG_ctrl_PDP:updateFCAN cartID', cartID);
        
// using encrypted card id
// using SKU variable
 
            ccrz__E_Cart__c theCart  = [ select Id, cc_FreightCarrierActNbr__c from ccrz__E_Cart__c where ccrz__EncryptedId__c= :cartID];
    
            theCart.cc_FreightCarrierActNbr__c = ThisFCAN;
            update theCart;
        
//        Map<String,Object> resultMap = new Map<String, Object>();
//        Map<String,Object> resultMap = new Map<String, String>();
        
//        resultMap.put('key1', 'value 1 data');
//        resultMap.put('key2', 'value 2 data');
//        result.data = resultMap;
         
//        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:X', 'CC_ERG_ctrl_PDP:updateFCAN');
//        ccrz.ccLog.close(result);


        
        return result;           
        
          
        
        
        
        
        
        
                        
                            
    }    
     
    
    
    @RemoteAction
    global static  ccrz.cc_RemoteActionResult updatecart(ccrz.cc_RemoteActionContext ctx, string location, string SKU, string field_qty){
        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);
        
        try{
         
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'CC_ERG_ctrl_PDP:updatecart');
        
        result.success = false;
  
        string ThisSKU; // this needs to be passed in with location
        ThisSKU =  'SRVC-LIF5YR';     
        
        ThisSKU =  SKU; 
        
        string cartID;
        cartID = ctx.currentCartId; 

        ccrz.cclog.log(System.LoggingLevel.DEBUG, 'CC_ERG_ctrl_PDP:updatecart location', location);
        ccrz.cclog.log(System.LoggingLevel.DEBUG, 'CC_ERG_ctrl_PDP:updatecart SKU', ThisSKU);
       ccrz.cclog.log(System.LoggingLevel.DEBUG, 'CC_ERG_ctrl_PDP:updatecart cartID', cartID);
        
// using encrypted card id
// using SKU variable

        Integer number_cart_items_found = 0;
        
         try {
            // count number of cart items records for this sku in this cart        
            number_cart_items_found  = [
            select Count()  
              from ccrz__E_CartItem__c 
             where ccrz__Product__r.ccrz__SKU__c = :SKU 
               and ccrz__Cart__r.ccrz__EncryptedId__c = :cartID
               and ccrz__Cart__r.ccrz__ActiveCart__c = true];
        } catch (Exception e) {
            number_cart_items_found = 0;
            result.success = false;
            ccrz.ccLog.log(System.LoggingLevel.ERROR, e.getMessage());
        } finally {
            ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:X', 'CC_ERG_ctrl_atp:updatecart');
        }
            
        Integer qty = Integer.valueOf(field_qty);
        
    // no cart item found for this sku
    if(number_cart_items_found <= 0)
    {
    
        //  a list of line itmes to add to cart (code came from example that can do multiples)
        List<ccrz.ccApiCart.LineData> linesToAdd = new List<ccrz.ccApiCart.LineData>(); 
        
        // line item working on 
        ccrz.ccApiCart.LineData lineToAdd = new ccrz.ccApiCart.LineData();  
     
    //      String cartId;
            Boolean hasCoupon = false;  // version 1 has no coupons
            String couponCode = '';     // version 1 has no coupons
//          integer  qty = 1;
    
            // populates list to build cart item from
                 lineToAdd.sku = SKU;  
            lineToAdd.quantity = qty;  
            linesToAdd.add(lineToAdd);   
    
        // product update for cart
        Map<String,Object> addResults = ccrz.ccApiCart.addTo(new Map<String,Object>{
            ccrz.ccApi.API_VERSION =>ccrz.ccApi.CURRENT_VERSION,
            ccrz.ccApiCart.CART_ENCID => cartId,
            ccrz.ccApiCart.LINE_DATA => linesToAdd,
            ccrz.ccApiCart.ISREPRICE  => true,    
            ccrz.ccApiCart.ISSKIPPRICING  => false
        });
        
        //debug
        ccrz.ccLog.log(System.LoggingLevel.DEBUG,'The addto success was: ' + (Boolean) addResults.get(ccrz.ccApi.SUCCESS));
        result.success = result.success && (Boolean) addResults.get(ccrz.ccApi.SUCCESS);
    
        // coupons update date (will be used in future store is why keeing code for now     
           
    //  if(hasCoupon){
    //      Map<String,Object> couponResults = ccrz.ccApiCart.addTo(new Map<String,Object>{
    //      ccrz.ccApi.API_VERSION => 4,
    //      ccrz.ccApiCart.CART_ENCID => cartId,
    //      ccrz.ccApiCart.COUPON_CODE => couponCode
    //      });
    //
    //          //debug
    //      ccrz.ccLog.log(System.LoggingLevel.DEBUG,'The coupon success was: ' + (Boolean) couponResults.get(ccrz.ccApi.SUCCESS));
    //      resp.success = resp.success && (Boolean) couponResults.get(ccrz.ccApi.SUCCESS);        
    //  }
    
    
        // pricing 
        /*
        Map<String,Object> priceResults = ccrz.ccApiCart.price(new Map<String,Object>{
             ccrz.ccApi.API_VERSION => 1,
             ccrz.ccApiCart.CART_ENCID => cartId
        });
        */
        // debug
        //ccrz.ccLog.log(System.LoggingLevel.DEBUG,'The price success was: ' + (Boolean) priceResults.get(ccrz.ccApi.SUCCESS));
        //result.success = result.success && (Boolean) priceResults.get(ccrz.ccApi.SUCCESS);

         ccrz__E_CartItem__c theCartItem  = [
        select Id, ccrz__Product__r.ccrz__SKU__c, ergo_wh_location__c
          from ccrz__E_CartItem__c 
         where ccrz__Product__r.ccrz__SKU__c = :SKU 
           and ccrz__Cart__r.ccrz__EncryptedId__c = :cartID
           and ccrz__Cart__r.ccrz__ActiveCart__c = true];
    
            theCartItem.ergo_wh_location__c = location;
        
            update theCartItem;
    
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:X', 'CC_ERG_ctrl_PDP:updatecart');    
        
        
        
    }
    else
    {
                
        
                
         ccrz__E_CartItem__c theCartItem  = [
        select Id, ccrz__Product__r.ccrz__SKU__c, ergo_wh_location__c, ccrz__quantity__c 
          from ccrz__E_CartItem__c 
         where ccrz__Product__r.ccrz__SKU__c = :SKU 
           and ccrz__Cart__r.ccrz__EncryptedId__c = :cartID
           and ccrz__Cart__r.ccrz__ActiveCart__c = true];
    
            theCartItem.ergo_wh_location__c = location;
            theCartItem.ccrz__quantity__c += qty;
                
            update theCartItem;
    
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:X', 'CC_ERG_ctrl_PDP:updatecart');    
                
                
     }

// could just do this code anyways  updating the skus found in this cart with the location 
//else
//{

//             string query = 'select Id, ccrz__Product__r.ccrz__SKU__c, ergo_wh_location__c   from ccrz__E_CartItem__c  where ccrz__Product__r.ccrz__SKU__c = :SKU    and ccrz__Cart__r.ccrz__EncryptedId__c = :cartID    and ccrz__Cart__r.ccrz__ActiveCart__c = true';         ccrz.cclog.log(System.LoggingLevel.DEBUG, 'CC_ERG_ctrl_PDP:updatecart SKU', query);
/* 
         ccrz__E_CartItem__c theCartItem  = [
        select Id, ccrz__Product__r.ccrz__SKU__c, ergo_wh_location__c 
          from ccrz__E_CartItem__c 
         where ccrz__Product__r.ccrz__SKU__c = :SKU 
           and ccrz__Cart__r.ccrz__EncryptedId__c = :cartID
           and ccrz__Cart__r.ccrz__ActiveCart__c = true];
    
            theCartItem.ergo_wh_location__c = location;
            update theCartItem;
    
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:X', 'CC_ERG_ctrl_PDP:updatecart');    
*/    
//}
        
//        Map<String,Object> resultMap = new Map<String, Object>();
        Map<String,Object> resultMap = new Map<String, String>();
        
        resultMap.put('key1', 'value 1 data');
        resultMap.put('key2', 'value 2 data');
        result.data = resultMap;
        } catch (Exception e){
            result.data = e.getStackTraceString();
        } 
        finally{
            ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:X', 'CC_ERG_ctrl_PDP:updatecart');
            ccrz.ccLog.close(result);
        }

        return result;   
    }
        
    
    
}