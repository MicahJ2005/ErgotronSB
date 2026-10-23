/*
	Utility class for calling external web services for creating Oracle customers, parties, and relationships.

	MOD DATE		Who						Description
	9/30/2014		Chris Noe				Initial Release
*/

public with sharing class Oracle_Customer_Utility {

	private Boolean bolEmptyResponse = false;

/*
BEGIN: ORACLE CREATE CUSTOMER LOGIC
*/	
	public class CreateCustomerRequest {
		//Inner class which provides the JSON request structure required for calling the Oracle create customer web service.
		
		public String ip_verification_id;
		public String ip_party_id;
		public String ip_cust_account_id;
		public String ip_ship_to_site_use_id;
		public String ip_organization_name;
		public String ip_account_name;
		public String ip_address1;
		public String ip_address2;
		public String ip_address3;
		public String ip_address4;
		public String ip_city;
		public String ip_state;
		public String ip_province;
		public String ip_postal_code;
		public String ip_country;
		public String ip_county;
		public String ip_person_first_name;
		public String ip_person_last_name;
		public String ip_raw_phone_number;
		public String ip_email_address;
		public String ip_is_bill_to_address;
		public String ip_is_ship_to_address;
		public String ip_salesforce_ref_id;
	}

	public class CreateCustomerResponse {
		//Inner class used for deserializing web service responses for creating new customers in Oracle.
		
		public String ip_verification_id;
		public String ip_party_id;
		public String ip_cust_account_id;
		public String ip_ship_to_site_use_id;
		public String ip_organization_name;
		public String ip_account_name;
		public String ip_address1;
		public String ip_address2;
		public String ip_address3;
		public String ip_address4;
		public String ip_city;
		public String ip_state;
		public String ip_province;
		public String ip_postal_code;
		public String ip_country;
		public String ip_county;
		public String ip_person_first_name;
		public String ip_person_last_name;
		public String ip_raw_phone_number;
		public String ip_email_address;
		public String ip_is_bill_to_address;
		public String ip_is_ship_to_address;
		public String ip_salesforce_ref_id;
		public String op_party_id;
		public String op_party_number;
		public String op_cust_account_id;
		public String op_ship_to_site_use_id;
		public String op_bill_to_site_use_id;
		public String op_ship_to_contact_id;
		public String op_cust_account_role_id;
		public String op_return_status;
		public String op_return_message;
		public String ws_callout_status_code;
		public String ws_callout_status_message;
		public String ws_exception_message;
	}

	public static CreateCustomerResponse createCustomerCallout(CreateCustomerRequest oCreateCustomerReqeust, String sCallingApplication) {
		//Method for making external web service callout for creating Oracle customer details.  This method is called as part of the seed unit ordering process.
		
		//Method variables
		//List<Interface_Log__c> lstLogs = new List<Interface_Log__c>();
		CreateCustomerResponse oCreateCustomerResponse = new CreateCustomerResponse();
		String sJSONRequest = '';
		String sJSONResponse = '';
		Web_Service_Details__c oWebServiceDetails = new Web_Service_Details__c();		
		Http oHTTP = new Http();
		HttpRequest oHTTPRequest = new HttpRequest();
		HTTPResponse oHTTPResponse = new HttpResponse();
		String sExceptionEmailSubject='';
		String sExceptionEmailBody='';
		List<String> listExceptionEmails = new List<String>();

		//Retrieve web service details from custom setting
		oWebServiceDetails = [select Endpoint__c, Password__c, Username__c, Exception_Email__c from Web_Service_Details__c where Name = 'Create Customer'];

		//Serialize and format the list of territory lookup request values passed to this method
		sJSONRequest = JSON.serialize(oCreateCustomerReqeust);
		sJSONRequest = '{"customer":' + sJSONRequest + '}';

		oHTTPRequest.setEndpoint(oWebServiceDetails.Endpoint__c);
		oHTTPRequest.setMethod('POST');
		oHTTPRequest.setHeader('Content-Type', 'application/json');
		oHTTPRequest.setTimeout(120000);
		Blob blobUserPwd = Blob.valueOf(oWebServiceDetails.Username__c + ':' + oWebServiceDetails.Password__c);
		oHTTPRequest.setHeader('Authorization', 'Basic '+ EncodingUtil.base64Encode(blobUserPwd));
		oHTTPRequest.setBody(sJSONRequest);	
		String sBody = oHTTPRequest.getBody();
		oHTTPRequest.setHeader('Content-Length', String.valueOf(sBody.length()));

		// 20150904 Andy and Steve - adding System Debug messages to determine what is being sent over to Oracle
		System.Debug('Oracle_Customer_Utility.createCustomerCallout');
		System.Debug(sJSONRequest);
		// 20150904 END

		// 20151116 Andy and Steve - Dumping the Request into the Logging Object
		UtilityMethods.addToLog('createCustomerCallout.Request', oCreateCustomerReqeust.ip_salesforce_ref_id + '|' + sJSONRequest, 'Success');

		try{
			System.Debug('STARTING TRY');
			oHTTPResponse = oHTTP.send(oHTTPRequest);
			sJSONResponse = oHTTPResponse.getBody();
			UtilityMethods.addToLog('createCustomerCallout.Response', oCreateCustomerReqeust.ip_salesforce_ref_id + '|' + sJSONResponse, 'Response');
			System.Debug('createCustomerCallout.Response ' + oCreateCustomerReqeust.ip_salesforce_ref_id + '|' + sJSONResponse);

			if(oHTTPResponse.getStatusCode()==200 && sJSONResponse != NULL) {
				//Remove the stuff that Apex does not like
				sJSONResponse = sJSONResponse.replace('{"d":', '');
				sJSONResponse = sJSONResponse.replace('}]}', '}]');

				// 20151116 Andy and Steve - Dumping the Request into the Logging Object
				UtilityMethods.addToLog('createCustomerCallout.Response', oCreateCustomerReqeust.ip_salesforce_ref_id + '|' + sJSONResponse, 'Success');

				oCreateCustomerResponse = (CreateCustomerResponse) JSON.deserialize(sJSONResponse, CreateCustomerResponse.class);
				oCreateCustomerResponse.ws_callout_status_code = String.valueOf(oHTTPResponse.getStatusCode());
				oCreateCustomerResponse.ws_callout_status_message = 'CALLOUT STATUS MESSAGE: ' + oHTTPResponse.getStatus();	

				//Evaluate Oracle API reponse - check for api errors and send email alert
				if(oCreateCustomerResponse.op_return_status!=NULL && oCreateCustomerResponse.op_return_status!='') {
					//Oracle API Exception, send email with error details.
					sExceptionEmailSubject=sCallingApplication + ' - CreateCustomer Interface - Oracle API Status Exception';
					sExceptionEmailBody = 'Oracle API Status Code: ' + oCreateCustomerResponse.op_return_status + '<br/>' + 'Oracle API Status Message: ' + oCreateCustomerResponse.op_return_message;
					sExceptionEmailBody = sExceptionEmailBody + '<br/>' + 'Salesforce Reference Id: ' + oCreateCustomerReqeust.ip_salesforce_ref_id;
					
					//Call method to send exception email notification
					listExceptionEmails.add(oWebServiceDetails.Exception_Email__c);
					sendExceptionEmail(listExceptionEmails, sExceptionEmailBody, sExceptionEmailSubject);

					UtilityMethods.addToLog('createCustomerCallout.Response', oCreateCustomerResponse.op_return_status + '|' + sJSONResponse, 'Failure');
				}	
			}
			else{
				//Status code exception, send email with error details.
				sExceptionEmailSubject=sCallingApplication + ' - CreateCustomer Interface - Web Service Response Status Exception';
				sExceptionEmailBody = 'HTTP Response Code: ' + oHTTPResponse.getStatusCode() + '<br/>' + 'HTTP Response Message: ' + oHTTPResponse.getStatus();
				sExceptionEmailBody = sExceptionEmailBody + '<br/>' + 'Salesforce Reference Id: ' + oCreateCustomerReqeust.ip_salesforce_ref_id;

				// 20151116 Andy and Steve - Dumping the Request into the Logging Object
				//UtilityMethods.lstLogs.add(new Interface_Log__c(Source_Process__c='createCustomerCallout.Response', Logging_Information__c=oCreateCustomerReqeust.ip_salesforce_ref_id + '|' + oHTTPResponse.getStatus(), Condition__c='Failure'));
				UtilityMethods.addToLog('createCustomerCallout.Response', oCreateCustomerReqeust.ip_salesforce_ref_id + '|' + oHTTPResponse.getStatus(), 'Failure');
				
				//Call method to send exception email notification
				listExceptionEmails.add(oWebServiceDetails.Exception_Email__c);
				sendExceptionEmail(listExceptionEmails, sExceptionEmailBody, sExceptionEmailSubject);

				//Set response status values
				oCreateCustomerResponse.ws_callout_status_code = String.valueOf(oHTTPResponse.getStatusCode());
				oCreateCustomerResponse.ws_callout_status_message = 'CALLOUT STATUS MESSAGE: ' + oHTTPResponse.getStatus() + '<br />';			
				oCreateCustomerResponse.ws_callout_status_message+= 'RETURNED FROM ORACLE: ' + oHTTPResponse.getBody();
			}
		}
		catch(Exception oException){
			//Callout exception, send email with error details.
			sExceptionEmailSubject=sCallingApplication + ' - CreateCustomer Interface - Web Service Callout Exception';
			sExceptionEmailBody = 'Exception Message: ' + oException.getMessage();
			sExceptionEmailBody = sExceptionEmailBody + '<br/>' + 'Salesforce Reference Id: ' + oCreateCustomerReqeust.ip_salesforce_ref_id;

			// 20151116 Andy and Steve - Dumping the Request into the Logging Object
			//UtilityMethods.lstLogs.add(new Interface_Log__c(Source_Process__c='createCustomerCallout.Response-Exception', Logging_Information__c=oException.getMessage(), Condition__c='Failure'));
			UtilityMethods.addToLog('createCustomerCallout.Response-Exception', oCreateCustomerReqeust.ip_salesforce_ref_id + '|' + oException.getMessage(), 'Failure');

			//Call method to send exception email notification
			listExceptionEmails.add(oWebServiceDetails.Exception_Email__c);
			sendExceptionEmail(listExceptionEmails, sExceptionEmailBody, sExceptionEmailSubject);
		
			//Set response status values
			oCreateCustomerResponse.ws_callout_status_code = String.valueOf(oHTTPResponse.getStatusCode());
			oCreateCustomerResponse.ws_callout_status_message = 'CALLOUT STATUS MESSAGE: ' + oHTTPResponse.getStatus();
			oCreateCustomerResponse.ws_exception_message = 'CALLOUT EXCEPTION: ' + oException.getMessage();
		}

		// 20151116 Andy and Steve - Save Logs
		//UtilityMethods.commitLogs();
		//try {
		//	System.Debug('INSERTING LOGS');
		//	System.Debug(lstLogs);
		//	if(lstLogs.size() > 0) { insert lstLogs; }
		//} catch(Exception ex) {
		//	System.Debug('BANG BANG BANG - ' + ex);
		//}

		return oCreateCustomerResponse;
	}
/*
END: ORACLE CREATE CUSTOMER LOGIC
*/

/*
BEGIN: ORACLE CREATE PARTY LOGIC
*/
	public class CreatePartyRequest {
		//Inner class which provides the JSON request structure required for calling the Oracle create party web service.
		
		public String ip_verification_id;
		public String ip_party_name;
		public String ip_address1;
		public String ip_address2;
		public String ip_address3;
		public String ip_address4;
		public String ip_city;
		public String ip_state;
		public String ip_province;
		public String ip_postal_code;
		public String ip_country;
		public String ip_salesforce_ref_id;
	}

	public class CreatePartyResponse {
		//Inner class used for deserializing web service responses for creating new parties in Oracle.
		
		public String ip_verification_id;
		public String ip_party_name;
		public String ip_address1;
		public String ip_address2;
		public String ip_address3;
		public String ip_address4;
		public String ip_city;
		public String ip_state;
		public String ip_province;
		public String ip_postal_code;
		public String ip_country;
		public String ip_salesforce_ref_id;
		public String op_party_id;
		public String op_party_number;
		public String op_return_status;
		public String op_return_message;
		public String ws_callout_status_code;
		public String ws_callout_status_message;
		public String ws_exception_message;
	}

	public static CreatePartyResponse createPartyCallout(CreatePartyRequest oCreatePartyReqeust, String sCallingApplication) {
		//Method for making external web service callout for creating Oracle party details.
		
		//Method variables
		//List<Interface_Log__c> lstLogs = new List<Interface_Log__c>();
		CreatePartyResponse oCreatePartyResponse = new CreatePartyResponse();
		String sJSONRequest = '';
		String sJSONResponse = '';
		Web_Service_Details__c oWebServiceDetails = new Web_Service_Details__c();		
		Http oHTTP = new Http();
		HttpRequest oHTTPRequest = new HttpRequest();
		HTTPResponse oHTTPResponse = new HttpResponse();
		String sExceptionEmailSubject='';
		String sExceptionEmailBody='';
		List<String> listExceptionEmails = new List<String>();

		//Retrieve web service details from custom setting
		oWebServiceDetails = [select Endpoint__c, Password__c, Username__c, Exception_Email__c from Web_Service_Details__c where Name = 'Create Party'];

		//Serialize and format the list of territory lookup request values passed to this method
		sJSONRequest = JSON.serialize(oCreatePartyReqeust);
		sJSONRequest = '{"party":' + sJSONRequest + '}';

		//UtilityMethods.lstLogs.add(new Interface_Log__c(Source_Process__c='createPartyCallout.Request', Logging_Information__c=oCreatePartyReqeust.ip_salesforce_ref_id + '|' + sJSONRequest, Condition__c='Success'));
		UtilityMethods.addToLog('createPartyCallout.Request', oCreatePartyReqeust.ip_salesforce_ref_id + '|' + sJSONRequest, 'Success');

		oHTTPRequest.setEndpoint(oWebServiceDetails.Endpoint__c);
		oHTTPRequest.setMethod('POST');
		oHTTPRequest.setHeader('Content-Type', 'application/json');
		oHTTPRequest.setTimeout(120000);
		Blob blobUserPwd = Blob.valueOf(oWebServiceDetails.Username__c + ':' + oWebServiceDetails.Password__c);
		oHTTPRequest.setHeader('Authorization', 'Basic '+ EncodingUtil.base64Encode(blobUserPwd));
		oHTTPRequest.setBody(sJSONRequest);	
		String sBody = oHTTPRequest.getBody();
		oHTTPRequest.setHeader('Content-Length', String.valueOf(sBody.length()));

		try{
			oHTTPResponse = oHTTP.send(oHTTPRequest);
			sJSONResponse = oHTTPResponse.getBody();
			System.Debug('createPartyCallout.Response ' + oCreatePartyReqeust.ip_salesforce_ref_id + '|' + sJSONResponse);
			UtilityMethods.addToLog('createPartyCallout.Response', oCreatePartyReqeust.ip_salesforce_ref_id + '|' + sJSONResponse, 'Response');

			if(oHTTPResponse.getStatusCode()==200 && sJSONResponse != NULL) {
				//Remove the stuff that Apex does not like
				sJSONResponse = sJSONResponse.replace('{"d":', '');
				sJSONResponse = sJSONResponse.replace('}]}', '}]');
				oCreatePartyResponse = (CreatePartyResponse) JSON.deserialize(sJSONResponse, CreatePartyResponse.class);
				oCreatePartyResponse.ws_callout_status_code = String.valueOf(oHTTPResponse.getStatusCode());
				oCreatePartyResponse.ws_callout_status_message = 'CALLOUT STATUS MESSAGE: ' + oHTTPResponse.getStatus();

				// 20151116 Andy and Steve - Dumping the Request into the Logging Object
				//UtilityMethods.lstLogs.add(new Interface_Log__c(Source_Process__c='createPartyCallout.Response', Logging_Information__c=oCreatePartyReqeust.ip_salesforce_ref_id + '|' + sJSONResponse, Condition__c='Success'));
				UtilityMethods.addToLog('createPartyCallout.Response', oCreatePartyReqeust.ip_salesforce_ref_id + '|' + sJSONResponse, 'Success');

				//Evaluate Oracle API reponse - check for api errors and send email alert
				if(oCreatePartyResponse.op_return_status!=NULL && oCreatePartyResponse.op_return_status!='') {
					//Oracle API Exception, send email with error details.
					sExceptionEmailSubject=sCallingApplication + ' - CreateParty Interface - Oracle API Status Exception';
					sExceptionEmailBody = 'Oracle API Status Code: ' + oCreatePartyResponse.op_return_status + '<br/>' + 'Oracle API Status Message: ' + oCreatePartyResponse.op_return_message;
					sExceptionEmailBody = sExceptionEmailBody + '<br/>' + 'Salesforce Reference Id: ' + oCreatePartyReqeust.ip_salesforce_ref_id;
					
					//Call method to send exception email notification
					listExceptionEmails.add(oWebServiceDetails.Exception_Email__c);
					sendExceptionEmail(listExceptionEmails, sExceptionEmailBody, sExceptionEmailSubject);

					UtilityMethods.addToLog('createPartyCallout.Response', oCreatePartyReqeust.ip_salesforce_ref_id + '|' + oCreatePartyResponse.op_return_status, 'Failure');
				}	
			}
			else{
				//Status code exception, send email with error details.
				sExceptionEmailSubject=sCallingApplication + ' - CreateParty Interface - Web Service Response Status Exception';
				sExceptionEmailBody = 'HTTP Response Code: ' + oHTTPResponse.getStatusCode() + '<br/>' + 'HTTP Response Message: ' + oHTTPResponse.getStatus();
				sExceptionEmailBody = sExceptionEmailBody + '<br/>' + 'Salesforce Reference Id: ' + oCreatePartyReqeust.ip_salesforce_ref_id;

				// 20151116 Andy and Steve - Dumping the Request into the Logging Object
				//UtilityMethods.lstLogs.add(new Interface_Log__c(Source_Process__c='createPartyCallout.Response', Logging_Information__c=oCreatePartyReqeust.ip_salesforce_ref_id + '|' + oHTTPResponse.getStatus(), Condition__c='Failure'));
				UtilityMethods.addToLog('createPartyCallout.Response', oCreatePartyReqeust.ip_salesforce_ref_id + '|' + oHTTPResponse.getStatus(), 'Failure');
				
				//Call method to send exception email notification
				listExceptionEmails.add(oWebServiceDetails.Exception_Email__c);
				sendExceptionEmail(listExceptionEmails, sExceptionEmailBody, sExceptionEmailSubject);

				//Set response status values
				oCreatePartyResponse.ws_callout_status_code = String.valueOf(oHTTPResponse.getStatusCode());
				oCreatePartyResponse.ws_callout_status_message = 'CALLOUT STATUS MESSAGE: ' + oHTTPResponse.getStatus() + '<br />';			
				oCreatePartyResponse.ws_callout_status_message+= 'RETURNED FROM ORACLE: ' + oHTTPResponse.getBody();		
			}
		}
		catch(Exception oException){
			//Callout exception, send email with error details.
			sExceptionEmailSubject=sCallingApplication + ' - CreateParty Interface - Web Service Callout Exception';
			sExceptionEmailBody = 'Exception Message: ' + oException.getMessage();
			sExceptionEmailBody = sExceptionEmailBody + '<br/>' + 'Salesforce Reference Id: ' + oCreatePartyReqeust.ip_salesforce_ref_id;

			// 20151116 Andy and Steve - Dumping the Request into the Logging Object
			//UtilityMethods.lstLogs.add(new Interface_Log__c(Source_Process__c='createPartyCallout.Response-Exception', Logging_Information__c=oException.getMessage(), Condition__c='Failure'));
			UtilityMethods.addToLog('createPartyCallout.Response-Exception', oCreatePartyReqeust.ip_salesforce_ref_id + '|' + oException.getMessage(), 'Failure');

			//Call method to send exception email notification
			listExceptionEmails.add(oWebServiceDetails.Exception_Email__c);
			sendExceptionEmail(listExceptionEmails, sExceptionEmailBody, sExceptionEmailSubject);
		
			//Set response status values
			oCreatePartyResponse.ws_callout_status_code = String.valueOf(oHTTPResponse.getStatusCode());
			oCreatePartyResponse.ws_callout_status_message = 'CALLOUT STATUS MESSAGE: ' + oHTTPResponse.getStatus();	
			oCreatePartyResponse.ws_exception_message = 'CALLOUT EXCEPTION: ' + oException.getMessage();
		}

		//// 20151116 Andy and Steve - Save Logs
		//System.Debug('INSERTING LOGS');
		//System.Debug(lstLogs);
		//if(lstLogs.size() > 0) { insert lstLogs; }

		return oCreatePartyResponse;
	}
/*
END: ORACLE CREATE PARTY LOGIC
*/

/*
BEGIN: ORACLE CREATE CUSTOMER RELATIONSHIP LOGIC
*/	
	public class CreateRelationshipRequest {
		//Inner class which provides the JSON request structure required for calling the Oracle create relationship web service.
		
		public String ip_verification_id;
		public String ip_cust_account_id;
		public String ip_related_cust_account_id;
		public String ip_bill_to_flag;
		public String ip_ship_to_flag;
		public String ip_salesforce_ref_id;
	}

	public class CreateRelationshipResponse {
		//Inner class used for deserializing web service responses for creating new customer relationship in Oracle.
		
		public String ip_verification_id;
		public String ip_cust_account_id;
		public String ip_related_cust_account_id;
		public String ip_bill_to_flag;
		public String ip_ship_to_flag;
		public String ip_salesforce_ref_id;
		public String op_return_status;
		public String op_return_message;
		public String ws_callout_status_code;
		public String ws_callout_status_message;
		public String ws_exception_message;
	}

	public static CreateRelationshipResponse createRelationshipCallout(CreateRelationshipRequest oCreateRelationshipReqeust, String sCallingApplication) {
		//Method for making external web service callout for creating Oracle customer relationships.
		
		//Method variables		
		CreateRelationshipResponse oCreateRelationshipResponse = new CreateRelationshipResponse();
		String sJSONRequest = '';
		String sJSONResponse = '';
		Web_Service_Details__c oWebServiceDetails = new Web_Service_Details__c();		
		Http oHTTP = new Http();
		HttpRequest oHTTPRequest = new HttpRequest();
		HTTPResponse oHTTPResponse = new HttpResponse();
		String sExceptionEmailSubject='';
		String sExceptionEmailBody='';
		List<String> listExceptionEmails = new List<String>();

		//Retrieve web service details from custom setting
		oWebServiceDetails = [select Endpoint__c, Password__c, Username__c, Exception_Email__c from Web_Service_Details__c where Name = 'Create Relationship'];

		//Serialize and format the list of territory lookup request values passed to this method
		sJSONRequest = JSON.serialize(oCreateRelationshipReqeust);
		sJSONRequest = '{"relationship":' + sJSONRequest + '}';

		oHTTPRequest.setEndpoint(oWebServiceDetails.Endpoint__c);
		oHTTPRequest.setMethod('POST');
		oHTTPRequest.setHeader('Content-Type', 'application/json');
		oHTTPRequest.setTimeout(120000);
		Blob blobUserPwd = Blob.valueOf(oWebServiceDetails.Username__c + ':' + oWebServiceDetails.Password__c);
		oHTTPRequest.setHeader('Authorization', 'Basic '+ EncodingUtil.base64Encode(blobUserPwd));
		oHTTPRequest.setBody(sJSONRequest);	
		String sBody = oHTTPRequest.getBody();
		oHTTPRequest.setHeader('Content-Length', String.valueOf(sBody.length()));

		try{
			oHTTPResponse = oHTTP.send(oHTTPRequest);
			sJSONResponse = oHTTPResponse.getBody();
			System.Debug('createPartyCallout.Response ' + oCreateRelationshipReqeust.ip_salesforce_ref_id + '|' + sJSONResponse);
			UtilityMethods.addToLog('createPartyCallout.Response', oCreateRelationshipReqeust.ip_salesforce_ref_id + '|' + sJSONResponse, 'Response');

			if(oHTTPResponse.getStatusCode()==200 && sJSONResponse != NULL) {
				//Remove the stuff that Apex does not like
				sJSONResponse = sJSONResponse.replace('{"d":', '');
				sJSONResponse = sJSONResponse.replace('}]}', '}]');
				oCreateRelationshipResponse = (CreateRelationshipResponse) JSON.deserialize(sJSONResponse, CreateRelationshipResponse.class);
				oCreateRelationshipResponse.ws_callout_status_code = String.valueOf(oHTTPResponse.getStatusCode());
				oCreateRelationshipResponse.ws_callout_status_message = 'CALLOUT STATUS MESSAGE: ' + oHTTPResponse.getStatus();	

				//Evaluate Oracle API reponse - check for api errors and send email alert
				if(oCreateRelationshipResponse.op_return_status!=NULL && oCreateRelationshipResponse.op_return_status!='') {
					//Oracle API Exception, send email with error details.
					sExceptionEmailSubject=sCallingApplication + ' - CreateRelationship Interface - Oracle API Status Exception';
					sExceptionEmailBody = 'Oracle API Status Code: ' + oCreateRelationshipResponse.op_return_status + '<br/>' + 'Oracle API Status Message: ' + oCreateRelationshipResponse.op_return_message;
					sExceptionEmailBody = sExceptionEmailBody + '<br/>' + 'Salesforce Reference Id: ' + oCreateRelationshipReqeust.ip_salesforce_ref_id;
					
					//Call method to send exception email notification
					listExceptionEmails.add(oWebServiceDetails.Exception_Email__c);
					sendExceptionEmail(listExceptionEmails, sExceptionEmailBody, sExceptionEmailSubject);	
				}	
			}
			else{
				//Status code exception, send email with error details.
				sExceptionEmailSubject=sCallingApplication + ' - CreateRelationship Interface - Web Service Response Status Exception';
				sExceptionEmailBody = 'HTTP Response Code: ' + oHTTPResponse.getStatusCode() + '<br/>' + 'HTTP Response Message: ' + oHTTPResponse.getStatus();
				sExceptionEmailBody = sExceptionEmailBody + '<br/>' + 'Salesforce Reference Id: ' + oCreateRelationshipReqeust.ip_salesforce_ref_id;
				
				//Call method to send exception email notification
				listExceptionEmails.add(oWebServiceDetails.Exception_Email__c);
				sendExceptionEmail(listExceptionEmails, sExceptionEmailBody, sExceptionEmailSubject);

				//Set response status values
				oCreateRelationshipResponse.ws_callout_status_code = String.valueOf(oHTTPResponse.getStatusCode());
				oCreateRelationshipResponse.ws_callout_status_message = 'CALLOUT STATUS MESSAGE: ' + oHTTPResponse.getStatus() + '<br />';			
				oCreateRelationshipResponse.ws_callout_status_message+= 'RETURNED FROM ORACLE: ' + oHTTPResponse.getBody();				
			}
		}
		catch(Exception oException){
			//Callout exception, send email with error details.
			sExceptionEmailSubject=sCallingApplication + ' - CreateRelationship Interface - Web Service Callout Exception';
			sExceptionEmailBody = 'Exception Message: ' + oException.getMessage();
			sExceptionEmailBody = sExceptionEmailBody + '<br/>' + 'Salesforce Reference Id: ' + oCreateRelationshipReqeust.ip_salesforce_ref_id;

			//Call method to send exception email notification
			listExceptionEmails.add(oWebServiceDetails.Exception_Email__c);
			sendExceptionEmail(listExceptionEmails, sExceptionEmailBody, sExceptionEmailSubject);
		
			//Set response status values
			oCreateRelationshipResponse.ws_callout_status_code = String.valueOf(oHTTPResponse.getStatusCode());
			oCreateRelationshipResponse.ws_callout_status_message = 'CALLOUT STATUS MESSAGE: ' + oHTTPResponse.getStatus();
			oCreateRelationshipResponse.ws_exception_message = 'CALLOUT EXCEPTION: ' + oException.getMessage();
		}

		return oCreateRelationshipResponse;
	}		
/*
END: ORACLE CREATE CUSTOMER RELATIONSHIP LOGIC
*/

	private static void sendExceptionEmail(List<String> listToAddresses, String sException, String sSubject) {
		//This method sends an email to the set of ToAddresses passed into this method.  This method is called when an exception occurs in this class.
		
		//Method variables
		Messaging.SingleEmailMessage oEmail = new Messaging.SingleEmailMessage();
		List<Messaging.SingleEmailMessage> listEmailMessages = new List<Messaging.SingleEmailMessage>();
		
		//Construct the email and send it.
		oEmail.setToAddresses(listToAddresses);
		oEmail.setSubject(sSubject);
		oEmail.setHTMLBody(sException);
		listEmailMessages.add(oEmail);
		Messaging.sendEmail(listEmailMessages);
	}	
}