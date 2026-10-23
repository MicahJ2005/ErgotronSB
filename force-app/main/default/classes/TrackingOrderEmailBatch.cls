/**
 * @description       : 
 * @author            : willh@demandchain.com
 * @group             : 
 * @last modified on  : 05-05-2021
 * @last modified by  : willh@demandchain.com
 * Modifications Log 
 * Ver   Date         Author                  Modification
 * 1.0   04-21-2021   willh@demandchain.com   Initial Version
 *       05-12-2021   sophiam@demandchain.com Fix issue with multiple emails going out multiple times
 * 		 05-25-2021   sophiam@demandchain.com Checking for empty email addresses before sending.
**/
global with sharing class TrackingOrderEmailBatch implements Database.Batchable<sObject>{
    public String query;
    //public Map<String, Document> documentMap;
    
    
    /**
    * @description 
    * @author willh@demandchain.com | 05-03-2021 
    **/
    global TrackingOrderEmailBatch() 
    {

        this.query = 'SELECT ID, Ship_To_Contact_Email__c, Ship_To_Contact__c FROM Sales_Order__c WHERE Queue__c = true AND Tracking_Order_Email_Sent__c = false';
        if(Test.isRunningTest())
        {
            this.query = 'SELECT ID, Ship_To_Contact_Email__c, Ship_To_Contact__c FROM Sales_Order__c WHERE Queue__c = true AND Tracking_Order_Email_Sent__c = false LIMIT 200' ;
        }
    }
    
    /**
    * @description 
    * @author willh@demandchain.com | 05-03-2021 
    * @param Database.BatchableContext bc 
    * @return Database.QueryLocator 
    **/
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator(query);
    }

    /**
    * @description 
    * @author willh@demandchain.com | 05-03-2021 
    * @param Database.BatchableContext BC 
    **/
    global void finish(Database.BatchableContext BC) 
    {

    }
    

    /**
    * @description 
    * @author willh@demandchain.com | 05-03-2021 
    * @param Database.BatchableContext BC 
    * @param List<Sobject> scope 
    **/
    global void execute(Database.BatchableContext BC, List<Sobject> scope) 
    {
        System.debug(scope);


        
        //Fetching Email template
        EmailTemplate templateId = [Select id from EmailTemplate where Name = 'CC ERG Order_Shipped' limit 1];
        system.debug('templateId:: '+templateId);
        OrgWideEmailAddress[] theOrgWideEmailList = [select Id from OrgWideEmailAddress where DisplayName  = 'Ergotron'];
        // string param1 ='<html>abcd</html>';       
        
        //List<string> EmailList = new List<String>();
        List<Messaging.SingleEmailMessage> listOfEmails = new List<Messaging.SingleEmailMessage>();
        List<Sales_Order__c> SalesOrderList = (List<Sales_Order__c>)scope;
        For (Sales_Order__c theSalesOrder : SalesOrderList) {
            
            List<string> tmpEmailList = new List<String>();
            if(theSalesOrder.Ship_To_Contact_Email__c != null && theSalesOrder.Ship_To_Contact_Email__c != '') {
                tmpEmailList.add(theSalesOrder.Ship_To_Contact_Email__c);
            }
            
            Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
            if ( theOrgWideEmailList.size() > 0 ) {
                singleEmail.setOrgWideEmailAddressId(theOrgWideEmailList.get(0).Id);
            }
            singleEmail.setTemplateID(templateId.Id);
            singleEmail.setToaddresses(tmpEmailList);
            singleEmail.setTargetObjectId(theSalesOrder.Ship_To_Contact__c);
            singleEmail.setWhatId(theSalesOrder.ID);
            
            system.debug('Mails'+singleEmail); 
            if(tmpEmailList.size() > 0) {
                listOfEmails.add(singleEmail);
            	theSalesOrder.Tracking_Order_Email_Sent__c = true;
            }
        }
        
        Messaging.sendEmail(listOfEmails); 
        update SalesOrderList;


    }


}