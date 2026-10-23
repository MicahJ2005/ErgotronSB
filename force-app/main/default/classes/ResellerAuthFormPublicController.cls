public class ResellerAuthFormPublicController {
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
*   Date        Name                            Description
*   20160705    Andy Boettcher DCS              Created
*   =============================================================================
*/
        public Lead soLead {get;set;}
        public Lead soLeadShipping {get;set;}
    public Seed_Unit_Order__c soLeadBillingAddress {get;set;}
    public Seed_Unit_Order__c soLeadShippingAddress {get;set;}
        public Boolean bolShowResults {get;set;}
        public Boolean bolSameAddress {get;set;}

        ///////////////////////////
        // Constructors
        ///////////////////////////
    public ResellerAuthFormPublicController(ApexPages.StandardController scController) {
        // TODO
        this.soLead = (Lead)scController.getRecord();
        soLead.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Lead' AND DeveloperName = 'Ergotron_Partner_Authorization_Request'].Id;
        this.soLeadShipping = new Lead();
        this.soLeadBillingAddress = new Seed_Unit_Order__c();
        this.soLeadShippingAddress = new Seed_Unit_Order__c();
        
        soLead.LeadSource = 'ResellerAuthForm';
        soLead.Lead_Source_Sales__c= 'Partner Authorization Request';
        soLead.Lead_Source_Sub_Type__c = 'Reseller';
        
        bolShowResults = false;
        bolSameAddress = false;
    }

        ///////////////////////////
        // ACTIONS
        ///////////////////////////

        public PageReference saveLead() {
        
        String strState = ''; String strCountry = '';

                List<Lead_Product__c> lstInsertLPs = new List<Lead_Product__c>();

                // Make sure Zip is required if necessary
                if((soLead.CountryCode == 'US' || soLead.CountryCode == 'CA') && soLead.PostalCode == null) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must enter a valid ' + soLead.CountryCode + ' postal code to complete a Partner Authorization request.'));
                }
        
        // Deal with weird dash thing for Lead.Address
        strState = soLeadBillingAddress.Ship_To_State_Province__c;
        strCountry = soLeadBillingAddress.Ship_To_Country__c;
        
        if(strState != null) { strState = strState.split('-')[0]; soLead.State = strState; }
        if(strCountry != null) { strCountry = strCountry.split('-')[0]; soLead.Country = strCountry; }

                // Handle "Copy from Existing" logic for Address
                        soLead.ShippingStreet__c = soLeadShipping.Street;
                        soLead.ShippingCity__c = soLeadShipping.City;
                        soLead.ShippingState__c = soLeadShippingAddress.Ship_To_State_Province__c;
                        soLead.ShippingPostalCode__c = soLeadShipping.PostalCode;
                        soLead.ShippingCountry__c = soLeadShippingAddress.Ship_To_Country__c;
                
                // Verify Captcha
        Boolean isSuccess;
        isSuccess = Utility_reCaptcha.verify(
            ApexPages.currentPage().getParameters().get('g-recaptcha-response'),
            new map<String,String>{'headerKey'=>'headerValue'}
        );

        // DML ME RIGHT ROUND RIGHT ROUND
                try {
                        insert soLead;
                        bolShowResults = true;

                        PageReference prSuccess = Page.ResellerAuthFormPublicConfirmation;
                        prSuccess.getParameters().put('id', soLead.Id);
                        prSuccess.setRedirect(true);
                        return prSuccess;

                } catch(Exception ex) {
                        bolShowResults = false;
                        return null;
                }

        }
        
}