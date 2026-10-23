/*
	Test class for Seed_Unit_Order_Utility.cls

	MOD DATE		Who						Description
	4/23/2014		Chris Noe				Initial Release
	6/24/2014		Chris Noe				Added method updateSeedUnitOrderApproverTest
    4/21/2015       Chris Noe               Added method testDelete
*/

@isTest
private class Seed_Unit_Order_Utility_Test {

    static testMethod void updateSeedUnitProductsSubmittedTest() {
        //Tests the Seed_Unit_Order_Utility.updateSeedUnitProductsSubmitted method
        
        //Create account for testing
        Account oAccount = Test_Environment_Utility.createInsertAccountUS();
        //Create contact for testing
        Contact oContact = Test_Environment_Utility.createInsertContact(oAccount);
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccount, 'Seeding', Date.today());
        //Create seed unit order for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Hospital', oAccount, oContact);
        //Create product for testing
        Product2 oProduct = Test_Environment_Utility.createInsertProduct();
        //Create seed unit product for testing
        Seed_Unit_Product__c oSeedUnitProduct = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProduct, 5);
        
        test.startTest();
        	//Update Seed_Unit_Order__c and set Seed Unit Order Submitted flag to true
        	oSeedUnitOrder.Seed_Unit_Order_Submitted__c=true;
        	update oSeedUnitOrder;
        	
        	//Retrieve associated Seed_Unit_Product__c records and verify that their submitted flag is set to true
        	for(Seed_Unit_Product__c oSeedUnitProductUpdate :[select Id, Seed_Unit_Order_Submitted__c from Seed_Unit_Product__c where Seed_Unit_Order__c = :oSeedUnitOrder.Id]){
        		system.assertEquals(true,oSeedUnitProductUpdate.Seed_Unit_Order_Submitted__c);
        	}
        test.stopTest();
    }

    static testMethod void updateSeedUnitOrderApproverTest() {
        //Tests the Seed_Unit_Order_Utility.updateSeedUnitProductsSubmitted method
        
        //Create users for testing
        User oManager1 = Test_Environment_Utility.createInsertUser();
        User oManager2 = Test_Environment_Utility.createInsertUser();
        User oUser1 = Test_Environment_Utility.createInsertUser();
        User oUser2 = Test_Environment_Utility.createInsertUser();
        
        oUser1.ManagerId = oManager1.Id;
        oUser1.Oracle_Salesrep_Id__c = String.valueOf(Test_Environment_Utility.getRandomInt(1, 99999));
        update oUser1;
        oUser2.ManagerId = oManager2.Id;
        oUser2.Oracle_Salesrep_Id__c = String.valueOf(Test_Environment_Utility.getRandomInt(1, 99999));
        update oUser2;
        
        //Create account for testing
        Account oAccount = Test_Environment_Utility.createInsertAccountUS();
        //Create contact for testing
        Contact oContact = Test_Environment_Utility.createInsertContact(oAccount);
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccount, 'Seeding', Date.today());
        //Create seed unit order for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Hospital', oAccount, oContact);
        
        test.startTest();
        	//Update Seed_Unit_Order__c and set Salesrep__c = oUser1
        	oSeedUnitOrder.Salesrep__c = oUser1.Id;
        	update oSeedUnitOrder;
        	
        	//Retrieve Seed_Unit_Order__c record and assert the Approver__c field
        	Seed_Unit_Order__c oSeedUnitOrderUpdate = [select Id, Approver__c from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];
        	system.assertEquals(oManager1.Id,oSeedUnitOrderUpdate.Approver__c);
        	
        	//Update Seed_Unit_Order__c and set Salesrep__c = oUser2
        	oSeedUnitOrderUpdate.Salesrep__c = oUser2.Id;
        	update oSeedUnitOrderUpdate;
        	
        	//Retrieve Seed_Unit_Order__c record and assert the Approver__c field
        	oSeedUnitOrderUpdate = [select Id, Approver__c from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];
        	system.assertEquals(oManager2.Id,oSeedUnitOrderUpdate.Approver__c);        	
        test.stopTest();
    }

    static testMethod void clearShipToDetails() {
        //Tests the Seed_Unit_Order_Utility.clearShipToDetails method
        
        //Create account for testing
        Account oAccount = Test_Environment_Utility.createInsertAccountUS();
        //Create contact for testing
        Contact oContact = Test_Environment_Utility.createInsertContact(oAccount);
        //Create customer account for test
        Account oCustomerAccount = Test_Environment_Utility.createInsertAccountUS();
        //Customer_Account__c oCustomerAccount = Test_Environment_Utility.createInsertCustomerAccount(oAccount);
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccount, 'Seeding', Date.today());
        //Create seed unit order for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Hospital', oAccount, oContact);
        //Set ship to details on seed unit order
        oSeedUnitOrder.Ship_To_Address1__c='TEST';
        oSeedUnitOrder.Ship_To_Address2__c='TEST';
        oSeedUnitOrder.Ship_To_Address3__c='TEST';
        oSeedUnitOrder.Ship_To_Address4__c='TEST';
        oSeedUnitOrder.Ship_To_Address1_Oracle__c='TEST';
        oSeedUnitOrder.Ship_To_Address2_Oracle__c='TEST';
        oSeedUnitOrder.Ship_To_Address3_Oracle__c='TEST';
        oSeedUnitOrder.Ship_To_Address4_Oracle__c='TEST';
        oSeedUnitOrder.Ship_To_City__c='TEST';
        oSeedUnitOrder.Ship_To_City_State_Zip_Country_Oracle__c='TEST';
        oSeedUnitOrder.Ship_To_Location_Name_Oracle__c='TEST';
        oSeedUnitOrder.Ship_To_Org_Id__c='TEST';
        oSeedUnitOrder.Ship_To_County__c='TEST';
        oSeedUnitOrder.Ship_To_Postal_Code__c='TEST';
        oSeedUnitOrder.Ship_To_State_Province__c='TEST';
        oSeedUnitOrder.Ship_To_Customer_Account_new__c=oCustomerAccount.Id;
        update oSeedUnitOrder;

        //Create product for testing
        Product2 oProduct = Test_Environment_Utility.createInsertProduct();
        //Create seed unit product for testing
        Seed_Unit_Product__c oSeedUnitProduct = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProduct, 5);
        
        test.startTest();
            //Create new ship to account and contact
            Account oAccountNew = Test_Environment_Utility.createInsertAccountUS();
            Contact oContactNew = Test_Environment_Utility.createInsertContact(oAccountNew);

            //Update Seed_Unit_Order__c and set Ship_To_Account__c
            oSeedUnitOrder.Ship_To_Account__c=oAccountNew.Id;
            oSeedUnitOrder.Ship_To_Contact__c=oContactNew.Id;
            update oSeedUnitOrder;
            
            //Retrieve seed unit order and assert null ship to details
            oSeedUnitOrder = [select Id, Ship_To_Address1__c, Ship_To_Address2__c, Ship_To_Address3__c, Ship_To_Address4__c, Ship_To_Address1_Oracle__c, Ship_To_Address2_Oracle__c,
                                Ship_To_Address3_Oracle__c, Ship_To_Address4_Oracle__c, Ship_To_City__c, Ship_To_City_State_Zip_Country_Oracle__c, Ship_To_Location_Name_Oracle__c,
                                Ship_To_Org_Id__c, Ship_To_County__c, Ship_To_Postal_Code__c, Ship_To_State_Province__c, Ship_To_Customer_Account__c 
                                from Seed_Unit_Order__c where Id = :oSeedUnitOrder.Id];

            system.assertEquals(null,oSeedUnitOrder.Ship_To_Address1__c);
            system.assertEquals(null,oSeedUnitOrder.Ship_To_Address2__c);
            system.assertEquals(null,oSeedUnitOrder.Ship_To_Address3__c);
            system.assertEquals(null,oSeedUnitOrder.Ship_To_Address4__c);
            system.assertEquals(null,oSeedUnitOrder.Ship_To_Address1_Oracle__c);
            system.assertEquals(null,oSeedUnitOrder.Ship_To_Address2_Oracle__c);
            system.assertEquals(null,oSeedUnitOrder.Ship_To_Address3_Oracle__c);
            system.assertEquals(null,oSeedUnitOrder.Ship_To_Address4_Oracle__c);
            system.assertEquals(null,oSeedUnitOrder.Ship_To_City__c);
            system.assertEquals(null,oSeedUnitOrder.Ship_To_City_State_Zip_Country_Oracle__c);
            system.assertEquals(null,oSeedUnitOrder.Ship_To_Location_Name_Oracle__c);
            system.assertEquals(null,oSeedUnitOrder.Ship_To_Org_Id__c);
            system.assertEquals(null,oSeedUnitOrder.Ship_To_County__c);
            system.assertEquals(null,oSeedUnitOrder.Ship_To_Postal_Code__c);
            system.assertEquals(null,oSeedUnitOrder.Ship_To_State_Province__c);
            system.assertEquals(null,oSeedUnitOrder.Ship_To_Customer_Account__c);
        test.stopTest();
    }

    static testMethod void testDelete() {
        //Tests the Seed_Unit_Order_Utility.checkSubmittedOrder method
        
        //Create account for testing
        Account oAccount = Test_Environment_Utility.createInsertAccountUS();
        //Create contact for testing
        Contact oContact = Test_Environment_Utility.createInsertContact(oAccount);
        //Create opportunity for testing
        Opportunity oOpportunity = Test_Environment_Utility.createInsertOpportunity('Ergotron Forecast Opportunity', oAccount, 'Seeding', Date.today());
        //Create seed unit order for testing
        Seed_Unit_Order__c oSeedUnitOrder = Test_Environment_Utility.createInsertSeedUnitOrder(oOpportunity, 'Hospital', oAccount, oContact);
        //Create product for testing
        Product2 oProduct = Test_Environment_Utility.createInsertProduct();
        //Create seed unit product for testing
        Seed_Unit_Product__c oSeedUnitProduct = Test_Environment_Utility.createInsertSeedUnitProduct(oSeedUnitOrder, oProduct, 5);
        
        test.startTest();
            //Update Seed_Unit_Order__c and set Seed Unit Order Submitted flag to true
            oSeedUnitOrder.Seed_Unit_Order_Submitted__c=true;
            update oSeedUnitOrder;
            
            try{
                delete oSeedUnitOrder;
            }
            catch(Exception oException){
                system.assert(oException.getMessage().contains('This seed unit order cannot be deleted because it has already been submitted to Oracle.'));
            }
        test.stopTest();
    }
}