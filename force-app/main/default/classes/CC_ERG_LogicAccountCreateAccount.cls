global without sharing class CC_ERG_LogicAccountCreateAccount extends ccrz.ccLogicAccountCreateAccount {
  global override Map<String, Object> createAccount(
    Map<String, Object> inputData
  ) {
    Map<String, Object> outputData = new Map<String, Object>();
    System.debug('==>' + inputData);

    try {
      //Get Default Owner Account Owner Id
      ccrz__E_Configuration__c custom_configs_values = [
        SELECT Name, ccrz__ConfigurationMeta__r.name, ccrz__TextValue__c
        FROM ccrz__E_Configuration__c
        WHERE ccrz__ConfigurationMeta__r.name = 'Default Account Owner'
      ];
      String defaultAccountOwnerId = custom_configs_values.ccrz__TextValue__c;
      ccrz.cclog.log(
        LoggingLevel.DEBUG,
        'createAccountccLogicAccountCreateAccount --',
        inputData
      );
      //Get Site record type for Account
      RecordType siteRecordId = [
        SELECT id, Name, DeveloperName
        FROM RecordType
        WHERE sObjectType = 'Account' AND DeveloperName = 'Site'
        LIMIT 1
      ];
        System.debug('==>inputData' + inputData); 
		System.debug('==>siteRecordId' + siteRecordId); 
      Account newAccount = (Account) inputData.get(
        ccrz.ccApiAccount.ACCOUNT_NEW
      );
      System.debug('==>newAccount' + newAccount);  
      ccrz.cclog.log(
        LoggingLevel.DEBUG,
        'ccLogicAccountCreateAccountewAccount-----',
        newAccount
      );
       System.debug('==>newAccount' + newAccount);
      if (newAccount != null) {
        Boolean isAddressSame = compairBillingAndShippingAddress(newAccount);
        ccrz.cclog.log(
          LoggingLevel.DEBUG,
          'isAddressSame -----',
          isAddressSame
        );
        Account customerAccount = creatAccountHeirarchy(
          newAccount,
          defaultAccountOwnerId,
          isAddressSame
        );

        newAccount.ShippingCountryCode = newAccount.ShippingCountry;
        newAccount.BillingCountryCode = newAccount.BillingCountry;
        newAccount.ShippingCountry = null;
        newAccount.BillingCountry = null;

        newAccount.BillingStateCode = newAccount.BillingState;
        newAccount.BillingState = null;
        newAccount.ShippingStateCode = newAccount.ShippingState;
        newAccount.ShippingState = null;

        newAccount.ParentId = customerAccount.Id;
        newAccount.OwnerId = defaultAccountOwnerId;
        newAccount.RecordTypeId = siteRecordId.Id;
        newAccount.PO_Allowed__c = false;
        newAccount.AccountSource = 'eCommerce';
        newAccount.Region__c = 'Americas';
        ccrz.cclog.log(LoggingLevel.DEBUG, 'newAccount Account', newAccount);
        outputData = super.createAccount(inputData);
        ccrz.cclog.log(LoggingLevel.DEBUG, 'outputData :', outputData);
      } else {
        ccrz.cclog.log(
          LoggingLevel.DEBUG,
          'CC_ERG_LogicAccountCreateAccount Account',
          newAccount
        );
      }
    } catch (Exception e) {
      ccrz.cclog.log(LoggingLevel.ERROR, 'Exception occured : ', e);
    }
    return outputData;
  }

  private static Boolean compairBillingAndShippingAddress(Account newAccount) {
    Boolean isAddressSame = true;
    if (newAccount.ShippingStreet != newAccount.BillingStreet) {
      isAddressSame = false;
    } else if (newAccount.ShippingCity != newAccount.BillingCity) {
      isAddressSame = false;
    } else if (newAccount.ShippingState != newAccount.BillingState) {
      isAddressSame = false;
    } else if (newAccount.ShippingPostalCode != newAccount.BillingPostalCode) {
      isAddressSame = false;
    } else if (newAccount.ShippingCountry != newAccount.BillingCountry) {
      isAddressSame = false;
    }
    return isAddressSame;
  }

  public static Account creatAccountHeirarchy(
    Account newAccount,
    String defaultAccountOwnerId,
    Boolean isAddressSame
  ) {
    List<RecordType> recLst = getAccountRecordTypes();
    Account customerAccount = new Account();
    String siteRecordId;
    String customerRecordId;
    String partyRecordId;

    if (recLst != null && recLst.size() > 0) {
      for (RecordType recType : recLst) {
        if (recType.DeveloperName == 'Site') {
          siteRecordId = recType.id;
        }
        if (recType.DeveloperName == 'Customer_Organization') {
          customerRecordId = recType.id;
        }
        if (recType.DeveloperName == 'Party') {
          partyRecordId = recType.id;
        }
      }
    }
    Account partyAccount = createAccount(
      newAccount,
      defaultAccountOwnerId,
      isAddressSame,
      '',
      partyRecordId,
      true
    );
    if (partyAccount != null) {
      customerAccount = createAccount(
        newAccount,
        defaultAccountOwnerId,
        isAddressSame,
        partyAccount.Id,
        customerRecordId,
        true
      );
      if (!isAddressSame) {
          Account partyShippingAccount = createAccount(
              newAccount,
              defaultAccountOwnerId,
              isAddressSame,
              '',
              partyRecordId,
              false
          );
          if (partyShippingAccount != null) {
              Account customerShippingAccount = createAccount(
                newAccount,
                defaultAccountOwnerId,
                isAddressSame,
                partyShippingAccount.Id,
                customerRecordId,
                 false
              );
            Account shippingSiteAccount = createAccount(
              newAccount,
              defaultAccountOwnerId,
              isAddressSame,
              customerShippingAccount.Id,
              siteRecordId,
              false
            );
          }
      }
    }
    return customerAccount;
  }
  public static Account createAccount(
    Account newAccount,
    String defaultAccountOwnerId,
    Boolean isAddressSame,
    String parentId,
    String recordTypeId, 
    Boolean createBillingHeirarchy
  ) {
    Account accountInfo = new Account();
    if (isAddressSame) {
      accountInfo.BillingCountryCode = newAccount.BillingCountry;
      accountInfo.BillingStateCode = newAccount.BillingState;
      accountInfo.BillingCountry = null;
      accountInfo.BillingState = null;
      accountInfo.BillingStreet = newAccount.BillingStreet;
      accountInfo.BillingCity = newAccount.BillingCity;
      accountInfo.BillingPostalCode = newAccount.BillingPostalCode;
    } else {
        if(createBillingHeirarchy){
            accountInfo.BillingCountryCode = newAccount.BillingCountry;
            accountInfo.BillingStateCode = newAccount.BillingState;
            accountInfo.BillingCountry = null;
            accountInfo.BillingState = null;
            accountInfo.BillingStreet = newAccount.BillingStreet;
            accountInfo.BillingCity = newAccount.BillingCity;
            accountInfo.BillingPostalCode = newAccount.BillingPostalCode;
        }else{
          accountInfo.BillingCountryCode = newAccount.ShippingCountry;
          accountInfo.BillingStateCode = newAccount.ShippingState;
          accountInfo.BillingCountry = null;
          accountInfo.BillingState = null;
          accountInfo.BillingStreet = newAccount.ShippingStreet;
          accountInfo.BillingCity = newAccount.ShippingCity;
          accountInfo.BillingPostalCode = newAccount.ShippingPostalCode;
        }
    }

    accountInfo.ShippingCountryCode = newAccount.ShippingCountry;
    accountInfo.ShippingStateCode = newAccount.ShippingState;
    accountInfo.ShippingCountry = null;
    accountInfo.ShippingState = null;
    accountInfo.ShippingStreet = newAccount.ShippingStreet;
    accountInfo.ShippingCity = newAccount.ShippingCity;
    accountInfo.ShippingPostalCode = newAccount.ShippingPostalCode;

    accountInfo.OwnerId = defaultAccountOwnerId;
    accountInfo.Name = newAccount.Name;
    accountInfo.Phone = newAccount.Phone;
    accountInfo.RecordTypeId = recordTypeId;
    accountInfo.PO_Allowed__c = false;
    accountInfo.AccountSource = 'eCommerce';  
    accountInfo.Region__c = 'Americas';
    if (String.isNotBlank(parentId)) {
      accountInfo.ParentId = parentId;
    }
    if (!isAddressSame) {
      accountInfo.ccrz__TaxExemptAccount__c = newAccount.ccrz__TaxExemptAccount__c;
      accountInfo.ccrz__E_AccountGroup__c = newAccount.ccrz__E_AccountGroup__c;
      accountInfo.Type = 'End User';
      accountInfo.Ergotron_Vertical_Market__c = 'Consumer';
    }
    insert accountInfo;
    return accountInfo;
  }
  private static List<RecordType> getAccountRecordTypes() {
    return [
      SELECT id, Name, DeveloperName
      FROM RecordType
      WHERE sObjectType = 'Account'
    ];
  }
}