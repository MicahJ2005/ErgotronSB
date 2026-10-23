global class CC_ERG_CartItemModel {
    
    global String cartItemId{set;get;}
    global String cartItemNumber{set;get;}
    global String cartItemType{set;get;}
    global String productSku{set;get;}
    global String productId{set;get;}
    global String productName{set;get;}
    global String productShortDescription{set;get;}
    global String productLongDescription{set;get;}
    global String productType{set;get;}
    global String taxCode{set;get;}
    global String cartId{set;get;}
    global String encryptedCartId{set;get;}
    global String parentProductId{set;get;}
    global Boolean isTrial{set;get;}
    global Decimal trialLength{set;get;}
    global String category{set;get;}
    global Decimal quantity{set;get;}
    global Decimal price{set;get;}
    global String priceModifierType{set;get;}
    global String pricingType{set;get;}
    global String cartItemLabel{set;get;}
    global Decimal cartItemTotal{set;get;}
    global Decimal originalItemPrice{set;get;}
    global Decimal originalQuantity{set;get;}
    global String couponId{set;get;}
    global String couponCode{set;get;}
    global String couponType{set;get;}
    global String couponMessage{set;get;}
    global String couponShortDescription{set;get;}
    global String couponLongDescription{set;get;}
    global String couponPurpose{set;get;}
    global Boolean isSubscription{set;get;}
    global String subProdTermId{set;get;}
    global String subscriptionTermType{set;get;}
    global Decimal subscriptionDuration{set;get;}
    global Decimal subscriptionFrequency{set;get;}
    global String subscriptionTermId{set;get;}
    global String uom{set;get;}
    global Decimal absoluteDiscount{set;get;}
    global Decimal percentageDiscount{set;get;}
    global Decimal adjustmentAmount{set;get;}
    global Decimal subAmount{set;get;}
    global Decimal taxAmount{set;get;}
    global Decimal taxPercentage{set;get;}
    global String billingProductId{set;get;}
    global String entitlementProductId{set;get;}
    global String bundleProductDescription{set;get;}
    global String bundleProductSKU{set;get;}
    global String tierDescription{set;get;}
    global Boolean isTierPriced{set;get;}
    global Boolean isADCPriced{set;get;}
    //TODO global List<MktpTierPriceModel> selectedTierList;
    //TODO global List<MktpProductModel> selectedBundleComponentList;
    global String productInstanceRegion{set;get;}
    global String isPrimaryProduct{set;get;}
    global String utmSource{set;get;}
    global Date startDate{set;get;}
    global Date endDate{set;get;}
    global String vShipmentId{set;get;}
    global Boolean recurringPrice{set;get;}
    global String imageURL{set;get;}
    global Boolean accountLevel{set;get;}

}