/*
    Test class for the Opportunity_Margin_Utility.cls.

    MOD DATE        Who                     Description
    03/13/2015      Chris Noe               Initial Release 
*/

@IsTest
private class Opportunity_Margin_Utility_Test {

    static testmethod void testOpptyMarginUtility() {
		//Create Account for testing
		Account oAccount = Test_Environment_Utility.createInsertAccountUS();

		//Create opportunity for testing
		Opportunity oOpportunity = Test_Environment_Utility.createOpportunity('Ergotron Forecast Opportunity', oAccount, 'Prospecting', Date.today());
		insert oOpportunity;

		//Intantiate controller and set opportunity id
		Opportunity_Margin_Utility oCntrl = new Opportunity_Margin_Utility();
		oCntrl.setsOpportunityId(oOpportunity.Id);
		system.assertEquals(oCntrl.getsOpportunityId(),oOpportunity.Id);

		//Assert margin value of 0.0.
		system.assertEquals(0.0,oCntrl.getdOverallProductMargin());

		//Set opportunity id to blank and assert null return
		oCntrl.setsOpportunityId('');
		system.assertEquals(null,oCntrl.getdOverallProductMargin());
    }
}