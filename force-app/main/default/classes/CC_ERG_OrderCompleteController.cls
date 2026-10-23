public with sharing class CC_ERG_OrderCompleteController {
    
       public string localizedLabel {get;set;}
 
        //query to get Page Label or I18N localization
        public String getLocalizationLabel() {
            /*
            //variable assignment
            String userLocale = ccrz.cc_util_Locale.getUserLocale();
            
            
            if (userLocale == null || userLocale == 'en_US')
            {
                //grab default CC Page Label (english)
                localizedLabel = [select ccrz__ValueRT__c from ccrz__E_PageLabel__c where Name = 'CCForgotPasswordTemplateText' limit 1].ccrz__ValueRT__c;
            }
            else {
                //grab CC PageLabeli18n based on User.LanguageLocaleKey
                localizedLabel = [select ccrz__ValueRT__c from ccrz__E_PageLabeli18n__c where ccrz__Language__c = :userLocale AND 
                    ccrz__PageLabel__c in (select id from ccrz__E_PageLabel__c where Name = 'CCForgotPasswordTemplateText')].ccrz__ValueRT__c;
            }
            */
 
            string thisvalue;
            //thisvalue = 'testing';
            thisvalue = ccrz.cc_CallContext.currCartId;

            return thisvalue;
        }
    
}