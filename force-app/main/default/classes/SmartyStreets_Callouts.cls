public with sharing class SmartyStreets_Callouts {
	public static List<SmartyStreets_Validation_Response> makeSmartyStreetsCallout(List<SmartyStreets_Validation_Request> lstRequests) {
		List<SmartyStreets_Validation_Response> lstResponses = new List<SmartyStreets_Validation_Response>();
		String sJSONRequest = '';
		String sJSONResponse = '';
		SmartyStreets_API__c oAPIDetails = new SmartyStreets_API__c();		
		Http oHTTP = new Http();
		HttpRequest oHTTPRequest = new HttpRequest();
		HTTPResponse oHTTPResponse = new HttpResponse();

		//Retrieve web service details from custom setting
		oAPIDetails = [select auth_id__c, auth_token__c from SmartyStreets_API__c where Name = 'SeedUnitAddressVerify'];

		// Build the REST endpoint URL string
		String sURL = 'https://api.smartystreets.com/street-address/?auth-id=' + EncodingUtil.urlEncode(oAPIDetails.auth_id__c,'UTF-8') + '&auth-token=' + EncodingUtil.urlEncode(oAPIDetails.auth_token__c,'UTF-8');

		//Serialize and list of validation requests
		sJSONRequest = JSON.serialize(lstRequests);
		oHTTPRequest.setEndpoint(sURL);
		oHTTPRequest.setMethod('POST');
		oHTTPRequest.setTimeout(120000);
		oHTTPRequest.setHeader('Content-Length', String.valueOf(sJSONRequest.length()));
		oHTTPRequest.setBody(sJSONRequest);

		try{
			/*if(Test.isRunningTest()){
				String strResBody;
				HttpResponse res = new HttpResponse();
				strResBody = '[{"input_id":"0010n00000fAmTTAA0","input_index":0,"candidate_index":0,"delivery_line_1":"11487 Valley View Rd","last_line":"Eden Prairie MN 55344-3617","delivery_point_barcode":"553443617877","components":{"primary_number":"11487","street_name":"Valley View","street_suffix":"Rd","city_name":"Eden Prairie","state_abbreviation":"MN","zipcode":"55344","plus4_code":"3617","delivery_point":"87","delivery_point_check_digit":"7"},"metadata":{"record_type":"S","zip_type":"Standard","county_fips":"27053","county_name":"Hennepin","carrier_route":"C012","congressional_district":"03","rdi":"Commercial","elot_sequence":"0130","elot_sort":"D","latitude":44.86858,"longitude":-93.42388,"precision":"Zip9","time_zone":"Central","utc_offset":-6,"dst":true},"analysis":{"dpv_match_code":"Y","dpv_footnotes":"AABB","dpv_cmra":"N","dpv_vacant":"N","active":"Y","footnotes":"N#"}}]';
				res.setStatus('OK');
				res.setStatusCode(200);
				res.setBody(strResBody);
				oHTTPResponse = res;
			}
			else{
			*/
				oHTTPResponse = oHTTP.send(oHTTPRequest);
			//}
			sJSONResponse = oHTTPResponse.getBody();				

			system.debug('SMARTYSTREETS RESPONSE CODE: ' + oHTTPResponse.getStatusCode());
			system.debug('SMARTYSTREETS RESPONSE BODY: ' + sJSONResponse);

			if(oHTTPResponse.getStatusCode()==200){
				System.debug('sJSONResponse: ' + sJSONResponse);
				lstResponses = (List<SmartyStreets_Validation_Response>) JSON.deserialize(sJSONResponse, List<SmartyStreets_Validation_Response>.class);
				System.debug('lstResponses: ' + lstResponses);
			}
		}
		catch (Exception oException) {
			lstResponses = null;
		}
		return lstResponses;
	}
}