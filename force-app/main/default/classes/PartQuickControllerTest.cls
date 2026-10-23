@isTest
public class PartQuickControllerTest {
    @testSetup
    static void setup() {
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(), IsActive = true);

        update standardPricebook;
        Product2 newProd = new Product2(Name = 'test product', family = 'test family');
        insert newProd;

        PricebookEntry pbe = [
            SELECT ID
            FROM PriceBookEntry
            WHERE Product2Id = :newProd.Id AND IsActive = TRUE AND PriceBook2Id = :Test.getStandardPricebookId() AND CurrencyIsoCode = :'USD'
            LIMIT 1
        ];

        WorkOrder wo = new WorkOrder(
            Subject = 'Test',
            Work_Order_Type__c = 'Standard',
            Status = 'New',
            Issue_as_Stated_by_Customer__c = 'Power failure',
            CurrencyIsoCode = 'USD',
            PriceBook2Id = Test.getStandardPricebookId()
        );
        insert wo;
        ProductConsumed pc = new ProductConsumed(
            PricebookEntryId = pbe.Id,
            QuantityConsumed = 15,
            SRO__c = 'P1',
            Tracking_Number__c = 'T1',
            WorkOrderId = wo.Id,
            Observation__c = 'Power issue',
            Critical_Part__c = 'Power System',
            Source__c = 'SRO',
            NewSerialNumber__c = '1234',
            OldSerialNumber__c = '5678',
            Status__c = 'Used for Repair'
        );
        insert pc;
        ProductConsumed pc2 = new ProductConsumed(
            SRO__c = 'P2',
            Tracking_Number__c = 'T1',
            WorkOrderId = wo.Id,
            PricebookEntryId = pbe.Id,
            QuantityConsumed = 15
        );
        insert pc2;

        WorkType wt = new WorkType(Name = 'Test', EstimatedDuration = 3, DurationType = 'Hours', Level__c = '2');
        insert wt;

        //array to upsert recors
        //array to delete records
        //call sync method to pass upsert and delete*/
    }

    public static testMethod void testGetParts() {
        List<WorkOrder> w1 = [SELECT Id FROM WorkOrder WHERE Subject = 'Test'];
        List<Part> parts = PartQuickEntryController.getParts(w1[0].Id);
        system.assertEquals('P1', Parts[0].sroNumber);
    }
    public static testMethod void testGetPartsShell() {
        List<WorkOrder> w1 = [SELECT Id FROM WorkOrder WHERE Subject = 'Test'];
        Part parts = PartQuickEntryController.getPartShell(w1[0].Id);
        System.assertEquals(w1[0].Id, Parts.workOrderId);
    }
    public static testMethod void testgetAllStandardPBE() {
        List<Pricebook2> pb2 = [SELECT Id FROM Pricebook2 WHERE IsStandard = TRUE];
        //List<PriceBookEntry>pbe = [SELECT Id, Pricebook2.IsStandard FROM PricebookEntry];

        List<PriceBookEntry> pbes = PartQuickEntryController.getAllStandardPBE();
        List<PriceBookEntry> pbes2 = [
            SELECT Pricebook2Id, Pricebook2.IsStandard
            FROM PriceBookEntry
        ];
        system.assertEquals(pb2[0].Id, pbes2[0].Pricebook2Id);
    }
    public static testMethod void testgetAllWorkTypes() {
        List<WorkType> workTypes = PartQuickEntryController.getAllWorkTypes();
        system.assertEquals('Test', workTypes[0].Name);
        /* workTypes[0].id = null;
List<WorkType> workTypess = [Select id from Worktype where id =: workTypes[0].id];
Test.startTest();

PartQuickEntryController.getAllWorkTypes();
Test.stopTest();*/
    }
    public static testMethod List<ProductRequired> getRequiredPartsFromTemplate() {
        List<WorkType> workTypes = PartQuickEntryController.getAllWorkTypes();
        List<ProductRequired> productsRequired = [
            SELECT Id, Product2Id
            FROM ProductRequired
            WHERE ParentRecordId = :workTypes[0].id
        ];
        return productsRequired;
    }
    public static testMethod void testTemplate() {
        List<WorkType> workTypes = PartQuickEntryController.getAllWorkTypes();
        PartQuickEntryController.getRequiredPartsFromTemplate(workTypes[0].id);
    }
    public static testMethod void testsyncParts() {
        List<ProductConsumed> UpsertArray = [
            SELECT id, priceBookEntryId, Product2Id
            FROM ProductConsumed
            WHERE SRO__c = 'P1'
        ];
        List<ProductConsumed> DelArray = [
            SELECT id
            FROM ProductConsumed
            WHERE SRO__c = 'P2'
        ];

        List<Map<Object, String>> a = new List<Map<Object, String>>();

        Map<Object, String> upsertMap = new Map<Object, String>();
        upsertMap.put('partId', UpsertArray[0].id);
        upsertMap.put('priceBookEntryId', UpsertArray[0].priceBookEntryId);
        a.add(upsertMap);

        List<Map<Object, String>> a1 = new List<Map<Object, String>>();
        a1.add(new Map<Object, String>{ 'partId' => DelArray[0].id });
        PartQuickEntryController.syncParts(a, a1);
    }
}