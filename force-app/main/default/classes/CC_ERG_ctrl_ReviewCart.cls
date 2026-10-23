/**
 * @description       : 
 * @author            : Unknown
 * @group             : 
 * @last modified on  : 09-10-2020
 * @last modified by  : Manoj Kumar
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   08-26-2020   Unknown          Initial Version
 * 1.1   09-28-2020   Glen Van Steeter      Changes to sendOrderToCustomer for guest (anon) user enablement (Padlock remediation)
 * 
**/
global without sharing class CC_ERG_ctrl_ReviewCart {
    
    public String OrderId{get;set;}
    public static Boolean isBusinessAdd{get;set;}
    public static Boolean isResidenceAdd{get;set;}
    public static Boolean showTerms{get;set;}
    public static Boolean taxCalculationError{get;set;}
    public static Boolean isDisplayUploadTaxCertificateLinkCust{get;set;}
    public static Boolean csrUserToShowShipping{get;set;}
    public static Boolean endUserToShowShipping{get;set;}

    public string jumpToServer;
    public string  getjumpToServer(){
        String currURL = URL.getSalesforceBaseUrl().toExternalForm();
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'ERG_ctrl_ReviewCart:getjumpToServer currURL='+currURL);
        
        ccrz__E_Configuration__c custom_configs_serverurlbase =[SELECT Name, ccrz__ConfigurationMeta__r.name, ccrz__TextValue__c FROM ccrz__E_Configuration__c where ccrz__ConfigurationMeta__r.name = 'Server URL']; 
        String serverurlbase =  custom_configs_serverurlbase.ccrz__TextValue__c;

        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'ERG_ctrl_ReviewCart:getjumpToServer serverurlbase='+serverurlbase);
        
        jumpToServer = serverurlbase;

        return jumpToServer;
    }
    
    public string dfltPONumber;
    public string  getdfltPONumber(){
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'ERG_ctrl_ReviewCart:getdfltPONumber');
        return dfltPONumber;
    }    

    public void setdfltPONumber(string value){
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'ERG_ctrl_ReviewCart:setdfltPONumber');
    }
     
 
     public string FreightCarrierActNbr;
     public string  getFreightCarrierActNbr(){
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'ERG_ctrl_ReviewCart:getFreightCarrierActNbr');
        return FreightCarrierActNbr;
    }
    
    public void setFreightCarrierActNbr(string value){
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'ERG_ctrl_ReviewCart:getFreightCarrierActNbr');
        string info = 'debug ERG_ctrl_ReviewCart:setFreightCarrierActNbr value=' + value;
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, info);        
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult populateManualAddressList(ccrz.cc_RemoteActionContext ctx, String type) {
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'ERG_ctrl_ReviewCart:populateManualAddressList');

        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);
  
        result.data = 'from remote action call';
        result.success = true;
        
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:X', 'ERG_ctrl_ReviewCart:populateManualAddressList');
        
        return result;
    }    
    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult setSelectedAccountAddress(ccrz.cc_RemoteActionContext ctx, String addressTtype, String theAccountID) {
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'ERG_ctrl_ReviewCart:setSelectedAccountAddress');

        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);
        String theCartId = ccrz.cc_CallContext.currCartId;
        result.data  = cc_erg_diffAddrSelector.updateCartAddress(theAccountID, addressTtype,theCartId);

        result.success = true;
        
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:X', 'ERG_ctrl_ReviewCart:setSelectedAccountAddress');
        ccrz.ccLog.close(result);
        
        return result;
    }    

    @RemoteAction
    global static ccrz.cc_RemoteActionResult setSelectedContact(ccrz.cc_RemoteActionContext ctx) {
        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);
        String theCartId = ccrz.cc_CallContext.currCartId;
        ccrz__E_Cart__c cartObj;
        try{
            cartObj = [SELECT Id, ccrz__ShipTo__c, ccrz__ShipTo__r.ccrz__Partner_Id__c from ccrz__E_Cart__c where ccrz__EncryptedId__c =: theCartId];
            if(String.isNotBlank(cartObj.ccrz__ShipTo__c) && String.isNotBlank(cartObj.ccrz__ShipTo__r.ccrz__Partner_Id__c)){
                List<Contact> contList =[SELECT Id,Name, FirstName, lastName,Email from contact where AccountId =: cartObj.ccrz__ShipTo__r.ccrz__Partner_Id__c];
                result.data  = contList;
                result.success = true;
            }else{
                result.data  = '';
                result.success = false;
            }
        } catch(Exception ex){
            System.debug('ex____'+ex);
        }                       
        return result;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult saveContactId(ccrz.cc_RemoteActionContext ctx,String contId) {
        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);
        String theCartId = ccrz.cc_CallContext.currCartId;
        ccrz__E_Cart__c cartObj;
        try{
            cartObj = [SELECT Id, ccrz__ShipTo__c, ccrz__ShipTo__r.ccrz__Partner_Id__c from ccrz__E_Cart__c where ccrz__EncryptedId__c =: theCartId];
            if(String.isNotBlank(cartObj.ccrz__ShipTo__c) && String.isNotBlank(cartObj.ccrz__ShipTo__r.ccrz__Partner_Id__c)){
                ccrz__E_ContactAddr__c contAdr = [select id,contactId__c from ccrz__E_ContactAddr__c where Id =: cartObj.ccrz__ShipTo__c];
                contAdr.contactId__c = contId;
                update contAdr;
                result.data  = '';
                result.success = true;
            }else{
                result.data  = '';
                result.success = false;
            }
        }catch(Exception ex){
            System.debug('ex____'+ex);
        }
        return result;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult updatesAccountList(ccrz.cc_RemoteActionContext ctx, String addressType, String searchword) {

        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'ERG_ctrl_ReviewCart:updatesAccountList');
        
        result.data = cc_erg_diffAddrSelector.getMapofAccounts(searchword);
        result.success = true;
        
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:X', 'ERG_ctrl_ReviewCart:updatesAccountList');
        ccrz.ccLog.close(result);
        
        return result;
    }    
    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult updateFCAN(ccrz.cc_RemoteActionContext ctx, String account_number) {
        //ccrz.cclog.log(System.LoggingLevel.DEBUG, 'CC_ERG_ctrl_PDP:updatecart DID THIS ONE TOO!', location);
        return CC_ERG_ctrl_atp.updateFCAN(ctx, account_number);
    }
    
    public boolean showSendButton{get; set;}
    global Boolean displayProceedPaymentButton{get;set;}
    global Boolean displayPlaceOrderButton{get;set;}
    global String zeroDollarPaymentType {get;set;}
    
    global String staticResourseBaseUrl{get;set;}

    
    global CC_ERG_ctrl_ReviewCart(){
        isBusinessAdd = false;
        isResidenceAdd = false;
        String curServer = URL.getSalesforceBaseUrl().toExternalForm();
        ccrz.ccLog.log(System.LoggingLevel.INFO, 'M:E', 'ERG_ctrl_ReviewCart:getjumpToServer currURL='+curServer);
        
        Shipping_Tab__mdt shipTab = [select Id, DeveloperName, CSR_User__c, End_User__c from Shipping_Tab__mdt where DeveloperName = 'Shipping_Tab' LIMIT 1];
        if(shipTab != null){
            csrUserToShowShipping =shipTab.CSR_User__c;
            endUserToShowShipping =shipTab.End_User__c;
        }

        ccrz__E_Configuration__c custom_configs_serverurlbase =[SELECT Name, ccrz__ConfigurationMeta__r.name, ccrz__TextValue__c FROM ccrz__E_Configuration__c where ccrz__ConfigurationMeta__r.name = 'Server URL']; 
        String serverToJumpTo =  custom_configs_serverurlbase.ccrz__TextValue__c;
        
        //ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'ERG_ctrl_ReviewCart:constructor curServer='+curServer);
        //ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'ERG_ctrl_ReviewCart:constructor serverToJumpTo='+serverToJumpTo);
        List<Case> listCase = [SELECT CaseNumber FROM Case WHERE CC_CartId__r.ccrz__EncryptedId__c = :ccrz.cc_CallContext.currCartId];
        
        //ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'ERG_ctrl_ReviewCart:constructor queryParam'+URL.getCurrentRequestUrl().getQuery());
        //ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'ERG_ctrl_ReviewCart:constructor queryParam1--'+ApexPages.currentPage().getParameters().get('cartID'));

        if(listCase.size()>0){
            for(Case theCase : listCase){
                dfltPONumber = theCase.CaseNumber;
            }
        }else{
            dfltPONumber = 'NO CASE FOUND FOR PO';
        }

        String cartID  = ApexPages.currentPage().getParameters().get('cartID');
        System.debug('cartID: ' + cartID);
         //ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'ERG_ctrl_ReviewCart:ERG_ctrl_ReviewCart----'+cartID);        
        try{
            ccrz__E_Cart__c cartObj = [SELECT Id, Name, Address_Type__c,ccrz__CartStatus__c,(select id,ccrz__EncryptedId__c from ccrz__E_Orders__r) 
                FROM ccrz__E_Cart__c where ccrz__EncryptedId__c = :cartID];
            if(cartObj!= null){
                if(cartObj.Address_Type__c.equalsIgnoreCase('Business')) {
                    isBusinessAdd = true;
                } else if (cartObj.Address_Type__c.equalsIgnoreCase('Residence')) {
                    isResidenceAdd = true;
                }
                if(cartObj.ccrz__E_Orders__r.size() > 0 && cartObj.ccrz__CartStatus__c.equalsIgnoreCase('Closed')) {
                    ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'ERG_ctrl_ReviewCart:constructor queryParam-----++ '+cartObj.ccrz__E_Orders__r[0].ccrz__EncryptedId__c);
                    String OrderEncId = cartObj.ccrz__E_Orders__r[0].ccrz__EncryptedId__c;
                    String storeName = ccrz.cc_CallContext.storefront;
                    OrderId = curServer+'/ccrz__OrderView?o='+OrderEncId+'&portalUser=&store='+storeName+'&cclcl=en_US';
                }
            }
            

        }catch(Exception ex){

        }
        displayProceedPaymentButton =true;
        isDisplayUploadTaxCertificateLinkCust = false;
        try{
            displayProceedPaymentButton = Boolean.valueOf(digitalriverb2b.DRB2B_PaymentRefundController.drConnectorConfigMap.get('Display_Proceed_to_Payment_Button'));                
            List<digitalriverb2b__DR_Connector_Configuration__mdt> drConnectorConfList = [SELECT Id, digitalriverb2b__Key__c, DeveloperName FROM digitalriverb2b__DR_Connector_Configuration__mdt  where DeveloperName ='Display_Upload_Tax_Certificate_Link'];
            if(!drConnectorConfList.isEmpty()){
                system.debug('isDisplayUploadTaxCertificateLinkCust:: '+drConnectorConfList[0].digitalriverb2b__Key__c);
                system.debug('isDisplayUploadTaxCertificateLinkCust:: 1 '+new digitalriverb2b.DRB2B_PaymentController().isDisplayUploadTaxCertificateLink);
                if(Boolean.valueOf(drConnectorConfList[0].digitalriverb2b__Key__c)){
                    system.debug('getUserType:: '+System.UserInfo.getUserType());
                    isDisplayUploadTaxCertificateLinkCust = true;   // Boolean.valueOf(drConnectorConfList[0].digitalriverb2b__Key__c);
                }
            
                if(System.UserInfo.getUserType() == 'Guest'){
                    isDisplayUploadTaxCertificateLinkCust = false;
                }
            }
            staticResourseBaseUrl = CC_ERG_ctrl_ReviewCart.getStaticResourcePath();
        }catch(Exception e){
            displayProceedPaymentButton =true;
        }
        displayPlaceOrderButton = Boolean.valueOf(digitalriverb2b.DRB2B_PaymentRefundController.drConnectorConfigMap.get('Display_Place_Order_Button'));
        zeroDollarPaymentType = digitalriverb2b.DRB2B_PaymentRefundController.drConnectorConfigMap.get('Zero_Dollar_Order_Payment_Type');
        ccrz.ccLog.log(System.LoggingLevel.INFO, 'M:E', 'ERG_ctrl_ReviewCart:ERG_ctrl_ReviewCart');
        showTerms = new digitalriverb2b.DROrderReviewController().showTerms;
        taxCalculationError = new digitalriverb2b.DROrderReviewController().taxCalculationError;
        //isDisplayUploadTaxCertificateLinkCust = new digitalriverb2b.DRB2B_PaymentController().isDisplayUploadTaxCertificateLink;   
    }

    public static String getStaticResourcePath() {
        String staticResourseBaseUrl;
        Domain d = [SELECT Id, Domain FROM Domain  LIMIT 1];
        if(String.isNotBlank(ApexPages.CurrentPage().getparameters().get('PortalUserID'))) {
            staticResourseBaseUrl = 'https://' + d.Domain + '/' + ccrz.cc_util_Storefront.getStoreName();
        }
        else {
            staticResourseBaseUrl = 'https://' + d.Domain;
        }
        return staticResourseBaseUrl;
    }

    @RemoteAction
    global static void updateAddressTypeInCart(String encId, String addressType) {
        if(String.isNotBlank(encId) && String.isNotBlank(addressType)) {
            ccrz__E_Cart__c theCart = [select id, Address_Type__c from ccrz__E_Cart__c where 
                ccrz__EncryptedId__c =: encId];
            if(theCart != null) {
                theCart.Address_Type__c = addressType;
                update theCart;
                if(theCart.Address_Type__c.equalsIgnoreCase('Business')) {
                    CC_ERG_ctrl_ReviewCart.isBusinessAdd = true;
                    CC_ERG_ctrl_ReviewCart.isResidenceAdd = false;
                } else if (theCart.Address_Type__c.equalsIgnoreCase('Residence')) {
                    CC_ERG_ctrl_ReviewCart.isBusinessAdd = false;
                    CC_ERG_ctrl_ReviewCart.isResidenceAdd = true;
                }
            }
        }
    }
    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult sendOrderToCustomer(ccrz.cc_RemoteActionContext ctx) {
        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'ERG_ctrl_ReviewCart:sendOrderToCustomer');

        result.success = false;

        try {
            if(ccrz.cc_CallContext.currCartId != null){
                ccrz__E_Cart__c theCart = [select id, ownerId, ccrz__Contact__r.FirstName, ccrz__storefront__c, ccrz__EncryptedId__c, ccrz__contact__c, ccrz__Contact__r.Email, ccrz__BillTo__r.OwnerId, ccrz__ShipTo__r.OwnerId 
                                             from ccrz__E_Cart__c 
                                            where ccrz__EncryptedId__c =: ccrz.cc_CallContext.currCartId];
                System.debug('theCart='+theCart);
                Contact theContact = [select id, Store_Member__c from Contact where id =: ccrz.cc_CallContext.currContact.Id];
                
                // start of new email                
                string cartID;
                cartID = ctx.currentCartId; 

                Case theCase = [SELECT Id, CaseNumber FROM Case WHERE CC_CartId__r.ccrz__EncryptedId__c =:cartID];        
                // ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'ERG_ctrl_ReviewCart.sendOrderToCustomer: SELECT Id FROM Case WHERE CC_CartId__c = '+cartID);
        
                string caseNumber = theCase.CaseNumber;
                ID ContactID;
                ID AccountId;
                ID deactivateUserId = theCart.OwnerId; // 2020.09.21 gvansteeter preserve the current owner id. If not a store member, will deactivate the user in this method.
                
                
                //2020.10.29 gvansteeter, reconfigure this section to use a single fetch!
                List<ccrz__E_Configuration__c> listConfigs = [SELECT Name, ccrz__ConfigurationMeta__r.name, ccrz__TextValue__c 
                                                                FROM ccrz__E_Configuration__c 
                                                               WHERE ccrz__ConfigurationMeta__r.name IN ('Approver Email Template',
                                                                                                         'Approver Link Tag',
                                                                                                         'Case Number Tag',
                                                                                                         'Link Name',
                                                                                                         'From Name',
                                                                                                         'From Email',
                                                                                                         'Server URL')];
                String templateUniqueName;
                String linktag;
                String casetag;
                String linkname;
                String fromname;
                String fromemail;
                String serverurlbase; 
                
                for(ccrz__E_Configuration__c theConfig : listConfigs){
                    if(theConfig.ccrz__ConfigurationMeta__r.name=='Approver Email Template'){
                        templateUniqueName = theConfig.ccrz__TextValue__c;
                    }
                    if(theConfig.ccrz__ConfigurationMeta__r.name=='Approver Link Tag'){
                        linktag = theConfig.ccrz__TextValue__c;
                    }
                    if(theConfig.ccrz__ConfigurationMeta__r.name=='Case Number Tag'){
                        casetag = theConfig.ccrz__TextValue__c;
                    }
                    if(theConfig.ccrz__ConfigurationMeta__r.name=='Link Name'){
                        linkname = theConfig.ccrz__TextValue__c;
                    }
                    if(theConfig.ccrz__ConfigurationMeta__r.name=='From Name'){
                        fromname = theConfig.ccrz__TextValue__c;
                    }
                    if(theConfig.ccrz__ConfigurationMeta__r.name=='From Email'){
                        fromemail = theConfig.ccrz__TextValue__c;
                    }
                    if(theConfig.ccrz__ConfigurationMeta__r.name=='Server URL'){
                        serverurlbase = theConfig.ccrz__TextValue__c;
                    }
                }

                EmailTemplate et=[SELECT id,name, subject,HtmlValue FROM EmailTemplate where DeveloperName=:templateUniqueName]; // name is the unique name in UI
                
                ContactID = ccrz.cc_CallContext.currContact.Id;
                AccountId = ccrz.cc_CallContext.currAccountId;

                //2020.09.21 gvansteeter begin new logic for non store member processing
                Contact refetchContact = [SELECT Id, Store_Member__c FROM Contact WHERE Id = :ContactId];
                if(!refetchContact.Store_Member__c){
                    boolean isOK2Proceed = false;
                    String droStorefront = ccrz.cc_CallContext.storefront;
                    
                    ccrz__E_Configuration__c configDroId = [SELECT ccrz__TextValue__c
                                                              FROM ccrz__E_Configuration__c 
                                                             WHERE ccrz__ConfigurationMeta__r.Name = 'Default Record Owner'
                                                               AND ccrz__Storefront__c = :droStorefront];

                    User guestUser = [SELECT Id, Name FROM User WHERE Id = :configDroId.ccrz__TextValue__c];

                    try{
                        theCart.OwnerId = guestUser.Id;
                        theCart.ccrz__ActiveCart__c = false;
                        theCart.ccrz__BillTo__r.OwnerId = guestUser.Id;
                        theCart.ccrz__ShipTo__r.OwnerId = guestUser.Id;
                        update theCart.ccrz__BillTo__r;
                        update theCart.ccrz__ShipTo__r;
                        update theCart;
                        isOK2Proceed = true;
                    }catch(Exception e){
                        isOK2Proceed = false;
                        System.debug(System.LoggingLevel.ERROR, 'ERG_ctrl_ReviewCart.sendOrderToCustomer: Error updating cart owner to Site Guest User: '+e.getMessage());
                        ccrz.ccLog.log(System.LoggingLevel.ERROR, 'ERG_ctrl_ReviewCart.sendOrderToCustomer: Error updating cart owner to Site Guest User: '+e.getMessage());
                    }
                    // Only deactivate the user if update to cart and addresses was successful
                    if(isOK2Proceed){
                        User refetchUser = [SELECT Id, Name, IsActive FROM User WHERE Id = :deactivateUserId];
                        try{
                            // call future method
                            CC_ERG_static_utils.deactivateUser(refetchUser.Id);
                            ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'ERG_ctrl_ReviewCart.sendOrderToCustomer: Deactivated user: '+deactivateUserId);
                        }catch(Exception e){
                            System.debug(System.LoggingLevel.ERROR, 'ERG_ctrl_ReviewCart.sendOrderToCustomer: Error deactivating User record for '+refetchUser.Name+': '+e.getMessage());
                            ccrz.ccLog.log(System.LoggingLevel.ERROR, 'ERG_ctrl_ReviewCart.sendOrderToCustomer: Error deactivating User record for '+refetchUser.Name+': '+e.getMessage());
                        }
                    }
                }// end if
                // 2020.09.21 gvansteeter end new logic for non store member processing.
                                
                // gets the as rendered body, html, txt
                Messaging.SingleEmailMessage renderedemail = Messaging.renderStoredEmailTemplate(et.id, ContactID, theCart.Id);        
                String subjectOrig = renderedemail.getSubject();
                String theHtmlBodyOrig =  renderedemail.getHtmlBody();        
                String theTextOrig =  renderedemail.getPlainTextBody();
                theHtmlBodyOrig = theHtmlBodyOrig.replace(casetag, caseNumber);
                theTextOrig = theTextOrig.replace(casetag, caseNumber);
                String theText;
                String theHtmlBody;
                String cartURL = serverurlbase + '/ccrz__Cart?cartID=' + cartID+'&jumpto=po';
                String emailLinkURL;   
                // 2020.09.28 jlowenthal
                if(theContact.store_member__c)
                    emailLinkURL = serverurlbase + '/ccrz__CCSiteLogin?cartID=' + cartID + '&startUrl=' + EncodingUtil.urlEncode(cartURL, 'UTF-8');        
                else
                    emailLinkURL = cartURL;
                String htmllink;
                String subject;

                subject = subjectOrig.replace(casetag, caseNumber);
                htmllink ='<a href="'+emailLinkURL+'">'+linkname+'</a>';
                
                theText = theTextOrig.replace(linktag, emailLinkURL);
                theHtmlBody = theHtmlBodyOrig.replace(linktag, htmllink);
        
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                System.debug('fromname=='+fromname);
                System.debug('fromemail=='+fromemail);
                List<OrgWideEmailAddress> orgWideEmailAddresses = [select id, address from OrgWideEmailAddress where Address = :fromemail Limit 1];
                
                List<String> sendTo = new List<String>();
                sendTo.add(theCart.ccrz__Contact__r.Email);
                mail.setToAddresses(sendTo);
                if(orgWideEmailAddresses.size() > 0){
                    mail.setOrgWideEmailAddressId(orgWideEmailAddresses[0].Id);
                }else{
                    mail.setSenderDisplayName(fromname);}
                //mail.setReplyTo(fromemail);
                //mail.setSenderDisplayName(fromname);  
                mail.setSubject(subject);
                mail.setHtmlBody(theHtmlBody);
                mail.setPlainTextBody(theText);
                mails.add(mail);
                     System.debug('sendTo=='+sendTo);
                try{
                Messaging.sendEmail(mails);
                System.debug('mails=='+mails);
                }
                catch(Exception ex){
                     System.debug('mails1=='+mails);
                }
                // end of new email                 
                
                Map<String,Object> resultMap = new Map<String, Object>();
                resultMap.put('contactId', theCart.ccrz__Contact__c);
                result.data = resultMap;
                result.success = true;
            }
        } catch (Exception e) {
            System.debug('e.getMessage()=='+e.getMessage());
            result.success = false;
            ccrz.ccLog.log(System.LoggingLevel.ERROR, e.getMessage());
            ccrz.ccLog.log(System.LoggingLevel.ERROR, e.getLineNumber());
            ccrz.ccLog.log(System.LoggingLevel.ERROR, e.getStackTraceString());

        } finally {
            ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:X', 'ERG_ctrl_ReviewCart:sendOrderToCustomer');
            ccrz.ccLog.close(result);
        }
        return result;
    }
    
    
    @RemoteAction
    global static String getStateName(){
    	Id accountId = ccrz.cc_CallContext.currAccountId;
        return [SELECT BillingState FROM Account WHERE Id=:accountId LIMIT 1].BillingState;
    }
}