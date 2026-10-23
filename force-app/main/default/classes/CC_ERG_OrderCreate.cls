/**
 * @description       : 
 * @author            : Glen Van Steeter
 * @group             : 
 * @last modified on  : 02.19.2020
 * @last modified by  : gvansteeter
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   02.19.2020   Glen Van Steeter  Initial Version
 * 1.1   09.21.2020   Glen Van Steeter  createOrUpdateUser modifications
 *                                      1) On initial user creation always create user as active regardless of Contact.Store_Member__c value, however
 *                                         suppress welcome email to customer if Contact.Store_Member__c is false.
 *                                      2) On update of existing user
 *                                         if Contact.Store_Member__c is false, even if User.IsActive is being updated to true, suppress
 *                                         reset password email else if Store_Member__c is true then send reset password email.
 *                  
 *                                      
**/
global class CC_ERG_OrderCreate {
        global String thePriceListsDropDown=null;
        global String theOrderTypeDropDown=null;
        global ID caseID;
        global ID contactId;
        global String OrderType=null;
        global String selectedPriceList;

        global String getthePriceListsDropDown() {
            return thePriceListsDropDown;
        }    
    
        global String gettheOrderTypeDropDown() {
            return theOrderTypeDropDown;
        }    
    
        global String getselectedPriceList() {
            return selectedPriceList;
        }
                       
        global void setselectedPriceList(String selectedPriceList) {
            this.selectedPriceList = selectedPriceList;
        } 
   
        global SelectOption[] PriceListsOptions{get;set;}    // magic, this defines the varialbe in the namespace
        
        global String forwardURL{get;set;}

        global List<Id> plIds{get;set;}
    
        // constructor
        global CC_ERG_OrderCreate()  {
            ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'debug_CC_ERG_OrderCreate: entering Constructor');
            this.OrderType='Warranty';
            
            this.PriceListsOptions = new SelectOption[]{}; // holds the pricelist ID and name for the apex selectlist       
                
            caseId = ApexPages.currentPage().getParameters().get('caseID');
            
            Case theCase = [select Contact.AccountId, Contact.Id, Account.ccrz__E_AccountGroup__c from Case where Id = :caseId];
            contactId = theCase.Contact.Id;

            List<ccrz__E_AccountGroupPriceList__c> accountgrouppricelist = [select ccrz__Pricelist__c, ccrz__Pricelist__r.Name
                                                                              from ccrz__E_AccountGroupPriceList__c 
                                                                             where ccrz__AccountGroup__c = :theCase.Account.ccrz__E_AccountGroup__c];

            // populates the drop down list, need name in here, not just the id
            // notice there are 2 c's in the SelectOption 
            // SelectOption(value,label,isDisabled)
            // I just used the id

            thePriceListsDropDown = '<select id="selectedpricelist">';
            
            Boolean  firsttime = true;
            for(ccrz__E_AccountGroupPriceList__c i: accountgrouppricelist) {
                
                String pid = String.valueOf(i.ccrz__Pricelist__c);
                String pname = i.ccrz__Pricelist__r.Name;
                
                if( firsttime)
                {
                    firsttime = false;
                    selectedPriceList = pid; // use the first one 
                    thePriceListsDropDown += '<option value="'+pid+'" selected>'+pname+'</option>';                     
                }
                else
                {
                    thePriceListsDropDown += '<option value="'+pid+'">'+pname+'</option>';                     
                }
                
                PriceListsOptions.add(new SelectOption(pid,pname));
                
            }

            thePriceListsDropDown += ' </select>';
            List<Oracle_Order_Type__c> oraOrdType = [SELECT Name, Order_Type_id__c, Salesforce_Order_Type__c, Domestic__c  FROM Oracle_Order_Type__c WHERE Salesforce_Order_Type__c = true AND Domestic__c = true  Order By Name ];
            theOrderTypeDropDown = '<select id="ordertype">';
            firsttime = true;

            for(Oracle_Order_Type__c i: oraOrdType) {
                String pid = String.valueOf(i.Order_Type_id__c);
                String pname = i.Name;
                if( firsttime)
                {
                    firsttime = false;
                    theOrderTypeDropDown += '<option value="'+pid+'" selected>'+pname+'</option>';                     
                }
                else
                {
                    theOrderTypeDropDown += '<option value="'+pid+'">'+pname+'</option>';                     
                }
            }
            theOrderTypeDropDown += ' </select>';
    }// end of constructor 
    
    global List<SelectOption> getPriceListsOptions() {
        return this.PriceListsOptions;
    }    
 
    global String getOrderType() {
        return this.OrderType;
    }
                    
    global void setOrderType(String OrderType) { this.OrderType = OrderType; }    
    
    // getter setters for ThiscontactId 
    global ID ThiscontactId{
        get{
            return this.contactId;
        }
        set;
    
    }       

     // getter setters for ThiscontactId
     global ID ThisCaseID{
         get{
                return this.caseId;
         }
         set;
    }  
    
    private static String generateAlias(String firstName, String lastName) {
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'CC_ERG_OrderCreate#generateAlias');
        Integer lastNameLength = lastName.length();
        If(lastNameLength>4){
            lastNameLength=4;
        }
        String theAlias = firstName.substring(0, 1) + lastName.substring(0,lastNameLength);
        Integer aliasCount = [select count() from user where alias = :theAlias];
        if(aliasCount>0){
            theAlias+= String.valueOf(aliasCount); 
        }
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:X', 'CC_ERG_OrderCreate#generateAlias');
        return theAlias;
    }

    private static String generateCommunityNickname(String username) {
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'CC_ERG_OrderCreate#generateCommunityNickname');
        final Integer maxNicknameLength = 40;
        final String timestamp = String.valueOf(System.currentTimeMillis()/1000);
        String communityNickname = username.left(maxNicknameLength - timestamp.length()) + timestamp;
        communityNickname = communityNickname.replace(' ', '_');
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'debug_CC_ERG_OrderCreate:generateCommunityNickname: Exit method.');
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:X', 'CC_ERG_OrderCreate#generateCommunityNickname');
        return communityNickname;
    }   
    // gvansteeter added 2020.04.17: Guarantee (nearly) unique User.UserName
    private static String genUniqueUserName(String userName){
        string s2 = userName.substringBefore('@');
        string s3 = userName.substringAfter('@');
        string returnString;
        final integer stringLength = 5;
        String randomValue = String.valueOf(Math.Round(Math.Random() * ((Math.pow(10,stringLength) - 1)-Math.pow(10,stringLength -1)) + Math.pow(10,stringLength -1)));
        returnString = s2+randomValue+'@'+s3;
        return returnString;
    }
    
    
    global void createOrUpdateUser(){
        // Need the B2B Storefront profileId to check existing user and/or create a new user!
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'CC_ERG_OrderCreate#createOrUpdateUser');
        
        Profile b2bProfile = [select Id, Name from Profile where Name = 'B2B Commerce']; // 2020.04.15
        User refetchUser;
        PermissionSet ps = [Select Name, Id From PermissionSet where Name = 'DRB2B_Permission_Set'];
        PermissionSetAssignment newPSA = new PermissionSetAssignment(); // in case the user doesn't have the DRB2B_Permission_Set, we will use this to add it.
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'debug_CC_ERG_OrderCreate:createOrUpdateUser: Entered method. contactID='+contactId);
        User[] theUser = [SELECT id, Name, isActive, profileId
                            FROM User
                           WHERE contactId = :contactId
                           LIMIT 1];

        Contact theContact = [SELECT email, Name, firstName, lastName, phone, AccountId, Store_Member__c
                              FROM Contact
                              WHERE Id = :contactId];       

        if(theUser.size()> 0) { // Contact has a user record.
            refetchUser = theUser[0];
            ccrz.cc_CallContext.currUserId = refetchUser.Id;
            if(!refetchUser.isActive) { 
                refetchUser.isActive = TRUE;
                update refetchUser;
                //2020.09.21 gvansteeter re-enabled this code
                if(theContact.Store_Member__c){ // only if the contact is a store member...
                    System.resetPassword(refetchUser.Id, true); //...will we force a system password email 
                }// 2020.09.21 end changes
            }
            // Make sure the user has the B2B Storefront profile! If not, add it!
            /*JLL 7/13/20 
                Support case - we shouldn't be switching profiles if user already exists. they could be partner.
                It throws an exception anyway, so illegal operation anyway.  Only set it if its null.
            */
            if(refetchUser.ProfileId == null) {
                refetchUser.ProfileId = b2bProfile.Id;
                update refetchUser;
            }
            // make sure the user has the DRB2B_Permission_Set! If not, add it.
            PermissionSetAssignment[] psaDRB2B = [SELECT PermissionSetId 
                                                    FROM PermissionSetAssignment
                                                   WHERE AssigneeId = :refetchUser.Id
                                                     AND PermissionSetId = :ps.Id];
            if(psaDRB2B.size()<1){
                newPSA.AssigneeId = refetchUser.Id;
                newPSA.PermissionSetId = ps.Id;
                insert newPSA;                
            }
        // no user found. Create one.
        } else {
            ccrz__E_Configuration__c custom_configs_template;
            if(!Test.isRunningTest()) custom_configs_template =[SELECT Name, ccrz__ConfigurationMeta__r.name, ccrz__TextValue__c FROM ccrz__E_Configuration__c where ccrz__ConfigurationMeta__r.name = 'UserName Suffix'];
            else custom_configs_template = new ccrz__E_Configuration__c(ccrz__TextValue__c = 'foo');
            String userNameSuffix =  custom_configs_template.ccrz__TextValue__c;
            // build the new user record
            User newUser = new User(
                Email = theContact.email,
                FirstName = theContact.firstName,
                LastName = theContact.lastName,
                Phone = theContact.phone,
                LocaleSidKey = 'en_US',
                ccrz__CC_CurrencyCode__c = 'USD',
                CommunityNickName  = generateCommunityNickname(theContact.email),
                ContactId = theContact.Id,
                ProfileId = b2bProfile.Id, 
                LanguageLocaleKey = 'en_US',
                TimeZoneSidKey = 'America/Los_Angeles', 
                Alias = generateAlias(theContact.firstName, theContact.lastName),
                EmailEncodingKey = 'ISO-8859-1', 
                Username = genUniqueUserName(theContact.Email+userNameSuffix) //2020.04.17: Call new method to generate unique User.UserName
            );
        
            if(!Test.isRunningTest())
                insert newUser;
            else{
               User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
               system.runAs(thisUser){
                insert newUser;
               }
            }
        
            if(String.isNotBlank(newUser.Id)){
                //Set set the user Context NOW!
                ccrz.cc_CallContext.currUserId = newUser.Id;
                ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'debug_CC_ERG_OrderCreate:createOrUpdateUser: Created user ' + newUser.Id);
                // 2020.09.21 gvansteeter re-enabled this code
                try{
                    if(theContact.Store_Member__c){ // only if a contact is a store member ...
                        System.resetPassword(newUser.Id, true); // ... send the resetPassword email.
                    }
                }catch(Exception e){
                    ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'CC_ERG_OrderCreate.createOrUpdateUser: '
                                  +'Failed while trying to create system reset password email for '
                                  +theContact.Name+'; ContactId='+theContact.Id);
                } // 2020.09.21 end gvansteeter modified code

                //assign the Digital river permission(DRB2B_Permission_Set) set.
                newPSA.AssigneeId = newUser.Id;
                newPSA.PermissionSetId = ps.Id;
                if(!Test.isRunningTest())
                    insert newPSA;
                else{
                User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
                system.runAs(thisUser){
                        insert newPSA;
                    }
                }
            } else {
                ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'debug_CC_ERG_OrderCreate:createOrUpdateUser: Create user did not work!');            
            }
        }
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:X', 'CC_ERG_OrderCreate#createOrUpdateUser');
    }// end createOrUpdateUser
    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult manageCarts(ccrz.cc_RemoteActionContext ctx, string caseId, string priceListId, string orderType) {
        
        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);
        result.success = true;
        Boolean wasSuccessful = true;
        boolean hasActiveCart = false;
        
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'debug_CC_ERG_OrderCreate:manageCarts: enter method: caseId='+caseId+'; priceListId='+priceListId);
        // get the contact, account and cartId from the case.
        Case theCase = [SELECT ContactId, AccountId, CC_CartId__c
                          FROM Case 
                         WHERE Id = :caseId];

        // now get the user Id for the contact.
        User theUser = new User(); 
        theUser = [SELECT Id FROM User WHERE ContactId = :theCase.ContactId];

        // SET THE CONTEXT
        ccrz.cc_CallContext.currAccountId = theCase.AccountId;
        ccrz.cc_CallContext.currUserId = theUser.Id;//TODO: Do we need this call here? We should have set the context in createOrUpdateUsers
        ccrz.cc_CallContext.currContact = [SELECT Id FROM Contact WHERE Id = :theCase.ContactId LIMIT 1]; 
        
        // Now, get all of the open carts for this user and contact regardless 
        // of active status.
        List<ccrz__E_Cart__c> listCartsToUpdate = new List<ccrz__E_Cart__c>();
        List<ccrz__E_Cart__c> openCarts = [SELECT Id, ccrz__ActiveCart__c
                                             FROM ccrz__E_Cart__c
                                            WHERE ccrz__CartStatus__c = 'Open'
                                              AND ccrz__Account__c = :theCase.AccountId
                                              AND ccrz__User__c = :theUser.id];

        // POSSIBLE STATES:
        // (0)No records found. A new cart will be created.
        // (1)Active = True, CartId matches Case, do nothing, set hasActiveCart true
        // (2)Active = False, CartId matches Case, update to active, set hasActiveCart true
        // (3)Active = True, CartId doesn't match Case, update to inactive.
        // (4)Active = False, CartId doesn't match Case, ignore this condition, we don't care.

        if(openCarts.size()> 0){
            for(ccrz__E_Cart__c currCart : openCarts){
                ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'debug_CC_ERG_OrderCreate:manageCarts: LOOP - CartId='+currCart.Id+'; ActiveCart='+currCart.ccrz__ActiveCart__c);
                if(currCart.Id == theCase.CC_CartId__c){
                    if(currCart.ccrz__ActiveCart__c){ // (1) Open, Active cart for this Case
                        hasActiveCart = true;
                        ccrz.ccLog.log(System.LoggingLevel.Debug, 'debug_CC_ERG_OrderCreate:manageCarts: Active cart found: '+ currCart.Id);
                        ccrz.cc_CallContext.currCartId = currCart.Id; // Add this cartId to the context
                    } else { //(2)  Open, Inactive cart for this case
                        currCart.ccrz__ActiveCart__c = true;
                        listCartsToUpdate.add(currCart);
                        hasActiveCart = true;
                        ccrz.ccLog.log(System.LoggingLevel.Debug, 'debug_cc_erg_ordercreate:manageCarts: Activated cart : '+ currCart.Id);
                        ccrz.cc_CallContext.currCartId = currCart.Id; // Add this cartId to the context
                    }
                } else { 
                    if(currCart.ccrz__ActiveCart__c){ //(3) Open, Active cart for another Case
                        currCart.ccrz__ActiveCart__c = false;
                        listCartsToUpdate.add(currCart);
                        ccrz.ccLog.log(System.LoggingLevel.Debug, 'debug_CC_ERG_OrderCreate:manageCarts: Deactivated cart, not the case cart: '+ currCart.Id);
                    }
                }
            }
            update listCartsToUpdate;
        }

        // At this point, if we still don't have an active cart, create one.
        if(!hasActiveCart) {
            ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'debug_CC_ERG_OrderCreate: manageCarts: Need to create a new cart!');
            Savepoint sp = Database.setSavepoint();
            String theNewCartId = null;
            try{
                Map<String,Object> createResults = ccrz.ccApiCart.addTo(new Map<String,Object>{
                    ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION 
                });
              
                wasSuccessful = (Boolean)createResults.get(ccrz.ccApi.SUCCESS);
              
                theNewCartId = (String)createResults.get(ccrz.ccApiCart.CART_ID);
                theCase.CC_CartId__c = theNewCartId;
                update theCase;
                
                if(String.isBlank(theNewCartId)){
                    wasSuccessful = false;
                    
                }else{
                    // We have the new cart ID.  Add the priceList to it.
                    ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'debug_CC_ERG_OrderCreate: manageCarts: Cart '+theNewCartId+' successfully created.');
                    ccrz__E_Cart__c newCartRec = [SELECT Id, priceListOverride__c, Ergotron_Order_Type__c
                                                    FROM ccrz__E_Cart__c
                                                   WHERE Id = :theNewCartId];
                    newCartRec.pricelistOverride__c = priceListId;
                    newCartRec.Ergotron_Order_Type__c = orderType;
                    update newCartRec;
                    ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'debug_CC_ERG_OrderCreate: manageCarts: Successfully added the pricelist and Oracle order type to the cart.');
                    ccrz.cc_CallContext.currCartId = theNewCartId; // Add this cartId to the context

                }
            }catch(Exception e){
                result.data = e.getMessage();
                result.success = false;
                ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'debug_CC_ERG_OrderCreate#manageCarts: Hit Exception!');
            }
              
            if(!wasSuccessful){
                // DEBUG
                ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'debug_CC_ERG_OrderCreate#manageCarts: was not successful, rolling back new cart.');

                Database.rollback(sp);
            }
            
        }
        result.success = wasSuccessful;
        result.data = ccrz.cc_CallContext.currCartId; // this let's the front end know that we had successful creation or selection of the cart.
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'debug_CC_ERG_OrderCreate#manageCarts: Was successful!');
                               
        return result;
    }// end manageCarts
    
     global String getGoToThisPLPURL()
     {

        PageReference pageRef = System.Page.ccrz__ProductList; // this puts a ? on end of string
        createOrUpdateUser(); 
        User u = new User();        
        String theUserId = ccrz.cc_CallContext.currUserId;
         ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'debug_CC_ERG_OrderCreate: getGoToThisPLPURL: found userId '+theUserId+' from context call.');
         if(String.isBlank(theUserId)) {//DO THIS ONLY IF USERID NOT IN CONTEXT! WE ARE TRYING TO LIMIT THE NUMBER OF DML STATEMENTS BEING EXECUTED IN THIS CONTROLLER!
             u = [select id, name from user where contactId = :contactId and isActive=TRUE limit 1];
             theUserId = u.Id;
             ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'debug_CC_ERG_OrderCreate: getGoToThisPLPURL: found userId '+theUserId+' from query. USERID not set in CONTEXT!');
         }
        
        ccrz__E_Category__c allProdCatId = [select Id from ccrz__E_Category__c where Name = 'All Products'];
        
        ID categoryID = allProdCatId.Id;
        
        // append the static parameters to the url 
        pageRef.getParameters().put('CategoryID', allProdCatId.Id); 
        pageRef.getParameters().put('store', 'DefaultStore'); //hard code for now, but this could be a custom setting.
        pageRef.getParameters().put('CaseID', caseId); // this should come from the current URL param
        pageRef.getParameters().put('portalUser', theUserId);

        String baseurl = pageRef.getURL();  // contains CategoryID, store, CaseID and portalUser, the other two would not update, so I did in VFP

        return baseurl;         
     }
}