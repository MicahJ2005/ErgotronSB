global without sharing class CC_ERG_CartRequest extends CC_ERG_BaseRequest{

    global String cartId{set;get;}
    global Boolean changePlan{ set; get; }
    global List<CartLineItem> lineItems{set;get;}
    global CC_ERG_CartReviewModel cartDetails{set;get;}
//    global String cartName{set;get;}
//    global String couponCode{set;get;}
//    global String utmSource{ set; get; }
//    global Boolean previewInvoice{ set; get; }
//    global Integer zipcode{set;get;}
//    global String pageId{ set; get; }
    global class CartLineItem {
        global String sku { set; get; }
        global Integer quantity { set; get; }
        global String cartItemId{set;get;}
//        global String productType { set; get; }
//        global String productFamily {set;get;}
    }

}