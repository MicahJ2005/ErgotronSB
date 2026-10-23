/*
	Controller class for the CampaignBucketHierarchy.page.

	MOD DATE		Who						Description
	1/19/2015		Chris Noe				Initial Release
*/

public with sharing class Campaign_Bucket_Hierarchy_Controller {
	private Campaign oCampaign {get;private set;}
	public List<Campaign> listBucketCampaigns {get;private set;}
	public Boolean bRendered {get;private set;}

	public Campaign_Bucket_Hierarchy_Controller(ApexPages.StandardController oStdController) {
        //Retrieve the current Campaign record
        this.oCampaign = (Campaign)oStdController.getRecord();

        this.listBucketCampaigns = [select Id, Name, Partner__r.Name, StartDate, EndDate, Actual_Spend__c, Rollover_from_Previous__c, Budget_Accrual__c, Rollover_to_Next__c 
        							from Campaign where ParentId = :oCampaign.Id and RecordType.Name='Ergotron MDF/VIR Checkbook Campaign' order by Partner__r.Name, StartDate];

        bRendered = false;
        bRendered = bRendered || listBucketCampaigns.size()>0;
	}
}