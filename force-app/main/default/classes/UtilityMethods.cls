public with sharing class UtilityMethods {
/**
*   {Purpose}  �  Global Methods and Functions class for Ergotron
*
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 612-424-0032                  
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date    	Name             		Description
*   20150922  	Andy Boettcher DCS		Created
*	20190203	Andy Boettcher DCS		Added ICRT Customer Inner Class for JSON/ICRT
*   =============================================================================
*/
	public static String G_SORT_ASCENDING = 'ASC';
	public static String G_SORT_DESCENDING = 'DESC';
	public static Boolean G_bolStopSPRRecursion = false;
	
	///////////////////////////
	// GET / SET
	///////////////////////////
	public static List<Interface_Log__c> lstLogs {
		get {
			if(lstLogs == null) {
				System.Debug('RETURNING NEW LOG LIST');
				lstLogs = new List<Interface_Log__c>();
			}

			return lstLogs;	
		}
		set {
			lstLogs = value;
		}
	}

	public static Set<String> setAuditFields {
		get {
			setAuditFields = new Set<String>();
			setAuditFields.add('OWNERID');
			setAuditFields.add('ISDELETED');
			setAuditFields.add('CURRENCYISOCODE');
			setAuditFields.add('RECORDTYPEID');
			setAuditFields.add('CREATEDDATE');
			setAuditFields.add('CREATEDBYID');
			setAuditFields.add('LASTMODIFIEDDATE');
			setAuditFields.add('LASTMODIFIEDBYID');
			setAuditFields.add('SYSTEMMODSTAMP');
			setAuditFields.add('LASTVIEWEDDATE');
			setAuditFields.add('LASTREFERENCEDDATE');
			return setAuditFields;
		}
		//private set { setAuditFields = value; }
	}
	public static string getCreatableFieldsSOQL(String objectName){
        String selects = '';       
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }      
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        } 
        return 'SELECT ' + selects + ' FROM ' + objectName; 
    }

	public static Map<String, Schema.SObjectField> mapFieldsInObject(String strObjectName) {
		return Schema.getGlobalDescribe().get(strObjectName).getDescribe().fields.getMap();
	}

	public static Map<Id, SObject> objRecordData(String strObjectName, Set<Id> setRecordIds, Set<String> setBlockedFields, Map<String, String> mapSort) {

		try {
			String strQuery = 'SELECT ';

			// Construct Dynamic SOQL Fields
			for(String strField : mapFieldsInObject(strObjectName).keyset()) {
				if(!setBlockedFields.contains(strField.toUpperCase())) {
					strQuery+= strField + ', ';
				}
			}
			strQuery = strQuery.substring(0,strQuery.length()-2);

			strQuery+= ' FROM ' + strObjectName;
			
			if(setRecordIds != null) {
				strQuery+= ' WHERE Id IN :setRecordIds';
			}
			
			if(mapSort.size() > 0) {
				strQuery+= ' ORDER BY ';
				for(String strKey : mapSort.keySet()) {
					strQuery+= strKey + ' ' + mapSort.get(strKey) + ', ';
				}
				strQuery = strQuery.substring(0,strQuery.length()-2);
			}

			if(setRecordIds == null) {
				strQuery+= ' LIMIT 50';
			}

			return new Map<Id, sObject>((List<sObject>)Database.query(strQuery));	
		} catch(Exception ex) {
			System.Debug(ex);
			return new Map<Id, sObject>();
		}
		

	}

	public static Map<String, Id> MAP_RECORDTYPES(String sObjectType) {

		Map<String, Id> mapReturn = new Map<String, Id>();

		for(RecordType objRT : [SELECT Id, DeveloperName FROM RecordType WHERE IsActive = TRUE AND sObjectType = :sObjectType]) {
			mapReturn.put(objRT.DeveloperName, objRT.Id);
		}

		return mapReturn;

	}

	public static Map<String, String> MAP_CONTENTTYPES() {

		Map<String, String> mapReturn = new Map<String, String>();
		mapReturn.put('html', 'application/html');
		mapReturn.put('java', 'application/java-archive');
		mapReturn.put('js', 'application/javascript');
		mapReturn.put('doc', 'application/msword');
		mapReturn.put('docx', 'application/msword');
		mapReturn.put('pdf', 'application/pdf');
		mapReturn.put('ps', 'application/postscript');
		mapReturn.put('rtf', 'application/rtf');
		mapReturn.put('xls', 'application/vnd.ms-excel');
		mapReturn.put('xlsx', 'application/vnd.ms-excel');
		mapReturn.put('xlsm', 'application/vnd.ms-excel.sheet.macroEnabled.12');
		mapReturn.put('ppt', 'application/vnd.ms-powerpoint');
		mapReturn.put('pptx', 'application/vnd.ms-powerpoint');
		mapReturn.put('pptm', 'application/vnd.ms-powerpoint.presentation.macroEnabled.12');
		mapReturn.put('docm', 'application/vnd.ms-word.document.macroEnabled.12');
		mapReturn.put('vsd', 'application/vnd.visio');
		mapReturn.put('vsdx', 'application/vnd.visio');
		mapReturn.put('xhtml', 'application/xhtml+xml');
		mapReturn.put('xml', 'application/xml');
		mapReturn.put('zip', 'application/zip');
		mapReturn.put('aac', 'audio/x-aac');
		mapReturn.put('wma', 'audio/x-ms-wma');
		mapReturn.put('wmv', 'audio/x-ms-wmv');
		mapReturn.put('wav', 'audio/x-wav');
		mapReturn.put('bmp', 'image/bmp');
		mapReturn.put('gif', 'image/gif');
		mapReturn.put('jpg', 'image/jpeg');
		mapReturn.put('jpeg', 'image/jpeg');
		mapReturn.put('png', 'image/png');
		mapReturn.put('svg', 'image/svg+xml');
		mapReturn.put('tiff', 'image/tiff');
		mapReturn.put('dwg', 'image/vnd.dwg');
		mapReturn.put('psd', 'image/x-photoshop');
		mapReturn.put('msg', 'message/rfc822');
		mapReturn.put('css', 'text/css');
		mapReturn.put('csv', 'text/csv');
		mapReturn.put('html', 'text/html');
		mapReturn.put('txt', 'text/plain');
		mapReturn.put('rtf', 'text/rtf');
		mapReturn.put('mp4', 'video/mp4');
		mapReturn.put('mpeg', 'video/mpeg');
		mapReturn.put('avi', 'video/quicktime');
		mapReturn.put('m4v', 'video/x-m4v');
		mapReturn.put('asf', 'video/x-ms-asf');
		mapReturn.put('wmv', 'video/x-ms-wmv');

		return mapReturn;


	}
	
	///////////////////////////
	// Action Methods
	///////////////////////////
	public static void addToLog(String strSourceProcess, String strInformation, String strResult) {
		System.Debug('ADDING LOG ENTRY');

		UtilityMethods.lstLogs.add(
			new Interface_Log__c(
				Source_Process__c=strSourceProcess, 
				Logging_Information__c=strInformation, 
				Condition__c=strResult
			)
		);

		System.Debug('LOG SIZE - ' + UtilityMethods.lstLogs.size());
	}

	public static void commitLogs() {
		System.Debug('COMMITTING LOGS CHECK - ' + UtilityMethods.lstLogs.size());
		if(UtilityMethods.lstLogs.size() > 0) {
			//insert lstLogs;
		}
	}

	/**
	 * Calls out to the REST API to describe a layout by object api name and the associated record type.
	 * Loops through the fields in the first section (and first column) and grabs the fields in the order they 
	 * are on the layout.  Used by the Comparison chart (both web / javascript and XLS file formats)
	 * @param  sObjectApiName The api name of the sobject (and therefore its pagelayout) to fetch
	 * @param  recordTypeId   RecordType associated with the particular layout
	 * @return                List of strings of field api names, in order according to the layout.
	 */
	public static List<String> getFieldsFromPageLayout(String sObjectApiName,Id recordTypeId){
		Http h = new Http();
        HttpRequest layoutReq = new HttpRequest();
        String describeUrl = '/services/data/v35.0/sobjects/' + sObjectApiName + '/describe/layouts/' + recordTypeId;
        layoutReq.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + describeUrl);
        layoutReq.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
        layoutReq.setHeader('Content-Type', 'application/json');
        layoutReq.setMethod('GET');
        HttpResponse layoutResponse = h.send(layoutReq);
        LayoutDescribeResult ldr = (LayoutDescribeResult)JSON.deserialize(layoutResponse.getBody(),LayoutDescribeResult.class);
        List<String> fields = new List<String>();
        for(LayoutDescribeResult.LayoutRows lr : ldr.detailLayoutSections.get(0).layoutRows){
        	fields.add(lr.layoutItems.get(0).layoutComponents.get(0).value);
        }
        return fields;
	}

	public static String sanitizeStringInput(String strInput) {

		String strOutput = strInput;

		if(String.isBlank(strInput) || strInput == 'null') {
			strOutput = '';
		}

		return strOutput;

	}

	///////////////////////////
	// Inner / Helper Classes
	///////////////////////////

	public class oracleNewCustomerWrapper {
		public List<UtilityMethods.oracleNewCustomer> customers {get;set;}
		public oracleNewCustomerWrapper() {
			customers = new List<UtilityMethods.oracleNewCustomer>();
		}
	}

	public class oracleNewCustomer {
		public String CUST_INFO_REF {get;set;}
		public String CUST_SOURCE {get;set;}
		public String SHIPTO_PARTY_NAME {get;set;}
		public String SHIPTO_PARTY_ID {get;set;}
		public String SHIPTO_PARTY_INFO_REF {get;set;}
		public String SHIPTO_CUSTOMER_ID {get;set;}
		public String SHIPTO_CUSTOMER_INFO_REF {get;set;}
		public String SHIPTO_CUSTOMER_NAME {get;set;}
		public String SHIPTO_ADDRESS1 {get;set;}
		public String SHIPTO_ADDRESS2 {get;set;}
		public String SHIPTO_ADDRESS3 {get;set;}
		public String SHIPTO_ADDRESS4 {get;set;}
		public String SHIPTO_COUNTRY {get;set;}
		public String SHIPTO_CITY {get;set;}
		public String SHIPTO_STATE {get;set;}
		public String SHIPTO_PROVINCE {get;set;}
		public String SHIPTO_POSTAL_CODE {get;set;}
		public String SHIPTO_COUNTY {get;set;}
		public String SHIPTO_REGION {get;set;}
		public String SHIP_TO_USE_ID {get;set;}
		public String SHIP_TO_SITE_ID {get;set;}
		public String SHIPTO_ADDRESS_INFO_REF {get;set;}
		public String BILLTO_PARTY_NAME {get;set;}
		public String BILLTO_PARTY_ID {get;set;}
		public String BILLTO_PARTY_INFO_REF {get;set;}
		public String BILLTO_CUSTOMER_ID {get;set;}
		public String BILLTO_CUSTOMER_INFO_REF {get;set;}
		public String BILLTO_CUSTOMER_NAME {get;set;}
		public String BILLTO_ADDRESS1 {get;set;}
		public String BILLTO_ADDRESS2 {get;set;}
		public String BILLTO_ADDRESS3 {get;set;}
		public String BILLTO_ADDRESS4 {get;set;}
		public String BILLTO_COUNTRY {get;set;}
		public String BILLTO_CITY {get;set;}
		public String BILLTO_STATE {get;set;}
		public String BILLTO_PROVINCE {get;set;}
		public String BILLTO_POSTAL_CODE {get;set;}
		public String BILLTO_COUNTY {get;set;}
		public String BILLTO_REGION {get;set;}
		public String BILL_TO_USE_ID {get;set;}
		public String BILL_TO_SITE_ID {get;set;}
		public String BILLTO_ADDRESS_INFO_REF {get;set;}
		public String CONTACT_ROLE_ID {get;set;}
		public String CONTACT_ID {get;set;}
		public String CONTACT_INFO_REF {get;set;}
		public String PERSON_FIRST_NAME {get;set;}
		public String PERSON_LAST_NAME {get;set;}
		public String EMAIL_ADDRESS {get;set;}
		public String PHONE_NUMBER {get;set;}
		public String CREATED_BY {get;set;}
		public String PROCESS_STATUS {get;set;}

		public oracleNewCustomer() { }
	}
}