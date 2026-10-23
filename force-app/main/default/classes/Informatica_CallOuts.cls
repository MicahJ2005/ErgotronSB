public class Informatica_CallOuts {
	public static String httpCallout(String strEndPt, String strParam){
		String endpoint = null;
		String strJSON = null;
		HttpResponse response = null;
		HttpRequest request = null;
		Http httpProtocol = null;
		httpProtocol = new Http();
		request = new HttpRequest();
		Informatica_CallOut__mdt ic = new Informatica_CallOut__mdt();
		ic = [SELECT Id, MasterLabel, Callout_URL__c FROM Informatica_CallOut__mdt WHERE MasterLabel = :strEndPt LIMIT 1];
		endpoint = ic.Callout_URL__c;
		endpoint += strParam;
		request.setEndpoint(endpoint);
		request.setMethod('GET');
		request.setTimeout(120000);
		try{
			//if(Test.isRunningTest()){
				//String strResBody;
				//HttpResponse res = new HttpResponse();
				//if(strEndPt == 'ATP Rest Callout'){
					//strResBody = '{"atpresult":[{"SALES_QTY":"0","ORGANIZATION_CODE":"CN1","SUPPLY_QTY_DATE":"","SUPPLY_QTY_BYW":"0","ITEM_DESCRIPTION":"Laptop standoff assembly","ITEM_NUMBER":"655-148-053-00","NETOH":"0","SUPPLY_QTY":"0"},{"SALES_QTY":"0","ORGANIZATION_CODE":"US1","SUPPLY_QTY_DATE":"","SUPPLY_QTY_BYW":"0","ITEM_DESCRIPTION":"Laptop standoff assembly","ITEM_NUMBER":"655-148-053-00","NETOH":"0","SUPPLY_QTY":"0"},{"SALES_QTY":"0","ORGANIZATION_CODE":"EU1","SUPPLY_QTY_DATE":"","SUPPLY_QTY_BYW":"0","ITEM_DESCRIPTION":"Laptop standoff assembly","ITEM_NUMBER":"655-148-053-00","NETOH":"0","SUPPLY_QTY":"0"}]}';
				//}
				//else if(strEndPt == 'BOM RestCallout'){
					//strResBody = '{"bomresult":[{"PATH":"509-407-053-00","ITEM_STATUS":"30-ACTIVE","INVENTORY_ITEM_ID":"2826518","COMP_ITEM":"509-407-053-00","COMP_QTY":"1","BOM_LEVEL":"  1","COMP_ITEM_TYPE":"E-COMP","ASSEMBLY_DESCR":"Laptop standoff assembly","COMP_ITEM_STATUS":"30-ACTIVE","ASSEMBLY_ITEM":"655-148-053-00","ORGANIZATION_ID":"701","COMP_ITEM_DESCR":"BRACKET, LAPTOP STAND-OFF, LIGHT GREY"},{"PATH":"774-071-053-00","ITEM_STATUS":"30-ACTIVE","INVENTORY_ITEM_ID":"2826521","COMP_ITEM":"774-071-053-00","COMP_QTY":"1","BOM_LEVEL":"  1","COMP_ITEM_TYPE":"E-COMP","ASSEMBLY_DESCR":"Laptop standoff assembly","COMP_ITEM_STATUS":"30-ACTIVE","ASSEMBLY_ITEM":"655-148-053-00","ORGANIZATION_ID":"701","COMP_ITEM_DESCR":"BUMPER, LAPTOP SUPPORT, SV4X CARTS"}]}';
				//}
                //else if(strEndPt == 'Salesrep Callout') {
                    //strResBody = '{"x_sales_rep_name":"SKRUKRUD, MIKE","x_sales_rep_phone":"612-701-4037","x_sales_rep_email":"MSKRUKRUD@ERGOTRON.COM","x_is_manager":"N","x_multi_salesreps":"Y"}';
                //}
				//else if(strEndPt == ''){
					//strResBody = '{"out_wo":{"WO_NUMBER":"1480369","ASSEMBLY_ITEM":"YESBASGMPW4","ITEM_CREATION_DATE":"2016-12-20Z","ORGANIZATION_CODE":"OR2","WO_ITEM_REVISION":"--D","DATE_COMPLETED":"2017-11-01Z","ENG_PART_TYPE":"FG+ANTHRO YES","CURRENT_REV":"--E"},"out_message":"Success"}';
				//}
				//res.setStatus('OK');
				//res.setStatusCode(200);
				//res.setBody(strResBody);
				//response = res;
			//}
			//else{
				response = httpProtocol.send(request);
				System.debug('response: ' + response);
			//}
		}
		catch (Exception ex){
	      	system.debug(LoggingLevel.ERROR, '\n\n***Error on http request:\n' + ex);
	    }
  		if(response != null){
			strJSON = response.getBody();
		}

		return strJSON;
	}
	public static ATP_Data ATPCalloutProcess(String partNumber){
		String endpointType;
		String strJSON;
		endpointType = 'ATP Rest Callout';
		strJSON = httpCallout(endpointType, partNumber);
		if(!String.isBlank(strJSON)){
			return parseATP(strJSON);
		}
		else{
			return null;
		}
	}
	public static WO_Data WOCalloutProcess(String woNumber){
		String endpointType;
		String strJSON;
		endpointType = 'WO RestCallout';
		strJSON = httpCallout(endpointType, woNumber);
		if(!String.isBlank(strJSON)){
			return parseWO(strJSON);
		}
		else{
			return null;
		}
	}
	public static BOM_Data BOMCallout(String strParam){
		String endpointType;
		String strJSON;
		endpointType = 'BOM RestCallout';
		strJSON = httpCallout(endpointType, strParam);
		if(!String.isBlank(strJSON)){
			return parseBOM(strJSON);
		}
		else{
			return null;
		}
	}
    
    public static HelperSalesRepData SalesRepCallout(String strState, String strZip, String strCountryCode) {
        String endpointType = 'Salesrep Callout';
        String strJSON = httpCallout(endpointType, 'ip_state_code=' + strState + '&ip_postal_code=' + strZip + '&ip_country_code=' + strCountryCode);
        if(!String.isBlank(strJSON)) {
            return (HelperSalesRepData) System.JSON.deserialize(strJSON, HelperSalesRepData.class);
        } else {
            return null;
        }
    }

	public class ATP_Data {
		public List<atpresult> atpresult;
	}
	public class atpresult {
		public String SALES_QTY;
		public String ORGANIZATION_CODE;
		public String SUPPLY_QTY_DATE;
		public String SUPPLY_QTY_BYW;
		public String ITEM_DESCRIPTION;
		public String ITEM_NUMBER;
		public String QTY_AVAIL;
		public String SUPPLY_QTY;
	}
	public static ATP_Data parseATP(String json) {
		return (ATP_Data) System.JSON.deserialize(json, ATP_Data.class);
	}
	public class WO_Data {
		public List<Woresult> woresult;
	}
	public class woresult {
		public String CURRENT_REV;
		public String ENG_PART_TYPE;
		public String INVENTORY_ITEM_ID;
		public String ORGANIZATION_CODE;
		public String DESCRIPTION;
		public String ITEM_CREATION_DATE;
		public String WO_ITEM_REVISION;
		public String WO_NUMBER;
		public String REV_A_IMPLEMENT_DATE;
		public String ASSEMBLY_ITEM;
		public String DATE_COMPLETED;
	}
	public static WO_Data parseWO(String json) {
		return (WO_Data) System.JSON.deserialize(json, WO_Data.class);
	}
	public class BOM_Data {
		public List<Bomresult> bomresult;
	}
	public class Bomresult {
		public String PATH;
		public String ITEM_STATUS;
		public String INVENTORY_ITEM_ID;
		public String COMP_ITEM;
		public String COMP_QTY;
		public String BOM_LEVEL;
		public String COMP_ITEM_TYPE;
		public String ASSEMBLY_DESCR;
		public String COMP_ITEM_STATUS;
		public String ASSEMBLY_ITEM;
		public String ORGANIZATION_ID;
		public String COMP_ITEM_DESCR;
	}
	
	public static BOM_Data parseBOM(String json) {
		return (BOM_Data) System.JSON.deserialize(json, BOM_Data.class);
	}
}