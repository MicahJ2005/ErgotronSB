//For deployment, the ccErg_trigger_CartDelete_TEST can be used.

trigger ccErg_trigger_CartDelete on ccrz__E_Cart__c (before delete) {
    //When a cart is deleted, a comment needs to be made on the Case where cc_CartId = thisCart.
    for(ccrz__E_Cart__c theCart : Trigger.old){
        
		try{
			Case theCase = [SELECT Id, CC_CartId__c, sub_status__c FROM Case WHERE CC_CartId__c = :theCart.Id];
			Map<Id, CaseComment> caseMap = new Map<Id,CaseComment>();
			CaseComment c = new CaseComment();        
			c.CommentBody = 'Cart: '+theCart.Name+'\nID: '+theCart.Id+'\n Cart was deleted.\n\nCART ITEMS:';
			
			// loop for cart items
			for(ccrz__E_CartItem__c cartItems : [SELECT ccrz__Quantity__c, ccrz__Product__r.ccrz__SKU__c, ccrz__Product__r.Name
												 FROM ccrz__E_CartItem__c
												 WHERE ccrz__Cart__c = :theCase.CC_CartId__c]) {
				c.CommentBody += '\nSKU:'+cartItems.ccrz__Product__r.ccrz__SKU__c
							  + '; ProdName: '+cartItems.ccrz__Product__r.Name
							  + '; Qty: '+cartItems.ccrz__Quantity__c+'.';
													 
			}

			c.IsPublished = true;
			c.ParentId = theCase.Id;
			insert c;

			//*/Clear case sub-status if it was 'Pending Open Cart'  -  Esau Sanchez 20200730
			if (theCase.sub_status__c == 'Pending Open Cart'){
				theCase.sub_status__c = null;
				update theCase;
			}
			//* End 20200730 change
			
			
		}
		catch(Exception e){
			ccrz.ccLog.log(System.LoggingLevel.ERROR, 'Cart '+theCart.Id+' was deleted but there was no link to a case.');
		}

	}
}