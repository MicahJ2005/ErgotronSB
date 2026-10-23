public with sharing class CPR_Log_Controller {
	public string CPid = ApexPages.currentPage().getParameters().get('CPid');

	public List<Custom_Product__c> lstcpr {
		get{
			if(CPid == '' || CPid == null){
				return [SELECT Id
							,Name
							,Date_Requested__c
							,Customer__r.Name
							,Prototype_Product_Part_Number__r.Name
							,Product_Specs__c
							,Reason_for_special_Product__c
							,TAM__c
							,Manufacturer__c
							,Minimum_Order_Quantity__c
							,MSRP__c
							,Image__c
						FROM Custom_Product__c
						WHERE Include_in_Rep_Document__c = true
						];
			}
			else{
				return [SELECT Id
							,Name
							,Date_Requested__c
							,Customer__r.Name
							,Prototype_Product_Part_Number__r.Name
							,Product_Specs__c
							,Reason_for_special_Product__c
							,TAM__c
							,Manufacturer__c
							,Minimum_Order_Quantity__c
							,MSRP__c
							,Image__c
						FROM Custom_Product__c
						WHERE Id =:CPid
						];
			}
		}
		set;
	}
}