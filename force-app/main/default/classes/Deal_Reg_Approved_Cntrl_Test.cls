/*
    Controller class for the Deal_Reg_Approved_Cntrl.cls.

    MOD DATE        Who                     Description
    11/04/2014      Chris Noe               Initial Release 
*/

@IsTest
private class Deal_Reg_Approved_Cntrl_Test {

    static testmethod void testApprovedPendingPricing() {
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
    			Lead oLead = new Lead(LastName='Test',Company='Test',Status='Registration Approved - Pending Pricing');
    			insert oLead;

    			Test.setCurrentPage(Page.DealRegApproved);
    			ApexPages.StandardController oStdCntrl = new ApexPages.StandardController(oLead);

    			Deal_Reg_Approved_Cntrl oExtCntrl = new Deal_Reg_Approved_Cntrl(oStdCntrl);

    				//Assert 1 record retrieved in the constructor
        		system.assertEquals(1,oExtCntrl.getlistLeadsApprovedPendingPricing().size());

    			//Call the toggle sort method and then assert that sSortDirection = 'asc'
        		oExtCntrl.toggleSortApprovedPendingPricing();
        		system.assertEquals('desc', oExtCntrl.sSortDirectionApprovedPendingPricing);

        		//Assert boolean flags
        		system.assertEquals(false, oExtCntrl.bHasNextApprovedPendingPricing);
        		system.assertEquals(false, oExtCntrl.bHasPreviousApprovedPendingPricing);
        		system.assertEquals(false, oExtCntrl.bDisplayFirstApprovedPendingPricing);
        		system.assertEquals(false, oExtCntrl.bDisplayFirstApprovedPendingPricing);
        		system.assertEquals(false, oExtCntrl.bDisplayLastApprovedPendingPricing);
        		system.assertEquals(true, oExtCntrl.bDisplayListApprovedPendingPricing);
        		system.assertEquals(1, oExtCntrl.iPageNumberApprovedPendingPricing);
        		system.assertEquals(1, oExtCntrl.iNumberOfPagesApprovedPendingPricing);
        		//Set first, last, previous, and next pages
        		oExtCntrl.firstApprovedPendingPricing();
        		oExtCntrl.lastApprovedPendingPricing();
        		oExtCntrl.previousApprovedPendingPricing();
        		oExtCntrl.nextApprovedPendingPricing();
            }
		Test.stopTest();
    }

    static testmethod void testApprovedPriced() {
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
                Lead oLead = new Lead(LastName='Test',Company='Test',Status='Registration Approved - Priced');
                insert oLead;

				Test.setCurrentPage(Page.DealRegApproved);
				ApexPages.StandardController oStdCntrl = new ApexPages.StandardController(oLead);

				Deal_Reg_Approved_Cntrl oExtCntrl = new Deal_Reg_Approved_Cntrl(oStdCntrl);

 				//Assert 1 record retrieved in the constructor
        		system.assertEquals(1,oExtCntrl.getlistLeadsApprovedPriced().size());

				//Call the toggle sort method and then assert that sSortDirection = 'asc'
        		oExtCntrl.toggleSortApprovedPriced();
        		system.assertEquals('desc', oExtCntrl.sSortDirectionApprovedPriced);

        		//Assert boolean flags
        		system.assertEquals(false, oExtCntrl.bHasNextApprovedPriced);
        		system.assertEquals(false, oExtCntrl.bHasPreviousApprovedPriced);
        		system.assertEquals(false, oExtCntrl.bDisplayFirstApprovedPriced);
        		system.assertEquals(false, oExtCntrl.bDisplayFirstApprovedPriced);
        		system.assertEquals(false, oExtCntrl.bDisplayLastApprovedPriced);
        		system.assertEquals(true, oExtCntrl.bDisplayListApprovedPriced);
        		system.assertEquals(1, oExtCntrl.iPageNumberApprovedPriced);
        		system.assertEquals(1, oExtCntrl.iNumberOfPagesApprovedPriced);
        		//Set first, last, previous, and next pages
        		oExtCntrl.firstApprovedPriced();
        		oExtCntrl.lastApprovedPriced();
        		oExtCntrl.previousApprovedPriced();
        		oExtCntrl.nextApprovedPriced();
            }
        Test.stopTest();
    }
}