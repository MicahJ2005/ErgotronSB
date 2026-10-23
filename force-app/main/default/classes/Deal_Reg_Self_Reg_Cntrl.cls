/*
    Controller class for the DealRegSelfReg.page.

    MOD DATE        Who                     Description
    11/04/2014      Chris Noe               Initial Release 
*/

public without sharing class Deal_Reg_Self_Reg_Cntrl {
    public User oNewUser {get; set;}
    public String sPassword {get; set {sPassword = value == null ? value : value.trim(); } }
    public String sConfirmPassword {get; set { sConfirmPassword = value == null ? value : value.trim(); } }	
    public String sLanguage {get; set;}

	public Deal_Reg_Self_Reg_Cntrl() {
		oNewUser = new User();
	}

    private boolean isValidPassword() {
        return sPassword == sConfirmPassword;
    }

    public PageReference registerUser() {
    	//Method variables
        String sAccountId = '';
        String sContactId = '';
        Contact oContact = new Contact();
        Community_Detail__c oCommunityDetail = new Community_Detail__c();
        String sFormattedUserName;
        User oExistingUser = new User();
        Contact oNewContact = new Contact();

		//Verify password and confirm password match
        if (!isValidPassword()) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.site.passwords_dont_match);
            ApexPages.addMessage(msg);
            return null;
        }    

        //Retrieve the community detail from the custom setting Community_Detail__c for this community.
        try {
        	oCommunityDetail = [select Id, Name, Default_Account_Id__c, Default_Profile_Id__c, Sub_Domain__c, Exception_Email__c from Community_Detail__c where Name = 'Ergotron Deal Registration Community'];	
        }
        catch(Exception oException) {
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
        	return null;
        }

        //Format the email entered in the login form with the sub-domain value retrieved from the custom setting above to create a unique username.
        sFormattedUserName = oNewUser.Email.replace('@', '.');
        sFormattedUserName = sFormattedUserName + '@' + oCommunityDetail.Sub_Domain__c;

		//Determine if user already exists with this email address and whether or not they are active/inactive.
		try {
			oExistingUser = [select Id, Email, IsActive from User where Email = :oNewUser.Email limit 1];
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'A registered user already exists with this email address.'));
			return null;
		}
		catch(Exception oException) {
			//No matching user found
		}		

		//Determine if contact already exists with this email address. If the contact already exists in the system, use the existing contact id and account
        //id when setting up the new community user. If the contact does not exist, create the contact under the default account id and use the new contact
        //id and default account id when setting up the new community user.
		try {
			oContact = [select Id, AccountId from Contact where Email = :oNewUser.Email limit 1];
			sContactId = oContact.Id;
			sAccountId = oContact.AccountId;
		}
		catch(Exception oException) {
			//No matching contact found.  Create the contact under the default community account.
            oNewContact.FirstName = oNewUser.FirstName;
            oNewContact.LastName = oNewUser.LastName;
            oNewContact.MailingStreet = oNewUser.Street;
            oNewContact.MailingCity = oNewUser.City;
            oNewContact.MailingStateCode = oNewUser.StateCode;
            oNewContact.MailingPostalCode = oNewUser.PostalCode;
            oNewContact.MailingCountryCode = oNewUser.CountryCode;
            oNewContact.Title = oNewUser.Title;
            oNewContact.Email = oNewUser.Email;
            oNewContact.Phone = oNewUser.Phone;
            oNewContact.Fax = oNewUser.Fax;
            oNewContact.AccountId = oCommunityDetail.Default_Account_Id__c;

            insert oNewContact;

            //Retrieve Id for the newly created contact which will be used to set up the new community user.
            sContactId = oNewContact.Id;
            //Set the sAccountId to the default account id since the contact was not found under an existing account
            sAccountId = oCommunityDetail.Default_Account_Id__c;
		}

        //Call @future method to create community user using the values set by the user on the self registration page.  @future method is required because DML cannot be
        //performed on a setup (User) and non-setup (Contact) object within the same context.  Under normal circumstances, the Site.createPortalUser method would work here
        //but the Contact and User objects have triggers associated with them that perform DML which causes an error when trying to use the createPortalUser method.
        createPortalUser(sAccountId,sContactId,oNewUser.CompanyName,oNewUser.Street,oNewUser.City,oNewUser.StateCode,oNewUser.CountryCode,oNewUser.FirstName,oNewUser.LastName,
                            oNewUser.Title,oNewUser.Email,oNewUser.Phone,oNewUser.Fax,sFormattedUserName,sPassword,oCommunityDetail.Default_Profile_Id__c,sLanguage,oNewUser.TimeZoneSidKey,
                            oNewUser.PostalCode, oCommunityDetail.Exception_Email__c,oNewUser.CurrencyIsoCode);

        //Return user to self registration confirmation page
        return new PageReference('/dealregselfregconfirm');
    }

    public PageReference cancelRegistration() {
    	return new PageReference('/dealreglogin');
    }

    @future
    static void createPortalUser(String sAccountId, String sContactId, String sComapnayName, String sStreet, String sCity, String sState, String sCountry, String sFirstName, String sLastName, 
                                    String sTitle, String sEmail, String sPhone, String sFax, String sUsername, String sPassword, String sProfileId, String sLanguage, String sTimeZone, 
                                    String sPostalCode, String sExceptionEmail, String sCurrency) {
        //Creates a community user based on the contact and user details passed into the method.
        //Method variables
        String sUserId;
        User oNewRegisteredUser = new User();
        List<String> listToAddresses = new List<String>();
        String sExceptionEmailSubject;
        String sExceptionEmailBody;
        Messaging.SingleEmailMessage oEmail = new Messaging.SingleEmailMessage();
        List<Messaging.SingleEmailMessage> listEmailMessages = new List<Messaging.SingleEmailMessage>();

        //Create new community user using the values passed into the method
        oNewRegisteredUser.ContactId=sContactId;
        oNewRegisteredUser.CompanyName=sComapnayName;
        oNewRegisteredUser.Street=sStreet;
        oNewRegisteredUser.City=sCity;
        oNewRegisteredUser.StateCode=sState;
        oNewRegisteredUser.CountryCode=sCountry;
        oNewRegisteredUser.PostalCode=sPostalCode;
        oNewRegisteredUser.FirstName=sFirstName;
        oNewRegisteredUser.LastName=sLastName;
        oNewRegisteredUser.Title=sTitle;
        oNewRegisteredUser.Email=sEmail;
        oNewRegisteredUser.Phone=sPhone;
        oNewRegisteredUser.Fax=sFax;
        oNewRegisteredUser.Username = sUsername;
        oNewRegisteredUser.CommunityNickname = sEmail.left(40);   //40 character limit
        oNewRegisteredUser.ProfileId=sProfileId;
        oNewRegisteredUser.EmailEncodingKey='UTF-8';
        oNewRegisteredUser.LanguageLocaleKey=sLanguage;
        oNewRegisteredUser.LocaleSidKey='en_US';
        oNewRegisteredUser.TimeZoneSidKey='America/Chicago';
        oNewRegisteredUser.Alias=sUsername.left(6);
        oNewRegisteredUser.UserPreferencesHideS1BrowserUI=true;
        oNewRegisteredUser.DefaultCurrencyIsoCode=sCurrency;

        try{
            //Insert new user record.
            insert oNewRegisteredUser;

            //Set password for new user based on value passed into the method.
            system.setPassword(oNewRegisteredUser.Id, sPassword);

        }
        catch(Exception oException) {
            //Error creating community user.  Send exception email.
            sExceptionEmailSubject='Error Creating Community User';
            sExceptionEmailBody = 'Error creating deal registration community user ' + sFirstName + ' ' + sLastName + ' from ' + sComapnayName + '.';
            sExceptionEmailBody = sExceptionEmailBody + '<br/>' + 'Exception Message: ' + oException.getMessage();
            //Add exception email address passed to this method
            listToAddresses.add(sExceptionEmail);
            
            //Construct the email and send it.
            oEmail.setToAddresses(listToAddresses);
            oEmail.setSubject(sExceptionEmailSubject);
            oEmail.setHTMLBody(sExceptionEmailBody);
            listEmailMessages.add(oEmail);
            Messaging.sendEmail(listEmailMessages);
        }
    }   
}