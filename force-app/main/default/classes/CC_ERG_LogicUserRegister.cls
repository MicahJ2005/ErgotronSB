global without sharing class CC_ERG_LogicUserRegister extends ccrz.ccLogicUserRegister {
  global override virtual Map<String, Object> validateUser(
    Map<String, Object> inputData
  ) {
    Map<String, Object> outputData = super.validateUser(inputData);
    List<ccrz.cc_bean_Message> messages = (List<ccrz.cc_bean_Message>) outputData.get(
      'messages'
    );
    System.debug('inputData :' + inputData);
    System.debug('messages :' + messages);
    System.debug('outputData :' + outputData);
    InputParser inputParsedData = (InputParser) JSON.deserialize(
      JSON.serialize(inputData.get('originalInputData')),
      InputParser.class
    );
    if (inputParsedData != null) {
      UsrRegister parsedUsrRegister = (UsrRegister) JSON.deserialize(
        inputParsedData.usrRegisterJson,
        UsrRegister.class
      );
      if (parsedUsrRegister != null) {
        if (null == messages) {
          messages = new List<ccrz.cc_bean_Message>();
          System.debug('check existing user with username');
        }
        if (
          parsedUsrRegister.username.equalsIgnoreCase(
            'jeff.williams@salesforce.com.invalid'
          )
        ) {
          System.debug(messages);
          System.debug('invalid username');
          ccrz.cc_bean_Message errMessage = new ccrz.cc_bean_Message(
            'Invalid Username!',
            ccrz.cc_bean_Message.MessageSeverity.ERROR
          );
          errMessage.classToAppend = 'error_messages_section';
          System.debug('check existing user with username');
          errMessage.type = ccrz.cc_bean_Message.MessageType.CUSTOM;
          System.debug('check existing user with username');
          messages.add(errMessage);
          System.debug('check existing user with username');
          outputData.put(ccrz.ccApi.MESSAGES, messages);
          System.debug('check existing user with username');
        } else {
          System.debug('check existing user with username');
        }
      }
    }
    System.debug(' ==@@> ' + outputData.get(ccrz.ccApi.MESSAGES));
    System.debug(' ==@@> ' + outputData);
    return outputData;
  }

  global override virtual Map<String, Object> register(
    Map<String, Object> inputData
  ) {
    System.debug(' ==@@>>> ');
    CC_ERG_LogicUserRegister objLogicUsrReg = new CC_ERG_LogicUserRegister();
    Map<String, Object> outputData = objLogicUsrReg.validateUser(inputData);
    List<ccrz.cc_bean_Message> messages = (List<ccrz.cc_bean_Message>) outputData.get(
      'messages'
    );
    System.debug(' ==@@> ' + messages);
    if (messages?.size() > 0) {
      return outputData;
    }
    System.debug('final');
    return super.register(inputData);
  }

  global override virtual Map<String, Object> createExternalUser(
    Map<String, Object> inputData
  ) {
    Map<String, Object> outputData = null;
    ccrz.cclog.log(LoggingLevel.DEBUG, 'createExternalUser---: ', inputData);
    ccrz.cclog.log(
      LoggingLevel.DEBUG,
      'ccrz.ccApiUser.USER_DATA_MAP',
      ccrz.ccApiUser.USER_DATA_MAP
    );
    ccrz.cclog.log(
      LoggingLevel.DEBUG,
      'ccrz.ccApiUser.USER_DATA_MAP : ',
      inputData.get(ccrz.ccApiUser.USER_DATA_MAP)
    );
    System.debug('createExternalUser dd:' + inputData);
    System.debug(
      'crz.ccApiAccount.ACCOUNT_NEW dd:' +
      inputData.get(ccrz.ccApiAccount.ACCOUNT_NEW)
    );
    System.debug(
      'inputData.get(ccrz.ccApiUser.USER_DATA_MAP) dd:' +
      inputData.get(ccrz.ccApiUser.USER_DATA_MAP)
    );
    System.debug(
      'inputData.get(ccrz.ccApiUser.USER_NEW) dd:' +
      inputData.get(ccrz.ccApiUser.USER_NEW)
    );
    //User userInfo = (User)inputData.get(ccrz.ccApiUser.USER_NEW);
    //System.debug('userinfo - '+userInfo);
    //List<Contact> existingContact = [Select Id,Email from contact where Email=:userInfo.Email limit 1];
    if (outputData == null) {
      outputData = super.createExternalUser(inputData);
    }
    System.debug(
      'ccrz.ccApiUser.USER_ID :' + outputData.get(ccrz.ccApiUser.USER_ID)
    );
    System.debug('ccrz.outputData.USER_REGISTER_JSON dd:' + outputData);
    ccrz.cclog.log(
      LoggingLevel.DEBUG,
      'CC_ERG_LogicUserRegister outputData',
      outputData
    );

    System.debug('after dd:' + outputData);
    return outputData;
  }
  @Future
  public static void assignDRPermissionSet(String userId) {
    if (String.isNotBlank(userId)) {
      //Get DR permission set
      PermissionSet drPermissionSet = [
        SELECT Id, Name
        FROM PermissionSet
        WHERE Name = 'DRB2B_Permission_Set'
      ];
      insert new PermissionSetAssignment(
        AssigneeId = userId,
        PermissionSetId = drPermissionSet.Id
      );
    }
  }
  global override virtual Map<String, Object> prepReturn(
    Map<String, Object> inputData
  ) {
    Map<String, Object> outputData = null;
    ccrz.cclog.log(LoggingLevel.DEBUG, 'prepReturn---: ', inputData);
    System.debug('prepReturn : ' + inputData);
    System.debug('ccrz.ccApiUser.USER_ID :' + ccrz.ccApiUser.USER_ID);
    System.debug(
      'ccrz.ccApiUser.USER_ID :' + inputData.get(ccrz.ccApiUser.USER_ID)
    );
    assignDRPermissionSet((string) inputData.get(ccrz.ccApiUser.USER_ID));
    Account accountInfo = (Account) inputData.get(
      ccrz.ccApiAccount.ACCOUNT_NEW
    );
    User userInfo = null;
    userInfo = (User) inputData.get(ccrz.ccApiUser.USER_NEW);
    String contactId = '';
    if (userInfo != null) {
      contactId = userInfo.ContactId;
      List<Contact> existingContact = [
        SELECT Id, Email, CreatedDate
        FROM contact
        WHERE Id = :userInfo.ContactId
        LIMIT 1
      ];
      Datetime currenTtime = System.now().addMinutes(-2);
      if (
        existingContact.size() > 0 &&
        existingContact.get(0).CreatedDate < currenTtime
      ) {
        Contact contactInfo = new Contact();
        contactInfo.Email = userInfo.Email;
        contactInfo.FirstName = userInfo.FirstName;
        contactInfo.LastName = userInfo.LastName;
        if (String.isNotBlank(userInfo.ccrz__User_Salutation__c)) {
          contactInfo.Salutation = userInfo.ccrz__User_Salutation__c;
        }
        if (String.isNotBlank(userInfo.Phone)) {
          contactInfo.Phone = userInfo.Phone;
        }
        contactInfo.CurrencyIsoCode = userInfo.DefaultCurrencyIsoCode;
        contactInfo.Store_Member__c = true;
        insert contactInfo;
        userInfo.ContactId = contactInfo.Id;
        contactId = contactInfo.Id;
      }
    }
    List<Account> shippingSiteAccountList = [
      SELECT Id, Name
      FROM Account
      WHERE
        Name = :accountInfo.Name
        AND Type = 'End User'
        AND RecordType.Name = 'Site'
    ];
    if (shippingSiteAccountList != null && shippingSiteAccountList.size() > 0) {
      createAccountContactRelationship(
        contactId,
        shippingSiteAccountList.get(0).Id
      );
    }
    if (outputData == null) {
      outputData = super.prepReturn(inputData);
    }
    System.debug('outputData : prepReturn' + outputData);
    ccrz.cclog.log(LoggingLevel.DEBUG, 'prepReturn outputData', outputData);
    return outputData;
  }
  @Future
  private static void createAccountContactRelationship(
    String contactId,
    String accountId
  ) {
    AccountContactRelation accountContactRelation = new AccountContactRelation();
    accountContactRelation.AccountId = accountId;
    accountContactRelation.ContactId = contactId;
    insert accountContactRelation;
  }

  global class InputParser {
    public String usrRegisterJson { get; set; }
    public String cartEncId { get; set; }
  }
  global class UsrRegister {
    public String username { get; set; }
  }
}