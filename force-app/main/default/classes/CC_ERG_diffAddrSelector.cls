global with sharing class CC_ERG_diffAddrSelector {
    /*
     * Salesforce 2020
     *  Author: gvansteeter
     *    Date: 2020.04.16
     * Purpose: Implements functionality to select an account not related to the Account Heirarchy 
     *          for either the billing or shipping address.
     **********************************************************************************************
     * Modification: 2020.04.19
     *      Purpose: 1) Added new method getMapofAccounts, which calls getListofAccounts, to return
     *                  a map of AccountIDs plus the Account Name and Billing Street to the calling 
     *                  controller method.
     *               2) Modified updateCartAddress as remoteAction, returns a map to the calling
     *                  controller method.  The map returns a single record indicating "Success",
     *                  or "Failed: " and an error message indicating what went wrong.
     */
    
    //Updates the cart billing or shipping address
    @RemoteAction
    global static  Map<ID,String> updateCartAddress(String theDiffAcctId, String addrType, String theCartId){
        //ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);
        Map<ID,String> result = new Map<ID,String>();
        string methodName = 'cc_erg_diffAddrSelector.updateCartAddress';
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', methodName+' theDiffAcctId=('+theDiffAcctId+'); addrType=('+addrType+'); theCartId=('+theCartId+').');
        String theAddrType;
        boolean delExistingCCContAddr; 
        boolean noErrors = true;
        
        if(addrType.toLowerCase().contains('bill')){
            theAddrType = 'BillTo';
        }else{
            theAddrType = 'ShipTo';
        }
        
        ccrz__E_Cart__c theCart = [SELECT Id, Name, ccrz__Contact__c, ccrz__Contact__r.FirstName, 
                                              ccrz__Contact__r.LastName, ccrz__Contact__r.Email, 
                                              ccrz__Contact__r.Phone, ccrz__Account__c, ccrz__Account__r.Name, 
                                              ccrz__BillTo__c, ccrz__ShipTo__c 
                                     FROM ccrz__E_Cart__c 
                                    WHERE Id = :theCartId
                                       OR ccrz__EncryptedId__c = :theCartId];    
        
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, methodName+ ': FOUND THE CART.');
        // Get the Account address information for the new address
        try{
            Account theAccount = [SELECT Id, Name, BillingStreet ,Oracle_Address_1__c, Oracle_Address_2__c, 
                                         Oracle_Address_3__c ,Oracle_Address_4__c, Oracle_City__c,
                                         Oracle_Country__c, Oracle_Postal_Code__c, Oracle_State__c, 
                                         BillingCountry, BillingCountryCode, BillingState, BillingStateCode
                                    FROM Account
                                   WHERE Id = :theDiffAcctId];
            ccrz.ccLog.log(System.LoggingLevel.DEBUG, methodName+': FOUND THE DIFFERENT ACCOUNT.');
            
            String theOracle3rdAddressLine = theAccount.Oracle_Address_3__c;
            if(String.isNotEmpty(theAccount.Oracle_Address_4__c)){
                theOracle3rdAddressLine+=', '+theAccount.Oracle_Address_4__c;  
                    ccrz.ccLog.log(System.LoggingLevel.DEBUG, methodName+': Different account has an Oracle_Address_4__c value.');
            }      
            
            //Create a new ccrz__E_ContactAddr__c record to insert
            ccrz__E_ContactAddr__c theContactAddr = new ccrz__E_ContactAddr__c(
                ccrz__Partner_Id__c = theDiffAcctId,
                ccrz__FirstName__c = theCart.ccrz__Contact__r.FirstName,
                ccrz__LastName__c = theCart.ccrz__Contact__r.LastName,
                ccrz__DaytimePhone__c = theCart.ccrz__Contact__r.Phone,
                ccrz__Email__c = theCart.ccrz__Contact__r.Email,
                ccrz__CompanyName__c = theAccount.Name,
                ccrz__AddressFirstline__c = theAccount.Oracle_Address_1__c,
                ccrz__AddressSecondline__c = theAccount.Oracle_Address_2__c,
                ccrz__AddressThirdline__c = theOracle3rdAddressLine,
                ccrz__City__c = theAccount.Oracle_City__c,
                ccrz__State__c = theAccount.Oracle_State__c,
                ccrz__StateISOCode__c = theAccount.BillingStateCode,
                ccrz__Country__c = theAccount.Oracle_Country__c,
                ccrz__CountryISOCode__c = theAccount.BillingCountryCode,
                ccrz__PostalCode__c = theAccount.Oracle_Postal_Code__c
            );    
            
            ccrz.ccLog.log(System.LoggingLevel.DEBUG, methodName+': CREATED NEW CONTACT ADDRESS TO INSERT. Id = '+theContactAddr.Id);
            try{
                insert theContactAddr;
                ccrz.ccLog.log(System.LoggingLevel.DEBUG, methodName+': CONTACT ADDRESS INSERTED. Id = '+theContactAddr.Id);
                
                ccrz__E_ContactAddr__c theContAddr2Del = new ccrz__E_ContactAddr__c();
                ccrz__E_Cart__c theCartToUpd = new ccrz__E_Cart__c();
                theCartToUpd.Id = theCart.Id;
        
                ccrz.ccLog.log(System.LoggingLevel.DEBUG, methodName+': Added cart to theCartToUpd.');
                
                delExistingCCContAddr = false;
                
                if(theAddrType=='BillTo'){
                    if(String.isNotEmpty(theCart.ccrz__BillTo__c)){
                        theContAddr2Del.Id = theCart.ccrz__BillTo__c;
                        delExistingCCContAddr = true;
                    }
                    theCartToUpd.ccrz__BillTo__c = theContactAddr.Id;
                }else{
                    if(String.isNotEmpty(theCart.ccrz__ShipTo__c)){
                        theContAddr2Del.Id = theCart.ccrz__ShipTo__c;
                        delExistingCCContAddr = true;
                    }
                    theCartToUpd.ccrz__ShipTo__c = theContactAddr.Id;
                }
                ccrz.ccLog.log(System.LoggingLevel.DEBUG, methodName+': ABOUT TO EXECUTE UPDATE theCartToUpd.');
                try{
                    update theCartToUpd;
                    ccrz.ccLog.log(System.LoggingLevel.DEBUG, methodName+': UPDATE TO theCartToUpd FINISHED.');
                    
                    if(delExistingCCContAddr){
                        try{
                            delete theContAddr2Del;  
                            ccrz.ccLog.log(System.LoggingLevel.DEBUG, methodName+': delete theContAddr2Del. Done.');
                        }catch(Exception e){
                            ccrz.ccLog.log(System.LoggingLevel.ERROR, methodName+': Failed to delete the old contact address! (Not critical!)'+e.getMessage());
                            // no addition to the result map. This is a non-critical error.
                        }
                    }
                }catch(Exception e){
                    ccrz.ccLog.log(System.LoggingLevel.ERROR, methodName+': FAILED TO UPDATE THE CART WITH THE NEW ADDRESS!'+e.getMessage());
                    noErrors = false;
                    result.put(theCart.Id, 'Failed: Unable to update the cart '+theAddrType+' address: '+e.getMessage());
                }
            }catch(Exception e){
                ccrz.ccLog.log(System.LoggingLevel.ERROR, methodName+': FAILED TO INSERT THE NEW CONTACT ADDRESS!'+e.getMessage());
                noErrors = false;
                result.put(theCart.Id, 'Failed: Unable to insert new CC Contact Address: '+e.getMessage());
            }
                        
        }catch(Exception e){
            ccrz.ccLog.log(System.LoggingLevel.ERROR, methodName+': Unable to find an account with this ID: "'+theDiffAcctId+'": '+e.getMessage());
            noErrors = false;
            result.put(theCart.Id, 'Failed: Account not found for this ID: "'+theDiffAcctId+'": '+e.getMessage());
        }
        
        if(noErrors){
            result.put(theCart.Id, 'Success');
        }
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:X', methodName);            
        return result;

    }
    
    
    //returns a list of accounts to select from based on search string
    private static List<Account> getListofAccounts(String inputString){
        string methodName = 'cc_erg_diffAddrSelector.getListofAccounts';
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', methodName);
        //TODO: How would I bring a message or response to the page if they provide a search string that returns nothing?

        List<Account> listAccounts = new List<Account>();

        listAccounts = Flow_ATP_Controller.getMoreAccounts(inputString);
        
        if(listAccounts.size()>0){
            for(Account theAccount: listAccounts){
                ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'ID='+theAccount.Id
                            +'; Name='+theAccount.Name+'; BillingStreet='+theAccount.BillingStreet);
            }
        }
        
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:X', methodName);
        return listAccounts;
    }
    
    @RemoteAction
    global static Map<ID,String> getMapofAccounts(String inputString){
        
        Map<ID,String> result = new Map<ID,String>();
        
        List<Account>  listAccount = getListOfAccounts(inputString);
        
        if(listAccount.size()>0){
            for(Account theAccount: listAccount){
                //
                result.put(theAccount.Id, theAccount.Customer_Number__c + ' - ' + theAccount.Name+' - '+theAccount.BillingStreet);
            }
        }
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'result.size()='+result.size());
        return result;
    }
}