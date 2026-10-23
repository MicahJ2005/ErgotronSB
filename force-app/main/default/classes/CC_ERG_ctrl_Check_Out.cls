global class CC_ERG_ctrl_Check_Out {

    public Integer randomNumber{get; set;}
    public String cartSource{get;set;}
    global CC_ERG_ctrl_Check_Out()  {
        randomNumber = Integer.valueof((Math.random() * 100));
        cartSource = '';
        List<ccrz__E_Cart__c> listCart = [
            SELECT 
            Id, Name, ccrz__EncryptedId__c, Source__c 
            FROM ccrz__E_Cart__c 
            where ccrz__EncryptedId__c =: ccrz.cc_CallContext.currCartId 
        ];
        if (listCart.size() > 0) {
            if(String.isNotBlank(listCart[0].Source__c)){
                cartSource = listCart[0].Source__c;
            }
        }
    }
    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult doATPForStore(ccrz.cc_RemoteActionContext ctx, String SKU) {
        return CC_ERG_ctrl_atp.doATPForStore(ctx, SKU);
    }
    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult updatecart(ccrz.cc_RemoteActionContext ctx, string location, string SKU, string qty){
        return CC_ERG_ctrl_atp.updatecart(ctx, location,SKU,qty);// 2020.10.27 gvansteeter
    }
    
    @RemoteAction
    global static Map<String,Object> updatecartOwner(string cartEncId){
    
        Map<String,Object> result = new Map<String,Object>();
        try{
            List<ccrz__E_Cart__c> cartList = [SELECT Id, Name, OwnerId,ccrz__Contact__c,ccrz__User__c, ccrz__EncryptedId__c FROM ccrz__E_Cart__c 
                where ccrz__EncryptedId__c =:cartEncId limit 1];
            if(!cartList.isEmpty()){
                cartList[0].OwnerId = UserInfo.getUserId();
                cartList[0].ccrz__User__c = UserInfo.getUserId();
            }    
            List<User> usrDetail = [SELECT Name, Id, ContactId, AccountId FROM User where id =:UserInfo.getUserId() ];
            if(!usrDetail.isEmpty()){
                if(usrDetail[0].ContactId != null){
                    cartList[0].ccrz__Contact__c = usrDetail[0].ContactId;
                }
                if(usrDetail[0].AccountId != null){
                    cartList[0].ccrz__Account__c = usrDetail[0].AccountId;
                }
            }
            update cartList;
            result.put('success', true);
            //return CC_ERG_ctrl_atp.updatecart(ctx, location,SKU,qty);// 2020.10.27 gvansteeter
        } catch(Exception ex){
            system.debug('ex: '+ex);
            result.put('success', false);
        }
        
        return result;
    }
    
    
    /**
     * @author R1
     * @description Handles file upload done by the user for tax exemption
     * @param fileName String
     * @param base64Data String
     * @param portalUserId String
     * @return Boolean
    **/
    @RemoteAction
    global static Boolean fileUpload(String fileName, String base64Data,String portalUserId) {
        String userId;
        try {
            userId = String.isBlank(portalUserId) ? ccrz.cc_CallContext.currUserId : portalUserId;
            User currentUser = [SELECT Id, AccountId FROM User WHERE Id = :userId];
            Id accountId = currentUser.AccountId;
            Nebula.logger.info('Tax Exempt File Upload for User: '+userId);
            if (String.isBlank(fileName) || String.isBlank(base64Data) || accountId == null) {
                Nebula.logger.error('Either params are null- FileName: '+fileName + ' ,accountId: '+accountId);
                Nebula.logger.saveLog();
                return false;
            }

            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = fileName;
            contentVersion.PathOnClient = fileName;
            contentVersion.VersionData = EncodingUtil.base64Decode(base64Data);
            insert contentVersion;

            Id contentDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;

            ContentDocumentLink link = new ContentDocumentLink(ShareType='V',Visibility='AllUsers');
            link.ContentDocumentId = contentDocId;
            link.LinkedEntityId = accountId;
            insert link;
			update new Account(Id = accountId, ccrz__TaxExemptAccount__c = true);
            return true;
        } catch (Exception ex) {
            Nebula.logger.error('Error: '+ex.getMessage()+' '+ex.getStackTraceString());
            Nebula.logger.saveLog();
            return false;
        }
    }
    
}