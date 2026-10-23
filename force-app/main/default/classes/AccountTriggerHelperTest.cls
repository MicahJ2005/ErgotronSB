@isTest
private class AccountTriggerHelperTest {

    static testmethod void testRegionMapping(){
        List<Region_Mapping__c> regionMappings = new List<Region_Mapping__c>{
            new Region_Mapping__c(Country__c='US',Region__c='Americas',Sub_Region__c='US'),
            new Region_Mapping__c(Country__c='CA',Region__c='Americas',Sub_Region__c='Canada'),
            new Region_Mapping__c(Country__c='PR',Region__c='Americas',Sub_Region__c='US'),
            new Region_Mapping__c(Country__c='IT',Region__c='EMEA')
        };
        insert regionMappings;

        List<Account> accounts = null;

        Test.setMock(HttpCalloutMock.class, new Utility_SmartyStreets_MOCK.SmartyStreetsHTTPCalloutMock());

		SmartyStreets_API__c ss = new SmartyStreets_API__c();
			ss.Name = 'SeedUnitAddressVerify';
			ss.auth_id__c = 'adsmfqmwepm09daasd';
			ss.auth_token__c = '23240kfir8fj8f8';
		insert ss;

        User salesUser = [Select Id From User Where Profile.Name='Ergotron Sales Profile' And IsActive = true Limit 1];
        System.runAs(salesUser){
            Test.startTest();
            accounts = new List<Account>{
                new Account(
                    Name = 'Test1',
                    BillingStreet = '11487 Valley View Rd.\r\nSuite A\r\nDock 7\r\nAddressLine4',
				    BillingCity = 'Eden Prairie',
				    BillingState = 'Minnesota',
				    BillingPostalCode = '55344',
                    BillingCountryCode = 'US',
                    Oracle_Site_Id__c = '12345678',
                    RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId()
                ),
                new Account(
                    Name='Test2',
                    BillingStreet = '11487 Valley View Rd.\r\nSuite A\r\nDock 7\r\nAddressLine4',
				    BillingCity = 'Eden Prairie',
				    BillingState = 'Minnesota',
				    BillingPostalCode = '55344',
                    BillingCountryCode='US',
                    RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId()
                ),/*,
                new Account(
                    Name = 'Test3',
                    BillingCountryCode = 'CA',
                    BillingStreet = '11487 Valley View Rd.\r\nSuite A\r\nDock 7\r\nAddressLine4',
				    BillingCity = 'Eden Prairie',
				    BillingStateCode = 'NS',
				    BillingPostalCode = '55344'
                ),
                new Account(
                    Name = 'Test4',
                    BillingCountryCode = 'PR',
                    BillingStreet = '11487 Valley View Rd.\r\nSuite A\r\nDock 7\r\nAddressLine4',
				    BillingCity = 'Eden Prairie',
				    //BillingState = 'Minnesota',
				    BillingPostalCode = '55344'
                ),
                new Account(
                    Name = 'Test5',
                    BillingCountryCode = 'IT',
                    BillingStreet = '11487 Valley View Rd.\r\nSuite A\r\nDock 7\r\nAddressLine4',
				    BillingCity = 'Eden Prairie',
			    	//BillingState = 'Minnesota',
				    BillingPostalCode = '55344'
                ),
                new Account(
                    Name = 'Test6',
                    BillingCountryCode = 'US',
                    BillingStreet = '11487 Valley View Rd.\r\nSuite A\r\nDock 7\r\nAddressLine4',
				    BillingCity = 'Eden Prairie',
				    BillingState = 'Minnesota',
				    BillingPostalCode = '55344'
                ),*/
                new Account(
                    Name = 'Test7',
                    //BillingCountryCode = 'US',
                    BillingStreet = '11487 Valley View Rd.\r\nSuite A\r\nDock 7\r\nAddressLine4',
				    BillingCity = 'Eden Prairie',
				    BillingState = 'Minnesota',
				    BillingPostalCode = '55344'
                )
            };
            insert accounts;
            accounts.get(2).BillingStateCode='MN';
            accounts.get(2).BillingCountryCode='US';
            update accounts;
            Test.stopTest();
        }

        accounts = [Select Name,Region__c,Sub_Region__c From Account Order By Name Asc];
        //System.assertEquals(null, accounts.get(0).Region__c);
        //System.assertEquals(null, accounts.get(0).Sub_Region__c);
        System.assertEquals('Americas', accounts.get(1).Region__c);
        System.assertEquals('US', accounts.get(1).Sub_Region__c);
        System.assertEquals('Americas', accounts.get(2).Region__c);
        System.assertEquals('US', accounts.get(2).Sub_Region__c);
        /*System.assertEquals('Americas', accounts.get(3).Region__c);
        System.assertEquals('US', accounts.get(3).Sub_Region__c);
        System.assertEquals('EMEA', accounts.get(4).Region__c);
        System.assertEquals(null, accounts.get(4).Sub_Region__c);
        System.assertEquals('Americas', accounts.get(5).Region__c);
        System.assertEquals('US', accounts.get(5).Sub_Region__c);
        System.assertEquals('Americas', accounts.get(6).Region__c);
        System.assertEquals('Canada', accounts.get(6).Sub_Region__c);*/
    }
}