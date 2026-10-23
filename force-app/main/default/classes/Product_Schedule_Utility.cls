/*
    Utility for the Product_Schedule__c trigger

    MOD DATE        Who                         Description
    08/20/2019      Sophia Murphy (Dem.Chain)   Initially created as a replacement for a failing process builder and flow
                                                Case #214868
	08/30/2019		Esau Sanchez (Ergotron)		Added exception based on Opportunity__r.Lock_Expected_Close_Date
*/
public with sharing class Product_Schedule_Utility {

    //Given the opportunity ID - query for the MIN scheduled_Date__c in the product schedule records 
    public static void setOppCloseDate(List<Product_Schedule__c> listPS) {

        Set<Id> oppIds = new Set<Id>();
        for(Product_Schedule__c ps : [SELECT id, opportunity__r.Lock_Expected_Close_Date__c from Product_Schedule__c where id IN :listPS]  ) {
            if(!ps.Opportunity__r.Lock_Expected_Close_Date__c){
                oppIds.add(ps.Opportunity__c);
            }
            
        } 

        System.debug('DC: oppIds: ' + oppIds);

        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for(AggregateResult ar : [SELECT MIN(Scheduled_Date__c) sDate, Opportunity__c FROM Product_Schedule__c 
                                    WHERE Opportunity__c IN :oppIds 
                                    AND Opportunity__r.RecordType.Name = 'Sales Development'
                                    GROUP BY Opportunity__c]) {
            Date sDate = (Date)ar.get('sDate');
            System.debug('DC: sDate: ' + sDate);

            Id oppId = (Id)ar.get('Opportunity__c');

            Opportunity tmpOpp = new Opportunity(Id = oppId);
            tmpOpp.CloseDate = sDate;

            oppsToUpdate.add(tmpOpp);
        }

        if(oppsToUpdate.size() > 0) {
            update oppsToUpdate;
        }
    }
}