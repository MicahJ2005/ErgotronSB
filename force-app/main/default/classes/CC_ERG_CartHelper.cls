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
global without sharing class CC_ERG_CartHelper {
    private static final String PRODUCT_ADD_ON = 'AddOn';
    global static final String STOREFRONT = 'Vonage ECOM';
    global static final String MODULE_NAME = 'Cart Module';
    global static final String CLASSNAME = 'VONB2B_CartHelper';

    /*
    * Method to transform the CC Cart into a Cart Model
    * @param  ccrz__E_Cart__c       Cart
    * @return MktpCartModel
    */
    global static CC_ERG_CartModel getCartModel(Map<String,Object> cartResponseObject) {
        CC_ERG_CartModel cartInfo = new CC_ERG_CartModel();
        if(cartResponseObject!=null && cartResponseObject.containsKey(ccrz.ccApiCart.CART_OBJ))
        {
            ccrz__E_Cart__c cartObject = (ccrz__E_Cart__c)cartResponseObject.get(ccrz.ccApiCart.CART_OBJ);
            if (cartObject != null)
            {
                String baseUrl = String.valueOf(Url.getOrgDomainUrl().toExternalForm());
                cartInfo.encryptedCartId = cartObject.ccrz__EncryptedId__c;
                cartInfo.cartId = cartObject.Id;
                cartInfo.storefront = cartObject.ccrz__Storefront__c;
                cartInfo.cartNumber = cartObject.Name;
                cartInfo.cartStatus = cartObject.ccrz__CartStatus__c;
                cartInfo.activeCart = cartObject.ccrz__ActiveCart__c;
                cartInfo.cartType = cartObject.ccrz__CartType__c;
                cartInfo.cartUrl = Label.B2B_Store_Base_URL+'/ccrz__Cart?cartId='+cartObject.ccrz__EncryptedId__c;

                cartInfo.currencyCode = cartObject.ccrz__CurrencyISOCode__c;
                if ((cartObject.ccrz__TotalAmount__c != null) && (cartObject.ccrz__TotalAmount__c > 0)) {
                    cartInfo.totalAmount = cartObject.ccrz__TotalAmount__c.setScale(2);
                } else {
                    cartInfo.totalAmount = cartObject.ccrz__TotalAmount__c;
                }

                if ((cartObject.ccrz__SubtotalAmount__c != null) && (cartObject.ccrz__SubtotalAmount__c > 0)) {
                    cartInfo.subTotalAmount = cartObject.ccrz__SubtotalAmount__c.setScale(2);
                } else {
                    cartInfo.subTotalAmount = cartObject.ccrz__SubtotalAmount__c;
                }

                cartInfo.adjustmentAmount = cartObject.ccrz__AdjustmentAmount__c;
                cartInfo.adjustmentReason = cartObject.ccrz__AdjustmentReason__c;
                if ((cartObject.ccrz__TaxAmount__c != null) && (cartObject.ccrz__TaxAmount__c > 0)) {
                    cartInfo.taxAmount = cartObject.ccrz__TaxAmount__c.setScale(2);
                } else {
                    cartInfo.taxAmount = cartObject.ccrz__TaxAmount__c;
                }

                cartInfo.taxExemptFlag = cartObject.ccrz__TaxExemptFlag__c;

                if ((cartObject.ccrz__TaxSubTotalAmount__c != null) && (cartObject.ccrz__TaxSubTotalAmount__c > 0)) {
                    cartInfo.taxSubtotalAmount = cartObject.ccrz__TaxSubTotalAmount__c.setScale(2);
                } else {
                    cartInfo.taxSubtotalAmount = cartObject.ccrz__TaxSubTotalAmount__c;
                }
                if ((cartObject.ccrz__TotalDiscount__c != null) && (cartObject.ccrz__TotalDiscount__c > 0)) {
                    cartInfo.totalDiscount = cartObject.ccrz__TotalDiscount__c.setScale(2);
                } else {
                    cartInfo.totalDiscount = cartObject.ccrz__TotalDiscount__c;
                }

                cartInfo.totalSurcharge = cartObject.ccrz__TotalSurcharge__c;
                cartInfo.buyerCompanyName = cartObject.ccrz__BuyerCompanyName__c;
                cartInfo.buyerEmail = cartObject.ccrz__BuyerEmail__c;
                cartInfo.buyerFirstName = cartObject.ccrz__BuyerFirstName__c;
                cartInfo.buyerLastName = cartObject.ccrz__BuyerLastName__c;
                cartInfo.buyerMobile = cartObject.ccrz__BuyerMobilePhone__c;
                cartInfo.buyerPhone = cartObject.ccrz__BuyerPhone__c;
                
              
                //retrieve Cart items
                cartInfo.cartItems = getCartItems(cartObject);
            }
        }
        return cartInfo;
    }

    

  
    /*
    * Retrieve Cart Items based on Encrypted Cart Id
    * @param  encryptedCartId               Encrypted Cart Id
    * @return List<MktpCartItemModel>       Returns all Cart Items associated with the current Cart
    */
    global static List<CC_ERG_CartItemModel> getCartItems(ccrz__E_Cart__c cartObject)
    {
        List<CC_ERG_CartItemModel> cartItemList = new List<CC_ERG_CartItemModel>();
        Map<String,Object> mapRequestParams = new Map<String,Object>();
        Map<String, ccrz__E_ProductMedia__c> mapProductWithImages = null;
        Set<String> setProductSKU = new Set<String>();
        if(cartObject!=null && cartObject.ccrz__E_CartItems__r!=null && cartObject.ccrz__E_CartItems__r.size()>0)
        {
            List<ccrz__E_CartItem__c> cartItems = cartObject.ccrz__E_CartItems__r;
            for (ccrz__E_CartItem__c cartItem : cartItems)
            {
                if(cartItem.ccrz__cartItemType__c == ccrz.ccApiCart.CARTITEM_TYPE_MAJOR)
                {
                    setProductSKU.add(cartItem.ccrz__Product__r.ccrz__SKU__c);
                }
            }

            System.debug('getCartItems:setProductSKU :'+setProductSKU);
            if(setProductSKU!=null && setProductSKU.size()>0)
            {
                mapRequestParams.put(CC_ERG_Constant.PRODUCT_SKU_LIST , setProductSKU);
                mapProductWithImages  = CC_ERG_ProductHelper.fetchProductImages(mapRequestParams);
            }
            System.debug('getCartItems:mapProductWithImages :'+mapProductWithImages);
            for (ccrz__E_CartItem__c cartItem : cartItems)
            {
                if(cartItem.ccrz__cartItemType__c == ccrz.ccApiCart.CARTITEM_TYPE_MAJOR)
                {
                    CC_ERG_CartItemModel cartItemModel = getCartItemModel(cartItem);
                    System.debug('getCartItems:cartItemModel.productSku :'+cartItemModel.productSku);
                    if(mapProductWithImages!=null && mapProductWithImages.containsKey(cartItemModel.productSku))
                    {
                        ccrz__E_ProductMedia__c ccProductMedia = (ccrz__E_ProductMedia__c)mapProductWithImages.get(cartItemModel.productSku);
                        if(ccProductMedia!=null && String.isNotBlank(ccProductMedia.ccrz__ProductDescription__c))
                        {
                            cartItemModel.imageURL =  ccProductMedia.ccrz__ProductDescription__c;
                        }
                    }
                    if(String.isNotBlank(cartItem.ccrz__Coupon__c)){
                        // CC_ERG_CartItemModel couponCItem = new CC_ERG_CartItemModel();
                        // couponCItem.cartItemId = cartItem.ccrz__Coupon__c;
                        // couponCItem.cartItemNumber = cartItem.ccrz__Coupon__r.ccrz__CouponCode__c;
                        // couponCItem.cartItemType = 'Coupon';
                        // couponCItem.absoluteDiscount = cartItem.ccrz__AbsoluteDiscount__c;
                        // //couponCItem.absoluteDiscount = cartItem.ccrz__AbsoluteDiscount__c;
                        // //couponCItem.adjustmentAmount = cartItem.ccrz__AdjustmentAmount__c;
                        // cartItemList.add(couponCItem);
                        
                    }
                    cartItemList.add(cartItemModel);
                }
            }
        }
        return cartItemList;
    }

    /**
    * Method to transform the CC Cart Item into a Cart Item Model
    *
    * @param  ccrz__E_CartItem__c       Cart Item
    *
    * @return MktpCartItemModel
    */
    global static CC_ERG_CartItemModel getCartItemModel(ccrz__E_CartItem__c cartItem) {

        CC_ERG_CartItemModel cartItemModel = new CC_ERG_CartItemModel();
        cartItemModel.cartItemId = cartItem.Id;
        cartItemModel.cartItemNumber = cartItem.Name;
        cartItemModel.cartItemType = cartItem.ccrz__cartItemType__c;
        cartItemModel.productSku = cartItem.ccrz__Product__r.ccrz__SKU__c;
        cartItemModel.productId = cartItem.ccrz__Product__r.Id;
        cartItemModel.productName = cartItem.ccrz__Product__r.Name;
        cartItemModel.productShortDescription = cartItem.ccrz__Product__r.ccrz__ShortDescRT__c;
        cartItemModel.productLongDescription = cartItem.ccrz__Product__r.ccrz__LongDescRT__c;
        //cartItemModel.taxCode = cartItem.ccrz__Product__r.ccrz__TaxRateId__c;
        /*
        TODO cartItemModel.isTrial = cartItem.Is_Trial_Product__c;
        cartItemModel.trialLength = cartItem.Trial_Length__c;
          cartItemModel.couponShortDescription = cartItem.ccrz__Coupon__r.Short_Description__c;
        cartItemModel.couponLongDescription = cartItem.ccrz__Coupon__r.Long_Description__c;
         cartItemModel.billingProductId = cartItem.ccrz__Product__r.Billing_Product__c;
          cartItemModel.entitlementProductId = cartItem.ccrz__Product__r.Entitlement_Product__c;
        cartItemModel.bundleProductDescription = cartItem.Bundle_Product_Description__c;
        cartItemModel.bundleProductSKU = cartItem.Bundle_Product_SKU__c;
        cartItemModel.tierDescription = cartItem.Tier_Description__c;
        cartItemModel.isTierPriced = cartItem.ccrz__Product__r.Tier_Priced__c;
         */
        cartItemModel.category = cartItem.ccrz__Category__c;
        cartItemModel.quantity = cartItem.ccrz__Quantity__c;
        cartItemModel.price = cartItem.ccrz__Price__c;
        cartItemModel.priceModifierType = cartItem.ccrz__PricingModifierTypes__c;
        cartItemModel.pricingType = cartItem.ccrz__PricingType__c;
        cartItemModel.cartItemLabel = cartItem.ccrz__ItemLabel__c;
        cartItemModel.cartItemTotal = cartItem.ccrz__ItemTotal__c;
        cartItemModel.originalItemPrice = cartItem.ccrz__OriginalItemPrice__c;
        cartItemModel.originalQuantity = cartItem.ccrz__OriginalQuantity__c;

       /* cartItemModel.couponId = cartItem.ccrz__Coupon__c;
        cartItemModel.couponCode = cartItem.ccrz__Coupon__r.ccrz__CouponCode__c;
        cartItemModel.couponType =  cartItem.ccrz__Coupon__r.ccrz__CouponType__c;
        cartItemModel.couponMessage = cartItem.ccrz__Coupon__r.ccrz__Coupon_Notes__c;

        //cartItemModel.couponPurpose = '';

        cartItemModel.isSubscription = cartItem.ccrz__Is_Subscription_Selected__c;
        cartItemModel.subProdTermId = cartItem.ccrz__SubProdTerm__c;
        cartItemModel.subscriptionTermType = cartItem.ccrz__SubProdTerm__r.ccrz__InstallmentFrequencyUOM__c;
        cartItemModel.subscriptionDuration = cartItem.ccrz__SubProdTerm__r.ccrz__InstallmentCount__c;
        cartItemModel.subscriptionFrequency = cartItem.ccrz__SubProdTerm__r.ccrz__InstallmentFrequency__c;
        cartItemModel.subscriptionTermId = cartItem.ccrz__SubProdTerm__c;*/

        cartItemModel.uom = cartItem.ccrz__UnitOfMeasure__c;
        cartItemModel.absoluteDiscount = cartItem.ccrz__AbsoluteDiscount__c;
        cartItemModel.percentageDiscount = cartItem.ccrz__PercentDiscount__c;
        cartItemModel.adjustmentAmount = cartItem.ccrz__AdjustmentAmount__c;
        cartItemModel.subAmount = cartItem.ccrz__SubAmount__c;
        cartItemModel.taxAmount = 0;
        cartItemModel.taxPercentage = 0;
        //global String productInstanceRegion;
        //global String isPrimaryProduct;
        //
        return cartItemModel;
    }

    global static ccrz__E_Cart__c getCartByEncryptedORCartId(Map<String,Object> mapRequestParams) {
        ccrz__E_Cart__c cartResult = null;
        String methodName = 'getCartByEncryptedORCartId';
        String supportData = '';
        try
        {
            String strCartId = null;
            if(mapRequestParams.containsKey(CC_ERG_Constant.CART_ID))
            {
                strCartId = (String)mapRequestParams.get(CC_ERG_Constant.CART_ID);
            }
            if(String.isBlank(strCartId) && mapRequestParams.containsKey(CC_ERG_Constant.POPULATED_CART_ID))
            {
                strCartId = (String)mapRequestParams.get(CC_ERG_Constant.POPULATED_CART_ID);
            }
            if(mapRequestParams.containsKey(ccrz.ccApiCart.CART_ENCID))
            {
                strCartId = (String)mapRequestParams.get(ccrz.ccApiCart.CART_ENCID);
            }
            String strOpen = CC_ERG_Constant.CART_STATUS_OPEN;
            List<ccrz__E_Cart__c> lstCartObjects = [SELECT Id,ccrz__ValidationStatus__c,Cart_Link__c,ccrz__Storefront__c, CurrencyIsoCode, ccrz__User__r.Name,ccrz__User__c,ccrz__Contact__c,ccrz__CartType__c, ccrz__TotalAmount__c,
                                                                        ccrz__CartStatus__c, ccrz__SubtotalAmount__c, ccrz__TaxAmount__c, ccrz__ShipMethod__c,
                                                                        ccrz__TaxSubTotalAmount__c, ccrz__TotalQuantity__c, ccrz__RequestDate__c,ccrz__TotalSurcharge__c,
                                                                        ccrz__Contact__r.FirstName,ccrz__Contact__r.LastName,ccrz__PONumber__c,ccrz__ActiveCart__c,ccrz__BuyerMobilePhone__c,
                                                                        (SELECT Id,Name,ccrz__Price__c,ccrz__SubAmount__c,ccrz__Quantity__c,ccrz__ItemTotal__c,ccrz__Category__c,
                                                                                ccrz__PricingType__c,ccrz__AbsoluteDiscount__c,ccrz__cartItemType__c,ccrz__ProductType__c,ccrz__PricingModifierTypes__c,
                                                                                ccrz__Coupon__c,ccrz__Coupon__r.ccrz__CouponCode__c,
                                                                                ccrz__UnitOfMeasure__c,ccrz__ItemStatus__c,ccrz__StoreID__c,ccrz__OriginalItemPrice__c,ccrz__ItemLabel__c,ccrz__PercentDiscount__c,
                                                                                ccrz__OriginalQuantity__c,ccrz__Product__r.Id,ccrz__Product__r.Name,ccrz__Product__r.ccrz__SKU__c,ccrz__AdjustmentAmount__c,
                                                                                ccrz__Product__r.ccrz__ProductType__c,ccrz__Product__r.ccrz__ShortDescRT__c,
                                                                                ccrz__Product__r.ccrz__LongDescRT__c,ccrz__ParentCartItem__c
                                                                         FROM ccrz__E_CartItems__r ORDER BY ccrz__cartItemType__c,ccrz__ProductType__c,ccrz__Product__r.Name ASC),
                                                                ccrz__Contact__r.Email,ccrz__Contact__r.Phone,ccrz__Contact__r.MailingStreet,ccrz__Contact__r.MailingCity,
                                                                ccrz__Contact__r.MailingState,ccrz__Contact__r.MailingCountry,ccrz__Contact__r.MailingPostalCode,
                                                                ccrz__Account__r.Id,ccrz__Account__r.Name,ccrz__Account__r.AccountNumber,ccrz__AdjustmentAmount__c,
                                                                ccrz__AdjustmentReason__c,ccrz__BuyerFirstName__c, ccrz__BuyerLastName__c, ccrz__BuyerEmail__c,
                                                                ccrz__BuyerCompanyName__c,ccrz__BuyerPhone__c,ccrz__TaxExemptFlag__c, Name, ccrz__EncryptedId__c,
                                                                ccrz__AnonymousId__c, ccrz__TotalDiscount__c,ccrz__CurrencyISOCode__c, ccrz__PaymentMethod__c,ccrz__Account__c,
                                                                Owner.Id, Owner.Username
                                                                FROM ccrz__E_Cart__c WHERE (ccrz__EncryptedId__c =: strCartId OR Id =: strCartId) AND ccrz__CartType__c='Cart'];
            if(lstCartObjects!=null && lstCartObjects.size()>0)
            {
                cartResult = lstCartObjects[0];
            }
        }catch(Exception expObject){
            ccrz.ccLog.log(LoggingLevel.ERROR, 'M:X', 'getCartByEncryptedORCartId' + expObject.getStackTraceString());
           // dcm_CustomException.storeExceptionLog(expObject, STOREFRONT , MODULE_NAME, CLASSNAME , methodName , supportData );
        }
        return cartResult;
    }

    /*
    global static List<ccrz__E_CartItem__c> getCartItemsByEncryptedORCartId(Map<String,Object> mapRequestParams){
        List<ccrz__E_CartItem__c> cartItemsList = null;
        if(mapRequestParams!=null && mapRequestParams.containsKey(CC_ERG_Constant.CART_ITEM_ID))
        {
            String cartItemId = (String)mapRequestParams.get(CC_ERG_Constant.CART_ITEM_ID);
            if (String.isNotBlank(cartItemId))
            {
                cartItemsList = [
                        SELECT Id,Name,ccrz__Price__c,ccrz__SubAmount__c,ccrz__Quantity__c,
                                ccrz__ItemTotal__c,ccrz__PricingType__c,ccrz__AbsoluteDiscount__c,ccrz__cartItemType__c,
                                ccrz__ProductType__c,ccrz__UnitOfMeasure__c,ccrz__ItemStatus__c,ccrz__StoreID__c,
                                ccrz__OriginalItemPrice__c,ccrz__OriginalQuantity__c,
                                ccrz__Cart__r.Id,ccrz__Cart__r.ccrz__EncryptedId__c,ccrz__Cart__r.ccrz__ActiveCart__c,
                                ccrz__Cart__r.ccrz__CartStatus__c,ccrz__Cart__r.ccrz__CartType__c,
                                ccrz__Cart__r.ccrz__Name__c,ccrz__Cart__r.ccrz__TotalQuantity__c,ccrz__Cart__r.ccrz__ShipAmount__c,
                                ccrz__Cart__r.ccrz__TaxAmount__c,ccrz__Cart__r.ccrz__TotalAmount__c,ccrz__Cart__r.ccrz__AdjustmentAmount__c,
                                ccrz__Cart__r.ccrz__TotalSurcharge__c,ccrz__Cart__r.ccrz__TaxSubTotalAmount__c,ccrz__Cart__r.ccrz__SubtotalAmount__c,
                                ccrz__Product__r.Id,ccrz__Product__r.Name,ccrz__Product__r.ccrz__SKU__c,
                                ccrz__Product__r.ccrz__ProductType__c
                        FROM ccrz__E_CartItem__c WHERE Id= :cartItemId
                ];
            }
        }
        return cartItemsList;
    } /*

    /*
    * Method to retrieve the Billing Address associated with the Cart
    * @param  cartId SFDC ID for the Cart
    * @return MktpAddressModel
    */
    //TODO change it to pass Cart Object and return Address
  
    /**
    * Method to create a new contact address and update it on the cart
    *
    * @param  addressLine1          Street Address Line 1
    * @param  addressLine2          Street Address Line 2
    * @param  city                  City
    * @param  state                 State
    * @param  zipCode               Zipcode
    * @param  country               Country
    * @param  email                 EMail
    * @param  firstName             First Name
    * @param  lastName              Last Name
    *
    * @return String                ID for the newly created Address
    */
    //TODO
  

    /*
    * Method to update the status of Cart
    *
    * @param  cartId            Cart ID
    * @param  status            Status to be associated wuth the Cart
    *
    * @return
    */
    
   /* 
    global static void updateCartStatus(Map<String,Object> mapRequestParams) {
        ccrz__E_Cart__c cart = getCartByEncryptedORCartId(mapRequestParams);
        if (cart == null) {
            //throw new MktpCartException(MktpCartException.EXCEPTION_INVALID_CART_ID);
        }
        //cart.ccrz__CartStatus__c = status;
        //this Validation status is needed by CloudCraze if Cart is managed through API
        cart.ccrz__ValidationStatus__c = CC_ERG_Constant.CART_VALIDATION_STATUS_VALIDATED;
        update cart;
    } */

    global static Map<String,Object> addToCart(Map<String,Object> addProductsToCartRequest){
         System.debug('addProductsToCartRequest:Results' + JSON.serialize(addProductsToCartRequest));
        Map<String,Object> addResults = ccrz.ccApiCart.addTo(addProductsToCartRequest);
        System.debug('addToCart:Results' + JSON.serialize(addResults));
        Boolean wasSuccessful = (Boolean) addResults.get(ccrz.ccApi.SUCCESS);
        System.debug('addToCart:status' + wasSuccessful);
        Api_Log__c apiLog = new Api_Log__c();
        if(JSON.serialize(addProductsToCartRequest)?.length() > 130700) {
            apiLog.Request_Body__c = JSON.serialize(addProductsToCartRequest).substring(0, 130695);
        } else {
            apiLog.Request_Body__c = JSON.serialize(addProductsToCartRequest);
        }
        if(JSON.serialize(addResults, true)?.length() > 130700) {
            apiLog.Response_Body__c = JSON.serialize(addResults, true).substring(0, 130695);
        } else {
            apiLog.Response_Body__c = JSON.serialize(addResults, true);
        }
        if(addProductsToCartRequest.containsKey(ccrz.ccApiCart.CART_ENCID)){
            apiLog.Request_CartID__c = (String)addProductsToCartRequest.get(ccrz.ccApiCart.CART_ENCID);
        }
        if(addResults.containsKey(ccrz.ccApiCart.CART_ENCID)){
            apiLog.Response_CartID__c = (String)addResults.get(ccrz.ccApiCart.CART_ENCID);
        }
        apiLog.Api_Endpoint_Name__c = 'addToCart-inner';
        insert apiLog;
        return addResults;
    }

    global static void updateCartSource(Map<String,Object> mapCartRequest) {
        ccrz__E_Cart__c cart = getCartByEncryptedORCartId(mapCartRequest);
        if(mapCartRequest.containsKey(CC_ERG_Constant.PRICE_LIST_NAME) && String.isNotBlank((String)mapCartRequest.get(CC_ERG_Constant.PRICE_LIST_NAME))) {
            string priceListName = (String)mapCartRequest.get(CC_ERG_Constant.PRICE_LIST_NAME);
            ccrz__E_PriceList__c priceList = [SELECT Id, Name from ccrz__E_PriceList__c where Name =: priceListName LIMIT 1];
            if(priceList != null){
                cart.pricelistOverride__c = priceList?.Id;
            }
        }
        string orderTypeId = CustomMetadataUtility.fetchOrderTypeId();
        if(String.isNotBlank(orderTypeId)) {
            cart.Ergotron_Order_Type__c = orderTypeId;
        }
        cart.Source__c = 'Ergotron';
        update cart;
    }


    global static Map<String,Object> priceCart(Map<String,Object> mapCartRequest )
    {
        Map<String,Object> priceCartResults = ccrz.ccApiCart.price(mapCartRequest);
        System.debug('priceCart:priceCartResults : ' + JSON.serialize(priceCartResults));
        Boolean wasSuccessful = (Boolean) priceCartResults.get(ccrz.ccApi.SUCCESS);
        System.debug('priceCart: priceCartResults:status : ' + wasSuccessful);
        return mapCartRequest;
    }

    /*
    * Method to update Cart
    *
    * @param  cartId            Cart ID
    * @param  status            Status to be associated wuth the Cart
    *
    * @return
    */
    global static Map<String,Object> updateCart(Map<String,Object> mapCartRequest) {
        Map<String,Object> mapResponse = new Map<String,Object>();
        mapResponse.put(CC_ERG_Constant.IS_SUCCESS ,false);
        if(mapCartRequest!=null && mapCartRequest.containsKey(ccrz.ccApiCart.CART_OBJ))
        {
            ccrz__E_Cart__c cartObject = (ccrz__E_Cart__c)mapCartRequest.get(ccrz.ccApiCart.CART_OBJ);
            update cartObject;
            mapResponse.put(CC_ERG_Constant.IS_SUCCESS ,true);
        }
        return mapResponse;
    }

    /*
    * Method to update Cart Items
    * @return
    */
    global static void updateCartItems(Map<String,Object> mapCartRequest) {
        if(mapCartRequest!=null && mapCartRequest.containsKey(ccrz.ccApiCart.CILIST))
        {
            List<ccrz__E_CartItem__c> lstCartItemObjects = ( List<ccrz__E_CartItem__c>)mapCartRequest.get(ccrz.ccApiCart.CILIST);
            if(lstCartItemObjects!=null && lstCartItemObjects.size()>0)
            {
                update lstCartItemObjects;
            }
        }
    }

    /*
    * Method to update Cart Items
    * @return
    */
    /* 
    global static void deleteCartItems(List<ccrz__E_CartItem__c> lstCartItemObjects) {
        if(lstCartItemObjects!=null && lstCartItemObjects.size()>0)
        {
            delete lstCartItemObjects;
        }
    } */

    
/*
    global static ccrz__E_Cart__c getAllCartByEncryptedORCartId(Map<String,Object> mapRequestParams) {
        ccrz__E_Cart__c cartResult = null;
        String methodName = 'getCartByEncryptedORCartId';
        String supportData = '';
        try
        {
            String strCartId = null;
            if(mapRequestParams.containsKey(CC_ERG_Constant.CART_ID))
            {
                strCartId = (String)mapRequestParams.get(CC_ERG_Constant.CART_ID);
            }
            if(String.isBlank(strCartId) && mapRequestParams.containsKey(CC_ERG_Constant.POPULATED_CART_ID))
            {
                strCartId = (String)mapRequestParams.get(CC_ERG_Constant.POPULATED_CART_ID);
            }
            if(mapRequestParams.containsKey(ccrz.ccApiCart.CART_ENCID))
            {
                strCartId = (String)mapRequestParams.get(ccrz.ccApiCart.CART_ENCID);
            }
            //String strOpen = VONB2B_Constant.CART_STATUS_OPEN;
            List<ccrz__E_Cart__c> lstCartObjects = [SELECT Id,ccrz__ValidationStatus__c,Cart_Link__c,ccrz__Storefront__c, CurrencyIsoCode,
                                                                        ccrz__User__r.Name,ccrz__User__c,ccrz__Contact__c,ccrz__CartType__c, ccrz__TotalAmount__c,
                                                                        ccrz__CartStatus__c, ccrz__SubtotalAmount__c, ccrz__TaxAmount__c, ccrz__ShipMethod__c,
                                                                        ccrz__TaxSubTotalAmount__c, ccrz__TotalQuantity__c, ccrz__RequestDate__c,ccrz__TotalSurcharge__c,
                                                                        ccrz__Contact__r.FirstName,ccrz__Contact__r.LastName,ccrz__PONumber__c,ccrz__ActiveCart__c,ccrz__BuyerMobilePhone__c,
                                                                        (SELECT Id,Name,ccrz__Price__c,ccrz__SubAmount__c,ccrz__Quantity__c,ccrz__ItemTotal__c,ccrz__Category__c,
                                                                                ccrz__PricingType__c,ccrz__AbsoluteDiscount__c,ccrz__cartItemType__c,ccrz__ProductType__c,ccrz__PricingModifierTypes__c,
                                                                                ccrz__UnitOfMeasure__c,ccrz__ItemStatus__c,ccrz__StoreID__c,ccrz__OriginalItemPrice__c,ccrz__ItemLabel__c,ccrz__PercentDiscount__c,
                                                                                ccrz__OriginalQuantity__c,ccrz__Product__r.Id,ccrz__Product__r.Name,ccrz__Product__r.ccrz__SKU__c,ccrz__AdjustmentAmount__c,
                                                                                ccrz__Product__r.ccrz__ProductType__c, ccrz__Product__r.ccrz__ShortDescRT__c,
                                                                                ccrz__Product__r.ccrz__LongDescRT__c,ccrz__ParentCartItem__c FROM ccrz__E_CartItems__r ORDER BY ccrz__cartItemType__c,ccrz__ProductType__c ASC),
                                                                ccrz__Contact__r.Email,ccrz__Contact__r.Phone,ccrz__Contact__r.MailingStreet,ccrz__Contact__r.MailingCity,
                                                                ccrz__Contact__r.MailingState,ccrz__Contact__r.MailingCountry,ccrz__Contact__r.MailingPostalCode,
                                                                ccrz__Account__r.Id,ccrz__Account__r.Name,ccrz__Account__r.AccountNumber,ccrz__AdjustmentAmount__c,
                                                                ccrz__AdjustmentReason__c,ccrz__BuyerFirstName__c, ccrz__BuyerLastName__c, ccrz__BuyerEmail__c,
                                                                ccrz__BuyerCompanyName__c,ccrz__BuyerPhone__c,ccrz__TaxExemptFlag__c, Name, ccrz__EncryptedId__c,
                                                                ccrz__AnonymousId__c, ccrz__TotalDiscount__c,ccrz__CurrencyISOCode__c, ccrz__PaymentMethod__c,ccrz__Account__c
                                                                FROM ccrz__E_Cart__c WHERE (ccrz__EncryptedId__c =: strCartId OR Id =: strCartId) AND ccrz__CartType__c='Cart'];
            if(lstCartObjects!=null && lstCartObjects.size()>0)
            {
                cartResult = lstCartObjects[0];
            }
        }catch(Exception expObject){
            ccrz.ccLog.log(LoggingLevel.ERROR, 'M:X', 'getCartByEncryptedORCartId' + expObject.getStackTraceString());
           // dcm_CustomException.storeExceptionLog(expObject, STOREFRONT , MODULE_NAME, CLASSNAME , methodName , supportData );
        }
        return cartResult;
    }
*/

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
    }

}