/*
	Utility class for calling external web services from Apex classes.

	MOD DATE		Who						Description
	3/17/2014		Chris Noe				Initial Release
	5/30/2014		Chris Noe				Updates to support external web service call to Oracle to retrieve ship to addresses.
*/

public with sharing class Web_Service_Utility {

	public class TerritoryLookupRequest {
		//Inner class which provides the JSON request structure required for calling the Oracle territory lookup web service.  This inner class
		//is used to populate Id, CountryCode, StateCode, and PostalCode values for Leads, Accounts, and POS records which require territory lookup.
		
		Id Id;
		String CountryCode;
		String PostalCode;
		String StateCode;
		String Vertical;

		public TerritoryLookupRequest(Id idRecordId, String sCountryCode, String sPostalCode, String sStateCode) {
			Id = idRecordId;
			CountryCode = sCountryCode;
			PostalCode = sPostalCode;
			StateCode = sStateCode;
			Vertical = '';
		}
		
		public TerritoryLookupRequest(Id idRecordId, String sCountryCode, String sPostalCode, String sStateCode, String sVertical) {
			Id = idRecordId;
			CountryCode = sCountryCode;
			PostalCode = sPostalCode;
			StateCode = sStateCode;
			Vertical = sVertical;
		}
	}

	public class TerritoryLookupResponse {
		//Inner class used for deserializing web service responses for territory lookup
		public String ID;
		public String Name;
		public String Phone;
		public String Email;
		public String Ismanager;
		public String Multirep;		
	}

	public class TerritoryLookupResponseV2 {
		//Inner class used for deserializing web service responses for verticalized territory lookup
		public String ID;
		public String LeadID;
		public String Name;
		public String Phone;
		public String Email;
		public String RoleCode; // This is the key for vertical assignments
		public String RoleName;
		public String RoleDescription;
		public String Region;
		public String PersonID;
		public String ManagerName;
		public String ManagerPhone;
		public String ManagerEmail;
		public String ManagerID;
		public String x_status;
		public String x_msg;

	}

	//public class TerritoryLookupResponseWrapperV2 {
	//	//Inner class used for deserializing web service responses for verticalized territory lookup
		
	//	public List<TerritoryLookupResponseV2> lstReps;
	//}
	
	//public static List<TerritoryLookupResponse> TerritoryLookupCallout(List<TerritoryLookupRequest> listTerritoryLookupRequest, String sCallingApplication) {
	public static List<TerritoryLookupResponseV2> TerritoryLookupCallout(List<TerritoryLookupRequest> listTerritoryLookupRequest, String sCallingApplication) {
		//Method for making external web service callout for territory assignment.  This is a generic method that can be used for any object which requires territory assignment
		//from Oracle.  This method takes one parameter which is a list of TerritoryAssignmentRequest records.  This list is built dynamically by the calling method based on the 
		//type of object requesting the territory (ex. Leads, Accounts, POS, etc.).  This method returns a list of TerritoryAssignmentResonse values which can then be used by the
		//calling method to assign ownership to a record such as a Lead, Account, or POS.
		
		//Method variables
		//List<TerritoryLookupResponse> listTerritoryLookupResponse = new List<TerritoryLookupResponse>();
		List<TerritoryLookupResponseV2> lstTerritoryLookupResponse = new List<TerritoryLookupResponseV2>();
		String sJSONRequest = '';
		String sJSONResponse = '';
		Web_Service_Details__c oWebServiceDetails = new Web_Service_Details__c();		
		Http oHTTP = new Http();
		HttpRequest oHTTPRequest = new HttpRequest();
		String sExceptionEmailSubject='';
		String sExceptionEmailBody='';
		List<String> listExceptionEmails = new List<String>();
		
		//Retrieve web service details from custom setting
		oWebServiceDetails = [select Endpoint__c, Password__c, Username__c, Exception_Email__c from Web_Service_Details__c where Name = 'Territory Lookup'];
		
		//Serialize and format the list of territory lookup request values passed to this method
		sJSONRequest = JSON.serialize(listTerritoryLookupRequest);
		//External web service for territory lookup requires the following format to be added
		sJSONRequest = '{"Leads":' + sJSONRequest + '}';		

		oHTTPRequest.setEndpoint(oWebServiceDetails.Endpoint__c);
		oHTTPRequest.setMethod('POST');
		oHTTPRequest.setHeader('Content-Type', 'application/json');
		oHTTPRequest.setTimeout(120000);
		Blob blobUserPwd = Blob.valueOf(oWebServiceDetails.Username__c + ':' + oWebServiceDetails.Password__c);
		oHTTPRequest.setHeader('Authorization', 'Basic '+ EncodingUtil.base64Encode(blobUserPwd));
		oHTTPRequest.setBody(sJSONRequest);					

		try{
			HTTPResponse oHTTPResponse = oHTTP.send(oHTTPRequest);
			sJSONResponse = oHTTPResponse.getBody();
				
			if(oHTTPResponse.getStatusCode()==200){
				//Remove the stuff that Apex does not like
				sJSONResponse = sJSONResponse.replace('{"d":', '');
				sJSONResponse = sJSONResponse.replace('}]}', '}]');
				
				// Modified 20160223 AAB for Verticalized Territory Webservice
				//listTerritoryLookupResponse = (List<TerritoryLookupResponse>) JSON.deserialize(sJSONResponse, List<TerritoryLookupResponse>.class);
				lstTerritoryLookupResponse = (List<Web_Service_Utility.TerritoryLookupResponseV2>) JSON.deserialize(sJSONResponse, List<Web_Service_Utility.TerritoryLookupResponseV2>.class);		
			}
			else{
				//Status code exception, send email with error details.
				sExceptionEmailSubject=sCallingApplication + ' - Web Service Response Status Exception';
				sExceptionEmailBody = 'HTTP Response Code: ' + oHTTPResponse.getStatusCode() + '<br/>' + 'HTTP Response Message: ' + oHTTPResponse.getStatus();
				
				//Call method to send exception email notification
				listExceptionEmails.add(oWebServiceDetails.Exception_Email__c);
				sendExceptionEmail(listExceptionEmails, sExceptionEmailBody, sExceptionEmailSubject);
			}
		}
		catch(Exception oException){
			//Callout exception, send email with error details.
			sExceptionEmailSubject=sCallingApplication + ' - Web Service Callout Exception';
			sExceptionEmailBody = 'Exception Message: ' + oException.getMessage();
			
			//Call method to send exception email notification
			listExceptionEmails.add(oWebServiceDetails.Exception_Email__c);
			sendExceptionEmail(listExceptionEmails, sExceptionEmailBody, sExceptionEmailSubject);
		}
		
		//Return territory response to calling method
		//return listTerritoryLookupResponse;
		return lstTerritoryLookupResponse;
	}

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
	
	public static List<ShipToSiteUseLookupResponse> SiteUseLookup(String sCustomerId, String sCallingApplication) {
		//Calls external web service "GetSiteUse" using the Customer Id value passed into the method. This service returns all of the ship to addresses
		//from Oracle that are active for the CustomerId passed into the method.

		//Method variables
		List<ShipToSiteUseLookupResponse> listShipToSiteUseLookupResponse = new List<ShipToSiteUseLookupResponse>();
		String sJSONResponse = '';
		Web_Service_Details__c oWebServiceDetails = new Web_Service_Details__c();		
		Http oHTTP = new Http();
		HttpRequest oHTTPRequest = new HttpRequest();
		String sExceptionEmailSubject='';
		String sExceptionEmailBody='';
		List<String> listExceptionEmails = new List<String>();
		
		//Retrieve web service details from custom setting
		oWebServiceDetails = [select Endpoint__c, Password__c, Username__c, Exception_Email__c from Web_Service_Details__c where Name = 'Ship To Site Use Lookup'];	
		
		//Set HTTPRequest
		oHTTPRequest.setEndpoint(oWebServiceDetails.Endpoint__c);
		oHTTPRequest.setMethod('POST');
		oHTTPRequest.setHeader('Content-Type', 'application/json');
		Blob blobUserPwd = Blob.valueOf(oWebServiceDetails.Username__c + ':' + oWebServiceDetails.Password__c);
		oHTTPRequest.setHeader('Authorization', 'Basic '+ EncodingUtil.base64Encode(blobUserPwd));
		oHTTPRequest.setBody('{"AccountID":"'+sCustomerId+'"}');
		try{
			HTTPResponse oHTTPResponse = oHTTP.send(oHTTPRequest);
			sJSONResponse = oHTTPResponse.getBody();

			//UtilityMethods.addToLog('SiteUseLookup.Response', sCustomerId + '|' + sJSONResponse, 'Response');
			System.Debug('SiteUseLookup.Response' + '|' + sJSONResponse);

			if(oHTTPResponse.getStatusCode()==200){
				//Remove the stuff that Apex does not like
				sJSONResponse = sJSONResponse.replace('{"d":', '');
				sJSONResponse = sJSONResponse.replace('}]}', '}]');
				system.debug('JSON RESPONSE=' + sJSONResponse);
				//Deserialize the web service JSON response using the inner class ShipToSiteUseLookupResponse
				listShipToSiteUseLookupResponse = (List<ShipToSiteUseLookupResponse>) JSON.deserialize(sJSONResponse, List<ShipToSiteUseLookupResponse>.class);	
			}
			else{
				//Status code exception, send email with error details.
				sExceptionEmailSubject=sCallingApplication + ' - Web Service Response Status Exception';
				sExceptionEmailBody = 'HTTP Response Code: ' + oHTTPResponse.getStatusCode() + '<br/>' + 'HTTP Response Message: ' + oHTTPResponse.getStatus();
				
				//Call method to send exception email notification
				listExceptionEmails.add(oWebServiceDetails.Exception_Email__c);
				sendExceptionEmail(listExceptionEmails, sExceptionEmailBody, sExceptionEmailSubject);
			}
		}
		catch(Exception oException){
			//Callout exception, send email with error details.
			sExceptionEmailSubject=sCallingApplication + ' - Web Service Callout Exception';
			sExceptionEmailBody = 'Exception Message: ' + oException.getMessage();
			
			//Call method to send exception email notification
			listExceptionEmails.add(oWebServiceDetails.Exception_Email__c);
			sendExceptionEmail(listExceptionEmails, sExceptionEmailBody, sExceptionEmailSubject);
		}
		
		//Return territory response to calling method
		return listShipToSiteUseLookupResponse;				
	}

	public class ShipToSiteUseLookupResponse {
		//Inner class used for deserializing web service responses for ship to site use records
		public String SiteUseId {get; set;}
		public String LocationName {get; set;}
		public String CustomerName {get; set;}
		public String CustomerNumber {get; set;}
		public String Address1 {get; set;}
		public String CityStateZipCountry {get; set;}
		public String Address2 {get; set;}
		public String Address3 {get; set;}
		public String Address4 {get; set;}
		public String AccountDescription {get; set;}
		public String PartyNumber {get; set;}
	}	
}