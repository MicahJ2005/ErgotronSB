@isTest
public class CC_ERG_ValidateUser_ext_Test {
    
    @isTest 
    static void checkUserAlreadyExist_Test(){
        CC_ERG_ValidateUser_ext.Response  response = new CC_ERG_ValidateUser_ext.Response();
        response =  CC_ERG_ValidateUser_ext.checkUserAlreadyExist(JSON.serialize('12331'));
        system.assertNotEquals(null, response);
    }
        
    @isTest 
    static void whenUserExists_Test(){
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'B2B Storefront' LIMIT 1];
        
        Account acct = new Account(Name = 'Test Account'); 
        insert acct;
        
        Contact cont = new Contact(FirstName = 'firstName', LastName ='lastContact', AccountId = acct.Id,Email = 'testdata@drtest.com');
        insert cont;
        
        User testUser = new User(Alias = 'drtest', Email='druser@testorg.com', EmailEncodingKey='UTF-8',
        FirstName='FirstlName', LastName='LastlName', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = profile.Id, ContactId = cont.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='druserName@testorg.com');
        insert testUser;
        
        CC_ERG_ValidateUser_ext.Response  response = new CC_ERG_ValidateUser_ext.Response();
        response =  CC_ERG_ValidateUser_ext.checkUserAlreadyExist('druserNametestorg.com');
        system.assertNotEquals(null, response);
    }
	@isTest 
    static void whenUsrExists_Test(){
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'B2B Storefront' LIMIT 1];
        
        Account acct = new Account(Name = 'Test Account'); 
        insert acct;
        
        Contact cont = new Contact(FirstName = 'firstName', LastName ='lastContact', AccountId = acct.Id,Email = 'testdata@drtest.com');
        insert cont;
        
        User testUser = new User(Alias = 'drtest', Email='druser@testorg.com', EmailEncodingKey='UTF-8',
        FirstName='FirstlName', LastName='LastlName', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = profile.Id, ContactId = cont.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='druserName@testorg.com');
        insert testUser;
        
        CC_ERG_ValidateUser_ext.Response  response = new CC_ERG_ValidateUser_ext.Response();
        CC_ERG_Header_PLOT sc = new CC_ERG_Header_PLOT();
        CC_ERG_ValidateUser_ext stdCon= new CC_ERG_ValidateUser_ext(sc);
        response =  CC_ERG_ValidateUser_ext.checkUserAlreadyExist('druserName@testorg.com');
        system.assertNotEquals(null, response);
    }
}