/**
 * @description       : 
 * @author            : Raziya Gurramkonda
 * @group             : 
 * @last modified on  : 11-17-2020
 * @last modified by  : Raziya Gurramkonda
 * Modifications Log 
 * Ver   Date         Author               Modification
 * 1.0   11-17-2020   Raziya Gurramkonda   Initial Version
**/
global without sharing class CC_ERG_PricingService {
    
    /* global static CC_ERG_PricingVO populateProductPricing(ccrz__E_PriceListItem__c priceListItemObject)
    {
        CC_ERG_PricingVO productPricingObject = new CC_ERG_PricingVO();
        if(priceListItemObject!=null)
        {
            productPricingObject.recurringPrice = priceListItemObject.ccrz__RecurringPrice__c;
            productPricingObject.price = priceListItemObject.ccrz__Price__c;
        }
        return productPricingObject;
    } */

    global static CC_ERG_PricingVO populateProductPricing(ccrz__E_PriceListItem__c priceListItemObject,map<String,Object> reqMap)
    {
        CC_ERG_PricingVO productPricingObject = new CC_ERG_PricingVO();
        if(priceListItemObject!=null)
        {
            productPricingObject = CC_ERG_PricingVO.parsePricing(priceListItemObject,reqMap);
        }
        return productPricingObject;
    }

/*     global static  Map<String, ccrz__E_PriceListItem__c> retrievePriceListBySKU(Map<String,Object> mapParams)
    {
        ccrz.ccLog.log(LoggingLevel.DEBUG, 'M:X:product fetching entitlement retrievePriceListBySKU mapParams: ',
                JSON.serialize(mapParams));
        Map<String,ccrz__E_PriceListItem__c> mapPriceListItemBySKU = new Map<String,ccrz__E_PriceListItem__c>();
        List<ccrz__E_PriceGroupPricelist__c> lstPriceGroupPricelists = fetchPriceList(mapParams);
        if(lstPriceGroupPricelists!=null && lstPriceGroupPricelists.size()>0)
        {
            ccrz.ccLog.log(LoggingLevel.DEBUG, 'M:X:product fetching entitlement retrievePriceListBySKU lstPriceGroupPricelists: ',
                    JSON.serialize(lstPriceGroupPricelists));
            ccrz__E_PriceList__c ccPriceListObj = lstPriceGroupPricelists[0].ccrz__Pricelist__r;
            if(ccPriceListObj!=null)
            {
                mapParams.put(CC_ERG_Constant.PRICE_LIST_ID , ccPriceListObj.Id);
                List<ccrz__E_PriceListItem__c> lstPriceListItems  = fetchPriceListItemByProducts(mapParams);
                if(lstPriceListItems!=null && lstPriceListItems.size()>0)
                {
                    for(ccrz__E_PriceListItem__c ccPriceListItem : lstPriceListItems)
                    {
                        mapPriceListItemBySKU.put(ccPriceListItem.ccrz__Product__r.ccrz__SKU__c , ccPriceListItem);
                    }
                }
            }
        }
        System.debug('mapPriceListItemBySKU  : '+JSON.serialize(mapPriceListItemBySKU));
        return mapPriceListItemBySKU;
    }
 */

    global static  List<ccrz__E_PriceGroupPricelist__c> fetchPriceList(Map<String,Object> mapParams)
    {
        List<ccrz__E_PriceGroupPricelist__c> priceGroupPriceList = null;
        ccrz.ccLog.log(LoggingLevel.DEBUG, 'M:X:product fetching entitlement mapParams price group Id : ',
                mapParams.get(CC_ERG_Constant.PRICE_GROUP_ID));
        ccrz.ccLog.log(LoggingLevel.DEBUG, 'M:X:product fetching entitlement fetchPriceList storefront name: ',
                mapParams.get(CC_ERG_Constant.STOREFRONT_NAME));
        if(mapParams!=null && mapParams.size()>0 &&
                mapParams.containsKey(CC_ERG_Constant.PRICE_GROUP_ID) &&
                mapParams.containsKey(CC_ERG_Constant.STOREFRONT_NAME) &&
                String.isNotBlank((String)mapParams.get(CC_ERG_Constant.PRICE_GROUP_ID)) &&
                String.isNotBlank((String)mapParams.get(CC_ERG_Constant.STOREFRONT_NAME)))
        {
            String priceGroupId = (String)mapParams.get(CC_ERG_Constant.PRICE_GROUP_ID);
            String storeFrontName = '%' + (String)mapParams.get(CC_ERG_Constant.STOREFRONT_NAME) + '%';
            priceGroupPriceList = [SELECT Id, ccrz__Pricelist__c, ccrz__Pricelist__r.Id,ccrz__Pricelist__r.Name FROM ccrz__E_PriceGroupPricelist__c
            WHERE ccrz__PriceGroup__c = :priceGroupId AND ccrz__Enabled__c = TRUE
            AND (ccrz__EffectiveStart__c <= TODAY AND ccrz__EffectiveEnd__c >= TODAY)
            AND ccrz__Pricelist__r.ccrz__Enabled__c = TRUE AND
            (ccrz__Pricelist__r.ccrz__StartDate__c <= TODAY AND ccrz__Pricelist__r.ccrz__EndDate__c >= TODAY)
            AND ccrz__Storefront__c LIKE :storeFrontName];
            ccrz.ccLog.log(LoggingLevel.DEBUG, 'M:X:product fetching entitlement fetchPriceList priceGroupPriceList: ',
                    JSON.serialize(priceGroupPriceList));
        }
        return priceGroupPriceList;
    }

    global static  Map<String, ccrz__E_PriceListItem__c> fetchPriceListItemsBySKU(Map<String,Object> mapParams)
    {
        ccrz.ccLog.log(LoggingLevel.DEBUG, 'M:X:product fetching entitlement retrievePriceListBySKU mapParams: ',
                JSON.serialize(mapParams));
        Map<String,ccrz__E_PriceListItem__c> mapPriceListItemBySKU = new Map<String,ccrz__E_PriceListItem__c>();
        if(mapParams!=null && mapParams.size()>0 && mapParams.containsKey(CC_ERG_Constant.PRICE_LIST_ID))
        {
            List<ccrz__E_PriceListItem__c> lstPriceListItems  = fetchPriceListItemByProducts(mapParams);
            if(lstPriceListItems!=null && lstPriceListItems.size()>0)
            {
                for(ccrz__E_PriceListItem__c ccPriceListItem : lstPriceListItems)
                {
                    mapPriceListItemBySKU.put(ccPriceListItem.ccrz__Product__r.ccrz__SKU__c , ccPriceListItem);
                }
            }
        }
        System.debug('mapPriceListItemBySKU  : '+JSON.serialize(mapPriceListItemBySKU));
        return mapPriceListItemBySKU;
    }

    global static  Map<String, List<ccrz__E_PriceListItem__c>> fetchAllPriceListItemsBySKU(Map<String,Object> mapParams)
    {
        system.debug('*** mapParams'+JSON.serialize(mapParams));
        Map<String,List<ccrz__E_PriceListItem__c>> mapPriceListItemBySKU = new Map<String,List<ccrz__E_PriceListItem__c>>();
        if(mapParams!=null && mapParams.size()>0 && mapParams.containsKey(CC_ERG_Constant.PRICE_LIST_ID))
        {
            List<ccrz__E_PriceListItem__c> lstPriceListItems  = fetchAllPriceListItemByProducts(mapParams);
            if(lstPriceListItems!=null && lstPriceListItems.size()>0)
            {
                for(ccrz__E_PriceListItem__c ccPriceListItem : lstPriceListItems)
                {
                    if(mapPriceListItemBySKU.containsKey(ccPriceListItem.ccrz__Product__r.ccrz__SKU__c)){
                        List<ccrz__E_PriceListItem__c> tempList = mapPriceListItemBySKU.get(ccPriceListItem.ccrz__Product__r.ccrz__SKU__c);
                        tempList.add(ccPriceListItem);
                        mapPriceListItemBySKU.put(ccPriceListItem.ccrz__Product__r.ccrz__SKU__c , tempList);
                    }else{
                        mapPriceListItemBySKU.put(ccPriceListItem.ccrz__Product__r.ccrz__SKU__c , new List<ccrz__E_PriceListItem__c>{ccPriceListItem});
                    }
                    
                }
            }
        }
        System.debug('mapPriceListItemBySKU  : '+JSON.serialize(mapPriceListItemBySKU));
        return mapPriceListItemBySKU;
    }

    global static  List<ccrz__E_PriceList__c> retrievePriceList(Map<String,Object> mapParams)
    {
        List<ccrz__E_PriceList__c> priceListObject = null;
        ccrz.ccLog.log(LoggingLevel.DEBUG, 'M:X:product fetching entitlement mapParams price group Id : ',
                                mapParams.get(CC_ERG_Constant.PRICE_GROUP_ID));
        ccrz.ccLog.log(LoggingLevel.DEBUG, 'M:X:product fetching entitlement fetchPriceList storefront name: ',
                                mapParams.get(CC_ERG_Constant.STOREFRONT_NAME));
        if(mapParams!=null && mapParams.size()>0 &&
                mapParams.containsKey(CC_ERG_Constant.STOREFRONT_NAME) &&
                String.isNotBlank((String)mapParams.get(CC_ERG_Constant.STOREFRONT_NAME)) &&
                mapParams.containsKey(CC_ERG_Constant.STOREFRONT_CURRENCY) &&
                String.isNotBlank((String)mapParams.get(CC_ERG_Constant.STOREFRONT_CURRENCY)) &&
                mapParams.containsKey(CC_ERG_Constant.PRICE_LIST_NAME) &&
                String.isNotBlank((String)mapParams.get(CC_ERG_Constant.PRICE_LIST_NAME)))
        {
            String storeFrontName = (String)mapParams.get(CC_ERG_Constant.STOREFRONT_NAME);
            String strCurrencyCode =  (String)mapParams.get(CC_ERG_Constant.STOREFRONT_CURRENCY);
            String priceListName =  (String)mapParams.get(CC_ERG_Constant.BASE_PRICE_LIST_NAME);
            // for sale price list detail
            String strPriceListId = (String)mapParams.get(CC_ERG_Constant.PRICE_LIST_ID);
            if(strPriceListId == null) {
                priceListName = (String)mapParams.get(CC_ERG_Constant.PRICE_LIST_NAME);
            }
            // end
            System.debug('>priceListName>>>'+priceListName);
            System.debug('>storeFrontName>>>'+storeFrontName);
            System.debug('>strCurrencyCode>>>'+strCurrencyCode);
            priceListObject = [SELECT Id,Name, ccrz__StartDate__c,ccrz__EndDate__c,ccrz__Enabled__c, ccrz__PricelistId__c,ccrz__Storefront__c,ccrz__CurrencyISOCode__c
                                        FROM ccrz__E_PriceList__c
                                        WHERE ccrz__Enabled__c = TRUE AND (ccrz__StartDate__c <= TODAY AND ccrz__EndDate__c >= TODAY)
                                        AND ccrz__Enabled__c = TRUE AND  ccrz__Storefront__c INCLUDES (:storeFrontName) AND ccrz__CurrencyISOCode__c=:strCurrencyCode
                                        AND Name=:priceListName];
            system.debug('*** priceListObject'+priceListObject);
            ccrz.ccLog.log(LoggingLevel.DEBUG, 'M:X:product fetching entitlement fetchPriceList priceGroupPriceList: ',
                    JSON.serialize(priceListObject));
        }
        return priceListObject;
    }

    global static  List<ccrz__E_PriceListItem__c> fetchPriceListItemByProducts(Map<String,Object> mapParams)
    {
        system.debug('*** mapParams in pricing'+JSON.serialize(mapParams));
        List<ccrz__E_PriceListItem__c> priceListItems = null;
        if(mapParams!=null && mapParams.size()>0 &&
                mapParams.containsKey(CC_ERG_Constant.PRICE_LIST_ID) &&
                mapParams.containsKey(CC_ERG_Constant.PRODUCT_SKU_LIST))
        {
            system.debug('*** in if');
            String strPriceListId = (String)mapParams.get(CC_ERG_Constant.PRICE_LIST_ID);
            Set<String> setProductSKU = (Set<String>)mapParams.get(CC_ERG_Constant.PRODUCT_SKU_LIST);
            priceListItems = [SELECT Id,ccrz__PricingTiers__c,ccrz__Pricelist__r.ccrz__CurrencyISOCode__c,ccrz__RecurringPrice__c,ccrz__Price__c,
                                        ccrz__MaxQty__c, ccrz__MinQty__c,ccrz__UnitOfMeasure__c,ccrz__Product__r.ccrz__Quantityperunit__c,
                                        ccrz__Product__r.Id, ccrz__Product__r.ccrz__UnitOfMeasure__c,ccrz__Product__r.ccrz__SKU__c FROM ccrz__E_PriceListItem__c
                                        WHERE ccrz__Pricelist__c =:strPriceListId  AND (ccrz__StartDate__c <= TODAY AND ccrz__EndDate__c >= TODAY) AND ccrz__Product__r.ccrz__SKU__c =: setProductSKU];
        }
        return priceListItems;
    }
     global static  List<ccrz__E_PriceListItem__c> fetchPriceListItemAndProducts(Map<String,Object> mapParams)
    {
        String productStatus= CC_ERG_Constant.PRODUCT_RELEASED;
         String storeFrontName = (String)mapParams.get(CC_ERG_Constant.STOREFRONT_NAME);
        system.debug('*** mapParams in pricing'+JSON.serialize(mapParams));
        List<ccrz__E_PriceListItem__c> priceListItems = null;
        if(mapParams!=null && mapParams.size()>0 &&
                mapParams.containsKey(CC_ERG_Constant.PRICE_LIST_ID))
        {
            system.debug('*** in if');
            // for sale price list detail
            String strPriceListId = (String)mapParams.get(CC_ERG_Constant.BASE_PRICE_LIST_ID);
            if(strPriceListId == null){
                strPriceListId = (String)mapParams.get(CC_ERG_Constant.PRICE_LIST_ID);
            }
            Set<String> setProductSKU = (Set<String>)mapParams.get(CC_ERG_Constant.PRODUCT_SKU_LIST);
            priceListItems = [SELECT Id,ccrz__PricingTiers__c,ccrz__Pricelist__r.ccrz__CurrencyISOCode__c,ccrz__RecurringPrice__c,ccrz__Price__c,
                                        ccrz__MaxQty__c, ccrz__MinQty__c,ccrz__UnitOfMeasure__c,ccrz__Product__r.ccrz__Quantityperunit__c,
                                        ccrz__Product__r.Id, ccrz__Product__r.ccrz__UnitOfMeasure__c,ccrz__Product__r.ccrz__SKU__c FROM ccrz__E_PriceListItem__c
                                        WHERE ccrz__Pricelist__c =:strPriceListId  AND (ccrz__StartDate__c <= TODAY AND ccrz__EndDate__c >= TODAY) 
                                        AND  ccrz__Product__r.ccrz__ProductStatus__c =: productStatus AND  (ccrz__Product__r.ccrz__StartDate__c <= TODAY) AND (ccrz__Product__r.ccrz__EndDate__c >= TODAY) 
                                        AND ccrz__Product__r.ccrz__Storefront__c=: storeFrontName ];
        }

        return priceListItems;
    }

    global static  List<ccrz__E_PriceListItem__c> fetchAllPriceListItemByProducts(Map<String,Object> mapParams)
    {
        List<ccrz__E_PriceListItem__c> priceListItems = null;
        if(mapParams!=null && mapParams.size()>0 &&
                mapParams.containsKey(CC_ERG_Constant.PRODUCT_SKU_LIST))
        {
            String storeFrontName = (String)mapParams.get(CC_ERG_Constant.STOREFRONT_NAME);
            String strCurrencyCode =  (String)mapParams.get(CC_ERG_Constant.STOREFRONT_CURRENCY);
            String strPriceListId = (String)mapParams.get(CC_ERG_Constant.PRICE_LIST_ID);
            system.debug('storeFrontName'+storeFrontName);
            system.debug('strCurrencyCode'+strCurrencyCode);
            system.debug('strPriceListId'+strPriceListId);
            Set<String> setProductSKU = (Set<String>)mapParams.get(CC_ERG_Constant.PRODUCT_SKU_LIST);
            priceListItems = [SELECT Id,ccrz__PricingTiers__c,ccrz__Pricelist__r.ccrz__CurrencyISOCode__c,ccrz__RecurringPrice__c,ccrz__Price__c,
                                        ccrz__MaxQty__c, ccrz__MinQty__c,ccrz__UnitOfMeasure__c,ccrz__Product__r.ccrz__Quantityperunit__c,
                                        ccrz__Product__r.Id, ccrz__Product__r.ccrz__UnitOfMeasure__c,ccrz__Product__r.ccrz__SKU__c FROM ccrz__E_PriceListItem__c
                                        WHERE  ccrz__Pricelist__r.ccrz__Storefront__c INCLUDES (:storeFrontName) AND ccrz__Pricelist__r.ccrz__CurrencyISOCode__c=:strCurrencyCode
                                        AND ccrz__Pricelist__r.ccrz__Enabled__c = TRUE AND (ccrz__StartDate__c <= TODAY AND ccrz__EndDate__c >= TODAY)
                                        AND ccrz__Product__r.ccrz__SKU__c =: setProductSKU ORDER BY ccrz__Price__c ASC];
            system.debug('priceListItems'+priceListItems);
        }
        return priceListItems;
    }

    global static List<ccrz__E_PriceGroupPricelist__c> fetchCCPriceGroup(String strPriceListId)
    {
        return [SELECT Id,ccrz__Pricelist__r.Id, ccrz__Pricelist__r.Name, ccrz__Pricelist__r.ccrz__PricelistId__c,
                                                                                                        ccrz__PriceGroup__r.Id,ccrz__PriceGroup__r.Name FROM ccrz__E_PriceGroupPricelist__c
                                                                                                        WHERE ccrz__Pricelist__r.ccrz__PricelistId__c=:strPriceListId];
    }

}