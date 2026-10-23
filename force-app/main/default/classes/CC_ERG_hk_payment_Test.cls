@isTest
public class CC_ERG_hk_payment_Test {
    
    @TestSetup
    static void setupData() {
        CC_ERG_TestData.initCCSettings();
    }

	@isTest
    public static void fetchPaymentTypes_Test() {
        ccrz__E_Cart__c cart = new ccrz__E_Cart__c();
        cart.ccrz__CartStatus__c = 'Open';
        cart.ccrz__ActiveCart__c = True;
        cart.ccrz__BuyerCompanyName__c = 'testCompany';
        Insert cart; 
    	Map<String, Object> inputData = new Map<String, Object>();
        inputData.put(ccrz.cc_hk_Payment.PARAM_APPL_PAYMENT_TYPES,'po');
        CC_ERG_hk_payment hkPayments = new CC_ERG_hk_payment();
        Map<String,Object> outputData = hkPayments.fetchPaymentTypes(inputData);
    }
}