public class CC_ERG_static_utils {
    //copied from OOTB for adding filter conditions to service calls
    public static Map<String, Object> accFilter(Map<String, Object> fcs, String key, String condition, String conjunction){
        if (!fcs.isEmpty()) {
            fcs.put(key,' '+conjunction+' '+condition);
        } else {
            fcs.put(key, condition);
        }
        return fcs;
    } 

    //To hold price list override
    public static final string PRICELIST_ID = 'pricelistID';
    
    @TestVisible
    public static String pricelistId{
        get{
            ccrz__E_Cart__c theCart = null;
            if(String.isBlank(pricelistId)){
                if(ccrz.cc_CallContext.currCartId != null){
                    theCart = [select pricelistOverride__c, ccrz__EncryptedId__c from ccrz__E_Cart__c where ccrz__EncryptedId__c =: ccrz.cc_CallContext.currCartId];
                    pricelistId = (String)theCart.pricelistOverride__c;
                }
            }
            return pricelistId;
        }
        set;
    }
    //2020.09.29 gvansteeter added deactivateUser method for guest user enablement
    @future
    public static void deactivateUser(final ID uID){
        User refetchUser = [SELECT Id, Name, IsActive FROM User WHERE Id = :uID];
        if(refetchUser.isActive){
            //ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'CC_ERG_static_Utils.deactivateUser: uID=' + uID);
            refetchUser.IsActive = false;
            try{
                update refetchUser;
            }catch(Exception e){
                System.debug(System.LoggingLevel.ERROR, 'CC_ERG_static_utils.deactivateUser: Error deactivating User record: Name =  '+ refetchUser.Name
                             +'; Id = '+ uId + ': ' + e.getMessage());
                ccrz.ccLog.log(System.LoggingLevel.ERROR, 'CC_ERG_static_utils.deactivateUser: Error deactivating User record: Name =  '+ refetchUser.Name
                             +'; Id = '+ uId + ': ' + e.getMessage());
            }
        }
    }
    public static Map<String,Object> createMailData(Map<String,Object> mapEmailRequest){
        Map<String,Object> mapResponse = new Map<String,Object>();
        if(mapEmailRequest!=null)
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            System.debug('mapEmailRequest :'+mapEmailRequest);
            if(mapEmailRequest.containsKey(Erg_Constants.EMAIL_TO_ADDRESS))
            {
                System.debug('mapEmailRequest :'+mapEmailRequest);
                List<String> lstToAddress = (List<String>) mapEmailRequest.get(Erg_Constants.EMAIL_TO_ADDRESS);
                mail.setToAddresses(lstToAddress);
            }
            if(mapEmailRequest.containsKey(Erg_Constants.EMAIL_SUBJECT))
            {
                String strSubject = (String) mapEmailRequest.get(Erg_Constants.EMAIL_SUBJECT);
                mail.setSubject(strSubject);
            }
            if(mapEmailRequest.containsKey(Erg_Constants.EMAIL_HTML_BODY))
            {
                String strHTMLBody = (String) mapEmailRequest.get(Erg_Constants.EMAIL_HTML_BODY);
                mail.setHtmlBody(strHTMLBody);
            }
            // if(mapEmailRequest.containsKey(VONB2B_Constant.EMAIL_ORG_WIDE_EMAIL_ADDRESS))
            // {
            //     String strOrgWideEmailAddressId = (String) mapEmailRequest.get(VONB2B_Constant.EMAIL_ORG_WIDE_EMAIL_ADDRESS);
            //     if(String.isNotBlank(strOrgWideEmailAddressId)){
            //         mail.setOrgWideEmailAddressId(strOrgWideEmailAddressId);
            //     }
            // }
            if(mapEmailRequest.containsKey(Erg_Constants.EMAIL_SAVE_AS_ACTIVITY))
            {
                mail.setSaveAsActivity((Boolean)mapEmailRequest.get(Erg_Constants.EMAIL_SAVE_AS_ACTIVITY));
            }
            mapResponse.put(Erg_Constants.EMAIL_DATA, mail);
        }
        return mapResponse;
    }

    public static Map<String,Object> sendEmail(Map<String,Object> mapEmailRequest) {
        Map<String, Object> mapResponse = new Map<String, Object>();
        try
        {
            if (mapEmailRequest != null && mapEmailRequest.containsKey(Erg_Constants.EMAIL_LIST_DATA))
            {
                List<Messaging.SingleEmailMessage> lstMails = (List<Messaging.SingleEmailMessage>)mapEmailRequest.get(Erg_Constants.EMAIL_LIST_DATA);
                List<Messaging.SendEmailResult> lstMessagingEmailResults = Messaging.sendEmail(lstMails);
                mapResponse.put(Erg_Constants.EMAIL_SERVER_RESPONSE , lstMessagingEmailResults);
            }
        }
        catch (Exception expObject)
        {
            System.debug('Exception Object : '+expObject.getStackTraceString());
        }
        return mapResponse;
    }

}