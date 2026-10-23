/*
    Controller class for the DealRegLogin.page.

    MOD DATE        Who                     Description
    11/04/2014      Chris Noe               Initial Release 
*/

public with sharing class Deal_Reg_Login_Cntrl {
	public String sEmail {get;set;}
    public String sPassword {get;set;}

	public Deal_Reg_Login_Cntrl() {}

    public PageReference login() {
        //Method Variables
        Community_Detail__c oCommunityDetail = new Community_Detail__c();
        String sFormattedUserName;

        //Retrieve the community detail from the custom setting Community_Detail__c for this community.
        try {
        	oCommunityDetail = [select Id, Name, Sub_Domain__c from Community_Detail__c where Name = 'Ergotron Deal Registration Community'];	
        }
        catch(Exception oException) {
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
            system.debug('LOGIN ERROR COMMUNITY DETAIL: ' + oException.getMessage());
        	return null;
        }

        //Format the email entered in the login form with the sub-domain value retrieved from the custom setting above.
        sFormattedUserName = sEmail.replace('@', '.');
        sFormattedUserName = sFormattedUserName + '@' + oCommunityDetail.Sub_Domain__c;

        //Call site.login function and attempt login. We do not set the URL to be redirected to upon successful login because the community Site.com configuration
        //will handle this through the site landing page logic.
        PageReference oPageRef = Site.login(sFormattedUserName, sPassword, null);

        if(oPageRef==NULL) {
        	for(ApexPages.Message oPageMessage: ApexPages.getMessages()) {
        		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oPageMessage.getSummary()));
        	}

        	return null;
        }
        
        return oPageRef;
    }
}