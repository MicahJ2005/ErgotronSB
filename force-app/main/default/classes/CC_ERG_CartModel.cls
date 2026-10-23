/**
 * @description       : 
 * @author            : Raziya Gurramkonda
 * @group             : 
 * @last modified on  : 11-11-2020
 * @last modified by  : Raziya Gurramkonda
 * Modifications Log 
 * Ver   Date         Author               Modification
 * 1.0   11-11-2020   Raziya Gurramkonda   Initial Version
**/
global without sharing class CC_ERG_CartModel extends CC_ERG_BaseModel{

    global String encryptedCartId{set;get;}
    global String cartId{set;get;}
    global String storefront{set;get;}
    global String cartNumber{set;get;}
    global String cartStatus{set;get;}
    global Boolean activeCart{set;get;}
    global String cartType{set;get;}
    global String cartUrl{set;get;}
    //global String locale;
    global String country{set;get;}
    global String currencyCode{set;get;}
    global Decimal totalAmount{set;get;}
    global Decimal subTotalAmount{set;get;}
    global Decimal adjustmentAmount{set;get;}
    global String adjustmentReason{set;get;}
    global Decimal taxAmount{set;get;}
    global Boolean taxExemptFlag{set;get;}
    global Decimal taxSubtotalAmount{set;get;}
    global Decimal totalDiscount{set;get;}
    global Decimal totalQuantity{set;get;}
    global Decimal totalSurcharge{set;get;}
    global String ccPaymentTransactionReference{set;get;}
    global String poNumber{set;get;}
    global String billTo{set;get;}
    global String buyerCompanyName{set;get;}
    global String buyerEmail{set;get;}
    global String buyerFirstName{set;get;}
    global String buyerLastName{set;get;}
    global String buyerMobile{set;get;}
    global String buyerPhone{set;get;}
    global String campaignCode{set;get;}
    global Boolean isAbandoned{set;get;}
    global String parentCartId{set;get;}
    global String portalUserName{set;get;}
    global Boolean allowCheckout{set;get;}
    global Boolean quantityExceeded{set;get;}
    global Boolean hardwareProductExist{set;get;}
    global Decimal monthlyRecurringAmount{set;get;}
    global Decimal monthlyRecurringTaxAmount{set;get;}
    global Decimal amountDueNow{set;get;}
    global Decimal taxAmountDueNow{set;get;}
    global Decimal amountDueOnActivation{set;get;}
    global Decimal taxAmountDueOnActivation{set;get;}
    global String currentStep{set;get;}
    global Boolean sameCompanyAddress{set;get;}
    global Boolean sameShippingAddress{set;get;}
    global Boolean sameBillingAddress{set;get;}
    global CC_ERG_CartReviewModel paymentDetails{set;get;}
    
    global List<CC_ERG_CartItemModel> cartItems{set;get;}
    global Error error{get;set;}

    global class Error{
        global Integer statusCode{set;get;}
        global Integer errorCount{set;get;}
        global String errorMessage{set;get;}
    }
}