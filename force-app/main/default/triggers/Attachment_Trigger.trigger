trigger Attachment_Trigger on Attachment (after insert)  { 

	// Sunsetted per Carol/Damon 20180711 (AAB / Demand Chain)

	// Clone and redirect any incoming email attachments to be attached to the Case.  Ugh Salesforce, really?
	//Set<Id> setEmailIds = new Set<Id>();
	//Set<Id> setAttachmentIds = new Set<Id>();

	// Determine if we have any Attachments to copy
	//for(Attachment objAtt : Trigger.new) {
		//if(String.valueOf(objAtt.ParentId).substring(0,3) == '02s') {
			//setAttachmentIds.add(objAtt.Id);
			//setEmailIds.add(objAtt.ParentId);
		//}
	//}

	// Send to Processing Method
	//if(!setEmailIds.isEmpty()) {
		//AttachmentMethods.moveEmailToCaseAttachments(setAttachmentIds, setEmailIds);
	//}

	
}