public with sharing class SRWizardController {
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
*   Date        Name                    Description
*   20160309    Andy Boettcher DCS      Created
*   20170418    Esau Sanchez            commented line 38 - to force users to select value
*   20170808    Esau Sanchez            Added Account validation - lines 313-316
*	20180517	Andy Boettcher DCS		Sunsetted for Lightning Service Cloud
*   =============================================================================
*/
    //public hclsQuickFind clsQuickFind {get;set;}
    //public Case soCase {get;set;}
    //public Contact soContact {get;set;}

    /////////////////////////////
    //// Constructors
    /////////////////////////////
    //public SRWizardController(ApexPages.standardController scMain) {

        //// Determine what object is being passed
        //SObjectType sotType = scMain.getRecord().getSObjectType();

        //// CASE - SERVICE REQUEST
        //if(sotType == Case.sObjectType) {
        
            //// Initialize public variables
            ////soCase = new Case();
            //soCase = (Case)scMain.getRecord();
            //clsQuickFind = new hclsQuickFind();

            ////soCase.Out_of_Box__c = 'No';

            //// Pull in URL Search Parameters
            //clsQuickFind.strSearchAccount = ApexPages.currentPage().getParameters().get('act');
            //clsQuickFind.strSearchContact = ApexPages.currentPage().getParameters().get('con');
            //clsQuickFind.strSearchInstalledProduct = ApexPages.currentPage().getParameters().get('sn');
            //clsQuickFind.strSearchServiceContract = ApexPages.currentPage().getParameters().get('sc');

            //// Pull in URL ID Parameters and set to Case if available
            //clsQuickFind.idAccount = ApexPages.currentPage().getParameters().get('actid');
            //clsQuickFind.idContact = ApexPages.currentPage().getParameters().get('conid');
            //clsQuickFind.idInstalledProduct = ApexPages.currentPage().getParameters().get('snid');
            //clsQuickFind.idServiceContract = ApexPages.currentPage().getParameters().get('scid');
            
            //// Pull in RecordType if passed
            //soCase.RecordTypeId = ApexPages.currentPage().getParameters().get('RecordType');

            //if(clsQuickFind.idAccount != '') { soCase.AccountId = clsQuickFind.idAccount; }
            //if(clsQuickFind.idContact != '') { soCase.ContactId = clsQuickFind.idContact; }
            //if(clsQuickFind.idInstalledProduct != '') { soCase.Serial_Number__c = clsQuickFind.idInstalledProduct; }
            //if(clsQuickFind.idServiceContract != '') { soCase.Service_Contract__c = clsQuickFind.idServiceContract; }

        //}

        //if(sotType == Contact.sObjectType) {

            //soContact = (Contact)scMain.getRecord();

            //// Initialize public variables
            //soContact.AccountId = ApexPages.currentPage().getParameters().get('actid');

        //}
    //}
    
    
    /////////////////////////////
    //// GET / SET
    /////////////////////////////
    //public PageReference prNewContact {
        //get {
            //PageReference prCase = Page.SRWizard;
            //prCase.getParameters().put('actid', clsQuickFind.idAccount);
            //prCase.getParameters().put('conid', clsQuickFind.idContact);
            //prCase.getParameters().put('snid', clsQuickFind.idInstalledProduct);
            //prCase.getParameters().put('scid', clsQuickFind.idServiceContract);

            ////PageReference prNew = new PageReference('/003/e');
            //PageReference prNew = Page.SRWizardContactNew;
            //prNew.setRedirect(true);
            //prNew.getParameters().put('actid', clsQuickFind.idAccount);
            //prNew.getParameters().put('conid', clsQuickFind.idContact);
            //prNew.getParameters().put('snid', clsQuickFind.idInstalledProduct);
            //prNew.getParameters().put('scid', clsQuickFind.idServiceContract);
            //prNew.getParameters().put('retURL', prCase.getURL());
            //return prNew;
        //}
    //}

    //public List<SelectOption> lstAccounts {
        //get {
       
            //System.Debug('lstAccounts');
            //System.Debug(clsQuickFind);
        
            //// Search By Name
            //String strQuery = 'SELECT Id, Name FROM Account WHERE ';
            //if(clsQuickFind.strSearchAccount != '') { 
                //strQuery+= ' Name LIKE \'%' + clsQuickFind.strSearchAccount + '%\' OR Oracle_Party_Number__c LIKE \'%' + clsQuickFind.strSearchAccount + '%\'';
            //} else {
                //strQuery+= ' Id = \'' + clsQuickFind.idAccount + '\'';
            //}
            //strQuery+= ' ORDER BY Name LIMIT 15';
            //List<SelectOption> lstTemp = new List<SelectOption>();
            
            //if(clsQuickFind.idAccount != '' || clsQuickFind.strSearchAccount.length() > 3) {
                //for(Account soAcct : Database.Query(strQuery)) {
                    //lstTemp.add(new SelectOption(soAcct.Id, soAcct.Name));
                //}
            //}

            //lstAccounts = lstTemp;
            //return lstAccounts;

        //}
        //private set;
    //}
    
    //public List<SelectOption> lstContacts {
        //get {
       
            //System.Debug('lstContacts');
            //System.Debug(clsQuickFind);
        
            //// Search By Name
            //String strQuery = 'SELECT Id, Name FROM Contact WHERE ';
            //if(clsQuickFind.strSearchContact != '') { 
                //strQuery+= ' Name LIKE \'%' + clsQuickFind.strSearchContact + '%\' ';
            //} else {
                //strQuery+= ' AccountId = \'' + clsQuickFind.idAccount + '\'';
            //}
            //strQuery+= ' ORDER BY Name LIMIT 25';
            //List<SelectOption> lstTemp = new List<SelectOption>();
            
            //if(clsQuickFind.idAccount != '' || clsQuickFind.strSearchContact.length() > 3) {
                //for(Contact soContact : Database.Query(strQuery)) {
                    //lstTemp.add(new SelectOption(soContact.Id, soContact.Name));
                //}
            //}

            //lstContacts = lstTemp;
            //return lstContacts;

        //}
        //private set;
    //}

    //public List<SelectOption> lstInstalledProducts {
        //get {

            //System.Debug('lstInstalledProducts');
            //System.Debug(clsQuickFind);

            //List<SelectOption> lstTemp = new List<SelectOption>();

            //if(clsQuickFind.idServiceContract != '') {

                //Map<Id, Service_Contract_Product__c> mapSCP = new Map<Id, Service_Contract_Product__c>();

                //for(Service_Contract_Product__c soSCP : [SELECT Installed_Product__c, Installed_Product__r.Name, Installed_Product__r.Product__r.Name FROM Service_Contract_Product__c WHERE Service_Contract__c = :clsQuickFind.idServiceContract]) {
                    //mapSCP.put(soSCP.Installed_Product__c, soSCP);
                //}

                //for(Id objId : mapSCP.keySet()) {
                    //lstTemp.add(new SelectOption(objId, mapSCP.get(objId).Installed_Product__r.Name + ' ' + mapSCP.get(objId).Installed_Product__r.Product__r.Name));
                //}



            //} else {

                //String strQuery = 'SELECT Id, Name, Product__r.Name FROM Installed_Product__c WHERE ';
                //if(clsQuickFind.strSearchInstalledProduct != '') {
                    //strQuery+= ' Name LIKE ' + '\'%' + clsQuickFind.strSearchInstalledProduct + '%\' ';
                //} else {
                    //if(clsQuickFind.idInstalledProduct != '') {
                        //strQuery+= ' Id = \'' + clsQuickFind.idInstalledProduct + '\'';
                    //} else {
                        //strQuery+= ' Customer_Name__c = \'' + clsQuickFind.idAccount + '\'';        
                    //}
                    
                //}
                //strQuery+= ' LIMIT 50';
                
                //if(clsQuickFind.idAccount != '' || clsQuickFind.strSearchInstalledProduct.length() > 4) {
                    //for(Installed_Product__c soIP : Database.Query(strQuery)) {
                        //lstTemp.add(new SelectOption(soIP.Id, soIP.Name + ' ' + soIP.Product__r.Name));
                    //}
                //}

            //}

            //lstInstalledProducts = lstTemp;
            //return lstInstalledProducts;
        //}
        //private set;
    //}
    
    //public List<SelectOption> lstServiceContracts {
        //get {

            //System.Debug('lstServiceContracts');
            //System.Debug(clsQuickFind);

            //List<SelectOption> lstTemp = new List<SelectOption>();
            //String strQuery = '';

            //if(clsQuickFind.idInstalledProduct != '') {
                //strQuery = 'SELECT Id, Service_Contract__c, Service_Contract__r.Name, Service_Contract__r.Contract_Status_Indicator_TEXT__c FROM Service_Contract_Product__c ';
                //strQuery+= 'WHERE Installed_Product__c = \'' + clsQuickFind.idInstalledProduct + '\'';

                //Map<Id, String> mapContracts = new Map<Id, String>();
                //for(Service_Contract_Product__c objSCP : Database.Query(strQuery)) {
                    //mapContracts.put(objSCP.Service_Contract__c, objSCP.Service_Contract__r.Name + ' (' + objSCP.Service_Contract__r.Contract_Status_Indicator_TEXT__c + ')');
                //}

                //for(Id objId : mapContracts.keySet()) {
                    //lstTemp.add(new SelectOption(objId, mapContracts.get(objId)));
                //}

            //} else {

                //strQuery = 'SELECT Id, Name, Contract_Status_Indicator_TEXT__c FROM Service_Contract__c WHERE ';
                //if(clsQuickFind.strSearchServiceContract != '') {
                    //strQuery+= ' Name LIKE ' + '\'%' + clsQuickFind.strSearchServiceContract + '%\' ';
                //} else {
                   //strQuery+= ' Customer_Name__c = \'' + clsQuickFind.idAccount + '\'';     
                //}
                //strQuery+= ' ORDER BY End_Date__c DESC LIMIT 15';
                
                
                //if(clsQuickFind.idAccount != '' || clsQuickFind.strSearchServiceContract.length() > 3) {
                    //for(Service_Contract__c soIP : Database.Query(strQuery)) {
                        //lstTemp.add(new SelectOption(soIP.Id, soIP.Name + ' (' + soIP.Contract_Status_Indicator_TEXT__c + ')'));
                    //}
                //}

            //}

            //lstServiceContracts= lstTemp;
            //return lstServiceContracts;
        //}
        //private set;
    //}

    //public List<Case> lstExistingCases {
        //get {
            //System.Debug('lstExistingCases');
            //System.Debug(clsQuickFind);

            //lstExistingCases = new List<Case>();

            //if(clsQuickFind.idInstalledProduct != '') {
                //lstExistingCases = [SELECT Id, CaseNumber, Oracle_SR_Number__c, Subject, Status FROM Case WHERE Serial_Number__c = :clsQuickFind.idInstalledProduct ORDER BY LastModifiedDate DESC];
            //}

            //return lstExistingCases;
        //}
        //private set;
    //}
    
    
    /////////////////////////////
    //// Action Methods
    /////////////////////////////
    //public void searchForData() {

        //// Set Ids
        //if(clsQuickFind.idInstalledProduct != '') {
            //clsQuickFind.idAccount = [SELECT Id, Customer_Name__c FROM Installed_Product__c WHERE Id = :clsQuickFind.idInstalledProduct LIMIT 1].Customer_Name__c;
        //}

        //if(clsQuickFind.idServiceContract != '' && clsQuickFind.idAccount == '') {
            //clsQuickFind.idAccount = [SELECT Id, Customer_Name__c FROM Service_Contract__c WHERE Id = :clsQuickFind.idServiceContract LIMIT 1].Customer_Name__c;
        //}

        //if(clsQuickFind.idContact != '' && clsQuickFind.idAccount == '') {
            //clsQuickFind.idAccount = [SELECT Id, AccountId FROM Contact WHERE Id = :clsQuickFind.idContact LIMIT 1].AccountId;
        //}

        //// Fill in Case Fields
        //if(clsQuickFind.idAccount != '' && soCase.AccountId != clsQuickFind.idAccount) { soCase.AccountId = clsQuickFind.idAccount; }
        //if(clsQuickFind.idContact != '' && soCase.ContactId != clsQuickFind.idContact) { soCase.ContactId = clsQuickFind.idContact; }
        //if(clsQuickFind.idInstalledProduct != '') { soCase.Serial_Number__c = clsQuickFind.idInstalledProduct; }
        //if(clsQuickFind.idServiceContract != '') { soCase.Service_Contract__c = clsQuickFind.idServiceContract; }
    
    //}

    //public void executeSearch() {

        //clsQuickFind.idAccount = '';
        //clsQuickFind.idContact = '';
        //clsQuickFind.idInstalledProduct = '';
        //clsQuickFind.idServiceContract = '';

        //// Clear Case Fields
        //soCase.AccountId = null;
        //soCase.ContactId = null;
        //soCase.Serial_Number__c = null;
        //soCase.Service_Contract__c = null;

    //}

    //public PageReference saveSR() {

        //try {

            //// Do Checks
            //if(soCase.AccountId == null) {
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please search and select an account to continue'));
                //return null;
            //}
            //if(soCase.Problem_Codes__c == null || 
                //soCase.Type == null ||
                //soCase.Subject == null ||
                //soCase.Disposition__c == null ||
                //soCase.Out_of_Box__c == null) {
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You need to specify the Type, Problem Code, Disposition, Out of Box Failure, and Subject to continue!'));
                //return null;
            //}

            //insert soCase;

            //return new PageReference('/' + soCase.Id);
        //} catch(Exception ex) {
            //return null;
        //}
    //}

    //public PageReference saveContact() {

        //try {
            //insert soContact;

            //// Somehow deal with creating the contact in Oracle before returning to the SR!

            //PageReference prSRCreate = Page.SRWizard;
            //prSRCreate.getParameters().put('actid', ApexPages.currentPage().getParameters().get('actid'));
            //prSRCreate.getParameters().put('conid', soContact.Id);
            //prSRCreate.getParameters().put('snid', ApexPages.currentPage().getParameters().get('snid'));
            //prSRCreate.getParameters().put('scid', ApexPages.currentPage().getParameters().get('scid'));
            //prSRCreate.setRedirect(true);
            //return prSRCreate;

        //} catch(Exception ex) {
            //return null;
        //}

    //}
    
    /////////////////////////////
    //// Inner / Helper Classes
    /////////////////////////////
    //public class hclsQuickFind {
        //public String strSearchAccount { get;
            //set {
                //if(value == null) { strSearchAccount = ''; } 
                    //else { strSearchAccount = value; }
            //}
        //}

        //public String strSearchContact { get;
            //set {
                //if(value == null) { strSearchContact = ''; } 
                    //else { strSearchContact = value; }
            //}
        //}

        //public String strSearchInstalledProduct { get;
            //set {
                //if(value == null) { strSearchInstalledProduct = ''; } 
                    //else { strSearchInstalledProduct = value; }
            //}
        //}

        //public String strSearchServiceContract { get;
            //set {
                //if(value == null) { strSearchServiceContract = ''; } 
                    //else { strSearchServiceContract = value; }
            //}
        //}

        //public String idAccount { get;
            //set {
                //if(value == null) { idAccount = ''; } 
                    //else { idAccount = value; }
            //}
        //}

        //public String idContact { get;
            //set {
                //if(value == null) { idContact = ''; } 
                    //else { idContact = value; }
            //}
        //}

        //public String idInstalledProduct { get;
            //set {
                //if(value == null) { idInstalledProduct = ''; } 
                    //else { idInstalledProduct = value; }
            //}
        //}

        //public String idServiceContract { get;
            //set {
                //if(value == null) { idServiceContract = ''; } 
                    //else { idServiceContract = value; }
            //}
        //}

        //public hclsQuickFind() {
            //strSearchAccount = '';
            //strSearchContact = '';
            //strSearchInstalledProduct = '';
            //strSearchServiceContract = '';

            //idAccount = '';
            //idContact = '';
            //idInstalledProduct = '';
            //idServiceContract = '';
        //}
    //}
}