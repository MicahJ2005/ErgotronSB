global without sharing class ccErgoLogicCartCreate extends ccrz.ccLogicCartCreate{
    global override Map<String,Object> process(Map<String,Object> inputData){
        ID caseID = ccrz.cc_CallContext.currPageParameters.get('CaseID'); // we will use this in production once the "buy stuff builder" is done.
		/*// TESTING - REMOVE BEFORE PUTTING INTO PRODUCTION!
        if(String.isBlank(caseID)){
	        caseId = '5001M00001PuFnoQAF'; // closed case for Westchester Medical Center from 9/18. 
        } // END TESTING CODE
        */
        Map<String,Object> outputData = super.process(inputData); // call the super to create the cart!
        // Grab all the information that we need for the case.
        // Note, we may not need to do this if we can do a "relatively" simple change to ccErgoServiceAddressBook.
        if(String.isNotBlank(caseId)){
            Case theCase = [select Id, CC_CartId__C
                              from Case 
                             where Id = :caseId];
            
            //Get the cartId from outputData, update the CC_CartID__c field, and then update the case.
            ID cartId = ID.valueOf(String.valueOf(outputData.get('cartId')));
            theCase.CC_CartId__c = cartId;
            update theCase;
        }else{
            ccrz.ccLog.log(System.LoggingLevel.ERROR, 'ccErgoLogicCartCreate: process: Unable to get the CaseId value from the URL.');
        }
        return outputData;
    }
}