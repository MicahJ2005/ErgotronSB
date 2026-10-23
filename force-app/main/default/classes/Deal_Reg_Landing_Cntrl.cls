/*
    Controller class for the DealRegLanding.page.

    MOD DATE        Who                     Description
    11/04/2014      Chris Noe               Initial Release 
*/

public with sharing class Deal_Reg_Landing_Cntrl {
	public Deal_Reg_Landing_Cntrl() {}

	// Code we will invoke on page load.
    public PageReference forwardToCustomAuthPage() {
        if(UserInfo.getUserType() == 'Guest'){
            return new PageReference('/dealreglogin');
        }
        else{
            return new PageReference('/home/home.jsp');
        }
    }	
}