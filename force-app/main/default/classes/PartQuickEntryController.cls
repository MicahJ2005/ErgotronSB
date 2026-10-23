/*
PartQuickEntryController : This apex class retrieves/updates data from/to Salesforce database from partquickentry LWC
*/

public with sharing class PartQuickEntryController 
{
    @AuraEnabled
    public static List<Part> getParts(Id workOrderId) 
    {
        List<Part> parts = new List<Part>();

        List<ProductConsumed> products = 
        [
            SELECT Id, WorkOrderId, Description, Critical_Part__c, Source__c, Status__c, RMA_Item_Status__c, NewSerialNumber__c, OldSerialNumber__c, Product2Id, Product2.Name,  Product2.ProductCode, Product2.Critical_Part__c,
                    PricebookEntryId, Observation__c, Tracking_Number__c, RMA_Return_Tracking__c, SRO__c, Product2.IsSerialized
            FROM ProductConsumed
            WHERE WorkOrderId = :workOrderId
            ORDER BY CreatedDate ASC
        ];

        for(ProductConsumed pc : products) {
            Part woPart = new Part();
            woPart.partId = pc.Id;
            woPart.workOrderId = pc.WorkOrderId;
            woPart.priceBookEntryId = pc.PricebookEntryId;
            woPart.productId = pc.Product2Id;
            woPart.sroNumber = pc.SRO__c;
            woPart.trackingNumber = pc.Tracking_Number__c;
            woPart.rmaTrackingNumber = pc.RMA_Return_Tracking__c;
            woPart.observation = pc.Observation__c;            
            woPart.criticalPart = pc.Critical_Part__c;
            woPart.source = pc.Source__c;
            woPart.status = pc.Status__c;
            woPart.rmaItemStatus = pc.RMA_Item_Status__c;
            woPart.newSerialNumber = pc.NewSerialNumber__c;
            woPart.oldSerialNumber = pc.OldSerialNumber__c;
            woPart.productName = pc.Product2.Name;
            woPart.productCode = pc.Product2.ProductCode;
            woPart.serialized = pc.Product2.IsSerialized;
            parts.add(woPart);
            system.debug(woPart.partId+ ' -- '+woPart.serialized);
        }

        return parts;
    }

    @AuraEnabled
    public static Part getPartShell(Id workOrderId) 
    {
        WorkOrder wo = [SELECT Case.Plex_Order_Number__c, Case.Tracking_Number_s__c FROM WorkOrder WHERE Id = :workOrderId LIMIT 1];

        Part partShell = new Part();
        //partShell.partId = pc.Id;
        partShell.workOrderId = workOrderId;
        partShell.description = null;    
        partShell.sroNumber = wo.Case.Plex_Order_Number__c;
        partShell.trackingNumber = wo.Case.Tracking_Number_s__c;
        partShell.rmaTrackingNumber = '';
        partShell.observation = null;
        partShell.criticalPart = null;
        partShell.source = null;
        partShell.status = null;
        partShell.newSerialNumber = '';
        partShell.oldSerialNumber = '';
        partShell.productName = null;
        partShell.productCode = null;
        partShell.priceBookEntryId = null;
        partShell.productId = null;
        partShell.serialized=false;

        return partShell;
    }

    @AuraEnabled
    public static List<WorkType> getAllWorkTypes(){
        try {
            List<WorkType> workTypes = [SELECT Id, Name FROM WorkType];    
            return workTypes;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<ProductRequired> getRequiredPartsFromTemplate(Id workTypeId){
        try {
            List<ProductRequired> productsRequired = [SELECT Id, Product2Id FROM ProductRequired WHERE ParentRecordId = :workTypeId];    
            return productsRequired;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /*
    getAllStandardPBE method retrieves all the products assigned to the pricebook to show prodcuts in parts section on WO, id of the pricebook is mentioned in the custom label.
    */
    @AuraEnabled
    public static List<PriceBookEntry> getAllStandardPBE() 
    {
        Id priceBookID = System.Label.PriceBookIdForWO;
        List<PriceBookEntry> pbes = 
        [
            SELECT Id,Product2Id, Product2.Name, Product2.Critical_Part__c, Product2.Observation__c, ProductCode, Description__c, Product2.IsSerialized
            FROM PriceBookEntry
            WHERE IsActive = True AND Product2.IsActive = True AND Pricebook2Id= :priceBookID
            //WITH SECURITY_ENFORCED
            ORDER BY Product2.Name
        ];
        return pbes;
    }
    

    @AuraEnabled
    public static void syncParts(List<Map<Object,String>> toupsert, List<Map<Object,String>> todelete)
    {
        System.Debug('syncProducts');
        System.debug('toupsert--->'+toupsert);
        System.debug('todelete--->'+todelete);

        List<ProductConsumed> delIDs = new List<ProductConsumed>();
        for(Map<Object,String> m : todelete)
        {
            String strID = m.get('partId');
            if(strID.left(1)=='-')
                continue;
            delIDs.add(new ProductConsumed(Id=strID));
        }

        List<ProductConsumed> prods = new List<ProductConsumed>();
        for(Map<Object,String> m : toupsert)
        {
            String strID = m.get('partId');
            Id recordID = null;
            if(strID.left(1)!='-')
                recordID = strID;

            ProductConsumed prod = new ProductConsumed(Id=recordID,
                WorkOrderId=m.get('workOrderId'), 
                QuantityConsumed=1,   
                SRO__c = m.get('sroNumber'), 
                Tracking_Number__c = m.get('trackingNumber'),
                RMA_Return_Tracking__c = m.get('rmaTrackingNumber'),
                RMA_Item_Status__c = m.get('rmaItemStatus'),
                PricebookEntryId=m.get('priceBookEntryId'),
                Observation__c=m.get('observation'), 
                Critical_Part__c=m.get('criticalPart'), 
                Source__c=m.get('source'), 
                Status__c=m.get('status'), 
                NewSerialNumber__c=m.get('newSerialNumber'), 
                OldSerialNumber__c=m.get('oldSerialNumber'));
            
            prods.add(prod);
        }
        
        try 
        {
            /*
            Database.delete(delIDs, true);
            Database.upsert(prods, true);
            */

            delete delIDs;
            upsert prods;
        } 
        catch (Exception e) 
        {
            System.Debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
}