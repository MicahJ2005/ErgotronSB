@isTest
private class RepFinderRESTTest {
    @isTest static void testSearchAccounts() {
        // Create a test account
        Account testAccount = new Account();
        testAccount.name = 'Test Account';
        testAccount.Show_Account__c = True;

        insert testAccount;

        // Set the test account name as the search string
        String searchString = testAccount.Name;

        Id [] searchResultsIds = new Id[1];
        searchResultsIds[0] = testAccount.id;
        Test.setFixedSearchResults(searchResultsIds);

        // Set up the test request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/RepFinder/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(searchString);
        RestContext.request = req;
        RestContext.response = res;

        // Call the method to test
        List<Account> accounts = RepFinderREST.searchAccounts(searchString);

        // Assert that the response contains the test account
        System.assert(accounts.size() > 0);
        System.assertEquals(testAccount.Name, accounts[0].Name);
    }
}