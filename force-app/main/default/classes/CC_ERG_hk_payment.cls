global without sharing class CC_ERG_hk_payment extends ccrz.cc_hk_Payment{

    global override Map<String,Object> fetchPaymentTypes(Map<String,Object> inputData){
        System.debug('inputDatainputData:  ' + inputData);
      Map<String, Object> results = super.fetchPaymentTypes(inputData);
         System.debug('resultsresults:  ' + results);
        ccrz__E_Cart__c theCart;
        if(!Test.isRunningTest()){
        	theCart = [select ccrz__Account__r.PO_Allowed__c, ccrz__SubtotalAmount__c, ccrz__BillTo__r.ccrz__CountryISOCode__c from ccrz__E_cart__c where ccrz__EncryptedId__c =: ccrz.cc_CallContext.currCartId];
        }else{
            theCart = [select ccrz__Account__r.PO_Allowed__c, ccrz__SubtotalAmount__c, ccrz__BillTo__r.ccrz__CountryISOCode__c from ccrz__E_cart__c Order by Createddate desc limit 1];
        } 
        //Account theAccount = [select PO_Allowed__c from Account where Id =: ccrz.cc_CallContext.effAccount.Id];
        System.debug('----JLL----cc_erg_hk_payment----- country iso code  ' + theCart.ccrz__BillTo__r.ccrz__CountryISOCode__c);
        Map<String, Object> paymentTypes = (Map<String, Object>)results.get('paymentTypes');
        //paymentTypes.clear();
        //Check for restricted country
        List<ccrz__E_Configuration__c> ccRestricted =[SELECT Name, ccrz__ConfigurationMeta__r.name, ccrz__TextValue__c FROM ccrz__E_Configuration__c where ccrz__ConfigurationMeta__r.name = 'Credit Card Allowed Countries' limit 1];
        System.debug('-------jll---------- ccRestrictedConfig:  ' + ccRestricted);
        List<String> ccRestrictedList;
        if(ccRestricted.size() > 0){
          if(ccRestricted[0].ccrz__TextValue__c != null)
            ccRestrictedList = ccRestricted[0].ccrz__TextValue__c.split(',');
            System.debug('-------jll---------- ccRestrictedList:  ' + ccRestrictedList);
            boolean found = false;
            for(String ccRest : ccRestrictedList){
              if(ccRest.equalsIgnoreCase(theCart.ccrz__BillTo__r.ccrz__CountryISOCode__c)){
                System.debug('-------jll---------- HERE!  ');
                found = true;
              }
            }
            if(!found){
                paymentTypes.put('cc', null);
                paymentTypes.put('pp', null);
            }
        }

        //CSR never sees credit card
        if(ccrz.cc_CallContext.isOnBehalf){
            //System.debug('----JLL----cc_erg_hk_payment----- 1');
            paymentTypes.put('cc', null);
            paymentTypes.put('pp', null);
            //paymentTypes.put('po', null);
        }
        //$0 order doesn't see credit card
        if(theCart.ccrz__SubtotalAmount__c == 0){
            //System.debug('----JLL----cc_erg_hk_payment----- 2');
            paymentTypes.put('cc', null);
            paymentTypes.put('pp', null);
        }
        //If not $0, only allow PO if account flag is set
        else if(!theCart.ccrz__Account__r.PO_Allowed__c){
          //System.debug('----JLL----cc_erg_hk_payment----- 3');
            paymentTypes.put('po', null);
        }
        //rearrange the options.

        Map<String, Object> paymentTypesToReturn =  new Map<String, Object>(); 
        if(paymentTypes.containsKey('cc')){
          paymentTypesToReturn.put('cc', paymentTypes.get('cc'));

        }
        
        //R1 commented - PayPal integration not implemented yet
        /*
        if(paymentTypes.containsKey('pp')){
          paymentTypesToReturn.put('pp', paymentTypes.get('pp'));

        }
		*/
        
        if(paymentTypes.containsKey('po')){
          paymentTypesToReturn.put('po', paymentTypes.get('po'));

        }
        results.put('paymentTypes', paymentTypesToReturn);
        return results;
    }
}