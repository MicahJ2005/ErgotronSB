/*
    Controller class for the Deal_Reg_Drafts_Cntrl.cls.

    MOD DATE        Who                     Description
    11/04/2014      Chris Noe               Initial Release 
*/

@IsTest
private class Deal_Reg_Drafts_Cntrl_Test {

    static testmethod void testDraftList() {
        User oUser = new User();

        //Create new user with random email addresss.
        String sEmail = String.valueOf(math.random()).left(20) + '@ergotron.com';
        String sUserName = sEmail.replace('@', '.') + '@dealreg.ergotron.com';

        //Create account and contact for new user
        Account oAccount = Test_Environment_Utility.createInsertAccountUS();
        Contact oContact = Test_Environment_Utility.createInsertPartnerContact(oAccount, sEmail);

        System.runAs(new User(Id = UserInfo.getUserId())){
            //Create community user record
            oUser = Test_Environment_Utility.createInsertCommunityUser(sUserName, sEmail, oContact.Id);
        }

        //Create web service details record record by lead assignment callout
        Web_Service_Details__c oWebService = Test_Environment_Utility.createInsertWebServiceDetails('Territory Lookup');
        
        Test.startTest();
            system.runAs(oUser) {
                Lead oLead = new Lead(LastName='Test',Company='Test');
                insert oLead;

				Test.setCurrentPage(Page.DealRegDrafts);
				ApexPages.StandardController oStdCntrl = new ApexPages.StandardController(oLead);

				Deal_Reg_Drafts_Cntrl oExtCntrl = new Deal_Reg_Drafts_Cntrl(oStdCntrl);

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
            }
        Test.stopTest();
    }
}