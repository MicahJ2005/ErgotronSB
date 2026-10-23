@isTest 
public class Test_MOCK_ServiceCalls {

	public static String strResponseInject = '';
	public static Integer intResponseCodeInject = 200;

	public class generalCalloutMock implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest req) {

			// Response Router
			String strEndpoint = req.getEndpoint();

			HttpResponse res = new HttpResponse();

			if(strEndpoint.contains('smartystreets')) {
				res = respond_SmartyStreets(req);
			}
			if(strEndpoint.contains('googlerecaptcha')) {
				res = respond_GoogleRecaptcha(req);
			}
			if(strEndpoint.contains('OracleWO')) {
				res = respond_OracleWO(req);
			}
			if(strEndpoint.contains('OracleATP-WebService')) {
				res = respond_OracleATP(req);
			}
			if(strEndpoint.contains('OracleBOM-WebService')) {
				res = respond_OracleBOM(req);
			}
			if(strEndpoint.contains('CreateOrder-JSON-WEB')) { //old Informatica process name
				res = respond_OracleICRTOrder(req);
			}
			if(strEndpoint.contains('CreateOrderSalesforceToOracleWrapper')) { //new Informatica process name
				res = respond_OracleICRTOrder(req);
			}

            if(strEndpoint.contains('CreateCustomer-JSON-WEB-CLW')) {
				res = respond_OracleICRTOrder(req);
			}
            if(strEndpoint.contains('blueprint')) {
                system.debug('Endpoint URL: ' + strEndpoint);
				res = respond_KinnexDevice(req);
			}

			return res;

		}
	}

	private static HttpResponse respond_OracleICRTOrder(HttpRequest req) {
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setBody(Test_MOCK_ServiceCalls.strResponseInject);
		res.setStatusCode(intResponseCodeInject);
		return res;
	}

	private static HttpResponse respond_OracleBOM(HttpRequest req) {
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setBody('{"bomresult":[{"PATH":"509-407-053-00","ITEM_STATUS":"30-ACTIVE","INVENTORY_ITEM_ID":"2826518","COMP_ITEM":"509-407-053-00","COMP_QTY":"1","BOM_LEVEL":"  1","COMP_ITEM_TYPE":"E-COMP","ASSEMBLY_DESCR":"Laptop standoff assembly","COMP_ITEM_STATUS":"30-ACTIVE","ASSEMBLY_ITEM":"655-148-053-00","ORGANIZATION_ID":"701","COMP_ITEM_DESCR":"BRACKET, LAPTOP STAND-OFF, LIGHT GREY"},{"PATH":"774-071-053-00","ITEM_STATUS":"30-ACTIVE","INVENTORY_ITEM_ID":"2826521","COMP_ITEM":"774-071-053-00","COMP_QTY":"1","BOM_LEVEL":"  1","COMP_ITEM_TYPE":"E-COMP","ASSEMBLY_DESCR":"Laptop standoff assembly","COMP_ITEM_STATUS":"30-ACTIVE","ASSEMBLY_ITEM":"655-148-053-00","ORGANIZATION_ID":"701","COMP_ITEM_DESCR":"BUMPER, LAPTOP SUPPORT, SV4X CARTS"}]}');
		res.setStatusCode(intResponseCodeInject);
		return res;
	}

	private static HttpResponse respond_OracleATP(HttpRequest req) {
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setBody('{"atpresult":[{"SALES_QTY":"0","ORGANIZATION_CODE":"CN1","SUPPLY_QTY_DATE":"","SUPPLY_QTY_BYW":"0","ITEM_DESCRIPTION":"Laptop standoff assembly","ITEM_NUMBER":"655-148-053-00","NETOH":"0","SUPPLY_QTY":"0"},{"SALES_QTY":"0","ORGANIZATION_CODE":"US1","SUPPLY_QTY_DATE":"","SUPPLY_QTY_BYW":"0","ITEM_DESCRIPTION":"Laptop standoff assembly","ITEM_NUMBER":"655-148-053-00","NETOH":"0","SUPPLY_QTY":"0"},{"SALES_QTY":"0","ORGANIZATION_CODE":"EU1","SUPPLY_QTY_DATE":"","SUPPLY_QTY_BYW":"0","ITEM_DESCRIPTION":"Laptop standoff assembly","ITEM_NUMBER":"655-148-053-00","NETOH":"0","SUPPLY_QTY":"0"}]}');
		res.setStatusCode(intResponseCodeInject);
		return res;
	}

	private static HttpResponse respond_OracleWO(HttpRequest req) {
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setBody('{"woresult":[{"CURRENT_REV":"--A","ENG_PART_TYPE":"SUBASSY+HDWR","INVENTORY_ITEM_ID":"2562","ORGANIZATION_CODE":"US1","DESCRIPTION":"KIT,END CAP PVT COVER,APG","ITEM_CREATION_DATE":"2004-07-16T03:13:47Z","WO_ITEM_REVISION":"--A","WO_NUMBER":"12345","WIP_ENTITY_ID":"156388","REV_A_IMPLEMENT_DATE":"2003-05-17T05:00:00Z","ASSEMBLY_ITEM":"696-831-099-00","DATE_COMPLETED":"2005-01-04T18:06:50Z"}]}');
		res.setStatusCode(intResponseCodeInject);
		return res;
	}

	private static HttpResponse respond_GoogleRecaptcha(HttpRequest req) {
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setBody('{"success":"true"}');
		res.setStatusCode(intResponseCodeInject);
		return res;
	}

	private static HttpResponse respond_SmartyStreets(HttpRequest req) {
		List<SmartyStreets_Validation_Request> lstRequest = (List<SmartyStreets_Validation_Request>)JSON.deserialize(req.getBody(), List<SmartyStreets_Validation_Request>.class);
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
		res.setStatusCode(intResponseCodeInject);
		return res;
	}
    
    private static HttpResponse respond_KinnexDevice(HttpRequest req) {
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setBody('{"devices":{"results":[{"created":"2017-11-21T14:28:10.000Z","createdById":"53ab3ebb-deae-4eef-9f56-475388b5c804","lastModified":"2019-03-06T00:22:04.000Z","lastModifiedById":"3b36f566-33ec-42c1-88c0-fa943104b0be","version":"X3","id":"05b3a35c-9dea-4135-ab1d-58e528f1a0cd","accountId":"184af8cb-03b6-4f0f-b6d3-85dc22f6def8","deviceTemplateId":"c712df42-b525-4718-a0b4-18467699db88","organizationId":"84421ae1-bf8f-48ea-86b7-5028fa44b4a9","serialNumber":"SV5X123","provisioningState":"activated","firmwareVersion":null,"latitude":null,"longitude":null,"connected":false,"lastConnected":null,"externalIp":null,"geoIpLatitude":null,"geoIpLongitude":null,"reverseDns":null,"name":null,"purchaseDate":null,"location":null,"deviceVersion":null,"channels":[{"channelTemplateId":"fd6911db-ba37-4fe4-97c7-f1368b035197","channelTemplateName":"_rejected","flags":{"deviceUpdatable":true,"timeSeries":false},"channel":"xi/blue/v1/184af8cb-03b6-4f0f-b6d3-85dc22f6def8/d/05b3a35c-9dea-4135-ab1d-58e528f1a0cd/_rejected","kinesisBridgeDelivery":0,"serviceTopic":true,"persistenceType":"simple"},{"channelTemplateId":"4d48c34c-83df-4ee4-91df-1155fc813269","channelTemplateName":"_set/fields","flags":{"deviceUpdatable":true,"timeSeries":false},"channel":"xi/blue/v1/184af8cb-03b6-4f0f-b6d3-85dc22f6def8/d/05b3a35c-9dea-4135-ab1d-58e528f1a0cd/_set/fields","kinesisBridgeDelivery":0,"serviceTopic":true,"persistenceType":"simple"},{"channelTemplateId":"da399208-4bb1-4664-9e38-e56adfb71730","channelTemplateName":"_updates/fields","flags":{"deviceUpdatable":true,"timeSeries":false},"channel":"xi/blue/v1/184af8cb-03b6-4f0f-b6d3-85dc22f6def8/d/05b3a35c-9dea-4135-ab1d-58e528f1a0cd/_updates/fields","kinesisBridgeDelivery":0,"serviceTopic":true,"persistenceType":"simple"},{"channelTemplateId":"e54f4951-d877-45d5-96b2-0d55e608af92","channelTemplateName":"group-settings","flags":{"deviceUpdatable":true,"timeSeries":false},"channel":"xi/blue/v1/184af8cb-03b6-4f0f-b6d3-85dc22f6def8/d/05b3a35c-9dea-4135-ab1d-58e528f1a0cd/group-settings","kinesisBridgeDelivery":0,"serviceTopic":false,"persistenceType":"simple"},{"channelTemplateId":"155c8ec0-b236-41d6-90fb-3f980854c9a9","channelTemplateName":"pin","flags":{"deviceUpdatable":true,"timeSeries":false},"channel":"xi/blue/v1/184af8cb-03b6-4f0f-b6d3-85dc22f6def8/d/05b3a35c-9dea-4135-ab1d-58e528f1a0cd/pin","kinesisBridgeDelivery":2,"serviceTopic":false,"persistenceType":"simple"},{"channelTemplateId":"650d3bc3-8a10-4ad1-91db-64ac19ddb170","channelTemplateName":"unlock","flags":{"deviceUpdatable":true,"timeSeries":false},"channel":"xi/blue/v1/184af8cb-03b6-4f0f-b6d3-85dc22f6def8/d/05b3a35c-9dea-4135-ab1d-58e528f1a0cd/unlock","kinesisBridgeDelivery":0,"serviceTopic":false,"persistenceType":"simple"},{"channelTemplateId":"98e5bbef-1caf-4ef4-9046-356b3306a5c6","channelTemplateName":"diagnostics","flags":{"deviceUpdatable":true,"timeSeries":true},"channel":"xi/blue/v1/184af8cb-03b6-4f0f-b6d3-85dc22f6def8/d/05b3a35c-9dea-4135-ab1d-58e528f1a0cd/diagnostics","kinesisBridgeDelivery":0,"serviceTopic":false,"persistenceType":"timeSeries"},{"channelTemplateId":"cd6321db-473d-4777-b777-f587eeeaee16","channelTemplateName":"battery-serial","flags":{"deviceUpdatable":true,"timeSeries":false},"channel":"xi/blue/v1/184af8cb-03b6-4f0f-b6d3-85dc22f6def8/d/05b3a35c-9dea-4135-ab1d-58e528f1a0cd/battery-serial","kinesisBridgeDelivery":2,"serviceTopic":false,"persistenceType":"simple"},{"channelTemplateId":"660d1743-0a4a-456a-addc-069751eefd2f","channelTemplateName":"battery-id","flags":{"deviceUpdatable":true,"timeSeries":false},"channel":"xi/blue/v1/184af8cb-03b6-4f0f-b6d3-85dc22f6def8/d/05b3a35c-9dea-4135-ab1d-58e528f1a0cd/battery-id","kinesisBridgeDelivery":0,"serviceTopic":false,"persistenceType":"simple"},{"channelTemplateId":"54a433e9-7cd1-4873-b590-9f4674cbe64d","channelTemplateName":"_log","flags":{"deviceUpdatable":true,"timeSeries":false},"channel":"xi/blue/v1/184af8cb-03b6-4f0f-b6d3-85dc22f6def8/d/05b3a35c-9dea-4135-ab1d-58e528f1a0cd/_log","kinesisBridgeDelivery":0,"serviceTopic":true,"persistenceType":"simple"}]}],"meta":{"count":1,"page":1,"pageSize":10,"sortOrder":"asc"}}}');
		res.setStatusCode(intResponseCodeInject);
		return res;
	}
    
}