/**
 * Schedulable job to look for orders that have been marked as Delivered
 * 
    DeliveredOrderEmailBatch batchClass = new DeliveredOrderEmailBatch(); 
    Database.ExecuteBatch(batchClass, 200);
 * 
 * Modifications Log 
 * Ver   Date         Author                  Modification
 * 1.0   10.13.2022   sophiam@demandchain.com Initial Version
 *       01.11.2023   sophiam@demandchain.com Updates to not look at OLD deliveries and ensure a tracking number is present.
 *       01.13.2023   sophiam@demandchain.com Added in overrides for TO addr; and BCC option from custom metadata
 *      01.30.2023    esau.sanchez@ergotron.com Added conditions to the shipment query to only do orders with 1 line and quanty 1.
 *                      and actual delivery date is = today (to prevent late emails due to tracking stage inconsitencies).
**/
global with sharing class DeliveredOrderEmailBatch implements Database.Batchable<sObject>{
    public String query;
    
    global DeliveredOrderEmailBatch() 
    {

        this.query = 'SELECT Id, Order__c, Sales_Order__c FROM zkmulti__MCShipment__c WHERE Sales_Order__c != null AND Delivered_Email_Sent__c = false AND zkmulti__Tracking_Stage__c = \'Delivered\'';
        this.query += ' AND Order_Tracking_Number__r.Tracking_Number__c != null ';
        this.query += ' AND zkmulti__Ship_Date__c > 2022-12-01 ';
        this.query += ' AND zkmulti__Actual_Delivery_Date__c = TODAY AND Sales_Order__r.Line_Count__c = 1 AND Sales_Order__r.Total_Quantity__c = 1';
        if(Test.isRunningTest())
        {
            this.query += ' LIMIT 200' ;
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator(query);
    }

    global void finish(Database.BatchableContext BC) 
    {

    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope) 
    {
        System.debug('DC: scope: ' + scope);
        //Fetching Email template
        //EmailTemplate templateId = [Select id from EmailTemplate where Name = 'SalesOrderDelivered' limit 1];
        //system.debug('DC: templateId:: '+templateId);
        OrgWideEmailAddress[] theOrgWideEmailList = [select Id from OrgWideEmailAddress where DisplayName  = 'Ergotron'];
        
        List<Messaging.SingleEmailMessage> listOfEmails = new List<Messaging.SingleEmailMessage>();

        //the scope gives us a list of zkmulti__MCShipment__c records; but there could be multiple of those for a single order
        // We want to send the email based on the Sales Order (not the shipment) - all shipments related to the same Sales Order will be in the email
        Set<Id> salesOrderIds = new Set<Id>();
        Map<Id, Id> shipmentIdToSOId = new Map<Id, Id>();
        for(zkmulti__MCShipment__c shipment : (List<zkmulti__MCShipment__c>)scope) {
            salesOrderIds.add(shipment.Sales_Order__c);
            shipmentIdToSOId.put(shipment.Id, shipment.Sales_Order__c);
        }

        //Check our custom metadata
        General_Ergotron_Setting__mdt defaultOverrides = [SELECT DeveloperName
                                                            , Delivered_Order_Email_BCC_Addr__c
                                                            , Delivered_Order_Email_Bypass_Recipient__c
                                                            , Delivered_Order_Email_Override_To_Addr__c
                                                            , Delivered_Order_Email_Override_Cnt_Id__c
                                                            , Delivered_Order_Email_Template_Id__c
                                                        FROM General_Ergotron_Setting__mdt 
                                                        WHERE DeveloperName = 'Default' LIMIT 1];

        system.debug('DC: defaultOverrides: ' + defaultOverrides);
        List<String> bccEmailList = new List<String>();
        List<String> overrideToEmailList = new List<String>();
        Boolean doOverrideTo = false;
        String overrideContactId = '';
        String emailTemplate = '';

        if(defaultOverrides != null) {
            if(defaultOverrides.Delivered_Order_Email_BCC_Addr__c != null) {
                bccEmailList = defaultOverrides.Delivered_Order_Email_BCC_Addr__c.split(';');
            }
            if(defaultOverrides.Delivered_Order_Email_Bypass_Recipient__c == true) {
                doOverrideTo = true;
                if(defaultOverrides.Delivered_Order_Email_Override_To_Addr__c != null) {
                    overrideToEmailList = defaultOverrides.Delivered_Order_Email_Override_To_Addr__c.split(';');
                }
            }
            if(defaultOverrides.Delivered_Order_Email_Override_Cnt_Id__c != null) {
                overrideContactId = defaultOverrides.Delivered_Order_Email_Override_Cnt_Id__c;
            }
            emailTemplate = defaultOverrides.Delivered_Order_Email_Template_Id__c;
        }

        system.debug('DC: bccEmailList: ' + bccEmailList);
        system.debug('DC: overrideToEmailList: ' + overrideToEmailList);
        system.debug('DC: doOverrideTo: ' + doOverrideTo);

        Set<Id> salesOrdersSent = new Set<Id>();
        List<Sales_Order__c> SalesOrderList = new List<Sales_Order__c>([SELECT Id, Ship_To_Contact_Email__c, Ship_To_Contact__c FROM Sales_Order__c WHERE Id IN :salesOrderIds]);
        System.debug('DC: SalesOrderList: ' + SalesOrderList);
        for (Sales_Order__c theSalesOrder : SalesOrderList) {
            
            List<string> tmpEmailList = new List<String>();
            if(theSalesOrder.Ship_To_Contact_Email__c != null && theSalesOrder.Ship_To_Contact_Email__c != '') {
                tmpEmailList.add(theSalesOrder.Ship_To_Contact_Email__c);
            }
            
            Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
            if ( theOrgWideEmailList.size() > 0 ) {
                singleEmail.setOrgWideEmailAddressId(theOrgWideEmailList.get(0).Id);
            }
            //singleEmail.setTemplateID(templateId.Id);
            singleEmail.setTemplateID(emailTemplate);
            if(doOverrideTo) {
                singleEmail.setToaddresses(overrideToEmailList);
                singleEmail.setTargetObjectId(overrideContactId);
            } else {
                singleEmail.setToaddresses(tmpEmailList);
                singleEmail.setTargetObjectId(theSalesOrder.Ship_To_Contact__c);
            }
            
            if(bccEmailList.size() > 0) {
                singleEmail.setBccAddresses(bccEmailList);
            }
            singleEmail.setWhatId(theSalesOrder.ID);
            
            system.debug('DC: singleEmail: ' + singleEmail); 
            salesOrdersSent.add(theSalesOrder.Id);
            listOfEmails.add(singleEmail);
        }

        //Ok - so we know all the sales orders we sent off - now we need to mark off the matching shipments as "emails sent"
        List<zkmulti__MCShipment__c> updateShipments =  new List<zkmulti__MCShipment__c>();
        for(Id shipmentId : shipmentIdToSOId.keySet()) {
            Id soId = shipmentIdToSOId.get(shipmentId);
            if(soId != null && salesOrdersSent.contains(soId)) {
                zkmulti__MCShipment__c tmpShipment = new zkmulti__MCShipment__c(Id = shipmentId);
                tmpShipment.Delivered_Email_Sent__c = true;
                updateShipments.add(tmpShipment);
            }
        }
        system.debug('DC: listOfEmails: ' + listOfEmails); 
        system.debug('DC: updateShipments: ' + updateShipments); 
        if(listOfEmails.size() > 0) {
            Messaging.sendEmail(listOfEmails); 
            if(updateShipments.size() > 0) {
                update updateShipments;
            }
        }
    }
}