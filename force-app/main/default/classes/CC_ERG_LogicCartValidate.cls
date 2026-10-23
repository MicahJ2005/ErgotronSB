global without sharing class CC_ERG_LogicCartValidate extends ccrz.ccLogicCartValidate {
  // 2020.02.12 13:14 MST
  // The purpose of this override is to check for two conditions: 1) The cart ergotron warehouse Id has not been defined, and
  // 2) the timestamp on the cartItem is older than 24 hours.  If any cartItem fails this validation, we prevent checkout and
  // put messages on the cartItems.
  global override Map<String, Object> processValidate(
    Map<String, Object> inputData
  ) {
    ccrz.ccLog.log(
      System.LoggingLevel.DEBUG,
      'M:E',
      'CC_ERG_LogicCartValidate#processValidate'
    );

    Boolean boolAllowCheckout = true;
    Decimal inventoryLimit = 10;
    String inventoryMsg = '';
    String strClassName; // The cartitem validation error message class
    String strMsg; // Used build the message to send to the cart when validation fails
    Map<String, Object> outputData = super.processValidate(inputData);
    System.debug('----@@' + inputData);
    System.debug('----@@' + outputData);
    List<ccrz.cc_bean_Message> messages = (List<ccrz.cc_bean_Message>) outputData.get(
      'messages'
    );
    System.debug('----' + messages);
    List<Map<String, Object>> outputCartList = (List<Map<String, Object>>) inputData.get(
      ccrz.ccApiCart.CART_OBJLIST
    );
    System.debug('----' + outputCartList);
    String cartId;
    if (outputCartList == null || outputCartList.size() > 0)
      cartId = (String) outputCartList[0].get('sfid');
    if (String.isBlank(cartId)) {
      String cartEncId = (String) inputData.get('cartId');
      cartId = [
        SELECT Id
        FROM ccrz__E_Cart__c
        WHERE ccrz__EncryptedId__c = :cartEncId
        LIMIT 1
      ]
      .Id;
    }

    if (null == messages) {
      new List<ccrz.cc_bean_Message>();
    }

    if (String.isNotBlank(cartId)) {
      List<ccrz__E_CartItem__c> listItemsToUpdate = new List<ccrz__E_CartItem__c>();
      String cartSource =  [SELECT Id,Source__c FROM ccrz__E_Cart__c WHERE Id = :cartId LIMIT 1].Source__c;
      List<ccrz__E_CartItem__c> cartItems = [
        SELECT
          Id,
          ergo_wh_location__c,
          LastModifiedDate,
          ccrz__ItemStatus__c,
          ccrz__Product__r.ccrz__SKU__c,
          ccrz__Cart__r.Source__c,
          ccrz__cartItemType__c,
          ccrz__Product__c
        FROM ccrz__E_CartItem__c
        WHERE
          ccrz__Product__r.cc_NonInventory_Fl__c = FALSE
          AND ccrz__Cart__r.Id = :cartId
      ];
      boolean boolHasNotExpired = true;
      Map<Id, Id> cartProductIds = new Map<Id, Id>();
	   System.debug('----' + cartItems);
      for (ccrz__E_CartItem__c currCartItem : cartItems) {
        if (
          String.isNotBlank(currCartItem.ccrz__Product__c) &&
          !currCartItem.ccrz__cartItemType__c?.equalsignorecase('Coupon')
        ) {
          cartProductIds.put(currCartItem.ccrz__Product__c, currCartItem.Id);
        }

        strClassName = null;
        strMsg = null;

        if (
          currCartItem.ccrz__Cart__r.Source__c
            ?.equalsIgnoreCase('salesforce') &&
          String.isBlank(currCartItem.ergo_wh_location__c) &&
          !currCartItem.ccrz__cartItemType__c?.equalsignorecase('Coupon')
        ) {
          boolAllowCheckout = false;
          strMsg = 'Warehouse has not been selected. ';
        }

        if (currCartItem.LastModifiedDate.addHours(24) < System.now()) {
          boolHasNotExpired = false;
          strMsg += 'Timestamp has expired.';
        }

        if (String.isNotBlank(strMsg)) {
          // Add a message to be displayed on the cartItem record.
          ccrz.cc_bean_Message msg = new ccrz.cc_bean_Message(
            strMsg,
            ccrz.cc_bean_Message.MessageSeverity.ERROR
          );
          msg.type = ccrz.cc_bean_Message.MessageType.CUSTOM;
          strClassName =
            'messagingSection-' +
            String.valueOf(currCartItem.Id) +
            '-Error';
          msg.classToAppend = strClassName;
          messages.add(msg);
        }
      } // end loop

      boolAllowCheckout &= boolHasNotExpired;

      if (!boolAllowCheckout) {
        // Add a message to be displayed on the Cart header messages area.
        outputData.put(ccrz.ccApiCart.ALLOW_CHECKOUT, false);
        ccrz.cc_bean_Message msg = new ccrz.cc_bean_Message(
          'This cart contains items that need to be updated before checkout can proceed.',
          ccrz.cc_bean_Message.MessageSeverity.ERROR
        );
        msg.type = ccrz.cc_bean_Message.MessageType.CUSTOM;
        msg.classToAppend = 'messagingSection-Error';
        messages.add(msg);
      } else {
        outputData.put(ccrz.ccApiCart.ALLOW_CHECKOUT, true);
      }

      if (cartSource.equalsIgnoreCase('Ergotron')){ 
        if (cartProductIds?.size() > 0) {
          List<ccrz__E_Configuration__c> invLimit =[SELECT Name, ccrz__ConfigurationMeta__r.name, ccrz__TextValue__c FROM ccrz__E_Configuration__c where ccrz__ConfigurationMeta__r.name = 'Inventory Limit'];
          if(!invLimit.isEmpty()){
              inventoryLimit = Decimal.valueOf(invLimit[0].ccrz__TextValue__c);
          }
          List<ccrz__E_PageLabel__c> pageLabel =  [SELECT Id, Name, ccrz__ValueRT__c FROM ccrz__E_PageLabel__c where Name = 'ERG_inventoryremove'];
          if(!pageLabel.isEmpty()){
              inventoryMsg = pageLabel[0].ccrz__ValueRT__c;
          }
          System.debug('@@' + cartProductIds);
          strMsg = '';
          List<ccrz__E_Product__c> productList = [
            SELECT
              Id,
              Name,
              (SELECT ccrz__QtyAvailable__c FROM ccrz__Product_Inventory_Items__r)
            FROM ccrz__E_Product__c
            WHERE Id IN :cartProductIds.keySet()
          ];

          if (productList?.size() > 0) {
            System.debug('@@' + productList);
            for (ccrz__E_Product__c ccProductObject : productList) {
              String cartItemIdOfProduct = cartProductIds.get(ccProductObject.Id);
              if (ccProductObject.ccrz__Product_Inventory_Items__r?.size() > 0) {
                Decimal quantity = 0;
                for (
                  ccrz__E_ProductInventoryItem__c obj : ccProductObject.ccrz__Product_Inventory_Items__r
                ) {
                  quantity += obj.ccrz__QtyAvailable__c;
                }
                System.debug('@@' + quantity);
                if (quantity < inventoryLimit) {
                  outputData.put(ccrz.ccApiCart.ALLOW_CHECKOUT, false);
                  strMsg += inventoryMsg;                                                   //'Sorry, this item is out of stock. Please remove this item from your cart to continue.';
                  ccrz.cc_bean_Message msg = new ccrz.cc_bean_Message(
                    strMsg,
                    ccrz.cc_bean_Message.MessageSeverity.ERROR
                  );
                  msg.type = ccrz.cc_bean_Message.MessageType.CUSTOM;
                  strClassName =
                    'messagingSection-' +
                    cartItemIdOfProduct +
                    '-Error';
                  msg.classToAppend = strClassName;
                  messages.add(msg);
                }
              } else {
                outputData.put(ccrz.ccApiCart.ALLOW_CHECKOUT, false);
                strMsg += inventoryMsg;                                                       //'Sorry, this item is out of stock. Please remove this item from your cart to continue.';
                ccrz.cc_bean_Message msg = new ccrz.cc_bean_Message(
                  strMsg,
                  ccrz.cc_bean_Message.MessageSeverity.ERROR
                );
                msg.type = ccrz.cc_bean_Message.MessageType.CUSTOM;
                strClassName =
                  'messagingSection-' +
                  cartItemIdOfProduct +
                  '-Error';
                msg.classToAppend = strClassName;
                messages.add(msg);
              }
            }
          }
        }
      }

    }

    outputData.put(ccrz.ccApi.MESSAGES, messages);
    ccrz.ccLog.log(
      System.LoggingLevel.DEBUG,
      'M:X',
      'CC_ERG_LogicCartValidate#processValidate'
    );

    System.debug('----@@' + outputData);
    return outputData;
  }
}