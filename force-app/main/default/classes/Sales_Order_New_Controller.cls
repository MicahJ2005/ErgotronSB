/*
    Controller class for the SalesOrderNew.page.

    MOD DATE        Who                     Description
    06/24/2015      Chris Noe               Initial Release
    06/07/2017      Esau Sanchez            Commented lines 73-78, 81-82, 101-106, 109-110 to encourage user selection of address
	02180517		Andy Boettcher DCS		Sunsetted for Lightning Service Console
*/

public without sharing class Sales_Order_New_Controller {
    ////Class variables
    //public final Sales_Order__c oSalesOrder;
    //public List<Sales_Order_Line__c> listSalesOrderLines {get; set;}
    //public List<selectOption> listOrderTypeOptions {get;private set;}
    //public String sOrderTypeId {get;set;}
    //public Map<String,String> mapOrderTypes {get;private set;}
    //public String sRelatedObject {get;set;}                                                             //SR=Service Request,SC=Service Contract
    //public String sRelatedObjectId {get;set;}                                                   //Record Id of the related object, used to link the Sales_Order__c to the originating object
    //public Boolean bShowDelete {get; set;}
    //public String sSelectedLineItem {get; set;}
    //public List<selectOption> listReturnReasonOptions {get;private set;}
    //public Map<String,String> mapReturnReasons {get;private set;}
    //public String sOrderType {get;set;}

    ////Used to help instantiate a counter for the Visualforce table rows
    //public final Integer ZERO {get; private set;}

        //public Sales_Order_New_Controller(ApexPages.StandardController oStdController) {
        ////Instatiate row counter for the list of deal registration products
        //this.ZERO = 0;

                ////Get the current Sales_Order__c record
        //oSalesOrder = (Sales_Order__c)oStdController.getRecord();   

        ////Initialize sales order lines list
        //listSalesOrderLines = new List<Sales_Order_Line__c>();

        ////Retrieve URL parameters for type and id
        //sRelatedObject = ApexPages.currentPage().getParameters().get('rtype');
        //sRelatedObjectId = ApexPages.currentPage().getParameters().get('rid');

        ////Set the selected order type if working with an exisitng Sales_Order__c record.  Get the list of sales order lines if working with an existing sales order.
        //if(oSalesOrder.Id!=NULL){
                //sOrderTypeId=oSalesOrder.Order_Type_Id__c;

            //sOrderType=oSalesOrder.Order_Type__c;

            //listSalesOrderLines = [select Id, Part_Number__c, Quantity__c, Return_Reason_Code__c, Return_Reason__c, Scheduled_Ship_Date__c
                                         //from Sales_Order_Line__c where Sales_Order__c = :oSalesOrder.Id];
        
            //if(listSalesOrderLines.isEmpty()) {
                ////Create 5 new sales order lines
                //addNewSalesOrderLines(5);
            //}
        //}
        //else {
                ////Create 5 new sales order lines
            //addNewSalesOrderLines(5);

            ////Creating new Sales_Order__c.  Set Sales_Order__c relationship fields and account details based on the rtype and rid URL parameters
                //if(sRelatedObject=='SR'){
                        ////Create sales order request came from a Service Request.
                        //oSalesOrder.Service_Request__c=sRelatedObjectId;

                        ////Retrieve Bill To/Ship To Account, Ship To Contact, and address details details from the related service request
                        //try{
                                //Case oCase = [select AccountId, ContactId, Incident_Address1_Oracle__c, Incident_Address2_Oracle__c, Incident_Address3_Oracle__c,
                                    //Incident_Address4_Oracle__c, Incident_City_State_Zip_Country__c, Incident_Org_Id__c
                                    //from Case where Id=:sRelatedObjectId limit 1];
                    
                    //oSalesOrder.Bill_To_Customer__c=oCase.AccountId;
                                //oSalesOrder.Ship_To_Customer__c=oCase.AccountId;
                                //oSalesOrder.Ship_To_Contact__c=oCase.ContactId;
                    ////oSalesOrder.Ship_To_Address1_Oracle__c=oCase.Incident_Address1_Oracle__c;
                    ////oSalesOrder.Ship_To_Address2_Oracle__c=oCase.Incident_Address2_Oracle__c;
                    ////oSalesOrder.Ship_To_Address3_Oracle__c=oCase.Incident_Address3_Oracle__c;
                    ////oSalesOrder.Ship_To_Address4_Oracle__c=oCase.Incident_Address4_Oracle__c;
                    ////oSalesOrder.Ship_To_City_State_Zip_Country_Oracle__c=oCase.Incident_City_State_Zip_Country__c;
                    ////oSalesOrder.Ship_To_Org_Id__c=oCase.Incident_Org_Id__c;

                    ////Set Bill To Customer Account and Ship To Customer Account on the Sales Order
                    ////oSalesOrder.Bill_To_Customer_Account__c=[select Id from Customer_Account__c where Party__c = :oCase.AccountId].Id;
                    ////oSalesOrder.Ship_To_Customer_Account__c=oSalesOrder.Bill_To_Customer_Account__c;
                        //}
                        //catch(Exception oException){
                                //system.debug('Error retrieving account and contact details from Service Request: ' + sRelatedObjectId);
                        //}
                //}
                //else if(sRelatedObject=='SC'){
                        ////Create sales order request came from a Service Contract.
                        //oSalesOrder.Service_Contract__c=sRelatedObjectId;

                        ////Retrieve Bill To/Ship To Account, Ship To Contact, and address details details from the related service contract
                        //try{
                                //Service_Contract__c oServiceContract = [select Customer_Name__c, Contact__c, Ship_To_Address1_Oracle__c, Ship_To_Address2_Oracle__c, Ship_To_Address3_Oracle__c,
                                    //Ship_To_Address4_Oracle__c, Ship_To_City_State_Zip_Country_Oracle__c, Ship_To_Org_Id__c
                                    //from Service_Contract__c where Id=:sRelatedObjectId limit 1];

                    //oSalesOrder.Bill_To_Customer__c=oServiceContract.Customer_Name__c;
                                //oSalesOrder.Ship_To_Customer__c=oServiceContract.Customer_Name__c;
                                //oSalesOrder.Ship_To_Contact__c=oServiceContract.Contact__c;
                    ////oSalesOrder.Ship_To_Address1_Oracle__c=oServiceContract.Ship_To_Address1_Oracle__c;
                    ////oSalesOrder.Ship_To_Address2_Oracle__c=oServiceContract.Ship_To_Address2_Oracle__c;
                    ////oSalesOrder.Ship_To_Address3_Oracle__c=oServiceContract.Ship_To_Address3_Oracle__c;
                    ////oSalesOrder.Ship_To_Address4_Oracle__c=oServiceContract.Ship_To_Address4_Oracle__c;
                    ////oSalesOrder.Ship_To_City_State_Zip_Country_Oracle__c=oServiceContract.Ship_To_City_State_Zip_Country_Oracle__c;
                    ////oSalesOrder.Ship_To_Org_Id__c=oServiceContract.Ship_To_Org_Id__c;

                    ////Set Bill To Customer Account and Ship To Customer Account on the Sales Order
                    ////oSalesOrder.Bill_To_Customer_Account__c=[select Id from Customer_Account__c where Party__c = :oServiceContract.Customer_Name__c].Id;
                    ////oSalesOrder.Ship_To_Customer_Account__c=oSalesOrder.Bill_To_Customer_Account__c;
                        //}
                        //catch(Exception oException){
                                //system.debug('Error retrieving account and contact details from Service Contract: ' + sRelatedObjectId);
                        //}
                //}
        //}

                ////Build list of order types from custom setting Oracle_Order_Type__c.
                //listOrderTypeOptions = new List<selectOption>();
                //mapOrderTypes = new Map<String,String>();

                ////Add blank value to the selection list
                //listOrderTypeOptions.add(new SelectOption('', '-- Select One --'));       

        ////Retrieve all order types from custom setting
        //Map<String, Oracle_Order_Type__c> mapOrderTypeCustomSetting = Oracle_Order_Type__c.getAll();
        //List<String> listOrderTypeNames = new List<String>();
        //listOrderTypeNames.addAll(mapOrderTypeCustomSetting.keySet());
        //listOrderTypeNames.sort();
        
        ////Create the Select Options.
        //for (String sOrderType : listOrderTypeNames) {
            //Oracle_Order_Type__c oOrderType = mapOrderTypeCustomSetting.get(sOrderType);
            
            ////Add order type to the selection list based on the custom setting fields.  Only display order types that have a Start Date Active value that is less than or equal to today,
            ////an End Date Active value that is NULL or greater than today, and a Salesforce_Order_Type__c value of True
            //if(oOrderType.Salesforce_Order_Type__c && oOrderType.Start_Date_Active__c<=Date.today() && (oOrderType.End_Date_Active__c==NULL || oOrderType.End_Date_Active__c>Date.today())){
                    //listOrderTypeOptions.add(new SelectOption(oOrderType.Order_Type_Id__c,oOrderType.Name));

                    ////Add key value pair to mapOrderTypes
                    //mapOrderTypes.put(oOrderType.Order_Type_Id__c,oOrderType.Name);             
            //}

                //}

        ////Build list of return reasons from custom setting Oracle_Return_Reason__c.
        //listReturnReasonOptions = new List<selectOption>();
        //mapReturnReasons = new Map<String,String>();

        ////Add blank value to the selection list
        //listReturnReasonOptions.add(new SelectOption('', '-- Select One --'));       

        ////Retrieve all return reasons from custom setting
        //Map<String, Oracle_Return_Reason__c> mapReturnReasonSetting = Oracle_Return_Reason__c.getAll();
        //List<String> listReturnReasonCodes = new List<String>();
        //listReturnReasonCodes.addAll(mapReturnReasonSetting.keySet());
        //listReturnReasonCodes.sort();
        
        ////Create the Select Options.
        //for (String sReturnReasonCode : listReturnReasonCodes) {
            //Oracle_Return_Reason__c oReturnReason = mapReturnReasonSetting.get(sReturnReasonCode);
            
            ////Add return reason to the selection list based on the custom setting fields.  Only display return reasons that have a Start Date Active value that is less than or equal to today,
            ////an End Date Active value that is NULL or greater than today, and a Enabled_Flag__c value of True
            //if(oReturnReason.Enabled_Flag__c && oReturnReason.Start_Date_Active__c<=Date.today() && (oReturnReason.End_Date_Active__c==NULL || oReturnReason.End_Date_Active__c>Date.today())){
                //listReturnReasonOptions.add(new SelectOption(oReturnReason.Lookup_Code__c,oReturnReason.Description__c));

                ////Add key value pair to mapReturnReasons
                //mapReturnReasons.put(oReturnReason.Lookup_Code__c,oReturnReason.Description__c);                
            //}

        //}
        //}

        //public PageReference saveSalesOrder() {
        ////Method variables
        //List<Sales_Order_Line__c> listUpdateSalesOrderLines = new List<Sales_Order_Line__c>();

        ////Verify required fields

        ////Order Type
        //if(sOrderTypeId==NULL){
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select an order type.'));
            //return null;
        //}

        ////Insert/Update Sales_Order__c
        //oSalesOrder.Order_Type_Id__c=sOrderTypeId;
        //oSalesOrder.Order_Type__c=mapOrderTypes.get(sOrderTypeId);

        //try{
                //upsert oSalesOrder;     
        //}
        //catch(Exception oException){
            //return null;                
        //}
        
        ////Verify Quantity__c for Sales_Order_Line__c records
        //if(!listSalesOrderLines.isEmpty()){
            //for(Integer i=0;i<listSalesOrderLines.size();i++){
                //if(listSalesOrderLines[i].Part_Number__c!=NULL && (listSalesOrderLines[i].Quantity__c==NULL || listSalesOrderLines[i].Quantity__c==0)) {
                    ////Part Number was selected but no quantity was entered.  Add error and return nulll.
                    //listSalesOrderLines[i].Quantity__c.addError('Please enter a quantity that is greater than 0.');
                    //return null;
                //}
            //}
        //}

        ////Save Sales_Order_Line__c records
        //if(!listSalesOrderLines.isEmpty()){
            //for(Integer i=0;i<listSalesOrderLines.size();i++){
                //if(listSalesOrderLines[i].Part_Number__c!=NULL) {
                    //listSalesOrderLines[i].Sales_Order__c = oSalesOrder.Id;
                    //if(sOrderType=='RETURN')
                        //if(listSalesOrderLines[i].Return_Reason_Code__c!=NULL){
                            //listSalesOrderLines[i].Return_Reason__c=mapReturnReasons.get(listSalesOrderLines[i].Return_Reason_Code__c);
                        //}
                        //else{
                            ////Return Reason code is required, add page message and return.
                            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a return reason for all sales order lines.'));
                            //return null;
                        //}
                    //else{
                        //listSalesOrderLines[i].Return_Reason__c='';
                        //listSalesOrderLines[i].Return_Reason_Code__c='';
                    //}

                    //listUpdateSalesOrderLines.add(listSalesOrderLines[i]);
                //}
            //}

            //if(!listUpdateSalesOrderLines.isEmpty()){
                //upsert listUpdateSalesOrderLines;
            //}
        //}

        //PageReference oPageRef = new PageReference('/' + oSalesOrder.Id);
        //oPageRef.setRedirect(true);
        //return oPageRef;                
        //}

    //public void addNewSalesOrderLines(Integer iNumberOfLines){
        ////This method adds multiple sales order lines based on the integer value passed into the method.

        //for(Integer i=0;i<iNumberOfLines;i++){
            //Sales_Order_Line__c oNewSalesOrderLine = new Sales_Order_Line__c();

            //listSalesOrderLines.add(oNewSalesOrderLine);
        //}

        //bShowDelete=false;
        //bShowDelete = bShowDelete || listSalesOrderLines.size()>1;
    //} 

    //public void addNewSalesOrderLine(){
        ////Adds a single sales order line. This action method is called from the SalesOrderNew.page when the user clicks "Add Line"

        //Sales_Order_Line__c oNewSalesOrderLine = new Sales_Order_Line__c();

        //listSalesOrderLines.add(oNewSalesOrderLine);

        //bShowDelete=false;
        //bShowDelete = bShowDelete || listSalesOrderLines.size()>1;
    //} 

    //public void removeNewSalesOrderLine(){
        ////This method removes a sales order line based on the row index set in the Visualforce page.

        ////Row index in Visualforce page is 1 based so we subtract one to get the item index for the list of sales order lines.
        //Integer rowIndex = Integer.valueOf(sSelectedLineItem) - 1;

        //if(rowIndex >= 0){
            //Sales_Order_Line__c oLineToRemove = listSalesOrderLines.get(rowIndex);
            //listSalesOrderLines.remove(rowIndex);
            //if(oLineToRemove.Id != null){
                //delete oLineToRemove;
            //}
        //}

        //bShowDelete=false;
        //bShowDelete = bShowDelete || listSalesOrderLines.size()>1;
    //}

    //public void setOrderType(){
        //if(mapOrderTypes.get(sOrderTypeId).contains('RETURN')){
            //sOrderType='RETURN';  
        //}
        //else if(mapOrderTypes.get(sOrderTypeId).contains('MAINTENANCE')){
            //sOrderType='MAINTENANCE';  
        //}
        //else if(mapOrderTypes.get(sOrderTypeId).contains('TRF')){
            //sOrderType='TRF';  
        //}
        //else{
            //sOrderType='';
        //}
    //}
}