@isTest 
public class Utility_SmartyStreets_MOCK {

	@isTest
	private static void testName() {
		Test.setMock(HttpCalloutMock.class, new Utility_SmartyStreets_MOCK.SmartyStreetsHTTPCalloutMock());
	}

	public class SmartyStreetsHTTPCalloutMock implements HttpCalloutMock {
		// Implement this interface method
		public HTTPResponse respond(HTTPRequest req) {
			// Create a fake response

			System.debug(req);
			System.debug(req.getBody());
			String strBody = req.getBody();

			List<SmartyStreets_Validation_Request> lstRequest = (List<SmartyStreets_Validation_Request>)JSON.deserialize(strBody, List<SmartyStreets_Validation_Request>.class);
			List<SmartyStreets_Validation_Response> lstResponse = new List<SmartyStreets_Validation_Response>();

			for(SmartyStreets_Validation_Request objReq : lstRequest) {
				SmartyStreets_Validation_Response objValidation = new SmartyStreets_Validation_Response();
				objValidation.input_id = objReq.input_id;
				objValidation.delivery_line_1 = objReq.street;
				objValidation.delivery_line_2 = objReq.street2;

				objValidation.components = new SmartyStreets_Validation_Response.Components();
				objValidation.components.city_name = objReq.city;
				objValidation.components.state_abbreviation = 'MN';
				objValidation.components.zipcode = objReq.zipcode;

				objValidation.metadata = new SmartyStreets_Validation_Response.Metadata();
				objValidation.metadata.county_name = 'Confusion';

				lstResponse.add(objValidation);
			}

			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');
			res.setBody(JSON.serialize(lstResponse));
			res.setStatusCode(200);
			return res;
		}
	}
}