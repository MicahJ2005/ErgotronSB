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
global class CC_ERG_PricingVO {
    
    global Boolean recurringPrice{set;get;}
    global Decimal listPrice{set;get;}
    global Decimal salePrice{set;get;}
    global Decimal price{set;get;}
    global Decimal tax{set;get;}
    global Decimal totalAmount{set;get;}
    global Boolean taxCalculated{set;get;}
    global Boolean tieredPricingEnabled{set;get;}
    global List<PriceTier> priceTiers{set;get;}
    global Integer quantity{set;get;}

    global class PriceTier{
        global Integer startQuantity{set;get;}
        global Integer endQuantity{set;get;}
        global Decimal listPrice{set;get;}
        global Decimal salePrice{set;get;}
    }

    global class Tiers {
        global Integer q;
        global Double p;
    }

    global List<Tiers> tiers;
    global String pT;

    /*
     "price" : {
        "tiers":[
            {"start":1, "end" : 4 , "listPrice":44.99 , "salePrice" : 37.99 },
            {"start":5, "end" : 19 , "listPrice":39.99 , "salePrice" : 35.99 },
            {"start":20, "end" : 99 , "listPrice":36.99 , "salePrice" : 32.99 }
        ],
        "listPrice" : 39.99,
        "salePrice" : 39.99,
        "tax" : 39.99,
        "totalAmount" : 39.99,
        "taxCalculated" : true,
        "tieredPricingEnabled" : true,
        "recurring" : true
    }
     */
    /*
    global static ccErg_PricingVO parse(ccrz__E_PriceListItem__c priceListItem , ccErg_PricingVO ccErgPricingVO ) {
        ccErgPricingVO.recurringPrice = priceListItem.ccrz__RecurringPrice__c;
        ccErgPricingVO.price = priceListItem.ccrz__Price__c;
        List<Tiers> lstExistingTiers = ccErgPricingVO.tiers;
        if(String.isNotBlank(priceListItem.ccrz__PricingTiers__c))
        {
            Tiers tiers ;
            ccErgPricingVO.tiers = null;
            if(lstExistingTiers != null)
            {
                //"listPrice":39.99
            }
            else
            {
                //FIRST TIME LOOP
            }


        }
        //return (ccErg_PricingVO) System.JSON.deserialize(json, ccErg_PricingVO.class);
        return ccErgPricingVO;
    }
    */
/*     
    global static CC_ERG_PricingVO parse(List<ccrz__E_PriceListItem__c> priceListItemList, map<String,Object> reqmap ) {
        CC_ERG_PricingVO ccErgPricingVO =  null ;
        Integer qty = 1;
        if(reqmap.containsKey(CC_ERG_Constant.PRODUCT_QTY)){
            qty = (Integer)reqmap.get(CC_ERG_Constant.PRODUCT_QTY);
        }
        if(!priceListItemList.isEmpty()){
            ccErgPricingVO = new CC_ERG_PricingVO();
            List<PriceTier> priceTiersList = new List<PriceTier>();
            ccrz__E_PriceListItem__c salePItem = priceListItemList.get(0);
            Integer lastIndex = priceListItemList.size() - 1 ;
            ccrz__E_PriceListItem__c listPItem = priceListItemList.get(lastIndex);

            ccErgPricingVO.recurringPrice = salePItem.ccrz__RecurringPrice__c;
            ccErgPricingVO.listPrice = listPItem.ccrz__Price__c ;
            ccErgPricingVO.salePrice = salePItem.ccrz__Price__c ;
            ccErgPricingVO.tieredPricingEnabled = false;
            String pricingTierStr = salePItem.ccrz__PricingTiers__c;
            if(String.isNotBlank(pricingTierStr))
            {
                ccErgPricingVO.tieredPricingEnabled = true;
                map<String,Object> tierMap = (map<String,Object>)JSON.deserializeUntyped(pricingTierStr);
                if(tierMap.containsKey('tiers')){
                    List<Object> tierList = (List<Object>)tierMap.get('tiers');
                    Integer i = 0;
                    for(Object obj: tierList){
                        map<String,Object> mapObj = (map<String,Object>)obj ;
                        PriceTier pt = new PriceTier();
                        pt = populateListTierPrice(listPItem,pt,i);
                        i++;
                        pt.startQuantity = Integer.valueOf(mapObj.get('q'));
                        if(tierList.size() > i){
                            map<String,Object> nextMapObj = (map<String,Object>)tierList[i] ;
                            pt.endQuantity = Integer.valueOf(nextMapObj.get('q')) - 1;
                        }else{
                            pt.endQuantity = 99;
                        }
                        pt.salePrice = Decimal.valueOf(String.valueOf(mapObj.get('p'))).setScale(2);
                        priceTiersList.add(pt);
                        if(qty>=pt.startQuantity && qty<=pt.endQuantity){
                            ccErgPricingVO.listPrice = pt.listPrice ;
                            ccErgPricingVO.salePrice = pt.salePrice  ;
                        }
                    }
                    ccErgPricingVO.totalAmount = ccErgPricingVO.salePrice * qty ;
                    ccErgPricingVO.totalAmount.setScale(2);
                    ccErgPricingVO.taxCalculated = false;
                    ccErgPricingVO.quantity = qty ;
                }
            }
            ccErgPricingVO.priceTiers =  priceTiersList;
        }
        return ccErgPricingVO;
    } */

    global static CC_ERG_PricingVO parsePricing(ccrz__E_PriceListItem__c priceListItemList, map<String,Object> reqmap ) {
        CC_ERG_PricingVO ccErgPricingVO =  null ;
        Integer qty = 1;
        if(reqmap.containsKey(CC_ERG_Constant.PRODUCT_QTY)){
            qty = (Integer)reqmap.get(CC_ERG_Constant.PRODUCT_QTY);
        }
        if(priceListItemList != null){
            ccErgPricingVO = new CC_ERG_PricingVO();
            List<PriceTier> priceTiersList = new List<PriceTier>();
           
            ccErgPricingVO.recurringPrice = priceListItemList.ccrz__RecurringPrice__c;
            ccErgPricingVO.listPrice = priceListItemList.ccrz__Price__c ;
            ccErgPricingVO.salePrice = priceListItemList.ccrz__Price__c ;
            ccErgPricingVO.tieredPricingEnabled = false;
            String pricingTierStr = priceListItemList.ccrz__PricingTiers__c;
            if(String.isNotBlank(pricingTierStr))
            {
                ccErgPricingVO.tieredPricingEnabled = true;
                map<String,Object> tierMap = (map<String,Object>)JSON.deserializeUntyped(pricingTierStr);
                /* if(tierMap.containsKey('tiers')){
                    List<Object> tierList = (List<Object>)tierMap.get('tiers');
                    Integer i = 0;
                    for(Object obj: tierList){
                        map<String,Object> mapObj = (map<String,Object>)obj ;
                        PriceTier pt = new PriceTier();
                        pt = populateListTierPrice(priceListItemList,pt,i);
                        i++;
                        pt.startQuantity = Integer.valueOf(mapObj.get('q'));
                        if(tierList.size() > i){
                            map<String,Object> nextMapObj = (map<String,Object>)tierList[i] ;
                            pt.endQuantity = Integer.valueOf(nextMapObj.get('q')) - 1;
                        }else{
                            pt.endQuantity = 99;
                        }
                        pt.salePrice = Decimal.valueOf(String.valueOf(mapObj.get('p'))).setScale(2);
                        priceTiersList.add(pt);
                        if(qty>=pt.startQuantity && qty<=pt.endQuantity){
                            ccErgPricingVO.listPrice = pt.listPrice ;
                            ccErgPricingVO.salePrice = pt.salePrice  ;
                        }
                    }
                    ccErgPricingVO.totalAmount = ccErgPricingVO.salePrice * qty ;
                    ccErgPricingVO.totalAmount.setScale(2);
                    ccErgPricingVO.taxCalculated = false;
                    ccErgPricingVO.quantity = qty ;
                } */
            }
            ccErgPricingVO.priceTiers =  priceTiersList;
        }
        return ccErgPricingVO;
    }

/*     global static PriceTier populateListTierPrice(ccrz__E_PriceListItem__c listPItem,PriceTier pt,Integer i){
        String pricingTierStr = listPItem.ccrz__PricingTiers__c;
        if(String.isNotBlank(pricingTierStr))
        {
            map<String,Object> tierMap = (map<String,Object>)JSON.deserializeUntyped(pricingTierStr);
            if(tierMap.containsKey('tiers')){
                List<Object> tierList = (List<Object>)tierMap.get('tiers');
                if(tierList.size()>i){
                    map<String,Object> mapObj = (map<String,Object>)tierList.get(i) ;
                    pt.listPrice = Decimal.valueOf(String.valueOf(mapObj.get('p'))).setScale(2);
                }
            }
        }


        return pt;
    } */


}