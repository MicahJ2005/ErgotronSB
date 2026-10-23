// This class respresent Parts which are shown on the LWC component to add part details on Work Order.
public with sharing class Part {

    @AuraEnabled
    public boolean deleted;
    @AuraEnabled
    public Id partId;
    @AuraEnabled
    public Id workOrderId;
    @AuraEnabled
    public Id priceBookEntryId;    
    @AuraEnabled
    public Id productId;
    @AuraEnabled
    public String sroNumber;
    @AuraEnabled
    public String trackingNumber;
    @AuraEnabled
    public String rmaTrackingNumber;
    @AuraEnabled
    public String observation;
    @AuraEnabled
    public String criticalPart;
    @AuraEnabled
    public String source;
    @AuraEnabled
    public String status;
    @AuraEnabled
    public String rmaItemStatus;
    @AuraEnabled
    public String newSerialNumber;
    @AuraEnabled
    public String oldSerialNumber;    
    @AuraEnabled
    public String productName;
    @AuraEnabled
    public String productCode;    
    @AuraEnabled
    public String description;
    @AuraEnabled
    public boolean serialized;
    //@AuraEnabled
    //public String bgColor;
}