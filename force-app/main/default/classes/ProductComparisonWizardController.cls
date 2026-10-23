public with sharing class ProductComparisonWizardController {
/**
*   {Purpose}  �  TODO:  Provide Purpose
*
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 612-424-0032
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date    	Name             		Description
*   20150922  	Andy Boettcher DCS		Created
*	20151009	Andy Boettcher DCS 		Modified the mapComparison to fill lstObjectFieldsDisplay
*										to not show fields with no comparable values
*   =============================================================================
*/
	public Map<Id, Ergotron_Product_Comparison__c> mapProducts {get;set;}
	public Ergotron_Product_Comparison__c objSearch {get;set;}
	public Ergotron_Product_Comparison__c objOrigin {get;set;}
	public List<String> lstObjectFieldsDisplay {get;set;}
	public Id idTarget {get;set;}
	public Set<Id> setProductIds {get;set;}
	public Boolean bolShowAutoAdd {get;set;}
	public Set<String> setBlockedFields;

	public List<Ergotron_Product_Comparison__c> lstResults {get; private set;}
	public List<String> lstObjectFields {get; private set;}
	public Map<Id, Ergotron_Product_Comparison__c> mapComparison {get; private set;}

	///////////////////////////
	// Constructors
	///////////////////////////
	public ProductComparisonWizardController() {
		objSearch = new Ergotron_Product_Comparison__c();
		mapProducts = new Map<Id, Ergotron_Product_Comparison__c>();
		lstResults = new List<Ergotron_Product_Comparison__c>();
		bolShowAutoAdd = false;

		setBlockedFields = UtilityMethods.setAuditFields;
		setBlockedFields.add('COMPARISONSORT__C');
		setBlockedFields.add('ISAVAILABLEFORSEARCH__C');

		if(!String.isEmpty(ApexPages.currentPage().getParameters().get('id'))){
			bolShowAutoAdd = true;
			idTarget = ApexPages.currentPage().getParameters().get('id');
			objOrigin =
				[Select
					Id
					,Name
					,RecordTypeId
					,Company__c
					,Manufacturers_Part_Number__c
					,RecordType.Name
					,Last_Revised__c
				 From
				 	Ergotron_Product_Comparison__c Where Id = :idTarget];
			mapProducts.put(objOrigin.Id,objOrigin);
			populateListOfObjectFields();
		}
	}

	///////////////////////////
	// GET / SET
	///////////////////////////
	public Boolean bolErrorMaxAdd {
		get {
			return mapProducts.size() >= 6;
		}
	}

	public PageReference searchListResults(){
		Set<Id> setExcludedIds = mapProducts.keySet();
		String strQuery =
			'Select ' +
				'Id' +
				',Company__c' +
				',Name' +
				',Manufacturers_Part_Number__c' +
				',RecordType.Name' +
				',Last_Revised__c ' +
			'From ' +
				'Ergotron_Product_Comparison__c ' +
			'Where ' +
				'IsAvailableForSearch__c = true ' +
				'And Id Not in :setExcludedIds ';

		for(Schema.FieldSetMember fsm : SObjectType.Ergotron_Product_Comparison__c.FieldSets.CompareWizardSearch.getFields()) {
			if(objSearch.get(fsm.getFieldPath()) != null) {
				strQuery += 'And ' + fsm.getFieldPath() + ' Like \'%' + objSearch.get(fsm.getFieldPath()) + '%\' ';
			}
		}

		strQuery += 'Order By Company__c, Name';
		System.debug('QUERY:::' + strQuery);

		this.lstResults = new List<Ergotron_Product_Comparison__c>((List<Ergotron_Product_Comparison__c>)Database.query(strQuery));
		return null;
	}

	private void populateListOfObjectFields(){
		this.lstObjectFields = new List<String>();

		setBlockedFields = UtilityMethods.setAuditFields;
		setBlockedFields.add('COMPARISONSORT__C');
		setBlockedFields.add('ISAVAILABLEFORSEARCH__C');
		setBlockedFields.add('ID');

		for(String str : UtilityMethods.getFieldsFromPageLayout('Ergotron_Product_Comparison__c',objOrigin.RecordTypeId)){
			if(!setBlockedFields.contains(str.toUpperCase())){
				this.lstObjectFields.add(str);
			}
		}
	}

	private void populateMapComparison(){
		mapComparison = new Map<Id, Ergotron_Product_Comparison__c>();
		Map<String, String> mapSort = new Map<String, String>();
		mapSort.put('ComparisonSort__c', UtilityMethods.G_SORT_DESCENDING);

		Map<Id, sObject> mapTemp = UtilityMethods.objRecordData(
			'Ergotron_Product_Comparison__c',
			setProductIds,
			setBlockedFields,
			mapSort
		);

		// Put full results in Map
		for(Id id : mapTemp.keyset()) {
			mapComparison.put(id, (Ergotron_Product_Comparison__c)mapTemp.get(id));
		}

		// Loop through and remove fields that aren't filled out
		lstObjectFieldsDisplay = new List<String>();
		for(String strField : lstObjectFields) {
			Boolean bolAddField = false;
			for(Ergotron_Product_Comparison__c objEPC : mapComparison.values()) {
				bolAddField |= (objEPC.get(strField) != null);
			}
			if(bolAddField) { lstObjectFieldsDisplay.add(strField); }
		}
	}

	///////////////////////////
	// Action Methods
	///////////////////////////
	public PageReference addToSelected() {

		if(!bolErrorMaxAdd) {
			mapProducts.put(idTarget,[Select Company__c,Name,Manufacturers_Part_Number__c,RecordType.Name,RecordTypeId,Last_Revised__c From Ergotron_Product_Comparison__c Where Id = :idTarget]);
			idTarget = null;
			if(mapProducts.size() > 1) { bolShowAutoAdd = false; }
			searchListResults();
		}

		return null;
	}

	public PageReference removeFromSelected() {
		mapProducts.remove(idTarget);
		idTarget = null;
		searchListResults();
		return null;
	}

	public PageReference displayComparison() {
		setProductIds = mapProducts.keySet();
		populateMapComparison();
		PageReference prRef = new PageReference('/apex/ProductComparison?generate=1');
		prRef.setRedirect(false);
		return prRef;
	}

	public PageReference displayComparisonXLS(){
		PageReference prRef = new PageReference('/apex/ProductComparisonXLS?generate=1&excel=true');
		prRef.setRedirect(false);
		return prRef;
	}

	public PageReference cancel() {
		PageReference prRef = new PageReference('/'+ApexPages.currentPage().getParameters().get('id'));
		prRef.setRedirect(true);
		return prRef;
	}
}