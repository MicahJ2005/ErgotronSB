@isTest
/*
  Test class for the Opp_Demand_Input_Approval_Controller. 

  MOD DATE      Who                 Description
  07/14/2017    Kelly Lafferty      Initial Release
*/
private class Opp_Demand_Input_Approval_Test {
    
    @isTest static void Opportunity_test() {
        //declare variables

        Account testaccount = Test_Environment_Utility.CreateInsertAccountUS();

        Opportunity opp = Test_Environment_Utility.CreateInsertOpportunity('Ergotron Forecast Opportunity',testAccount, 'Prospecting', system.today());

        Id pbId = Test.getStandardPricebookId();

        Product2 prod = new Product2 ();
            prod.name = 'test product';
            prod.ProductCode = '123';
            prod.IsActive = True;
            prod.CanUseQuantitySchedule = True;
            insert prod;

        PricebookEntry pbe = new PricebookEntry();
            pbe.Product2Id = prod.Id;
            pbe.Pricebook2Id = pbId;
            pbe.UnitPrice = 5.00;
            pbe.IsActive = True;
            insert pbe;

        OpportunityLineItem oli = new OpportunityLineItem ();
            oli.OpportunityId = opp.Id;
            oli.PricebookEntryId = pbe.Id;
            oli.Quantity = 10;
            oli.Rebate_Amount__c = 10.00;
            oli.UnitPrice = 44.00;
            oli.Estimated_Distribution_Margin__c = 10.00;
            oli.Estimated_Reseller_Margin__c = 4.00;
            insert oli;

        Product_Schedule__c ps = new Product_Schedule__c ();
            ps.Item_Description__c = prod.Id;
            ps.Opportunity__c = opp.id;
            ps.Scheduled_Date__c = Date.today();
            ps.Scheduled_Quantity__c = 5;
            ps.Scheduled_Revenue__c = 1.00;
            ps.Name = prod.name;
            ps.Opportunity_Line_Item_Schedule_Id__c = '1';
            ps.Opportunity_Line_Item_Id__c = '1';
            insert ps;

        ps = new Product_Schedule__c ();
            ps.Item_Description__c = prod.Id;
            ps.Opportunity__c = opp.id;
            ps.Scheduled_Date__c = Date.today()+1;
            ps.Scheduled_Quantity__c = 5;
            ps.Scheduled_Revenue__c = 1.00;
            ps.Name = prod.name;
            ps.Opportunity_Line_Item_Schedule_Id__c = '2';
            ps.Opportunity_Line_Item_Id__c = '1';
            insert ps;

        Opp_Demand_Input_Approval_Controller DemandInput = new Opp_Demand_Input_Approval_Controller ();
        DemandInput.OppId = opp.Id;
        List<string> LstProductNames = DemandInput.getLstProductNames ();
    }   
}