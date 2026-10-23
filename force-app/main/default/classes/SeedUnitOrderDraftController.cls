public with sharing class SeedUnitOrderDraftController {
/**
*   {Purpose}  �  Controller for SeedUnitOrderDraft, a VF page published via Sites to collect "anonymous" SUOs
*
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 612-424-0032                  
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date    	Name             		Description
*   20160705  	Andy Boettcher DCS		Created
*   20240205    Esau Sanchez            Updated the evaluation of vertical market against eligible seed unit checkboxes for the
*                                       partner community - getProductOptions() method.
*   =============================================================================
*/
	public Lead soLead {get;set;}
	public Lead soLeadShipping {get;set;}
    public Seed_Unit_Order__c soLeadBillingAddress {get;set;}
    public Seed_Unit_Order__c soLeadShippingAddress {get;set;}
	public Boolean bolShowResults {get;set;}
	public Boolean bolSameAddress {get;set;}
    public String strBrand {get;set;}

	///////////////////////////
	// Constructors
	///////////////////////////
	public SeedUnitOrderDraftController(ApexPages.StandardController scController) {
		// TODO
		this.soLead = (Lead)scController.getRecord();
		this.soLeadShipping = new Lead();
        this.soLeadBillingAddress = new Seed_Unit_Order__c();
        this.soLeadShippingAddress = new Seed_Unit_Order__c();

		soLead.LeadSource = 'SUODraft-CommercialBU';
        soLead.Lead_Source_Sales__c= 'Web Seed Request';
        soLead.Lead_Source_Sub_Type__c = 'Web Seed Request';

		User oUser = [Select Id, FirstName, LastName,
		Street, State, City, Country, PostalCode, Title, Phone, MobilePhone, CompanyName, Email from User where Id = :UserInfo.getUserId()];

		if(soLead.Id == null){
			soLead.FirstName = oUser.FirstName;
			soLead.LastName = oUser.LastName;
			soLead.Title = oUser.Title;
			soLead.Phone = oUser.Phone;
			soLead.MobilePhone = oUser.MobilePhone;
			soLead.Email = oUser.Email;
			soLead.Company = oUser.CompanyName;
			soLead.Street = oUser.Street;
			soLead.City = oUser.City;
			soLead.Country = oUser.Country;
			soLead.State = oUser.State;
			soLead.PostalCode = oUser.PostalCode;
		}

		if(ApexPages.currentPage().getParameters().get('leadsource') != '') {
			soLead.LeadSource = ApexPages.currentPage().getParameters().get('leadsource');
		}

        strBrand = ApexPages.currentPage().getParameters().get('brand').toUpperCase();

		bolShowResults = false;
		bolSameAddress = false;
	}
	
	///////////////////////////
	// GET / SET
	///////////////////////////
    public List<SelectOption> lstProducts {
    	get {
    		List<SelectOption> lstTemp = new List<SelectOption>();
    		Set<String> setItemType = new Set<String>();	
			setItemType.add('E-FG');
			setItemType.add('E-SERVICE');
			setItemType.add('PTO');

			Set<String> setCostingInventory = new Set<String>();
			setCostingInventory.add('F');
			setCostingInventory.add('ANT');

    		if(((strBrand == 'ERGOTRON' || strBrand == '') && soLead.Ergotron_Vertical_Market__c == null) || (strBrand == 'HAWORTH' && soLead.Industry == null)) {
    			lstTemp.add(new SelectOption('', ' -- Select an Industry -- '));
    			return lstTemp;
    		}

    		lstTemp.add(new SelectOption('', ' -- Select a Product -- '));

    		String strQuery = 'SELECT Id, Name, ProductCode FROM Product2 WHERE ';
    		strQuery+= ' (Item_Type__c IN :setItemType AND Inventory_Item_Status_Code__c = \'MASTER\' AND IsActive = TRUE) ';
    		strQuery+= ' AND ';
    		strQuery+= ' (MSRP_EMEA_APAC_USD__c > 0 OR MSRP_EMEA_EUR__c > 0 OR MSRP_EMEA_GBP__c > 0 OR MSRP_US_STANDARD_USD__c > 0) ';
    		strQuery+= ' AND ';
    		strQuery+= ' Costing_Inventory__c IN :setCostingInventory ';

            if(strBrand == 'HAWORTH') {
                strQuery+=' AND Public_Seed_Unit_Eligible_Haworth__c = TRUE ';
            }

            if(strBrand == 'ERGOTRON' || strBrand == '') {
                if(soLead.Ergotron_Vertical_Market__c == 'Education') {
                    strQuery+=' AND PublicSeedUnitEligibleEducation__c = TRUE ';
                }
                if(soLead.Ergotron_Vertical_Market__c == 'Enterprise') {
                    strQuery+=' AND PublicSeedUnitEligibleEnterprise__c = TRUE ';
                }
                if(soLead.Ergotron_Vertical_Market__c == 'Government') {
                    strQuery+=' AND PublicSeedUnitEligibleGovernment__c = TRUE ';
                }
                if(soLead.Ergotron_Vertical_Market__c == 'Healthcare') {
                    strQuery+=' AND PublicSeedUnitEligibleHospital__c = TRUE '; 
                }
                if(soLead.Ergotron_Vertical_Market__c == 'Office/Wellness') {
                    strQuery+=' AND PublicSeedUnitEligibleHospital__c = TRUE '; 
                }
            }

    		strQuery+= ' ORDER BY ProductCode ASC';
    		strQuery+= ' LIMIT 750';

    		for(Product2 objPrd : (List<Product2>)Database.query(strQuery)) {
    			lstTemp.add(new SelectOption(objPrd.Id, objPrd.Name + ' (' + objPrd.ProductCode + ')'));
    		}

    		return lstTemp;
    	}
    }

	public PageReference saveLead() {
        
        String strState = ''; String strCountry = '';

		List<Lead_Product__c> lstInsertLPs = new List<Lead_Product__c>();
		soLead.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Lead' AND DeveloperName = 'Seed_Unit_Order_Submission'].Id;

		// Make sure Zip is required if necessary
		if((soLead.CountryCode == 'US' || soLead.CountryCode == 'CA') && soLead.PostalCode == null) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must enter a valid ' + soLead.CountryCode + ' postal code to complete a Seed Unit Order request.'));
		}

		if(soLead.WebSeedProductRequested__c == null) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must select a product to complete a Seed Unit Order request.'));
			return null;
		}
        
        // Deal with weird dash thing for Lead.Address
        strState = soLeadBillingAddress.Ship_To_State_Province__c;
        strCountry = soLeadBillingAddress.Ship_To_Country__c;
        
        if(strState != null) { strState = strState.split('-')[0]; soLead.State = strState; }
        if(strCountry != null) { strCountry = strCountry.split('-')[0]; soLead.Country = strCountry; }

		// Handle "Copy from Existing" logic for Address
		if(soLeadShipping.ShippingStreet__c == '') {
			soLead.ShippingStreet__c = soLead.Street;
			soLead.ShippingCity__c = soLead.City;
			soLead.ShippingState__c = soLeadBillingAddress.Ship_To_State_Province__c;
			soLead.ShippingPostalCode__c = soLead.PostalCode;
			soLead.ShippingCountry__c = soLeadBillingAddress.Ship_To_Country__c;
		} else {
			soLead.ShippingStreet__c = soLeadShipping.Street;
			soLead.ShippingCity__c = soLeadShipping.City;
			soLead.ShippingState__c = soLeadShippingAddress.Ship_To_State_Province__c;
			soLead.ShippingPostalCode__c = soLeadShipping.PostalCode;
			soLead.ShippingCountry__c = soLeadShippingAddress.Ship_To_Country__c;
		}
        
        // Verify Reseller Fields
        Boolean isResellerFieldsVerified = true;
        if(soLead.WebResellerName__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Required fields are missing [Reseller Name]'));
            isResellerFieldsVerified = false;
        }
        if(soLead.WebResellerContact__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Required fields are missing [Reseller Contact Name]'));
            isResellerFieldsVerified = false;
        }
        if(soLead.WebResellerAddress1__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Required fields are missing [Reseller Street Address 1]'));
            isResellerFieldsVerified = false;
        }
        if(soLead.WebResellerCity__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Required fields are missing [Reseller City]'));
            isResellerFieldsVerified = false;
        }
        if(soLead.WebResellerStateCountry__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Required fields are missing [Reseller State/Country]'));
            isResellerFieldsVerified = false;
        }
        if(soLead.WebResellerPostalCode__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Required fields are missing [Reseller Postal Code]'));
            isResellerFieldsVerified = false;
        }
        if(soLead.WebResellerPhone__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Required fields are missing [Reseller Phone]'));
            isResellerFieldsVerified = false;
        }
        if(soLead.WebResellerEmail__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Required fields are missing [Reseller Email]'));
            isResellerFieldsVerified = false;
        }
        
        if(!isResellerFieldsVerified) {
            return null;
        }
		
		// Verify Captcha
        Boolean isSuccess;
        isSuccess = Utility_reCaptcha.verify(
            ApexPages.currentPage().getParameters().get('g-recaptcha-response'),
            new map<String,String>{'headerKey'=>'headerValue'}
        );
        
        if(!isSuccess) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You have not completed the CAPTCHA verification step!'));
            return null;
        }

        // DML ME RIGHT ROUND RIGHT ROUND
		try {
			insert soLead;
			bolShowResults = true;

			PageReference prSuccess = Page.SeedUnitOrderPublicConfirmation;
			prSuccess.getParameters().put('id', soLead.Id);
			prSuccess.setRedirect(true);
			return prSuccess;

		} catch(Exception ex) {
			// ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
			bolShowResults = false;
			return null;
		}

	}
    
    
    @AuraEnabled(cacheable=true)
    public static List<Option> getProductOptions(String brand, String market){
        
        Set<String> setItemType = new Set<String>{'E-FG','E-SERVICE','PTO'};
        Set<String> setCostingInventory = new Set<String>{'F','ANT'};
            
        String query = 
            'Select ' + 
             	'Id,' +
             	'Name,' +
             	'ProductCode ' +
             'From ' +
            	'Product2 ' +
             'Where ' +
             	'Item_Type__c in :setItemType ' + 
             	'And Inventory_Item_Status_Code__c = \'Master\' ' + 
             	'And IsActive = true ' +
            	'And (MSRP_EMEA_APAC_USD__c > 0 OR MSRP_EMEA_EUR__c > 0 OR MSRP_EMEA_GBP__c > 0 OR MSRP_US_STANDARD_USD__c > 0) ' +
             	'And Costing_Inventory__c in :setCostingInventory ';
        
        String additionalQuery = '';
        if(brand == 'HAWORTH') {
            additionalQuery = ' AND Public_Seed_Unit_Eligible_Haworth__c = TRUE ';
        }
                       
		if(brand == 'ERGOTRON' || String.isEmpty(brand)) {
            switch on market{
                when 'All' {
                    additionalQuery = 'AND (PublicSeedUnitEligibleEducation__c = TRUE OR PublicSeedUnitEligibleEnterprise__c = TRUE OR PublicSeedUnitEligibleGovernment__c = TRUE OR PublicSeedUnitEligibleHospital__c = TRUE)';
                }
                when 'Consumer', 'Industrial', 'Workspace' {
                    additionalQuery = 'AND (PublicSeedUnitEligibleEnterprise__c = TRUE OR PublicSeedUnitEligibleGovernment__c = TRUE)';
                }
                when 'Education'{
            	    additionalQuery = ' AND PublicSeedUnitEligibleEducation__c = TRUE ';
                }
                when 'Healthcare' {
                    additionalQuery = ' AND PublicSeedUnitEligibleHospital__c = TRUE '; 
                }
                when else {
                    additionalQuery = 'AND (PublicSeedUnitEligibleEducation__c = TRUE OR PublicSeedUnitEligibleEnterprise__c = TRUE OR PublicSeedUnitEligibleGovernment__c = TRUE OR PublicSeedUnitEligibleHospital__c = TRUE)';
                }
            }
        }
        
        List<Option> options = new List<Option>{new Option('-- None --',null)};
                
        query += 
            (String.isEmpty(additionalQuery) ? '' : additionalQuery) +
        	' Order By Name Asc, ProductCode Asc' +
    		' Limit 750';

        
        System.debug('Query: ' + query);
        for(Product2 prod : Database.query(query)){
            options.add(new Option(prod.Name, prod.Id));
        }
        return options;     
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Option> getMarkets(){
    	List<Option> options = new List<Option>();
   		Schema.DescribeFieldResult fieldResult = Lead.Ergotron_Vertical_Market__c.getDescribe();
   		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
      		options.add(new Option(f.getLabel(), f.getValue()));
   		}       
   		return options;
	}
    
    public class Option{
        @AuraEnabled public String label {get; set;}
        @AuraEnabled public String value {get; set;}
        public Option(String label, String value){
            this.label = label;
            this.value = value;
        }
    }
	
}