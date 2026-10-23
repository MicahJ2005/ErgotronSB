/*
	Controller class for the ComparePricing.page.

	MOD DATE		Who						Description
	06/04/2015		Chris Noe				Initial Release
*/

public with sharing class Compare_Pricing_Controller {
	//Class variables
	private Opportunity oOpportunity {get;private set;}
	public List<pricingProduct> listProducts {get;private set;}
    public String sApprovedPartId {get;set;}
    private Map<Id,Approved_Special_Pricing__c> mapApprovedProductIds {private get;private set;}

	public Compare_Pricing_Controller(ApexPages.StandardController oStdController) {
		//Retrieve the opportunity
        this.oOpportunity = (Opportunity)oStdController.getRecord();

        //Declare new instance of listProducts
        listProducts = new List<pricingProduct>();

        //Declare maps for OpportunityLineItem and Approved_Pricing__c records which will be used to populate the listProducts inner class. Map keys will be part number.
        Map<String,OpportunityLineItem> mapOppProducts = new Map<String,OpportunityLineItem>();
        Map<String,Approved_Special_Pricing__c> mapApprovedProducts = new Map<String,Approved_Special_Pricing__c>();
        mapApprovedProductIds = new Map<Id,Approved_Special_Pricing__c>();

        //Populate mapOppProducts with OpportunityLineItem records for this Opportunity
        for(OpportunityLineItem oOppLineItem :[select Product2.ProductCode,Quantity,Target_Rebate_Amount__c 
        	from OpportunityLineItem where OpportunityId = :oOpportunity.Id order by Product2.ProductCode]){
        	mapOppProducts.put(oOppLineItem.Product2.ProductCode,oOppLineItem);
        }

        //Populate mapApprovedProducts with Approved_Special_Pricing__c records for this Opportunity.  Populate mapApprovedProductIds which 
        //is used in the addToSalesforce method when adding OpportunityLineItem records based on Approved_Special_Pricing__c records.
        for(Approved_Special_Pricing__c oApprovedLineItem :[select Item_Number__c,Quantity__c,Rebate_Amount__c 
        	from Approved_Special_Pricing__c where Opportunity__c = :oOpportunity.Id order by Item_Number__c]){
        	mapApprovedProducts.put(oApprovedLineItem.Item_Number__c,oApprovedLineItem);
            mapApprovedProductIds.put(oApprovedLineItem.Id,oApprovedLineItem);
        }

        //Build listProducts based on the map values populated above - this logic checks to see if each record in OpportunityLineItem exists in Approved_Special_Pricing__c.  If
        //the part numbers, quantity, or rebate amount does not match, then add to the list of items to display on the page.
        for(String sPartNumber :mapOppProducts.keySet()){
        	//Create new instance of the inner class
        	pricingProduct oProduct = new pricingProduct();

        	//Populate the inner class values for the Approved_Special_Pricing__c records if they exist for the current part number 
        	if(mapApprovedProducts.containsKey(sPartNumber)){
        		//OpportunityLineItem part number exists in Approved_Special_Pricing__c list. Check to make sure that the Quantity and Rebate Amount values
                //match.  If they do not match, add to the inner class list.
                if(mapOppProducts.get(sPartNumber).Quantity!=mapApprovedProducts.get(sPartNumber).Quantity__c || 
                    mapOppProducts.get(sPartNumber).Target_Rebate_Amount__c!=mapApprovedProducts.get(sPartNumber).Rebate_Amount__c) {
                    //Quantity or Rebate do not match, add record to inner class
                    oProduct.sOpptyPartNumber=sPartNumber;
                    oProduct.dOpptyPartQuantity=mapOppProducts.get(sPartNumber).Quantity;
                    oProduct.dOpptyPartRebate=mapOppProducts.get(sPartNumber).Target_Rebate_Amount__c;                
                    oProduct.sApprovedPartNumber=sPartNumber;
                    oProduct.dApprovedPartQuantity=mapApprovedProducts.get(sPartNumber).Quantity__c;
                    oProduct.dApprovedPartRebate=mapApprovedProducts.get(sPartNumber).Rebate_Amount__c;
                    oProduct.bAddToSalesforce=false;
                    oProduct.sApprovedPartId=mapApprovedProducts.get(sPartNumber).Id;

                    listProducts.add(oProduct);
                }
        	}
            else{
                //OpportunityLineItem part number does not exist in the approved list, populate the inner class values for the OpportunityLineItem values
                oProduct.sOpptyPartNumber = sPartNumber;
                oProduct.dOpptyPartQuantity = mapOppProducts.get(sPartNumber).Quantity;
                oProduct.dOpptyPartRebate = mapOppProducts.get(sPartNumber).Target_Rebate_Amount__c;
                oProduct.bAddToSalesforce=false;

                listProducts.add(oProduct);
            }
        }

        //Now loop through the map of Approved_Special_Pricing__c records and see if any part numbers are missing from OpportunityLineItem records.
        for(String sPartNumber :mapApprovedProducts.keySet()){
        	//Check to see if the current part number exists in the OpportunityLineItem list for this Opportunity.
        	if(!mapOppProducts.containsKey(sPartNumber)){
        		//Current Approved_Special_Pricing__c record does not exist as an OpportunityLineItem record for this opportunity. Add it to the inner class list
        		pricingProduct oProduct = new pricingProduct();
        		oProduct.sApprovedPartNumber=sPartNumber;
        		oProduct.dApprovedPartQuantity=mapApprovedProducts.get(sPartNumber).Quantity__c;
        		oProduct.dApprovedPartRebate=mapApprovedProducts.get(sPartNumber).Rebate_Amount__c;
                //Set flag that will allow user to add the Approved_Special_Pricing__c part number to the OpportunityLineItem
                oProduct.bAddToSalesforce=true;
                oProduct.sApprovedPartId=mapApprovedProducts.get(sPartNumber).Id;

        		listProducts.add(oProduct);
        	}
        }
	}

	public PageReference returnToOpportunity(){
    	PageReference oPageRef = new PageReference('/' + oOpportunity.Id);
        oPageRef.setRedirect(true);
        return oPageRef;
	}

    public PageReference addToSalesforce(){
        //This method will add a new OpportunityLineItem record to the existing opportunity based on the values on an Approved_Special_Pricing__c record.
        //When a user clicks on the "Add To Salesforce" link, this method will be called which will add the product as an OpportunityLineItem record.

        //Method Variables
        PricebookEntry oPBE = new PricebookEntry();
        OpportunityLineItem oOpptyLineItem = new OpportunityLineItem();
        OpportunityLineItemSchedule oOpptyLineItemSchedule = new OpportunityLineItemSchedule();

        //Retrieve the PricebookEntry record based on the Opportunity.Pricebook2Id and Approved_Special_Pricing__c.Item_Number__c values
        oPBE = [select Id, UnitPrice from PricebookEntry where Pricebook2Id = :oOpportunity.Pricebook2Id and ProductCode = :mapApprovedProductIds.get(sApprovedPartId).Item_Number__c and IsActive=true];

        //Create and insert OpportunityLineItem record.
        oOpptyLineItem.OpportunityId=oOpportunity.Id;
        oOpptyLineItem.PricebookEntryId=oPBE.Id;
        oOpptyLineItem.Quantity=mapApprovedProductIds.get(sApprovedPartId).Quantity__c;
        oOpptyLineItem.UnitPrice=oPBE.UnitPrice;
        oOpptyLineItem.Estimated_Distribution_Margin__c=4.0;
        oOpptyLineItem.Estimated_Reseller_Margin__c=10.0;
        oOpptyLineItem.Rebate_Amount__c=mapApprovedProductIds.get(sApprovedPartId).Rebate_Amount__c;

        insert oOpptyLineItem;

        //Create and insert OpportunityLineItemSchedule record for the OpportunityLineItem created above
        oOpptyLineItemSchedule.OpportunityLineItemId=oOpptyLineItem.Id;
        oOpptyLineItemSchedule.Quantity=mapApprovedProductIds.get(sApprovedPartId).Quantity__c;
        oOpptyLineItemSchedule.ScheduleDate=oOpportunity.CloseDate;
        oOpptyLineItemSchedule.Type='Quantity';

        insert oOpptyLineItemSchedule;

        PageReference oPageRef = Page.ComparePricing;
        oPageRef.getParameters().put('id',String.valueOf(oOpportunity.Id));
        oPageRef.setRedirect(true);
        return oPageRef;
    }

    //Inner class used for displaying a comparison between the opportunity products and approved special pricing lists on an Opportunity.
    public with sharing class pricingProduct {
    	public String sOpptyPartNumber {get;set;}
    	public Decimal dOpptyPartQuantity {get;set;}
    	public Decimal dOpptyPartRebate {get;set;}
    	public String sApprovedPartNumber {get;set;}
    	public Decimal dApprovedPartQuantity {get;set;}
    	public Decimal dApprovedPartRebate {get;set;}
        public Boolean bAddToSalesforce {get;set;}
        public String sApprovedPartId {get;set;}
    }
}