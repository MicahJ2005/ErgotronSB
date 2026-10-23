/*
    Test class for the Opportunity_Product_Utility.cls.

    MOD DATE        Who                     Description
    03/12/2015      Chris Noe               Initial Release 
*/

@IsTest(seeAllData=true)
private class Opportunity_Product_Utility_Test {

    static testmethod void testOpptyPartnerUtility() {
		//Create Account for testing
		Account oAccount = Test_Environment_Utility.createInsertAccountUS();

		//Create opportunity for testing
		Opportunity oOpportunity = Test_Environment_Utility.createOpportunity('Ergotron Forecast Opportunity', oAccount, 'Prospecting', Date.today());
		insert oOpportunity;

		//Retrieve pricebook and product for test
        PricebookEntry oPBE = [select Id, Pricebook2Id, UnitPrice, Product2Id from PricebookEntry where Pricebook2.Name='US STANDARD PRICE LIST' and isActive=true limit 1];

        //Create OpportunityLineItem records for test
        OpportunityLineItem oOLI = new OpportunityLineItem(PricebookEntryId=oPBE.Id, UnitPrice=oPBE.UnitPrice, Target_End_User_Price__c=oPBE.UnitPrice, OpportunityId=oOpportunity.Id, Quantity=100);
        insert oOLI;

		//Intantiate controller and set opportunity id
		Opportunity_Product_Utility oCntrl = new Opportunity_Product_Utility();
		oCntrl.setsOpportunityId(oOpportunity.Id);
		system.assertEquals(oCntrl.getsOpportunityId(),oOpportunity.Id);

		//Get list of products for the opportunity and assert 1 record in the list
		List<Object> listProducts = oCntrl.getlistProducts();
		system.assertEquals(1,listProducts.size());

		//Set opportunity id to blank and assert null return
		oCntrl.setsOpportunityId('');
		system.assertEquals(null,oCntrl.getlistProducts());
    }
}