global class CC_ERG_Header_PLOT {
  public Boolean isGuest { get; private set; }

  public Boolean isCSR { get; private set; }

  public Boolean isExternalCart { get; private set; }

  public String portalUser { get; private set; }

  public Integer lenportalUser { get; private set; }

  public String encCartId { get; private set; }

  public static String getLogoURL() {
    return label.ERG_B2B_Continue_Shopping_Link;
  }

  public List<Header_Link__mdt> headerLinks;

  public List<Header_Link__mdt> getHeaderLinks() {
    return headerLinks;
  }

  public List<Top_Header_Link__mdt> topHeaderLinks;

  public List<Top_Header_Link__mdt> getTopHeaderLinks() {
    return topHeaderLinks;
  }

  public Decimal cartTotalQuantity;

  public Decimal getCartTotalQuantity() {
    return cartTotalQuantity;
  }

  public string theOrderType;

  public string gettheOrderType() {
    return theOrderType;
  }

  public string thePriceList;

  public string getthePriceList() {
    return thePriceList;
  }

  public CC_ERG_Header_PLOT() {
    headerLinks = [
      SELECT Link__c, Sequence__c, DeveloperName, Label
      FROM Header_Link__mdt
      ORDER BY Sequence__c ASC
    ];

    topHeaderLinks = [
      SELECT Link__c, Sequence__c, DeveloperName, Label
      FROM Top_Header_Link__mdt
      ORDER BY Sequence__c ASC
    ];

    try {
      portalUser = ApexPages.currentPage().getParameters().get('portalUser');
      String source = ApexPages.currentPage().getParameters().get('source');
      String cartId = ApexPages.currentPage().getParameters().get('cartId');
      String orderId = ApexPages.currentPage().getParameters().get('o');

      System.debug('==>' + cartId);
      isCSR = ccrz.cc_CallContext.isOnBehalf;
      isGuest = ccrz.cc_CallContext.isGuest;
      isExternalCart = false;

     /* if (!isGuest && !isCSR  && String.isBlank(cartId) || cartId == 'undefined') {
        Map<String, Object> paramMap = new Map<String, Object>();
        paramMap.put(ccrz.ccApi.API_VERSION, ccrz.ccApi.CURRENT_VERSION);
        Map<String, Object> cartDetail = ccrz.ccApiCart.getActive(paramMap);
        System.debug(cartDetail);
        if (cartDetail?.size() > 0) {
          Object cartObj = cartDetail.get('cartList');
          System.debug(cartObj);
          List<JsonParserClass> jsonObj = (List<JsonParserClass>) JSON.deserialize(
            JSON.serialize(cartObj),
            List<JsonParserClass>.class
          );
          System.debug(jsonObj);
          encCartId = jsonObj?.get(0)?.encryptedId;
        }
      } else {
        encCartId = cartId;
      }*/

      if (String.isBlank(cartId) && String.isNotBlank(orderId)) {
        List<ccrz__E_Order__c> orderlist = [
          SELECT id, ccrz__OriginatedCart__r.ccrz__EncryptedId__c
          FROM ccrz__E_Order__c
          WHERE Id = :orderId OR ccrz__EncryptedId__c = :orderId
        ];
        if (orderlist.size() > 0) {
          cartId = orderlist[0].ccrz__OriginatedCart__r.ccrz__EncryptedId__c;
        }
      }
      portalUser = ApexPages.currentPage().getParameters().get('portalUser');
      ccrz.ccLog.log(
        System.LoggingLevel.DEBUG,
        'M:X',
        'CC_ERG_ctrl_ReviewCart:dasd ==> ' + portalUser
      );
      if (cartId != null) {
        ccrz__E_Cart__c currentCart = [
          SELECT id, Source__c
          FROM ccrz__E_Cart__c
          WHERE Id = :cartId OR ccrz__EncryptedId__c = :cartId
        ];
        if (
          currentCart != null &&
          currentCart.Source__c != null &&
          currentCart.Source__c.equalsIgnoreCase('ergotron')
        ) {
          isExternalCart = true;
        }
        System.debug('isExternalCart ' + isExternalCart);
        if (source != null && source.equalsIgnoreCase('ergotron')) {
          isExternalCart = true;
        }
        if (portalUser != null && portalUser == '') {
          lenportalUser = 0;
          isCSR = false;
        } else {
          lenportalUser = portalUser.length();
          isCSR = true;
        }
      }
    } catch (Exception e) {
      ccrz.ccLog.log(
        System.LoggingLevel.DEBUG,
        'M:X',
        'CC_ERG_ctrl_ReviewCart:sendOrderToCustomer exception ' + e
      );
      system.debug('exception ==> ' + e);
      lenportalUser = 0;
      isCSR = false;
    } finally {
      ccrz.ccLog.log(
        System.LoggingLevel.DEBUG,
        'M:X',
        'CC_ERG_ctrl_ReviewCart:sendOrderToCustomer'
      );
    }

    theOrderType = 'Undefined';
    thePriceList = 'Undefined';

    if (ccrz.cc_CallContext.currCartId == null) {
      theOrderType = 'Undefined';
      thePriceList = 'Undefined';
    } else {
      List<ccrz__E_Cart__c> listCart = [
        SELECT
          priceListOverride__c,
          Ergotron_Order_Type__c,
          (
            SELECT ccrz__ItemTotal__c,ccrz__Quantity__c, ccrz__ProductType__c
            FROM ccrz__E_CartItems__r
            WHERE ccrz__ProductType__c = 'Product'
          )
        FROM ccrz__E_Cart__c
        WHERE ccrz__EncryptedId__c = :ccrz.cc_CallContext.currCartId
      ];
      
      List<ccrz__E_CartItem__c> cartItemList = [SELECT ccrz__ItemTotal__c,ccrz__Quantity__c, ccrz__ProductType__c FROM ccrz__E_CartItem__c
            WHERE ccrz__ProductType__c = 'Product' AND ccrz__Cart__r.ccrz__EncryptedId__c = :ccrz.cc_CallContext.currCartId];

      /*
             string tmp;
             tmp = ccrz.cc_CallContext.currCartId;
             ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'debug__ CC_ERG_ctrl_PDP: '+tmp);
             ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'debug__ CC_ERG_ctrl_PDP: SELECT Ergotron_Order_Type__c FROM ccrz__E_Cart__c WHERE ccrz__EncryptedId__c =:ccrz.cc_CallContext.currCartId');
             */

      string theOrderType_id = '';
      string thePriceList_id = '';

      if (listCart.size() > 0) {
        cartTotalQuantity = 0;
        for (ccrz__E_Cart__c theCart : listCart) {
          theOrderType_id = theCart.Ergotron_Order_Type__c;
          thePriceList_id = theCart.priceListOverride__c;
          /*if (theCart.ccrz__E_CartItems__r?.size() > 0) {
            cartTotalQuantity += theCart.ccrz__E_CartItems__r?.size();
          }*/
        }
        if (cartItemList.size() > 0) {
            for(ccrz__E_CartItem__c ci : cartItemList){
                if(ci?.ccrz__Quantity__c != null){
                    cartTotalQuantity += ci?.ccrz__Quantity__c;
                }
            }
        }
      } else {
        theOrderType_id = '';
        thePriceList_id = '';
        cartTotalQuantity = 0;
      }

      theOrderType = 'Undefined';
      thePriceList = 'Undefined';

      /*
             ID anID;

             anID = theOrderType_id;

             Ordertype = 2865 Pricelist = a5v4F0000001EDaQAM
             List<Oracle_Order_Type__c> orderTypes = [SELECT Name FROM Oracle_Order_Type__c WHERE Order_Type_id__c ='2865' ];
             */

      List<Oracle_Order_Type__c> theOrderTypeDetails = [
        SELECT Name
        FROM Oracle_Order_Type__c
        WHERE Order_Type_id__c = :theOrderType_id
      ];

      /*
             ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'debug__ CC_ERG_ctrl_PDP: SELECT Name FROM Oracle_Order_Type__c WHERE Order_Type_id__c =\''+theOrderType_id+'\'');
             List has no rows for assignment to SObject
             An unexpected error has occurred. Your development organization has been notified.
             */
      theOrderType = theOrderTypeDetails.size() > 0
        ? theOrderTypeDetails[0].Name
        : 'undefined';

      /*
             ccrz__E_PriceList__c
             List<ccrz__E_PriceList__c> priceLists = [SELECT Name FROM ccrz__E_PriceList__c WHERE ID ='a5v4F0000001EDaQAM' ];
             */

      List<ccrz__E_PriceList__c> thePriceListDetails = [
        SELECT Name
        FROM ccrz__E_PriceList__c
        WHERE ID = :thePriceList_id
      ];
      thePriceList = thePriceListDetails.size() > 0
        ? thePriceListDetails[0].Name
        : 'undefined';
    }
  }
  @RemoteAction
  global static String fetchOrderNumber(String orderId) {
    Map<String, Object> orderFetchQuery = new Map<String, Object>{
      ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
      ccrz.ccApiOrder.PARAM_ORDER_ID_LIST => new Set<String>{ orderId }
    };
    try {
      Map<String, Object> orderFetchResults = ccrz.ccApiOrder.fetch(
        orderFetchQuery
      );
      if (orderFetchResults.get(ccrz.ccApiOrder.ORDERLIST) != null) {
        List<Map<String, Object>> outputOrdersList = (List<Map<String, Object>>) orderFetchResults.get(
          ccrz.ccApiOrder.ORDERLIST
        );
        String orderNumber = String.valueOf(
          outputOrdersList?.get(0)?.get('orderNumber')
        );
        String cart = (String) outputOrdersList?.get(0)?.get('encryptedId');
        return cart + '=' + orderNumber;
      }
    } catch (Exception e) {
      System.debug(e + 'line number' + e.getLineNumber());
    }
    return '';
  }

  @RemoteAction
    global static Map<String,Object> fetchPliOfProd(string sfid, List<String> prodIds){
        system.debug('sfid : '+sfid);
        Map<String,Object> result = new Map<String,Object>();
        Map<String, Decimal> mapOfSku = new Map<String, Decimal>();
        List<ccrz__E_Product__c> filteredProdList = new List<ccrz__E_Product__c>();
        map<id,decimal> prodIdSeqMap = new map<id,decimal>();
        Decimal inventoryLimit = 10;
        try{
          List<String> relProdIds = new List<String>();
          //Fetch Related Prod PLI and Prod Detail 
          if(!prodIds.isEmpty() && !String.isBlank(sfid)){
            List<ccrz__E_RelatedProduct__c> relProdList = [SELECT id, Name,ccrz__RelatedProduct__r.ccrz__AlternateName__c, 
            ccrz__Sequence__c, ccrz__RelatedProduct__r.ccrz__SKU__c , ccrz__RelatedProduct__c,
            ccrz__Product__c FROM ccrz__E_RelatedProduct__c  where ccrz__Product__c =:sfid AND ccrz__Enabled__c = true 
               AND ccrz__StartDate__c <= Today AND ccrz__EndDate__c >= Today AND ccrz__RelatedProduct__c NOT IN: prodIds 
               order By ccrz__Sequence__c ASC ];
            
            For(ccrz__E_RelatedProduct__c relProd : relProdList){
              relProdIds.add(relProd.ccrz__RelatedProduct__c);
              prodIdSeqMap.put(relProd.ccrz__RelatedProduct__c, relProd.ccrz__Sequence__c);
            }
  
            if(!relProdIds.isEmpty()){
              List<ccrz__E_Product__c> prodList = [SELECT id, Name,ccrz__AlternateName__c,ccrz__SKU__c,External_URL__c,
              (SELECT ccrz__ProductItem__r.ccrz__SKU__c, ccrz__InventoryLocationCode__c, ccrz__QtyAvailable__c, 
              ccrz__Status__c from ccrz__Product_Inventory_Items__r ),
              (SELECT id, Name, ccrz__Price__c   from ccrz__E_PriceListItems__r where ccrz__Pricelist__r.Name = 'US Ergotron Store' 
                AND ccrz__StartDate__c <= Today AND ccrz__EndDate__c >= Today  ),
                (select id,ccrz__RelatedProduct__c,ccrz__Sequence__c from ccrz__E_RelatedProducts__r),
              (select Id, ccrz__URI__c from ccrz__E_ProductMedias__r) from ccrz__E_Product__c where Id IN : relProdIds AND
              ccrz__ProductStatus__c = 'Released' order by Id];

              List<ccrz__E_Configuration__c> invLimit =[SELECT Name, ccrz__ConfigurationMeta__r.name, ccrz__TextValue__c FROM ccrz__E_Configuration__c where ccrz__ConfigurationMeta__r.name = 'Inventory Limit'];
              if(!invLimit.isEmpty()){
                  inventoryLimit = Decimal.valueOf(invLimit[0].ccrz__TextValue__c);
              }
  
              // List<ccrz__E_PriceListItem__c> pliIds = [SELECT id, Name, ccrz__Price__c ,ccrz__Product__r.ccrz__AlternateName__c, ccrz__Product__r.ccrz__SKU__c 
              //   from ccrz__E_PriceListItem__c where ccrz__Product__c  ='a6K1M000000TZ3I' AND ccrz__Pricelist__r.Name = 'US Ergotron Store' 
              //     AND ccrz__StartDate__c <= Today AND ccrz__EndDate__c >= Today ];
  
              if(!prodList.isEmpty()){
                for(ccrz__E_Product__c prod : prodList){
                  Decimal count = 0;
                  if(!prod.ccrz__E_PriceListItems__r.isEmpty()){
                    if(!prod.ccrz__Product_Inventory_Items__r.isEmpty()){
                      for(ccrz__E_ProductInventoryItem__c inv : prod.ccrz__Product_Inventory_Items__r){
                        if(prod.ccrz__SKU__c == inv.ccrz__ProductItem__r.ccrz__SKU__c){
                          count += inv.ccrz__QtyAvailable__c;
                        }
                      }  
                    }
                  }
                  mapOfSku.put((String)prod.ccrz__SKU__c, count);
                }
                system.debug('mapOfSku : '+mapOfSku);
                if(!mapOfSku.isEmpty()){
                  for(ccrz__E_Product__c prod : prodList){
                    if(mapOfSku.get(prod.ccrz__SKU__c) > inventoryLimit){
                      if(filteredProdList.size() < 3){
                        if(prodIdSeqMap.keySet().contains(prod.id))
                          filteredProdList.add(prod);
                      }
                    }
                  }
                }
                //inventoryLimit
                result.put('success', true);
                result.put('prodList', filteredProdList);
              }
            }
          }
        }catch(Exception ex){
            system.debug('ex: '+ex);
            result.put('success', false);
        }

        return result;

    }

    @RemoteAction
    global static Map<String,Object> addToCartRelProd(string sku, String cartId){
      Map<String,Object> result = new Map<String,Object>();
      if(! String.isBlank(sku) && !String.isBlank(cartId)){
        system.debug('sku : '+sku);
        Boolean wasSuccessful = false;
        Map<String, Object> newSKUToAdd = new Map<String, Object> {
            ccrz.ccApiCart.LINE_DATA_SKU => sku,
            ccrz.ccApiCart.LINE_DATA_QUANTITY => 1
        };

        Map<String, Object> cartItemsToAdd = new Map<String, Object> {
            ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
            ccrz.ccApiCart.CART_ENCID => cartId,
            ccrz.ccApiCart.LINE_DATA => new List<Map<String, Object>> {newSKUToAdd}
        };

        try {
            Map<String, Object> addToCartResults = ccrz.ccApiCart.addTo(cartItemsToAdd);
            wasSuccessful = (Boolean)addToCartResults.get(ccrz.ccApi.SUCCESS);
            result.put('success', true);
        } catch (Exception ex) {
            // Error handling...
            system.debug('ex: '+ex);
            result.put('success', false);
        }
      }
        
        return result;
    }
    
    /**
     * @author R1
     * @description Method for updating the order as authorized in case of Stripe CC Payment
     * @param orderId
     * @return Map<String,Object>
    **/
    @RemoteAction
    global static Map<String,Object> setOrderAsAuthorized(String orderId){
        Map<String,Object> response = new Map<String,Object>();
        ccrz__E_Order__c order = [SELECT Id,Stripe_Payment_Status__c FROM ccrz__E_Order__c WHERE Id = :orderId LIMIT 1];
        if(String.isBlank(order.Stripe_Payment_Status__c)){
            update new ccrz__E_Order__c(Id = order.Id, Stripe_Payment_Status__c = 'Authorized');
        }
        response.put('success',true);
        return response;
    }

  public class JsonParserClass {
    String encryptedId { get; set; }
  }
}