/*
	Controller class for the SeedUnitOrderConfirmation.page on the Seed_Unit_Order__c object.

	MOD DATE		Who						Description
	4/24/2014		Chris Noe				Initial Release
	9/3/2014        Chris Noe               Updates related to FB-00449 to properly set the bill to account on seed unit orders for hospitals.
	10/9/2014       Chris Noe               Updates related to FB-00368 and the implementation of new web service callouts for creating customers.
*/

public without sharing class Seed_Unit_Order_Confirmation_Controller {
    //Class variables
    public final Seed_Unit_Order__c oSeedUnitOrder;
    public Boolean bApprovalRequired {get; private set;}
    
	//Constructor method
    public Seed_Unit_Order_Confirmation_Controller(ApexPages.StandardController stdController) {
        //Get the current Seed_Unit_Order__c record
        this.oSeedUnitOrder = (Seed_Unit_Order__c)stdController.getRecord();

		//Initialize boolean flags
		bApprovalRequired=false;
		
		//Set flag for seed unit order approval required
		for(Seed_Unit_Product__c oSeedUnitProduct :[select Id, Seed_Unit_Eligible__c from Seed_Unit_Product__c where Seed_Unit_Order__c = :oSeedUnitOrder.Id]) {
			if(!oSeedUnitProduct.Seed_Unit_Eligible__c) {
				bApprovalRequired=true;
			}
		}		
    }            	

    //Returns a page reference to the seed unit order page when user submits the seed unit order from the confirmation page
    public PageReference orderConfirmationSubmit(){
    	//Method variables
    	PageReference oPageRef;
    	Approval.ProcessSubmitRequest oApprovalProcess = new Approval.ProcessSubmitRequest();
    	Approval.ProcessResult oProcessResult;
		Oracle_Customer_Utility.CreateCustomerRequest oCreateCustomerRequest = new Oracle_Customer_Utility.CreateCustomerRequest();
		Oracle_Customer_Utility.CreateCustomerResponse oCreateCustomerResponse = new Oracle_Customer_Utility.CreateCustomerResponse();
		Account oAccountUpdate;
		Account oNewCustomerAccount;
		Contact oContactUpdate;

/*
BEGIN LOGIC FOR SEED UNIT ORDERS WHERE SOLD_TO_SALESFORCE_ID__C == SHIP_TO_SALESFORCE_ID__C - BILLING AND SHIPPING TO THE SAME CUSTOMER
*/
		//Check to see if Sold To and Ship To Salesforce Id's match
		if(oSeedUnitOrder.Sold_To_Salesforce_Id__c==oSeedUnitOrder.Ship_To_Salesforce_Id__c) {
			//Format the new ship to address to include the hospital/clinic name in ADDRESS2 field for new addresses at Clinic or Hospital seed location types
		    if(oSeedUnitOrder.Ship_To_Org_Id__c==NULL && oSeedUnitOrder.Sold_To_Salesforce_Id__c!=oSeedUnitOrder.Opportunity__r.Account.Id && (oSeedUnitOrder.Seed_Unit_Location_Type__c=='Clinic' || oSeedUnitOrder.Seed_Unit_Location_Type__c=='Hospital')) {
	            //Move ADDRESS3 to ADDRESS4 and ADDRESS2 to ADDRESS3
	            String sShipToAddress4 = oSeedUnitOrder.Ship_To_Address3__c;
	            String sShipToAddress3 = oSeedUnitOrder.Ship_To_Address2__c;

	            oSeedUnitOrder.Ship_To_Address4__c=sShipToAddress4;
	            oSeedUnitOrder.Ship_To_Address3__c=sShipToAddress3;

	            String sUpperAccountName=oSeedUnitOrder.Opportunity__r.Account.Name;
	            sUpperAccountName=sUpperAccountName.toUpperCase();
	            oSeedUnitOrder.Ship_To_Address2__c=sUpperAccountName;
	        }

			//Check Customer, Ship To Address, and Ship To Contact Ids - If either of these are NULL, process the integration callout logic.
			if(oSeedUnitOrder.Sold_To_Org_Id__c==NULL || oSeedUnitOrder.Ship_To_Org_Id__c==NULL || oSeedUnitOrder.Ship_To_Contact_Role_Id__c==NULL) {
				//Retrieve unique integration id for transaction validation.
				Integration_Id__c oIntegrationId = [select Id, Name, Security_Id__c from Integration_Id__c order by CreatedDate limit 1];	
				
				//Set request verification id
				oCreateCustomerRequest.ip_verification_id = oIntegrationId.Security_Id__c;
				//Set request salesforce ref id
				oCreateCustomerRequest.ip_salesforce_ref_id = oSeedUnitOrder.ORIG_SYS_DOCUMENT_REF__c;

				//Check for existing Party Id for the sold to account account associated with the seed unit order
				if(oSeedUnitOrder.Sold_To_Party_Id__c!=NULL) {
					//Party exists, set party id value on the request and set organization name to blank.
					oCreateCustomerRequest.ip_party_id=oSeedUnitOrder.Sold_To_Party_Id__c;
					oCreateCustomerRequest.ip_organization_name='';
				}
				else {
					//Party does not exist, set party id to blank and organization name to account name
					oCreateCustomerRequest.ip_party_id='';
					oCreateCustomerRequest.ip_organization_name=oSeedUnitOrder.Sold_To_Party_Name__c.toUpperCase();
				}
				
				//Check for existing customer id for the sold to account associated with the seed unit order
				if(oSeedUnitOrder.Sold_To_Org_Id__c!=NULL){
					//Customer exists, set customer account id on the request and set account name to blank
					oCreateCustomerRequest.ip_cust_account_id=oSeedUnitOrder.Sold_To_Org_Id__c;
					oCreateCustomerRequest.ip_account_name='';
				}
				else {
					//Customer does not exist, set customer account id to blank and account name based on country
					oCreateCustomerRequest.ip_cust_account_id='';
					//Set account name based on Ship_To_Country__c - US='DOMESTIC', CA='CANADA', blank for all other countries
					if(oSeedUnitOrder.Ship_To_Country__c=='United States-US') {
						oCreateCustomerRequest.ip_account_name='DOMESTIC';
					}
					else if(oSeedUnitOrder.Ship_To_Country__c=='Canada-CA') {
						oCreateCustomerRequest.ip_account_name='CANADA';
					}
					else{
						oCreateCustomerRequest.ip_account_name='';
					}
				}

				//Check for existing site use id. This value will be populated if the user selected an existing Oracle ship to address when setting up their order.  If the 
				//Ship_To_Org_Id__c is null then a new ship to address needs to be created as part of the create customer interface request.
				if(oSeedUnitOrder.Ship_To_Org_Id__c!=NULL) {
					//Ship to site use exists, set ship to site use on the request and set address fields to blank
					oCreateCustomerRequest.ip_ship_to_site_use_id=oSeedUnitOrder.Ship_To_Org_Id__c;
					oCreateCustomerRequest.ip_address1='';
					oCreateCustomerRequest.ip_address2='';
					oCreateCustomerRequest.ip_address3='';
					oCreateCustomerRequest.ip_address4='';
					oCreateCustomerRequest.ip_city='';
					oCreateCustomerRequest.ip_state='';
					oCreateCustomerRequest.ip_province='';
					oCreateCustomerRequest.ip_postal_code='';
					oCreateCustomerRequest.ip_country='';
					oCreateCustomerRequest.ip_county='';
				}
				else {
					//Ship to site use does not exist, set ship to site use to blank and set address fields
					oCreateCustomerRequest.ip_ship_to_site_use_id='';
					//NULL checks required when doing toUpperCase
					if(oSeedUnitOrder.Ship_To_Address1__c!=NULL){
						oCreateCustomerRequest.ip_address1=oSeedUnitOrder.Ship_To_Address1__c.toUpperCase();	
					}
					if(oSeedUnitOrder.Ship_To_Address2__c!=NULL){
						oCreateCustomerRequest.ip_address2=oSeedUnitOrder.Ship_To_Address2__c.toUpperCase();
					}
					if(oSeedUnitOrder.Ship_To_Address3__c!=NULL){
						oCreateCustomerRequest.ip_address3=oSeedUnitOrder.Ship_To_Address3__c.toUpperCase();
					}
					if(oSeedUnitOrder.Ship_To_Address4__c!=NULL){
						oCreateCustomerRequest.ip_address4=oSeedUnitOrder.Ship_To_Address4__c.toUpperCase();
					}
					if(oSeedUnitOrder.Ship_To_City__c!=NULL){
						oCreateCustomerRequest.ip_city=oSeedUnitOrder.Ship_To_City__c.toUpperCase();
					}
					oCreateCustomerRequest.ip_is_ship_to_address='Y';
					//If creating new customer, set bill to flag to 'Y'
					if(oSeedUnitOrder.Sold_To_Org_Id__c==NULL){
						oCreateCustomerRequest.ip_is_bill_to_address='Y';
					}
					else {
						oCreateCustomerRequest.ip_is_bill_to_address='N';	
					}
					//If Ship_To_Country__c = 'CA', set state value to CA (required for Oracle Canadian address format) and set province value
					if(oSeedUnitOrder.Ship_To_State_Province__c!=NULL) {
						if(oSeedUnitOrder.Ship_To_Country__c=='Canada-CA') {
							oCreateCustomerRequest.ip_state='CA';
							oCreateCustomerRequest.ip_province=oSeedUnitOrder.Ship_To_State_Province__c.right(2);				
						}
						else if(oSeedUnitOrder.Ship_To_Country__c=='United States-US') {
							oCreateCustomerRequest.ip_state=oSeedUnitOrder.Ship_To_State_Province__c.right(2);
							oCreateCustomerRequest.ip_province='';					
						}
						else if(oSeedUnitOrder.Ship_To_Country__c=='China-CN') {
							oCreateCustomerRequest.ip_state='';
							oCreateCustomerRequest.ip_province=oSeedUnitOrder.Ship_To_State_Province__c.right(2);					
						}
					}

					//NULL checks required when doing toUpperCase
					if(oSeedUnitOrder.Ship_To_Postal_Code__c!=NULL){
						oCreateCustomerRequest.ip_postal_code=oSeedUnitOrder.Ship_To_Postal_Code__c.toUpperCase();
					}
					if(oSeedUnitOrder.Ship_To_Country__c!=NULL){
						oCreateCustomerRequest.ip_country=oSeedUnitOrder.Ship_To_Country__c.right(2).toUpperCase();

						//Map Ship_To_Country__c to ip_state when Ship_To_Country__c!=United States-US, Canada-CA, United Kingdom-GB, and China-CN to match Oracle address styles
						if(oSeedUnitOrder.Ship_To_Country__c!='United States-US' && oSeedUnitOrder.Ship_To_Country__c!='Canada-CA' 
							&& oSeedUnitOrder.Ship_To_Country__c!='United Kingdom-GB' && oSeedUnitOrder.Ship_To_Country__c!='China-CN') {
							oCreateCustomerRequest.ip_state=oSeedUnitOrder.Ship_To_Country__c.right(2).toUpperCase();
						}
					}

					//Set county value on request.  County for DC returned by address validation service does not match Oracle/Vertex display value ('DISTRICT OF COLUMBIA' vs 'DIST OF COLUMBIA).
					//Do not set county value if State=DC.  Oracle will default to the correct county for DC ('DIST OF COLUMBIA').
					//Do not set county value if State=AK.  Oracle will default to the correct county for AK.
					if(oSeedUnitOrder.Ship_To_State_Province__c!=NULL && oSeedUnitOrder.Ship_To_Country__c=='United States-US') {
						if(oSeedUnitOrder.Ship_To_County__c!=NULL && oSeedUnitOrder.Ship_To_State_Province__c!='District of Columbia-DC' && oSeedUnitOrder.Ship_To_State_Province__c!='Alaska-AK'){
							oCreateCustomerRequest.ip_county=oSeedUnitOrder.Ship_To_County__c.toUpperCase();

							//If city=SAINT LOUIS, change county to "SAINT LOUIS (IND CIT"
							if(oSeedUnitOrder.Ship_To_City__c=='SAINT LOUIS') {
								oCreateCustomerRequest.ip_county='SAINT LOUIS (IND CIT';
							}
						}
					}
					//Set ip_state to the Ship To County value if Ship To Country is 'United Kingdom-GB' - This is required for the UAA (United Kingdom) address format in Oracle
					else if(oSeedUnitOrder.Ship_To_County__c!=NULL && oSeedUnitOrder.Ship_To_Country__c=='United Kingdom-GB') {
						oCreateCustomerRequest.ip_state=oSeedUnitOrder.Ship_To_County__c.toUpperCase();
					}				
				}

				//Add ship to contact details to the request - NULL checks required for toUpperCase function
				if(oSeedUnitOrder.Ship_To_Contact_First_Name__c!=NULL){
					oCreateCustomerRequest.ip_person_first_name=oSeedUnitOrder.Ship_To_Contact_First_Name__c.toUpperCase();	
				}
				if(oSeedUnitOrder.Ship_To_Contact_Last_Name__c!=NULL){
					oCreateCustomerRequest.ip_person_last_name=oSeedUnitOrder.Ship_To_Contact_Last_Name__c.toUpperCase();
				}
				if(oSeedUnitOrder.Ship_To_Contact_Phone__c!=NULL){
					oCreateCustomerRequest.ip_raw_phone_number=oSeedUnitOrder.Ship_To_Contact_Phone__c;
				}
				if(oSeedUnitOrder.Ship_To_Contact_Email__c!=NULL){
					oCreateCustomerRequest.ip_email_address=oSeedUnitOrder.Ship_To_Contact_Email__c.toUpperCase();
				}

				System.Debug('SENDING ORACLE WEB SERVICE');

				//Submit interface request
				oCreateCustomerResponse = Oracle_Customer_Utility.createCustomerCallout(oCreateCustomerRequest, 'Seed Unit Order Submission');

				//Evaluate web service response - web service callout exception check.
				if(oCreateCustomerResponse.ws_exception_message!=NULL && oCreateCustomerResponse.ws_exception_message!='') {
					//Web service callout exception.  Add page message and return NULL to the user.
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'CALLOUT EXCEPTION. Error creating Oracle customer, address, or contact details. Your system administrator has been notified.'));
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oCreateCustomerResponse.ws_exception_message));
					UtilityMethods.commitLogs();
					return null;
				}

				//Evalutate web service response - web service status check.
				if(oCreateCustomerResponse.ws_callout_status_code!='200') {
					//Web service status exception.  Add page message and return NULL to the user.
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'STATUS EXCEPTION. Error creating Oracle customer, address, or contact details. Your system administrator has been notified.'));
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'STATUS CODE: ' + oCreateCustomerResponse.ws_callout_status_code));
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oCreateCustomerResponse.ws_callout_status_message));
					UtilityMethods.commitLogs();
					return null;			
				}

				//Evaluate Oracle API reponse - check for api errors
				if(oCreateCustomerResponse.op_return_status!=NULL && oCreateCustomerResponse.op_return_status!='') {
					//Oracle API exception.  Add page message and return NULL to the user.
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ORACLE API EXCEPTION. Error creating Oracle customer, address, or contact details. Your system administrator has been notified.'));
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ORACLE API STATUS CODE: ' + oCreateCustomerResponse.op_return_status));
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ORACLE API STATUS MESSAGE: ' + oCreateCustomerResponse.op_return_message));
					
					//Delete integration id associated with the transaction
					delete oIntegrationId;
					UtilityMethods.commitLogs();
					return null;
				}

				//Web service call was successful, process response.

				//Delete integration id associated with the transaction
				delete oIntegrationId;

				//Check Party Id.  If Sold To Party Id is NULL, update the Oracle_Party_Number__c and Oracle_Party_Id__c with the values returned from the web service call.
				if(oSeedUnitOrder.Sold_To_Party_Id__c==NULL) {
					oAccountUpdate = new Account(Id=oSeedUnitOrder.Sold_To_Salesforce_Id__c);
					oAccountUpdate.Oracle_Party_Id__c=oCreateCustomerResponse.op_party_id;
					oAccountUpdate.Oracle_Party_Number__c=oCreateCustomerResponse.op_party_number;

					// Added 20151007 AAB - Copying BT/ST Site Id up to the attached Account
					//oAccountUpdate.Oracle_Site_Id__c = oCreateCustomerResponse.op_ship_to_site_use_id;

					update oAccountUpdate;
				}

				//Check customer id.  If Sold To Org Id is NULL, create new Customer_Account__c record with the values returned from the web service call.  Also update the seed unit order
				//with a refence to the newly created customer account (set Sold_To_Org__c and Ship_To_Customer_Account__c).
				if(oSeedUnitOrder.Sold_To_Org_Id__c==NULL){
					oNewCustomerAccount = new Account(
						Name=oSeedUnitOrder.Sold_To_Party_Name__c.left(80), 
						Customer_Account_Id__c=oCreateCustomerResponse.op_cust_account_id, 
						//Party__c=oSeedUnitOrder.Sold_To_Salesforce_Id__c, 
						Oracle_Party_Status__c='A');
					insert oNewCustomerAccount;

					oSeedUnitOrder.Sold_To_Org_new__c=oNewCustomerAccount.Id;
					oSeedUnitOrder.Ship_To_Customer_Account_new__c=oNewCustomerAccount.Id;
				}

				//Check site use id.  If current Ship To Org Id is null, populate this value with the return value from the web service.
				if(oSeedUnitOrder.Ship_To_Org_Id__c==NULL) {		
					oSeedUnitOrder.Ship_To_Org_Id__c=oCreateCustomerResponse.op_ship_to_site_use_id;
				}

				//Check ship to contact role id.  If current Ship To Contact Role Id is null, populate this value with the return value from the web service.
				//Also update ship to contact with the contact role id returned from Oracle.
				if(oSeedUnitOrder.Ship_To_Contact_Role_Id__c==NULL) {
					oContactUpdate = new Contact(Id=oSeedUnitOrder.Ship_To_Contact__c,Oracle_Contact_Id__c=oCreateCustomerResponse.op_cust_account_role_id);
					update oContactUpdate;

					oSeedUnitOrder.Ship_To_Contact_Role_Id__c=oCreateCustomerResponse.op_cust_account_role_id;
				}
			}
		}
/*
END LOGIC FOR SEED UNIT ORDERS WHERE SOLD_TO_SALESFORCE_ID__C == SHIP_TO_SALESFORCE_ID__C - BILLING AND SHIPPING TO END USER
*/

/*
BEGIN LOGIC FOR SEED UNIT ORDERS WHERE SOLD_TO_SALESFORCE_ID__C != SHIP_TO_SALESFORCE_ID__C - BILLING TO END USER AND SHIPPING TO THIRD PARTY
*/
		else {
			//Variables for create customer and create relationship callout for ship to and sold to on the 
			Oracle_Customer_Utility.CreateCustomerRequest oCreateCustomerRequestSoldTo = new Oracle_Customer_Utility.CreateCustomerRequest();
			Oracle_Customer_Utility.CreateCustomerResponse oCreateCustomerResponseSoldTo = new Oracle_Customer_Utility.CreateCustomerResponse();
			Oracle_Customer_Utility.CreateCustomerRequest oCreateCustomerRequestShipTo = new Oracle_Customer_Utility.CreateCustomerRequest();
			Oracle_Customer_Utility.CreateCustomerResponse oCreateCustomerResponseShipTo = new Oracle_Customer_Utility.CreateCustomerResponse();
			Oracle_Customer_Utility.CreateRelationshipRequest oCreateCustomerRelationshipRequest = new Oracle_Customer_Utility.CreateRelationshipRequest();
			Oracle_Customer_Utility.CreateRelationshipResponse oCreateCustomerRelationshipResponse = new Oracle_Customer_Utility.CreateRelationshipResponse();
			Boolean bCalloutError = false;

			Account oAccountUpdateSoldTo;
			Account oNewCustomerAccountSoldTo;
			Account oAccountUpdateShipTo;
			Account oNewCustomerAccountShipTo;
			Contact oContactUpdateShipTo;

			String sSoldToCustomerId='';
			String sShipToCustomerId='';

			Integration_Id__c oIntegrationIdSoldTo = new Integration_Id__c();
			Integration_Id__c oIntegrationIdShipTo = new Integration_Id__c();
			Integration_Id__c oIntegrationIdRelationship = new Integration_Id__c();

			//Retrieve 3 integration ids and add to list
			List<Integration_Id__c> listIntegrationIds = [select Id, Name, Security_Id__c from Integration_Id__c order by CreatedDate limit 3];

/*
	BEGIN: LOGIC TO CREATE SOLD TO CUSTOMER IF SOLD TO CUSTOMER DOES NOT ALREADY EXIST
*/
			if(oSeedUnitOrder.Sold_To_Org_Id__c==NULL) {
				//Retrieve unique integration id for transaction validation.
				oIntegrationIdSoldTo = listIntegrationIds[0];	
				
				//Set request verification id
				oCreateCustomerRequestSoldTo.ip_verification_id = oIntegrationIdSoldTo.Security_Id__c;
				//Set request salesforce ref id
				oCreateCustomerRequestSoldTo.ip_salesforce_ref_id = oSeedUnitOrder.Sold_To_Salesforce_Id__c;

				//Check for existing Party Id for the sold to account account associated with the seed unit order
				if(oSeedUnitOrder.Sold_To_Party_Id__c!=NULL) {
					//Party exists, set party id value on the request and set organization name to blank.
					oCreateCustomerRequestSoldTo.ip_party_id=oSeedUnitOrder.Sold_To_Party_Id__c;
					oCreateCustomerRequestSoldTo.ip_organization_name='';
				}
				else {
					//Party does not exist, set party id to blank and organization name to account name
					oCreateCustomerRequestSoldTo.ip_party_id='';
					oCreateCustomerRequestSoldTo.ip_organization_name=oSeedUnitOrder.Sold_To_Party_Name__c.toUpperCase();
				}
				
				//Set customer account id to blank and account name based on country
				oCreateCustomerRequestSoldTo.ip_cust_account_id='';
				//Set account name based on Opportunity__r.Account.BillingCountryCode - US='DOMESTIC', CA='CANADA', blank for all other countries
				if(oSeedUnitOrder.Opportunity__r.Account.BillingCountryCode=='US') {
					oCreateCustomerRequestSoldTo.ip_account_name='DOMESTIC';
				}
				else if(oSeedUnitOrder.Opportunity__r.Account.BillingCountryCode=='CA') {
					oCreateCustomerRequestSoldTo.ip_account_name='CANADA';
				}
				else{
					oCreateCustomerRequestSoldTo.ip_account_name='';
				}
					
				//Create ship to/bill to address for new sold to customer.  Pull address details from the end user account assoicated with the opportunity
				oCreateCustomerRequestSoldTo.ip_ship_to_site_use_id='';
				//NULL checks required when doing toUpperCase
				if(oSeedUnitOrder.Opportunity__r.Account.BillingStreet!=NULL){
					oCreateCustomerRequestSoldTo.ip_address1=oSeedUnitOrder.Opportunity__r.Account.BillingStreet.toUpperCase();	
				}
				if(oSeedUnitOrder.Opportunity__r.Account.BillingCity!=NULL){
					oCreateCustomerRequestSoldTo.ip_city=oSeedUnitOrder.Opportunity__r.Account.BillingCity.toUpperCase();
				}
				
				//Set billing and shipping address flag to 'Y'
				oCreateCustomerRequestSoldTo.ip_is_ship_to_address='Y';
				oCreateCustomerRequestSoldTo.ip_is_bill_to_address='Y';
				
				//If Opportunity__r.Account.BillingCountryCode = 'CA', set state value to CA (required for Oracle Canadian address format) and set province value
				if(oSeedUnitOrder.Opportunity__r.Account.BillingCountryCode=='CA') {
					oCreateCustomerRequestSoldTo.ip_state='CA';
					oCreateCustomerRequestSoldTo.ip_province=oSeedUnitOrder.Opportunity__r.Account.BillingStateCode;				
				}
				else if(oSeedUnitOrder.Opportunity__r.Account.BillingCountryCode=='US') {
					oCreateCustomerRequestSoldTo.ip_state=oSeedUnitOrder.Opportunity__r.Account.BillingStateCode;
					oCreateCustomerRequestSoldTo.ip_province='';					
				}
				else if(oSeedUnitOrder.Opportunity__r.Account.BillingCountryCode=='CN') {
					oCreateCustomerRequestSoldTo.ip_state='';
					oCreateCustomerRequestSoldTo.ip_province=oSeedUnitOrder.Opportunity__r.Account.BillingStateCode;					
				}

				//NULL checks required when doing toUpperCase
				if(oSeedUnitOrder.Opportunity__r.Account.BillingPostalCode!=NULL){
					oCreateCustomerRequestSoldTo.ip_postal_code=oSeedUnitOrder.Opportunity__r.Account.BillingPostalCode.toUpperCase();
				}
				if(oSeedUnitOrder.Opportunity__r.Account.BillingCountryCode!=NULL){
					oCreateCustomerRequestSoldTo.ip_country=oSeedUnitOrder.Opportunity__r.Account.BillingCountryCode.toUpperCase();

					//Map BillingCountryCode to ip_state when BillingCountryCode!=US, CA, GB, and CN to match Oracle address styles
					if(oSeedUnitOrder.Opportunity__r.Account.BillingCountryCode!='US' && oSeedUnitOrder.Opportunity__r.Account.BillingCountryCode!='CA' 
						&& oSeedUnitOrder.Opportunity__r.Account.BillingCountryCode!='GB' && oSeedUnitOrder.Opportunity__r.Account.BillingCountryCode!='CN') {
						oCreateCustomerRequestSoldTo.ip_state=oSeedUnitOrder.Opportunity__r.Account.BillingCountryCode.toUpperCase();
					}
				}	

				//Submit interface request
				oCreateCustomerResponseSoldTo = Oracle_Customer_Utility.createCustomerCallout(oCreateCustomerRequestSoldTo, 'Seed Unit Order Submission-Create Sold To Customer');

				//Evaluate web service response - web service callout exception check.
				if(oCreateCustomerResponseSoldTo.ws_exception_message!=NULL && oCreateCustomerResponseSoldTo.ws_exception_message!='') {
					//Web service callout exception.  Add page message and return NULL to the user.
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'CALLOUT EXCEPTION. Error creating Oracle Sold To Customer details. Your system administrator has been notified.'));
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oCreateCustomerResponseSoldTo.ws_exception_message));
					UtilityMethods.commitLogs();
					return null;
				}

				//Evalutate web service response - web service status check.
				if(oCreateCustomerResponseSoldTo.ws_callout_status_code!='200') {
					//Web service status exception.  Add page message and return NULL to the user.
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'STATUS EXCEPTION. Error creating Oracle Sold To Customer details. Your system administrator has been notified.'));
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'STATUS CODE: ' + oCreateCustomerResponseSoldTo.ws_callout_status_code));
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oCreateCustomerResponseSoldTo.ws_callout_status_message));
					UtilityMethods.commitLogs();
					return null;			
				}

				//Evaluate Oracle API reponse - check for api errors
				if(oCreateCustomerResponseSoldTo.op_return_status!=NULL && oCreateCustomerResponseSoldTo.op_return_status!='') {
					//Oracle API exception.  Add page message and return NULL to the user.
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ORACLE API EXCEPTION. Error creating Oracle Sold To Customer details. Your system administrator has been notified.'));
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ORACLE API STATUS CODE: ' + oCreateCustomerResponseSoldTo.op_return_status));
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ORACLE API STATUS MESSAGE: ' + oCreateCustomerResponseSoldTo.op_return_message));
					
					//Delete integration id associated with the transaction
					delete oIntegrationIdSoldTo;
					UtilityMethods.commitLogs();
					return null;
				}

				//Web service call was successful, set sold to customer id and move on to next callout.

				//Set sold to customer account id for callout to create customer relationship
				sSoldToCustomerId = oCreateCustomerResponseSoldTo.op_cust_account_id;		
			}

			else {
				//Set sold to customer account id for callout to create customer relationship
				sSoldToCustomerId = oSeedUnitOrder.Sold_To_Org_Id__c;
			}
/*
	END: LOGIC TO CREATE SOLD TO CUSTOMER IF SOLD TO CUSTOMER DOES NOT ALREADY EXIST
*/

/*
	BEGIN: LOGIC TO CREATE SHIP TO CUSTOMER, SHIP TO ADDRESS, AND SHIP TO CONTACT IF THEY DO NOT EXIST
*/
			//Ship To Address, and Ship To Contact Ids - If either of these are NULL, process the integration callout logic.
			if(oSeedUnitOrder.Ship_To_Org_Id__c==NULL || oSeedUnitOrder.Ship_To_Contact_Role_Id__c==NULL) {
				//Retrieve unique integration id for transaction validation.
				oIntegrationIdShipTo = listIntegrationIds[1];	
				
				//Set request verification id
				oCreateCustomerRequestShipTo.ip_verification_id = oIntegrationIdShipTo.Security_Id__c;
				//Set request salesforce ref id
				oCreateCustomerRequestShipTo.ip_salesforce_ref_id = oSeedUnitOrder.ORIG_SYS_DOCUMENT_REF__c;

				//Check for existing Party Id for the ship to account account associated with the seed unit order
				if(oSeedUnitOrder.Ship_To_Party_Id__c!=NULL) {
					//Party exists, set party id value on the request and set organization name to blank.
					oCreateCustomerRequestShipTo.ip_party_id=oSeedUnitOrder.Ship_To_Party_Id__c;
					oCreateCustomerRequestShipTo.ip_organization_name='';
				}
				else {
					//Party does not exist, set party id to blank and organization name to account name
					oCreateCustomerRequestShipTo.ip_party_id='';
					oCreateCustomerRequestShipTo.ip_organization_name=oSeedUnitOrder.Ship_To_Party_Name__c.toUpperCase();
				}
				
				//Check for existing customer id for the ship to account associated with the seed unit order
				if(oSeedUnitOrder.Ship_To_Customer_Account_Id__c!=NULL){
					//Customer exists, set customer account id on the request and set account name to blank
					oCreateCustomerRequestShipTo.ip_cust_account_id=oSeedUnitOrder.Ship_To_Customer_Account_Id__c;
					oCreateCustomerRequestShipTo.ip_account_name='';
				}
				else {
					//Customer does not exist, set customer account id to blank and account name based on country
					oCreateCustomerRequestShipTo.ip_cust_account_id='';
					//Set account name based on Ship_To_Country__c - US='DOMESTIC', CA='CANADA', blank for all other countries
					if(oSeedUnitOrder.Ship_To_Country__c=='United States-US') {
						oCreateCustomerRequestShipTo.ip_account_name='DOMESTIC';
					}
					else if(oSeedUnitOrder.Ship_To_Country__c=='Canada-CA') {
						oCreateCustomerRequestShipTo.ip_account_name='CANADA';
					}
					else{
						oCreateCustomerRequestShipTo.ip_account_name='';
					}
				}

				//Check for existing site use id. This value will be populated if the user selected an existing Oracle ship to address when setting up their order.  If the 
				//Ship_To_Org_Id__c is null then a new ship to address needs to be created as part of the create customer interface request.
				if(oSeedUnitOrder.Ship_To_Org_Id__c!=NULL) {
					//Ship to site use exists, set ship to site use on the request and set address fields to blank
					oCreateCustomerRequestShipTo.ip_ship_to_site_use_id=oSeedUnitOrder.Ship_To_Org_Id__c;
					oCreateCustomerRequestShipTo.ip_address1='';
					oCreateCustomerRequestShipTo.ip_address2='';
					oCreateCustomerRequestShipTo.ip_address3='';
					oCreateCustomerRequestShipTo.ip_address4='';
					oCreateCustomerRequestShipTo.ip_city='';
					oCreateCustomerRequestShipTo.ip_state='';
					oCreateCustomerRequestShipTo.ip_province='';
					oCreateCustomerRequestShipTo.ip_postal_code='';
					oCreateCustomerRequestShipTo.ip_country='';
					oCreateCustomerRequestShipTo.ip_county='';
				}
				else {
					//Ship to site use does not exist, set ship to site use to blank and set address fields
					oCreateCustomerRequestShipTo.ip_ship_to_site_use_id='';
					//NULL checks required when doing toUpperCase
					if(oSeedUnitOrder.Ship_To_Address1__c!=NULL){
						oCreateCustomerRequestShipTo.ip_address1=oSeedUnitOrder.Ship_To_Address1__c.toUpperCase();	
					}
					if(oSeedUnitOrder.Ship_To_Address2__c!=NULL){
						oCreateCustomerRequestShipTo.ip_address2=oSeedUnitOrder.Ship_To_Address2__c.toUpperCase();
					}
					if(oSeedUnitOrder.Ship_To_Address3__c!=NULL){
						oCreateCustomerRequestShipTo.ip_address3=oSeedUnitOrder.Ship_To_Address3__c.toUpperCase();
					}
					if(oSeedUnitOrder.Ship_To_Address4__c!=NULL){
						oCreateCustomerRequestShipTo.ip_address4=oSeedUnitOrder.Ship_To_Address4__c.toUpperCase();
					}
					if(oSeedUnitOrder.Ship_To_City__c!=NULL){
						oCreateCustomerRequestShipTo.ip_city=oSeedUnitOrder.Ship_To_City__c.toUpperCase();
					}
					oCreateCustomerRequestShipTo.ip_is_ship_to_address='Y';
					//If creating new customer, set bill to flag to 'Y'
					if(oSeedUnitOrder.Ship_To_Customer_Account_Id__c==NULL){
						oCreateCustomerRequestShipTo.ip_is_bill_to_address='Y';
					}
					else {
						oCreateCustomerRequestShipTo.ip_is_bill_to_address='N';	
					}
					//If Ship_To_Country__c = 'CA', set state value to CA (required for Oracle Canadian address format) and set province value
					if(oSeedUnitOrder.Ship_To_State_Province__c!=NULL) {
						if(oSeedUnitOrder.Ship_To_Country__c=='Canada-CA') {
							oCreateCustomerRequestShipTo.ip_state='CA';
							oCreateCustomerRequestShipTo.ip_province=oSeedUnitOrder.Ship_To_State_Province__c.right(2);				
						}
						else if(oSeedUnitOrder.Ship_To_Country__c=='United States-US') {
							oCreateCustomerRequestShipTo.ip_state=oSeedUnitOrder.Ship_To_State_Province__c.right(2);
							oCreateCustomerRequestShipTo.ip_province='';					
						}
						else if(oSeedUnitOrder.Ship_To_Country__c=='China-CN') {
							oCreateCustomerRequestShipTo.ip_state='';
							oCreateCustomerRequestShipTo.ip_province=oSeedUnitOrder.Ship_To_State_Province__c.right(2);	
						}
					}

					//NULL checks required when doing toUpperCase
					if(oSeedUnitOrder.Ship_To_Postal_Code__c!=NULL){
						oCreateCustomerRequestShipTo.ip_postal_code=oSeedUnitOrder.Ship_To_Postal_Code__c.toUpperCase();
					}
					if(oSeedUnitOrder.Ship_To_Country__c!=NULL){
						oCreateCustomerRequestShipTo.ip_country=oSeedUnitOrder.Ship_To_Country__c.right(2).toUpperCase();

						//Map Ship_To_Country__c to ip_state when Ship_To_Country__c!=United States-US, Canada-CA, United Kingdom-GB, and China-CN to match Oracle address styles
						if(oSeedUnitOrder.Ship_To_Country__c!='United States-US' && oSeedUnitOrder.Ship_To_Country__c!='Canada-CA' 
							&& oSeedUnitOrder.Ship_To_Country__c!='United Kingdom-GB' && oSeedUnitOrder.Ship_To_Country__c!='China-CN') {
							oCreateCustomerRequestShipTo.ip_state=oSeedUnitOrder.Ship_To_Country__c.right(2).toUpperCase();
						}
					}

					//Set county value on request.  County for DC returned by address validation service does not match Oracle/Vertex display value ('DISTRICT OF COLUMBIA' vs 'DIST OF COLUMBIA).
					//Do not set county value if State=DC.  Oracle will default to the correct county for DC ('DIST OF COLUMBIA').
					//Do not set county value if State=AK.  Oracle will default to the correct county for AK.
					if(oSeedUnitOrder.Ship_To_State_Province__c!=NULL && oSeedUnitOrder.Ship_To_Country__c=='United States-US') {
						if(oSeedUnitOrder.Ship_To_County__c!=NULL && oSeedUnitOrder.Ship_To_State_Province__c!='District of Columbia-DC' && oSeedUnitOrder.Ship_To_State_Province__c!='Alaska-AK'){
							oCreateCustomerRequestShipTo.ip_county=oSeedUnitOrder.Ship_To_County__c.toUpperCase();

							//If city=SAINT LOUIS, change county to "SAINT LOUIS (IND CIT"
							if(oSeedUnitOrder.Ship_To_City__c=='SAINT LOUIS') {
								oCreateCustomerRequestShipTo.ip_county='SAINT LOUIS (IND CIT';
							}
						}						
					}
					//Set ip_state to the Ship To County value if Ship To Country is 'United Kingdom-GB' - This is required for the UAA (United Kingdom) address format in Oracle
					else if(oSeedUnitOrder.Ship_To_County__c!=NULL && oSeedUnitOrder.Ship_To_Country__c=='United Kingdom-GB') {
						oCreateCustomerRequestShipTo.ip_state=oSeedUnitOrder.Ship_To_County__c.toUpperCase();
					}	
				}

				//Add ship to contact details to the request - NULL checks required for toUpperCase function
				if(oSeedUnitOrder.Ship_To_Contact_First_Name__c!=NULL){
					oCreateCustomerRequestShipTo.ip_person_first_name=oSeedUnitOrder.Ship_To_Contact_First_Name__c.toUpperCase();	
				}
				if(oSeedUnitOrder.Ship_To_Contact_Last_Name__c!=NULL){
					oCreateCustomerRequestShipTo.ip_person_last_name=oSeedUnitOrder.Ship_To_Contact_Last_Name__c.toUpperCase();
				}
				if(oSeedUnitOrder.Ship_To_Contact_Phone__c!=NULL){
					oCreateCustomerRequestShipTo.ip_raw_phone_number=oSeedUnitOrder.Ship_To_Contact_Phone__c;
				}
				if(oSeedUnitOrder.Ship_To_Contact_Email__c!=NULL){
					oCreateCustomerRequestShipTo.ip_email_address=oSeedUnitOrder.Ship_To_Contact_Email__c.toUpperCase();
				}

				//Reset callout error boolean
				bCalloutError = false;
				//Submit interface request
				oCreateCustomerResponseShipTo = Oracle_Customer_Utility.createCustomerCallout(oCreateCustomerRequestShipTo, 'Seed Unit Order Submission-Create Ship To Customer');

				//Evaluate web service response - web service callout exception check.
				if(oCreateCustomerResponseShipTo.ws_exception_message!=NULL && oCreateCustomerResponseShipTo.ws_exception_message!='') {
					//Web service callout exception.  Add page message and return NULL to the user.
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'CALLOUT EXCEPTION. Error creating Oracle ship to customer, address, or contact details. Your system administrator has been notified.'));
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oCreateCustomerResponseShipTo.ws_exception_message));
					bCalloutError=true;
				}

				//Evalutate web service response - web service status check.
				if(oCreateCustomerResponseShipTo.ws_callout_status_code!='200') {
					//Web service status exception.  Add page message and return NULL to the user.
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'STATUS EXCEPTION. Error creating Oracle ship to customer, address, or contact details. Your system administrator has been notified.'));
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'STATUS CODE: ' + oCreateCustomerResponseShipTo.ws_callout_status_code));
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oCreateCustomerResponseShipTo.ws_callout_status_message));
					bCalloutError=true;			
				}

				//Evaluate Oracle API reponse - check for api errors
				if(oCreateCustomerResponseShipTo.op_return_status!=NULL && oCreateCustomerResponseShipTo.op_return_status!='') {
					//Oracle API exception.  Add page message and return NULL to the user.
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ORACLE API EXCEPTION. Error creating Oracle ship to customer, address, or contact details. Your system administrator has been notified.'));
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ORACLE API STATUS CODE: ' + oCreateCustomerResponseShipTo.op_return_status));
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ORACLE API STATUS MESSAGE: ' + oCreateCustomerResponseShipTo.op_return_message));
					bCalloutError=true;
					//Delete integration id associated with the ship to customer transaction
					delete oIntegrationIdShipTo;
				}

				if(bCalloutError) {
					//Error calling web service to create ship to customer.  Perform DML operations for Sold To customer.  If the sold to customer callout was successful but 
					//the ship to customer logic failed and returned an Oracle or web service error, we need to update the sold to customer details in Salesforce.
					//Delete integration id associated with the sold to customer transaction if a sold to account was created via callout. Create new Customer_Account__c record with 
					//the values returned from the web service call.  Also update the seed unit order with a refence to the newly created customer account.
					if(oSeedUnitOrder.Sold_To_Org_Id__c==NULL) {
						delete oIntegrationIdSoldTo;

						oNewCustomerAccountSoldTo = new Account(
							Name=oSeedUnitOrder.Sold_To_Party_Name__c.left(80), 
							Customer_Account_Id__c=oCreateCustomerResponseSoldTo.op_cust_account_id, 
							//Party__c=oSeedUnitOrder.Sold_To_Salesforce_Id__c, 
							Oracle_Party_Status__c='A');
						insert oNewCustomerAccountSoldTo;

						oSeedUnitOrder.Sold_To_Org_new__c=oNewCustomerAccountSoldTo.Id;

						//Check Party Id.  If Sold To Party Id is NULL, update the Oracle_Party_Number__c and Oracle_Party_Id__c with the values returned from the web service call.
						if(oSeedUnitOrder.Sold_To_Party_Id__c==NULL) {
							oAccountUpdateSoldTo = new Account(Id=oSeedUnitOrder.Sold_To_Salesforce_Id__c, Oracle_Party_Id__c=oCreateCustomerResponseSoldTo.op_party_id, Oracle_Party_Number__c=oCreateCustomerResponseSoldTo.op_party_number);
							update oAccountUpdateSoldTo;
						}

						update oSeedUnitOrder;
					}
					
					UtilityMethods.commitLogs();
					return null;
				}

				//Web service call was successful, set ship to to customer id and move on to next callout.

				//Set ship to customer account id for callout to create customer relationship
				sShipToCustomerId = oCreateCustomerResponseShipTo.op_cust_account_id;				
			}

			else {
				//Set ship to customer account id for callout to create customer relationship
				sShipToCustomerId = oSeedUnitOrder.Ship_To_Customer_Account_Id__c;
			}
/*
	END: LOGIC TO CREATE SHIP TO CUSTOMER, SHIP TO ADDRESS, AND SHIP TO CONTACT IF THEY DO NOT EXIST
*/

/*
	BEGIN: LOGIC TO CREATE SHIP TO RELATIONSHIP
*/			
			//Retrieve unique integration id for transaction validation.
			oIntegrationIdRelationship = listIntegrationIds[2];	
			
			//Set request verification id
			oCreateCustomerRelationshipRequest.ip_verification_id = oIntegrationIdRelationship.Security_Id__c;
			//Set request salesforce ref id
			oCreateCustomerRelationshipRequest.ip_salesforce_ref_id = oSeedUnitOrder.ORIG_SYS_DOCUMENT_REF__c;
			//Set TO and FROM and Ship To/Bill To flags
			oCreateCustomerRelationshipRequest.ip_cust_account_id = sShipToCustomerId;
			oCreateCustomerRelationshipRequest.ip_related_cust_account_id = sSoldToCustomerId;
			oCreateCustomerRelationshipRequest.ip_bill_to_flag = '';
			oCreateCustomerRelationshipRequest.ip_ship_to_flag = 'Y';

			//Reset callout error boolean
			bCalloutError = false;
			//Submit interface request
			oCreateCustomerRelationshipResponse = Oracle_Customer_Utility.createRelationshipCallout(oCreateCustomerRelationshipRequest, 'Seed Unit Order Submission-Create Customer Relationship');

			//Evaluate web service response - web service callout exception check.
			if(oCreateCustomerRelationshipResponse.ws_exception_message!=NULL && oCreateCustomerRelationshipResponse.ws_exception_message!='') {
				//Web service callout exception.  Add page message and return NULL to the user.
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'CALLOUT EXCEPTION. Error creating Oracle customer relationship. Your system administrator has been notified.'));
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oCreateCustomerRelationshipResponse.ws_exception_message));
				bCalloutError=true;
			}

			//Evalutate web service response - web service status check.
			if(oCreateCustomerRelationshipResponse.ws_callout_status_code!='200') {
				//Web service status exception.  Add page message and return NULL to the user.
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'STATUS EXCEPTION. Error creating Oracle customer relationship. Your system administrator has been notified.'));
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'STATUS CODE: ' + oCreateCustomerRelationshipResponse.ws_callout_status_code));
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oCreateCustomerRelationshipResponse.ws_callout_status_message));
				bCalloutError=true;			
			}

			//Evaluate Oracle API reponse - check for api errors
			if(oCreateCustomerRelationshipResponse.op_return_status!=NULL && oCreateCustomerRelationshipResponse.op_return_status!='') {
				//Oracle API exception.  Add page message and return NULL to the user.
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ORACLE API EXCEPTION. Error creating Oracle customer relationship. Your system administrator has been notified.'));
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ORACLE API STATUS CODE: ' + oCreateCustomerRelationshipResponse.op_return_status));
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ORACLE API STATUS MESSAGE: ' + oCreateCustomerRelationshipResponse.op_return_message));
				bCalloutError=true;
				//Delete integration id associated with the create relationship transaction
				delete oIntegrationIdRelationship;
			}		

			if(bCalloutError) {
				//Error calling web service to create relationship.  Perform DML operations for Sold To customer.  If the sold to customer callout was successful but 
				//the customer relationship logic failed and returned an Oracle or web service error, we need to update the sold to customer details in Salesforce.
				//Delete integration id associated with the sold to customer transaction if a sold to account was created via callout. Create new Customer_Account__c record with 
				//the values returned from the web service call.  Also update the seed unit order with a refence to the newly created customer account.
				if(oSeedUnitOrder.Sold_To_Org_Id__c==NULL) {
					delete oIntegrationIdSoldTo;

					oNewCustomerAccountSoldTo = new Account(
						Name=oSeedUnitOrder.Sold_To_Party_Name__c.left(80), 
						Customer_Account_Id__c=oCreateCustomerResponseSoldTo.op_cust_account_id, 
						//Party__c=oSeedUnitOrder.Sold_To_Salesforce_Id__c, 
						Oracle_Party_Status__c='A');
					insert oNewCustomerAccountSoldTo;

					oSeedUnitOrder.Sold_To_Org_new__c=oNewCustomerAccountSoldTo.Id;

					//Check Party Id.  If Sold To Party Id is NULL, update the Oracle_Party_Number__c and Oracle_Party_Id__c with the values returned from the web service call.
					if(oSeedUnitOrder.Sold_To_Party_Id__c==NULL) {
						oAccountUpdateSoldTo = new Account(Id=oSeedUnitOrder.Sold_To_Salesforce_Id__c, Oracle_Party_Id__c=oCreateCustomerResponseSoldTo.op_party_id, Oracle_Party_Number__c=oCreateCustomerResponseSoldTo.op_party_number);
						update oAccountUpdateSoldTo;
					}
				}

				//Perform DML operations for Ship To customer.  If the ship to customer callout was successful but the customer relationship logic failed and returned an Oracle 
				//or web service error, we need to update the ship to customer details in Salesforce.
				if(oSeedUnitOrder.Ship_To_Org_Id__c==NULL || oSeedUnitOrder.Ship_To_Contact_Role_Id__c==NULL) {
					//Delete integration id associated with the ship to customer transaction if a ship to account, address, and contact was created via callout
					delete oIntegrationIdShipTo;
				}
				
				//Check Ship To Party Id. If Ship To Party Id is NULL, update the Oracle_Party_Number__c and Oracle_Party_Id__c with the values returned from the web service call.
				if(oSeedUnitOrder.Ship_To_Party_Id__c==NULL) {
					oAccountUpdateShipTo = new Account(Id=oSeedUnitOrder.Ship_To_Salesforce_Id__c, Oracle_Party_Id__c=oCreateCustomerResponseShipTo.op_party_id, Oracle_Party_Number__c=oCreateCustomerResponseShipTo.op_party_number);
					update oAccountUpdateShipTo;
				}

				//Check ship to customer id.  If Ship To Customer Id is NULL, create new Customer_Account__c record with the values returned from the web service call.  
				//Also update the seed unit order with a reference to the newly created ship to customer account.
				if(oSeedUnitOrder.Ship_To_Customer_Account_Id__c==NULL){
					oNewCustomerAccountShipTo = new Account(
						Name=oSeedUnitOrder.Ship_To_Party_Name__c.left(80), 
						Customer_Account_Id__c=oCreateCustomerResponseShipTo.op_cust_account_id, 
						//Party__c=oSeedUnitOrder.Ship_To_Salesforce_Id__c, 
						Oracle_Party_Status__c='A');
					insert oNewCustomerAccountShipTo;

					oSeedUnitOrder.Ship_To_Customer_Account_new__c=oNewCustomerAccountShipTo.Id;
				}

				//Check site use id.  If current Ship To Org Id is null, populate this value with the return value from the web service.
				if(oSeedUnitOrder.Ship_To_Org_Id__c==NULL) {		
					oSeedUnitOrder.Ship_To_Org_Id__c=oCreateCustomerResponseShipTo.op_ship_to_site_use_id;
				}

				//Check ship to contact role id.  If current Ship To Contact Role Id is null, populate this value with the return value from the web service.
				//Also update ship to contact with the contact role id returned from Oracle.
				if(oSeedUnitOrder.Ship_To_Contact_Role_Id__c==NULL) {
					oContactUpdateShipTo = new Contact(Id=oSeedUnitOrder.Ship_To_Contact__c,Oracle_Contact_Id__c=oCreateCustomerResponseShipTo.op_cust_account_role_id);
					update oContactUpdateShipTo;

					oSeedUnitOrder.Ship_To_Contact_Role_Id__c=oCreateCustomerResponseShipTo.op_cust_account_role_id;	
				}
				
				update oSeedUnitOrder;

				UtilityMethods.commitLogs();
				return null;
			}
/*
	END: LOGIC TO CREATE SHIP TO RELATIONSHIP
*/

/*
	BEGIN: PERFORM DML OPERATIONS FOR SOLD TO ACCOUNT PROCESSING ONCE WEB SERVICE CALLOUTS HAVE COMPLETED SUCCESSFULLY
*/			
			//Delete integration id associated with the sold to customer transaction if a sold to account was created via callout. Create new Customer_Account__c record with 
			//the values returned from the web service call.  Also update the seed unit order with a refence to the newly created customer account.
			if(oSeedUnitOrder.Sold_To_Org_Id__c==NULL) {
				delete oIntegrationIdSoldTo;

				oNewCustomerAccountSoldTo = new Account(
					Name=oSeedUnitOrder.Sold_To_Party_Name__c.left(80), 
					Customer_Account_Id__c=oCreateCustomerResponseSoldTo.op_cust_account_id, 
					//Party__c=oSeedUnitOrder.Sold_To_Salesforce_Id__c, 
					Oracle_Party_Status__c='A');
				insert oNewCustomerAccountSoldTo;

				oSeedUnitOrder.Sold_To_Org_new__c=oNewCustomerAccountSoldTo.Id;

				//Check Party Id.  If Sold To Party Id is NULL, update the Oracle_Party_Number__c and Oracle_Party_Id__c with the values returned from the web service call.
				if(oSeedUnitOrder.Sold_To_Party_Id__c==NULL) {
					oAccountUpdateSoldTo = new Account(Id=oSeedUnitOrder.Sold_To_Salesforce_Id__c, Oracle_Party_Id__c=oCreateCustomerResponseSoldTo.op_party_id, Oracle_Party_Number__c=oCreateCustomerResponseSoldTo.op_party_number);
					update oAccountUpdateSoldTo;
				}
			}
/*
	END: PERFORM DML OPERATIONS FOR SOLD TO ACCOUNT PROCESSING ONCE WEB SERVICE CALLOUTS HAVE COMPLETED SUCCESSFULLY
*/

/*
	BEGIN: PERFORM DML OPERATIONS FOR SHIP TO ACCOUNT PROCESSING ONCE WEB SERVICE CALLOUTS HAVE COMPLETED SUCCESSFULLY
*/
			if(oSeedUnitOrder.Ship_To_Org_Id__c==NULL || oSeedUnitOrder.Ship_To_Contact_Role_Id__c==NULL) {
				//Delete integration id associated with the ship to customer transaction if a ship to account, address, and contact was created via callout
				delete oIntegrationIdShipTo;
			}
			
			//Check Ship To Party Id. If Ship To Party Id is NULL, update the Oracle_Party_Number__c and Oracle_Party_Id__c with the values returned from the web service call.
			if(oSeedUnitOrder.Ship_To_Party_Id__c==NULL) {
				oAccountUpdateShipTo = new Account(Id=oSeedUnitOrder.Ship_To_Salesforce_Id__c, Oracle_Party_Id__c=oCreateCustomerResponseShipTo.op_party_id, Oracle_Party_Number__c=oCreateCustomerResponseShipTo.op_party_number);
				update oAccountUpdateShipTo;
			}

			//Check ship to customer id.  If Ship To Customer Id is NULL, create new Customer_Account__c record with the values returned from the web service call.  
			//Also update the seed unit order with a reference to the newly created ship to customer account.
			if(oSeedUnitOrder.Ship_To_Customer_Account_Id__c==NULL){
				oNewCustomerAccountShipTo = new Account(
					Name=oSeedUnitOrder.Ship_To_Party_Name__c.left(80), 
					Customer_Account_Id__c=oCreateCustomerResponseShipTo.op_cust_account_id, 
					//Party__c=oSeedUnitOrder.Ship_To_Salesforce_Id__c, 
					Oracle_Party_Status__c='A');
				insert oNewCustomerAccountShipTo;

				oSeedUnitOrder.Ship_To_Customer_Account_new__c=oNewCustomerAccountShipTo.Id;
			}

			//Check site use id.  If current Ship To Org Id is null, populate this value with the return value from the web service.
			if(oSeedUnitOrder.Ship_To_Org_Id__c==NULL) {		
				oSeedUnitOrder.Ship_To_Org_Id__c=oCreateCustomerResponseShipTo.op_ship_to_site_use_id;
			}

			//Check ship to contact role id.  If current Ship To Contact Role Id is null, populate this value with the return value from the web service.
			//Also update ship to contact with the contact role id returned from Oracle.
			if(oSeedUnitOrder.Ship_To_Contact_Role_Id__c==NULL) {
				oContactUpdateShipTo = new Contact(Id=oSeedUnitOrder.Ship_To_Contact__c,Oracle_Contact_Id__c=oCreateCustomerResponseShipTo.op_cust_account_role_id);
				update oContactUpdateShipTo;

				oSeedUnitOrder.Ship_To_Contact_Role_Id__c=oCreateCustomerResponseShipTo.op_cust_account_role_id;	
			}
/*
	END: PERFORM DML OPERATIONS FOR SHIP TO ACCOUNT PROCESSING ONCE WEB SERVICE CALLOUTS HAVE COMPLETED SUCCESSFULLY
*/

/*
	BEGIN: PERFORM DML OPERATIONS FOR RELATIONSHIP PROCESSING ONCE WEB SERVICE CALLOUTS HAVE COMPLETED SUCCESSFULLY
*/
			//Delete integration id used for the customer relationship callout
			delete oIntegrationIdRelationship;
/*
	END: PERFORM DML OPERATIONS FOR RELATIONSHIP PROCESSING ONCE WEB SERVICE CALLOUTS HAVE COMPLETED SUCCESSFULLY
*/

///*  
//	BEGIN:  MOVE BILL TO / SHIP TO SITE IDS TO THE PROPER RELATED ACCOUNTS
//*/			List<Account> lstUpdateAccount = new List<Account>();
//			lstUpdateAccount.add(new Account(Id=oSeedUnitOrder.Ship_To_Salesforce_Id__c, Oracle_Site_Id__c=oSeedUnitOrder.Ship_To_Org_Id__c));
//			lstUpdateAccount.add(new Account(Id=oSeedUnitOrder.Sold_To_Salesforce_Id__c, Oracle_Site_Id__c=oSeedUnitOrder.Sold_To_Org_Id__c));
//			if(lstUpdateAccount.size() > 0) { update lstUpdateAccount; }
///*  
//	END:  MOVE BILL TO / SHIP TO SITE IDS TO THE PROPER RELATED ACCOUNTS
//*/
		}
/*
END LOGIC FOR SEED UNIT ORDERS WHERE SOLD_TO_SALESFORCE_ID__C != SHIP_TO_SALESFORCE_ID__C - BILLING TO END USER AND SHIPPING TO THIRD PARTY
*/
		if(bApprovalRequired) {		
			//Update approval required flag on the seed unit order and submit to approval process.
			oSeedUnitOrder.Seed_Unit_Approval_Required__c=true;
			update oSeedUnitOrder;
			
			//Submit to the approval process for seed unit orders.
    		try{
    			oApprovalProcess.setObjectId(oSeedUnitOrder.id);
    			oProcessResult = Approval.process(oApprovalProcess);
    		}
    		catch(Exception oException){
    			ApexPages.addMessages(oException);
    			UtilityMethods.commitLogs();
    			return oPageRef;
    		} 
		}
	
		else {
			//No approval required.  All fields have been populated and seed unit order is ready for submission. Update Seed_Unit_Order__c.Seed_Unit_Order_Submitted__c to 
			//true.  This will trigger workflow rule to fire to push order header details to Oracle interface tables.  This update will also fire the Seed_Unit_Order_Trigger 
			//which will update the Seed_Unit_Order_Submitted__c flag to true on all of the related Seed_Unit_Product__c records. The trigger logic is used so that the 
			//related Seed_Unit_Product__c.Seed_Unit_Order_Submitted__c values can be updated when the approval process sets the Seed_Unit_Order__c.Seed_Unit_Order_Submitted__c flag to true.
			
			oSeedUnitOrder.Seed_Unit_Approval_Required__c=false;
			oSeedUnitOrder.Seed_Unit_Approval_Status__c=NULL;
			oSeedUnitOrder.Seed_Unit_Order_Submitted__c=true;
			oSeedUnitOrder.Date_Time_Submitted_To_Oracle__c = Datetime.now();
			update oSeedUnitOrder;
		}
    	
		oPageRef = Page.SeedUnitOrderSummary;
		oPageRef.getParameters().put('id', oSeedUnitOrder.Id);
		oPageRef.setRedirect(true);
		UtilityMethods.commitLogs();
		return oPageRef;
    }
    
    //Returns page reference to SeedUnitSelectShipTo
    public PageReference selectShipTo(){
		PageReference oPageRef = Page.SeedUnitSelectShipTo;
		oPageRef.getParameters().put('id', oSeedUnitOrder.Id);
		oPageRef.setRedirect(true);
		return oPageRef;    	
    }
    
    //Returns user to seed unit order edit screen
    public PageReference editOrderDetails(){
		PageReference oPageRef = new PageReference('/' + oSeedUnitOrder.Id + '/e?retURL=%2F' + oSeedUnitOrder.Id);
		oPageRef.setRedirect(true);
		return oPageRef;      	
    }
}