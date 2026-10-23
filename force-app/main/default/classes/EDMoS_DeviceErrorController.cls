global without sharing class EDMoS_DeviceErrorController{

    global EDMoS_DeviceErrorController(){}

    global String caseId { get; set; }
    global List<String> deviceErrorList{ //get; set;}
    //global Case caseObj{
        get{
            System.debug('DC: CaseId passed: '+ caseId);
            if(caseId != null) {
                Case caseObj = [Select Id, CaseNumber, Device_Error__c, Asset_Numbers__c, ThreadId__c from Case where Id=:caseId LIMIT 1];
                if (caseObj != null){
                    String deviceError = caseObj.Device_Error__c;
                    if (deviceError != null || String.isNotBlank(deviceError)){
                        if (deviceError.startsWith('{') && deviceError.endsWith('}')){
                            // its a json string format
                            Map<String, Object> jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(deviceError);
                            deviceErrorList = new List<String>();
                            for(String str: jsonMap.keySet()){
                                deviceErrorList.add(str + ': ' + String.valueOf(jsonMap.get(str)));
                            }
                            
                        }else{
                            deviceErrorList = new List<String>();
                            deviceErrorList.add(deviceError);
                        }
                    }
                }
            }
            return deviceErrorList;
        }
        set;
    }
}