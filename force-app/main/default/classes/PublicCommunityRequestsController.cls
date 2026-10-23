public class PublicCommunityRequestsController {

    public class PrivacyRequest {
        public String contactEmail{get; set;}
        public String firstName{get; set;}
        public String lastName{get; set;}
        public String middleInitial{get; set;}
        //public String phone{get; set;}
        //public String address{get; set;}
        public String street {get; set;}
        public String city {get; set;}
        public String state {get; set;}
        public String postal {get; set;}
        public String subject {get; set;}
        public List<String> relationship {get; set;}
        public String type {get; set;}
        public List<String> subType {get; set;}
        public List<String> contactMethod {get; set;}
        public String members {get; set;}
        public String infoToCorrect {get; set;}
        public String residentInfo{get; set;}
        //public String residentEmail{get; set;}
        //public String residentFirstName{get; set;}
        //public String residentLastName{get; set;}
    }
    
    @AuraEnabled
    public static String submitPrivacyRequest(String request) {
        //  https://full-ergotron.cs195.force.com/public/s/privacy-request
        System.debug('request: ' + request);
        PrivacyRequest req = (PrivacyRequest)JSON.deserialize(request, PrivacyRequest.class);
        System.debug('req: ' + req);

        //Decision to NOT create a Contact.
        //Contact contact = new Contact();
        //contact.FirstName = req.firstName;
        //contact.LastName = req.lastName;
        //contact.Middle_Initial__c = req.middleInitial;
        //contact.Phone =  req.phone;
        //contact.MailingStreet = req.address;
        
        // String rcm = '';
        // for (String cm : req.contactMethod) {
        //     rcm = rcm + cm + '; ';
        // }
        // rcm.removeEnd(';');
        // contact.Requested_Contact_Method__c = rcm;
        // if (req.subject == 'I am a California resident and am submitting this request on my own behalf.') {
        //     contact.Request_Subject__c = 'California Resident Submitting on Own Behalf';
        // } else if (req.subject == 'I am a California resident and am submitting this request on behalf of my household, which is located in California.') {
        //     contact.Request_Subject__c = 'California Resident Submitting on Household\'s Behalf';
        // } else if (req.subject == 'I am authorized to submit this request on behalf of another individual who is a California resident.') {
        //     contact.Request_Subject__c = 'Authorized to Submit on Behalf of Another California Resident';
        // }
        //insert contact;

        Case newCase = new Case();
        
        newCase.SuppliedName = req.firstName + req.middleInitial + '. ' + req.lastName;
        //newCase.SuppliedPhone = req.phone;
        newCase.SuppliedEmail = req.contactEmail;
        //newCase.ContactId = contact.Id;
        newCase.Request_Subject__c = req.subject;
        newCase.Type_of_Request__c = req.type;
        String description = '';
        // public String firstName{get; set;}
        //if (req.middleInitial != null) {
        //    description = 'Name: ' + req.firstName + ' ' + req.middleInitial + '. ' + req.lastName + '\r\n';
        //} else {
        //    description = 'Name: ' + req.firstName + ' ' + req.lastName + '\r\n';
        //}
        description += addToDescription('First Name', req.firstName);
        description += addToDescription('Middle Initial', req.middleInitial);
        description += addToDescription('Last Name', req.lastName);
        description += addToDescription('Email', req.contactEmail);
        //description += addToDescription('Phone', req.phone);
        description += addToDescription('Street Address', req.street);
        description += addToDescription('City', req.city);
        description += addToDescription('State', req.state);
        description += addToDescription('Postal Code', req.postal);
        description += addToDescription('Subject', req.subject);
        //description += addToDescription('Relationship', req.relationship);
        description += addToDescription('Type', req.type);

        // public List<String> subType {get; set;}
        description += 'SubType: ';
        for (String st : req.subType) {
            description += st + ' ';
        }
        description = description.removeEnd(' ');
        description += '\r\n';

        // public List<String> contactMethod {get; set;}
        description += 'Requested Contact Method: ';
        for (String cm : req.contactMethod) {
            description += cm + ', ';
        }
        description = description.removeEnd(', ');
        description += '\r\n';
        
        description += 'Relationship: ';
        for (String r : req.relationship) {
            description += r + ', ';
        }
        description = description.removeEnd(', ');
        description += '\r\n';


        description += addToDescription('Members', req.members);
        description += addToDescription('Resident Information', req.residentInfo);
        description += addToDescription('Info to Correct', req.infoToCorrect);
        //description += addToDescription('Resident Email', req.residentEmail);
        //description += addToDescription('Resident Name', req.residentFirstName + ' ' + req.residentLastName);

        newCase.Description = description;
        
        String st = '';
        for (String subtype : req.subType) {
            st = st + subtype + '; ';
        }
        st.removeEnd('; ');
        newCase.Request_SubType__c = st;

        //And finally - defaults for this case
        //RT = data privacy; priority = medium; origin = email (we'll do web); owner = customer engagement queue
        newCase.RecordTypeId = getRecordTypeId('Data Privacy Request');
        newCase.Priority = 'Medium';
        newCase.Origin = 'Email';
        newCase.OwnerId = getQueueId('Customer Engagement Queue');
        newCase.Description = description;
        newCase.Subject = 'Data Privacy Request';
        return insertCase(newCase);
    }

    public class eKinnexRequest {
        public String firstName{get; set;}
        public String lastName{get; set;}
        public String company{get; set;}
        public String title{get; set;}
        public String role{get; set;}
        public String email{get; set;}
        public String phone{get; set;}
        public String address1{get; set;}
        public String address2{get; set;}
        public String city{get; set;}
        public String state{get; set;}
        public String country{get; set;}
        public String postalCode{get; set;}
        public String requestType{get; set;}
        public String platformStr{get; set;}
        public String drawerValuesStr{get; set;}
        public String comment{get; set;}
    }

    @AuraEnabled
    public static String submitEKinnexRequest(String request) {
        eKinnexRequest req = (eKinnexRequest)JSON.deserialize(request, eKinnexRequest.class);
        Case newCase = new Case();
        newCase.SuppliedName = req.firstName + ' ' + req.lastName;
        newCase.SuppliedCompany = req.company;
        newCase.SuppliedEmail = req.email;
        newCase.SuppliedPhone = req.phone;
        String description = '';
        description += addToDescription('First Name', req.firstName);
        description += addToDescription('Last Name', req.lastName);
        description += addToDescription('Company', req.company);
        description += addToDescription('Role', req.role);
        description += addToDescription('Email', req.email);
        description += addToDescription('Phone', req.phone);
        description += addToDescription('Title', req.title);
        description += addToDescription('Address line 1', req.address1);
        description += addToDescription('Address line 2', req.address2);
        description += addToDescription('City', req.city);
        description += addToDescription('State', req.state);
        description += addToDescription('Country', req.country);
        description += addToDescription('Postal Code', req.postalCode);
        description += addToDescription('Request Type', req.requestType);
        description += addToDescription('Platforms selected', req.platformStr);
        description += addToDescription('Drawer options selected', req.drawerValuesStr);
        description += addToDescription('Comment, question or concern', req.comment);
        newCase.Description = description;

        newCase.RecordTypeId = getRecordTypeId('Product');
        newCase.Priority = 'Medium';
        newCase.Origin = 'Email';
        newCase.OwnerId = getQueueId('eKinnex');
        newCase.Subject = 'eKinnex Support Request';
        return insertCase(newCase);
    }

    public class ServiceRequest {
        public String firstname{get; set;}
        public String lastname{get; set;}
        public String postalCode{get; set;}
        public String phone{get; set;}
        public String email{get; set;}
        public String partnum{get; set;}
        public String quantity{get; set;}
        public String comment{get; set;}
    }

    @AuraEnabled
    public static String submitServiceRequest(String request) {
        ServiceRequest req = (ServiceRequest)JSON.deserialize(request, ServiceRequest.class);
        Case newCase = new Case();
        newCase.SuppliedName = req.firstname + ' ' + req.lastname;
        newCase.SuppliedEmail = req.email;
        newCase.SuppliedPhone = req.phone;
        String description = '';
        description += addToDescription('First Name', req.firstname);
        description += addToDescription('Last Name', req.lastname);
        description += addToDescription('Zip Code', req.postalCode);
        description += addToDescription('Phone', req.phone);
        description += addToDescription('Email', req.email);
        description += addToDescription('Model / part number', req.partnum);
        description += addToDescription('Qty of products needing service', req.quantity);
        description += addToDescription('Comment', req.comment);
        newCase.Description = description;

        //newCase.RecordTypeId = getRecordTypeId('Product');
        newCase.Priority = 'Medium';
        newCase.Origin = 'Email';
        newCase.OwnerId = getQueueId('Technical Support Queue');
        newCase.Subject = 'Service Request';
        return insertCase(newCase);
    }

    public class RecallInformationRequest {
        public String firstName{get; set;}
        public String lastName{get; set;}
        public String company{get; set;}
        public String address1{get; set;}
        public String address2{get; set;}
        public String city{get; set;}
        public String state{get; set;}
        public String postalCode{get; set;}
        public String phone{get; set;}
        public String email{get; set;}
        public String product{get; set;}
        public String purchaseDate{get; set;}
        public String ugCode{get; set;}
        public String dateCode{get; set;}
        public String details{get; set;}
    }

    @AuraEnabled
    public static String submitRecallInformationRequest(String request) {
        RecallInformationRequest req = (RecallInformationRequest)JSON.deserialize(request, RecallInformationRequest.class);
        Case newCase = new Case();
        newCase.SuppliedName = req.firstName + ' ' + req.lastName;
        newCase.SuppliedCompany = req.company;
        newCase.SuppliedEmail = req.email;
        newCase.SuppliedPhone = req.phone;
        String description = '';
        description += addToDescription('Name', req.firstName + ' ' + req.lastName);
        description += addToDescription('Company', req.company);
        description += addToDescription('Address', req.address1 + '\r\n' + req.address2);
        description += addToDescription('City', req.city);
        description += addToDescription('State', req.state);
        description += addToDescription('Zip Code', req.postalCode);
        description += addToDescription('Phone', req.phone);
        description += addToDescription('Email', req.email);
        description += addToDescription('Product', req.product);
        description += addToDescription('Purchase Date', req.purchaseDate);
        description += addToDescription('UPC / GTIN Code', req.ugCode);
        description += addToDescription('Date Code', req.dateCode);
        description += addToDescription('Additional Details', req.details);
        newCase.Description = description;

        newCase.RecordTypeId = getRecordTypeId('Distribution Order');
        newCase.Priority = 'Medium';
        newCase.Origin = 'Email';
        newCase.OwnerId = getQueueId('Distribution Order Queue');
        newCase.Subject = 'Recall Information Request';
        return insertCase(newCase);
    }

    public class PartnerLogoRequest {
        public String firstname {get; set;}
        public String lastname {get; set;}
        public String company {get; set;}
        public String email {get; set;}
    }

    @AuraEnabled
    public static String submitPartnerLogoRequest(String request) {
        System.debug('DC: inside submitPartnerLogoRequest: ' + request);
        PartnerLogoRequest req = (PartnerLogoRequest)JSON.deserialize(request, PartnerLogoRequest.class);
        Case newCase = new Case();
        newCase.SuppliedName = req.firstname + ' ' + req.lastname;
        newCase.SuppliedCompany = req.company;
        newCase.SuppliedEmail = req.email;
        String description = '';
        description += addToDescription('First Name', req.firstname);
        description += addToDescription('Last Name', req.lastname);
        description += addToDescription('Company', req.company);
        description += addToDescription('Email', req.email);
        newCase.Description = description;

        //newCase.RecordTypeId = getRecordTypeId('Distribution Order');
        newCase.Priority = 'Medium';
        newCase.Origin = 'Email';
        newCase.Subject = 'Partner Logo Request';
        //newCase.OwnerId = getQueueId('Distribution Order Queue');
        return insertCase(newCase);
    }

    private static String insertCase(Case newCase) {
        try{
            insert newCase;
            return 'CREATED';
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }

    //Given a string; add it to the description - checking for nulls; etc.  
    private static String addToDescription(String label, String value) {
        String returnVal = '';
        if(value != null && value != '' && String.isNotBlank(value)) {
            returnVal = label + ': ' + value + '\r\n';
        }
        return returnVal;
    }

    private static Id getRecordTypeId(String rtName) {
        Id recTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(rtName).getRecordTypeId();
        return recTypeId;
    }

    private static Id getQueueId(String qName) {
        Group grp = [SELECT Id FROM Group WHERE Type='Queue' AND Name = :qName limit 1];
        return grp.Id;
    }

}