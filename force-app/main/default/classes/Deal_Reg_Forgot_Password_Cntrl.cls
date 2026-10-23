/*
    Controller class for the DealRegForgotPassword.page.

    MOD DATE        Who                     Description
    11/04/2014      Chris Noe               Initial Release 
*/

public with sharing class Deal_Reg_Forgot_Password_Cntrl {
    public String sEmail {get; set;}  

	public Deal_Reg_Forgot_Password_Cntrl() {}

	public PageReference forgotPassword() {
        //Method Variables
        Community_Detail__c oCommunityDetail = new Community_Detail__c();
        String sFormattedUserName;

        //Retrieve the community detail from the custom setting Community_Detail__c for this community.
        try {
        	oCommunityDetail = [select Id, Name, Sub_Domain__c from Community_Detail__c where Name = 'Ergotron Deal Registration Community'];	
        }
        catch(Exception oException) {
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
        	return null;
        }

        //Format the username entered in the login form with the sub-domain value retrieved from the custom setting above.
        sFormattedUserName = sEmail.replace('@', '.');
        sFormattedUserName = sFormattedUserName + '@' + oCommunityDetail.Sub_Domain__c;

        //Determine if active user exists with the formatted username above
        try{
        	User oUserExists = [select Id, Username from User where IsActive=true and Username = :sFormattedUserName];
        }
        catch (Exception oException) {
        	//User not found, add page message.
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Active user not found for the email address entered.'));
        	return null;
        }

        //Call the Site class forgotPassword method.  This method will send the password reset email (using the template defined in the communtiy set up) to the user.
  		Boolean bResetSuccess = Site.forgotPassword(sFormattedUserName);
  		
  		//Check for reset success and then redirect the user to the password reset confirmation page.
  		if(bResetSuccess) {  			
  			PageReference oPageRef = Page.DealRegForgotPasswordConfirm;
  			oPageRef.setRedirect(true);
  			return oPageRef;
  		}

  		//Error calling forgot password method, display message to the user.
		for(ApexPages.Message oPageMessage: ApexPages.getMessages()) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oPageMessage.getSummary()));
		}  		
  		
  		return null;
	}
}