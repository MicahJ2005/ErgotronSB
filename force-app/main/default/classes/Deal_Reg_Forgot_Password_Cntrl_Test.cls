/*
    Controller class for the Deal_Reg_Forgot_Password_Cntrl.cls.

    MOD DATE        Who                     Description
    11/04/2014      Chris Noe               Initial Release 
*/

@IsTest
private class Deal_Reg_Forgot_Password_Cntrl_Test {

    static testmethod void testForgotPassword() {
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

        	//Instantiate forgot password controller
        	Deal_Reg_Forgot_Password_Cntrl oForgotPwdController = new Deal_Reg_Forgot_Password_Cntrl();
        	//Set email on controller
        	oForgotPwdController.sEmail = sEmail;
        	//Call forgot password method
        	PageReference oPageRef = oForgotPwdController.forgotPassword();
        Test.stopTest();
    }

    static testmethod void testForgotPasswordException() {
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
        	//Instantiate forgot password controller
        	Deal_Reg_Forgot_Password_Cntrl oForgotPwdController = new Deal_Reg_Forgot_Password_Cntrl();
        	//Set email on controller
        	oForgotPwdController.sEmail = sEmail;
        	//Call forgot password method
        	PageReference oPageRef = oForgotPwdController.forgotPassword();
        	//NULL due to no Community_Detail__c record
        	system.assertEquals(null,oPageRef);

    		//Set up new Community_Detail__c record
    		Community_Detail__c oCommunityDetail = Test_Environment_Utility.createInsertCommunityDetails();

        	//Set email to not match user created above
        	sEmail = 'test' + sEmail;
        	oForgotPwdController.sEmail = sEmail;
    		oPageRef = oForgotPwdController.forgotPassword();
        	//NULL due to no user found
        	system.assertEquals(null,oPageRef);
        Test.stopTest();
    }
}