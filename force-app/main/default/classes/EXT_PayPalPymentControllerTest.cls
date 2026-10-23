@isTest
public with sharing class EXT_PayPalPymentControllerTest {
  @isTest
  public static void EXT_PayPalPymentController_Test() {
     digitalriverb2b.DRB2B_PayPalPaymentController paymentCtrl = new digitalriverb2b.DRB2B_PayPalPaymentController();
     EXT_PayPalPymentController extPaypalCtrl = new EXT_PayPalPymentController(paymentCtrl);
      System.assert(extPaypalCtrl != null);   
  }
}