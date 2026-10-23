global class CC_ERG_ctrl_PDP {
        
    @RemoteAction
    global static ccrz.cc_RemoteActionResult doATPForStore(ccrz.cc_RemoteActionContext ctx, String SKU) {
        return CC_ERG_ctrl_atp.doATPForStore(ctx, SKU);
    }
    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult updatecart(ccrz.cc_RemoteActionContext ctx, string location, string SKU, string qty){
        ccrz.cclog.log(System.LoggingLevel.DEBUG, 'CC_ERG_ctrl_PDP:updatecart', location);
        return CC_ERG_ctrl_atp.updatecart(ctx, location,SKU, qty);
    }
    
    public string theOrderType;
    public string  gettheOrderType(){
        return theOrderType;
    }
    public string thePriceList;
    public string  getthePriceList(){
        return thePriceList;
    }
       
    public CC_ERG_ctrl_PDP()
    {
        
        Boolean havePriceAndOrder;
        havePriceAndOrder = true;

        string thisOrderTypeID;  
        thisOrderTypeID =  ApexPages.currentPage().getParameters().get('orderType');
        if(thisOrderTypeID == NULL )
        {
             havePriceAndOrder = false;
        }
        
        string thisPriceListID;  
        thisPriceListID =  ApexPages.currentPage().getParameters().get('pricelistID');
        if(thisPriceListID == NULL )
        {
             havePriceAndOrder = false;
        }

        if( havePriceAndOrder == true)
        {
           
            Oracle_Order_Type__c theOrderTypeDetails = new Oracle_Order_Type__c(); 
            theOrderTypeDetails = [SELECT Name FROM Oracle_Order_Type__c WHERE Order_Type_id__c =:thisOrderTypeID];
            
            theOrderType = theOrderTypeDetails.Name;
            
            ccrz__E_PriceList__c thePriceListDetails = new ccrz__E_PriceList__c(); 
            
            thePriceListDetails = [SELECT Name FROM ccrz__E_PriceList__c WHERE ID =:thisPriceListID];
            thePriceList = thePriceListDetails.Name;            
        }        
        else    
        {
        
            string thisCartID;
            thisCartID = NULL;
            if(ccrz.cc_CallContext.currCartId == NULL)
            {
                thisCartID = ApexPages.currentPage().getParameters().get('caseID');
            }
            else
            {
                thisCartID = ccrz.cc_CallContext.currCartId;
            }
            
            theOrderType = 'Undefined';
            thePriceList = 'Undefined';
            
            if(thisCartID == NULL)
            {
                theOrderType = 'Undefined';
                thePriceList = 'Undefined';            
            }            
            else
            {
                List<ccrz__E_Cart__c> listCart = [SELECT priceListOverride__c, Ergotron_Order_Type__c FROM ccrz__E_Cart__c WHERE ccrz__EncryptedId__c =:thisCartID];
        
                string theOrderType_id = '';
                string thePriceList_id = '';
                
                if(listCart.size()>0)
                {
                    for(ccrz__E_Cart__c theCart : listCart)
                    {
                        theOrderType_id = theCart.Ergotron_Order_Type__c;
                        thePriceList_id = theCart.priceListOverride__c;
                    }
                }
                else
                {
                    theOrderType_id = '';
                    thePriceList_id = '';         
                }
        
                theOrderType = 'Undefined';
                thePriceList = 'Undefined';
                
         
                Oracle_Order_Type__c theOrderTypeDetails = new Oracle_Order_Type__c(); 
                theOrderTypeDetails = [SELECT Name FROM Oracle_Order_Type__c WHERE Order_Type_id__c =:theOrderType_id];
        
         
                theOrderType = theOrderTypeDetails.Name;
              
                ccrz__E_PriceList__c thePriceListDetails = new ccrz__E_PriceList__c(); 
                
                thePriceListDetails = [SELECT Name FROM ccrz__E_PriceList__c WHERE ID =:thePriceList_id];
                thePriceList = thePriceListDetails.Name;
            
            }   
        
        }
        
    }

    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult sendTestEmail(ccrz.cc_RemoteActionContext ctx ) {

        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'CC_ERG_ctrl_ReviewCart:sendTestEmail');


        
        result.success = false;
 
        string cartID;
        cartID = ctx.currentCartId; 

        Case theCase = [SELECT Id, CaseNumber FROM Case WHERE CC_CartId__r.ccrz__EncryptedId__c =:cartID];        
//        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'ERG_ctrl_ReviewCart: SELECT Id FROM Case WHERE CC_CartId__c = '+cartID);
        
        string caseNumber = theCase.CaseNumber;
 
        
//        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'ERG_ctrl_ReviewCart:sendTestEmail'+cartID);
//      ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'ERG_ctrl_ReviewCart:sendTestEmail  select Id, ccrz__ContractId__c  from ccrz__E_Cart__c where ccrz__EncryptedId__c='+cartID);            

        ID ContactID;
        ID AccountId;

        ccrz__E_Configuration__c custom_configs_template =[SELECT Name, ccrz__ConfigurationMeta__r.name, ccrz__TextValue__c FROM ccrz__E_Configuration__c where ccrz__ConfigurationMeta__r.name = 'Approver Email Template'];
        String templateUniqueName =  custom_configs_template.ccrz__TextValue__c;
        
        ccrz__E_Configuration__c custom_configs_link_tag =[SELECT Name, ccrz__ConfigurationMeta__r.name, ccrz__TextValue__c FROM ccrz__E_Configuration__c where ccrz__ConfigurationMeta__r.name = 'Approver Link Tag'];
        String linktag =  custom_configs_link_tag.ccrz__TextValue__c;

        ccrz__E_Configuration__c custom_configs_case_tag =[SELECT Name, ccrz__ConfigurationMeta__r.name, ccrz__TextValue__c FROM ccrz__E_Configuration__c where ccrz__ConfigurationMeta__r.name = 'Case Number Tag'];
        String casetag =  custom_configs_case_tag.ccrz__TextValue__c;
 
        ccrz__E_Configuration__c custom_configs_linkname =[SELECT Name, ccrz__ConfigurationMeta__r.name, ccrz__TextValue__c FROM ccrz__E_Configuration__c where ccrz__ConfigurationMeta__r.name = 'Link Name'];
        String linkname =  custom_configs_linkname.ccrz__TextValue__c;
 
        ccrz__E_Configuration__c custom_configs_fromname =[SELECT Name, ccrz__ConfigurationMeta__r.name, ccrz__TextValue__c FROM ccrz__E_Configuration__c where ccrz__ConfigurationMeta__r.name = 'From Name']; 
        String fromname =  custom_configs_fromname.ccrz__TextValue__c;
 

        ccrz__E_Configuration__c custom_configs_fromemail =[SELECT Name, ccrz__ConfigurationMeta__r.name, ccrz__TextValue__c FROM ccrz__E_Configuration__c where ccrz__ConfigurationMeta__r.name = 'From Email']; 
        String fromemail =  custom_configs_fromemail.ccrz__TextValue__c;
 

        ccrz__E_Configuration__c custom_configs_serverurlbase =[SELECT Name, ccrz__ConfigurationMeta__r.name, ccrz__TextValue__c FROM ccrz__E_Configuration__c where ccrz__ConfigurationMeta__r.name = 'Server URL']; 
        String serverurlbase =  custom_configs_serverurlbase.ccrz__TextValue__c;
 
        EmailTemplate et=[SELECT id,name, subject,HtmlValue FROM EmailTemplate where DeveloperName=:templateUniqueName]; // name is the unique name in UI
        
        ContactID = ccrz.cc_CallContext.currContact.Id;
        AccountId = ccrz.cc_CallContext.currAccountId;
 
        
        // gets the as rendered body, html, txt
        Messaging.SingleEmailMessage renderedemail = Messaging.renderStoredEmailTemplate(et.id, ContactID, AccountId);        
        String subjectOrig = renderedemail.getSubject();
        String theHtmlBodyOrig =  renderedemail.getHtmlBody();        
        String theTextOrig =  renderedemail.getPlainTextBody();
        
        
 
        theHtmlBodyOrig = theHtmlBodyOrig.replace(casetag, caseNumber);
        theTextOrig = theTextOrig.replace(casetag, caseNumber);
        
        
        String theText;
        String theHtmlBody;

        String cartURL = serverurlbase + '/ccrz__cart?cartID=' + cartID+'&jumpto=po';
        String emailLinkURL;        
        emailLinkURL = serverurlbase + '/ccrz__CCSiteLogin?cartID=' + cartID + '&startUrl=' + EncodingUtil.urlEncode(cartURL, 'UTF-8');        
               
        
        String htmllink;
        
        String subject;
        subject = subjectOrig.replace(casetag, caseNumber);
        htmllink ='<a href="'+emailLinkURL+'">'+linkname+'</a>';
        
        theText = theTextOrig.replace(linktag, emailLinkURL);
        theHtmlBody = theHtmlBodyOrig.replace(linktag, htmllink);
 

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
    List<String> sendTo = new List<String>();

    sendTo.add('tulanch@salesforce.com');
    sendTo.add('tulanch@yahoo.com');
    sendTo.add('jeff.williams@salesforce.com');
                
    mail.setToAddresses(sendTo);
        
//  mail.setTemplateId(et.id);    
//  mail.setTargetObjectId(ContactID);    
//  mail.setSaveAsActivity(false);  
        
      
    mail.setReplyTo(fromemail);  
    mail.setSenderDisplayName(fromname);  
        
    mail.setSubject(subject);
        
    mail.setHtmlBody(theHtmlBody);
    mail.setPlainTextBody(theText);
       
        
   
     
    mails.add(mail);
        

        
        
    Messaging.sendEmail(mails);

        
        

    result.success = true;

        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:X', 'CC_ERG_ctrl_ReviewCart:sendTestEmail');
        ccrz.ccLog.close(result);
// end of email 

        return result;
    }    
    
    
  }