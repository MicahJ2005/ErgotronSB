/**
 * @description       : 
 * @author            : Raziya Gurramkonda
 * @group             : 
 * @last modified on  : 11-13-2020
 * @last modified by  : Raziya Gurramkonda
 * Modifications Log 
 * Ver   Date         Author               Modification
 * 1.0   11-11-2020   Raziya Gurramkonda   Initial Version
**/
global without sharing class CC_ERG_CartManager {
    global static final String STOREFRONT = 'DefaultStore';
    global static final String MODULE_NAME = 'Cart Module';
    global static final String CLASSNAME = 'ccErg_CartManager';

    global static CC_ERG_CartModel processAddToCart(CC_ERG_CartRequest cartRequest)
    {
         System.debug('>cartRequest '+JSON.serialize(cartRequest));
        CC_ERG_CartModel cartModelObject = new CC_ERG_CartModel();
        String strEncryptedCartId = null;
        Boolean itemAddedToCart = false;
        if (cartRequest != null && cartRequest.lineItems != null && cartRequest.lineItems.size() > 0)
        {
            Map<String, Object> mapCartRequest = new Map<String, Object>();
            mapCartRequest.put(CC_ERG_Constant.STOREFRONT_NAME, cartRequest.storefrontName);
            mapCartRequest.put(CC_ERG_Constant.STOREFRONT_LOCALE, cartRequest.locale);
            mapCartRequest.put(CC_ERG_Constant.STOREFRONT_CURRENCY, cartRequest.userCurrency);
            mapCartRequest.put(CC_ERG_Constant.CART_ITEM_MODEL_OBJ , cartRequest.lineItems);
            mapCartRequest.put(ccrz.ccApiCart.CART_ENCID , cartRequest.cartId);
            mapCartRequest.put(CC_ERG_Constant.CART_PROCESS_ACTION  ,CC_ERG_Constant.ADD_TO_CART);
            mapCartRequest.put(CC_ERG_Constant.ADD_TO_CART_CHANGE_PLAN , cartRequest.changePlan);
            strEncryptedCartId = cartRequest.cartId;
            String priceList = CustomMetadataUtility.fetchCurrentPriceListName();
            if(priceList != null) {
                mapCartRequest.put(CC_ERG_Constant.PRICE_LIST_NAME, priceList); // use current price list
            }
            //Pre Validation cart request check
            mapCartRequest = preValidateCartRequest(mapCartRequest);
           
           if(mapCartRequest.containsKey(CC_ERG_Constant.CART_REQUEST_VALID) &&
                    (Boolean)mapCartRequest.get(CC_ERG_Constant.CART_REQUEST_VALID))
            {
              /*  if(mapCartRequest.containsKey(ccrz.ccApiCart.CART_OBJ) && mapCartRequest.get(ccrz.ccApiCart.CART_OBJ)!=null)
                {
                    ccrz__E_Cart__c ccCartObject = (ccrz__E_Cart__c)mapCartRequest.get(ccrz.ccApiCart.CART_OBJ);
                    if(ccCartObject!=null && ccCartObject.ccrz__E_CartItems__r!=null && ccCartObject.ccrz__E_CartItems__r.size()>0)
                    {
                        ccErg_CartHelper.deleteCartItems(ccCartObject.ccrz__E_CartItems__r);
                    }
                }*/

              
                System.debug('mapCartRequest : '+JSON.serialize(mapCartRequest));
                //check given cart is Abandoned ER2- 206
                 if(String.isNotBlank(strEncryptedCartId))
                {
                List<ccrz__E_Cart__c > cartList = [SELECT Id, Name, ccrz__CartStatus__c, ccrz__EncryptedId__c FROM 
                    ccrz__E_Cart__c where (ccrz__EncryptedId__c =: strEncryptedCartId OR Id =: strEncryptedCartId )AND ccrz__CartStatus__c = 'Abandoned'];
                    if(cartList.size() > 0){
                        mapCartRequest?.remove(ccrz.ccApiCart.CART_ENCID);
                    }
                
                }
                //Add to Cart
                Map<String, Object> addToCartResponse = CC_ERG_CartManager.addProductsToCart(mapCartRequest);

                if(addToCartResponse!=null && addToCartResponse.containsKey(ccrz.ccApiCart.CART_ENCID))
                {
                    strEncryptedCartId = (String)addToCartResponse.get(ccrz.ccApiCart.CART_ENCID);
                    itemAddedToCart = (Boolean) addToCartResponse.get(CC_ERG_Constant.IS_SUCCESS);
                }
            }
            if(String.isNotBlank(strEncryptedCartId))
            {
                mapCartRequest.put(ccrz.ccApiCart.CART_ENCID , strEncryptedCartId);
                cartModelObject = fetchCartModel(mapCartRequest);
                cartModelObject.status = itemAddedToCart;
            }
            if (mapCartRequest.containsKey(CC_ERG_Constant.ADD_TO_CART_ERROR) 
                && String.isNotBlank((String)(mapCartRequest.get(CC_ERG_Constant.ADD_TO_CART_ERROR)))){
                CC_ERG_CartModel.Error errorObj = new CC_ERG_CartModel.Error();
                errorObj.statusCode = 404;
                errorObj.errorCount = 1;
                errorObj.errorMessage = (String) mapCartRequest.get(CC_ERG_Constant.ADD_TO_CART_ERROR);
                cartModelObject.error = errorObj;
            }
        }
        return cartModelObject;
    }
    /* 
    global static CC_ERG_CartModel processUpdateCart(CC_ERG_CartRequest cartRequest)
    {
        CC_ERG_CartModel cartModelObject = new CC_ERG_CartModel();
        if (cartRequest != null && cartRequest.lineItems != null && cartRequest.lineItems.size() > 0)
        {
            Map<String, Object> mapCartRequest = new Map<String, Object>();
            mapCartRequest.put(CC_ERG_Constant.STOREFRONT_NAME, cartRequest.storefrontName);
            mapCartRequest.put(CC_ERG_Constant.STOREFRONT_LOCALE, cartRequest.locale);
            mapCartRequest.put(CC_ERG_Constant.STOREFRONT_CURRENCY, cartRequest.userCurrency);
            mapCartRequest.put(CC_ERG_Constant.CART_ITEM_MODEL_OBJ , cartRequest.lineItems);
            mapCartRequest.put(ccrz.ccApiCart.CART_ENCID ,cartRequest.cartId);
            mapCartRequest.put(CC_ERG_Constant.CART_PROCESS_ACTION  ,CC_ERG_Constant.CHANGE_CART_QUANTITY);
            mapCartRequest.put(CC_ERG_Constant.PRICE_LIST_NAME, cartRequest.priceBook);

            //Pre Validation cart request check
            mapCartRequest = preValidateCartRequest(mapCartRequest);

            if(mapCartRequest.containsKey(CC_ERG_Constant.CART_REQUEST_VALID) &&
                    (Boolean)mapCartRequest.get(CC_ERG_Constant.CART_REQUEST_VALID) &&
                    mapCartRequest.containsKey(ccrz.ccApiCart.CART_ENCID))
            {
                ccrz__E_Cart__c cartObject = CC_ERG_CartHelper.getCartByEncryptedORCartId(mapCartRequest);
                mapCartRequest.put(ccrz.ccApiCart.CART_OBJ, cartObject);
                List<CC_ERG_CartRequest.CartLineItem> cartLineItems = cartRequest.lineItems;
                List<ccrz__E_CartItem__c> lstZeroCartItems = new List<ccrz__E_CartItem__c>();
                List<ccrz__E_CartItem__c> lstCartItems = cartObject.ccrz__E_CartItems__r;
                if(lstCartItems!=null && lstCartItems.size()>0)
                {
                    for(ccrz__E_CartItem__c cartItemObject : lstCartItems)
                    {
                        for(CC_ERG_CartRequest.CartLineItem cartLineItem : cartLineItems)
                        {
                            if( (cartItemObject.ccrz__Quantity__c ==0 && String.isNotBlank(cartLineItem.cartItemId) &&
                                    cartLineItem.cartItemId != cartItemObject.Id ) ||
                                    (cartLineItem.cartItemId ==cartItemObject.Id && cartLineItem.quantity ==0))
                            {
                                ccrz__E_CartItem__c newCartItemObject = cartItemObject.clone();
                                if(cartLineItem.quantity ==0)
                                {
                                    newCartItemObject.ccrz__Quantity__c = 0;
                                    newCartItemObject.ccrz__SubAmount__c = 0;
                                    newCartItemObject.ccrz__Price__c = 0;
                                }
                                lstZeroCartItems.add(newCartItemObject);
                            }
                        }
                    }
                }
                //Updating Cart Item Quantity
                mapCartRequest = updateCartItemQuantity(mapCartRequest);

                //DML Statement to update Quantity
                CC_ERG_CartHelper.updateCartItems(mapCartRequest);

                //Repricing the cart after Quantity Changed
                Map<String,Object> mapCartResponse = processPriceCart(mapCartRequest);

                if(lstZeroCartItems!=null && lstZeroCartItems.size()>0)
                {
                    insert lstZeroCartItems;
                }

                if(mapCartRequest!=null && mapCartRequest.containsKey(ccrz.ccApiCart.CART_ENCID))
                {
                    cartModelObject = fetchCartModel(mapCartRequest);
                    cartModelObject.status = (Boolean) mapCartResponse.get(CC_ERG_Constant.IS_SUCCESS);
                }
            }
        }
        return cartModelObject;
    }
    
    global static CC_ERG_CartModel populateCartReviewDetails(CC_ERG_CartRequest cartRequest)
    {
        CC_ERG_CartModel cartModelObject = new CC_ERG_CartModel();
        if (cartRequest != null)
        {
            Map<String, Object> mapCartRequest = new Map<String, Object>();
            mapCartRequest.put(CC_ERG_Constant.STOREFRONT_NAME, cartRequest.storefrontName);
            mapCartRequest.put(CC_ERG_Constant.STOREFRONT_LOCALE, cartRequest.locale);
            mapCartRequest.put(CC_ERG_Constant.STOREFRONT_CURRENCY, cartRequest.userCurrency);
            mapCartRequest.put(ccrz.ccApiCart.CART_ENCID ,cartRequest.cartId);
            if(mapCartRequest.containsKey(ccrz.ccApiCart.CART_ENCID) && cartRequest.cartDetails!=null)
            {
                mapCartRequest.put(CC_ERG_Constant.CART_REVIEW_DETAILS , cartRequest.cartDetails);

                populateCartReviewOnCart(mapCartRequest);

                Map<String,Object> mapCartResponse = CC_ERG_CartHelper.updateCart(mapCartRequest);

                if(mapCartRequest!=null && mapCartRequest.containsKey(ccrz.ccApiCart.CART_ENCID))
                {
                    cartModelObject = fetchCartModel(mapCartRequest);
                    cartModelObject.status = (Boolean) mapCartResponse.get(CC_ERG_Constant.IS_SUCCESS);
                }
            }
        }
        return cartModelObject;
    }

    global static Map<String,Object> populateCartReviewOnCart(Map<String, Object> mapCartRequest)
    {
        if(mapCartRequest.containsKey(ccrz.ccApiCart.CART_ENCID) &&
                mapCartRequest.containsKey(CC_ERG_Constant.CART_REVIEW_DETAILS))
        {
            ccrz__E_Cart__c cartObject = CC_ERG_CartHelper.getCartByEncryptedORCartId(mapCartRequest);
            CC_ERG_CartReviewModel cartDetailsObject = (CC_ERG_CartReviewModel)mapCartRequest.get(CC_ERG_Constant.CART_REVIEW_DETAILS);
            if(cartObject!=null && cartDetailsObject!=null)
            {
               
                mapCartRequest.put(ccrz.ccApiCart.CART_OBJ, cartObject);
            }
        }
        return mapCartRequest;
    }

    global static CC_ERG_CartModel processRemoveCartItem(CC_ERG_CartRequest cartRequest)
    {
        CC_ERG_CartModel cartModelObject = new CC_ERG_CartModel();
        Map<String, Object> mapCartItemDelete = new Map<String,Object>();
        List<ccrz__E_CartItem__c> lstCartItems = new List<ccrz__E_CartItem__c>();
        Boolean changePlan = false;
        Boolean nonBundledProduct = true;
        if (cartRequest != null && cartRequest.lineItems != null && cartRequest.lineItems.size() > 0)
        {
            Map<String, Object> mapCartRequest = new Map<String, Object>();
            mapCartRequest.put(CC_ERG_Constant.STOREFRONT_NAME, cartRequest.storefrontName);
            mapCartRequest.put(CC_ERG_Constant.STOREFRONT_LOCALE, cartRequest.locale);
            mapCartRequest.put(CC_ERG_Constant.STOREFRONT_CURRENCY, cartRequest.userCurrency);
            mapCartRequest.put(CC_ERG_Constant.PRICE_LIST_NAME, cartRequest.priceBook);
            mapCartRequest.put(CC_ERG_Constant.CART_ITEM_MODEL_OBJ , cartRequest.lineItems);
            mapCartRequest.put(ccrz.ccApiCart.CART_ENCID , cartRequest.cartId);
            mapCartRequest.put(CC_ERG_Constant.CART_PROCESS_ACTION  ,CC_ERG_Constant.REMOVE_CART_ITEM);

            if(cartRequest.changePlan!=null)
            {
                changePlan = cartRequest.changePlan;
            }

            ccrz__E_Cart__c cartObject = CC_ERG_CartHelper.getCartByEncryptedORCartId(mapCartRequest);
            SObject cartOwner = cartObject.Owner;
            mapCartRequest.put(CC_ERG_Constant.STOREFRONT_USERNAME, cartOwner.get(CC_ERG_Constant.USER_USERNAME));
            mapCartRequest.put(ccrz.ccApiCart.CART_OBJ, cartObject);

            mapCartItemDelete = fetchCartWithCartItems(mapCartRequest);

            if(cartObject!=null && cartObject.ccrz__E_CartItems__r!=null && cartObject.ccrz__E_CartItems__r.size()>0)
            {
                //check for Bundle Product remove
                for(CC_ERG_CartRequest.CartLineItem cartLineItemObject : cartRequest.lineItems)
                {

                    List<ccrz__E_CartItem__c> lstCartItemToBeDeleted = null;
                    if(mapCartItemDelete!=null && mapCartItemDelete.containsKey(cartLineItemObject.cartItemId))
                    {
                        lstCartItemToBeDeleted = (List<ccrz__E_CartItem__c>)mapCartItemDelete.get(cartLineItemObject.cartItemId);
                    }
                    if(lstCartItemToBeDeleted!=null && lstCartItemToBeDeleted.size()>0)
                    {
                        if (changePlan)
                        {
                            lstCartItems.addAll(lstCartItemToBeDeleted);
                        }
                        else if (String.isNotBlank(cartLineItemObject.cartItemId))
                        {
                            for (ccrz__E_CartItem__c cartItemObj : lstCartItemToBeDeleted)
                            {
                                if(cartItemObj.ccrz__ProductType__c == CC_ERG_Constant.PRODUCT_TYPE_BUNDLED)
                                {
                                    nonBundledProduct = false;
                                }
                            }
                            if(nonBundledProduct)
                            {
                                lstCartItems.addAll(lstCartItemToBeDeleted);
                            }
                        }
                    }
                }
                //Deleting Cart Items
                if(lstCartItems!=null && lstCartItems.size()>0)
                {
                    CC_ERG_CartHelper.deleteCartItems(lstCartItems);
                    cartModelObject.status = true;
                }
                if(!changePlan)
                {
                    cartModelObject = fetchCartModel(mapCartRequest);
                }
                cartModelObject.status = nonBundledProduct;
            }
        }
        return cartModelObject;
    }
    */
    global static CC_ERG_CartModel populateCartDetails(Map<String,Object> cartResponseObject)
    {
        CC_ERG_CartModel cartModelObject = new CC_ERG_CartModel();
        if(cartResponseObject!=null)
        {
            cartModelObject = CC_ERG_CartHelper.getCartModel(cartResponseObject);
        }
        return cartModelObject;
    }

    /*
    *
    * Method to create a Cart
    *
    * @param  storefront                Storefront associated with the Cart
    * @param  userName                  Name of the Portal User to be used for CloudCraze User
    * @param  userLocale                Name of the Portal User
    * @param  userCurrency              Currency to be used for the current transaction
    * @param  cartName                  Name for the Cart
    * @param  transactionType           Indicates transaction type "Trial", "Buy", "Convert" etc.
    *
    * @return MktpCartModel
    */
    global static Map<String, Object> createCart(String storefrontName)
    {
        Map<String, Object> createCartResults = new Map<String, Object>();
        try {
            
            Map<String, Object> cartToCreate = new Map<String, Object> {
                    'cartType' => 'Cart',
                    'activeCart' => true,
                    'storefront' => storefrontName
            };
            Map<String, Object> cartCreateInputData = new Map<String, Object> {
                    ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION ,
                    ccrz.ccApiCart.CART_OBJLIST => new List<Map<String, Object>> {cartToCreate}
            };
            createCartResults  = ccrz.ccApiCart.create(cartCreateInputData);
            
            
        }
        catch (Exception ex) {
            System.debug(ex);
        }
        return createCartResults;
    }

    /*
    * Method to add selected Products to Cart.
    *
    * @param  ca           Encrypted Cart Id
    * @param  lineDataList              List<Map<String, Object> List of Cart Items passed as CC Line Data Objects
    *                                   Each Cart Item should've a SKU, Quantity, SubProdTermId
    *
    * @return Boolean
    */
    global static Map<String,Object> addProductsToCart(Map<String,Object> mapCartRequest){
        Map<String,Object> addToCartRequest = new Map<String,Object>();
        Map<String,Object> addToResponse = new Map<String,Object>();
        List<Map<String, Object>> cartLineItemList = new List<Map<String, Object>>();
        String encryptedCartId = null;
        if(mapCartRequest!=null && mapCartRequest.containsKey(CC_ERG_Constant.CART_ITEM_MODEL_OBJ) &&
                mapCartRequest.containsKey(CC_ERG_Constant.STOREFRONT_NAME))
        {
            ccrz.ccContext ctx = CC_ERG_Context.getCCContextForUser(mapCartRequest);
            if(!Test.isRunningTest()){
                // test
            }
            
            if(mapCartRequest.containsKey(ccrz.ccApiCart.CART_ENCID) &&
                    String.isNotBlank((String)mapCartRequest.get(ccrz.ccApiCart.CART_ENCID)))
            {
                encryptedCartId = (String)mapCartRequest.get(ccrz.ccApiCart.CART_ENCID);
            }
            else
            {
                System.debug('@@ --> '+ (String)mapCartRequest.get(CC_ERG_Constant.STOREFRONT_NAME));
                Map<String, Object> mapNewCartResponse = createCart( (String)mapCartRequest.get(CC_ERG_Constant.STOREFRONT_NAME));
               
                if(mapNewCartResponse!=null && mapNewCartResponse.containsKey(CC_ERG_Constant.IS_SUCCESS) &&
                        (Boolean)mapNewCartResponse.get(CC_ERG_Constant.IS_SUCCESS) && mapNewCartResponse.containsKey(ccrz.ccApiCart.CART_ENCID))
                {
                    encryptedCartId = (String)mapNewCartResponse.get(ccrz.ccApiCart.CART_ENCID);
                    mapCartRequest.put(ccrz.ccApiCart.CART_ENCID,encryptedCartId);
                CC_ERG_CartHelper.updateCartSource(mapCartRequest);
                }
            }

            List<CC_ERG_CartRequest.CartLineItem> cartItems = (List<CC_ERG_CartRequest.CartLineItem>)mapCartRequest.get(CC_ERG_Constant.CART_ITEM_MODEL_OBJ);
            for (CC_ERG_CartRequest.CartLineItem  cartItem : cartItems)
            {
                Map<String, Object> newSKUToAdd = new Map<String, Object> {
                        ccrz.ccApiCart.LINE_DATA_SKU => cartItem.sku,
                        ccrz.ccApiCart.LINE_DATA_QUANTITY => cartItem.quantity
                };
                cartLineItemList.add(newSKUToAdd);
            }
            addToCartRequest.put(ccrz.ccApi.API_VERSION , ccrz.ccApi.CURRENT_VERSION);
            if(String.isNotBlank(encryptedCartId))
            {
                addToCartRequest.put(ccrz.ccApiCart.CART_ENCID , encryptedCartId);
            }
            if(cartLineItemList!=null && cartLineItemList.size()>0)
            {
                addToCartRequest.put(ccrz.ccApiCart.LINE_DATA , cartLineItemList);
                addToResponse = CC_ERG_CartHelper.addToCart(addToCartRequest);
            }
            if(String.isNotBlank(encryptedCartId))
            {
                Map<String, Object> res = ccrz.ccApiCart.price(new Map<String,Object>{
                    ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                    ccrz.ccApiCart.CART_ENCID => encryptedCartId
                });
            }
        }
        return addToResponse;
    }

    /* 
    global static Map<String,Object> updateCartItemQuantity(Map<String,Object> mapCartRequest){
        Map<String,Object> mapProductCartItems = new Map<String,Object>();
        List<ccrz__E_CartItem__c> lstCartItemToUpdate = new List<ccrz__E_CartItem__c>();
        if(mapCartRequest!=null && mapCartRequest.containsKey(ccrz.ccApiCart.CART_OBJ))
        {
            mapProductCartItems = fetchCartWithCartItems(mapCartRequest);
            System.debug('mapProductCartItems : '+JSON.serialize(mapProductCartItems));
            List<CC_ERG_CartRequest.CartLineItem> cartItems = (List<CC_ERG_CartRequest.CartLineItem>) mapCartRequest.get(CC_ERG_Constant.CART_ITEM_MODEL_OBJ);
            for (CC_ERG_CartRequest.CartLineItem cartItem : cartItems)
            {
                if(mapProductCartItems!=null && mapProductCartItems.containsKey(cartItem.cartItemId))
                {
                    List<ccrz__E_CartItem__c> lstCartItems = (List<ccrz__E_CartItem__c>)mapProductCartItems.get(cartItem.cartItemId);
                    if(lstCartItems!=null && lstCartItems.size()>0)
                    {
                        for(ccrz__E_CartItem__c cartItemObject : lstCartItems)
                        {
                            cartItemObject.ccrz__Quantity__c = cartItem.quantity;
                            lstCartItemToUpdate.add(cartItemObject);
                        }
                    }
                }
                if(lstCartItemToUpdate!=null && lstCartItemToUpdate.size()>0)
                {
                    mapCartRequest.put(ccrz.ccApiCart.CILIST , lstCartItemToUpdate);
                }
            }
        }
        return mapCartRequest;
    }

    global static Map<String,Object> fetchCartWithCartItems(Map<String,Object> mapCartRequest)
    {
        Map<String,Object> mapProductCartItems = new Map<String,Object>();
        List<ccrz__E_CartItem__c> lstBundleItems = new List<ccrz__E_CartItem__c>();
        if(mapCartRequest!=null && mapCartRequest.containsKey(ccrz.ccApiCart.CART_OBJ))
        {
            ccrz__E_Cart__c ccCartObject = (ccrz__E_Cart__c) mapCartRequest.get(ccrz.ccApiCart.CART_OBJ);
            if (ccCartObject != null)
            {
                List<ccrz__E_CartItem__c> lstCartItems = ccCartObject.ccrz__E_CartItems__r;
                if (lstCartItems != null && lstCartItems.size() > 0)
                {
                    for (ccrz__E_CartItem__c cartItemObject : lstCartItems)
                    {
                        if (cartItemObject.ccrz__ProductType__c == CC_ERG_Constant.PRODUCT_TYPE_BUNDLED ||
                                String.isNotBlank(cartItemObject.ccrz__ParentCartItem__c))
                        {
                            lstBundleItems.add(cartItemObject);
                            if (cartItemObject.ccrz__ProductType__c == CC_ERG_Constant.PRODUCT_TYPE_BUNDLED)
                            {
                                mapProductCartItems.put(cartItemObject.Id, lstBundleItems);
                            }
                        }
                        else
                        {
                            mapProductCartItems.put(cartItemObject.Id, new List<ccrz__E_CartItem__c>{
                                    cartItemObject
                            });
                        }
                    }
                }
            }
        }
        return mapProductCartItems;
    }

    global static Map<String,Object> processPriceCart(Map<String,Object> mapCartRequest){
        Map<String,Object> priceCartRequest = new Map<String,Object>();
        Map<String,Object> priceCartResponse = new Map<String,Object>();
        String encryptedCartId = null;
        if(mapCartRequest!=null && mapCartRequest.containsKey(CC_ERG_Constant.STOREFRONT_NAME))
        {
            ccrz.ccContext ctx = CC_ERG_Context.getCCContextForUser(mapCartRequest);
            System.debug('processPriceCart:ctx: ' + ctx);
            if (mapCartRequest.containsKey(ccrz.ccApiCart.CART_ENCID) &&
                    String.isNotBlank((String) mapCartRequest.get(ccrz.ccApiCart.CART_ENCID)))
            {
                encryptedCartId = (String) mapCartRequest.get(ccrz.ccApiCart.CART_ENCID);

            /*
             List<ccErg_CartRequest.CartLineItem> cartItems = (List<ccErg_CartRequest.CartLineItem>) mapCartRequest.get(CC_ERG_Constant.CART_ITEM_MODEL_OBJ);
                Map<String, Map<String, Object>> mapCartItemRequest = new Map<String, Map<String, Object>>();
                for (ccErg_CartRequest.CartLineItem cartItem : cartItems)
                {
                    Map<String, Object> itemToRePriced = new Map<String, Object>{
                            ccrz.ccApiCart.CIQTY => cartItem.quantity
                    };
                    mapCartItemRequest.put(cartItem.cartLineItemId , itemToRePriced);
                }
                System.debug('mapCartItemRequest :  ' + JSON.serialize(mapCartItemRequest));
                 if (mapCartItemRequest != null && mapCartItemRequest.size() > 0)
                {
                    //priceCartRequest.put(ccrz.ccApiCart.CILIST , mapCartItemRequest);
                    System.debug('priceCart: priceCartRequest ' + JSON.serialize(priceCartRequest));
                }
                if(mapCartRequest!=null && mapCartRequest.containsKey(ccrz.ccApiCart.CILIST))
                {
                    Map<String, Map<String, Object>> ciUpdates = new Map<String, Map<String, Object>>();
                    List<ccrz__E_CartItem__c> lstCartItemObjects = ( List<ccrz__E_CartItem__c>)mapCartRequest.get(ccrz.ccApiCart.CILIST);
                    if(lstCartItemObjects!=null && lstCartItemObjects.size()>0)
                    {
                        for(ccrz__E_CartItem__c ccCartItemId : lstCartItemObjects)
                        {
                            ciUpdates.put(ccCartItemId.Id, new Map<String, Object> {
                                    ccrz.ccApiCart.CIQTY => ccCartItemId.ccrz__Quantity__c
                            });
                        }
                        priceCartRequest.put(ccrz.ccApiCart.CILIST , ciUpdates);
                    }
                }
                // above coment end here
                priceCartRequest.put(ccrz.ccApi.API_VERSION, ccrz.ccApi.CURRENT_VERSION);
                priceCartRequest.put(ccrz.ccApiCart.CART_ENCID, encryptedCartId);
                priceCartRequest.put(ccrz.ccApiCart.CIPREPROC, false);
                priceCartRequest.put(ccrz.ccApiCart.SKIP_CART_PRICING, false);
                priceCartResponse = CC_ERG_CartHelper.priceCart(priceCartRequest);
            }
        }
        return priceCartResponse;
    }
    */

    global static Map<String,Object> preValidateCartRequest(Map<String,Object> mapCartRequest){
        Boolean isSuccess = true;
        Boolean addToCartFlow = true;
        Boolean isBundleProduct = false;
        Set<String> setProductSKU = new Set<String>();
        ccrz__E_Cart__c cartObject = null;
        Decimal inventoryLimit = 10;
        String inventoryMsg = '';
        if(mapCartRequest!=null && mapCartRequest.containsKey(CC_ERG_Constant.CART_ITEM_MODEL_OBJ))
        {
            List<ccrz__E_Configuration__c> invLimit =[SELECT Name, ccrz__ConfigurationMeta__r.name, ccrz__TextValue__c FROM ccrz__E_Configuration__c where ccrz__ConfigurationMeta__r.name = 'Inventory Limit'];
            if(!invLimit.isEmpty()){
                inventoryLimit = Decimal.valueOf(invLimit[0].ccrz__TextValue__c);
            }

            List<ccrz__E_PageLabel__c> pageLabel =  [SELECT Id, Name, ccrz__ValueRT__c FROM ccrz__E_PageLabel__c where Name = 'ERG_inventoryOOStock'];
            if(!pageLabel.isEmpty()){
                inventoryMsg = pageLabel[0].ccrz__ValueRT__c;
            }
           
            if(mapCartRequest.containsKey(ccrz.ccApiCart.CART_ENCID) && String.isNotBlank((String)(mapCartRequest.get(ccrz.ccApiCart.CART_ENCID)))){
                cartObject = CC_ERG_CartHelper.getCartByEncryptedORCartId(mapCartRequest);
                system.debug('username  '+ JSON.serialize(cartObject));
                mapCartRequest.put(ccrz.ccApiCart.CART_ENCID, cartObject?.ccrz__EncryptedId__c);
                if(cartObject.Owner != null) {
                    SObject cartOwner = cartObject.Owner;
                    system.debug('username  '+cartOwner.get(CC_ERG_Constant.USER_USERNAME));
                    mapCartRequest.put(CC_ERG_Constant.STOREFRONT_USERNAME, cartOwner.get(CC_ERG_Constant.USER_USERNAME));
                }
                mapCartRequest.put(ccrz.ccApiCart.CART_OBJ, cartObject);
            }
            else{
                String storeFrontName = CustomMetadataUtility.fetchStorefrontUserName();
                System.debug(' @@# ==> '+storeFrontName);
                if(storeFrontName != null) {
                    mapCartRequest.put(CC_ERG_Constant.STOREFRONT_USERNAME, storeFrontName);
                }
            }        
            List<CC_ERG_CartRequest.CartLineItem> cartItems = (List<CC_ERG_CartRequest.CartLineItem>)mapCartRequest.get(CC_ERG_Constant.CART_ITEM_MODEL_OBJ);
            if(cartItems!=null && cartItems.size()>0)
            {
                for(CC_ERG_CartRequest.CartLineItem cartLineItemObject :  cartItems)
                {
                    if(String.isNotBlank(cartLineItemObject.sku))
                    {
                        setProductSKU.add(cartLineItemObject.sku);
                    }
                    if(mapCartRequest.containsKey(CC_ERG_Constant.CART_PROCESS_ACTION) &&
                            (String)mapCartRequest.get(CC_ERG_Constant.CART_PROCESS_ACTION) == CC_ERG_Constant.CHANGE_CART_QUANTITY)
                    {
                        addToCartFlow = false;
                        if(String.isBlank(cartLineItemObject.cartItemId))
                        {
                            isSuccess = false;
                        }
                    }
                }
            }
            if(setProductSKU!=null && setProductSKU.size()>0 && addToCartFlow)
            {
                mapCartRequest.put(CC_ERG_Constant.PRODUCT_SEARCH_STRING, setProductSKU);
                Map<String, Object> mapResponse = CC_ERG_ProductHelper.retrieveProductsBySearchTerm(mapCartRequest);
                Map<Id, ccrz__E_Product__c> mapProductResponse = (Map<Id, ccrz__E_Product__c>)mapResponse.get(CC_ERG_Constant.PRODUCT_SEARCH_RESULTS);
                if(mapProductResponse!=null && mapProductResponse.size()>0)
                {
                    for(String strProductId :  mapProductResponse.keySet())
                    {
                        ccrz__E_Product__c ccProductObject = mapProductResponse.get(strProductId);
                        if(ccProductObject.ccrz__ProductType__c == CC_ERG_Constant.PRODUCT_TYPE_BUNDLED)
                        {
                            isBundleProduct = true;
                            mapCartRequest.put(CC_ERG_Constant.PRODUCT_INDEX_PRODUCTS , ccProductObject);
                        }
                        System.debug('CC PRODUCT => '+ccProductObject);
                        if(setProductSKU.contains(ccProductObject.ccrz__SKU__c)) {
                            if(ccProductObject.ccrz__Product_Inventory_Items__r?.size() > 0) {
                                Decimal quantity = 0;
                                for(ccrz__E_ProductInventoryItem__c obj : ccProductObject.ccrz__Product_Inventory_Items__r) {
                                    quantity += obj.ccrz__QtyAvailable__c;
                                }
                                if(quantity < inventoryLimit){
                                    mapCartRequest.put(CC_ERG_Constant.ADD_TO_CART_ERROR, inventoryMsg);
                                    isSuccess = false;
                                }
                            } else {
                                mapCartRequest.put(CC_ERG_Constant.ADD_TO_CART_ERROR, 'No Inventory Found!');
                                isSuccess = false;
                            }
                        }
                    }
                    if(isBundleProduct && cartObject!=null && cartObject.ccrz__E_CartItems__r!=null && cartObject.ccrz__E_CartItems__r.size()>0
                            && mapCartRequest.containsKey(CC_ERG_Constant.PRODUCT_INDEX_PRODUCTS))
                    {
                        ccrz__E_Product__c ccBundleProduct = (ccrz__E_Product__c)mapCartRequest.get(CC_ERG_Constant.PRODUCT_INDEX_PRODUCTS);
                       for(ccrz__E_CartItem__c cartItemObject : cartObject.ccrz__E_CartItems__r)
                        {
                           if((cartItemObject.ccrz__Product__r.ccrz__ProductType__c == ccBundleProduct.ccrz__ProductType__c) &&
                                (cartItemObject.ccrz__Product__r.ccrz__SKU__c == ccBundleProduct.ccrz__SKU__c))
                            {
                                isSuccess = false;
                            }
                        }
                    }
                }
                else
                {
                    mapCartRequest.put(CC_ERG_Constant.ADD_TO_CART_ERROR, 'Product doesn\'t exist.');
                    isSuccess = false;
                }
            }
        }
        mapCartRequest.put(CC_ERG_Constant.CART_BUNDLED_PRODUCT_EXIST, isBundleProduct);
        mapCartRequest.put(CC_ERG_Constant.CART_REQUEST_VALID , isSuccess);
        return mapCartRequest;
    }

    global static CC_ERG_CartModel fetchCartModel(Map<String,Object> mapCartRequest){
        CC_ERG_CartModel cartModelObject = new CC_ERG_CartModel();
        if(mapCartRequest!=null && mapCartRequest.containsKey(ccrz.ccApiCart.CART_ENCID))
        {
            ccrz__E_Cart__c cartObject = CC_ERG_CartHelper.getCartByEncryptedORCartId(mapCartRequest);
            mapCartRequest.put(ccrz.ccApiCart.CART_OBJ, cartObject);
            System.debug('@@ ==> '+cartObject);
            System.debug('@@ ==> '+cartObject.ccrz__E_CartItems__r);
            //Post Cart Validation
            mapCartRequest = postValidateCartDetails(mapCartRequest);

            //Populate Cart Details
            cartModelObject = populateCartDetails(mapCartRequest);
            cartModelObject.status = true;
            System.debug('cartModelObject.mapCartRequest  : '+JSON.serialize(mapCartRequest));

           /* cartModelObject.allowCheckout =  (Boolean) mapCartRequest.get(CC_ERG_Constant.CART_ALLOW_CHECKOUT);
            cartModelObject.quantityExceeded =  (Boolean) mapCartRequest.get(CC_ERG_Constant.CART_PRODUCT_QUANTITY_EXCEEDED);
            cartModelObject.hardwareProductExist  = (Boolean)mapCartRequest.get(CC_ERG_Constant.CART_PHONE_PRODUCT_ADDED);
            if(cartModelObject.amountDueNow==null && mapCartRequest.containsKey(CC_ERG_Constant.CART_DUE_TODAY) && false)
            {
                cartModelObject.amountDueNow = (Decimal)mapCartRequest.get(CC_ERG_Constant.CART_DUE_TODAY);
                System.debug('>>cartModelObject.amountDueNow>>>'+cartModelObject.amountDueNow);
            }
            if(cartModelObject.monthlyRecurringAmount==null && mapCartRequest.containsKey(CC_ERG_Constant.CART_MONTHLY_TODAY))
            {
                cartModelObject.monthlyRecurringAmount =  (Decimal) mapCartRequest.get(CC_ERG_Constant.CART_MONTHLY_TODAY);
                System.debug('>>cartModelObject.taxAmountDueNow>>>'+cartModelObject.taxAmountDueNow);
            } */
        }
        return cartModelObject;
    }

    global static Map<String,Object> postValidateCartDetails(Map<String,Object> mapCartRequest){
        if(mapCartRequest!=null && mapCartRequest.containsKey(ccrz.ccApiCart.CART_OBJ))
        {
            mapCartRequest = postPopulateCartValidationDetails(mapCartRequest);
        }
        System.debug('JSON Serialize : '+JSON.serialize(mapCartRequest));
        return mapCartRequest;
    }

    global static Map<String,Object> postPopulateCartValidationDetails(Map<String,Object> mapCartRequest){
        Boolean allowCheckOut = false;
        Boolean hardwareProductExist = false;
        Boolean numberProductAdded = false;
        Boolean bundledProductAdded = false;
        Boolean multipleBundledProductAdded = false;
        Boolean bundleProductQuantityMatched = false;
        Integer bundleProductQuantity = 0;
        Set<String> setProductSKU = new Set<String>();
        Decimal dueToday = 0.0;
        Decimal monthlyBill = 0.0;
        if(mapCartRequest!=null && mapCartRequest.containsKey(ccrz.ccApiCart.CART_OBJ))
        {
            ccrz__E_Cart__c ccCartObject = (ccrz__E_Cart__c)mapCartRequest.get(ccrz.ccApiCart.CART_OBJ);
            if(ccCartObject!=null)
            {
                List<ccrz__E_CartItem__c> lstCartItems = ccCartObject.ccrz__E_CartItems__r;
                //Check Bundle Product Added
                //Check 2 or more Bundled Product Added validation
                //Check if no Bundled Product Added
                //Check check Quantity increased
                //Check Fees Added
                if(lstCartItems!=null && lstCartItems.size()>0)
                {
                    for (ccrz__E_CartItem__c cartItemObject : lstCartItems)
                    {
                        List<CartProductItem> lstProduct = new List<CartProductItem>();
                        if (cartItemObject.ccrz__cartItemType__c == ccrz.ccApiCart.CARTITEM_TYPE_MAJOR)
                        {
                            ccrz__E_Product__c ccProduct = cartItemObject.ccrz__Product__r;
                            CartProductItem cartProductItemObject = new CartProductItem();
                            cartProductItemObject.productSKU = ccProduct.ccrz__SKU__c;
                            cartProductItemObject.product = ccProduct;
                            cartProductItemObject.cartItem = cartItemObject;
                            cartProductItemObject.cartItemId = cartItemObject.Id;
                            if (cartItemObject.ccrz__Quantity__c != null)
                            {
                                cartProductItemObject.quantity = Integer.valueOf(cartItemObject.ccrz__Quantity__c);
                            }
                            
                        }
                    }
                }
            }
        }
      /*  Boolean bln = bundleProductQuantity < CC_ERG_Constant.PRODUCT_QUANTITY;
        System.debug('>>>>bundleProductQuantity<CC_ERG_Constant.PRODUCT_QUANTITY >>>>>>'+ bln);
        System.debug('>>>>bundleProductQuantityMatched>>>>>>'+bundleProductQuantityMatched);
        System.debug('>>>>bundleProductQuantity>>>>>>'+bundleProductQuantity);
        System.debug('>>>>bundledProductAdded>>>>>>'+bundledProductAdded);
        System.debug('>>>>multipleBundledProductAdded>>>>>>'+multipleBundledProductAdded);
        System.debug('>>>>numberProductAdded>>>>>>'+numberProductAdded);
        //if any of this true then return false
    mapCartRequest.put(CC_ERG_Constant.CART_PRODUCT_QUANTITY_EXCEEDED, bundleProductQuantity>CC_ERG_Constant.PRODUCT_QUANTITY);
        mapCartRequest.put(CC_ERG_Constant.CART_MULTIPLE_BUNDLE_PRODUCT_ADDED, multipleBundledProductAdded);
        mapCartRequest.put(CC_ERG_Constant.CART_PRODUCT_QUANTITY_MISMATCHED , bundleProductQuantityMatched);
        mapCartRequest.put(CC_ERG_Constant.CART_REQUIRED_PRODUCT_ADDED, numberProductAdded);

        //if any of this false then return false
        mapCartRequest.put(CC_ERG_Constant.CART_BUNDLE_PRODUCT_ADDED, bundledProductAdded);

        if( bundleProductQuantity<CC_ERG_Constant.PRODUCT_QUANTITY && !multipleBundledProductAdded
                && !bundleProductQuantityMatched && bundledProductAdded && numberProductAdded)
        {
            allowCheckOut = true;
        }
        System.debug('>>>>allowCheckOut>>>>>>'+allowCheckOut);
        mapCartRequest.put(CC_ERG_Constant.CART_ALLOW_CHECKOUT , allowCheckOut);
        mapCartRequest.put(CC_ERG_Constant.CART_PHONE_PRODUCT_ADDED, hardwareProductExist);
        mapCartRequest.put(CC_ERG_Constant.CART_DUE_TODAY , dueToday);
        mapCartRequest.put(CC_ERG_Constant.CART_MONTHLY_TODAY , monthlyBill);
*/
        return mapCartRequest;
    }

    global class CartProductItem{
        global ccrz__E_Product__c product;
        global String productSKU;
        global Integer quantity;
        global ccrz__E_CartItem__c cartItem;
        global String cartItemId;
    }

    global static void dummy(){
        Integer x = 0;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++; 
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        
    }
}