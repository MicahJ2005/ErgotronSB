/*
	Test class for Product2_Trigger.trigger and Product2_Utility.cls.

	MOD DATE		Who						Description
	2/13/2014		Chris Noe				Initial Release
	6/30/2014		Chris Noe				Updates to test methods to accomodate for changes to Product2_Trigger and Product2_Utility.cls.
	7/15/2014		Chris Noe				Added assertion logic for new default quantity and revenue schedule logic on Product2_Utility.cls.
*/

@isTest
private class Product2_Utility_Test {
	
	@isTest (SeeAllData=true) //SeeAllData=true required since we are working with standard price book
    static void testUpdateProduct2Single() {
    	//Tests insert and update of a single Product2 record
    	
    	//Method Variables
    	Map<Id, Double> mapStandardPrices = new Map<Id, Double>();
    	
    	Product2 oProduct = new Product2();
    	oProduct.Name='TEST';
    	oProduct.IsActive=true;
    	insert oProduct;

		//Assertions for standard prices
		for(PricebookEntry oPBE :[select Product2Id, UnitPrice from PricebookEntry where Pricebook2.IsStandard=true and Product2Id = :oProduct.Id]){
			mapStandardPrices.put(oPBE.Product2Id,oPBE.UnitPrice);
		}
		
		if(!mapStandardPrices.IsEmpty()){
			system.assertEquals(0.0, mapStandardPrices.get(oProduct.Id));
		}    	
		
		//Assertions for schedule defaults
		oProduct = [select Id, CanUseQuantitySchedule, QuantityScheduleType, QuantityInstallmentPeriod, NumberOfQuantityInstallments from Product2 where Id = :oProduct.Id];
					
		system.assertEquals(true,oProduct.CanUseQuantitySchedule);
		system.assertEquals('Divide',oProduct.QuantityScheduleType);
		system.assertEquals('Monthly',oProduct.QuantityInstallmentPeriod);
		system.assertEquals(1,oProduct.NumberOfQuantityInstallments);
    }
}