global with sharing class ccErgoServiceAddressBook extends ccrz.ccServiceAddressBook {
// Version: 2020.09.23 MST
    global override Map<String,Object> fetch(Map<String,Object> inputData) {
        Map<String,Object> outputData = super.fetch(inputData);//2020.09.23        
        ID accountId = ccrz.cc_CallContext.currAccountId;
        Integer billAddrCounter = 0; //unique ids for billing addresslist records.
        Integer shipAddrCounter = 1000; // unique ids for shipping address list records.
        Integer addrRecordCounter = 0; // unique ids for all addressList records w/o discrimination between billing and shipping.
        Integer addrBookRecCounter = 10000; // unique ids for all addressBook records w/o discrimination between billing and shipping.
        Boolean boolShipAddr;
        Boolean boolBillAddr;
        Boolean boolDefault; // used to determine if the address should default on the checkout page.
        Integer shipLink;
        Integer billLink;
        
        if (!ccrz.cc_CallContext.isGuest){ //2020.09.23
            ID contactId = ccrz.cc_CallContext.currContact.Id; //2020.09.23
                
            //get the contact's first and last name
            Contact theContact = [select firstName, lastName
                                    from contact
                                   where id = :contactId]; 
           
            //BEGIN ACCOUNT TRAVERSAL
            Account theAccount = [select id, parentID  
                                    from account 
                                   where id = :accountId];
            Set<ID> AllParents = new Set<ID>();
            Account allAccts = new Account();
            Boolean allDone;
            
            AllParents.add(theAccount.ID);
            //If the account we are starting at has a Parent ID, add it to the set of IDs
            if(theAccount.ParentID != Null){
                AllParents.add(theAccount.ParentID);
            }
            
            //MAIN LOOP TRAVERSE HIERARCHY
            do{
                //Set the flag to indicate loop should stop
                allDone = true;
                //Get a list of accounts with IDs or Parent IDs in the AllParents Set
                //This will produce 1 SOQL for each level in the Hierachy 
                //For Ergotron, that should be three loops.
                for(Account a : [Select ID, ParentID
                                   From Account 
                                  Where ID IN :AllParents OR ParentID IN :AllParents]){
                    if(!AllParents.contains(a.ID) || ( !AllParents.contains(a.parentID) && a.parentID != null)){
    
                        if(a.parentID != null)
                           AllParents.add(a.parentID);
                           AllParents.add(a.id); 
                           //Reset flag to find more parents / children
                           allDone = false;
                    }
                }
            } while(allDone == false); //Finished traversing the account hierarchy.
            
    
            List<Map<String,Object>> newAddressList = new List<Map<String,Object>>(); // collection of addresses
            List<Map<String,Object>> newAddressBook = new List<Map<String,Object>>(); // collection of addressbooks
     
    //        for(ID i : AllParents) {
                
                for(Account a2 : [Select ID, ParentID, Name, AccountSource,
                                         BillingStreet, BillingCity, BillingStateCode, BillingPostalCode, BillingCountry, BillingCountryCode,
                                         ShippingStreet, ShippingCity, ShippingStateCode, ShippingPostalCode, ShippingCountry, ShippingCountryCode
                                    From Account 
                                  //Where ID = :i]){
                                  Where ID in: AllParents]){
                                  
                    //ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'debug_ccServiceAddressBook:a2: ', JSON.serialize(a2));
                    boolShipAddr = false;
                    boolBillAddr = false;
                    boolDefault = false;
    
                    if(a2.Id == accountId) {
                        boolDefault = true;                      
                    }
                    
                    Map<String,Object> newAddressListEntry = new Map<String,Object>(); // billing addresses
                    Map<String,Object> newAddressListEntry2 = new Map<String,Object>(); // shipping addresses
                    Map<String,Object> newAddressBookEntry = new Map<String,Object>(); // billing addresses
                    Map<String,Object> newAddressBookEntry2 = new Map<String,Object>(); // shipping addresses
                    
                    //BUILD THE ADDRESS LIST ENTRIES
                    // TODO: Whole thing fails if we don't have a billing address for the account.  
                    // On 2020.02.10, checked ecom(Sandbox) and there were no accounts w/o a billing address
                    // Nonetheless, do we need some error handling here?
                    if (String.isNotBlank(a2.BillingStreet)) {
                        // Add the billing address to the billing address entries.
                        billAddrCounter++;
                        addrRecordCounter++;
                        boolBillAddr = true;
                        newAddressListEntry.put('sfid', String.valueOf(billAddrCounter)); //this will join this addressList record to addressBook.
                        newAddressListEntry.put('ownerId', contactId); 
                        newAddressListEntry.put('sfdcName', String.valueOf(addrRecordCounter)); // make this unique!
                        newAddressListEntry.put('addrReadOnly', true);
                        newAddressListEntry.put('addressFirstline', a2.BillingStreet);
                        newAddressListEntry.put('city', a2.BillingCity);
                        newAddressListEntry.put('companyName', a2.Name);
                        newAddressListEntry.put('countryISOCode', a2.BillingCountryCode);
                        newAddressListEntry.put('country', a2.BillingCountry);
                        newAddressListEntry.put('firstName', theContact.FirstName); 
                        newAddressListEntry.put('lastName', theContact.LastName); 
                        newAddressListEntry.put('postalCode', a2.BillingPostalCode);
                        newAddressListEntry.put('stateISOCode', a2.BillingStateCode);
                        newAddressListEntry.put('partnerId', a2.Id);
    
                        newAddressList.add(newAddressListEntry); 
    
                        // Add the billing address as a shipping address.
                        shipAddrCounter++;
                        addrRecordCounter++;
                        boolShipAddr = true;
                        if(a2.AccountSource == 'eCommerce'){
                            newAddressListEntry2.put('addressFirstline', a2.ShippingStreet);
                            newAddressListEntry2.put('city', a2.ShippingCity);
                            newAddressListEntry2.put('countryISOCode', a2.ShippingCountryCode);
                            newAddressListEntry2.put('country', a2.ShippingCountry);
                            newAddressListEntry2.put('postalCode', a2.ShippingPostalCode);
                            newAddressListEntry2.put('stateISOCode', a2.ShippingStateCode);
                        } else{
                            newAddressListEntry2.put('addressFirstline', a2.BillingStreet);
                            newAddressListEntry2.put('city', a2.BillingCity);
                            newAddressListEntry2.put('countryISOCode', a2.BillingCountryCode);
                            newAddressListEntry2.put('country', a2.BillingCountry);
                            newAddressListEntry2.put('postalCode', a2.BillingPostalCode);
                            newAddressListEntry2.put('stateISOCode', a2.BillingStateCode);
                        }
                        newAddressListEntry2.put('sfid', String.valueOf(shipAddrCounter)); //This will join this addressList record to addressBook.
                        newAddressListEntry2.put('ownerId', contactId);
                        newAddressListEntry2.put('sfdcName', String.valueOf(addrRecordCounter)); // make this unique!
                        newAddressListEntry2.put('addrReadOnly', true);
                        newAddressListEntry2.put('companyName', a2.Name);
                        newAddressListEntry2.put('firstName', theContact.FirstName); 
                        newAddressListEntry2.put('lastName', theContact.LastName); 
                        newAddressListEntry2.put('partnerId', a2.Id);
                        newAddressList.add(newAddressListEntry2);                     
                        billLink = billAddrCounter;
                        shipLink = shipAddrCounter;
        
                         // billing addressbook entry
                        addrBookRecCounter++;
                        newAddressBookEntry.put('typeReadOnly', true);
                        newAddressBookEntry.put('EContactAddress', String.valueOf(billLink));
                        newAddressBookEntry.put('default', boolDefault);
                        newAddressBookEntry.put('addressType', 'Billing');
                        newAddressBookEntry.put('accountId', accountId);
                        newAddressBookEntry.put('ownerId', contactId);
                        newAddressBookEntry.put('sfdcName', Null);
                        newAddressBookEntry.put('sfid', addrBookRecCounter);
        
                        newAddressBook.add(newAddressBookEntry);
                                          
                        // shipping addressbook entry
                        addrBookRecCounter++;
                        newAddressBookEntry2.put('typeReadOnly', true);
                        newAddressBookEntry2.put('EContactAddress', String.valueOf(shipLink));
                        newAddressBookEntry2.put('default', boolDefault);
                        newAddressBookEntry2.put('addressType', 'Shipping');
                        newAddressBookEntry2.put('accountId', accountId);
                        newAddressBookEntry2.put('ownerId', contactId);
                        newAddressBookEntry2.put('sfdcName', Null);
                        newAddressBookEntry2.put('sfid', addrBookRecCounter);
        
                        newAddressBook.add(newAddressBookEntry2);
                    }
    
    
                }//End Account a2 Loop
    //        }
            // END LOOP TRAVERSE HIERARCHY
            //ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'debug_ccServiceAddressBook:fetch:inputData: ', JSON.serialize(inputData));
    
            //Map<String,Object> outputData = super.fetch(inputData); //2020.09.23
    
            //ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'debug_ccServiceAddressBook:fetch:outputData: ', JSON.serialize(outputData));
            //MERGE IT!
            //ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'debug_ccServiceAddressBook:newAddressBook: ', JSON.serialize(newAddressBook));
            //ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'debug_ccServiceAddressbook:newAddressList: ', JSON.serialize(newAddressList));
            outputData.put(ccrz.ccAPIAddressBook.ADDRESSBOOKS, newAddressBook);  
            outputData.put('addressList', newAddressList);
        }//2020.09.23
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'debug_ccServiceAddressBook:fetch:outputData:final ', JSON.serialize(outputData));
        return outputData;
    }
}