public without sharing class DealRegRegistrationCtrl {
    
	@AuraEnabled
    public static String register(User u, String password) {
    	//Method variables
        Community_Detail__c settings = null;
        String exceptionEmail;
        
        //Check to see if the user is a valid reseller.
        //Throws Aura / Lightning exception if user is NOT a valid reseller.
        isReseller(u.Email);
        
        Id accountId = null;
        //Retrieve the community detail from the custom setting Community_Detail__c for this community.
        try {
        	settings = [select Id, Name, Default_Account_Id__c, Default_Profile_Id__c, Sub_Domain__c, Exception_Email__c from Community_Detail__c where Name = 'Ergotron Deal Registration Community'];	
        	u.ProfileId = settings.Default_Profile_Id__c;
            u.Username = u.Email.replace('@', '.') + '@' + settings.Sub_Domain__c;
            u.CommunityNickname = u.Email.left(40); 
            u.LocaleSidKey='en_US';
        	u.TimeZoneSidKey='America/Chicago';
        	u.Alias = u.Username.left(6);
            u.EmailEncodingKey='UTF-8';
            accountId = settings.Default_Account_Id__c;
            exceptionEmail = settings.Exception_Email__c;
        }
        catch(Exception oException) {
            throw new AuraHandledException(oException.getMessage());
        }

		//Determine if user already exists with this email address and whether or not they are active/inactive.
		try {
			User existing = [select Id, Email, IsActive from User where Email = :u.Email limit 1];
            throw new AuraHandledException('ALREADY_EXISTS');//('A registered user already exists with this email address.');
        }
		catch(QueryException oException) {
			//No matching user found
		}
        
        try {
			Contact c = [select Id, AccountId from Contact where Email = :u.Email limit 1];
            u.ContactId = c.Id;
			accountId = c.AccountId;		
        }catch(Exception e){
            Contact c = createContact(u, accountId);
            u.ContactId = c.Id;
            //No existing contact found, default to default account id.
        }
        
        createCommunityUser(JSON.serialize(u),accountId, password, exceptionEmail);
        
        return u.Email;
    }
    
    @AuraEnabled
    public static void reset(String username){
        //Check to see if the user is a valid reseller.
        //Throws Aura / Lightning exception if user is NOT a valid reseller.
        isReseller(username);
        try{
            
            Community_Detail__c settings = [select Sub_Domain__c from Community_Detail__c where Name = 'Ergotron Deal Registration Community'];
        	username = username.replace('@', '.') + '@' + settings.Sub_Domain__c;
        	User u = [Select Id From User Where Username = :username];
        	System.resetPassword(u.Id, true);
    	}catch(Exception ex){
        	throw new AuraHandledException(ex.getMessage());
    	}
    }
    
    @AuraEnabled
    public static String login(String username, String password, String startUrl){
        System.debug('DC: startUrl: ' + startUrl);
        
        //Check to see if the user is a valid reseller.
        //Throws Aura / Lightning exception if user is NOT a valid reseller.
        isReseller(username);
        
        Community_Detail__c settings = [select Sub_Domain__c from Community_Detail__c where Name = 'Ergotron Deal Registration Community'];
        username = username.replace('@', '.') + '@' + settings.Sub_Domain__c;
        
        try{
            //PageReference pageRef = Site.login(username, password, null);
            //03.14.2020 - Sophia Murphy (Demand Chain)
            //In order for the Bridge LMS to get users back to bridge, we need to maintain the startURL
            if(startUrl != '' && startUrl != null) {
                startUrl = EncodingUtil.urlDecode(startUrl,'UTF-8');
            }
            PageReference pageRef = Site.login(username, password, startUrl);
            if(!Test.isRunningTest()){
                Aura.Redirect(pageRef);
            }
        }catch(Exception ex){
            System.debug('ex: ' + ex.getMessage());
            System.debug('ex stack trace: ' + ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage());
        }
        

        return null;
    }
    
    @future
    private static void createCommunityUser(String userJson,String accountId,String password,String exceptionEmail){
        User u = (User)JSON.deserialize(userJson, User.class);
        try{
            
            insert u;
            System.setPassword(u.Id, password);
            //Site.login(u.Username, password, null);
        }catch(Exception e){
         	String sExceptionEmailBody = 'Error creating deal registration community user ' + u.FirstName + ' ' + u.LastName + ' from ' + u.CompanyName + '.';
            sExceptionEmailBody = sExceptionEmailBody + '<br/>Exception Message: ' + e.getMessage();
            
            //Construct the email and send it.
            Messaging.SingleEmailMessage oEmail = new Messaging.SingleEmailMessage();
        	oEmail.setToAddresses(new List<String>{exceptionEmail});
            oEmail.setSubject('Error Creating Community User');
            oEmail.setHTMLBody(sExceptionEmailBody);
            
            List<Messaging.SingleEmailMessage> listEmailMessages = new List<Messaging.SingleEmailMessage>();
            listEmailMessages.add(oEmail);
            
            if(!Test.isRunningTest()){
            	Messaging.sendEmail(listEmailMessages);
            }
        }
        
    }
    
    private static Contact createContact(User u, Id accountId){
        Contact c = new Contact(
        	FirstName = u.FirstName,
            LastName = u.LastName,
            MailingStreet = u.Street,
            MailingCity = u.City,
            MailingStateCode = u.StateCode,
            MailingPostalCode = u.PostalCode,
            MailingCountryCode = u.CountryCode,
            Title = u.Title,
            Email = u.Email,
            Phone = u.Phone,
            Fax = u.Fax,
            AccountId = accountId
        );
        insert c;
        return c;
    }
    
    private static boolean isReseller(String email){
        return true;
        /*
         * Commented out for Brandon on 1/9/2020 in  prep for communities go-live. because.... reasons?
         * 
        boolean result = false;
        List<String> emailParts = email.split('@');
        if(emailParts.size() == 2){
            String domain = emailParts.get(1);
            try{
                ///////////////////////////////////////////////////////////////////////////////////////
                //Email from Brandon on 12/4/2019
                //Here are the details on how to get the list of valid domains for creation and login:
                //Filters to use
                //Account Record Type = “Party”
                //Account.Type = “Reseller”
                //Account.Authorized_Reseller__c = “Yes”( this is a checkbox field)
                //URL field to use to derive the domain
                //Account.Website = Holds URL of account, this is the field you would base you formula field off of to isolate the domain.
                Account a = 
                    [Select 
                     	Id 
                     From 
                     	Account 
                     Where 
                     	Type='Reseller' 
                     	And RecordType.DeveloperName = 'Party' 
                     	And Authorized_Reseller__c = true
                     	And Domain__c = :domain Limit 1];
            	return true;
            }catch(QueryException qe){
            }
        }
        throw new AuraHandledException('We don’t list you as an authorized reseller—yet. Contact insidesales@ergotron.com or 888-743-1119 to register for the Ergotron Elite Circle authorized reseller program.');
    	*/
    }
}