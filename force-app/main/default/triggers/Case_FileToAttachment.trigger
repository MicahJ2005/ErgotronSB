trigger Case_FileToAttachment on ContentDocumentLink (after insert) {

	// This trigger takes the newly created ContentDocumentLink and shadows it over to Attachments on Cases
	// so Informatica can pick them up as it did with native Classic Attachments...

	Map<Id, Id> mapCDsToMove = new Map<Id, Id>();

	for(ContentDocumentLink objCDL : trigger.new) {
		if(String.valueOf(objCDL.LinkedEntityId).substring(0,3) == '500') {
			mapCDsToMove.put(objCDL.ContentDocumentId, objCDL.LinkedEntityId);
		}
	}

	List<Attachment> lstAttachmentInsert = new List<Attachment>();
	Map<String, String> mapContentTypes = UtilityMethods.MAP_CONTENTTYPES();

	for(ContentVersion objCV : [SELECT Id, ContentDocumentId, VersionData, Title, FileExtension FROM ContentVersion WHERE ContentDocumentId IN :mapCDsToMove.keyset() AND IsLatest = TRUE]) {
		
		String strContentType = mapContentTypes.get('txt');
		if(!mapContentTypes.containsKey(objCV.FileExtension)) {
			strContentType = mapContentTypes.get(objCV.FileExtension);
		}

		lstAttachmentInsert.add(
			new Attachment(
				ParentId = mapCDsToMove.get(objCV.ContentDocumentId),
				Name = objCV.Title + '.' + objCV.FileExtension,
				Body = objCV.VersionData,
				ContentType = strContentType
			)
		);
	}

	if(!lstAttachmentInsert.isEmpty()) {
		insert lstAttachmentInsert;
	}

}