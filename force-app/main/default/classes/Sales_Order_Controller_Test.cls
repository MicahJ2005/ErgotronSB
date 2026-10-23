/*
	Test class for the Sales_Order__c and Sales_Order_Line__c Apex classes, triggers, and Visualforce pages.
	*Sales_Order_New_Controller.cls
	*Sales_Order_Confirmation_Cntrl.cls
	*Sales_Order_Line_New_Controller.cls
	*Sales_Order_Line_Trigger.trigger
	*Sales_Order_Line_Utility.cls
	*Sales_Order_Select_Ship_To_Cntrl.cls
	*Sales_Order_Submit_Controller.cls
	*Sales_Order_Summary_Controller.cls
	*Sales_Order_Trigger.trigger
	*Sales_Order_Utility.cls

	MOD DATE		Who						Description
	07/10/2015		Chris Noe				Initial Release
	10/11/2017      DCS - MCS               Removal Customer_Account__c
	20180517		Andy Boettcher DCS		Sunsetting for Lighting Service Cloud
*/

@isTest
private class Sales_Order_Controller_Test {
	
    ////Test data setup method
    //@testSetup
    //static void testDataSetup() {
    	////Create Account records for testing
    	//Account oAccountEndUser = Test_Environment_Utility.createInsertAccountUS();
    	//Account oAccountReseller = Test_Environment_Utility.createInsertAccountUS();
    	//Account oAccountDistributor = Test_Environment_Utility.createInsertAccountUS();

    	////Create Contact for testing
	    //Contact oContact = Test_Environment_Utility.createInsertContact(oAccountEndUser);

    	////Create Customer_Account__c records for testing
    	////Customer_Account__c oCustomerAccountEndUser = Test_Environment_Utility.createInsertCustomerAccount(oAccountEndUser);
    	////Customer_Account__c oCustomerAccountReseller = Test_Environment_Utility.createInsertCustomerAccount(oAccountReseller);
    	////Customer_Account__c oCustomerAccountDistributor = Test_Environment_Utility.createInsertCustomerAccount(oAccountDistributor);

    	////Create custom setting details
    	//Set<String> setOrderTypes = new Set<String>{'RETURN','MAINTENANCE','TRF'};
    	//Set<String> setReturnReasons = new Set<String>{'BAD','DEFECT','PACKAGING'};
    	//List<Oracle_Order_Type__c> listOrderTypes = Test_Environment_Utility.createInsertOrderTypes(setOrderTypes);
    	//List<Oracle_Return_Reason__c> listReturnReasons = Test_Environment_Utility.createInsertReturnReasons(setReturnReasons);

    	////Create service product for testing
    	//Product2 oProductService = Test_Environment_Utility.createInsertProduct();
    	//oProductService.Item_Type__c='E-SERVICE';
    	//update oProductService;

    	////Create finished good product
    	//Product2 oProductFG = Test_Environment_Utility.createInsertProduct();

		//Pricebook2 objServicePB = Test_Environment_Utility.createServicePricebookWithProduct(oProductFG);

    	////Create web service details for testing
        //Web_Service_Details__c oWebServiceDetailCreateCustomer = Test_Environment_Utility.createInsertWebServiceDetails('Create Customer');
        //Web_Service_Details__c oWebServiceDetailSelectShipTo = Test_Environment_Utility.createInsertWebServiceDetails('Ship To Site Use Lookup');
        //Web_Service_Details__c oWebServiceDetailCreateRelationship = Test_Environment_Utility.createInsertWebServiceDetails('Create Relationship');

        ////Create Service_Contract__c for testing
        ////Service_Contract__c oServiceContract = Test_Environment_Utility.createInsertServiceContract('APEX TEST', oAccountEndUser, oAccountDistributor, oAccountReseller, oProductService, oContact);
		//ServiceContract oServiceContract = Test_Environment_Utility.createInsertServiceContract('APEX TEST', oAccountEndUser, oAccountDistributor, oAccountReseller, oProductService, oContact, objServicePB);

        ////Create Case for testing
        //Case oServiceRequest = Test_Environment_Utility.createInsertCase(oAccountEndUser,oContact, null, null);
    //}
	
	//static testMethod void createSOFromSC() {
		////Create new Sales_Order__c from Service_Contract__c record

		////Method variables
		//Boolean bFoundMessage=false;

		////Retrieve test data
		//ServiceContract oServiceContract = [select Id from ServiceContract limit 1];
		//Map<String, Oracle_Order_Type__c> mapOrderTypeCustomSetting = Oracle_Order_Type__c.getAll();
		//Map<String, Oracle_Return_Reason__c> mapReturnReasonCustomSetting = Oracle_Return_Reason__c.getAll();
		//Product2 oProductFG = [select Id from Product2 where Item_Type__c='E-FG'];

		////Create new Sales_Order__c record
		//Sales_Order__c oSalesOrder = new Sales_Order__c();

		//Test.startTest();
	       	////Set page reference
	       	//PageReference oPageRefSave = Page.SalesOrderNew;
	       	//Test.setCurrentPage(oPageRefSave); 

	       	////Invoke standard controller and populate URL parameters
	       	//ApexPages.StandardController oStdControllerSave = new ApexPages.StandardController(oSalesOrder);
	       	//oPageRefSave.getParameters().put('rtype','SC');
	       	//oPageRefSave.getParameters().put('rid',String.valueOf(oServiceContract.Id));
	       	//Sales_Order_New_Controller oExtControllerSave = new Sales_Order_New_Controller(oStdControllerSave);

			////**BEGIN: Test Save, order type validation.
	        //system.assertEquals(null,oExtControllerSave.saveSalesOrder());
	        ////Assert page messages
	        //bFoundMessage=false;
	        //for(ApexPages.Message oMessage :ApexPages.getMessages()) {
	            //if(!String.isEmpty(oMessage.getDetail())) {
	                //bFoundMessage=true;
	            //}
	        //}   
	        //system.assert(bFoundMessage);

	        ////Select Order type of "RETURN" and save
	        //oExtControllerSave.sOrderTypeId=oExtControllerSave.mapOrderTypes.get('RETURN');
	        //oExtControllerSave.setOrderType();
	        //oExtControllerSave.saveSalesOrder();

	        ////Retrieve sales order and verify that order type values were set correctly
	        //oSalesOrder = [select Id, Order_Type_Id__c, Order_Type__c from Sales_Order__c limit 1];
	        //system.assertEquals(mapOrderTypeCustomSetting.get('RETURN').Order_Type_Id__c,oSalesOrder.Order_Type_Id__c);
	        //system.assertEquals(mapOrderTypeCustomSetting.get('RETURN').Order_Type_Id__c,oSalesOrder.Order_Type__c);
	        ////**END: Test Save, order type validation.

	        ////**BEGIN: Test Save, sales order line validation.
	        //oPageRefSave = Page.SalesOrderNew;
	       	//Test.setCurrentPage(oPageRefSave); 

	       	////Invoke standard controller and extension contollers
	       	//oStdControllerSave = new ApexPages.StandardController(oSalesOrder);
	       	//oExtControllerSave = new Sales_Order_New_Controller(oStdControllerSave);

	       	////Add new line item with no quantity selected
	       	//Sales_Order_Line__c oSalesOrderLine = new Sales_Order_Line__c();
	       	//oSalesOrderLine.Part_Number__c=oProductFG.Id;
	       	//oExtControllerSave.listSalesOrderLines.add(oSalesOrderLine);

			////Assert Save error, no quantity selected on sales order line
	        //system.assertEquals(null,oExtControllerSave.saveSalesOrder());
	        ////Assert page messages
	        //bFoundMessage=false;
	        //for(ApexPages.Message oMessage :ApexPages.getMessages()) {
	            //if(!String.isEmpty(oMessage.getDetail())) {
	                //bFoundMessage=true;
	            //}
	        //}   
	        //system.assert(bFoundMessage);
	        ////**END: Test Save, sales order line validation.

	        ////**BEGIN: Test Save, return reason line validation.
	        ////Set Sales_Order_Line__c Quantity__c value and save.  Assert save error, no return reason select
	        //oExtControllerSave.listSalesOrderLines.clear();
	        //oSalesOrderLine = new Sales_Order_Line__c();
	       	//oSalesOrderLine.Part_Number__c=oProductFG.Id;
	       	//oSalesOrderLine.Quantity__c=1;
	       	//oExtControllerSave.listSalesOrderLines.add(oSalesOrderLine);

	        //system.assertEquals(null,oExtControllerSave.saveSalesOrder());
	        ////Assert page messages
	        //bFoundMessage=false;
	        //for(ApexPages.Message oMessage :ApexPages.getMessages()) {
	            //if(!String.isEmpty(oMessage.getDetail())) {
	                //bFoundMessage=true;
	            //}
	        //}   
	        //system.assert(bFoundMessage);

	        ////Set Sales_Order_Line__c, Quantity__c, and Return_Reason__c values and save.  Assert successful save
	        //oExtControllerSave.listSalesOrderLines.clear();
	        //oSalesOrderLine = new Sales_Order_Line__c();
	       	//oSalesOrderLine.Part_Number__c=oProductFG.Id;
	       	//oSalesOrderLine.Quantity__c=1;
	       	//oSalesOrderLine.Return_Reason_Code__c=oExtControllerSave.mapReturnReasons.get('DEFECT');
	       	//oExtControllerSave.listSalesOrderLines.add(oSalesOrderLine);

	       	//system.assertEquals('/'+oSalesOrder.Id,oExtControllerSave.saveSalesOrder().getURL());
	       	////**END: Test Save, return reason line validation.

	       	////Remove sales order line
	       	//oExtControllerSave.sSelectedLineItem='1';
	       	//oExtControllerSave.removeNewSalesOrderLine();

	       	////Assert sales order line list size of 0
	       	//system.assertEquals(0,oExtControllerSave.listSalesOrderLines.size());

	       	////Add sales order line using controller extension action method
	       	//oExtControllerSave.addNewSalesOrderLine();
			////Assert sales order line list size of 1
	       	//system.assertEquals(1,oExtControllerSave.listSalesOrderLines.size());

	        ////Select Order type of "MAINTENANCE" and save
	        //oExtControllerSave.sOrderTypeId=oExtControllerSave.mapOrderTypes.get('MAINTENANCE');
	        //oExtControllerSave.setOrderType();
	        //oExtControllerSave.saveSalesOrder();

	        ////Retrieve sales order and assert order type
	        //oSalesOrder = [select Id, Order_Type_Id__c, Order_Type__c from Sales_Order__c limit 1];
	        //system.assertEquals(mapOrderTypeCustomSetting.get('MAINTENANCE').Order_Type_Id__c,oSalesOrder.Order_Type_Id__c);
	        //system.assertEquals(mapOrderTypeCustomSetting.get('MAINTENANCE').Order_Type_Id__c,oSalesOrder.Order_Type__c);

	        ////Select Order type of "TRF" and save
	        //oExtControllerSave.sOrderTypeId=oExtControllerSave.mapOrderTypes.get('TRF');
	        //oExtControllerSave.setOrderType();
	        //oExtControllerSave.saveSalesOrder();

	        ////Retrieve sales order and assert order type
	        //oSalesOrder = [select Id, Order_Type_Id__c, Order_Type__c, Ship_To_Org_Id__c, Order_Submitted__c, Total_Quantity__c from Sales_Order__c limit 1];
	        //system.assertEquals(mapOrderTypeCustomSetting.get('TRF').Order_Type_Id__c,oSalesOrder.Order_Type_Id__c);
	        //system.assertEquals(mapOrderTypeCustomSetting.get('TRF').Order_Type_Id__c,oSalesOrder.Order_Type__c);

	       	////Submit order.  Assert no sales order lines (total quantity=0)
	       	////Set page reference for sales order submit page
	       	//PageReference oPageRefSubmit = Page.SalesOrderSubmit;
	       	//Test.setCurrentPage(oPageRefSubmit); 

	       	////Invoke standard controller and populate URL parameters
	       	//ApexPages.StandardController oStdControllerSubmit = new ApexPages.StandardController(oSalesOrder);
	       	//oPageRefSubmit.getParameters().put('id',oSalesOrder.Id);
	       	//Sales_Order_Submit_Controller oExtControllerSubmit = new Sales_Order_Submit_Controller(oStdControllerSubmit);

	       	//system.assertEquals('/apex/salesordersummary?id=' + oSalesOrder.Id,oExtControllerSubmit.submitSalesOrder().getURL());

	        ////Set Sales_Order_Line__c and Quantity__c values and save.  Assert successful save
	        //oExtControllerSave.listSalesOrderLines.clear();
	        //oSalesOrderLine = new Sales_Order_Line__c();
	       	//oSalesOrderLine.Part_Number__c=oProductFG.Id;
	       	//oSalesOrderLine.Quantity__c=1;
	       	//oExtControllerSave.listSalesOrderLines.add(oSalesOrderLine);

	       	//system.assertEquals('/'+oSalesOrder.Id,oExtControllerSave.saveSalesOrder().getURL());

	       	////Retrieve sales order
	       	//oSalesOrder = [select Id, Order_Type_Id__c, Order_Type__c, Ship_To_Org_Id__c, Order_Submitted__c, Total_Quantity__c from Sales_Order__c limit 1];

			////Submit order.  Assert no ship to address selected
	       	////Set page reference for sales order submit page
	       	//oPageRefSubmit = Page.SalesOrderSubmit;
	       	//Test.setCurrentPage(oPageRefSubmit); 

	       	////Invoke standard controller and populate URL parameters
	       	//oStdControllerSubmit = new ApexPages.StandardController(oSalesOrder);
	       	//oPageRefSave.getParameters().put('id',oSalesOrder.Id);
	       	//oExtControllerSubmit = new Sales_Order_Submit_Controller(oStdControllerSubmit);

	       	//system.assertEquals(true,oExtControllerSubmit.bMissingShipToLocation);
	       	//system.assertEquals('/apex/salesorderselectshipto?id=' + oSalesOrder.Id,oExtControllerSubmit.submitSalesOrder().getURL());

	       	////Set Ship_To_Org_Id__c and submit.  Assert success and redirect to salesordersummary page
	       	//oSalesOrder.Ship_To_Org_Id__c='12345';
	       	//update oSalesOrder;

	       	////Retrieve sales order
	       	//oSalesOrder = [select Id, Order_Type_Id__c, Order_Type__c, Ship_To_Org_Id__c, Order_Submitted__c, Total_Quantity__c from Sales_Order__c limit 1];
	       	
	       	////Invoke standard controller and populate URL parameters
	       	//oStdControllerSubmit = new ApexPages.StandardController(oSalesOrder);
	       	//oPageRefSave.getParameters().put('id',oSalesOrder.Id);
	       	//oExtControllerSubmit = new Sales_Order_Submit_Controller(oStdControllerSubmit);

	       	//system.assertEquals('/apex/salesorderconfirmation?id=' + oSalesOrder.Id,oExtControllerSubmit.submitSalesOrder().getURL());

	       	////Confirm order.  Assertions for edit and select ship to
	       	////Retrieve sales order
	       	//oSalesOrder = [select Id, Ship_To_Contact_Role_Id__c, Ship_To_Customer__r.Oracle_Party_Id__c, Ship_To_Customer_Account_New__c, Ship_To_Customer_Id__c, 
	       					//Ship_To_Org_Id__c, Bill_To_Customer_Account_New__c, Bill_To_Customer_Id__c, Order_Submitted__c, Date_Time_Submitted__c, ORIG_SYS_DOCUMENT_REF__c
	       					//from Sales_Order__c limit 1];

	       	////Set page reference for sales order confirmation page
	       	//PageReference oPageRefConfirm = Page.SalesOrderConfirmation;
	       	//Test.setCurrentPage(oPageRefConfirm); 

	       	////Invoke standard controller and populate URL parameters
	       	//ApexPages.StandardController oStdControllerConfirm = new ApexPages.StandardController(oSalesOrder);
	       	//oPageRefConfirm.getParameters().put('id',oSalesOrder.Id);
	       	//Sales_Order_Confirmation_Cntrl oExtControllerConfirm = new Sales_Order_Confirmation_Cntrl(oStdControllerConfirm);

	       	//system.assertEquals('/' + oSalesOrder.Id + '/e?retURL=%2F' + oSalesOrder.Id,oExtControllerConfirm.editOrderDetails().getURL());
	       	//system.assertEquals('/apex/salesorderselectshipto?id=' + oSalesOrder.Id,oExtControllerConfirm.selectShipTo().getURL());

	       	////Set order to submitted.  Assert redirect to summary page displaying order submission details.
	       	//oSalesOrder.Order_Submitted__c=true;
	       	//oSalesOrder.Date_Time_Submitted__c=Datetime.now();
	       	//update oSalesOrder;

			////Retrieve sales order
	       	//oSalesOrder = [select Id, Ship_To_Contact_Role_Id__c, Ship_To_Customer__r.Oracle_Party_Id__c, Ship_To_Customer_Account_New__c, Ship_To_Customer_Id__c, Service_Contract__c,
	       					//Ship_To_Org_Id__c, Bill_To_Customer_Account_New__c, Bill_To_Customer_Id__c, Order_Submitted__c, Date_Time_Submitted__c, ORIG_SYS_DOCUMENT_REF__c
	       					//from Sales_Order__c limit 1];
	       	
	       	////Invoke standard controller and populate URL parameters
	       	//oStdControllerSubmit = new ApexPages.StandardController(oSalesOrder);
	       	//oPageRefSave.getParameters().put('id',oSalesOrder.Id);
	       	//oExtControllerSubmit = new Sales_Order_Submit_Controller(oStdControllerSubmit);

	       	//system.assertEquals('/apex/salesordersummary?id=' + oSalesOrder.Id,oExtControllerSubmit.submitSalesOrder().getURL());

	       	////Order summary testing
	       	////Set page reference for sales order summary page
	       	//PageReference oPageRefSummary = Page.SalesOrderSummary;
	       	//Test.setCurrentPage(oPageRefSummary); 

	       	////Invoke standard controller and populate URL parameters
	       	//ApexPages.StandardController oStdControllerSummary = new ApexPages.StandardController(oSalesOrder);
	       	//oPageRefSummary.getParameters().put('id',oSalesOrder.Id);
	       	//Sales_Order_Summary_Controller oExtControllerSummary = new Sales_Order_Summary_Controller(oStdControllerSummary);

	       	//system.assertEquals(oSalesOrder.Date_Time_Submitted__c.format(),oExtControllerSummary.getFormattedSubmissionDate());
	       	//system.assertEquals('/' + oSalesOrder.Id,oExtControllerSummary.returnToSalesOrder().getURL());
	       	//system.assertEquals('/' + oServiceContract.Id,oExtControllerSummary.returnToServiceContract().getURL());

	       	////Attempt to delete sales order line on submitted Sales_Order__c
	       	//try{
	       		//delete [select Id from Sales_Order_Line__c limit 1];
	       	//}
	       	//catch(Exception oException){
				//system.assertEquals(true,oException.getMessage().contains('This sales order line cannot be deleted because it has already been submitted to Oracle.'));
	       	//}

	       	////Attempt to delete Sales_Order__c that has already been submitted
	       	//try{
	       		//delete [select Id from Sales_Order__c limit 1];
	       	//}
	       	//catch(Exception oException){
	       		//system.assertEquals(true,oException.getMessage().contains('This sales order cannot be deleted because it has already been submitted to Oracle.'));
			//}

			////Test Sales_Order_Line__c view override
	       	////Retrieve Sales_Order_Line__c
	       	//Sales_Order_Line__c oSalesOrderLineOverride = [select Id, Sales_Order__c from Sales_Order_Line__c limit 1];
	       	////Set page reference for overrideSalesOrderLine page

	       	//PageReference oPageRefSalesOrderLineOverride = Page.overrideSalesOrderLineView;
	       	//Test.setCurrentPage(oPageRefSalesOrderLineOverride); 

	       	////Invoke standard controller and populate URL parameters
	       	//ApexPages.StandardController oStdControllerSalesOrderLine= new ApexPages.StandardController(oSalesOrderLineOverride);
	       	//oPageRefSalesOrderLineOverride.getParameters().put('id',oSalesOrderLineOverride.Id);
	       	//Sales_Order_Line_Override oExtControllerSalesOrderLine = new Sales_Order_Line_Override(oStdControllerSalesOrderLine);

	       	//system.assertEquals('/' + oSalesOrderLine.Sales_Order__c,oExtControllerSalesOrderLine.redirect().getURL());
			
	    //Test.stopTest();
	//}

	//static testMethod void createSOFromSR() {
		////Create new Sales_Order__c from Service Request (Case)

		////Method variables
		//Boolean bFoundMessage=false;

		////Retrieve test data
		//Case oServiceRequest = [select Id from Case limit 1];
		//Product2 oProductFG = [select Id from Product2 where Item_Type__c='E-FG'];

		////Create new Sales_Order__c record
		//Sales_Order__c oSalesOrder = new Sales_Order__c();

		//Test.startTest();
	       	////Set page reference
	       	//PageReference oPageRefSave = Page.SalesOrderNew;
	       	//Test.setCurrentPage(oPageRefSave); 

	       	////Invoke standard controller and populate URL parameters
	       	//ApexPages.StandardController oStdControllerSave = new ApexPages.StandardController(oSalesOrder);
	       	//oPageRefSave.getParameters().put('rtype','SR');
	       	//oPageRefSave.getParameters().put('rid',String.valueOf(oServiceRequest.Id));
			//Sales_Order_New_Controller oExtControllerSave = new Sales_Order_New_Controller(oStdControllerSave);
	        
	        ////Select Order type of "RETURN" and save
	        //oExtControllerSave.sOrderTypeId=oExtControllerSave.mapOrderTypes.get('RETURN');
	        //oExtControllerSave.setOrderType();
	        //oExtControllerSave.saveSalesOrder();

	        ////Retrieve sales order created above
	        //oSalesOrder = [select Id, Order_Type__c from Sales_Order__c where Id = :oSalesOrder.Id];

	        ////Begin test, add sales order line item using SalesOrderLineNew.page
	        //Sales_Order_Line__c oSalesOrderLine = new Sales_Order_Line__c();

	        //PageReference oPageRefSalesOrderLine = Page.SalesOrderLineNew;
	       	//Test.setCurrentPage(oPageRefSalesOrderLine); 

	       	//ApexPages.StandardController oStdControllerSalesOrderLine = new ApexPages.StandardController(oSalesOrderLine);
	       	//oPageRefSalesOrderLine.getParameters().put('soid',oSalesOrder.Id);
			//Sales_Order_Line_New_Controller oExtControllerSalesOrderLine = new Sales_Order_Line_New_Controller(oStdControllerSalesOrderLine);

			//oSalesOrderLine.Part_Number__c=oProductFG.Id;
			//oSalesOrderLine.Quantity__c=1;

			////Invoke save method, assert error for return reason required
	        //system.assertEquals(null,oExtControllerSalesOrderLine.saveSalesOrderLine());
	        ////Assert page messages
	        //bFoundMessage=false;
	        //for(ApexPages.Message oMessage :ApexPages.getMessages()) {
	            //if(!String.isEmpty(oMessage.getDetail())) {
	                //bFoundMessage=true;
	            //}
	        //}   
	        //system.assert(bFoundMessage);

	        ////Set return reason and assert successful save
			//oSalesOrderLine.Part_Number__c=oProductFG.Id;
			//oSalesOrderLine.Quantity__c=1;
			//oExtControllerSalesOrderLine.sReturnReason=oExtControllerSalesOrderLine.mapReturnReasons.get('DEFECT');

			//system.assertEquals('/' + oSalesOrder.Id,oExtControllerSalesOrderLine.saveSalesOrderLine().getURL());

			////Retrieve the sales order line and edit, assert successful save
			//oSalesOrderLine = [select Id, Return_Reason_Code__c, Sales_Order__r.Order_Type__c from Sales_Order_Line__c where Sales_Order__c = :oSalesOrder.Id];

			//oPageRefSalesOrderLine = Page.SalesOrderLineNew;
	       	//Test.setCurrentPage(oPageRefSalesOrderLine);

			//oStdControllerSalesOrderLine = new ApexPages.StandardController(oSalesOrderLine);
	       	//oPageRefSalesOrderLine.getParameters().put('soid',oSalesOrder.Id);
	       	//oPageRefSalesOrderLine.getParameters().put('id',oSalesOrderLine.Id);
			//oExtControllerSalesOrderLine = new Sales_Order_Line_New_Controller(oStdControllerSalesOrderLine);

			//oExtControllerSalesOrderLine.oSalesOrderLine.Quantity__c=10;
			//system.assertEquals('/' + oSalesOrder.Id,oExtControllerSalesOrderLine.saveSalesOrderLine().getURL());

			////Set Ship_To_Org_Id__c, Order_Submitted__c, and Date_Time_Submitted__con Sales_Order__c
			//oSalesOrder.Ship_To_Org_Id__c='12345';
			//oSalesOrder.Order_Submitted__c=true;
			//oSalesOrder.Date_Time_Submitted__c=Datetime.now();
			//update oSalesOrder;

			////Retrieve sales order details, invoke summary page, and assert return to service request method
			//oSalesOrder = [select Id, Ship_To_Contact_Role_Id__c, Ship_To_Customer__r.Oracle_Party_Id__c, Ship_To_Customer_Account_New__c, Ship_To_Customer_Id__c, Service_Request__c,
	       					//Ship_To_Org_Id__c, Bill_To_Customer_Account_New__c, Bill_To_Customer_Id__c, Order_Submitted__c, Date_Time_Submitted__c, ORIG_SYS_DOCUMENT_REF__c
	       					//from Sales_Order__c limit 1];

	        //PageReference oPageRefSummary = Page.SalesOrderSummary;
	       	//Test.setCurrentPage(oPageRefSummary); 

	       	//ApexPages.StandardController oStdControllerSalesOrderSummary = new ApexPages.StandardController(oSalesOrder);
	       	//oPageRefSalesOrderLine.getParameters().put('id',oSalesOrder.Id);
			//Sales_Order_Summary_Controller oExtControllerSalesOrderSummary = new Sales_Order_Summary_Controller(oStdControllerSalesOrderSummary);	

			//system.assertEquals('/' + oServiceRequest.Id,oExtControllerSalesOrderSummary.returnToServiceRequest().getURL());       
	    //Test.stopTest();
	//}

	//static testMethod void testSelectShipTo() {
		////Test web service callout to select ship to location

		////Get previously created test data
		//Account oAccount=[select Id from Account limit 1];
		//Contact oContact=[select Id from Contact limit 1];
		//Product2 oProductFG = [select Id from Product2 where Item_Type__c='E-FG'];

		////Create Sales_Order__c record
		//Sales_Order__c oSalesOrder = new Sales_Order__c();
		//oSalesOrder.Bill_To_Customer__c=oAccount.Id;
		//oSalesOrder.Ship_To_Customer__c=oAccount.Id;
		//oSalesOrder.Order_Type_Id__c='MAINTENANCE';
		//oSalesOrder.Order_Type__c='MAINTENANCE';
		//oSalesOrder.Ship_To_Contact__c=oContact.Id;
		//oSalesOrder.Customer_PO_Number__c='APEXTEST';

		//insert oSalesOrder;

		////Create Sales_Order_Line__c record
		//Sales_Order_Line__c oSalesOrderLine = new Sales_Order_Line__c();
		//oSalesOrderLine.Sales_Order__c=oSalesOrder.Id;
		//oSalesOrderLine.Part_Number__c=oProductFG.Id;
		//oSalesOrderLine.Quantity__c=1;

		//insert oSalesOrderLine;

		//Test.startTest();
			////Set up mock web service request
			//SingleHTTPRequestMock_Test oFakeResponseTrigger = new SingleHTTPRequestMock_Test(200,
	                                                        //'Complete',
	                                                        //'['+
	            //'  {'+
	            //'    \"__type\": \"RepLocator.Site\",'+
	            //'    \"SiteUseId\": \"611088\",'+
	            //'    \"LocationName\": \"CHAMPAIGN 2109\",'+
	            //'    \"CustomerName\": \"AMDOCS\",'+
	            //'    \"CustomerNumber\": \"147872\",'+
	            //'    \"Address1\": \"2109 FOX DR\",'+
	            //'    \"CityStateZipCountry\": \"CHAMPAIGN,IL, 61820, US\",'+
	            //'    \"Address2\": \"\",'+
	            //'    \"Address3\": \"\",'+
	            //'    \"Address4\": \"\",'+
	            //'    \"AccountDescription\": \"DOMESTIC\",'+
	            //'    \"PartyNumber\": \"303075\"'+
	            //'  }'+
	            //']'
	             //, null);
	        
	        //Test.setMock(HttpCalloutMock.class, oFakeResponseTrigger);

			////Retrieve sales order
	       	//oSalesOrder = [select Id, Order_Type_Id__c, Order_Type__c, Bill_To_Customer__c, Ship_To_Customer__c, Order_Submitted__c from Sales_Order__c limit 1];

	        //PageReference oPageRefSelectShipTo = Page.SalesOrderSelectShipTo;
	        //Test.setCurrentPage(oPageRefSelectShipTo);
	        ////Invoke the standard and extension controllers with Sales_Order__c created above
	        //ApexPages.StandardController oStdControllerSelectShipTo = new ApexPages.StandardController(oSalesOrder);
	        ////Add the selected ship to id and Sales_Order__c.Id parameters to the page
	        //oPageRefSelectShipTo.getParameters().put('shipLocId','611088');
	        //oPageRefSelectShipTo.getParameters().put('id',String.valueOf(oSalesOrder.Id));
	        //Sales_Order_Select_Ship_To_Cntrl oExtControllerSelectShipTo = new Sales_Order_Select_Ship_To_Cntrl(oStdControllerSelectShipTo);         
	        
	        ////Assert page reference returned for save/select with ship to
	        //System.assertEquals('/' + oSalesOrder.Id,oExtControllerSelectShipTo.shipToSelect().getURL());

	        ////Set order submitted = true
	        //oSalesOrder.Order_Submitted__c=true;
	        //oSalesOrder.Date_Time_Submitted__c=Datetime.now();
	        //update oSalesOrder;

			////Retrieve sales order and assert order submitted flag
	       	//oSalesOrder = [select Id, Order_Type_Id__c, Order_Type__c, Bill_To_Customer__c, Ship_To_Customer__c, Order_Submitted__c from Sales_Order__c limit 1];

	        //oPageRefSelectShipTo = Page.SalesOrderSelectShipTo;
	        //Test.setCurrentPage(oPageRefSelectShipTo);
	        ////Invoke the standard and extension controllers with Sales_Order__c retrieved above
	        //oStdControllerSelectShipTo = new ApexPages.StandardController(oSalesOrder);
			////Add the selected ship to id and Sales_Order__c.Id parameters to the page
	        //oPageRefSelectShipTo.getParameters().put('id',String.valueOf(oSalesOrder.Id));
	        //oExtControllerSelectShipTo = new Sales_Order_Select_Ship_To_Cntrl(oStdControllerSelectShipTo);  

	        //system.assertEquals(true,oExtControllerSelectShipTo.bOrderSubmitted);
		//Test.stopTest();
	//}

	//static testMethod void testSelectShipToBillTo() {
		////Test web service callout to select ship to location when ship to and bill to customers are different

		////Get previously created test data
		//Account oAccountShipTo=[select Id from Account limit 1];
		//Account oAccountBillTo=[select Id from Account where Id !=:oAccountShipTo.Id limit 1];
		//Contact oContact=[select Id from Contact limit 1];
		//Product2 oProductFG = [select Id from Product2 where Item_Type__c='E-FG'];

		////Create Sales_Order__c record
		//Sales_Order__c oSalesOrder = new Sales_Order__c();
		//oSalesOrder.Bill_To_Customer__c=oAccountShipTo.Id;
		//oSalesOrder.Ship_To_Customer__c=oAccountBillTo.Id;
		//oSalesOrder.Order_Type_Id__c='MAINTENANCE';
		//oSalesOrder.Order_Type__c='MAINTENANCE';
		//oSalesOrder.Ship_To_Contact__c=oContact.Id;
		//oSalesOrder.Customer_PO_Number__c='APEXTEST';

		//insert oSalesOrder;

		////Create Sales_Order_Line__c record
		//Sales_Order_Line__c oSalesOrderLine = new Sales_Order_Line__c();
		//oSalesOrderLine.Sales_Order__c=oSalesOrder.Id;
		//oSalesOrderLine.Part_Number__c=oProductFG.Id;
		//oSalesOrderLine.Quantity__c=1;

		//insert oSalesOrderLine;

		//Test.startTest();
			////Set up mock web service request
			//SingleHTTPRequestMock_Test oFakeResponseTrigger = new SingleHTTPRequestMock_Test(200,
	                                                        //'Complete',
	                                                        //'['+
	            //'  {'+
	            //'    \"__type\": \"RepLocator.Site\",'+
	            //'    \"SiteUseId\": \"611088\",'+
	            //'    \"LocationName\": \"CHAMPAIGN 2109\",'+
	            //'    \"CustomerName\": \"AMDOCS\",'+
	            //'    \"CustomerNumber\": \"147872\",'+
	            //'    \"Address1\": \"2109 FOX DR\",'+
	            //'    \"CityStateZipCountry\": \"CHAMPAIGN,IL, 61820, US\",'+
	            //'    \"Address2\": \"\",'+
	            //'    \"Address3\": \"\",'+
	            //'    \"Address4\": \"\",'+
	            //'    \"AccountDescription\": \"DOMESTIC\",'+
	            //'    \"PartyNumber\": \"303075\"'+
	            //'  }'+
	            //']'
	             //, null);
	        
	        //Test.setMock(HttpCalloutMock.class, oFakeResponseTrigger);

			////Retrieve sales order
	       	//oSalesOrder = [select Id, Order_Type_Id__c, Order_Type__c, Bill_To_Customer__c, Ship_To_Customer__c, Order_Submitted__c from Sales_Order__c limit 1];

	        //PageReference oPageRefSelectShipTo = Page.SalesOrderSelectShipTo;
	        //Test.setCurrentPage(oPageRefSelectShipTo);
	        ////Invoke the standard and extension controllers with Sales_Order__c created above
	        //ApexPages.StandardController oStdControllerSelectShipTo = new ApexPages.StandardController(oSalesOrder);
	        ////Add the selected ship to id and Sales_Order__c.Id parameters to the page
	        //oPageRefSelectShipTo.getParameters().put('shipLocId','611088');
	        //oPageRefSelectShipTo.getParameters().put('id',String.valueOf(oSalesOrder.Id));
	        //Sales_Order_Select_Ship_To_Cntrl oExtControllerSelectShipTo = new Sales_Order_Select_Ship_To_Cntrl(oStdControllerSelectShipTo);         
	        
	        ////Assert page reference returned for save/select with ship to
	        //System.assertEquals('/' + oSalesOrder.Id,oExtControllerSelectShipTo.shipToSelect().getURL());

	        ////Set order submitted = true
	        //oSalesOrder.Order_Submitted__c=true;
	        //oSalesOrder.Date_Time_Submitted__c=Datetime.now();
	        //update oSalesOrder;

			////Retrieve sales order and assert order submitted flag
	       	//oSalesOrder = [select Id, Order_Type_Id__c, Order_Type__c, Bill_To_Customer__c, Ship_To_Customer__c, Order_Submitted__c from Sales_Order__c limit 1];

	        //oPageRefSelectShipTo = Page.SalesOrderSelectShipTo;
	        //Test.setCurrentPage(oPageRefSelectShipTo);
	        ////Invoke the standard and extension controllers with Sales_Order__c retrieved above
	        //oStdControllerSelectShipTo = new ApexPages.StandardController(oSalesOrder);
			////Add the selected ship to id and Sales_Order__c.Id parameters to the page
	        //oPageRefSelectShipTo.getParameters().put('id',String.valueOf(oSalesOrder.Id));
	        //oExtControllerSelectShipTo = new Sales_Order_Select_Ship_To_Cntrl(oStdControllerSelectShipTo);  

	        //system.assertEquals(true,oExtControllerSelectShipTo.bOrderSubmitted);
		//Test.stopTest();
	//}

	//static testMethod void testSelectShipException1() {
		////Exception testing for select ship to logic

		////Create Accounts for testing
		//Account oAccountShipTo = Test_Environment_Utility.createInsertAccountUS();
		//Contact oContact = Test_Environment_Utility.createInsertContact(oAccountShipTo);

		////Modify Account so query fails
		//oAccountShipTo.Oracle_Party_Status__c = 'd';
		//update oAccountShipTo;

		////Get previously created data
		//Product2 oProductFG = [select Id from Product2 where Item_Type__c='E-FG'];

		////Create Sales_Order__c record
		//Sales_Order__c oSalesOrder = new Sales_Order__c();
		//oSalesOrder.Bill_To_Customer__c=oAccountShipTo.Id;
		//oSalesOrder.Ship_To_Customer__c=oAccountShipTo.Id;
		//oSalesOrder.Order_Type_Id__c='MAINTENANCE';
		//oSalesOrder.Order_Type__c='MAINTENANCE';
		//oSalesOrder.Ship_To_Contact__c=oContact.Id;
		//oSalesOrder.Customer_PO_Number__c='APEXTEST';

		//insert oSalesOrder;

		////Create Sales_Order_Line__c record
		//Sales_Order_Line__c oSalesOrderLine = new Sales_Order_Line__c();
		//oSalesOrderLine.Sales_Order__c=oSalesOrder.Id;
		//oSalesOrderLine.Part_Number__c=oProductFG.Id;
		//oSalesOrderLine.Quantity__c=1;

		//insert oSalesOrderLine;

		//Test.startTest();
			////Retrieve sales order
	       	//oSalesOrder = [select Id, Order_Type_Id__c, Order_Type__c, Bill_To_Customer__c, Ship_To_Customer__c, Order_Submitted__c from Sales_Order__c limit 1];

	        //PageReference oPageRefSelectShipTo = Page.SalesOrderSelectShipTo;
	        //Test.setCurrentPage(oPageRefSelectShipTo);
	        ////Invoke the standard and extension controllers with Sales_Order__c created above
	        //ApexPages.StandardController oStdControllerSelectShipTo = new ApexPages.StandardController(oSalesOrder);
	        ////Add the selected ship to id and Sales_Order__c.Id parameters to the page
	        //oPageRefSelectShipTo.getParameters().put('id',String.valueOf(oSalesOrder.Id));
	        //Sales_Order_Select_Ship_To_Cntrl oExtControllerSelectShipTo = new Sales_Order_Select_Ship_To_Cntrl(oStdControllerSelectShipTo);

	        ////Assert NULL values for web service response list and map
	        //system.assertEquals(null,oExtControllerSelectShipTo.listShipToSiteUseLookupResponses);
	        //system.assertEquals(null,oExtControllerSelectShipTo.mapShipToSiteUseLookupResponses);
		//Test.stopTest();
	//}

	//static testMethod void testSelectShipException2() {
		////Exception testing for select ship to logic

		////Create Accounts for testing
		//Account oAccountShipTo = Test_Environment_Utility.createInsertAccountUS();
		//Account oAccountBillTo = Test_Environment_Utility.createInsertAccountUS();
		//Contact oContact = Test_Environment_Utility.createInsertContact(oAccountShipTo);

		////Get previously created data
		//Product2 oProductFG = [select Id from Product2 where Item_Type__c='E-FG'];

		////Create Sales_Order__c record
		//Sales_Order__c oSalesOrder = new Sales_Order__c();
		//oSalesOrder.Bill_To_Customer__c=oAccountShipTo.Id;
		//oSalesOrder.Ship_To_Customer__c=oAccountBillTo.Id;
		//oSalesOrder.Order_Type_Id__c='MAINTENANCE';
		//oSalesOrder.Order_Type__c='MAINTENANCE';
		//oSalesOrder.Ship_To_Contact__c=oContact.Id;
		//oSalesOrder.Customer_PO_Number__c='APEXTEST';

		//insert oSalesOrder;

		////Create Sales_Order_Line__c record
		//Sales_Order_Line__c oSalesOrderLine = new Sales_Order_Line__c();
		//oSalesOrderLine.Sales_Order__c=oSalesOrder.Id;
		//oSalesOrderLine.Part_Number__c=oProductFG.Id;
		//oSalesOrderLine.Quantity__c=1;

		//insert oSalesOrderLine;

		////Modify Account so query fails
		//oAccountShipTo.Oracle_Party_Status__c = 'd';
		//update oAccountShipTo;

		//Test.startTest();
			////Retrieve sales order
	       	//oSalesOrder = [select Id, Order_Type_Id__c, Order_Type__c, Bill_To_Customer__c, Ship_To_Customer__c, Order_Submitted__c from Sales_Order__c limit 1];

	        //PageReference oPageRefSelectShipTo = Page.SalesOrderSelectShipTo;
	        //Test.setCurrentPage(oPageRefSelectShipTo);
	        ////Invoke the standard and extension controllers with Sales_Order__c created above
	        //ApexPages.StandardController oStdControllerSelectShipTo = new ApexPages.StandardController(oSalesOrder);
	        ////Add the selected ship to id and Sales_Order__c.Id parameters to the page
	        //oPageRefSelectShipTo.getParameters().put('id',String.valueOf(oSalesOrder.Id));
	        //Sales_Order_Select_Ship_To_Cntrl oExtControllerSelectShipTo = new Sales_Order_Select_Ship_To_Cntrl(oStdControllerSelectShipTo);

	        ////Assert NULL values for web service response list and map
	        //system.assertEquals(null,oExtControllerSelectShipTo.listShipToSiteUseLookupResponses);
	        //system.assertEquals(null,oExtControllerSelectShipTo.mapShipToSiteUseLookupResponses);
		//Test.stopTest();
	//}

	//static testMethod void testSelectShipException3() {
		////Exception testing for select ship to logic

		////Create Accounts for testing
		//Account oAccountShipTo = Test_Environment_Utility.createInsertAccountUS();
		////Customer_Account__c oCustomerAccountShipTo = Test_Environment_Utility.createInsertCustomerAccount(oAccountShipTo);
		//Account oAccountBillTo = Test_Environment_Utility.createInsertAccountUS();
		//Contact oContact = Test_Environment_Utility.createInsertContact(oAccountShipTo);

		////Get previously created data
		//Product2 oProductFG = [select Id from Product2 where Item_Type__c='E-FG'];

		////Create Sales_Order__c record
		//Sales_Order__c oSalesOrder = new Sales_Order__c();
		//oSalesOrder.Bill_To_Customer__c=oAccountShipTo.Id;
		//oSalesOrder.Ship_To_Customer__c=oAccountBillTo.Id;
		//oSalesOrder.Order_Type_Id__c='MAINTENANCE';
		//oSalesOrder.Order_Type__c='MAINTENANCE';
		//oSalesOrder.Ship_To_Contact__c=oContact.Id;
		//oSalesOrder.Customer_PO_Number__c='APEXTEST';

		//insert oSalesOrder;

		////Create Sales_Order_Line__c record
		//Sales_Order_Line__c oSalesOrderLine = new Sales_Order_Line__c();
		//oSalesOrderLine.Sales_Order__c=oSalesOrder.Id;
		//oSalesOrderLine.Part_Number__c=oProductFG.Id;
		//oSalesOrderLine.Quantity__c=1;

		//insert oSalesOrderLine;

		////Modify Account so query fails
		//oAccountShipTo.Oracle_Party_Status__c = 'd';
		//update oAccountShipTo;

		//Test.startTest();
			////Retrieve sales order
	       	//oSalesOrder = [select Id, Order_Type_Id__c, Order_Type__c, Bill_To_Customer__c, Ship_To_Customer__c, Order_Submitted__c from Sales_Order__c limit 1];

	        //PageReference oPageRefSelectShipTo = Page.SalesOrderSelectShipTo;
	        //Test.setCurrentPage(oPageRefSelectShipTo);
	        ////Invoke the standard and extension controllers with Sales_Order__c created above
	        //ApexPages.StandardController oStdControllerSelectShipTo = new ApexPages.StandardController(oSalesOrder);
	        ////Add the selected ship to id and Sales_Order__c.Id parameters to the page
	        //oPageRefSelectShipTo.getParameters().put('id',String.valueOf(oSalesOrder.Id));
	        //Sales_Order_Select_Ship_To_Cntrl oExtControllerSelectShipTo = new Sales_Order_Select_Ship_To_Cntrl(oStdControllerSelectShipTo);

	        ////Assert NULL values for web service response list and map
	        //system.assertEquals(null,oExtControllerSelectShipTo.listShipToSiteUseLookupResponses);
	        //system.assertEquals(null,oExtControllerSelectShipTo.mapShipToSiteUseLookupResponses);
		//Test.stopTest();
	//}

	//static testMethod void testConfirmationSuccess() {
		////Sales order confirmation - Web servcie callout testing.

		////Create data for testing
		//Account oAccountShipTo = Test_Environment_Utility.createInsertAccountUS();
		////Customer_Account__c oCustomerAccount = Test_Environment_Utility.createInsertCustomerAccount(oAccountShipTo);
		//Contact oContact = Test_Environment_Utility.createInsertContact(oAccountShipTo);

		////Get previously created data
		//Product2 oProductFG = [select Id from Product2 where Item_Type__c='E-FG'];

		////Create Sales_Order__c record
		//Sales_Order__c oSalesOrder = new Sales_Order__c();
		////oSalesOrder.Bill_To_Customer__c=oAccountShipTo.Id;
		////oSalesOrder.Ship_To_Customer__c=oAccountShipTo.Id;
		//oSalesOrder.Bill_To_Customer_Account_New__c=oAccountShipTo.Id;
		//oSalesOrder.Ship_To_Customer_Account_New__c=oAccountShipTo.Id;
		//oSalesOrder.Order_Type_Id__c='MAINTENANCE';
		//oSalesOrder.Order_Type__c='MAINTENANCE';
		//oSalesOrder.Ship_To_Contact__c=oContact.Id;
		//oSalesOrder.Customer_PO_Number__c='APEXTEST';
		//oSalesOrder.Ship_To_Org_Id__c='APEXTEST';

		//insert oSalesOrder;

		////Create Sales_Order_Line__c record
		//Sales_Order_Line__c oSalesOrderLine = new Sales_Order_Line__c();
		//oSalesOrderLine.Sales_Order__c=oSalesOrder.Id;
		//oSalesOrderLine.Part_Number__c=oProductFG.Id;
		//oSalesOrderLine.Quantity__c=1;

		//insert oSalesOrderLine;

		////Create Integration_Id__c for use in the web service response below
		//Integration_Id__c oIntegrationIdShipTo = Test_Environment_Utility.createInsertIntegrationId();
		//Integration_Id__c oIntegrationIdRelationship = Test_Environment_Utility.createInsertIntegrationId();

		//Test.startTest();
        	////Set up mock web service response for successful callout
            //SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(200,
                                                            //'OK',
                //'{'+
                //'  \"__type\": \"RepLocator.Customer\",'+
                //'  \"ip_verification_id\": \"' + oIntegrationIdShipTo.Id + '\",'+
                //'  \"ip_party_id\": \"\",'+
                //'  \"ip_cust_account_id\": \"\",'+
                //'  \"ip_ship_to_site_use_id\": \"\",'+
                //'  \"ip_organization_name\": \"\",'+
                //'  \"ip_account_name\": \"\",'+
                //'  \"ip_address1\": \"\",'+
                //'  \"ip_address2\": \"\",'+
                //'  \"ip_address3\": \"\",'+
                //'  \"ip_address4\": \"\",'+
                //'  \"ip_city\": \"\",'+
                //'  \"ip_state\": \"\",'+
                //'  \"ip_province\": \"\",'+
                //'  \"ip_postal_code\": \"\",'+
                //'  \"ip_country\": \"\",'+
                //'  \"ip_county\": \"\",'+
                //'  \"ip_person_first_name\": \"\",'+
                //'  \"ip_person_last_name\": \"\",'+
                //'  \"ip_raw_phone_number\": \"\",'+
                //'  \"ip_email_address\": \"\",'+
                //'  \"ip_is_bill_to_address\": \"\",'+
                //'  \"ip_is_ship_to_address\": \"\",'+
                //'  \"ip_salesforce_ref_id\": \"\",'+
                //'  \"op_party_id\": \"\",'+
                //'  \"op_party_number\": \"\",'+
                //'  \"op_cust_account_id\": \"\",'+
                //'  \"op_ship_to_site_use_id\": \"\",'+
                //'  \"op_bill_to_site_use_id\": \"\",'+
                //'  \"op_ship_to_contact_id\": \"21046994\",'+
                //'  \"op_cust_account_role_id\": \"19300031\",'+
                //'  \"op_return_status\": \"\",'+
                //'  \"op_return_message\": \"\"'+
                //'}'
                 //, null);
            //Test.setMock(HttpCalloutMock.class, oFakeResponse);

			////Retrieve sales order
	       	//oSalesOrder = [select Id, Ship_To_Contact_Role_Id__c, Ship_To_Customer__r.Oracle_Party_Id__c, Ship_To_Customer_Account_New__c, Ship_To_Customer_Id__c, 
	       					//Ship_To_Org_Id__c, Bill_To_Customer_Account_New__c, Bill_To_Customer_Id__c, Order_Submitted__c, Date_Time_Submitted__c, ORIG_SYS_DOCUMENT_REF__c,
	       					//Ship_To_Contact_First_Name__c, Ship_To_Contact_Last_Name__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Email__c
	       					//from Sales_Order__c limit 1];
            
            ////Create PageReference to the SalesOrderConfirmation
            //PageReference oPageRef = Page.SalesOrderConfirmation;
            //Test.setCurrentPage(oPageRef);

            ////Invoke the standard and extension controllers with the sales order retrieved above
            //ApexPages.StandardController oStdController = new ApexPages.StandardController(oSalesOrder);
            //ApexPages.currentPage().getParameters().put('id',oSalesOrder.id);
            //Sales_Order_Confirmation_Cntrl oExtController = new Sales_Order_Confirmation_Cntrl(oStdController);
            
            //system.assertEquals('/apex/salesordersummary?id=' + oSalesOrder.Id,oExtController.orderConfirmationSubmit().getURL());   
            
            ////Assert Sales_Order__c details
            //oSalesOrder=[select Id, Ship_To_Contact_Role_Id__c, Order_Submitted__c from Sales_Order__c where Id=:oSalesOrder.Id];
            //system.assertEquals('19300031',oSalesOrder.Ship_To_Contact_Role_Id__c);
            //system.assertEquals(true,oSalesOrder.Order_Submitted__c); 
		//Test.stopTest();
	//}

	//static testMethod void testConfirmationCreateRelationshipSuccess() {
		////Sales order confirmation - Web servcie callout testing when Oracle Bill To/Ship To relationship is required.

		////Create data for testing
		//Account oAccountShipTo = Test_Environment_Utility.createInsertAccountUS();
		////Customer_Account__c oCustomerAccountShipTo = Test_Environment_Utility.createInsertCustomerAccount(oAccountShipTo);
		//Account oAccountBillTo = Test_Environment_Utility.createInsertAccountUS();
		////Customer_Account__c oCustomerAccountBillTo = Test_Environment_Utility.createInsertCustomerAccount(oAccountBillTo);
		//Contact oContact = Test_Environment_Utility.createInsertContact(oAccountShipTo);

		////Get previously created data
		//Product2 oProductFG = [select Id from Product2 where Item_Type__c='E-FG'];

		////Create Sales_Order__c record
		//Sales_Order__c oSalesOrder = new Sales_Order__c();
		////oSalesOrder.Bill_To_Customer__c=oAccountBillTo.Id;
		////oSalesOrder.Ship_To_Customer__c=oAccountShipTo.Id;
		//oSalesOrder.Bill_To_Customer_Account_New__c=oAccountBillTo.Id;
		//oSalesOrder.Ship_To_Customer_Account_New__c=oAccountShipTo.Id;
		//oSalesOrder.Order_Type_Id__c='MAINTENANCE';
		//oSalesOrder.Order_Type__c='MAINTENANCE';
		//oSalesOrder.Ship_To_Contact__c=oContact.Id;
		//oSalesOrder.Customer_PO_Number__c='APEXTEST';
		//oSalesOrder.Ship_To_Org_Id__c='APEXTEST';
		//oSalesOrder.Ship_To_Contact_Role_Id__c='APEXTEST';

		//insert oSalesOrder;

		////Create Sales_Order_Line__c record
		//Sales_Order_Line__c oSalesOrderLine = new Sales_Order_Line__c();
		//oSalesOrderLine.Sales_Order__c=oSalesOrder.Id;
		//oSalesOrderLine.Part_Number__c=oProductFG.Id;
		//oSalesOrderLine.Quantity__c=1;

		//insert oSalesOrderLine;

		////Create Integration_Id__c records for use in the web service response below
		//Integration_Id__c oIntegrationIdShipTo = Test_Environment_Utility.createInsertIntegrationId();
		//Integration_Id__c oIntegrationIdRelationship = Test_Environment_Utility.createInsertIntegrationId();

		//Test.startTest();
        	////Set up mock web service response for successful callout
            //SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(200,
                                                            //'OK',
                //'{'+
                //'  \"__type\": \"RepLocator.Relationship\",'+
                //'  \"ip_verification_id\": \"' + oIntegrationIdRelationship.Id + '\",'+
                //'  \"ip_cust_account_id\": \"\",'+
                //'  \"ip_related_cust_account_id\": \"\",'+
                //'  \"ip_bill_to_flag\": \"\",'+
                //'  \"ip_ship_to_flag\": \"Y\",'+
                //'  \"op_return_status\": \"\",'+
                //'  \"op_return_message\": \"\"'+
                //'}' 
                 //, null);
            //Test.setMock(HttpCalloutMock.class, oFakeResponse);

			////Retrieve sales order
	       	//oSalesOrder = [select Id, Ship_To_Contact_Role_Id__c, Ship_To_Customer__r.Oracle_Party_Id__c, Ship_To_Customer_Account_New__c, Ship_To_Customer_Id__c, 
	       					//Ship_To_Org_Id__c, Bill_To_Customer_Account_New__c, Bill_To_Customer_Id__c, Order_Submitted__c, Date_Time_Submitted__c, ORIG_SYS_DOCUMENT_REF__c,
	       					//Ship_To_Contact_First_Name__c, Ship_To_Contact_Last_Name__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Email__c
	       					//from Sales_Order__c limit 1];
            
            ////Create PageReference to the SalesOrderConfirmation
            //PageReference oPageRef = Page.SalesOrderConfirmation;
            //Test.setCurrentPage(oPageRef);

            ////Invoke the standard and extension controllers with the sales order retrieved above
            //ApexPages.StandardController oStdController = new ApexPages.StandardController(oSalesOrder);
            //ApexPages.currentPage().getParameters().put('id',oSalesOrder.id);
            //Sales_Order_Confirmation_Cntrl oExtController = new Sales_Order_Confirmation_Cntrl(oStdController);
            
            //system.assertEquals('/apex/salesordersummary?id=' + oSalesOrder.Id,oExtController.orderConfirmationSubmit().getURL());   
            
            ////Assert Sales_Order__c details
            //oSalesOrder=[select Id, Ship_To_Contact_Role_Id__c, Order_Submitted__c from Sales_Order__c where Id=:oSalesOrder.Id];
            //system.assertEquals(true,oSalesOrder.Order_Submitted__c); 
		//Test.stopTest();
	//}

	//static testMethod void testConfirmationShipToWSCalloutException() {
		////Sales order confirmation - Web servcie callout exception testing for creating ship to contact.

		////Create data for testing
		//Account oAccountShipTo = Test_Environment_Utility.createInsertAccountUS();
		//Contact oContact = Test_Environment_Utility.createInsertContact(oAccountShipTo);

		////Get previously created data
		//Product2 oProductFG = [select Id from Product2 where Item_Type__c='E-FG'];

		////Create Sales_Order__c record
		//Sales_Order__c oSalesOrder = new Sales_Order__c();
		//oSalesOrder.Bill_To_Customer__c=oAccountShipTo.Id;
		//oSalesOrder.Ship_To_Customer__c=oAccountShipTo.Id;
		//oSalesOrder.Order_Type_Id__c='MAINTENANCE';
		//oSalesOrder.Order_Type__c='MAINTENANCE';
		//oSalesOrder.Ship_To_Contact__c=oContact.Id;
		//oSalesOrder.Customer_PO_Number__c='APEXTEST';
		//oSalesOrder.Ship_To_Org_Id__c='APEXTEST';

		//insert oSalesOrder;

		////Create Sales_Order_Line__c record
		//Sales_Order_Line__c oSalesOrderLine = new Sales_Order_Line__c();
		//oSalesOrderLine.Sales_Order__c=oSalesOrder.Id;
		//oSalesOrderLine.Part_Number__c=oProductFG.Id;
		//oSalesOrderLine.Quantity__c=1;

		//insert oSalesOrderLine;

        ////Create Integration_Id__c for use in the web service response below
    	//Integration_Id__c oIntegrationIdShipTo = Test_Environment_Utility.createInsertIntegrationId();
		//Integration_Id__c oIntegrationIdRelationship = Test_Environment_Utility.createInsertIntegrationId();

		//Test.startTest();
            ////Set up response since web service callouts are not allowed from test classes - this is a bad JSON format that includes '//' at the beginning of the string
            ////which will trigger the callout exception logic.
            //SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(200,
                                                            //'OK',
                //'//{'+
                //'  \"__type\": \"RepLocator.Customer\",'+
                //'  \"ip_verification_id\": \"' + oIntegrationIdShipTo.Id + '\",'+
                //'  \"ip_party_id\": \"\",'+
                //'  \"ip_cust_account_id\": \"\",'+
                //'  \"ip_ship_to_site_use_id\": \"\",'+
                //'  \"ip_organization_name\": \"\",'+
                //'  \"ip_account_name\": \"\",'+
                //'  \"ip_address1\": \"\",'+
                //'  \"ip_address2\": \"\",'+
                //'  \"ip_address3\": \"\",'+
                //'  \"ip_address4\": \"\",'+
                //'  \"ip_city\": \"\",'+
                //'  \"ip_state\": \"\",'+
                //'  \"ip_province\": \"\",'+
                //'  \"ip_postal_code\": \"\",'+
                //'  \"ip_country\": \"\",'+
                //'  \"ip_county\": \"\",'+
                //'  \"ip_person_first_name\": \"\",'+
                //'  \"ip_person_last_name\": \"\",'+
                //'  \"ip_raw_phone_number\": \"\",'+
                //'  \"ip_email_address\": \"\",'+
                //'  \"ip_is_bill_to_address\": \"\",'+
                //'  \"ip_is_ship_to_address\": \"Y\",'+
                //'  \"ip_salesforce_ref_id\": \"\",'+
                //'  \"op_party_id\": \"187267221\",'+
                //'  \"op_party_number\": \"\",'+
                //'  \"op_cust_account_id\": \"16762542\",'+
                //'  \"op_ship_to_site_use_id\": \"19099009\",'+
                //'  \"op_bill_to_site_use_id\": \"\",'+
                //'  \"op_ship_to_contact_id\": \"21046994\",'+
                //'  \"op_cust_account_role_id\": \"19300030\",'+
                //'  \"op_return_status\": \"\",'+
                //'  \"op_return_message\": \"\"'+
                //'}'
                 //, null);
            //Test.setMock(HttpCalloutMock.class, oFakeResponse); 

			////Retrieve sales order
	       	//oSalesOrder = [select Id, Ship_To_Contact_Role_Id__c, Ship_To_Customer__r.Oracle_Party_Id__c, Ship_To_Customer_Account_New__c, Ship_To_Customer_Id__c, 
	       					//Ship_To_Org_Id__c, Bill_To_Customer_Account_New__c, Bill_To_Customer_Id__c, Order_Submitted__c, Date_Time_Submitted__c, ORIG_SYS_DOCUMENT_REF__c,
	       					//Ship_To_Contact_First_Name__c, Ship_To_Contact_Last_Name__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Email__c
	       					//from Sales_Order__c limit 1];
            
            ////Create PageReference to the SalesOrderConfirmation
            //PageReference oPageRef = Page.SalesOrderConfirmation;
            //Test.setCurrentPage(oPageRef);

            ////Invoke the standard and extension controllers with the sales order retrieved above
            //ApexPages.StandardController oStdController = new ApexPages.StandardController(oSalesOrder);
            //ApexPages.currentPage().getParameters().put('id',oSalesOrder.id);
            //Sales_Order_Confirmation_Cntrl oExtController = new Sales_Order_Confirmation_Cntrl(oStdController);
            
            //oPageRef = oExtController.orderConfirmationSubmit();   
            ////Assert null return for page ref
            //system.assertEquals(null,oPageRef);
            ////Assert page messages
            //Boolean bFoundMessage=false;
            //for(ApexPages.Message oMessage :ApexPages.getMessages()) {
                //if(oMessage.getDetail().contains('CALLOUT EXCEPTION')) {
                    //bFoundMessage=true;
                //}
            //}   
            //system.assert(bFoundMessage);   
		//Test.stopTest();
	//}

	//static testMethod void testConfirmationShipToWSStatusException() {
		////Sales order confirmation - Web servcie status exception testing for creating ship to contact.

		////Create data for testing
		//Account oAccountShipTo = Test_Environment_Utility.createInsertAccountUS();
		//Contact oContact = Test_Environment_Utility.createInsertContact(oAccountShipTo);

		////Get previously created data
		//Product2 oProductFG = [select Id from Product2 where Item_Type__c='E-FG'];

		////Create Sales_Order__c record
		//Sales_Order__c oSalesOrder = new Sales_Order__c();
		//oSalesOrder.Bill_To_Customer__c=oAccountShipTo.Id;
		//oSalesOrder.Ship_To_Customer__c=oAccountShipTo.Id;
		//oSalesOrder.Order_Type_Id__c='MAINTENANCE';
		//oSalesOrder.Order_Type__c='MAINTENANCE';
		//oSalesOrder.Ship_To_Contact__c=oContact.Id;
		//oSalesOrder.Customer_PO_Number__c='APEXTEST';
		//oSalesOrder.Ship_To_Org_Id__c='APEXTEST';

		//insert oSalesOrder;

		////Create Sales_Order_Line__c record
		//Sales_Order_Line__c oSalesOrderLine = new Sales_Order_Line__c();
		//oSalesOrderLine.Sales_Order__c=oSalesOrder.Id;
		//oSalesOrderLine.Part_Number__c=oProductFG.Id;
		//oSalesOrderLine.Quantity__c=1;

		//insert oSalesOrderLine;

        ////Create Integration_Id__c for use in the web service response below
    	//Integration_Id__c oIntegrationIdShipTo = Test_Environment_Utility.createInsertIntegrationId();
		//Integration_Id__c oIntegrationIdRelationship = Test_Environment_Utility.createInsertIntegrationId();

		//Test.startTest();
            ////Set up response since web service callouts are not allowed from test classes - 404 status exception testing
            //SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(404,
                                                            //'',
                //'{'+
                //'  \"__type\": \"RepLocator.Customer\",'+
                //'  \"ip_verification_id\": \"' + oIntegrationIdShipTo.Id + '\",'+
                //'  \"ip_party_id\": \"\",'+
                //'  \"ip_cust_account_id\": \"\",'+
                //'  \"ip_ship_to_site_use_id\": \"\",'+
                //'  \"ip_organization_name\": \"\",'+
                //'  \"ip_account_name\": \"\",'+
                //'  \"ip_address1\": \"\",'+
                //'  \"ip_address2\": \"\",'+
                //'  \"ip_address3\": \"\",'+
                //'  \"ip_address4\": \"\",'+
                //'  \"ip_city\": \"\",'+
                //'  \"ip_state\": \"\",'+
                //'  \"ip_province\": \"\",'+
                //'  \"ip_postal_code\": \"\",'+
                //'  \"ip_country\": \"\",'+
                //'  \"ip_county\": \"\",'+
                //'  \"ip_person_first_name\": \"\",'+
                //'  \"ip_person_last_name\": \"\",'+
                //'  \"ip_raw_phone_number\": \"\",'+
                //'  \"ip_email_address\": \"\",'+
                //'  \"ip_is_bill_to_address\": \"\",'+
                //'  \"ip_is_ship_to_address\": \"Y\",'+
                //'  \"ip_salesforce_ref_id\": \"\",'+
                //'  \"op_party_id\": \"187267221\",'+
                //'  \"op_party_number\": \"\",'+
                //'  \"op_cust_account_id\": \"16762542\",'+
                //'  \"op_ship_to_site_use_id\": \"19099009\",'+
                //'  \"op_bill_to_site_use_id\": \"\",'+
                //'  \"op_ship_to_contact_id\": \"21046994\",'+
                //'  \"op_cust_account_role_id\": \"19300030\",'+
                //'  \"op_return_status\": \"\",'+
                //'  \"op_return_message\": \"\"'+
                //'}'
                 //, null);
            //Test.setMock(HttpCalloutMock.class, oFakeResponse); 

			////Retrieve sales order
	       	//oSalesOrder = [select Id, Ship_To_Contact_Role_Id__c, Ship_To_Customer__r.Oracle_Party_Id__c, Ship_To_Customer_Account_New__c, Ship_To_Customer_Id__c, 
	       					//Ship_To_Org_Id__c, Bill_To_Customer_Account_New__c, Bill_To_Customer_Id__c, Order_Submitted__c, Date_Time_Submitted__c, ORIG_SYS_DOCUMENT_REF__c,
	       					//Ship_To_Contact_First_Name__c, Ship_To_Contact_Last_Name__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Email__c
	       					//from Sales_Order__c limit 1];
            
            ////Create PageReference to the SalesOrderConfirmation
            //PageReference oPageRef = Page.SalesOrderConfirmation;
            //Test.setCurrentPage(oPageRef);

            ////Invoke the standard and extension controllers with the sales order retrieved above
            //ApexPages.StandardController oStdController = new ApexPages.StandardController(oSalesOrder);
            //ApexPages.currentPage().getParameters().put('id',oSalesOrder.id);
            //Sales_Order_Confirmation_Cntrl oExtController = new Sales_Order_Confirmation_Cntrl(oStdController);
            
            //oPageRef = oExtController.orderConfirmationSubmit();   
            ////Assert null return for page ref
            //system.assertEquals(null,oPageRef);
            ////Assert page messages
            //Boolean bFoundMessage=false;
            //for(ApexPages.Message oMessage :ApexPages.getMessages()) {
                //if(oMessage.getDetail().contains('STATUS EXCEPTION')) {
                    //bFoundMessage=true;
                //}
            //}   
            //system.assert(bFoundMessage);   
		//Test.stopTest();
	//}

	//static testMethod void testConfirmationShipToOracleAPIException() {
		////Sales order confirmation - Oracle API exception testing for creating ship to contact.

		////Create data for testing
		//Account oAccountShipTo = Test_Environment_Utility.createInsertAccountUS();
		//Contact oContact = Test_Environment_Utility.createInsertContact(oAccountShipTo);

		////Get previously created data
		//Product2 oProductFG = [select Id from Product2 where Item_Type__c='E-FG'];

		////Create Sales_Order__c record
		//Sales_Order__c oSalesOrder = new Sales_Order__c();
		//oSalesOrder.Bill_To_Customer__c=oAccountShipTo.Id;
		//oSalesOrder.Ship_To_Customer__c=oAccountShipTo.Id;
		//oSalesOrder.Order_Type_Id__c='MAINTENANCE';
		//oSalesOrder.Order_Type__c='MAINTENANCE';
		//oSalesOrder.Ship_To_Contact__c=oContact.Id;
		//oSalesOrder.Customer_PO_Number__c='APEXTEST';
		//oSalesOrder.Ship_To_Org_Id__c='APEXTEST';

		//insert oSalesOrder;

		////Create Sales_Order_Line__c record
		//Sales_Order_Line__c oSalesOrderLine = new Sales_Order_Line__c();
		//oSalesOrderLine.Sales_Order__c=oSalesOrder.Id;
		//oSalesOrderLine.Part_Number__c=oProductFG.Id;
		//oSalesOrderLine.Quantity__c=1;

		//insert oSalesOrderLine;

        ////Create Integration_Id__c for use in the web service response below
    	//Integration_Id__c oIntegrationIdShipTo = Test_Environment_Utility.createInsertIntegrationId();
		//Integration_Id__c oIntegrationIdRelationship = Test_Environment_Utility.createInsertIntegrationId();

		//Test.startTest();
            ////Set up response since web service callouts are not allowed from test classes - 404 status exception testing
            //SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(200,
                                                            //'OK',
                //'{'+
                //'  \"__type\": \"RepLocator.Customer\",'+
                //'  \"ip_verification_id\": \"' + oIntegrationIdShipTo.Id + '\",'+
                //'  \"ip_party_id\": \"\",'+
                //'  \"ip_cust_account_id\": \"\",'+
                //'  \"ip_ship_to_site_use_id\": \"\",'+
                //'  \"ip_organization_name\": \"\",'+
                //'  \"ip_account_name\": \"\",'+
                //'  \"ip_address1\": \"\",'+
                //'  \"ip_address2\": \"\",'+
                //'  \"ip_address3\": \"\",'+
                //'  \"ip_address4\": \"\",'+
                //'  \"ip_city\": \"\",'+
                //'  \"ip_state\": \"\",'+
                //'  \"ip_province\": \"\",'+
                //'  \"ip_postal_code\": \"\",'+
                //'  \"ip_country\": \"\",'+
                //'  \"ip_county\": \"\",'+
                //'  \"ip_person_first_name\": \"\",'+
                //'  \"ip_person_last_name\": \"\",'+
                //'  \"ip_raw_phone_number\": \"\",'+
                //'  \"ip_email_address\": \"\",'+
                //'  \"ip_is_bill_to_address\": \"\",'+
                //'  \"ip_is_ship_to_address\": \"Y\",'+
                //'  \"ip_salesforce_ref_id\": \"\",'+
                //'  \"op_party_id\": \"187267221\",'+
                //'  \"op_party_number\": \"\",'+
                //'  \"op_cust_account_id\": \"16762542\",'+
                //'  \"op_ship_to_site_use_id\": \"19099009\",'+
                //'  \"op_bill_to_site_use_id\": \"\",'+
                //'  \"op_ship_to_contact_id\": \"21046994\",'+
                //'  \"op_cust_account_role_id\": \"19300030\",'+
                //'  \"op_return_status\": \"E\",'+
                //'  \"op_return_message\": \"ORACLE API ERROR\"'+
                //'}'
                 //, null);
            //Test.setMock(HttpCalloutMock.class, oFakeResponse); 

			////Retrieve sales order
	       	//oSalesOrder = [select Id, Ship_To_Contact_Role_Id__c, Ship_To_Customer__r.Oracle_Party_Id__c, Ship_To_Customer_Account_New__c, Ship_To_Customer_Id__c, 
	       					//Ship_To_Org_Id__c, Bill_To_Customer_Account_New__c, Bill_To_Customer_Id__c, Order_Submitted__c, Date_Time_Submitted__c, ORIG_SYS_DOCUMENT_REF__c,
	       					//Ship_To_Contact_First_Name__c, Ship_To_Contact_Last_Name__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Email__c
	       					//from Sales_Order__c limit 1];
            
            ////Create PageReference to the SalesOrderConfirmation
            //PageReference oPageRef = Page.SalesOrderConfirmation;
            //Test.setCurrentPage(oPageRef);

            ////Invoke the standard and extension controllers with the sales order retrieved above
            //ApexPages.StandardController oStdController = new ApexPages.StandardController(oSalesOrder);
            //ApexPages.currentPage().getParameters().put('id',oSalesOrder.id);
            //Sales_Order_Confirmation_Cntrl oExtController = new Sales_Order_Confirmation_Cntrl(oStdController);
            
            //oPageRef = oExtController.orderConfirmationSubmit();   
            ////Assert null return for page ref
            //system.assertEquals(null,oPageRef);
            ////Assert page messages
            //Boolean bFoundMessage=false;
            //for(ApexPages.Message oMessage :ApexPages.getMessages()) {
                //if(oMessage.getDetail().contains('ORACLE API EXCEPTION')) {
                    //bFoundMessage=true;
                //}
            //}   
            //system.assert(bFoundMessage);   
		//Test.stopTest();
	//}

	//static testMethod void testConfirmationCreateRelationshipWSCalloutException() {
		////Sales order confirmation - Web servcie callout exception testing for creating bill to ship to relationship.

		////Create data for testing
		//Account oAccountShipTo = Test_Environment_Utility.createInsertAccountUS();
		////Customer_Account__c oCustomerAccountShipTo = Test_Environment_Utility.createInsertCustomerAccount(oAccountShipTo);
		//Account oAccountBillTo = Test_Environment_Utility.createInsertAccountUS();
		////Customer_Account__c oCustomerAccountBillTo = Test_Environment_Utility.createInsertCustomerAccount(oAccountBillTo);
		//Contact oContact = Test_Environment_Utility.createInsertContact(oAccountShipTo);

		////Get previously created data
		//Product2 oProductFG = [select Id from Product2 where Item_Type__c='E-FG'];

		////Create Sales_Order__c record
		//Sales_Order__c oSalesOrder = new Sales_Order__c();
		//oSalesOrder.Bill_To_Customer__c=oAccountBillTo.Id;
		//oSalesOrder.Ship_To_Customer__c=oAccountShipTo.Id;
		//oSalesOrder.Bill_To_Customer_Account_New__c=oAccountShipTo.Id;
		//oSalesOrder.Ship_To_Customer_Account_New__c=oAccountBillTo.Id;
		//oSalesOrder.Order_Type_Id__c='MAINTENANCE';
		//oSalesOrder.Order_Type__c='MAINTENANCE';
		//oSalesOrder.Ship_To_Contact__c=oContact.Id;
		//oSalesOrder.Customer_PO_Number__c='APEXTEST';
		//oSalesOrder.Ship_To_Org_Id__c='APEXTEST';
		//oSalesOrder.Ship_To_Contact_Role_Id__c='APEXTEST';

		//insert oSalesOrder;

		////Create Sales_Order_Line__c record
		//Sales_Order_Line__c oSalesOrderLine = new Sales_Order_Line__c();
		//oSalesOrderLine.Sales_Order__c=oSalesOrder.Id;
		//oSalesOrderLine.Part_Number__c=oProductFG.Id;
		//oSalesOrderLine.Quantity__c=1;

		//insert oSalesOrderLine;

		////Create Integration_Id__c records for use in the web service response below
		//Integration_Id__c oIntegrationIdShipTo = Test_Environment_Utility.createInsertIntegrationId();
		//Integration_Id__c oIntegrationIdRelationship = Test_Environment_Utility.createInsertIntegrationId();

		//Test.startTest();
        	////Set up response since web service callouts are not allowed from test classes - incorrect JSON format
            //SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(200,
                                                            //'OK',
                //'//{'+
                //'  \"__type\": \"RepLocator.Relationship\",'+
                //'  \"ip_verification_id\": \"' + oIntegrationIdRelationship.Id + '\",'+
                //'  \"ip_cust_account_id\": \"\",'+
                //'  \"ip_related_cust_account_id\": \"\",'+
                //'  \"ip_bill_to_flag\": \"\",'+
                //'  \"ip_ship_to_flag\": \"Y\",'+
                //'  \"op_return_status\": \"\",'+
                //'  \"op_return_message\": \"\"'+
                //'}' 
                 //, null);
            //Test.setMock(HttpCalloutMock.class, oFakeResponse);

			////Retrieve sales order
	       	//oSalesOrder = [select Id, Ship_To_Contact_Role_Id__c, Ship_To_Customer__r.Oracle_Party_Id__c, Ship_To_Customer_Account_New__c, Ship_To_Customer_Id__c, 
	       					//Ship_To_Org_Id__c, Bill_To_Customer_Account_New__c, Bill_To_Customer_Id__c, Order_Submitted__c, Date_Time_Submitted__c, ORIG_SYS_DOCUMENT_REF__c,
	       					//Ship_To_Contact_First_Name__c, Ship_To_Contact_Last_Name__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Email__c
	       					//from Sales_Order__c limit 1];
            
            ////Create PageReference to the SalesOrderConfirmation
            //PageReference oPageRef = Page.SalesOrderConfirmation;
            //Test.setCurrentPage(oPageRef);

            ////Invoke the standard and extension controllers with the sales order retrieved above
            //ApexPages.StandardController oStdController = new ApexPages.StandardController(oSalesOrder);
            //ApexPages.currentPage().getParameters().put('id',oSalesOrder.id);
            //Sales_Order_Confirmation_Cntrl oExtController = new Sales_Order_Confirmation_Cntrl(oStdController);
            
            //oPageRef = oExtController.orderConfirmationSubmit();   
            ////Assert null return for page ref
            //system.assertEquals(null,oPageRef);
            ////Assert page messages
            //Boolean bFoundMessage=false;
            //for(ApexPages.Message oMessage :ApexPages.getMessages()) {
                //if(oMessage.getDetail().contains('CALLOUT EXCEPTION')) {
                    //bFoundMessage=true;
                //}
            //}   
            //system.assert(bFoundMessage);
		//Test.stopTest();
	//}

	//static testMethod void testConfirmationCreateRelationshipWSStatusException() {
		////Sales order confirmation - Web servcie status exception testing for creating bill to ship to relationship.

		////Create data for testing
		//Account oAccountShipTo = Test_Environment_Utility.createInsertAccountUS();
		////Customer_Account__c oCustomerAccountShipTo = Test_Environment_Utility.createInsertCustomerAccount(oAccountShipTo);
		//Account oAccountBillTo = Test_Environment_Utility.createInsertAccountUS();
		////Customer_Account__c oCustomerAccountBillTo = Test_Environment_Utility.createInsertCustomerAccount(oAccountBillTo);
		//Contact oContact = Test_Environment_Utility.createInsertContact(oAccountShipTo);

		////Get previously created data
		//Product2 oProductFG = [select Id from Product2 where Item_Type__c='E-FG'];

		////Create Sales_Order__c record
		//Sales_Order__c oSalesOrder = new Sales_Order__c();
		//oSalesOrder.Bill_To_Customer__c=oAccountBillTo.Id;
		//oSalesOrder.Ship_To_Customer__c=oAccountShipTo.Id;
		//oSalesOrder.Bill_To_Customer_Account_New__c=oAccountBillTo.Id;
		//oSalesOrder.Ship_To_Customer_Account_New__c=oAccountShipTo.Id;
		//oSalesOrder.Order_Type_Id__c='MAINTENANCE';
		//oSalesOrder.Order_Type__c='MAINTENANCE';
		//oSalesOrder.Ship_To_Contact__c=oContact.Id;
		//oSalesOrder.Customer_PO_Number__c='APEXTEST';
		//oSalesOrder.Ship_To_Org_Id__c='APEXTEST';
		//oSalesOrder.Ship_To_Contact_Role_Id__c='APEXTEST';

		//insert oSalesOrder;

		////Create Sales_Order_Line__c record
		//Sales_Order_Line__c oSalesOrderLine = new Sales_Order_Line__c();
		//oSalesOrderLine.Sales_Order__c=oSalesOrder.Id;
		//oSalesOrderLine.Part_Number__c=oProductFG.Id;
		//oSalesOrderLine.Quantity__c=1;

		//insert oSalesOrderLine;

		////Create Integration_Id__c records for use in the web service response below
		//Integration_Id__c oIntegrationIdShipTo = Test_Environment_Utility.createInsertIntegrationId();
		//Integration_Id__c oIntegrationIdRelationship = Test_Environment_Utility.createInsertIntegrationId();

		//Test.startTest();
        	////Set up response since web service callouts are not allowed from test classes - 404 bad request
            //SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(404,
                                                            //'BAD',
                //'{'+
                //'  \"__type\": \"RepLocator.Relationship\",'+
                //'  \"ip_verification_id\": \"' + oIntegrationIdRelationship.Id + '\",'+
                //'  \"ip_cust_account_id\": \"\",'+
                //'  \"ip_related_cust_account_id\": \"\",'+
                //'  \"ip_bill_to_flag\": \"\",'+
                //'  \"ip_ship_to_flag\": \"Y\",'+
                //'  \"op_return_status\": \"\",'+
                //'  \"op_return_message\": \"\"'+
                //'}' 
                 //, null);
            //Test.setMock(HttpCalloutMock.class, oFakeResponse);

			////Retrieve sales order
	       	//oSalesOrder = [select Id, Ship_To_Contact_Role_Id__c, Ship_To_Customer__r.Oracle_Party_Id__c, Ship_To_Customer_Account_New__c, Ship_To_Customer_Id__c, 
	       					//Ship_To_Org_Id__c, Bill_To_Customer_Account_New__c, Bill_To_Customer_Id__c, Order_Submitted__c, Date_Time_Submitted__c, ORIG_SYS_DOCUMENT_REF__c,
	       					//Ship_To_Contact_First_Name__c, Ship_To_Contact_Last_Name__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Email__c
	       					//from Sales_Order__c limit 1];
            
            ////Create PageReference to the SalesOrderConfirmation
            //PageReference oPageRef = Page.SalesOrderConfirmation;
            //Test.setCurrentPage(oPageRef);

            ////Invoke the standard and extension controllers with the sales order retrieved above
            //ApexPages.StandardController oStdController = new ApexPages.StandardController(oSalesOrder);
            //ApexPages.currentPage().getParameters().put('id',oSalesOrder.id);
            //Sales_Order_Confirmation_Cntrl oExtController = new Sales_Order_Confirmation_Cntrl(oStdController);
            
            //oPageRef = oExtController.orderConfirmationSubmit();   
            ////Assert null return for page ref
            //system.assertEquals(null,oPageRef);
            ////Assert page messages
            //Boolean bFoundMessage=false;
            //for(ApexPages.Message oMessage :ApexPages.getMessages()) {
                //if(oMessage.getDetail().contains('STATUS EXCEPTION')) {
                    //bFoundMessage=true;
                //}
            //}   
            //system.assert(bFoundMessage);
		//Test.stopTest();
	//}

	//static testMethod void testConfirmationCreateRelationshipOracleAPIException() {
		////Sales order confirmation - Oracle API exception testing for creating bill to ship to relationship.

		////Create data for testing
		//Account oAccountShipTo = Test_Environment_Utility.createInsertAccountUS();
		////Customer_Account__c oCustomerAccountShipTo = Test_Environment_Utility.createInsertCustomerAccount(oAccountShipTo);
		//Account oAccountBillTo = Test_Environment_Utility.createInsertAccountUS();
		////Customer_Account__c oCustomerAccountBillTo = Test_Environment_Utility.createInsertCustomerAccount(oAccountBillTo);
		//Contact oContact = Test_Environment_Utility.createInsertContact(oAccountShipTo);

		////Get previously created data
		//Product2 oProductFG = [select Id from Product2 where Item_Type__c='E-FG'];

		////Create Sales_Order__c record
		//Sales_Order__c oSalesOrder = new Sales_Order__c();
		//oSalesOrder.Bill_To_Customer__c=oAccountBillTo.Id;
		//oSalesOrder.Ship_To_Customer__c=oAccountShipTo.Id;
		//oSalesOrder.Bill_To_Customer_Account_New__c=oAccountBillTo.Id;
		//oSalesOrder.Ship_To_Customer_Account_New__c=oAccountShipTo.Id;
		//oSalesOrder.Order_Type_Id__c='MAINTENANCE';
		//oSalesOrder.Order_Type__c='MAINTENANCE';
		//oSalesOrder.Ship_To_Contact__c=oContact.Id;
		//oSalesOrder.Customer_PO_Number__c='APEXTEST';
		//oSalesOrder.Ship_To_Org_Id__c='APEXTEST';
		//oSalesOrder.Ship_To_Contact_Role_Id__c='APEXTEST';

		//insert oSalesOrder;

		////Create Sales_Order_Line__c record
		//Sales_Order_Line__c oSalesOrderLine = new Sales_Order_Line__c();
		//oSalesOrderLine.Sales_Order__c=oSalesOrder.Id;
		//oSalesOrderLine.Part_Number__c=oProductFG.Id;
		//oSalesOrderLine.Quantity__c=1;

		//insert oSalesOrderLine;

		////Create Integration_Id__c records for use in the web service response below
		//Integration_Id__c oIntegrationIdShipTo = Test_Environment_Utility.createInsertIntegrationId();
		//Integration_Id__c oIntegrationIdRelationship = Test_Environment_Utility.createInsertIntegrationId();

		//Test.startTest();
        	////Set up response since web service callouts are not allowed from test classes - Oracle return status and return message set
            //SingleHTTPRequestMock_Test oFakeResponse = new SingleHTTPRequestMock_Test(200,
                                                            //'OK',
                //'{'+
                //'  \"__type\": \"RepLocator.Relationship\",'+
                //'  \"ip_verification_id\": \"' + oIntegrationIdRelationship.Id + '\",'+
                //'  \"ip_cust_account_id\": \"\",'+
                //'  \"ip_related_cust_account_id\": \"\",'+
                //'  \"ip_bill_to_flag\": \"\",'+
                //'  \"ip_ship_to_flag\": \"Y\",'+
                //'  \"op_return_status\": \"E\",'+
                //'  \"op_return_message\": \"ORACLE API EXCEPTION\"'+
                //'}' 
                 //, null);
            //Test.setMock(HttpCalloutMock.class, oFakeResponse);

			////Retrieve sales order
	       	//oSalesOrder = [select Id, Ship_To_Contact_Role_Id__c, Ship_To_Customer__r.Oracle_Party_Id__c, Ship_To_Customer_Account_New__c, Ship_To_Customer_Id__c, 
	       					//Ship_To_Org_Id__c, Bill_To_Customer_Account_New__c, Bill_To_Customer_Id__c, Order_Submitted__c, Date_Time_Submitted__c, ORIG_SYS_DOCUMENT_REF__c,
	       					//Ship_To_Contact_First_Name__c, Ship_To_Contact_Last_Name__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Email__c
	       					//from Sales_Order__c limit 1];
            
            ////Create PageReference to the SalesOrderConfirmation
            //PageReference oPageRef = Page.SalesOrderConfirmation;
            //Test.setCurrentPage(oPageRef);

            ////Invoke the standard and extension controllers with the sales order retrieved above
            //ApexPages.StandardController oStdController = new ApexPages.StandardController(oSalesOrder);
            //ApexPages.currentPage().getParameters().put('id',oSalesOrder.id);
            //Sales_Order_Confirmation_Cntrl oExtController = new Sales_Order_Confirmation_Cntrl(oStdController);
            
            //oPageRef = oExtController.orderConfirmationSubmit();   
            ////Assert null return for page ref
            //system.assertEquals(null,oPageRef);
            ////Assert page messages
            //Boolean bFoundMessage=false;
            //for(ApexPages.Message oMessage :ApexPages.getMessages()) {
                //if(oMessage.getDetail().contains('ORACLE API EXCEPTION')) {
                    //bFoundMessage=true;
                //}
            //}   
            //system.assert(bFoundMessage);
		//Test.stopTest();
	//}
}