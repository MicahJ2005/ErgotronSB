/*
	Controller class for the SeedApprovalMessage.page.

	MOD DATE		Who						Description
	4/11/2014		Chris Noe				Initial Release
*/

public with sharing class Seed_Approval_Message_Controller {
	private Seed_Unit_Order__c oSeedUnitOrder {get;private set;}
	private List<Seed_Unit_Product__c> listSeedProducts {get;private set;}
	public Boolean bContainsNotEligibleProducts {get;private set;}
	
	public Seed_Approval_Message_Controller(ApexPages.StandardController oStdController) {
         //Retrieve the seed unit order record
        this.oSeedUnitOrder = (Seed_Unit_Order__c)oStdController.getRecord();
        
        //Retrieve list of Seed_Unit_Product__c records that contain products which are not eligible for seeding
        this.listSeedProducts = [select Id from Seed_Unit_Product__c where Seed_Unit_Order__c = :this.oSeedUnitOrder.Id and Seed_Unit_Eligible__c = false];
        
        if(this.listSeedProducts.isEmpty()){
        	bContainsNotEligibleProducts=false;
        }
        else{
        	bContainsNotEligibleProducts=true;
        }
	}	
}