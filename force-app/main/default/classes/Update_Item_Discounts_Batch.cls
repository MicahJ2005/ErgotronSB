/*
	Batch class that updates distribution discounts for US, EMEA, and APAC based on discount category codes and discount classes from Oracle.  This batch class 
	runs nightly after Informatica jobs load Discount_Class__c records from Oracle.  This class is called from the Update_Item_Discounts_Schedule.cls scheduled class.

	MOD DATE		Who						Description
	03/06/2015		Chris Noe				Initial Release
	07/07/2022		Esau Sanchez			Add new discount class -- EMEA DIRECT DEALER
*/

global class Update_Item_Discounts_Batch implements Database.Batchable<sObject>, Database.Stateful{
	
	String sQuery;
	String sAPAC = 'BROADLINE APAC';
	String sEMEA = 'BROADLINE EMEA DISCOUNT';
	String sUS = 'BROADLINE US';
	String sEMEADD = 'EMEA DIRECT DEALER';
	Map<String,Map<String,Double>> mapDiscountClasses;
	
	global Update_Item_Discounts_Batch() {
		//Method variables
		String sCurrentDiscountClass;
		Map<String,Double> mapDiscountClass = new Map<String,Double>();

		//Retrieve all discount classes that are set up on the Discount_Class__c object and add them to a map which will be used to populate
		//the discount % for each region on each product.
		mapDiscountClasses = new Map<String,Map<String,Double>>();
		for(Discount_Class__c oDiscountClass : [select Name, Discount_Category_Code__c, Discount__c from Discount_Class__c order by Name]){
			//Populate the discount class map with a unique map item for each geography and discount code
    		if(oDiscountClass.Name!=sCurrentDiscountClass && sCurrentDiscountClass!=NULL){
    			Map<String,Double> mapDiscountClassToAdd = new Map<String,Double>();
    			mapDiscountClassToAdd=mapDiscountClass.clone();
    			
    			mapDiscountClasses.put(sCurrentDiscountClass,mapDiscountClassToAdd);
    			mapDiscountClass.clear();
    			mapDiscountClass.put(oDiscountClass.Discount_Category_Code__c,oDiscountClass.Discount__c);
    		}	
    		else {
    			mapDiscountClass.put(oDiscountClass.Discount_Category_Code__c,oDiscountClass.Discount__c);
    		}		
    		
    		sCurrentDiscountClass=oDiscountClass.Name;
    	}
    	
    	if(sCurrentDiscountClass!=NULL && !mapDiscountClass.isEmpty()) {
    		mapDiscountClasses.put(sCurrentDiscountClass,mapDiscountClass);
    	}

		//Build the batch query string to pull all Product2 records for update
		sQuery = 'select Id, Discount_Code__c, Broadline_US_Discount__c, Broadline_EMEA_Discount__c, Broadline_APAC_Discount__c, EMEA_Direct_Dealer_Discount__c from Product2';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(sQuery);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		//Method variables
		List<Product2> listProductScope = new List<Product2>();

		//Build list of products to update
		for(Sobject s : scope) {
			listProductScope.add((Product2)s);
		}

		//Loop through each product returned in the query and update the discount percentages.
		for(Product2 oProduct : listProductScope){
			//Check to see if Discount Code is applied to the product
			if(oProduct.Discount_Code__c!='' && oProduct.Discount_Code__c!=NULL && oProduct.Discount_Code__c!='NONE') {
				//Populate US Discount - Verify that the map values contain the correct keys
				if(mapDiscountClasses.containsKey(sUS)){
					if(mapDiscountClasses.get(sUS).containsKey(oProduct.Discount_Code__c)){
						oProduct.Broadline_US_Discount__c=mapDiscountClasses.get(sUS).get(oProduct.Discount_Code__c);
					}
					else {
						oProduct.Broadline_US_Discount__c=0.0;
					}
				}
				//Populate EMEA Discount - Verify that the map values contain the correct keys
				if(mapDiscountClasses.containsKey(sEMEA)){
					if(mapDiscountClasses.get(sEMEA).containsKey(oProduct.Discount_Code__c)){
						oProduct.Broadline_EMEA_Discount__c=mapDiscountClasses.get(sEMEA).get(oProduct.Discount_Code__c);
					}
					else {
						oProduct.Broadline_EMEA_Discount__c=0.0;
					}
				}
				//Populate APAC Discount - Verify that the map values contain the correct keys
				if(mapDiscountClasses.containsKey(sAPAC)){
					if(mapDiscountClasses.get(sAPAC).containsKey(oProduct.Discount_Code__c)){
						oProduct.Broadline_APAC_Discount__c=mapDiscountClasses.get(sAPAC).get(oProduct.Discount_Code__c);
					}
					else {
						oProduct.Broadline_APAC_Discount__c=0.0;
					}
				}
				//Populate EMEA Direct Dealer Discount - Verify that the map values contain the correct keys
				if(mapDiscountClasses.containsKey(sEMEADD)){
					if(mapDiscountClasses.get(sEMEADD).containsKey(oProduct.Discount_Code__c)){
						oProduct.EMEA_Direct_Dealer_Discount__c=mapDiscountClasses.get(sEMEADD).get(oProduct.Discount_Code__c);
					}
					else {
						oProduct.EMEA_Direct_Dealer_Discount__c=0.0;
					}
				}
			}

			else {
				oProduct.Broadline_US_Discount__c=0.0;
				oProduct.Broadline_EMEA_Discount__c=0.0;
				oProduct.Broadline_APAC_Discount__c=0.0;
				oProduct.EMEA_Direct_Dealer_Discount__c=0.0;
			}
		}

		update listProductScope;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
}