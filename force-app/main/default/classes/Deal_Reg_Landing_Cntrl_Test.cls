/*
    Controller class for the Deal_Reg_Landing_Cntrl.cls.

    MOD DATE        Who                     Description
    11/04/2014      Chris Noe               Initial Release 
*/

@IsTest(SeeAllData=true) 
private class Deal_Reg_Landing_Cntrl_Test {

    static testmethod void testLandingControllerLoggedInUser() {
		// Instantiate a new controller with all parameters in the page
		Deal_Reg_Landing_Cntrl oController = new Deal_Reg_Landing_Cntrl();

        PageReference oPageRef = oController.forwardToCustomAuthPage();

        system.assertEquals('/home/home.jsp',oPageRef.getUrl());
    }

    static testmethod void testLandingControllerGuest() {
		//Retrieve a "Guest" UserType

		try{
			User oUser = [select Id from User where UserType='Guest'];

			system.runAs(oUser) {
				// Instantiate a new controller with all parameters in the page
				Deal_Reg_Landing_Cntrl oController = new Deal_Reg_Landing_Cntrl();

		        PageReference oPageRef = oController.forwardToCustomAuthPage();

		        system.assertEquals('/dealreglogin',oPageRef.getUrl());
			}
		}

		catch (Exception oException) {
			system.debug('Error Retrieving Guest UserType: ' +oException);
		}
    }
}