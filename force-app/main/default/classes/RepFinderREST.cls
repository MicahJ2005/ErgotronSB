@RestResource(urlMapping='/RepFinder')
global with sharing class RepFinderREST {

@HttpPost
    global static List<Account> searchAccounts(String searchString) {
        String searchQuery = 'FIND {' + searchString + '} in name fields returning account (Name,Owner.email,Owner.phone, Owner.Title ,billingcity,billingstatecode, BillingCountryCode, Owner.Name where recordtype.name = \'Site\' and Show_Account__c = True and owner.name not in (\'Ergotron-System\', \'Oracle Integration\') order by billingstate, billingcity)';
        List<List<SObject>> searchList = Search.query(searchQuery);
        return (List<Account>)searchList[0];
    }
}