public class HelperOracleOrderReturn {

	public class Return_cust_results {
		public String SHIPTO_COUNTY;
		public String PROCESS_MESSAGE;
		public String PRICE_LIST;
		public String SHIPTO_CUSTOMER_ID;
		public String BILLTO_PARTY_ID;
		public String BILL_TO_SITE_ID;
		public String SHIPTO_PARTY_NAME;
		public String LAST_UPDATE_DATE;
		public String BILLTO_CITY;
		public String EMAIL_ADDRESS;
		public String SHIPTO_CITY;
		public String PERSON_FIRST_NAME;
		public String CREATED_BY;
		public String LAST_UPDATED_BY;
		public String PROCESS_STATUS;
		public String ORDER_DATE;
		public String WAREHOUSE;
		public String RETURN_REASON;
		public String PRICE_LIST_ID;
		public String CREATION_DATE;
		public String BILLTO_CUSTOMER_NAME;
		public String ORDER_INFO_REF;
		public String BILLTO_COUNTRY;
		public String BILLTO_ADDRESS3;
		public String SHIP_TO_SITE_ID;
		public String BILLTO_ADDRESS4;
		public String SHIPTO_PARTY_ID;
		public String BILLTO_ADDRESS1;
		public String BILLTO_PARTY_INFO_REF;
		public String BILLTO_ADDRESS2;
		public String SHIPMENT_PRIORITY;
		public String SHIP_TO_USE_ID;
		public String BILLTO_POSTAL_CODE;
		public String PHONE_NUMBER;
		public String BILLTO_COUNTY;
		public String SHIPTO_POSTAL_CODE;
		public String BILLTO_PARTY_NAME;
		public String BILLTO_CUSTOMER_ID;
		public String BILLTO_ADDRESS_INFO_REF;
		public String NOTES;
		public String BILLTO_STATE;
		public String PAYMENT_TERMS;
		public String BILLTO_PROVINCE;
		public String SHIPTO_CUSTOMER_INFO_REF;
		public String ORDER_TYPE_ID;
		public String SHIPTO_COUNTRY;
		public String SHIPTO_ADDRESS1;
		public String SHIPTO_ADDRESS2;
		public String SHIPTO_ADDRESS3;
		public String CUSTOMER_PO_NO;
		public String SHIPTO_CUSTOMER_NAME;
		public String SHIPTO_ADDRESS4;
		public String ORDER_TYPE;
		public String SHIPTO_ADDRESS_INFO_REF;
		public String SALES_REP_ID;
		public String SHIPTO_STATE;
		public String BILLTO_CUSTOMER_INFO_REF;
		public String SHIPTO_PROVINCE;
		public String BILL_TO_USE_ID;
		public String PERSON_LAST_NAME;
		public String ORDER_SOURCE;
		public String LINES_COUNT;
		public String CONTACT_ROLE_ID;
		public String CONTACT_ID;
		public String CONTACT_INFO_REF;
		public String SHIPTO_PARTY_INFO_REF;
	}

	public Return_cust_results return_cust_results;

	
	public static HelperOracleOrderReturn parse(String json) {
		return (HelperOracleOrderReturn) System.JSON.deserialize(json, HelperOracleOrderReturn.class);
	}
}