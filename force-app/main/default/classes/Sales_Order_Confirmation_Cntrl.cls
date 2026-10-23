/*
    Controller class for the SalesOrderConfirmation.page on the Sales_Order__c object.

    MOD DATE        Who                     Description
    7/2/2015        Chris Noe               Initial Release
    10/11/2017      DCS - MCS               Removal Customer_Account__c
*/

public without sharing class Sales_Order_Confirmation_Cntrl {
    //Class variables
    public final Sales_Order__c oSalesOrder;

    public Sales_Order_Confirmation_Cntrl(ApexPages.StandardController stdController) {
        //Get the current Sales_Order__c record
        this.oSalesOrder = (Sales_Order__c)stdController.getRecord();
    }

    //Returns a page reference to the seed unit order page when user submits the seed unit order from the confirmation page
    public PageReference orderConfirmationSubmit(){
        //Method variables - Request and response objects for integration calls to Oracle
        Oracle_Customer_Utility.CreateCustomerRequest oCreateCustomerRequest = new Oracle_Customer_Utility.CreateCustomerRequest();
        Oracle_Customer_Utility.CreateCustomerResponse oCreateCustomerResponse = new Oracle_Customer_Utility.CreateCustomerResponse();
        Oracle_Customer_Utility.CreateRelationshipRequest oCreateCustomerRelationshipRequest = new Oracle_Customer_Utility.CreateRelationshipRequest();
        Oracle_Customer_Utility.CreateRelationshipResponse oCreateCustomerRelationshipResponse = new Oracle_Customer_Utility.CreateRelationshipResponse();
        Boolean bCalloutError = false;
        Integration_Id__c oIntegrationIdShipToContact = new Integration_Id__c();
        Integration_Id__c oIntegrationIdRelationship = new Integration_Id__c();

        //Generate a list of 2 integration id's for the Oracle API transactions
        List<Integration_Id__c> listIntegrationIds = [select Id, Name, Security_Id__c from Integration_Id__c order by CreatedDate limit 2];

        //Check to see if Ship To Contact Role Id is populated.
        if(oSalesOrder.Ship_To_Contact_Role_Id__c==NULL){
            //Ship To Contact Role Id is null, create integration request to Oracle to create the ship to contact

            //Retrieve unique integration id for ship to contact transaction validation.
            oIntegrationIdShipToContact = listIntegrationIds[0];

            //Build integration request
            //Set request verification id
            oCreateCustomerRequest.ip_verification_id = oIntegrationIdShipToContact.Security_Id__c;
            //Set request salesforce ref id
            oCreateCustomerRequest.ip_salesforce_ref_id = oSalesOrder.ORIG_SYS_DOCUMENT_REF__c;
            //Set ship to party id
            oCreateCustomerRequest.ip_party_id=oSalesOrder.Ship_To_Customer__r.Oracle_Party_Id__c;
            oCreateCustomerRequest.ip_organization_name='';
            //Set ship to customer id
            oCreateCustomerRequest.ip_cust_account_id=oSalesOrder.Ship_To_Customer_Id__c;
            oCreateCustomerRequest.ip_account_name='';
            //Set ship to org id
            oCreateCustomerRequest.ip_ship_to_site_use_id=oSalesOrder.Ship_To_Org_Id__c;
            //Set ship to contact details
            oCreateCustomerRequest.ip_person_first_name=oSalesOrder.Ship_To_Contact_First_Name__c;  
            oCreateCustomerRequest.ip_person_last_name=oSalesOrder.Ship_To_Contact_Last_Name__c;
            oCreateCustomerRequest.ip_raw_phone_number=oSalesOrder.Ship_To_Contact_Phone__c;
            oCreateCustomerRequest.ip_email_address=oSalesOrder.Ship_To_Contact_Email__c;

            //Submit interface request to create ship to contact
            oCreateCustomerResponse = Oracle_Customer_Utility.createCustomerCallout(oCreateCustomerRequest, 'Sales Order Submission-Create Ship To Contact');

            //Evaluate web service response - web service callout exception check.
            if(oCreateCustomerResponse.ws_exception_message!=NULL && oCreateCustomerResponse.ws_exception_message!='') {
                //Web service callout exception.  Add page message and return NULL to the user.
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'CALLOUT EXCEPTION. Error creating Oracle ship to contact. Your system administrator has been notified.'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oCreateCustomerResponse.ws_exception_message));
                return null;
            }

            //Evalutate web service response - web service status check.
            if(oCreateCustomerResponse.ws_callout_status_code!='200') {
                //Web service status exception.  Add page message and return NULL to the user.
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'STATUS EXCEPTION. Error creating Oracle ship to contact. Your system administrator has been notified.'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'STATUS CODE: ' + oCreateCustomerResponse.ws_callout_status_code));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oCreateCustomerResponse.ws_callout_status_message));
                return null;            
            }

            //Evaluate Oracle API reponse - check for api errors
            if(oCreateCustomerResponse.op_return_status!=NULL && oCreateCustomerResponse.op_return_status!='') {
                //Oracle API exception.  Add page message and return NULL to the user.
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ORACLE API EXCEPTION. Error creating Oracle ship to contact. Your system administrator has been notified.'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ORACLE API STATUS CODE: ' + oCreateCustomerResponse.op_return_status));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ORACLE API STATUS MESSAGE: ' + oCreateCustomerResponse.op_return_message));
                
                //Delete integration id associated with the transaction
                delete oIntegrationIdShipToContact;
                return null;
            }

            //Web service call was successful, process response and update Sales_Order__c record.

            //Update Ship To Contact Role Id on the Sales Order
            oSalesOrder.Ship_To_Contact_Role_Id__c=oCreateCustomerResponse.op_cust_account_role_id;
        }

        //Create Bill To/Ship To relationship in Oracle if the billing and shipping customers are different.
        if(oSalesOrder.Bill_To_Customer_Account_new__c!=oSalesOrder.Ship_To_Customer_Account_new__c){
        //if(oSalesOrder.Bill_To_Customer_Account__c!=oSalesOrder.Ship_To_Customer_Account__c){
            //Retrieve unique integration id for relationship transaction validation.
            oIntegrationIdRelationship = listIntegrationIds[1];

            //Set request verification id
            oCreateCustomerRelationshipRequest.ip_verification_id = oIntegrationIdRelationship.Security_Id__c;
            //Set request salesforce ref id
            oCreateCustomerRelationshipRequest.ip_salesforce_ref_id = oSalesOrder.ORIG_SYS_DOCUMENT_REF__c;
            //Set TO and FROM and Ship To/Bill To flags
            oCreateCustomerRelationshipRequest.ip_cust_account_id = oSalesOrder.Ship_To_Customer_Id__c;
            oCreateCustomerRelationshipRequest.ip_related_cust_account_id = oSalesOrder.Bill_To_Customer_Id__c;
            oCreateCustomerRelationshipRequest.ip_bill_to_flag = '';
            oCreateCustomerRelationshipRequest.ip_ship_to_flag = 'Y';

            //Submit interface request to create Bill To/Ship To relationshiop
            oCreateCustomerRelationshipResponse = Oracle_Customer_Utility.createRelationshipCallout(oCreateCustomerRelationshipRequest, 'Sales Order Submission-Create Customer Relationship');

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
                //Delete integration id associated with the ship to contact outbound message transaction
                try{
                    delete oIntegrationIdShipToContact; 
                }
                catch(Exception oException){
                    system.debug('No Integration Id for Ship To Contact');
                }

                //If callout error, process DML for Sales Order and return null
                update oSalesOrder;

                return null;
            }
        }

        //Delete used integration ids
        try{
            delete oIntegrationIdShipToContact; 
        }
        catch(Exception oException){
            system.debug('No Integration Id for Ship To Contact');
        }
        try{
            delete oIntegrationIdRelationship;  
        }
        catch(Exception oException){
            system.debug('No Integration Id for Relationship');
        }

        //Processing complete, update the Sales Order and return the user to the summary page
        oSalesOrder.Order_Submitted__c=true;
        oSalesOrder.Date_Time_Submitted__c = Datetime.now();
        update oSalesOrder;

        PageReference oPageRef = Page.SalesOrderSummary;
        oPageRef.getParameters().put('id', oSalesOrder.Id);
        oPageRef.setRedirect(true);
        return oPageRef;
    }

    //Returns user to sales order edit screen
    public PageReference editOrderDetails(){
        PageReference oPageRef = new PageReference('/' + oSalesOrder.Id + '/e?retURL=%2F' + oSalesOrder.Id);
        oPageRef.setRedirect(true);
        return oPageRef;        
    }

    //Returns page reference to SalesOrderSelectShipTo
    public PageReference selectShipTo(){
        PageReference oPageRef = Page.SalesOrderSelectShipTo;
        oPageRef.getParameters().put('id', oSalesOrder.Id);
        oPageRef.setRedirect(true);
        return oPageRef;        
    }
}