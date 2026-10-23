/*
    Controller class for the Deal_Reg_Self_Reg_Cntrl.cls.

    MOD DATE        Who                     Description
    11/04/2014      Chris Noe               Initial Release 
*/

@IsTest
private class Deal_Reg_Self_Reg_Cntrl_Test {

    static testmethod void testSelfRegNoContact() {
		//Create email for new user
		String sEmail = String.valueOf(math.random()).left(20) + '@ergotron.com';

		//Set up new Community_Detail__c record
		Community_Detail__c oCommunityDetail = Test_Environment_Utility.createInsertCommunityDetails();

    	//Instantiate the controller
    	Deal_Reg_Self_Reg_Cntrl oController = new Deal_Reg_Self_Reg_Cntrl();

    	//Set new user values
    	oController.oNewUser.FirstName='TEST';
    	oController.oNewUser.LastName='TEST';
    	oController.oNewUser.Street='1181 TRAPP RD';
    	oController.oNewUser.City='EAGAN';
    	oController.oNewUser.StateCode='MN';
    	oController.oNewUser.PostalCode='55121';
    	oController.oNewUser.CountryCode='US';
    	oController.oNewUser.Title='TEST';
    	oController.oNewUser.Email=sEmail;
    	oController.oNewUser.Phone='8888888888';
    	oController.oNewUser.Fax='8888888888';

    	//Set controller variables
    	oController.sLanguage='en_US';
    	oController.sPassword='JustStand!';
    	oController.sConfirmPassword='JustStand!';

    	PageReference oPageRef = oController.registerUser();

    	system.assertEquals('/dealregselfregconfirm',oPageRef.getUrl());
    }

    static testmethod void testSelfRegContactMatch() {
		//Create email for new user
		String sEmail = String.valueOf(math.random()).left(20) + '@ergotron.com';

		//Create account and contact for new user
		Account oAccount = Test_Environment_Utility.createInsertAccountUS();
		Contact oContact = Test_Environment_Utility.createInsertPartnerContact(oAccount, sEmail);

		//Set up new Community_Detail__c record
		Community_Detail__c oCommunityDetail = Test_Environment_Utility.createInsertCommunityDetails();

    	//Instantiate the controller
    	Deal_Reg_Self_Reg_Cntrl oController = new Deal_Reg_Self_Reg_Cntrl();

    	//Set new user values
    	oController.oNewUser.FirstName='TEST';
    	oController.oNewUser.LastName='TEST';
    	oController.oNewUser.Street='1181 TRAPP RD';
    	oController.oNewUser.City='EAGAN';
    	oController.oNewUser.StateCode='MN';
    	oController.oNewUser.PostalCode='55121';
    	oController.oNewUser.CountryCode='US';
    	oController.oNewUser.Title='TEST';
    	oController.oNewUser.Email=sEmail;
    	oController.oNewUser.Phone='8888888888';
    	oController.oNewUser.Fax='8888888888';

    	//Set controller variables
    	oController.sLanguage='en_US';
    	oController.sPassword='JustStand!';
    	oController.sConfirmPassword='JustStand!';

    	PageReference oPageRef = oController.registerUser();

    	system.assertEquals('/dealregselfregconfirm',oPageRef.getUrl());
    } 

    static testmethod void testSelfRegExceptions() { 
    	//Exception testing

		//Create email for new user
		String sEmail = String.valueOf(math.random()).left(20) + '@ergotron.com';

		//Create account and contact for new user
		Account oAccount = Test_Environment_Utility.createInsertAccountUS();
		Contact oContact = Test_Environment_Utility.createInsertPartnerContact(oAccount, sEmail);

    	//Instantiate the controller
    	Deal_Reg_Self_Reg_Cntrl oController = new Deal_Reg_Self_Reg_Cntrl();

    	//Set new user values
    	oController.oNewUser.FirstName='TEST';
    	oController.oNewUser.LastName='TEST';
    	oController.oNewUser.Street='1181 TRAPP RD';
    	oController.oNewUser.City='EAGAN';
    	oController.oNewUser.StateCode='MN';
    	oController.oNewUser.PostalCode='55121';
    	oController.oNewUser.CountryCode='US';
    	oController.oNewUser.Title='TEST';
    	oController.oNewUser.Email=sEmail;
    	oController.oNewUser.Phone='8888888888';
    	oController.oNewUser.Fax='8888888888';

    	//Set controller variables
    	oController.sLanguage='en_US';
    	oController.sPassword='JustStand!';
    	oController.sConfirmPassword='JustStand!Just';

    	PageReference oPageRef = oController.registerUser();
    	//Passwords do not match
    	system.assertEquals(null,oPageRef);

    	oController.sConfirmPassword='JustStand!';
    	oPageRef = oController.registerUser();
    	//No Community_Detail__c record
    	system.assertEquals(null,oPageRef);

		//Cancel logic
		system.assertEquals('/dealreglogin',oController.cancelRegistration().getUrl());
    }  
}