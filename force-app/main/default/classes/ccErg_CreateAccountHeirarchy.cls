global without sharing class ccErg_CreateAccountHeirarchy {

    
    global static String createAccounts(String accId, ccrz__E_Order__c ccOrder){
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'debug_ccErg_CreateAccountHeirarchy#createAccounts '+ accId);
        ccrz__E_Configuration__c custom_configs_serverurlbase =[SELECT Name, ccrz__ConfigurationMeta__r.name, ccrz__TextValue__c FROM ccrz__E_Configuration__c where ccrz__ConfigurationMeta__r.name = 'Default Account Owner']; 
        String defaultAccountOwnerId =  custom_configs_serverurlbase.ccrz__TextValue__c;
        Account acc = new Account();
        String siteRecordId;
        String customerRecordId;
        String partyRecordId;
        if(accId != null){
            acc=[select id, Name, BillingStreet,BillingCity,BillingState,BillingCountry,BillingPostalCode, County__c, 
                 ParentId, RecordTypeId from Account where id=: accId LIMIT 1];
            List<RecordType> recLst = [select id,Name,DeveloperName from RecordType where sObjectType = 'Account'];
            // siteRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName.get('Site').getRecordTypeId();
            // customerRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName.get('Customer_Organization').getRecordTypeId();
            // partyRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName.get('Party').getRecordTypeId();
            if(recLst != null && recLst.size()>0){
                for(RecordType recType: recLst){
                    if(recType.DeveloperName == 'Site'){
                        siteRecordId=recType.id;
                    }
                    if(recType.DeveloperName == 'Customer_Organization'){
                        customerRecordId = recType.id;
                    }
                    if(recType.DeveloperName == 'Party'){
                        partyRecordId = recType.id;
                    }
                }
            }
            ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'debug_ccErg_CreateAccountHeirarchy#createAccounts '+ acc);

            if(acc.RecordTypeId == siteRecordId){
                if(acc.ParentId != null){
                    Account parentAcc = [select id,RecordTypeId from Account where id=: acc.ParentId LIMIT 1];
                    if(parentAcc.RecordTypeId != customerRecordId){
                        Account customerAcc = new Account();
                        customerAcc.BillingCountry = acc.BillingCountry;
                        customerAcc.Name = acc.Name;
                        customerAcc.ParentId = parentAcc.Id;
                        customerAcc.RecordTypeId = customerRecordId;
                        customerAcc.OwnerId =defaultAccountOwnerId;
                        customerAcc.AccountSource = 'eCommerce';
                        customerAcc.Region__c = 'Americas';
                        insert customerAcc;
                        acc.ParentId = customerAcc.id;
                        update acc;
                    }
                }
                else{
                    Account partyAcc = new Account();
                    partyAcc.BillingStreet = acc.BillingStreet;
                    partyAcc.BillingCity = acc.BillingCity;
                    partyAcc.BillingState = acc.BillingState;
                    partyAcc.BillingCountry = acc.BillingCountry;
                    partyAcc.BillingPostalCode = acc.BillingPostalCode;
                    partyAcc.Name = acc.Name;
                    partyAcc.RecordTypeId = partyRecordId;
                    partyAcc.OwnerId =defaultAccountOwnerId;
                    partyAcc.AccountSource = 'eCommerce';
                    partyAcc.Region__c = 'Americas';

                    insert partyAcc;
                    
                    Account customerAcc = new Account();
                    customerAcc.BillingCountry = acc.BillingCountry;
                    customerAcc.BillingStreet = acc.BillingStreet;
                    customerAcc.BillingCity = acc.BillingCity;
                    customerAcc.BillingState = acc.BillingState;
                    customerAcc.BillingPostalCode = acc.BillingPostalCode;
                    customerAcc.Name = acc.Name;
                    customerAcc.ParentId = partyAcc.Id;
                    customerAcc.RecordTypeId = customerRecordId;
                    customerAcc.OwnerId =defaultAccountOwnerId;
                    customerAcc.AccountSource = 'eCommerce';
                    customerAcc.Region__c = 'Americas';

                    insert customerAcc;
                    
                    acc.ParentId = customerAcc.id;
                    update acc;
                }
            }

            ccrz__E_Order__c order = [SELECT Id, ccrz__BuyerEmail__c, ccrz__BuyerFirstName__c, ccrz__BuyerLastName__c, 
                ccrz__BuyerMobilePhone__c, ccrz__BuyerPhone__c, ccrz__Contact__c, ccrz__Account__c 
                    FROM ccrz__E_Order__c WHERE Id= :ccOrder.Id LIMIT 1];
			if(ccrz.cc_CallContext.isGuest) {
                Contact contact = new Contact();
                contact.LastName = order.ccrz__BuyerLastName__c;
                contact.FirstName = order.ccrz__BuyerFirstName__c;
                contact.Email = order.ccrz__BuyerEmail__c;
                contact.Phone = order.ccrz__BuyerPhone__c;
                contact.MobilePhone = order.ccrz__BuyerMobilePhone__c;
                contact.OwnerId = defaultAccountOwnerId;
                contact.AccountId = acc.Id;
                insert contact;
    
                ccErg_CreateAccountHeirarchy.updateOrderAccount(order,acc.Id, contact.Id);
            }
            return acc.ParentId;
        }
        return null;
    }
    
    public static void updateOrderAccount(ccrz__E_Order__c order,String accountID, String contactId)
    {
        system.debug('order Id destails--->'+order);
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
    
    global static void checkCCOrderBillToShipTo(ccrz__E_Order__c ccOrder){
        list<Account> accList = new List<Account>();
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'debug_ccErg_CreateAccountHeirarchy#checkCCOrderBillToShipTo');
        ccrz__E_Configuration__c custom_configs_serverurlbase = [SELECT Name, ccrz__ConfigurationMeta__r.name, ccrz__TextValue__c FROM ccrz__E_Configuration__c where ccrz__ConfigurationMeta__r.name = 'Default Account Owner'
        and ccrz__TextValue__c !=null]; 
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'debug_ccErg_CreateAccountHeirarchy#checkCCOrderBillToShipTo -> found configuration');
        String defaultAccountOwnerId =  custom_configs_serverurlbase.ccrz__TextValue__c;
		System.debug('ccOrder : '+ccOrder);
        if(ccOrder != null){
            if(ccOrder.ccrz__BillTo__c!= null && ccOrder.ccrz__ShipTo__c!= null){
                
                Set<String> fieldsToInclude = new Set<String>{'ccrz__AddressFirstline__c','ccrz__AddressSecondline__c','ccrz__AddressThirdline__c',
                    'ccrz__City__c','ccrz__State__c','ccrz__StateISOCode__c','ccrz__Country__c','ccrz__CountryISOCode__c','ccrz__PostalCode__c','ccrz__FirstName__c','ccrz__FirstName__c' };

                ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'debug_ccErg_CreateAccountHeirarchy#checkCCOrderBillToShipTo'+ ccOrder);
                ccrz__E_ContactAddr__c billTo = [select id,ccrz__AddressFirstline__c,ccrz__AddressSecondline__c,ccrz__AddressThirdline__c,
                                                         ccrz__Partner_Id__c,ccrz__City__c,ccrz__State__c,ccrz__StateISOCode__c,ccrz__Country__c,ccrz__CountryISOCode__c,
                                                         ccrz__CompanyName__c,ccrz__FirstName__c,ccrz__LastName__c,
                                                         ccrz__PostalCode__c from ccrz__E_ContactAddr__c where id=: ccOrder.ccrz__BillTo__c LIMIT 1];
                
                ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'debug_ccErg_CreateAccountHeirarchy#checkCCOrderBillToShipTo billTo'+ billTo);
                system.debug('*** billTo'+billTo);
                ccrz__E_ContactAddr__c shipTo = [select id,ccrz__AddressFirstline__c,ccrz__AddressSecondline__c,ccrz__AddressThirdline__c,
                                                 ccrz__Partner_Id__c,ccrz__City__c,ccrz__State__c,ccrz__StateISOCode__c,ccrz__Country__c,ccrz__CountryISOCode__c,
                                                 ccrz__CompanyName__c,ccrz__FirstName__c,ccrz__LastName__c,
                                                 ccrz__PostalCode__c from ccrz__E_ContactAddr__c where id=: ccOrder.ccrz__ShipTo__c LIMIT 1];
                RecordType siteRecordId = [select id,Name,DeveloperName from RecordType where sObjectType = 'Account' AND DeveloperName = 'Site' LIMIT 1];
                system.debug('*** shipTo'+shipTo);
                boolean isSame = false;
                
                for(String field : fieldsToInclude)
                {
                    if (billTo.get(field) == shipTo.get(field))
                    {
                        isSame = true;
                    }else{
                        isSame = false;
                        break;
                    }
                }
                
                // Schema.DescribeFieldResult fieldResult = Account.BillingStateCode.getDescribe();
                // Map<String,String> statePickLst = new Map<String,String>();
                // List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                // System.debug('Picklist::'+ple);
                // for( Schema.PicklistEntry f : ple){
                //     statePickLst.put(f.getValue(),f.getLabel());
                // }
                ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'debug_ccErg_CreateAccountHeirarchy#checkCCOrderBillToShipTo isSame'+ isSame);
                
                if(isSame){
                    Account siteAcc = new Account();
                    siteAcc.BillingStreet = billTo.ccrz__AddressFirstline__c;
                    siteAcc.BillingCity = billTo.ccrz__City__c;
                    siteAcc.BillingStateCode = billTo.ccrz__StateISOCode__c;
                    siteAcc.BillingCountryCode = billTo.ccrz__CountryISOCode__c;
                    siteAcc.BillingState = billTo.ccrz__State__c;
                    siteAcc.BillingCountry = billTo.ccrz__Country__c;
                    siteAcc.BillingPostalCode = billTo.ccrz__PostalCode__c;
                    siteAcc.ShippingStreet = billTo.ccrz__AddressFirstline__c;
                    siteAcc.ShippingCity = billTo.ccrz__City__c;
                    siteAcc.ShippingStateCode = billTo.ccrz__StateISOCode__c;
                    siteAcc.ShippingCountryCode = billTo.ccrz__CountryISOCode__c;
                    siteAcc.ShippingState = billTo.ccrz__State__c;
                    siteAcc.ShippingCountry = billTo.ccrz__Country__c;
                    siteAcc.ShippingPostalCode = billTo.ccrz__PostalCode__c;
                    siteAcc.AccountSource = 'eCommerce';
                    siteAcc.Region__c = 'Americas';

                    if(billTo.ccrz__CompanyName__c != null){
                    siteAcc.Name = billTo.ccrz__CompanyName__c  ;
                    }else{
                    siteAcc.Name = billTo.ccrz__FirstName__c +' '+billTo.ccrz__LastName__c  ;
                    }
                    siteAcc.RecordTypeId = siteRecordId.Id;
                    siteAcc.OwnerId =defaultAccountOwnerId;
                    system.debug('siteAcc-------'+siteAcc);
                    insert siteAcc;
                    system.debug(siteAcc.id);

                    shipTo.ccrz__Partner_Id__c = siteAcc.Id;
                    billTo.ccrz__Partner_Id__c = siteAcc.Id;
                    
                    update shipTo;
                    update billTo;
                    createAccounts(siteAcc.id,ccOrder);
                }
                else{
                    Account siteBillingAcc = new Account();
                    siteBillingAcc.BillingStreet = billTo.ccrz__AddressFirstline__c;
                    siteBillingAcc.BillingCity = billTo.ccrz__City__c;
                    siteBillingAcc.BillingState = billTo.ccrz__State__c;
                    siteBillingAcc.BillingCountry = billTo.ccrz__Country__c;
                    siteBillingAcc.BillingPostalCode = billTo.ccrz__PostalCode__c;
                    siteBillingAcc.ShippingStateCode = billTo.ccrz__StateISOCode__c;
                    siteBillingAcc.ShippingCountryCode = billTo.ccrz__CountryISOCode__c;
                    siteBillingAcc.AccountSource = 'eCommerce';
                    siteBillingAcc.Region__c = 'Americas';

                    if(billTo.ccrz__CompanyName__c != null){
                    siteBillingAcc.Name = billTo.ccrz__CompanyName__c  ;
                    }else{
                    siteBillingAcc.Name = billTo.ccrz__FirstName__c + ' '+billTo.ccrz__LastName__c  ;
                    }
                    
                    siteBillingAcc.RecordTypeId = siteRecordId.Id;
                    siteBillingAcc.OwnerId =defaultAccountOwnerId;

                    ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'debug_ccErg_CreateAccountHeirarchy#checkCCOrderBillToShipTo '+ siteBillingAcc);
                    //insert siteBillingAcc;
                    accList.add(siteBillingAcc);
                    ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'debug_ccErg_CreateAccountHeirarchy#checkCCOrderBillToShipTo siteBillingAcc  => '+ siteBillingAcc);

                    Account siteShippingAcc = new Account();
                    siteShippingAcc.BillingStreet = shipTo.ccrz__AddressFirstline__c;
                    siteShippingAcc.BillingCity = shipTo.ccrz__City__c;
                    siteShippingAcc.BillingState = shipTo.ccrz__State__c;
                    siteShippingAcc.BillingCountry = shipTo.ccrz__Country__c;
                    siteShippingAcc.BillingPostalCode = shipTo.ccrz__PostalCode__c;

                    siteShippingAcc.ShippingStreet = shipTo.ccrz__AddressFirstline__c;
                    siteShippingAcc.ShippingCity = shipTo.ccrz__City__c;
                    siteShippingAcc.ShippingState = shipTo.ccrz__State__c;
                    siteShippingAcc.ShippingCountry = shipTo.ccrz__Country__c;
                    siteShippingAcc.ShippingPostalCode = shipTo.ccrz__PostalCode__c;
                    siteShippingAcc.ShippingStateCode = shipTo.ccrz__StateISOCode__c;
                    siteShippingAcc.ShippingCountryCode = shipTo.ccrz__CountryISOCode__c;
                    siteShippingAcc.Type = 'End User';
                    siteShippingAcc.AccountSource = 'eCommerce';
                    siteShippingAcc.Region__c = 'Americas';

                    siteShippingAcc.Ergotron_Vertical_Market__c = 'Consumer';
                    if(shipTo.ccrz__CompanyName__c != null){
                    siteShippingAcc.Name = shipTo.ccrz__CompanyName__c  ;
                    }else{
                    siteShippingAcc.Name = shipTo.ccrz__FirstName__c +' '+shipTo.ccrz__LastName__c  ;
                    }
                    siteShippingAcc.OwnerId =defaultAccountOwnerId;
                    siteShippingAcc.RecordTypeId = siteRecordId.Id;
                    ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'debug_ccErg_CreateAccountHeirarchy#checkCCOrderBillToShipTo '+ siteShippingAcc);
                    //insert siteShippingAcc;
                    accList.add(siteShippingAcc);
                    insert accList;
                    ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'debug_ccErg_CreateAccountHeirarchy#checkCCOrderBillToShipTo siteShippingAcc  => '+ siteShippingAcc);


                    ccrz__E_Cart__c orderCart = [SELECT id, ccrz__ShipTo__r.Id FROM ccrz__E_Cart__c WHERE id=: ccOrder.ccrz__OriginatedCart__c];
                    ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'debug_ccErg_CreateAccountHeirarchy#checkCCOrderBillToShipTo orderCart  => '+ orderCart.ccrz__ShipTo__r);

                    ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'debug_ccErg_CreateAccountHeirarchy#checkCCOrderBillToShipTo orderCart  => '+ orderCart);
                    
                    if(orderCart != null && orderCart.ccrz__ShipTo__r != null){
                        ccrz__E_ContactAddr__c orderCartShipTo = orderCart.ccrz__ShipTo__r;

                        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'debug_ccErg_CreateAccountHeirarchy#checkCCOrderBillToShipTo orderCartShipTo  => '+ orderCartShipTo);
                        if(ccrz.cc_CallContext.isGuest) {
                            Contact shipToContact = new Contact();
                            shipToContact.LastName = shipTo.ccrz__LastName__c;
                            shipToContact.FirstName = shipTo.ccrz__FirstName__c;
                            shipToContact.Email = ccOrder.ccrz__BuyerEmail__c;
                            shipToContact.Phone = ccOrder.ccrz__BuyerPhone__c;
                            shipToContact.MobilePhone = ccOrder.ccrz__BuyerMobilePhone__c;
                            shipToContact.OwnerId = defaultAccountOwnerId;
                            shipToContact.AccountId = siteShippingAcc.Id;
                            insert shipToContact;
                            orderCartShipTo.contactId__c = shipToContact.Id;
                            update orderCartShipTo;
                            System.debug('orderCartShipTo ==> '+ orderCartShipTo);
                        }
                    }
                    shipTo.ccrz__Partner_Id__c = siteShippingAcc.Id;
                    billTo.ccrz__Partner_Id__c = siteBillingAcc.Id;
                    
                    update shipTo;
                    update billTo;
                    ccrz__E_Order__c ccOrderInfo = [Select Id,Order_Number_Txt__c,ccrz__OrderNumber__c from ccrz__E_Order__c where Id=:ccOrder.Id];
                    System.debug('String.valueOfccOrder.ccrz__OrderNumber__c :'+String.valueOf(ccOrderInfo.ccrz__OrderNumber__c));
                    System.debug('String.valueOfccOrder :'+ccOrderInfo.Order_Number_Txt__c);
                    if(String.isNotBlank(String.valueOf(ccOrderInfo.ccrz__OrderNumber__c))){
                        List<Sales_Order__c> salesOrderList = [Select Id,Billl_To_Contact__c,CC_Order_Number__c,Ship_To_Customer__c,Bill_To_Customer__c from Sales_Order__c where CC_Order_Number__c =:String.valueOf(ccOrderInfo.ccrz__OrderNumber__c) order by createddate desc limit 1];
                        System.debug('salesOrderList :'+salesOrderList);
                        if(salesOrderList != null && salesOrderList.size()>0){
                            Sales_Order__c salesOrder = salesOrderList.get(0);
                            salesOrder.Bill_To_Customer__c = siteBillingAcc.Id;
                            salesOrder.Ship_To_Customer__c = siteShippingAcc.Id;
                            //salesOrder.Billl_To_Contact__c = ccOrder.ccrz__Contact__c;
                            update salesOrder;
                        }
                	}
                    string customerAccId = createAccounts(siteBillingAcc.id,ccOrder);
                    string customerAccId1 = createAccounts(siteShippingAcc.id,ccOrder);

                    
                    
                    // if(String.isNotBlank(customerAccId1)) {
                    //     siteShippingAcc.ParentId = customerAccId1;
                    //     update siteShippingAcc;
                    // }
                }
            }
        }
    }
}