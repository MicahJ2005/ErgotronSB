/*
    Test class for the Price_Book trigger

    MOD DATE        Who                     
    01/20/2020      Sophia Murphy (Demand Chain)
					Initial Creation 
*/
@IsTest
private class Price_Book_Test {

    static testmethod void testOne() {
        Integer numToCreate = 30;
        
        //We need a cc_acct_group created...
        ccrz__E_AccountGroup__c cAG = new ccrz__E_AccountGroup__c ();
        cAG.Name = 'Replacement Parts';
        insert cAG;
        
        //The flow can't handle 200 records, it can handle 100 - but then when I query again, it's 101; opted to test with 50
        List<Pricebook2> pbTest = Test_Environment_Utility.generatePricebooks(numToCreate, true);
        //the autolaunched flow creates a ccrz__E_PriceList__c record related to the Pricebook 
        List<ccrz__E_PriceList__c> ccList = new List< ccrz__E_PriceList__c >([SELECT Id FROM ccrz__E_PriceList__c WHERE Price_Book__c IN :pbTest]);
        system.assertEquals(numToCreate, ccList.size());
    }
}