public without sharing class CaseOutboundEmailHandler  {

	@Future
	public static void processCaseEmails(Set<Id> setCaseIds, Boolean isCreate, Boolean testOnly) {
        
        // Hold Ghost Contact Container
        List<Contact> lstDeleteContact = new List<Contact>();

		// Pull Case Information
		Map<Id, Case> mapCases = new Map<Id, Case>([
			SELECT 
				Id,
				CaseNumber,
				AccountId,
				ContactId,
				Case_Language__c,
				Contact.Send_Case_Notifications__c,
				ContactEmail,
				SuppliedEmail,
            	SuppliedName,
				Subject
			FROM
				Case
			WHERE
				Id IN :setCaseIds
				AND (ContactEmail != NULL OR SuppliedEmail != NULL)
		]);

		System.debug('CASE IDs PROVIDED');
		System.debug(JSON.serialize(setCaseIds));

		System.debug('CASES BEING PROCESSED');
		System.debug(JSON.serialize(mapCases.values()));

		// Get Rule Set
		List<Case_Outbound_Email_Rule__mdt> lstRulesOnCreate = [SELECT Id, DeveloperName, IsDefault__c, Language__c, RecordType_Name__c, Template_Developer_Name__c FROM Case_Outbound_Email_Rule__mdt WHERE IsActive__c = TRUE AND Use_Case__c = 'On Open' ORDER BY IsDefault__c ASC];
		List<Case_Outbound_Email_Rule__mdt> lstRulesOnClose = [SELECT Id, DeveloperName, IsDefault__c, Language__c, RecordType_Name__c, Template_Developer_Name__c FROM Case_Outbound_Email_Rule__mdt WHERE IsActive__c = TRUE AND Use_Case__c = 'On Close' ORDER BY IsDefault__c ASC];
		if(lstRulesOnCreate.isEmpty() && lstRulesOnClose.isEmpty()) { return; }

		System.debug(JSON.serialize(lstRulesOnCreate));
		System.debug(JSON.serialize(lstRulesOnClose));

		// Create Template DeveloperName to Id map
		Map<String, Id> mapTemplates = new Map<String, Id>();
		for(EmailTemplate objET : [SELECT Id, DeveloperName FROM EmailTemplate WHERE Folder.DeveloperName = 'Case_Automated_Emails' AND IsActive = TRUE]) {
			mapTemplates.put(objET.DeveloperName.toUpperCase(), objET.Id);
		} 

		System.debug(JSON.serialize(mapTemplates));

		// Get Blacklisted Email Addresses
		Set<String> setBlocked = new Set<String>();
		for(Case_Email_Blacklist__c objBL : [SELECT Id, Name FROM Case_Email_Blacklist__c]) {
			setBlocked.add(objBL.Name);
		}

		// Get Organization-Wide Email Address to use
		OrgWideEmailAddress objOWEA = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'customerservice@ergotron.com' LIMIT 1];

		List<Messaging.SingleEmailMessage> lstEmailsToSend = new List<Messaging.SingleEmailMessage>();
		// Loop through cases and determine what to send
		for(Case objCase : mapCases.values()) {

			List<String> lstToAddresses = new List<String>();
			if(String.isNotBlank(objCase.SuppliedEmail)) { lstToAddresses.add(objCase.SuppliedEmail); }
			if(String.isNotBlank(objCase.ContactEmail)) { lstToAddresses.add(objCase.ContactEmail); }

			System.debug('Processing CaseId ' + objCase.Id);
			Messaging.SingleEmailMessage objEmail = new Messaging.SingleEmailMessage();
			objEmail.setSaveAsActivity(false);
			objEmail.setToAddresses(lstToAddresses);
			objEmail.setWhatId(objCase.Id);
			objEmail.setOrgWideEmailAddressId(objOWEA.Id);
            
            // Create Ghost Contact for Email Template if no Contact found
            objEmail.setTargetObjectId(objCase.ContactId);
            if(objCase.ContactEmail == null) {
                Contact objGhostContact = new Contact(Firstname=objCase.SuppliedEmail, LastName=objCase.SuppliedEmail, Email=objCase.SuppliedEmail);
                insert objGhostContact;
            	objEmail.setTargetObjectId(objGhostContact.Id);
                lstDeleteContact.add(objGhostContact);
            }

			Boolean sendEmail = true;

			// Do we have an email address at all?
			if(String.isBlank(objCase.ContactEmail) && String.isBlank(objCase.ContactEmail)) {
				System.debug('CaseOutboundEmailHandler.processCaseEmails EMAIL BLOCKED - There is no email to send to!');
				sendEmail = false;
			}

			// Check for Blacklist
			for(String strBL : setBlocked) {

				if(String.isNotBlank(objCase.ContactEmail)) {
					if(objCase.ContactEmail != null) {
						if(objCase.ContactEmail.contains(strBL)) {
							System.debug('CaseOutboundEmailHandler.processCaseEmails EMAIL BLOCKED - ContactEmail is on Blacklist!  BL = ' + strBL);
							sendEmail = false;
						}
					}
				}

				if(String.isNotBlank(objCase.SuppliedEmail)) {
					if(objCase.SuppliedEmail.contains(strBL)) {
						System.debug('CaseOutboundEmailHandler.processCaseEmails EMAIL BLOCKED - SuppliedEmail is on Blacklist!  BL = ' + strBL);
						sendEmail = false;
					}
				}

			}

			// Check for Auto Responses
			Set<String> setBlockedSubjects = new Set<String>();
			setBlockedSubjects.add('AUTO REPLY');
            setBlockedSubjects.add('AUTO RESPONSE');
            setBlockedSubjects.add('AUTOMATISCH ANTWOORD BERICHT');            
			setBlockedSubjects.add('OUT OF OFFICE');
			setBlockedSubjects.add('OUT OF THE OFFICE');
            setBlockedSubjects.add('OOO');
            setBlockedSubjects.add('ABSENTE');

			System.debug('Checking Subject for Blocked Words - ' + objCase.Subject.toUpperCase());
			for(String strBL : setBlockedSubjects) {
				System.debug('Checking Subject for ' + strBL);
				if(objCase.Subject.toUpperCase().contains(strBL)) {
					System.debug('CaseOutboundEmailHandler.processCaseEmails EMAIL BLOCKED - Subject contains a word on the blacklist!  BL = ' + strBL);
					sendEmail = false;
				}
			}

			// Check if Contact wants emails
			if(String.isNotBlank(objCase.ContactId)) {
				if(!objCase.Contact.Send_Case_Notifications__c) {
					System.debug('CaseOutboundEmailHandler.processCaseEmails EMAIL BLOCKED - Contact is set to NOT send Case Emails!');
					sendEmail = false;
				}
			}

			// Set proper set of rules to fire
			List<Case_Outbound_Email_Rule__mdt> lstScopedRules = new List<Case_Outbound_Email_Rule__mdt>();
			if(isCreate) { lstScopedRules = lstRulesOnCreate; }
			if(!isCreate) { lstScopedRules = lstRulesOnClose; }

			// Record Create (isCreate = TRUE) Use Cases
			if(!lstScopedRules.isEmpty() && sendEmail) {

				Boolean bolMatch = false;

				// Run all Rules
				for(Case_Outbound_Email_Rule__mdt objRule : lstScopedRules) {
					if(!bolMatch) {

						System.debug('Language Check - ' + objCase.Case_Language__c + ' = ' + objRule.Language__c);
						if(objCase.Case_Language__c == objRule.Language__c) {
							System.debug('Looking for Template Name = ' + objRule.Template_Developer_Name__c.toUpperCase());
							System.debug('Setting TemplateId = ' + mapTemplates.get(objRule.Template_Developer_Name__c.toUpperCase()));
							objEmail.setTemplateId(mapTemplates.get(objRule.Template_Developer_Name__c.toUpperCase()));
							bolMatch = true;
						}
					}

					if(!bolMatch && objRule.IsDefault__c) {
						System.debug('Looking for Default Template Name = ' + objRule.Template_Developer_Name__c.toUpperCase());
						System.debug('Setting Default TemplateId = ' + mapTemplates.get(objRule.Template_Developer_Name__c.toUpperCase()));
						objEmail.setTemplateId(mapTemplates.get(objRule.Template_Developer_Name__c.toUpperCase()));
						bolMatch = true;
					}
				}

				// If Match, add to send list
				if(bolMatch) {
					lstEmailsToSend.add(objEmail);
				}
			}
		}

		System.debug('EMAILS READY TO SEND');
		System.debug(JSON.serialize(lstEmailsToSend));

		// Send Emails!
		if(!lstEmailsToSend.isEmpty()) {
			Messaging.sendEmail(lstEmailsToSend);
		}
        
        // Delete Ghost Contacts
        if(!lstDeleteContact.isEmpty()) {
            delete lstDeleteContact;
        }

	}

}