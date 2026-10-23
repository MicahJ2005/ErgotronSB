/*
	Controller class for the CampaignSpendHierarchy.page.

	MOD DATE		Who						Description
	1/19/2015		Chris Noe				Initial Release
*/

public with sharing class Campaign_Spend_Hierarchy_Controller {
	private Campaign oCampaign {get;private set;}
	public List<Campaign> listSpendCampaigns {get;private set;}
	public Boolean bRendered {get;private set;}

	public Campaign_Spend_Hierarchy_Controller(ApexPages.StandardController oStdController) {
        //Retrieve the current Campaign record
        this.oCampaign = (Campaign)oStdController.getRecord();

        this.listSpendCampaigns = [select Id, Name, Partner__r.Name, StartDate, EndDate, Actual_Spend__c 
        							from Campaign where ParentId = :oCampaign.Id and RecordType.Name='Ergotron MDF/VIR Spend Campaign' order by Partner__r.Name, StartDate];

        bRendered = false;
        bRendered = bRendered || listSpendCampaigns.size()>0;
	}
}