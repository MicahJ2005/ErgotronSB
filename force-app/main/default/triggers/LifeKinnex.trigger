//Trigger to handle platform events not finding an asset in Salesforce
trigger LifeKinnex on LiFeKinnex__e (after insert) {
    
    // List to hold all cases to be created.
    List<Case> cases = new List<Case>();
    
    // Get case record type ID for Product case record type
    Recordtype rcrdTypeId = [select id from recordtype where name = 'Product'];
    // Get queue id for the eKinnex queue to assigne ownership of the case.
    Group queue = [select id from Group where name = 'eKinnex' and type = 'Queue'];

    // Iterate through each notification.
    for (LifeKinnex__e event : Trigger.New) {
        //Create a case for every event without a matching asset
        integer numOfAssets = [select count() from asset where SerialNumber = :event.serial_number__c];
        
        
        if (numOfAssets == 0 || numOfAssets >= 2){
            // Create Case to dispatch new team.
            Case cs = new Case();
            cs.LifeKinnex_SN__c = event.serial_Number__c;
            cs.RecordTypeId = rcrdTypeId.Id;
            cs.Sub_Type__c = 'Device Alert';
            cs.Subject = ' ⚠ An alert message was not able to match an asset. Device SN: ' + 
                event.Serial_Number__c;
            cs.Alert_Email_Address__c = event.service_email__c;
            cs.Alert_Email_Address_2__c = event.service_email_2__c;
            cs.Alert_Email_Address_3__c = event.service_email_3__c;
            cs.Alert_Type__c = event.Type__c;
            cs.Device_Error__c = event.Error_JSON__c;
            cs.Description = 
                'Either no asset records were found or there were multiple assets with this serial number' + '\n' +
                'Device Serial Number: ' + event.Serial_Number__c + '\n' +
                'Device ID: ' + event.Device_ID__c + '\n' +
                'Power Module SN: ' + event.Power_Mod_Serial__c;
            cs.OwnerId = queue.Id;
            cs.Attached_To_Serial_Number__c = event.Attached_To_Serial_Number__c;
            cs.Cycle_Count__c = Event.Cycle_Count__c;
            cs.State_of_Health__c = Event.State_of_Health__c;
            
            cases.add(cs);
        }
    }
    
    // Insert all cases corresponding to events received.
    insert cases;
    
}