@isTest 
private class CaseToFileAttachment_Test {

	@isTest
	private static void testCDLToAttachment() {
		
		Case objCase = new Case(Subject='Test Case', SuppliedEmail='me@you.com');
		insert objCase;

		Blob objBlob = Blob.valueOf('TEST TEST TEST');

		// Insert ContentDocument Data
		ContentVersion objCV = new ContentVersion();
		objCV.Title = 'Test Attachment';
		objCV.PathOnClient = 'Test';
		objCV.VersionData = objBlob;
		insert objCV;

		objCV = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];

		ContentDocumentLink objCDL = new ContentDocumentLink();
		objCDL.ContentDocumentId = objCV.ContentDocumentId;
		objCDL.LinkedEntityId = objCase.Id;
		objCDL.ShareType = 'V';
		insert objCDL;

	}
}