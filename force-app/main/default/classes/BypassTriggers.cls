/**
 * @description : Looks at the Custom Setting ProcessSwitches__c and determines if 
 *                a trigger for an object should be bypassed.
 *
 * @author Matthew J Lennington -- (Demand Chain)
 * @date 2024-11-06
 *
*/
public with sharing class BypassTriggers {
    @InvocableMethod(label='ByPass Object' description='Bypass Flows for an Object' category='Apex')
    public static List<Boolean> flowBypassObject(List<String> objectNames) {
        List<Boolean> result = new List<Boolean>();
        
        ProcessSwitches__c ps = ProcessSwitches__c.getInstance(UserInfo.getUserId());
        Set<String> bypassObject = getBypassObjectSet(ps.Bypass_Objects__c);
        
        for(String objectName : objectNames){
            result.add(bypassObject.contains(objectName.toLowerCase()));
        }
        return result;
    }
    
    
    
    
    
    public static Boolean getBypassTrigger(String objectName) {
        return bypass(objectName);
    }
    public static Boolean bypass(String objectName) {
        //Getting the ProcessSwitches custom setting value that is relevant to our running user
        ProcessSwitches__c ps = ProcessSwitches__c.getInstance(UserInfo.getUserId());

        if (ps.Bypass_All_Triggers__c || getBypassObjectSet(ps.Bypass_Objects__c).contains(objectName.toLowerCase())) {
            return true;
        }

        return false;

    }
    
    public static Boolean bypass() {
        String objectName = trigger.isDelete ? trigger.old.getSObjectType().getDescribe().name.toLowerCase() : trigger.new.getSObjectType().getDescribe().name.toLowerCase();
        return bypass(objectName);
    }

    private static Set<String> getBypassObjectSet(String objectString) {
        //if the user can bypass the trigger, return and do not continue the trigger.
        Set<String> bypassObjects = new Set<String>();

        if(objectString != null){
            bypassObjects.addAll(objectString?.toLowerCase()?.split(';'));
        }

        return bypassObjects;
    }

}