@IsTest
public class Utility_CreateICRTOracleParty_Test  {

	@TestSetup
	private static void setupTestData() {
		SmartyStreets_API__c ss = new SmartyStreets_API__c();
			ss.Name = 'SeedUnitAddressVerify';
			ss.auth_id__c = 'adsmfqmwepm09daasd';
			ss.auth_token__c = '23240kfir8fj8f8';
		insert ss;

	}

	@isTest
	private static void sendICRTCustomerToOracleSUCCESS() {

		Test.setMock(HttpCalloutMock.class, new Test_MOCK_ServiceCalls.generalCalloutMock());

		Integer intTest = 999;
		Account objParty = new Account(
			Name='Test Party' + intTest,
			RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType='Account' AND DeveloperName = 'Party'].Id
		);
		insert objParty;

		Account objCustomer = new Account(
			Name='Test Customer' + intTest,
			RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType='Account' AND DeveloperName = 'Customer_Organization'].Id,
			ParentId = objParty.Id
		);
		insert objCustomer;

		Account objSite = new Account(
			Name='Test Site' + intTest,
			RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType='Account' AND DeveloperName = 'Site'].Id,
			ParentId = objCustomer.Id,
			ShippingStreet = '1181 Trapp Rd',
			ShippingCity = 'Eagan',
			ShippingState = 'Minnesota',
			ShippingStateCode = 'MN',
			ShippingCountry = 'United States',
			ShippingCountryCode = 'US',
			ShippingPostalCode = '55121',
			BillingStreet = '1181 Trapp Rd',
			BillingCity = 'Eagan',
			BillingState = 'Minnesota',
			BillingStateCode = 'MN',
			BillingCountry = 'United States',
			BillingCountryCode = 'US',
			BillingPostalCode = '55121'
		);
		insert objSite;

		//Account objSiteICRT = [SELECT 
								//Id, 
								//Name, 
								//ParentId, 
								//ShippingStreet, 
								//ShippingCity, 
								//ShippingStateCode, 
								//ShippingPostalCode, 
								//ShippingCountryCode, 
								//BillingStreet, 
								//BillingCity, 
								//BillingStateCode, 
								//BillingPostalCode, 
								//BillingCountryCode, 
								//Oracle_SiteShipToUseId__c, 
								//Oracle_SiteBillToUseId__c, 
								//Oracle_Site_Id__c 
							//FROM Account WHERE Id = :objSite.Id];


		String strResponse = '';
		strResponse = '{"return_cust_results":{"SHIPTO_COUNTY":"SUFFOLK","PROCESS_MESSAGE":"","PRICE_LIST":"","SHIPTO_CUSTOMER_ID":"13582395",';
		strResponse = strResponse + '"BILLTO_PARTY_ID":"21617334","BILL_TO_SITE_ID":"554680","SHIPTO_PARTY_NAME":"908 DEVICES","LAST_UPDATE_DATE":"",';
		strResponse = strResponse + '"BILLTO_CITY":"BOSTON","EMAIL_ADDRESS":"brendan0powers@gmail.com","SHIPTO_CITY":"BOSTON","PERSON_FIRST_NAME":"BRENDAN","CREATED_BY":"1050",';
		strResponse = strResponse + '"LAST_UPDATED_BY":"","PROCESS_STATUS":"PENDING","ORDER_DATE":"","WAREHOUSE":"","SHIPTO_REGION":"Americas","RETURN_REASON":"","PRICE_LIST_ID":"",';
		strResponse = strResponse + '"CREATION_DATE":"","BILLTO_CUSTOMER_NAME":"908 DEVICES","ORDER_INFO_REF":"","BILLTO_COUNTRY":"US","BILLTO_ADDRESS3":"27 DRYDOCK AVE",';
		strResponse = strResponse + '"SHIP_TO_SITE_ID":"554680","BILLTO_ADDRESS4":"","SHIPTO_PARTY_ID":"21617334","BILLTO_ADDRESS1":"27 DRYDOCK AVE",';
		strResponse = strResponse + '"BILLTO_PARTY_INFO_REF":"' + objParty.Id + '","BILLTO_ADDRESS2":"","SHIPMENT_PRIORITY":"false","SHIP_TO_USE_ID":"746688",';
		strResponse = strResponse + '"BILLTO_POSTAL_CODE":"2210","PHONE_NUMBER":"603 762-4336","BILLTO_COUNTY":"SUFFOLK","SHIPTO_POSTAL_CODE":"2210","BILLTO_PARTY_NAME":"908 DEVICES",';
		strResponse = strResponse + '"BILLTO_CUSTOMER_ID":"13582395","BILLTO_ADDRESS_INFO_REF":"' + objSite.Id + '","NOTES":"","BILLTO_STATE":"MA","PAYMENT_TERMS":"",';
		strResponse = strResponse + '"BILLTO_PROVINCE":"","SHIPTO_CUSTOMER_INFO_REF":"' + objCustomer.Id + '","ORDER_TYPE_ID":"1067","SHIPTO_COUNTRY":"US",';
		strResponse = strResponse + '"SHIPTO_ADDRESS1":"27 DRYDOCK AVE","SHIPTO_ADDRESS2":"","SHIPTO_ADDRESS3":"27 DRYDOCK AVE","CUSTOMER_PO_NO":"UNKNOWN",';
		strResponse = strResponse + '"SHIPTO_CUSTOMER_NAME":"908 DEVICES","SHIPTO_ADDRESS4":"","ORDER_TYPE":"","SHIPTO_ADDRESS_INFO_REF":"' + objSite.Id + '",';
		strResponse = strResponse + '"SALES_REP_ID":"","SHIPTO_STATE":"MA","BILLTO_CUSTOMER_INFO_REF":"' + objCustomer.Id + '","SHIPTO_PROVINCE":"",';
		strResponse = strResponse + '"BILL_TO_USE_ID":"746690","PERSON_LAST_NAME":"POWERS","ORDER_SOURCE":"salesforce.com","LINES_COUNT":"1","CONTACT_ROLE_ID":"19535449",';
		strResponse = strResponse + '"CONTACT_ID":"21292171","CONTACT_INFO_REF":"","SHIPTO_PARTY_INFO_REF":"' + objParty.Id + '"}}';

		Test_MOCK_ServiceCalls.strResponseInject = strResponse;

		// Send Ids through Invocable
		List<Id> lstSendIds = new List<Id>();
		lstSendIds.add(objSite.Id);
		//Utility_CreateICRTOracleParty.sendICRTCreateParty(JSON.serialize(objSiteICRT));

		Test.startTest(); 
			Utility_CreateICRTOracleParty.flowCreateParty(lstSendIds);
		Test.stopTest();

	}

	@isTest
	private static void sendICRTCustomerToOracleFAIL() {

		Test.setMock(HttpCalloutMock.class, new Test_MOCK_ServiceCalls.generalCalloutMock());

		Integer intTest = 999;
		Account objParty = new Account(
			Name='Test Party' + intTest,
			RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType='Account' AND DeveloperName = 'Party'].Id
		);
		insert objParty;

		Account objCustomer = new Account(
			Name='Test Customer' + intTest,
			RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType='Account' AND DeveloperName = 'Customer_Organization'].Id,
			ParentId = objParty.Id
		);
		insert objCustomer;

		Account objSite = new Account(
			Name='Test Site' + intTest,
			RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType='Account' AND DeveloperName = 'Site'].Id,
			ParentId = objCustomer.Id,
			ShippingStreet = '1181 Trapp Rd',
			ShippingCity = 'Eagan',
			ShippingState = 'Minnesota',
			ShippingStateCode = 'MN',
			ShippingCountry = 'United States',
			ShippingCountryCode = 'US',
			ShippingPostalCode = '55121',
			BillingStreet = '1181 Trapp Rd',
			BillingCity = 'Eagan',
			BillingState = 'Minnesota',
			BillingStateCode = 'MN',
			BillingCountry = 'United States',
			BillingCountryCode = 'US',
			BillingPostalCode = '55121'
		);
		insert objSite;

		Account objSiteICRT = [SELECT 
								Id, 
								Name, 
								ParentId, 
								ShippingStreet, 
								ShippingCity, 
								ShippingStateCode, 
								ShippingPostalCode, 
								ShippingCountryCode, 
								BillingStreet, 
								BillingCity, 
								BillingStateCode, 
								BillingPostalCode, 
								BillingCountryCode, 
								Oracle_SiteShipToUseId__c, 
								Oracle_SiteBillToUseId__c, 
								Oracle_Site_Id__c 
							FROM Account WHERE Id = :objSite.Id];


		String strResponse = '';
		strResponse = '{"error":{"code":500,"detail":{"reason":"ORA-00001: unique constraint (ERGO_CUS.SYS_C003491187) violated\n","code":"dataAccessFault","details":"ORA-00001: unique constraint (ERGO_CUS.SYS_C003491187) violated\n"},"message":"ORA-00001: unique constraint (ERGO_CUS.SYS_C003491187) violated\n"}}';
		Test_MOCK_ServiceCalls.intResponseCodeInject = 500;

		Test_MOCK_ServiceCalls.strResponseInject = strResponse;

		Test.startTest(); 
			Utility_CreateICRTOracleParty.sendICRTCreateParty(JSON.serialize(objSiteICRT));
		Test.stopTest();

	}

}