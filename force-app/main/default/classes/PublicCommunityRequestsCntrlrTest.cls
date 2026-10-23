@isTest 
private class PublicCommunityRequestsCntrlrTest {

    @isTest
	private static void testPrivacyRequest() {

        PublicCommunityRequestsController.PrivacyRequest cls = new PublicCommunityRequestsController.PrivacyRequest();
        cls.contactEmail = 'test@test.com';
        cls.firstName = 'First';
        cls.lastName = 'Last';
        cls.middleInitial = 'M';
        cls.street = '100 South Main St';
        cls.city = 'Minneapolis';
        cls.state = 'MN';
        cls.postal = '55155';
        cls.subject = 'I am a California resident and am submitting this request on my own behalf.';
        cls.relationship = new List<String>{'Customer or prospective customer on behalf of a business'};
        cls.type = 'Request to know';
        cls.subType = new List<String>{'Categories of personal information that we collected in the last 12 months.'};
        cls.contactMethod = new List<String>{'Postal Mail'};
        cls.members = 'Member info';
        cls.residentInfo = 'Resident Info';

        String returnVal = PublicCommunityRequestsController.submitPrivacyRequest(JSON.serialize(cls));
        System.debug('DC: returnVal - ' + returnVal);
        System.assertEquals('CREATED', returnVal);
	}
    
    @isTest
	private static void testeKinnexRequest() {

        PublicCommunityRequestsController.eKinnexRequest cls = new PublicCommunityRequestsController.eKinnexRequest();
        cls.firstName = 'First';
        cls.lastName = 'Last';
        cls.company = 'My Company';
        cls.title = 'VIP';
        cls.email = 'test@test.com';
        cls.phone = 'phone';
        cls.address1 = '100 South Main St';
        cls.address2 = 'Apt 303';
        cls.city = 'Minneapolis';
        cls.state = 'MN';
        cls.country = 'USA';
        cls.postalCode = '55155';
       
        String returnVal = PublicCommunityRequestsController.submitEKinnexRequest(JSON.serialize(cls));
        System.debug('DC: returnVal - ' + returnVal);
        System.assertEquals('CREATED', returnVal);
	}
    
    @isTest
	private static void testServiceRequest() {

        PublicCommunityRequestsController.ServiceRequest cls = new PublicCommunityRequestsController.ServiceRequest();
        cls.firstName = 'First';
        cls.lastName = 'Last';
        cls.postalCode = '55155';
        cls.phone = '222-222-2222';
        cls.email = 'test@test.com';
        cls.comment = 'No comment';

        String returnVal = PublicCommunityRequestsController.submitServiceRequest(JSON.serialize(cls));
        System.debug('DC: returnVal - ' + returnVal);
        System.assertEquals('CREATED', returnVal);
	}
    
    @isTest
	private static void testRecallInformationRequest() {

        PublicCommunityRequestsController.RecallInformationRequest cls = new PublicCommunityRequestsController.RecallInformationRequest();
        cls.firstName = 'First';
        cls.lastName = 'Last';
        cls.company = 'My Company';
        cls.address1 = '100 South Main St';
        cls.address2 = 'Apt 303';
        cls.city = 'Minneapolis';
        cls.state = 'MN';
        cls.postalCode = '55155';
        cls.email = 'test@test.com';
        cls.phone = 'phone';
        cls.product = 'something';
        cls.purchaseDate = 'something';
        cls.ugCode = 'something';
        cls.dateCode = 'something';
        cls.details = 'something';
       
        String returnVal = PublicCommunityRequestsController.submitRecallInformationRequest(JSON.serialize(cls));
        System.debug('DC: returnVal - ' + returnVal);
        System.assertEquals('CREATED', returnVal);
	}
    
    @isTest
	private static void testPartnerLogoRequest() {

        PublicCommunityRequestsController.PartnerLogoRequest cls = new PublicCommunityRequestsController.PartnerLogoRequest();
        cls.firstName = 'First';
        cls.lastName = 'Last';
        cls.company = 'My Company';
        cls.email = 'test@test.com';
        
        String returnVal = PublicCommunityRequestsController.submitPartnerLogoRequest(JSON.serialize(cls));
        System.debug('DC: returnVal - ' + returnVal);
        System.assertEquals('CREATED', returnVal);
	}
}