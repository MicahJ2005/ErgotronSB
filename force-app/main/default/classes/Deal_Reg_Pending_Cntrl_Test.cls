/*
    Controller class for the Deal_Reg_Pending_Cntrl.cls.

    MOD DATE        Who                     Description
    11/04/2014      Chris Noe               Initial Release 
*/

@IsTest
private class Deal_Reg_Pending_Cntrl_Test {

    static testmethod void testPendingList() {
		//Get user for testing
        User oUser = [select Id from User where ProfileId='00eG0000000g7Ph' and IsActive=true limit 1];

		//Create web service details record record by lead assignment callout
		Web_Service_Details__c oWebService = Test_Environment_Utility.createInsertWebServiceDetails('Territory Lookup');

		system.runAs(oUser) {
			Lead oLead = new Lead(LastName='Test',Company='Test',Status='Registration Submitted');
			insert oLead;

			Test.startTest();
				Test.setCurrentPage(Page.DealRegPending);
				ApexPages.StandardController oStdCntrl = new ApexPages.StandardController(oLead);

				Deal_Reg_Pending_Cntrl oExtCntrl = new Deal_Reg_Pending_Cntrl(oStdCntrl);

 				//Assert 1 record retrieved in the constructor
        		system.assertEquals(1,oExtCntrl.getlistLeads().size());

				//Call the toggle sort method and then assert that sSortDirection = 'asc'
        		oExtCntrl.toggleSort();
        		system.assertEquals('asc', oExtCntrl.sSortDirection);

        		//Assert boolean flags
        		system.assertEquals(false, oExtCntrl.bHasNext);
        		system.assertEquals(false, oExtCntrl.bHasPrevious);
        		system.assertEquals(false, oExtCntrl.bDisplayFirst);
        		system.assertEquals(false, oExtCntrl.bDisplayFirst);
        		system.assertEquals(false, oExtCntrl.bDisplayLast);
        		system.assertEquals(true, oExtCntrl.bDisplayList);
        		system.assertEquals(1, oExtCntrl.iPageNumber);
        		system.assertEquals(1, oExtCntrl.iNumberOfPages);
        		//Set first, last, previous, and next pages
        		oExtCntrl.first();
        		oExtCntrl.last();
        		oExtCntrl.previous();
        		oExtCntrl.next();
			Test.stopTest();
		}
    }
}