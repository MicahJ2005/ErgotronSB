/*
Trigger for Case object.
+ After Insert Logic - For use with the SR Integration, if a case if created by anyone EXCEPT the Oracle Integration user,
create a case comment so Oracle knows who created it.

MOD DATE		Who						Description
20160502		Andy Boettcher			Initial Release
20180607		Andy Boettcher			Adding in Case Email functionality
20180718		Andy Boettcher			Collapsing Case Email class to here to account for Salesforce SYSTEM not being able to deal with classes
20200424        Esau Sanchez            Adding validation here dut to "You have reached the maximum number of 20 object references on Case"
                                        Use Case_Trigger_Test to deploy.
20201111        Esau Sanchez            Added condition for Parner Logo Request
20201202        Esau Sanchez            Email-to-Case auto response - handling regions based on queue (case ownership).
*/

trigger Case_Trigger on Case(after insert, after update) {
   
    if(BypassTriggers.bypass()){
        return;
    }

    if (Trigger.isUpdate) {
        System.debug('DC: BEGIN Trigger.isUpdate');
    }
    if (Trigger.isInsert) {
        System.debug('DC: BEGIN Trigger.isInsert');
    }

    //* Validation - Cannot close case if the CC Cart is open
    if (Trigger.isUpdate) {
        System.debug('case_Trigger Open CC Cart Validation');
        List<Case> caseList = [SELECT CC_CartId__c, CC_CartId__r.ccrz__CartStatus__c, status, isClosed FROM case WHERE id IN :Trigger.new];
        Map<Id, Case> caseMap = Trigger.newMap;
        for (case c : caseList) {
            System.debug('cart Id = ' + c.CC_CartId__c + '  cart status = ' + c.CC_CartId__r.ccrz__CartStatus__c + '  case status = ' + c.Status + '  case closed = ' + c.isClosed);
            if (c.CC_CartId__c != null && c.CC_CartId__r.ccrz__CartStatus__c == 'Open' && c.isClosed) {
                System.debug(
                    'Validation true: cart Id = ' + c.CC_CartId__c + '  cart status = ' + c.CC_CartId__r.ccrz__CartStatus__c + '  case status = ' + c.Status + '  case closed = ' + c.isClosed
                );

                caseMap.get(c.id).CC_CartId__c.adderror('The cart must be closed before the case can be closed.');
            }
        }
    }
    //*/

    // Create SR Comment on initial create populate WO data
    if (Trigger.isInsert && Trigger.isAfter) {
        if (!System.isFuture() && !System.isBatch()) {
            CaseTriggerMethods.PopulateWOData(Trigger.newMap.keySet());
        }
        List<CaseComment> lstComments = new List<CaseComment>();

        for (Case objCase : Trigger.new) {
            if (objCase.CreatedById != '005G0000003r9HE') {
                //Oracle Integration user
                CaseComment objCC = new CaseComment();
                objCC.ParentId = objCase.Id;
                objCC.CommentBody = 'Created By: ' + UserInfo.getName();
                objCC.IsPublished = false;
                lstComments.add(objCC);
            }
        }

        if (!lstComments.isEmpty()) {
            insert lstComments;
        }
    }

    // Close any open entitlements and populate Case WO Data from ICRT
    if (Trigger.isUpdate && Trigger.isAfter) {
        CaseTriggerMethods.CloseOpenEntitlements(Trigger.new, Trigger.oldMap);
        if (!System.isFuture() && !System.isBatch()) {
            CaseTriggerMethods.PopulateWOData(Trigger.newMap.keySet());
        }


        /**
         * @description : Enovate Merge Code
         *
         * @author Matthew J Lennington -- (Demand Chain)
         * @date 2025-01-07
         *
        */
        // if(CaseTriggerHandler.isCaseTriggerExecuted == false) {
          
        //CaseTriggerHandler.isCaseTriggerExecuted = true;
        CaseTriggerMethods.createServiceAppointments(Trigger.new, Trigger.oldMap);                
        //}    
    }

    // Handle any email notifications
    if ((Trigger.isInsert || Trigger.isUpdate) && !System.isFuture() && !System.isBatch()) {
        // Case Open
        //if(Trigger.isInsert) {
        //CaseOutboundEmailHandler.processCaseEmails(trigger.newMap.keySet(), true, true);

        //}

        // Case Close
        if (Trigger.isUpdate || Trigger.isInsert) {
            Set<Id> setClosedCases = new Set<Id>();

            if (Trigger.isInsert) {
                setClosedCases = Trigger.newMap.keySet();
            }

            if (Trigger.isUpdate) {
                for (Case objCase : Trigger.new) {
                    if (objCase.IsClosed && (!Trigger.oldMap.get(objCase.Id).IsClosed)) {
                        setClosedCases.add(objCase.Id);
                    }
                }
            }

            if (!setClosedCases.isEmpty()) {
                //CaseOutboundEmailHandler.processCaseEmails(setClosedCases, false, true);

                ////////////////////////////////////////////
                // PUTTING CLASS LOGIC HERE BECAUSE SALESFORCE SYSTEM USER CANNOT ACCESS CLASSES!?!
                ////////////////////////////////////////////

                // Hold Ghost Contact Container
                List<Contact> lstDeleteContact = new List<Contact>();

                // Pull Case Information
                Map<Id, Case> mapCases = new Map<Id, Case>(
                    [
                        SELECT
                            Id,
                            recordtype.name,
                            CaseNumber,
                            AccountId,
                            ContactId,
                            Case_Language__c,
                            Contact.Send_Case_Notifications__c,
                            ContactEmail,
                            Contact.Region__c,
                            CreatedBy.Profile.Name,
                            CreatedById,
                            SuppliedEmail,
                            SuppliedName,
                            Subject,
                            IsClosed,
                            Owner.name
                        FROM Case
                        WHERE Id IN :setClosedCases AND (ContactEmail != NULL OR SuppliedEmail != NULL)
                    ]
                );

                System.debug('CASE IDs PROVIDED');
                System.debug(JSON.serialize(setClosedCases));

                System.debug('CASES BEING PROCESSED');
                System.debug(JSON.serialize(mapCases.values()));

                // Get Rule Set
                List<Case_Outbound_Email_Rule__mdt> lstRulesOnCreate = [
                    SELECT Id, DeveloperName, IsDefault__c, Language__c, RecordType_Name__c, Template_Developer_Name__c, Region__c, Queue_Name__c, FromAddress__c
                    FROM Case_Outbound_Email_Rule__mdt
                    WHERE IsActive__c = TRUE AND Use_Case__c = 'On Open'
                    ORDER BY IsDefault__c ASC
                ];
                List<Case_Outbound_Email_Rule__mdt> lstRulesOnClose = [
                    SELECT Id, DeveloperName, IsDefault__c, Language__c, RecordType_Name__c, Template_Developer_Name__c, Region__c, Queue_Name__c, FromAddress__c
                    FROM Case_Outbound_Email_Rule__mdt
                    WHERE IsActive__c = TRUE AND Use_Case__c = 'On Close'
                    ORDER BY IsDefault__c ASC
                ];
                if (lstRulesOnCreate.isEmpty() && lstRulesOnClose.isEmpty()) {
                    return;
                } //No email rules - we're done!

                System.debug(JSON.serialize(lstRulesOnCreate));
                System.debug(JSON.serialize(lstRulesOnClose));

                // Create Template DeveloperName to Id map
                Map<String, Id> mapTemplates = new Map<String, Id>();
                for (EmailTemplate objET : [SELECT Id, DeveloperName FROM EmailTemplate WHERE Folder.DeveloperName = 'Case_Automated_Emails' AND IsActive = TRUE]) {
                    mapTemplates.put(objET.DeveloperName.toUpperCase(), objET.Id);
                }

                System.debug(JSON.serialize(mapTemplates));

                // Get Blacklisted Email Addresses
                Set<String> setBlocked = new Set<String>();
                for (Case_Email_Blacklist__c objBL : [SELECT Id, Name FROM Case_Email_Blacklist__c]) {
                    setBlocked.add(objBL.Name);
                }

                // Get Organization-Wide Email Addresses to use
                Map<String, Id> mapFromAddresses = new Map<String, Id>();
                for (OrgWideEmailAddress objOWEA : [SELECT Id, Address FROM OrgWideEmailAddress]) {
                    mapFromAddresses.put(objOWEA.Address.toUpperCase(), objOWEA.Id);
                }

                List<Messaging.SingleEmailMessage> lstEmailsToSend = new List<Messaging.SingleEmailMessage>();
                // Loop through cases and determine what to send
                for (Case objCase : mapCases.values()) {
                    List<String> lstToAddresses = new List<String>();
                    if (String.isNotBlank(objCase.SuppliedEmail)) {
                        lstToAddresses.add(objCase.SuppliedEmail);
                    }
                    if (String.isNotBlank(objCase.ContactEmail)) {
                        lstToAddresses.add(objCase.ContactEmail);
                    }

                    System.debug('Processing CaseId ' + objCase.Id);
                    Messaging.SingleEmailMessage objEmail = new Messaging.SingleEmailMessage();
                    objEmail.setSaveAsActivity(false);
                    objEmail.setToAddresses(lstToAddresses);
                    objEmail.setWhatId(objCase.Id);

                    // Create Ghost Contact for Email Template if no Contact found
                    objEmail.setTargetObjectId(objCase.ContactId);
                    if (objCase.ContactEmail == null) {
                        String strGhostContactTempName = objCase.SuppliedEmail;
                        strGhostContactTempName = strGhostContactTempName.left(40);
                        Contact objGhostContact = new Contact(Firstname = strGhostContactTempName, LastName = strGhostContactTempName, Email = objCase.SuppliedEmail);
                        insert objGhostContact;
                        objEmail.setTargetObjectId(objGhostContact.Id);
                        lstDeleteContact.add(objGhostContact);
                    }

                    Boolean sendEmail = true;

                    //*/Do not send it if it is a logo access request

                    if (objCase.recordtype.name == 'Information' && objCase.Subject == 'Partner Logo Request' && objCase.CreatedBy.Profile.Name == 'Ergotron Public Community Profile') {
                        System.debug('Partner Logo Request - no auto response');
                        sendEmail = false;
                    }
                    //*/

                    //*Is it Data Privacy Request?
                    if (objCase.recordtype.name == 'Data Privacy Request') {
                        System.debug('Data Privacy Request - no auto response');
                        sendEmail = false;
                    }
                    //*/

                    // Do we have an email address at all?
                    if (String.isBlank(objCase.ContactEmail) && String.isBlank(objCase.SuppliedEmail)) {
                        System.debug('CaseOutboundEmailHandler.processCaseEmails EMAIL BLOCKED - There is no email to send to!');
                        sendEmail = false;
                    }

                    // Check for Blacklist
                    for (String strBL : setBlocked) {
                        if (String.isNotBlank(objCase.ContactEmail)) {
                            if (objCase.ContactEmail.contains(strBL)) {
                                System.debug('CaseOutboundEmailHandler.processCaseEmails EMAIL BLOCKED - ContactEmail is on Blacklist!  BL = ' + strBL);
                                sendEmail = false;
                            }
                        }

                        if (String.isNotBlank(objCase.SuppliedEmail)) {
                            if (objCase.SuppliedEmail.contains(strBL)) {
                                System.debug('CaseOutboundEmailHandler.processCaseEmails EMAIL BLOCKED - SuppliedEmail is on Blacklist!  BL = ' + strBL);
                                sendEmail = false;
                            }
                        }
                    }

                    if (String.isNotBlank(objCase.Subject)) {
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
                        for (String strBL : setBlockedSubjects) {
                            System.debug('Checking Subject for ' + strBL);
                            if (objCase.Subject.toUpperCase().contains(strBL)) {
                                System.debug('CaseOutboundEmailHandler.processCaseEmails EMAIL BLOCKED - Subject contains a word on the blacklist!  BL = ' + strBL);
                                sendEmail = false;
                            }
                        }
                    }

                    // Check if Contact wants emails
                    if (String.isNotBlank(objCase.ContactId)) {
                        if (!objCase.Contact.Send_Case_Notifications__c) {
                            System.debug('CaseOutboundEmailHandler.processCaseEmails EMAIL BLOCKED - Contact is set to NOT send Case Emails!');
                            sendEmail = false;
                        }
                    }

                    // Set proper set of rules to fire
                    List<Case_Outbound_Email_Rule__mdt> lstScopedRules = new List<Case_Outbound_Email_Rule__mdt>();
                    //if(isCreate) { lstScopedRules = lstRulesOnCreate; }
                    //if(!isCreate) { lstScopedRules = lstRulesOnClose; }
                    if (Trigger.isInsert) {
                        System.debug('ADDING ON OPEN RULE SET');
                        System.debug(JSON.serialize(lstRulesOnCreate));
                        lstScopedRules = lstRulesOnCreate;
                    }
                    if (Trigger.isUpdate) {
                        System.debug('ADDING ON CLOSE RULE SET');
                        System.debug(JSON.serialize(lstRulesOnClose));
                        lstScopedRules = lstRulesOnClose;
                    }

                    System.debug('Entering final email spin - sendEmail flag = ' + sendEmail);

                    // Record Create (isCreate = TRUE) Use Cases
                    if (!lstScopedRules.isEmpty() && sendEmail) {
                        Boolean bolMatch = false;

                        // Run all Rules -  Email Template Assignment
                        for (Case_Outbound_Email_Rule__mdt objRule : lstScopedRules) {
                            if (!bolMatch) {
                                //match on language and region for cases created in house
                                if (
                                    !String.isBlank(objCase.Case_Language__c) &&
                                    !String.isBlank(objCase.Contact.Region__c) &&
                                    objCase.Case_Language__c == objRule.Language__c &&
                                    objCase.Contact.Region__c == objRule.Region__c
                                ) {
                                    System.debug('lang & region match' + objRule.Language__c + ' ' + objRule.Region__c);
                                    objEmail.setTemplateId(mapTemplates.get(objRule.Template_Developer_Name__c.toUpperCase()));
                                    objEmail.setOrgWideEmailAddressId(mapFromAddresses.get(objRule.FromAddress__c.toUpperCase()));
                                    bolMatch = true;
                                    //match on case owner(queue) for email-to-case cases
                                } else if (!String.isBlank(objCase.Owner.Name) && objCase.Owner.name == objRule.Queue_Name__c) {
                                    System.debug('owner match ' + objCase.Owner.Name);
                                    objEmail.setTemplateId(mapTemplates.get(objRule.Template_Developer_Name__c.toUpperCase()));
                                    objEmail.setOrgWideEmailAddressId(mapFromAddresses.get(objRule.FromAddress__c.toUpperCase()));
                                    bolMatch = true;
                                }
                            }
                            //if no match, use the default
                            if (!bolMatch && objRule.IsDefault__c) {
                                System.debug('Looking for Default Template Name = ' + objRule.Template_Developer_Name__c.toUpperCase());
                                System.debug('Setting Default TemplateId = ' + mapTemplates.get(objRule.Template_Developer_Name__c.toUpperCase()));
                                objEmail.setTemplateId(mapTemplates.get(objRule.Template_Developer_Name__c.toUpperCase()));
                                objEmail.setOrgWideEmailAddressId(mapFromAddresses.get(objRule.FromAddress__c.toUpperCase()));
                                bolMatch = true;
                            }
                        }

                        // If Match, add to send list
                        if (bolMatch) {
                            lstEmailsToSend.add(objEmail);
                        }
                    }
                }

                System.debug('EMAILS READY TO SEND');
                System.debug(JSON.serialize(lstEmailsToSend));

                // Send Emails!
                try {
                    if (!lstEmailsToSend.isEmpty()) {
                        Messaging.sendEmail(lstEmailsToSend);
                    }
                } catch (Exception ex) {
                    System.debug(String.valueOf(ex));
                }

                // Delete Ghost Contacts
                if (!lstDeleteContact.isEmpty()) {
                    delete lstDeleteContact;
                }
            }
        }
    }

    if (Trigger.isUpdate) {
        System.debug('DC: END Trigger.isUpdate');
    }
    if (Trigger.isInsert) {
        System.debug('DC: END Trigger.isInsert');
    }

}