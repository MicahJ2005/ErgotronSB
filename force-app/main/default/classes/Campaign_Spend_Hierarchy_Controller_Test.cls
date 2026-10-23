/*
	Test class for Campaign_Spend_Hierarchy_Controller.cls

	MOD DATE		Who						Description
	1/22/2015		Chris Noe				Initial Release
*/
@isTest
private class Campaign_Spend_Hierarchy_Controller_Test {
	static testmethod void testConstructor() {
        //Test method for Campaign_Spend_Hierarchy_Controller constructor
        
        //Create campaigns for testing
        Campaign oParentCampaign = Test_Environment_Utility.createInsertCampaign('Ergotron MDF Bucket Campaign', null);
        Campaign oChildCampaign = Test_Environment_Utility.createInsertCampaign('Ergotron MDF/VIR Spend Campaign', oParentCampaign.Id);
		
        Test.startTest();
            //Set the page reference
            PageReference oPageRef = Page.CampaignSpendHierarchy;
            Test.setCurrentPage(oPageRef);

            //Invoke the standard and extension controllers with the parent campaign created above
			ApexPages.StandardController oStdControllerOrder = new ApexPages.StandardController(oParentCampaign);
            oPageRef.getParameters().put('id',String.valueOf(oParentCampaign.Id));
			Campaign_Spend_Hierarchy_Controller oExtController = new Campaign_Spend_Hierarchy_Controller(oStdControllerOrder);

			//Assertions
			system.assertEquals(true,oExtController.bRendered);
			system.assertEquals(1,oExtController.listSpendCampaigns.size());
			system.assertEquals(oChildCampaign.Id,oExtController.listSpendCampaigns[0].Id);
        Test.stopTest();
	}
}