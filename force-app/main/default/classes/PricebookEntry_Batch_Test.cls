/*
    Test class for the PricebookEntry_Batch batch job

    MOD DATE        Who                     
    02/04/2020      Sophia Murphy (Demand Chain)
                    Initial Creation 
*/
@IsTest
private class PricebookEntry_Batch_Test {

    static testmethod void testOne() {
        
        Test_Environment_Utility.setupCustomSettings();
        
        //Integer numToCreate = 5;
        //We need a cc_acct_group created...
        ccrz__E_AccountGroup__c cAG = new ccrz__E_AccountGroup__c ();
        cAG.Name = 'Replacement Parts';
        insert cAG;
        
        List<Pricebook2> pbTest = Test_Environment_Utility.generatePricebooks(1, true);
        //List<Product2> prodList = Test_Environment_Utility.generateFGProducts(numToCreate, true);
        Product2 singleProduct = Test_Environment_Utility.createInsertProduct(false);
        singleProduct.Name = 'Earth Walk Test';
        insert singleProduct;
        
        Map<Id,Decimal> mapProductPrices = new Map<Id,Decimal>();
        //for(Product2 p : prodList) {
        //    mapProductPrices.put(p.Id, 2.22);
        //}
        mapProductPrices.put(singleProduct.Id, 2.22);
        List<PricebookEntry> pbeStandard = Test_Environment_Utility.generatePricebookEntries(mapProductPrices, Test.getStandardPricebookId(), true);
        List<PricebookEntry> pbeList = Test_Environment_Utility.generatePricebookEntries(mapProductPrices, pbTest[0].Id, true);
    
        //Need to make sure that the cc_rpice
        ccrz__E_PriceList__c ccPB = ([SELECT Id FROM ccrz__E_PriceList__c WHERE Price_Book__c IN :pbTest LIMIT 1]);
        system.debug(ccPB.Id);
        
        //Now that the PBEs are all created, run the batch job.  
        //Test.startTest();
            PricebookEntry_Batch batchClass = new PricebookEntry_Batch(); 
            Database.ExecuteBatch(batchClass, 10);
        //Test.stopTest();

        // Test Schedulable
        PricebookEntry_Batch clsBatch = new PricebookEntry_Batch();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test PBE Batch', sch, clsBatch);

        
    }
}