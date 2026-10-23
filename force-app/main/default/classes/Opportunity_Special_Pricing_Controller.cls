/*
    Controller class for the OpportunitySpecialPricing.page.

    MOD DATE        Who                     Description
    3/25/2014       Chris Noe               Initial Release
    5/20/2014       Chris Noe               Updated display logic to require selection of 'Distributor' and 'Reseller' on the Partners related list.
    6/29/2015       Chris Noe               Updates for the new Opportunity_Partner__c object - FB-00653.
	7/2/2019		Esau Sanchez			Changed == to contains for the SPR_Type__c comparisons to allow "APAC Special Pricing" to be considered. 
*/

public with sharing class Opportunity_Special_Pricing_Controller {
    private Opportunity oOpportunity {get;private set;}
    private List<Opportunity_Partner__c> listOpportunityDistributors {get;private set;}
    private List<Opportunity_Partner__c> listOpportunityResellers {get;private set;}
    private List<OpportunityContactRole> listOpportunityContactRoles {get;private set;}
    
    public Boolean bOpptyDistributor {get;private set;}         //Does this opportunity have Opportunity_Partner__c records where Partner_Role__c='Distributor'?
    public Boolean bOpptyReseller {get;private set;}            //Does this opportunity have Opportunity_Partner__c records where Partner_Role__c='Reseller'?
    public Boolean bOpptyContactRoles {get;private set;}        //Does this opportunity have OpportunityContactRole records?
    public Boolean bOpptyProducts {get;private set;}            //Does this opportunity have products if required (special pricing type)?
    public Boolean bRequiredSPRFields {get;private set;}        //Have the fields required for SPR approval submission been populated?
    public Boolean bDisplaySubmitButton {get;private set;}      //Display the submit for approval button
    private ApexPages.StandardController oStandardController;
    public String sRedirectUrl {public get; private set;}
    public Boolean bShouldRedirect {public get; private set;}   
    
    public Opportunity_Special_Pricing_Controller(ApexPages.StandardController oStdController) {
        this.oStandardController = oStdController;
        bShouldRedirect=false;
        
        //Retrieve the opportunity record
        this.oOpportunity = (Opportunity)oStdController.getRecord();
        
        //Retrieve related Opportunity_Partner__c and OpportunityContactRole records
        this.listOpportunityDistributors = [select Id from Opportunity_Partner__c where Opportunity__c = :oOpportunity.Id and Partner_Role__c='Distributor'];
        this.listOpportunityResellers = [select Id from Opportunity_Partner__c where Opportunity__c = :oOpportunity.Id and Partner_Role__c='Reseller'];
        this.listOpportunityContactRoles = [select Id from OpportunityContactRole where OpportunityId = :oOpportunity.Id and Role='Reseller Contact'];
        
        //Set flags used to determine if opportunity partner and opportunity contact roles have been added
        bOpptyDistributor = !listOpportunityDistributors.isEmpty();
        bOpptyReseller = !listOpportunityResellers.isEmpty();
        bOpptyContactRoles = !listOpportunityContactRoles.isEmpty();
        
        //Determine if special pricing request requires and has products
        if(( (oOpportunity.SPR_Type__c != null  && oOpportunity.SPR_Type__c.contains('Special Pricing')) && 
            oOpportunity.HasOpportunityLineItem) || oOpportunity.SPR_Type__c=='Advantage Account Registration') {
            bOpptyProducts=true;
        }
        else {
            bOpptyProducts=false;   
        }
        
        //Determine if required Advantage Registration/Special Pricing fields have been populated
        if((oOpportunity.SPR_Type__c != null  && oOpportunity.SPR_Type__c.contains('Special Pricing')) && oOpportunity.SPR_Reason__c!=NULL && (oOpportunity.Expected_Order_Date__c!=NULL || oOpportunity.Expected_Ship_Date__c!=NULL) && oOpportunity.Business_Justification__c!=NULL){
            bRequiredSPRFields=true;
        }
        
        else if(oOpportunity.SPR_Type__c=='Advantage Account Registration' && oOpportunity.Advantage_Submission_Notes__c!=NULL && oOpportunity.Advantage_Requested_Date__c!=NULL){
            bRequiredSPRFields=true;
        }
        
        else {
            bRequiredSPRFields=false;
        }
        
        //Determine if approval submission button should be displayed
        if(bOpptyDistributor && bOpptyReseller && bOpptyContactRoles && (bOpptyProducts || oOpportunity.SPR_Type__c=='Advantage Account Registration') && bRequiredSPRFields && (oOpportunity.SPR_Status__c==NULL || oOpportunity.SPR_Status__c=='Special Pricing-Sales Director Rejected' || oOpportunity.SPR_Status__c=='Special Pricing-Program Manager Rejected')) {
            bDisplaySubmitButton=true;
        }
        else {
            bDisplaySubmitButton=false;
        }
    }
    
    public PageReference SubmitSPRApproval() {
        //Method variables
        Approval.ProcessSubmitRequest oApprovalProcess = new Approval.ProcessSubmitRequest();
        Approval.ProcessResult oProcessResult;      

        //Submit to approval process
        try{
            if(oOpportunity.SPR_Type__c != null  && oOpportunity.SPR_Type__c.contains('Special Pricing')) {
                oApprovalProcess.setComments('Special Pricing approval request.');  
            }
            
            else if(oOpportunity.SPR_Type__c=='Advantage Account Registration') {
                oApprovalProcess.setComments('Advantage Account Registration approval request.');
            }
            
            oApprovalProcess.setObjectId(oOpportunity.id);
            oProcessResult = Approval.process(oApprovalProcess);
        }
        catch(Exception oException){
            ApexPages.addMessages(oException);
            return null;
        }
        
        bShouldRedirect = true;
        sRedirectUrl = oStandardController.view().getUrl();
        return null;
    }
}