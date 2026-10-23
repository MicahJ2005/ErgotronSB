/*
Class to create account hierarchy
Step 1 -> Create BillTo/ShipTo
Step 2 -> Associate contact with account
Step 3 -> CC Order to account
Step 4 -> Validate Address
Step 5 -> Set Order Sync status* */
public class CC_ERG_CreateAccountHierarchy {
    public static string defaultAccountOwnerId {get; set;}
    
    @InvocableMethod
    // Method to check if order has billto/ ship to accounts
    public static void checkCCOrderBillToShipTo(List<string> eventData){
        Map<String,Object> mapOfccOrder;
        for(String eventDataString: eventData){
            mapOfccOrder = new Map<String,Object>();
            mapOfccOrder = (Map<String,Object>)JSON.deserializeUntyped(eventDataString);
        }
        String ccOrderId;
        if(!mapOfccOrder.isEmpty()){
            // get the cc order to create sales order
            ccOrderId = (String)mapOfccOrder.get('Id');  
            System.debug('account cc orderid=>'+ ccOrderId);
        }
        
        ccrz__E_Order__c ccOrder;
        if(String.isNotBlank(ccOrderId)){
            List<ccrz__E_Order__c> listOfCCOrders = [SELECT Id,ccrz__BillTo__c,ccrz__ShipTo__c,ccrz__OriginatedCart__c,
                                                     shipContactId__c,ccrz__Contact__c,ccrz__ShipComplete__c,ccrz__BuyerEmail__c,
                                                     ccrz__BuyerPhone__c ,ccrz__BuyerMobilePhone__c, cc_FreightCarrierActNbr__c,
                                                     Order_Number_Txt__c,ccrz__OrderNumber__c,
                                                     ccrz__OrderStatus__c,Sales_Order__c,
                                                     ccrz__Account__c //R1-29 May 2025-to set partner Id as the effective account
                                                     FROM ccrz__E_Order__c
                                                     WHERE Id = :ccOrderId LIMIT 1];
            if(!listOfCCOrders.isEmpty()){                
                ccOrder =listOfCCOrders[0];
            }
        }
        List<Account> accList = new List<Account>();
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'debug_CC_ERG_CreateAccountHierarchy#checkCCOrderBillToShipTo');
        
        //get default owner id from configuration
        defaultAccountOwnerId = getDefaultAccountOwnerId();
        
        if(ccOrder != null){
            if(ccOrder.ccrz__BillTo__c!= null && ccOrder.ccrz__ShipTo__c!= null){                
                Set<String> fieldsToInclude = new Set<String>{'ccrz__AddressFirstline__c','ccrz__AddressSecondline__c','ccrz__AddressThirdline__c',
                    'ccrz__City__c','ccrz__State__c','ccrz__StateISOCode__c','ccrz__Country__c','ccrz__CountryISOCode__c','ccrz__PostalCode__c','ccrz__FirstName__c','ccrz__LastName__c' };
                        
                        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'debug_CC_ERG_CreateAccountHierarchy#checkCCOrderBillToShipTo'+ ccOrder);
                
                Set<string> setOfBillToShipToOrder = new Set<string>();
                setOfBillToShipToOrder.add(ccOrder.ccrz__BillTo__c);
                setOfBillToShipToOrder.add(ccOrder.ccrz__ShipTo__c);
                ccrz__E_ContactAddr__c billTo;
                ccrz__E_ContactAddr__c shipTo;
                List<ccrz__E_ContactAddr__c>  listOfContactAddresses = [SELECT Id,ccrz__AddressFirstline__c,ccrz__AddressSecondline__c,ccrz__AddressThirdline__c, ccrz__Partner_Id__c,
                                                                        ccrz__City__c,ccrz__State__c,ccrz__StateISOCode__c,ccrz__Country__c,
                                                                        ccrz__CountryISOCode__c, ccrz__CompanyName__c,ccrz__FirstName__c,
                                                                        ccrz__LastName__c, ccrz__PostalCode__c 
                                                                        FROM ccrz__E_ContactAddr__c WHERE Id In :setOfBillToShipToOrder  LIMIT 2];
                if(!listOfContactAddresses.isEmpty()){
                    for(ccrz__E_ContactAddr__c contactAddress : listOfContactAddresses){
                        if(contactAddress.Id == ccOrder.ccrz__BillTo__c){
                            billTo = contactAddress;
                        }
                        else if(contactAddress.Id == ccOrder.ccrz__ShipTo__c){
                            shipTo = contactAddress;
                        }
                    }
                }
                
                ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'debug_CC_ERG_CreateAccountHierarchy#checkCCOrderBillToShipTo billTo'+ billTo);
                system.debug('*** billTo'+billTo);
                
                string siteRecordTypeId;
                List<RecordType> listOfRecordTypes = [SELECT Id,Name,DeveloperName FROM RecordType 
                                                      WHERE sObjectType = 'Account' AND DeveloperName = 'Site' 
                                                      LIMIT 1];
                if(!listOfRecordTypes.isEmpty()){
                    siteRecordTypeId = listOfRecordTypes[0].Id;
                }
                system.debug('*** shipTo'+shipTo);
                boolean isSame = false;
                for(String field : fieldsToInclude){
                    if (billTo.get(field) == shipTo.get(field)){
                        isSame = true;
                    }else{
                        isSame = false;
                        break;
                    }
                }
                ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'debug_CC_ERG_CreateAccountHierarchy#checkCCOrderBillToShipTo isSame'+ isSame);
                
                //R1-29 May 2025-to set partner Id as the effective account
                Id effectiveAccountId = ccOrder.ccrz__Account__c;
                if(isSame){
                    Account siteAccount = new Account();
                    if(String.isNotBlank(billTo.ccrz__AddressSecondline__c)){
                        siteAccount.BillingStreet = billTo.ccrz__AddressFirstline__c+ ' ' + billTo.ccrz__AddressSecondline__c;
                    }
                    else{
                        siteAccount.BillingStreet = billTo.ccrz__AddressFirstline__c;
                    }
                    siteAccount.BillingCity = billTo.ccrz__City__c;
                    siteAccount.BillingStateCode = billTo.ccrz__StateISOCode__c;
                    siteAccount.BillingCountryCode = billTo.ccrz__CountryISOCode__c;
                    siteAccount.BillingState = billTo.ccrz__State__c;
                    siteAccount.BillingCountry = billTo.ccrz__Country__c;
                    siteAccount.BillingPostalCode = billTo.ccrz__PostalCode__c;
                    siteAccount.ShippingStreet = billTo.ccrz__AddressFirstline__c;
                    siteAccount.ShippingCity = billTo.ccrz__City__c;
                    siteAccount.ShippingStateCode = billTo.ccrz__StateISOCode__c;
                    siteAccount.ShippingCountryCode = billTo.ccrz__CountryISOCode__c;
                    siteAccount.ShippingState = billTo.ccrz__State__c;
                    siteAccount.ShippingCountry = billTo.ccrz__Country__c;
                    siteAccount.ShippingPostalCode = billTo.ccrz__PostalCode__c;
                    siteAccount.AccountSource = Erg_Constants.eCommerce;
                    siteAccount.Region__c =  Erg_Constants.Americas;
                    
                    if(billTo.ccrz__CompanyName__c != null){
                        siteAccount.Name = billTo.ccrz__CompanyName__c  ;
                    }else{
                        siteAccount.Name = billTo.ccrz__FirstName__c +' '+billTo.ccrz__LastName__c  ;
                    }
                    siteAccount.RecordTypeId = siteRecordTypeId;
                    siteAccount.OwnerId =defaultAccountOwnerId;
                    if(ccrz.cc_CallContext.isGuest){
                    	insert siteAccount;
                        shipTo.ccrz__Partner_Id__c = siteAccount.Id;
                    	billTo.ccrz__Partner_Id__c = siteAccount.Id;
                    }
                    //R1-29 May 2025-to set partner Id as the effective account
                    else{
                    	shipTo.ccrz__Partner_Id__c = effectiveAccountId;
                    	billTo.ccrz__Partner_Id__c = effectiveAccountId;
                    }
                    update shipTo;
                    update billTo;
                    // create accounts for cc order
                    // R1 - 29 May 2025 - check for guest
                    if(ccrz.cc_CallContext.isGuest){
                    	createAccounts(siteAccount.id,ccOrder);
                    }
                    else{
                        createAccounts(null,ccOrder);
                    }
                }
                else{
                    
                    Account siteBillingAcc = new Account();
                    if(String.isNotBlank(billTo.ccrz__AddressSecondline__c)){
                        siteBillingAcc.BillingStreet = billTo.ccrz__AddressFirstline__c + ' ' + billTo.ccrz__AddressSecondline__c;
                    }
                    else{
                        siteBillingAcc.BillingStreet = billTo.ccrz__AddressFirstline__c;
                    }
                    
                    siteBillingAcc.BillingCity = billTo.ccrz__City__c;
                    siteBillingAcc.BillingState = billTo.ccrz__State__c;
                    siteBillingAcc.BillingCountry = billTo.ccrz__Country__c;
                    siteBillingAcc.BillingPostalCode = billTo.ccrz__PostalCode__c;
                    siteBillingAcc.ShippingStateCode = billTo.ccrz__StateISOCode__c;
                    siteBillingAcc.ShippingCountryCode = billTo.ccrz__CountryISOCode__c;
                    siteBillingAcc.AccountSource = Erg_Constants.eCommerce;
                    siteBillingAcc.Region__c =  Erg_Constants.Americas;
                    
                    if(billTo.ccrz__CompanyName__c != null){
                        siteBillingAcc.Name = billTo.ccrz__CompanyName__c  ;
                    }else{
                        siteBillingAcc.Name = billTo.ccrz__FirstName__c + ' '+billTo.ccrz__LastName__c  ;
                    }
                    
                    siteBillingAcc.RecordTypeId = siteRecordTypeId;
                    siteBillingAcc.OwnerId =defaultAccountOwnerId;
                    ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'debug_CC_ERG_CreateAccountHierarchy#checkCCOrderBillToShipTo '+ siteBillingAcc);
                    if(ccrz.cc_CallContext.isGuest){
                    	accList.add(siteBillingAcc);
                    }
                    ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'debug_CC_ERG_CreateAccountHierarchy#checkCCOrderBillToShipTo siteBillingAcc  => '+ siteBillingAcc);
                    
                    
                    Account siteShippingAcc = new Account();
                    if(String.isNotBlank(shipTo.ccrz__AddressSecondline__c)){
                        siteShippingAcc.BillingStreet = shipTo.ccrz__AddressFirstline__c +' '+ shipTo.ccrz__AddressSecondline__c;
                    }
                    else{
                        siteShippingAcc.BillingStreet = shipTo.ccrz__AddressFirstline__c;
                    }
                    
                    siteShippingAcc.BillingCity = shipTo.ccrz__City__c;
                    siteShippingAcc.BillingState = shipTo.ccrz__State__c;
                    siteShippingAcc.BillingCountry = shipTo.ccrz__Country__c;
                    siteShippingAcc.BillingPostalCode = shipTo.ccrz__PostalCode__c;
                    
                    if(String.isNotBlank(shipTo.ccrz__AddressSecondline__c)){
                        siteShippingAcc.ShippingStreet = shipTo.ccrz__AddressFirstline__c+' '+ shipTo.ccrz__AddressSecondline__c;
                    }
                    else{
                        siteShippingAcc.ShippingStreet = shipTo.ccrz__AddressFirstline__c;
                    }
                    
                    siteShippingAcc.ShippingCity = shipTo.ccrz__City__c;
                    siteShippingAcc.ShippingState = shipTo.ccrz__State__c;
                    siteShippingAcc.ShippingCountry = shipTo.ccrz__Country__c;
                    siteShippingAcc.ShippingPostalCode = shipTo.ccrz__PostalCode__c;
                    siteShippingAcc.ShippingStateCode = shipTo.ccrz__StateISOCode__c;
                    siteShippingAcc.ShippingCountryCode = shipTo.ccrz__CountryISOCode__c;
                    siteShippingAcc.Type =Erg_Constants.EndUser;
                    siteShippingAcc.AccountSource = Erg_Constants.eCommerce;
                    siteShippingAcc.Region__c =  Erg_Constants.Americas;
                    
                    siteShippingAcc.Ergotron_Vertical_Market__c = Erg_Constants.Consumer;
                    if(shipTo.ccrz__CompanyName__c != null){
                        siteShippingAcc.Name = shipTo.ccrz__CompanyName__c  ;
                    }else{
                        siteShippingAcc.Name = shipTo.ccrz__FirstName__c +' '+shipTo.ccrz__LastName__c  ;
                    }
                    siteShippingAcc.OwnerId =defaultAccountOwnerId;
                    siteShippingAcc.RecordTypeId = siteRecordTypeId;
                    ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'debug_CC_ERG_CreateAccountHierarchy#checkCCOrderBillToShipTo '+ siteShippingAcc);
                    
                    accList.add(siteShippingAcc);
                    if(!accList.isEmpty()){
                        insert accList;
                    }
                    ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'debug_CC_ERG_CreateAccountHierarchy#checkCCOrderBillToShipTo siteShippingAcc  => '+ siteShippingAcc);
                    
                    
                    List<ccrz__E_Cart__c> listOfCarts = [SELECT Id, ccrz__ShipTo__r.Id, Name FROM ccrz__E_Cart__c 
                                                         WHERE Id=: ccOrder.ccrz__OriginatedCart__c];
                    ccrz__E_Cart__c orderCart;
                    if(!listOfCarts.isEmpty()){
                        orderCart = listOfCarts[0];
                    }
                    ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'debug_CC_ERG_CreateAccountHierarchy#checkCCOrderBillToShipTo orderCart  => '+ orderCart.ccrz__ShipTo__r);
                    
                    ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'debug_CC_ERG_CreateAccountHierarchy#checkCCOrderBillToShipTo orderCart  => '+ orderCart);
                    
                    if(orderCart != null && orderCart.ccrz__ShipTo__r != null){
                        ccrz__E_ContactAddr__c orderCartShipTo = orderCart.ccrz__ShipTo__r;
                        
                        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'debug_CC_ERG_CreateAccountHierarchy#checkCCOrderBillToShipTo orderCartShipTo  => '+ orderCartShipTo);
                        if(ccrz.cc_CallContext.isGuest) {
                            Contact shipToContact = new Contact();
                            List<Contact> conExistList = [SELECT Id FROM Contact WHERE Cart_Contact__c = TRUE and Cart_Number__c =: orderCart.Name];
                            if(!conExistList.isEmpty()){
                                Contact existingContact = conExistList.get(0);
                                existingContact.LastName = shipTo.ccrz__LastName__c;
                                existingContact.FirstName = shipTo.ccrz__FirstName__c;
                                existingContact.Email = ccOrder.ccrz__BuyerEmail__c;
                                existingContact.Phone = ccOrder.ccrz__BuyerPhone__c;
                                existingContact.MobilePhone = ccOrder.ccrz__BuyerMobilePhone__c;
                                existingContact.OwnerId = defaultAccountOwnerId;
                                existingContact.AccountId = siteShippingAcc.Id;
                                update existingContact;
                                orderCartShipTo.contactId__c = existingContact.Id;
                            }else{
                                shipToContact.LastName = shipTo.ccrz__LastName__c;
                                shipToContact.FirstName = shipTo.ccrz__FirstName__c;
                                shipToContact.Email = ccOrder.ccrz__BuyerEmail__c;
                                shipToContact.Phone = ccOrder.ccrz__BuyerPhone__c;
                                shipToContact.MobilePhone = ccOrder.ccrz__BuyerMobilePhone__c;
                                shipToContact.OwnerId = defaultAccountOwnerId;
                                shipToContact.AccountId = siteShippingAcc.Id;
                                insert shipToContact;
                                orderCartShipTo.contactId__c = shipToContact.Id;
                            }
                            
                            
                            update orderCartShipTo;
                        }
                    }
                    
                    //R1 - 29 May 2025 - if ship to is different, then always create and assign new account
                    shipTo.ccrz__Partner_Id__c = siteShippingAcc.Id;
                    if(ccrz.cc_CallContext.isGuest){
                    	billTo.ccrz__Partner_Id__c = siteBillingAcc.Id;
                    }
                    //R1-29 May 2025-to set partner Id as the effective account
                    else{
                    	billTo.ccrz__Partner_Id__c = effectiveAccountId;
                    }
                    update shipTo;
                    update billTo;
                    
                    List<ccrz__E_Order__c> listOfCCOrders = [Select Id,Order_Number_Txt__c,ccrz__OrderNumber__c,ccrz__OriginatedCart__c
                                                             FROM ccrz__E_Order__c where Id=:ccOrder.Id];
                    ccrz__E_Order__c  ccOrderInfo;
                    if(!listOfCCOrders.isEmpty()){
                        ccOrderInfo = listOfCCOrders[0];
                    }
                    
                    if(String.isNotBlank(String.valueOf(ccOrderInfo.ccrz__OrderNumber__c))){
                        List<Sales_Order__c> salesOrderList = [Select Id,Billl_To_Contact__c,CC_Order_Number__c,Ship_To_Customer__c,Bill_To_Customer__c 
                                                               from Sales_Order__c where CC_Order_Number__c =:String.valueOf(ccOrderInfo.ccrz__OrderNumber__c) order by createddate desc limit 1];
                        
                        if(salesOrderList != null && salesOrderList.size()>0){
                            Sales_Order__c salesOrder = salesOrderList.get(0);
                            salesOrder.Bill_To_Customer__c = siteBillingAcc.Id;
                            salesOrder.Ship_To_Customer__c = siteShippingAcc.Id;
                            update salesOrder;
                        }
                    }
                    if(ccrz.cc_CallContext.isGuest){
                    	string customerAccId = createAccounts(siteBillingAcc.id,ccOrder);
                    	string customerAccId1 = createAccounts(siteShippingAcc.id,ccOrder);
                    }
                    else{
                        string customerAccId = createAccounts(siteShippingAcc.id,ccOrder);
                    }
                }
            }
        }
        
    }
    
    // create new accounts for the order
    public static string createAccounts(String accountId, ccrz__E_Order__c ccOrder){
        System.debug('createAccounts'+ accountId);
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'debug_CC_ERG_CreateAccountHierarchy#createAccounts '+ accountId);
        //get default owner id from configuration
        defaultAccountOwnerId = getDefaultAccountOwnerId();
        List<ccrz__E_Order__c> listOfCCOrders = [SELECT Id, ccrz__BuyerEmail__c, ccrz__BuyerFirstName__c, ccrz__BuyerLastName__c, 
                                                     ccrz__BuyerMobilePhone__c, ccrz__BuyerPhone__c, ccrz__Contact__c,
                                                     ccrz__Account__c , ccrz__OriginatedCart__r.isAddressVerified__c,
                                                     ccrz__OriginatedCart__r.Name
                                                     FROM ccrz__E_Order__c WHERE Id= :ccOrder.Id LIMIT 1];
            
        ccrz__E_Order__c order;
        if(!listOfCCOrders.isEmpty()){
           order = listOfCCOrders[0];
        }
        Account account = new Account();
        String siteRecordId;
        String customerRecordId;
        String partyRecordId;
        if(accountId != null){
            List<Account> listOfAccounts=[select id, Name, BillingStreet,BillingCity,BillingState,BillingCountry,BillingPostalCode, County__c, 
                                          ParentId, RecordTypeId 
                                          from Account where id=: accountId LIMIT 1];
            if(!listOfAccounts.isEmpty()){
                account = listOfAccounts[0];
            }
            List<RecordType> recLst = [select id,Name,DeveloperName from RecordType where sObjectType = 'Account'];
            
            if(recLst != null && recLst.size()>0){
                for(RecordType recType: recLst){
                    if(recType.DeveloperName == Erg_Constants.Site){
                        siteRecordId=recType.id;
                    }
                    if(recType.DeveloperName == Erg_Constants.Customer_Organization){
                        customerRecordId = recType.id;
                    }
                    if(recType.DeveloperName == Erg_Constants.Party){
                        partyRecordId = recType.id;
                    }
                }
            }
            ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'debug_CC_ERG_CreateAccountHierarchy#createAccounts '+ account);
            
            if(account.RecordTypeId == siteRecordId){
                if(account.ParentId != null){
                    Account parentAcc = [select id,RecordTypeId from Account where id=: account.ParentId LIMIT 1];
                    if(parentAcc.RecordTypeId != customerRecordId){
                        Account customerAcc = new Account();
                        customerAcc.BillingCountry = account.BillingCountry;
                        customerAcc.Name = account.Name;
                        customerAcc.ParentId = parentAcc.Id;
                        customerAcc.RecordTypeId = customerRecordId;
                        customerAcc.OwnerId =defaultAccountOwnerId;
                        customerAcc.AccountSource =Erg_Constants.eCommerce;
                        customerAcc.Region__c = Erg_Constants.Americas;
                        insert customerAcc;
                        
                        account.ParentId = customerAcc.id;
                        update account;
                    }
                }
                else{             
                    Account partyAcc = new Account();
                    partyAcc.BillingStreet = account.BillingStreet;
                    partyAcc.BillingCity = account.BillingCity;
                    partyAcc.BillingState = account.BillingState;
                    partyAcc.BillingCountry = account.BillingCountry;
                    partyAcc.BillingPostalCode = account.BillingPostalCode;
                    partyAcc.Name = account.Name;
                    partyAcc.RecordTypeId = partyRecordId;
                    partyAcc.OwnerId =defaultAccountOwnerId;
                    partyAcc.AccountSource = Erg_Constants.eCommerce;
                    partyAcc.Region__c = Erg_Constants.Americas;
                    insert partyAcc;
                    
                    
                    Account customerAcc = new Account();
                    customerAcc.BillingCountry = account.BillingCountry;
                    customerAcc.BillingStreet = account.BillingStreet;
                    customerAcc.BillingCity = account.BillingCity;
                    customerAcc.BillingState = account.BillingState;
                    customerAcc.BillingPostalCode = account.BillingPostalCode;
                    customerAcc.Name = account.Name;
                    customerAcc.ParentId = partyAcc.Id;
                    customerAcc.RecordTypeId = customerRecordId;
                    customerAcc.OwnerId =defaultAccountOwnerId;
                    customerAcc.AccountSource = Erg_Constants.eCommerce;
                    customerAcc.Region__c = Erg_Constants.Americas;
                    insert customerAcc;
                    
                    account.ParentId = customerAcc.id;
                    update account;
                }
            }
            
            if(ccrz.cc_CallContext.isGuest) {
                Contact contact = new Contact();
                List<Contact> conExistList;
                if(String.isNotBlank(order.ccrz__OriginatedCart__r.Name)){
                    conExistList = [SELECT Id FROM Contact WHERE Cart_Contact__c = TRUE and Cart_Number__c =: order.ccrz__OriginatedCart__r.Name];
                }
                if(!conExistList.isEmpty()){
                    Contact existingContact = conExistList.get(0);
                    existingContact.LastName = order.ccrz__BuyerLastName__c;
                    existingContact.FirstName = order.ccrz__BuyerFirstName__c;
                    existingContact.Email = order.ccrz__BuyerEmail__c;
                    existingContact.Phone = order.ccrz__BuyerPhone__c;
                    existingContact.MobilePhone = order.ccrz__BuyerMobilePhone__c;
                    existingContact.OwnerId = defaultAccountOwnerId;
                    existingContact.AccountId = account.Id;
                    update existingContact;
                    updateOrderAccount(order,account.Id, existingContact.Id);
                }
                else{
                    contact.LastName = order.ccrz__BuyerLastName__c;
                    contact.FirstName = order.ccrz__BuyerFirstName__c;
                    contact.Email = order.ccrz__BuyerEmail__c;
                    contact.Phone = order.ccrz__BuyerPhone__c;
                    contact.MobilePhone = order.ccrz__BuyerMobilePhone__c;
                    contact.OwnerId = defaultAccountOwnerId;
                    contact.AccountId = account.Id;
                    insert contact;
                    updateOrderAccount(order,account.Id, contact.Id);
                }
                  
            }
            if(checkIfAddressVerified(order)){
                createSalesOrder(order);
            }
            return account.ParentId;
            
        }
        //R1 - 29 May 2025 - for the case where we do not want to create accounts
        if(checkIfAddressVerified(order)){
            createSalesOrder(order);
        }
        return null;
    }
    
    //update the order with contact and account
    public static void updateOrderAccount(ccrz__E_Order__c order,String accountID, String contactId){
        if(order != null)
        {
            try{
                order.ccrz__Contact__c = contactId;
                order.ccrz__Account__c = accountID;
                update order;
            }catch(Exception e)
            {
                system.debug('Exception in method updateOrderAccount'+e.getMessage());
            }
        }
    }
    
    // check if address is verified and update the CC order status
    public static boolean checkIfAddressVerified(ccrz__E_Order__c ccOrder){
        boolean isAddressVerified = false;
        if(ccOrder.ccrz__OriginatedCart__r.isAddressVerified__c){
            ccOrder.ERG_Order_Sync_Status__c = Erg_Constants.Ready_For_Sales_Order;
            isAddressVerified = true;
        }
        /*else{                                                                                //ER2-193 : commenting for further processing manually, if user address is not verified
            ccOrder.ERG_Order_Sync_Status__c= Erg_Constants.Under_Review;
        }*/
        
        update ccOrder;
        return isAddressVerified;
    }
    
    // Method to publish the platform event to create SalesOrder from CC Order
    public static void createSalesOrder(ccrz__E_Order__c ccOrder){
        try{
            ERG_CCOrderToSalesOrder__e event = new ERG_CCOrderToSalesOrder__e();
            event.CCOrder__c  = JSON.serialize(ccOrder);
            Database.SaveResult result = EventBus.publish(event);  
        }
        catch(Exception ex){
            System.debug('Exception in createSalesOrder method');
            ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'debug_CC_ERG_CreateAccountHierarchy#createSalesOrder '+ ccOrder);
        }
    }
    
    // get default account owner id
    private static string getDefaultAccountOwnerId(){
        try{
            List<ccrz__E_Configuration__c> custom_configs_serverurlbase = [SELECT Name, ccrz__ConfigurationMeta__r.name, ccrz__TextValue__c 
                                                                           FROM ccrz__E_Configuration__c 
                                                                           WHERE ccrz__ConfigurationMeta__r.name = 'Default Account Owner'
                                                                           AND ccrz__TextValue__c !=null Limit 1]; 
            if(!custom_configs_serverurlbase.isEmpty()){
                defaultAccountOwnerId= custom_configs_serverurlbase[0].ccrz__TextValue__c;
            }
        }
        catch(Exception ex){
            ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'debug_CC_ERG_CreateAccountHierarchy#getDefaultAccountOwnerId ');
        }
        return defaultAccountOwnerId;
    }
}