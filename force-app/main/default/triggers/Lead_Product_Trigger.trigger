/*
	Trigger for Lead_Product__c object.
	+ Before Insert/Update Logic - Set the currency value on the Lead_Product__c record to match the associated Lead currency value.

	+ After Insert/Update Logic - Aggregate and rollup MSRP values to the associated Lead record.  This logic is performed via a trigger because the Lead object cannot be the master
	object in a Master/Detail relationship (as of Spring 2015 release) so we cannot use rollup summary values from the Lead_Product__c object.  Also, because multi-currency is enabled,
	we have to retrieve the conversion values and apply them to the rollup fields because aggregate functions such as SUM always aggregate currency values using the corporate currency
	and not the currency assigned to the record (as of Spring 2015 release).

	+ After Delete Logic - Handles rollup calculations when Lead_Product__c records are deleted.
	
	MOD DATE		Who						Description
	02/04/2015		Chris Noe				Initial Release
*/

trigger Lead_Product_Trigger on Lead_Product__c (before insert, before update, after insert, after update, after delete) {
	
	//BEGIN: Before Insert/Update Logic - Set the currency value on the Lead_Product__c record to match the associated Lead currency value.
	if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)) {
		//Trigger variables
		Set<Id> setLeadIds = new Set<Id>();
		Map<Id,String> mapLeadCurrencyValues = new Map<Id,String>();

		//Build a set of Lead ids based on the Lead_Product__c records in this trigger.
		for(Lead_Product__c oLeadProduct :trigger.new){
			setLeadIds.add(oLeadProduct.Lead__c);
		}

		//Get currency values for all Leads and add to map
		for(Lead oLead :[select Id, CurrencyIsoCode from Lead where Id in :setLeadIds]) {
			mapLeadCurrencyValues.put(oLead.Id,oLead.CurrencyIsoCode);
		}

		//Loop through Lead_Product__c records and set Currency value based on parent Lead__c currency value.
		for(Lead_Product__c oLeadProduct :trigger.new){
			oLeadProduct.CurrencyIsoCode=mapLeadCurrencyValues.get(oLeadProduct.Lead__c);
		}
	}
	//END: Before Insert/Update Logic - Set the currency value on the Lead_Product__c record to match the associated Lead currency value.

	//BEGIN: After Insert/Update Logic - Aggregate and rollup MSRP values to the associated Lead record.  This logic is performed via a trigger because the Lead object cannot be the master
	//object in a Master/Detail relationship (as of Spring 2015 release) so we cannot use rollup summary values from the Lead_Product__c object.
	if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
		//Trigger variables
		List<Lead> listLeadUpdate = new List<Lead>();
		Set<Id> setLeadIds = new Set<Id>();

		//Get all Lead__c Id's for aggregate query
		for(Lead_Product__c oLeadProduct :trigger.new){
			setLeadIds.add(oLeadProduct.Lead__c);
		}

		//Perform aggregate query and set Lead rollup field values based on aggregate results and conversion rates
		for(AggregateResult oAR : [SELECT Lead__c, Sum(Total_MSRP__c) lre0, Sum(Quantity__c) lre1 FROM Lead_Product__c WHERE Lead__c in :setLeadIds GROUP BY Lead__c]){
			Lead oLead = new Lead();
			oLead.Id=(id)oAR.get('Lead__c');
			oLead.Total_MSRP_Rollup__c=(Decimal)oAR.get('lre0');
			oLead.Total_Quantity__c=(Decimal)oAR.get('lre1');

			listLeadUpdate.add(oLead);
		}

		if(!listLeadUpdate.isEmpty()) {
			update listLeadUpdate;
		}
	}
	//END: After Insert/Update Logic - Aggregate and rollup MSRP values to the associated Lead record.  This logic is performed via a trigger because the Lead object cannot be the master
	//object in a Master/Detail relationship (as of Spring 2015 release) so we cannot use rollup summary values from the Lead_Product__c object.

	//BEGIN: After Delete Logic - Handles rollup calculations when Lead_Product__c records are deleted.
	if(trigger.isAfter && trigger.isDelete) {
		//Trigger variables
		List<Lead> listLeadUpdateZero = new List<Lead>();
		List<Lead> listLeadUpdate = new List<Lead>();
		Set<Id> setLeadIds = new Set<Id>();

		//Get all Lead__c Id's for aggregate query
		for(Lead_Product__c oLeadProduct :trigger.old){
			setLeadIds.add(oLeadProduct.Lead__c);
		}

		//Set all rollup values to 0 for the Leads retrieved above.  This is required in case there are no longer any Lead_Product__c records associated with the Lead.  If there
		//are still Lead_Product__c records then their associated Leads will get updated in the logic that follows.
		for(Lead oLead :[select Id from Lead where Id in :setLeadIds]){
			Lead oLeadUpdate = new Lead();
			oLeadUpdate.Id=oLead.Id;
			oLeadUpdate.Total_MSRP_Rollup__c=0;
			oLeadUpdate.Total_Quantity__c=0;

			listLeadUpdateZero.add(oLeadUpdate);
		}

		if(!listLeadUpdateZero.isEmpty()){
			update listLeadUpdateZero;
		}

		//Reset aggregate rollup values for Leads that still have Lead_Product__c values associated with them.
		for(AggregateResult oAR : [SELECT Lead__c, Sum(Total_MSRP__c) lre0, Sum(Quantity__c) lre1 FROM Lead_Product__c WHERE Lead__c in :setLeadIds GROUP BY Lead__c]){
			Lead oLead = new Lead();
			oLead.Id=(id)oAR.get('Lead__c');
			oLead.Total_MSRP_Rollup__c=(Decimal)oAR.get('lre0');
			oLead.Total_Quantity__c=(Decimal)oAR.get('lre1');

			listLeadUpdate.add(oLead);
		}

		if(!listLeadUpdate.isEmpty()) {
			update listLeadUpdate;
		}		
	}
	//END: After Delete Logic - Handles rollup calculations when Lead_Product__c records are deleted.
}