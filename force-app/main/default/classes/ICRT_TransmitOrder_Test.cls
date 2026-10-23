@isTest 
private class ICRT_TransmitOrder_Test {

	@TestSetup
	private static void setupTestData() {
		SmartyStreets_API__c ss = new SmartyStreets_API__c();
			ss.Name = 'SeedUnitAddressVerify';
			ss.auth_id__c = 'adsmfqmwepm09daasd';
			ss.auth_token__c = '23240kfir8fj8f8';
		insert ss;

		Account acctSite = new Account(
			Name='Test Site',
			RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId(),
			BillingStreet='1181 Trapp Road', 
            BillingCity='Eagan', 
            BillingState='Minnesota',
			BillingStateCode = 'MN', 
            BillingPostalCode='55121', 
            BillingCountry='United States', 
            BillingCountryCode='US',
			IsAddressValidated__c=true,
			Process_Account_Hierarchy__c=true,
			Site_Deduplication__c='yes'	
		);
		
		insert acctSite;
		// Create a second site account to test submitting orders different bill-to and ship-to sites
		Account acctSite2 = new Account(
			Name='Test Site2',
			RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId(),
			BillingStreet='1183 Trapp Road', 
            BillingCity='Eagan', 
            BillingState='Minnesota',
			BillingStateCode = 'MN', 
            BillingPostalCode='55121', 
            BillingCountry='United States', 
            BillingCountryCode='US',
			IsAddressValidated__c=true,
			Process_Account_Hierarchy__c=true,
			Site_Deduplication__c='yes'	
		);
		
		insert acctSite2;

		Contact objContact = new Contact(
			FirstName = 'First',
			LastName = 'Last',
			Email = 'me@you.com',
			AccountId = acctSite.Id
		);

		insert objContact;
	}

	@isTest
	private static void sendICRTOrderToOracle() {

		Test.setMock(HttpCalloutMock.class, new Test_MOCK_ServiceCalls.generalCalloutMock());

		Product2 objProduct = Test_Environment_Utility.createInsertProduct();

		Account objAcctParty = [SELECT Id FROM Account WHERE RecordTypeId = :Schema.SObjectType.Account.getRecordTypeInfosByName().get('Party').getRecordTypeId() and Name = 'Test Site' LIMIT 1];
		Account objAcctCustomer = [SELECT Id FROM Account WHERE RecordTypeId = :Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer - Organization').getRecordTypeId() and Name = 'Test Site' LIMIT 1];
		Account objAcctSite = [SELECT Id FROM Account WHERE RecordTypeId = :Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId() and Name = 'Test Site' LIMIT 1];
		Contact objContact = [SELECT Id FROM Contact LIMIT 1];

		Sales_Order__c objSO = new Sales_Order__c(
            Bill_To_Customer__c = objAcctSite.Id,
            Ship_To_Customer__c = objAcctSite.Id,
            Customer_PO_Number__c = '0000001',
            Ship_To_Contact__c = objContact.Id,
            Order_Type_Id__c = 'TRF',
            Notes__c = 'TEST NOTES',
            Sales_Rep__c = UserInfo.getUserId()
		);

		insert(objSO);

		String strResponse = '';
		strResponse = '{"return_cust_results":{"SHIPTO_COUNTY":"SUFFOLK","PROCESS_MESSAGE":"","PRICE_LIST":"","SHIPTO_CUSTOMER_ID":"13582395",';
		strResponse = strResponse + '"BILLTO_PARTY_ID":"21617334","BILL_TO_SITE_ID":"554680","SHIPTO_PARTY_NAME":"908 DEVICES","LAST_UPDATE_DATE":"",';
		strResponse = strResponse + '"BILLTO_CITY":"BOSTON","EMAIL_ADDRESS":"brendan0powers@gmail.com","SHIPTO_CITY":"BOSTON","PERSON_FIRST_NAME":"BRENDAN","CREATED_BY":"1050",';
		strResponse = strResponse + '"LAST_UPDATED_BY":"","PROCESS_STATUS":"PENDING","ORDER_DATE":"","WAREHOUSE":"","SHIPTO_REGION":"Americas","RETURN_REASON":"","PRICE_LIST_ID":"",';
		strResponse = strResponse + '"CREATION_DATE":"","BILLTO_CUSTOMER_NAME":"908 DEVICES","ORDER_INFO_REF":"' + objSO.Id + '","BILLTO_COUNTRY":"US","BILLTO_ADDRESS3":"27 DRYDOCK AVE",';
		strResponse = strResponse + '"SHIP_TO_SITE_ID":"554680","BILLTO_ADDRESS4":"","SHIPTO_PARTY_ID":"21617334","BILLTO_ADDRESS1":"27 DRYDOCK AVE",';
		strResponse = strResponse + '"BILLTO_PARTY_INFO_REF":"' + objAcctParty.Id + '","BILLTO_ADDRESS2":"","SHIPMENT_PRIORITY":"false","SHIP_TO_USE_ID":"746688",';
		strResponse = strResponse + '"BILLTO_POSTAL_CODE":"2210","PHONE_NUMBER":"603 762-4336","BILLTO_COUNTY":"SUFFOLK","SHIPTO_POSTAL_CODE":"2210","BILLTO_PARTY_NAME":"908 DEVICES",';
		strResponse = strResponse + '"BILLTO_CUSTOMER_ID":"13582395","BILLTO_ADDRESS_INFO_REF":"' + objAcctSite.Id + '","NOTES":"","BILLTO_STATE":"MA","PAYMENT_TERMS":"",';
		strResponse = strResponse + '"BILLTO_PROVINCE":"","SHIPTO_CUSTOMER_INFO_REF":"' + objAcctCustomer.Id + '","ORDER_TYPE_ID":"1067","SHIPTO_COUNTRY":"US",';
		strResponse = strResponse + '"SHIPTO_ADDRESS1":"27 DRYDOCK AVE","SHIPTO_ADDRESS2":"","SHIPTO_ADDRESS3":"27 DRYDOCK AVE","CUSTOMER_PO_NO":"UNKNOWN",';
		strResponse = strResponse + '"SHIPTO_CUSTOMER_NAME":"908 DEVICES","SHIPTO_ADDRESS4":"","ORDER_TYPE":"","SHIPTO_ADDRESS_INFO_REF":"' + objAcctSite.Id + '",';
		strResponse = strResponse + '"SALES_REP_ID":"","SHIPTO_STATE":"MA","BILLTO_CUSTOMER_INFO_REF":"' + objAcctCustomer.Id + '","SHIPTO_PROVINCE":"",';
		strResponse = strResponse + '"BILL_TO_USE_ID":"746690","PERSON_LAST_NAME":"POWERS","ORDER_SOURCE":"salesforce.com","LINES_COUNT":"1","CONTACT_ROLE_ID":"19535449",';
		strResponse = strResponse + '"CONTACT_ID":"21292171","CONTACT_INFO_REF":"' + objContact.Id + '","SHIPTO_PARTY_INFO_REF":"' + objAcctParty.Id + '"}}';

		Test_MOCK_ServiceCalls.strResponseInject = strResponse;
		ICRT_TransmitOrder.singleIdToSubmitOrderToICRT(objSO.Id);

	}
	@IsTest
	private static void sendICRTOrderToOracle2() {

		Test.setMock(HttpCalloutMock.class, new Test_MOCK_ServiceCalls.generalCalloutMock());

		Product2 objProduct = Test_Environment_Utility.createInsertProduct();

		Account objAcctParty = [SELECT Id FROM Account WHERE RecordTypeId = :Schema.SObjectType.Account.getRecordTypeInfosByName().get('Party').getRecordTypeId() and Name = 'Test Site' LIMIT 1];
		Account objAcctCustomer = [SELECT Id FROM Account WHERE RecordTypeId = :Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer - Organization').getRecordTypeId() and Name = 'Test Site' LIMIT 1];
		Account objAcctSite = [SELECT Id FROM Account WHERE RecordTypeId = :Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId() and Name = 'Test Site' LIMIT 1];
		Contact objContact = [SELECT Id FROM Contact LIMIT 1];

		Account objAcctParty2 = [SELECT Id FROM Account WHERE RecordTypeId = :Schema.SObjectType.Account.getRecordTypeInfosByName().get('Party').getRecordTypeId() and Name = 'Test Site2' LIMIT 1];
		Account objAcctCustomer2 = [SELECT Id FROM Account WHERE RecordTypeId = :Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer - Organization').getRecordTypeId() and Name = 'Test Site2' LIMIT 1];
		Account objAcctSite2 = [SELECT Id FROM Account WHERE RecordTypeId = :Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId() and Name = 'Test Site2' LIMIT 1];

		Sales_Order__c objSO = new Sales_Order__c(
            Bill_To_Customer__c = objAcctSite.Id,
            Ship_To_Customer__c = objAcctSite.Id,
            Customer_PO_Number__c = '0000001',
            Ship_To_Contact__c = objContact.Id,
            Order_Type_Id__c = 'TRF',
            Notes__c = 'TEST NOTES',
            Sales_Rep__c = UserInfo.getUserId()
		);

		insert(objSO);

		String strResponse = '';
		strResponse = '{"return_cust_results":{"SHIPTO_COUNTY":"SUFFOLK","PROCESS_MESSAGE":"","PRICE_LIST":"","SHIPTO_CUSTOMER_ID":"13582395",';
		strResponse = strResponse + '"BILLTO_PARTY_ID":"21617334","BILL_TO_SITE_ID":"554680","SHIPTO_PARTY_NAME":"*","LAST_UPDATE_DATE":"",';
		strResponse = strResponse + '"BILLTO_CITY":"BOSTON","EMAIL_ADDRESS":"brendan0powers@gmail.com","SHIPTO_CITY":"BOSTON","PERSON_FIRST_NAME":"BRENDAN","CREATED_BY":"1050",';
		strResponse = strResponse + '"LAST_UPDATED_BY":"","PROCESS_STATUS":"PENDING","ORDER_DATE":"","WAREHOUSE":"","SHIPTO_REGION":"Americas","RETURN_REASON":"","PRICE_LIST_ID":"",';
		strResponse = strResponse + '"CREATION_DATE":"","BILLTO_CUSTOMER_NAME":"*","ORDER_INFO_REF":"' + objSO.Id + '","BILLTO_COUNTRY":"US","BILLTO_ADDRESS3":"27 DRYDOCK AVE",';
		strResponse = strResponse + '"SHIP_TO_SITE_ID":"554680","BILLTO_ADDRESS4":"","SHIPTO_PARTY_ID":"21617334","BILLTO_ADDRESS1":"27 DRYDOCK AVE",';
		strResponse = strResponse + '"BILLTO_PARTY_INFO_REF":"' + objAcctParty.Id + '","BILLTO_ADDRESS2":"","SHIPMENT_PRIORITY":"false","SHIP_TO_USE_ID":"746688",';
		strResponse = strResponse + '"BILLTO_POSTAL_CODE":"2210","PHONE_NUMBER":"603 762-4336","BILLTO_COUNTY":"SUFFOLK","SHIPTO_POSTAL_CODE":"2210","BILLTO_PARTY_NAME":"*",';
		strResponse = strResponse + '"BILLTO_CUSTOMER_ID":"13582395","BILLTO_ADDRESS_INFO_REF":"' + objAcctSite.Id + '","NOTES":"","BILLTO_STATE":"MA","PAYMENT_TERMS":"",';
		strResponse = strResponse + '"BILLTO_PROVINCE":"","SHIPTO_CUSTOMER_INFO_REF":"' + objAcctCustomer2.Id + '","ORDER_TYPE_ID":"1067","SHIPTO_COUNTRY":"US",';
		strResponse = strResponse + '"SHIPTO_ADDRESS1":"27 DRYDOCK AVE","SHIPTO_ADDRESS2":"","SHIPTO_ADDRESS3":"27 DRYDOCK AVE","CUSTOMER_PO_NO":"UNKNOWN",';
		strResponse = strResponse + '"SHIPTO_CUSTOMER_NAME":"*","SHIPTO_ADDRESS4":"","ORDER_TYPE":"","SHIPTO_ADDRESS_INFO_REF":"' + objAcctSite2.Id + '",';
		strResponse = strResponse + '"SALES_REP_ID":"","SHIPTO_STATE":"MA","BILLTO_CUSTOMER_INFO_REF":"' + objAcctCustomer.Id + '","SHIPTO_PROVINCE":"",';
		strResponse = strResponse + '"BILL_TO_USE_ID":"746690","PERSON_LAST_NAME":"POWERS","ORDER_SOURCE":"salesforce.com","LINES_COUNT":"1","CONTACT_ROLE_ID":"19535449",';
		strResponse = strResponse + '"CONTACT_ID":"21292171","CONTACT_INFO_REF":"' + objContact.Id + '","SHIPTO_PARTY_INFO_REF":"' + objAcctParty2.Id + '"}}';

		Test_MOCK_ServiceCalls.strResponseInject = strResponse;
		ICRT_TransmitOrder.singleIdToSubmitOrderToICRT(objSO.Id);

	}

}