public with sharing class EXT_PayPalPymentController {
    public Boolean isPaypalTestMode {get;set;}

    public EXT_PayPalPymentController(digitalriverb2b.DRB2B_PayPalPaymentController payPal) {
        Map<String, String> paypalData = digitalriverb2b.DRB2B_PayPalPaymentController.drConnectorConfigMap;
        isPaypalTestMode = Boolean.valueOf(paypalData.get('Test_Order_Paypal'));
        System.debug(isPaypalTestMode);
    }
}