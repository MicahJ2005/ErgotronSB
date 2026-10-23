/*
	Controller class for the OracleCreateParty.page on the Account object.

	MOD DATE		Who						Description
	10/09/2014		Chris Noe				Initial Release
*/

public without sharing class Oracle_Create_Party_Controller {
    //Class variables
    public final Account oAccount;

	public Oracle_Create_Party_Controller(ApexPages.StandardController stdController) {
		//Get the current Account record
        this.oAccount = (Account)stdController.getRecord();
	}

	public PageReference createParty(){
    	//Method variables
    	PageReference oPageRef;
		Oracle_Customer_Utility.CreatePartyRequest oCreatePartyRequest = new Oracle_Customer_Utility.CreatePartyRequest();
		Oracle_Customer_Utility.CreatePartyResponse oCreatePartyResponse = new Oracle_Customer_Utility.CreatePartyResponse();

		//Retrieve unique integration id for transaction validation
		Integration_Id__c oIntegrationId = [select Id, Name, Security_Id__c from Integration_Id__c order by CreatedDate limit 1];

		//Set verification id
		oCreatePartyRequest.ip_verification_id = oIntegrationId.Security_Id__c;
		//Set salesforce ref id
		oCreatePartyRequest.ip_salesforce_ref_id = oAccount.Id;

		//Set party details - NULL checks required for toUpperCase function
		if(oAccount.Name!=NULL) {
			oCreatePartyRequest.ip_party_name=oAccount.Name.toUpperCase();	
		}
		if(oAccount.BillingStreet!=NULL) {
			oCreatePartyRequest.ip_address1=oAccount.BillingStreet.toUpperCase();	
		}
		if(oAccount.BillingCity!=NULL) {
			oCreatePartyRequest.ip_city=oAccount.BillingCity.toUpperCase();	
		}
		if(oAccount.BillingStateCode!=NULL) {
			//For Canadian addresses, set State value to CA (required for Canadian address formats in Oracle) and set province value to state code
			if(oAccount.BillingCountryCode=='CA') {
				oCreatePartyRequest.ip_state='CA';
				oCreatePartyRequest.ip_province=oAccount.BillingStateCode.toUpperCase();
			}
			else if (oAccount.BillingCountryCode=='US'){
				//Set state and province values
				oCreatePartyRequest.ip_state=oAccount.BillingStateCode.toUpperCase();
				oCreatePartyRequest.ip_province='';
			}
			else {
				//Set state and province values
				oCreatePartyRequest.ip_state=oAccount.BillingStateCode.toUpperCase();
				oCreatePartyRequest.ip_province=oAccount.BillingStateCode.toUpperCase();
			}			
		}
		if(oAccount.BillingPostalCode!=NULL) {
			oCreatePartyRequest.ip_postal_code=oAccount.BillingPostalCode.toUpperCase();
		}
		if(oAccount.BillingCountryCode!=NULL) {
			oCreatePartyRequest.ip_country=oAccount.BillingCountryCode.toUpperCase();
		}	
		
		//Submit create party interface request
		oCreatePartyResponse = Oracle_Customer_Utility.createPartyCallout(oCreatePartyRequest, 'Create Party From Account Request');

		//Delete integration id associated with this transaction
		delete oIntegrationId;

		//Evaluate web service response - web service callout exception check.
		if(oCreatePartyResponse.ws_exception_message!=NULL && oCreatePartyResponse.ws_exception_message!='') {
			//Web service callout exception.  Add page message and return NULL to the user.
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'CALLOUT EXCEPTION. Error creating Oracle party details. Your system administrator has been notified.'));
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oCreatePartyResponse.ws_exception_message));
			return null;
		}

		//Evalutate web service response - web service status check.
		if(oCreatePartyResponse.ws_callout_status_code!='200') {
			//Web service status exception.  Add page message and return NULL to the user.
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'STATUS EXCEPTION. Error creating Oracle party details. Your system administrator has been notified.'));
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'STATUS CODE: ' + oCreatePartyResponse.ws_callout_status_code));
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oCreatePartyResponse.ws_callout_status_message));
			return null;			
		}

		//Evaluate Oracle API reponse - check for api errors
		if(oCreatePartyResponse.op_return_status!=NULL && oCreatePartyResponse.op_return_status!='') {
			//Oracle API exception.  Add page message and return NULL to the user.
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ORACLE API EXCEPTION. Error creating Oracle party details. Your system administrator has been notified.'));
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ORACLE API STATUS CODE: ' + oCreatePartyResponse.op_return_status));
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ORACLE API STATUS MESSAGE: ' + oCreatePartyResponse.op_return_message));
			return null;		
		}

		//Web service call was successful, process response.  Populate Oracle party details on the current account.
		oAccount.Oracle_Party_Name__c = oCreatePartyResponse.ip_party_name;
		oAccount.Oracle_Party_Status__c = 'A';
		oAccount.Oracle_Party_Id__c = oCreatePartyResponse.op_party_id;
		oAccount.Oracle_Party_Number__c = oCreatePartyResponse.op_party_number;
		update oAccount;

		oPageRef = Page.OracleCreatePartySummary;
		oPageRef.getParameters().put('id', oAccount.Id);
		oPageRef.setRedirect(true);
		return oPageRef;
	}
}