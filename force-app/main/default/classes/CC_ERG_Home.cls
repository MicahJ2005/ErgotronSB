global class CC_ERG_Home {
 
   public string AllProductsCatID;
    public string  getAllProductsCatID(){
        
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'CC_ERG_ctrl_ReviewCart:AllProductsCatID');
        
         String thisAllProductsCatID = 'a5E4F0000004en0UAA';
// select ID, ccrz__CategoryID__c from ccrz__E_Category__c where name='All Products'
        
        ccrz__E_Category__c theCatagoriesDetails = new ccrz__E_Category__c(); 
        
        theCatagoriesDetails = [SELECT ID, ccrz__CategoryID__c from ccrz__E_Category__c where name='All Products'];
        thisAllProductsCatID = theCatagoriesDetails.ID;        
        
        
        
   /*   
        //String currURL = ccrz.cc_callContext.currURL;
        //String currURL = ccrz.ccAPISiteIndex.FULL_URL;
 
        String currURL = URL.getSalesforceBaseUrl().toExternalForm();
        
        
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'ERG_ctrl_ReviewCart:getjumpToServer currURL='+currURL);
        
        
        ccrz__E_Configuration__c custom_configs_serverurlbase =[SELECT Name, ccrz__ConfigurationMeta__r.name, ccrz__TextValue__c FROM ccrz__E_Configuration__c where ccrz__ConfigurationMeta__r.name = 'Server URL']; 
        String serverurlbase =  custom_configs_serverurlbase.ccrz__TextValue__c;


        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:E', 'ERG_ctrl_ReviewCart:getjumpToServer serverurlbase='+serverurlbase);

        
//         jumpToServer = 'does this work';
         jumpToServer = serverurlbase;
*/
        return thisAllProductsCatID;
    }
    
  

}