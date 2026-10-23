/*
    Controller class for the Attachment Triggers

    MOD DATE        Who                     Description
    20180620		Andy Boettcher			Created
	20180711		Andy Boettcher			Sunsetted per Carol/Damon
*/

public class AttachmentMethods  {

	/**************************
	This method takes any Attachments sent via EmailToCase and copies that Attachment to the Case
	so that the Informatica process can push them to Oracle to populate the NCR.  (yes...)

	**************************/
	//@Future
	//public static void moveEmailToCaseAttachments(Set<Id> setAttachmentIds, Set<Id> setEmailIds) {

		//List<Attachment> lstAttToCopy = new List<Attachment>();
		//Map<Id, Id> mapEmailToCase = new Map<Id, Id>();
		
		//// Determine if a Case is attached and populate Map
		//for(EmailMessage objEM : [SELECT Id, RelatedToId FROM EmailMessage WHERE Id IN :setEmailIds]) {
			//if(String.valueOf(objEM.RelatedToId).substring(0,3) == '500') {
				//mapEmailToCase.put(objEM.Id, objEM.RelatedToId);
			//}
		//}

		//// Get List of Attachments and start cloning
		//for(Attachment objAtt : [SELECT Id, Body, BodyLength, ContentType, Description, IsPrivate, Name, ParentId FROM Attachment WHERE Id IN :setAttachmentIds]) {
			//Attachment objClone = objAtt.clone(false);
			//objClone.ParentId = mapEmailToCase.get(objAtt.ParentId);
			//lstAttToCopy.add(objClone);
		//}
		
		//// Insert
		//if(!lstAttToCopy.isEmpty()) {
			//insert lstAttToCopy;
		//}
	//}

}