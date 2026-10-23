/*
	Test class for Update_Item_Discounts_Batch.cls and Update_Item_Discounts_Schedule

	MOD DATE		Who						Description
	03/09/2015		Chris Noe				Initial Release
	07/07/2022		Esau Sanchez			Add new discount class - EMEA DIRECT DEALER
*/

@isTest
private class Update_Item_Discounts_Test {
    
    static testMethod void testUpdateItemDiscountsBatch() {
    	//Tests the Update_Item_Discounts_Batch.cls
    	
    	//Create Product2 records for test
    	Product2 oProduct = Test_Environment_Utility.createInsertProduct();
    	oProduct.Discount_Code__c = 'RED';
    	update oProduct;

    	Product2 oProductNoDiscountCode = Test_Environment_Utility.createInsertProduct();

		//Create Discount_Class__c records for testing
		List<Discount_Class__c> listDiscountClasses = new List<Discount_Class__c>();

		Discount_Class__c oDiscountClassAPAC = new Discount_Class__c(Name='BROADLINE APAC', Discount_Category_Code__c='RED', Discount__c=0.04);
		listDiscountClasses.add(oDiscountClassAPAC);
		Discount_Class__c oDiscountClassEMEA = new Discount_Class__c(Name='BROADLINE EMEA DISCOUNT', Discount_Category_Code__c='RED', Discount__c=0.04);
		listDiscountClasses.add(oDiscountClassEMEA);
		Discount_Class__c oDiscountClassUS = new Discount_Class__c(Name='BROADLINE US', Discount_Category_Code__c='RED', Discount__c=0.04);
		listDiscountClasses.add(oDiscountClassUS);
		Discount_Class__c oDisctountClassEMEADD = new Discount_Class__c(Name='EMEA DIRECT DEALER', Discount_Category_Code__c='RED', Discount__c=0.04);
		listDiscountClasses.add(oDisctountClassEMEADD);

		insert listDiscountClasses;

		Test.startTest();
			String sJob = Database.executeBatch(new Update_Item_Discounts_Batch(), 2);
		Test.stopTest();

		list<AsyncApexJob> listAsyncJob = [select Id from AsyncApexJob where Id=:sJob];
		system.assert(listAsyncJob.size()>0);
    }

    static testMethod void testUpdateItemDiscountsBatchNoDiscountClasses() {
    	//Tests the Update_Item_Discounts_Batch.cls when no discount class records exist for a specific discount code
    	
    	//Create Product2 records for test
    	Product2 oProduct = Test_Environment_Utility.createInsertProduct();
    	oProduct.Discount_Code__c = 'RED';
    	update oProduct;

    	Product2 oProductNoDiscountCode = Test_Environment_Utility.createInsertProduct();

		//Create Discount_Class__c records for testing
		List<Discount_Class__c> listDiscountClasses = new List<Discount_Class__c>();

		Discount_Class__c oDiscountClassAPAC = new Discount_Class__c(Name='BROADLINE APAC', Discount_Category_Code__c='BLUE', Discount__c=0.04);
		listDiscountClasses.add(oDiscountClassAPAC);
		Discount_Class__c oDiscountClassEMEA = new Discount_Class__c(Name='BROADLINE EMEA DISCOUNT', Discount_Category_Code__c='BLUE', Discount__c=0.04);
		listDiscountClasses.add(oDiscountClassEMEA);
		Discount_Class__c oDiscountClassUS = new Discount_Class__c(Name='BROADLINE US', Discount_Category_Code__c='BLUE', Discount__c=0.04);
		listDiscountClasses.add(oDiscountClassUS);
		Discount_Class__c oDisctountClassEMEADD = new Discount_Class__c(Name='EMEA DIRECT DEALER', Discount_Category_Code__c='BLUE', Discount__c=0.04);
		listDiscountClasses.add(oDisctountClassEMEADD);

		insert listDiscountClasses;

		Test.startTest();
			String sJob = Database.executeBatch(new Update_Item_Discounts_Batch(), 2);
		Test.stopTest();

		list<AsyncApexJob> listAsyncJob = [select Id from AsyncApexJob where Id=:sJob];
		system.assert(listAsyncJob.size()>0);
    }

	static testMethod void testUpdateItemDiscountsSchedule(){
		//Tests the Update_Item_Discounts_Schedule.cls

        test.startTest();
            String sch = '0 1 * * * ?'; 
            String jobId = system.schedule('Schedule Job', sch, new Update_Item_Discounts_Schedule());
        test.stopTest();

        system.assert([SELECT c.Id FROM CronTrigger c WHERE c.Id=:jobId].size()>0);
    }
}