/**
*   {Purpose}  –  This class performs various actions against the opportunity object
*                
*   {Function}  – 
*                 
*   {Support}   - For assistance with this code, please contact support@demandchainsystems.com             
*                 www.demandchainsystems.com
*                 (952) 345-4533
*
*
*   CHANGE  HISTORY
*   =============================================================================
*   Date   	  Name             Description
*   20170307  EBG DCS          Created
*   =============================================================================
*/ 

public with sharing class ServiceContractProductSearchController {  
   
   //public list<Service_Contract_Product__c> lstScp {get;set;}
   //public list<Installed_Product__c> lstIp {get;set;}
   //public id customerId {get;set;}
   //public id scId {get;set;}
   //public id ipId {get;set;}
   //public boolean ShowAddToContract {get;set;}
   //public string searchstring {get;set;} 
    
   //public ServiceContractProductSearchController(ApexPages.StandardController controller) {  
   	   //ShowAddToContract = false;
       //customerId = ApexPages.currentPage().getParameters().get('customerId');
       //scId = ApexPages.currentPage().getParameters().get('id');
   //}  

    //public void search(){
        //lstIp=new list<Installed_Product__c>([Select id
                                            		//,Name
                                             		//,Customer_Name__c
                                              		//,Part_Number__c
                                              		//,Oracle_Item_Status_Indicator__c
                                              		//,Product__c
                                              		//,Shipped_Date__c
                                              		//,Shipped_To_Location__c
                                              		//,Oracle_Order_Number__c
                                              		//,(select Id
                                                       	   	  //,Service_Contract__r.Name
                                                	       	  //,Service_Contract__r.Customer_Name__c
                                                     		  //,Service_Contract__r.Customer_Number__c
                                                     		  //,Service_Contract__r.Part_Number__c
                                                    		  //,Service_Contract__r.Sales_Order__c
                                                 	      	  //,Service_Contract__r.Contract_Status_Indicator__c
                                                 	      	  //,Service_Contract__r.Start_Date__c
                                                  	    	  //,Service_Contract__r.End_Date__c
                                                       //from Service_Products__r)
                                            //from Installed_Product__c
                                            //where Name = :searchstring.trim()]);
        
       //for(Installed_Product__c oIp:lstIp){
           //ShowAddToContract = true;
           //ipId = oIp.Id;
           //If(oIp.Service_Products__r.size()>0){
               //lstScp = oIp.Service_Products__r;
               //for(Service_Contract_Product__c oScp:oIp.Service_Products__r){
                   //If(oScp.Service_Contract__r.Customer_Name__c != customerId
                            //|| oScp.Service_Contract__c == scId){
                        //ShowAddToContract = false;
                        //ipId = null;
                        //break;
                   //}                   
               //}
           //}
           //If(ShowAddToContract == false){
               //break;
           //}
       //}
        //if(lstIp.size()>1){
            //ShowAddToContract = False;
        //}
    //} 
///*******************************************
 //* 
 //******************************************/
    //public void saveScpRecord(){
    	//Service_Contract_Product__c oSc = new Service_Contract_Product__c();
        //oSc.Installed_Product__c = ipId;
        //oSc.Service_Contract__c = scId;
        //insert oSc;
        //search();
    //}
 }