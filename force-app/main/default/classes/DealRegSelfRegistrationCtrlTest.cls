@isTest
private class DealRegSelfRegistrationCtrlTest{
    static testmethod void testSelfRegNoContact() {
		//Create email for new user
		String sEmail = String.valueOf(math.random()).left(20) + '@ergotron.com';

		//Set up new Community_Detail__c record
		Community_Detail__c oCommunityDetail = Test_Environment_Utility.createInsertCommunityDetails();
        
        createResellerAccount();
        
        User u = new User(
            FirstName='TEST',
    		LastName='TEST',
    		Street='1181 TRAPP RD',
    		City='EAGAN',
    		StateCode='MN',
    		PostalCode='55121',
    		CountryCode='US',
    		Title='TEST',
    		Email=sEmail,
    		Phone='8888888888',
    		Fax='8888888888',
        	LanguageLocaleKey='en_US');
        
        
        Test.startTest();
    	String result = DealRegRegistrationCtrl.register(u, 'JustStand12345');
        DealRegRegistrationCtrl.login(sEmail, 'JustStand12345', null);
		Test.stopTest();
        System.assertNotEquals(null,result);
    }

    static testmethod void testSelfRegContactMatch() {
		//Create email for new user
		String sEmail = String.valueOf(math.random()).left(20) + '@ergotron.com';

		//Create account and contact for new user
		createResellerAccount();
		Account oAccount = Test_Environment_Utility.createInsertAccountUS();
		Contact oContact = Test_Environment_Utility.createInsertPartnerContact(oAccount, sEmail);

		//Set up new Community_Detail__c record
		Community_Detail__c oCommunityDetail = Test_Environment_Utility.createInsertCommunityDetails();

    	User u = new User(
            FirstName='TEST',
    		LastName='TEST',
    		Street='1181 TRAPP RD',
    		City='EAGAN',
    		StateCode='MN',
    		PostalCode='55121',
    		CountryCode='US',
    		Title='TEST',
    		Email=sEmail,
    		Phone='8888888888',
    		Fax='8888888888',
        	LanguageLocaleKey='en_US');
        
        System.assertEquals(1,[Select Id From Contact].size());
        Test.startTest();
    	String result = DealRegRegistrationCtrl.register(u, 'JustStand12345');
		Test.stopTest();
        System.assertEquals(1,[Select Id From Contact].size());
    }

    static testmethod void testSelfRegExceptions() { 
    	//Exception testing

		//Create email for new user
		String sEmail = String.valueOf(math.random()).left(20) + '@ergotron.com';
        
        createResellerAccount();

		//Create account and contact for new user
		Account oAccount = Test_Environment_Utility.createInsertAccountUS();
		Contact oContact = Test_Environment_Utility.createInsertPartnerContact(oAccount, sEmail);
        
        User u = new User(
            FirstName='TEST',
    		LastName='TEST',
    		Street='1181 TRAPP RD',
    		City='EAGAN',
    		StateCode='MN',
    		PostalCode='55121',
    		CountryCode='US',
    		Title='TEST',
    		Email=sEmail,
    		Phone='8888888888',
    		Fax='8888888888',
        	LanguageLocaleKey='en_US');
        
        boolean exc = false;
        Test.startTest();
        try{
    	    DealRegRegistrationCtrl.register(u, 'JustStand12345');
        }catch(Exception e){
            exc = true;
        }
        Test.stopTest();
        System.assert(exc);
    }
    
    static testmethod void testSelfRegExistingUsername() { 
    	String email = [Select Email From User Where IsActive = true Limit 1].Email;
    	
        //Create account and contact for new user
		Account oAccount = Test_Environment_Utility.createInsertAccountUS();
		Contact oContact = Test_Environment_Utility.createInsertPartnerContact(oAccount, email);
        
        createResellerAccount();
        
        //Set up new Community_Detail__c record
		Community_Detail__c oCommunityDetail = Test_Environment_Utility.createInsertCommunityDetails();
        
            
        User u = new User(
            FirstName='TEST',
    		LastName='TEST',
    		Street='1181 TRAPP RD',
    		City='EAGAN',
    		StateCode='MN',
    		PostalCode='55121',
    		CountryCode='US',
    		Title='TEST',
    		Email=email,
    		Phone='8888888888',
    		Fax='8888888888',
        	LanguageLocaleKey='en_US');
        
        boolean exc = false;
        Test.startTest();
        try{
            DealRegRegistrationCtrl.register(u, 'JustStand12345');
        }catch(Exception e){
            exc = true;
        }
        Test.stopTest();
        System.assert(exc);
    }
    
    static testmethod void testSelfRegUserException() { 
    	//Exception testing

		//Create email for new user
		String sEmail = String.valueOf(math.random()).left(20) + '@ergotron.com';

		//Create account and contact for new user
		createResellerAccount();
		Account oAccount = Test_Environment_Utility.createInsertAccountUS();
		Contact oContact = Test_Environment_Utility.createInsertPartnerContact(oAccount, sEmail);
        
        //Set up new Community_Detail__c record
		Community_Detail__c oCommunityDetail = Test_Environment_Utility.createInsertCommunityDetails();
        
        User u = new User(
            FirstName='TEST',
    		LastName='TEST',
    		Street='1181 TRAPP RD',
    		City='EAGAN',
    		StateCode='MN',
    		PostalCode='55121',
    		CountryCode='US',
    		Title='TEST',
    		Email=sEmail,
    		Phone='8888888888',
    		Fax='8888888888',
        	LanguageLocaleKey=null);
        
        Test.startTest();
        DealRegRegistrationCtrl.register(u, 'JustStand12345');
        //System.assertEquals(1, Limits.getEmailInvocations());
        Test.stopTest();
    }
    
    private static void createResellerAccount(){
        RecordType rt = [Select Id From RecordType Where DeveloperName = 'Party' and sObjectType='Account'];
        
        insert new Account(
        	RecordTypeId = rt.Id,
			Type = 'Reseller',
			Region__c = 'Americas',
			Sub_Region__c = 'US',
			Partner_Level__c = 'Authorized',
            Authorized_Reseller__c = true,
            Website = 'http://www.ergotron.com',
            Name='Ergotron The Reseller'
        );
    }
}