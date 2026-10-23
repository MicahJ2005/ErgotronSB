/*
	Test class for the Opportunity_Special_Pricing_Controller.cls.

	MOD DATE		Who						Description
	3/25/2014		Chris Noe				Initial Release
	5/20/2014		Chris Noe				Updates to support default selection of distributors (Partners) on Ergotron Branded opportunities.
	6/24/2014		Chris Noe				Updated to use Test_Environment_Utility methods for creating data
	6/29/2015       Chris Noe               Updates for the new Opportunity_Partner__c object - FB-00653.
*/

@isTest (seeAllData=true) //seeAllData = true is required since we are working with standard pricebook

private class Opportunity_SPR_Controller_Test {

    static testMethod void sprControllerTestSpecialPricing() {
        //Create Accounts for test
        Account oEndUser = Test_Environment_Utility.createInsertAccountUS();
        Account oReseller = Test_Environment_Utility.createInsertAccountUS();
		oReseller.Authorized_Reseller__c = true;
        update oReseller;
        Account oDistributor = Test_Environment_Utility.createInsertAccountUS();
        
        //Retrieve pricebook and product for test
        PricebookEntry oPBE = [select Id, Pricebook2Id, Product2Id from PricebookEntry where Pricebook2.Name='US STANDARD PRICE LIST' and isActive=true limit 1];
        
        //Create opportunity for test
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oEndUser, 'Test', Date.today());
        
        //Create reseller contact for test
        Contact oContact = new Contact(FirstName='Reseller', LastName='Contact', AccountId=oReseller.Id);
        insert oContact;

        //Start Testing
        Test.startTest();        
			PageReference oPageRef = Page.OpportunitySpecialPricing;
			Test.setCurrentPage(oPageRef); 
			ApexPages.StandardController oStdController = new ApexPages.StandardController(oOpportunity);
			oPageRef.getParameters().put('id',String.valueOf(oOpportunity.Id));
			Opportunity_Special_Pricing_Controller oExtController = new Opportunity_Special_Pricing_Controller(oStdController);
			
			//Assertion statements for opportunity with no special pricing details
			system.assertEquals(true, oExtController.bOpptyDistributor); //Accounts default to Country=US - seeAllData=true so distributors are automatically pulled in
	        system.assertEquals(false, oExtController.bOpptyReseller);
	        system.assertEquals(false, oExtController.bOpptyContactRoles);
	        system.assertEquals(false, oExtController.bOpptyProducts);
	        system.assertEquals(false, oExtController.bRequiredSPRFields);
	        system.assertEquals(false, oExtController.bDisplaySubmitButton);
	        
	        //Create OpportunityLineItem records for test
	        OpportunityLineItem oOLI = new OpportunityLineItem(PricebookEntryId=oPBE.Id, Target_End_User_Price__c=100.00, UnitPrice=100.00, OpportunityId=oOpportunity.Id, Quantity=100);
	        insert oOLI;
	        
	        //Create Opportunity Partner records for test
	        Opportunity_Partner__c oOP = new Opportunity_Partner__c(Opportunity__c=oOpportunity.Id, Partner_Account__c=oDistributor.Id, Partner_Role__c='Distributor');
	        insert oOP;
	        Opportunity_Partner__c oOP1 = new Opportunity_Partner__c(Opportunity__c=oOpportunity.Id, Partner_Account__c=oReseller.Id, Partner_Role__c='Reseller');
	        insert oOP1;
	        	        
	        //Create OpportunityContactRole records for test
        	OpportunityContactRole oOCR = new OpportunityContactRole(ContactId=oContact.Id, OpportunityId=oOpportunity.Id, Role='Reseller Contact');
        	insert oOCR;

	        //Update opportunity with SPR required fields.
	        oOpportunity.SPR_Type__c = 'Special Pricing';
	        oOpportunity.SPR_Reason__c = 'Competition';
	        oOpportunity.Expected_Order_Date__c = Date.today();
	        oOpportunity.Business_Justification__c = 'Competition';
	        update oOpportunity;
	        
	        oOpportunity = [select Id, SPR_Status__c, SPR_Type__c, Advantage_Requested_Date__c, Expected_Order_Date__c, Expected_Ship_Date__c, SPR_Reason__c, Business_Justification__c, HasOpportunityLineItem, Products_Exceeding_Max_Rebate__c, RecordType.Name, SPR_PM_Approval_Date_Time__c from Opportunity where Id = :oOpportunity.Id];
        	
			ApexPages.StandardController oStdControllerUpdate = new ApexPages.StandardController(oOpportunity);
			Opportunity_Special_Pricing_Controller oExtControllerUpdate = new Opportunity_Special_Pricing_Controller(oStdControllerUpdate);
			
			PageReference oPageRefUpdate = Page.OpportunitySpecialPricing;
			oPageRefUpdate.getParameters().put('id',String.valueOf(oOpportunity.Id));
			Test.setCurrentPage(oPageRefUpdate); 
			
			//Assertion statements for opportunity with all special pricing details populated
			system.assertEquals(true, oExtControllerUpdate.bOpptyDistributor);
	        system.assertEquals(true, oExtControllerUpdate.bOpptyReseller);
	        system.assertEquals(true, oExtControllerUpdate.bOpptyContactRoles);
	        system.assertEquals(true, oExtControllerUpdate.bOpptyProducts);
	        system.assertEquals(true, oExtControllerUpdate.bRequiredSPRFields);
	        system.assertEquals(true, oExtControllerUpdate.bDisplaySubmitButton);
	        
	        //Submit SPR for approval
	        oExtControllerUpdate.SubmitSPRApproval();         	
        Test.stopTest();
    }
    
    static testMethod void sprControllerTestAdvantage() {
        //Create Accounts for test
        Account oEndUser = Test_Environment_Utility.createInsertAccountUS();
        Account oReseller = Test_Environment_Utility.createInsertAccountUS();
		oReseller.Authorized_Reseller__c = true;
        update oReseller;

        Account oDistributor = Test_Environment_Utility.createInsertAccountUS();

		//Create opportunity for test
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oEndUser, 'Test', Date.today());
        
        //Create reseller contact for test
        Contact oContact = new Contact(FirstName='Reseller', LastName='Contact', AccountId=oReseller.Id);
        insert oContact;

        //Start Testing
        Test.startTest();        
			PageReference oPageRef = Page.OpportunitySpecialPricing;
			Test.setCurrentPage(oPageRef); 
			ApexPages.StandardController oStdController = new ApexPages.StandardController(oOpportunity);
			oPageRef.getParameters().put('id',String.valueOf(oOpportunity.Id));
			Opportunity_Special_Pricing_Controller oExtController = new Opportunity_Special_Pricing_Controller(oStdController);
			
			//Assertion statements for opportunity with no advantage details
			system.assertEquals(true, oExtController.bOpptyDistributor); //Accounts default to Country=US - seeAllData=true so distributors are automatically pulled in
	        system.assertEquals(false, oExtController.bOpptyReseller);
	        system.assertEquals(false, oExtController.bOpptyContactRoles);
	        system.assertEquals(false, oExtController.bOpptyProducts);
	        system.assertEquals(false, oExtController.bRequiredSPRFields);
	        system.assertEquals(false, oExtController.bDisplaySubmitButton);
	        
	        //Create Opportunity Partner records for test
	        Opportunity_Partner__c oOP = new Opportunity_Partner__c(Opportunity__c=oOpportunity.Id, Partner_Account__c=oDistributor.Id, Partner_Role__c='Distributor');
	        insert oOP;
	        Opportunity_Partner__c oOP1 = new Opportunity_Partner__c(Opportunity__c=oOpportunity.Id, Partner_Account__c=oReseller.Id, Partner_Role__c='Reseller');
	        insert oOP1;
	        	        
	        //Create OpportunityContactRole records for test
        	OpportunityContactRole oOCR = new OpportunityContactRole(ContactId=oContact.Id, OpportunityId=oOpportunity.Id, Role='Reseller Contact');
        	insert oOCR;

	        //Update opportunity with Advantage required fields.
	        oOpportunity.SPR_Type__c = 'Advantage Account Registration';
	        oOpportunity.Advantage_Requested_Date__c = Date.today();
	        oOpportunity.Advantage_Submission_Notes__c = 'Competition';
	        update oOpportunity;
	        
	        oOpportunity = [select Id, SPR_Status__c, SPR_Type__c, Advantage_Requested_Date__c, Expected_Order_Date__c, Advantage_Submission_Notes__c, Expected_Ship_Date__c, SPR_Reason__c, Business_Justification__c, HasOpportunityLineItem, Products_Exceeding_Max_Rebate__c, RecordType.Name, SPR_PM_Approval_Date_Time__c from Opportunity where Id = :oOpportunity.Id];
        	
			ApexPages.StandardController oStdControllerUpdate = new ApexPages.StandardController(oOpportunity);
			Opportunity_Special_Pricing_Controller oExtControllerUpdate = new Opportunity_Special_Pricing_Controller(oStdControllerUpdate);
			
			PageReference oPageRefUpdate = Page.OpportunitySpecialPricing;
			oPageRefUpdate.getParameters().put('id',String.valueOf(oOpportunity.Id));
			Test.setCurrentPage(oPageRefUpdate); 
			
			//Assertion statements for opportunity with all advantage details populated
			system.assertEquals(true, oExtControllerUpdate.bOpptyDistributor);
	        system.assertEquals(true, oExtControllerUpdate.bOpptyReseller);
	        system.assertEquals(true, oExtControllerUpdate.bOpptyContactRoles);
	        system.assertEquals(true, oExtControllerUpdate.bOpptyProducts);
	        system.assertEquals(true, oExtControllerUpdate.bRequiredSPRFields);
	        system.assertEquals(true, oExtControllerUpdate.bDisplaySubmitButton);
	        
	        //Submit Advantage for approval
	        oExtControllerUpdate.SubmitSPRApproval();         	
        Test.stopTest();
    }

    static testMethod void sprControllerTestException() {
        //Create Accounts for test
        Account oEndUser = Test_Environment_Utility.createInsertAccountUS();
        Account oReseller = Test_Environment_Utility.createInsertAccountUS();
        Account oDistributor = Test_Environment_Utility.createInsertAccountUS();
         
		//Create opportunity for test
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oEndUser, 'Test', Date.today());

        //Start Testing
        Test.startTest();        
			PageReference oPageRef = Page.OpportunitySpecialPricing;
			Test.setCurrentPage(oPageRef); 

			ApexPages.StandardController oStdController = new ApexPages.StandardController(oOpportunity);
			oPageRef.getParameters().put('id',String.valueOf(oOpportunity.Id));
			Opportunity_Special_Pricing_Controller oExtController = new Opportunity_Special_Pricing_Controller(oStdController);
	        
	        //Submit for approval - Exception logic will catch this because no SPR/Advantage fields or related items have been populated.
	        oExtController.SubmitSPRApproval();         	
        Test.stopTest();
    }
}