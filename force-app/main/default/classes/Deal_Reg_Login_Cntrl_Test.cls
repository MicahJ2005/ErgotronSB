/*
    Controller class for the Deal_Reg_Login_Cntrl.cls.

    MOD DATE        Who                     Description
    11/04/2014      Chris Noe               Initial Release 
*/

@IsTest
private class Deal_Reg_Login_Cntrl_Test {

    static testmethod void testLogin() {
		//Create new user with random email addresss.
		String sEmail = String.valueOf(math.random()).left(20) + '@ergotron.com';
		String sUserName = sEmail.replace('@', '.') + '@dealreg.ergotron.com';
		String sPassword = 'password1234';

		//Create account and contact for new user
		Account oAccount = Test_Environment_Utility.createInsertAccountUS();
		Contact oContact = Test_Environment_Utility.createInsertPartnerContact(oAccount, sEmail);

		System.runAs(new User(Id = UserInfo.getUserId())){
			User oUser = Test_Environment_Utility.createInsertCommunityUser(sUserName, sEmail, oContact.Id);

			//Set password for new user
			system.setPassword(oUser.Id, sPassword);
		}

		Test.startTest();
			//Set up new Community_Detail__c record
			Community_Detail__c oCommunityDetail = Test_Environment_Utility.createInsertCommunityDetails();
			
			// Instantiate a new controller with all parameters in the page
			Deal_Reg_Login_Cntrl oController = new Deal_Reg_Login_Cntrl();

			//Set controller values
			oController.sEmail = sEmail;
			oController.sPassword = sPassword;

	        PageReference oPageRef = oController.login();
    	Test.stopTest();
    }

    static testmethod void testLoginException() {
		//Create new user with random email addresss.
		String sEmail = String.valueOf(math.random()).left(20) + '@ergotron.com';
		String sUserName = sEmail.replace('@', '.') + '@dealreg.ergotron.com';
		String sPassword = 'password1234';

		//Create account and contact for new user
		Account oAccount = Test_Environment_Utility.createInsertAccountUS();
		Contact oContact = Test_Environment_Utility.createInsertPartnerContact(oAccount, sEmail);

		System.runAs(new User(Id = UserInfo.getUserId())){
			User oUser = Test_Environment_Utility.createInsertCommunityUser(sUserName, sEmail, oContact.Id);

			//Set password for new user
			system.setPassword(oUser.Id, sPassword);
		}
		
		Test.startTest();		
			// Instantiate a new controller with all parameters in the page
			Deal_Reg_Login_Cntrl oController = new Deal_Reg_Login_Cntrl();

			//Set controller values
			oController.sEmail = sEmail;
			oController.sPassword = sPassword;

	        PageReference oPageRef = oController.login();

	        //Error will be returned because we did not have a Community_Detail__c record created.
	        system.assertEquals(null,oPageRef);

			//Set up new Community_Detail__c record
			Community_Detail__c oCommunityDetail = Test_Environment_Utility.createInsertCommunityDetails();


			// Instantiate a new controller with all parameters in the page
			oController = new Deal_Reg_Login_Cntrl();

			//Set controller values - set invalid password to get login error
			oController.sEmail = sEmail;
			oController.sPassword = sPassword + 'wrongpwd';

	        oPageRef = oController.login();

	        system.assertEquals(null,oPageRef);
		Test.stopTest();
    }
}