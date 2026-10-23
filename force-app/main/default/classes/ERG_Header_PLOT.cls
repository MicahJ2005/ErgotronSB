public class ERG_Header_PLOT {

	public Boolean isGuest{get; private set;}
    public Boolean isCSR{get; private set;}
	public String  portalUser{get; private set;}
	public Integer lenportalUser{get; private set;}
	    
    public string theOrderType;
    public string  gettheOrderType(){
      	return theOrderType;
    }
    public string thePriceList;
    public string  getthePriceList(){
      	return thePriceList;
    }
     
   	public ERG_Header_PLOT(){
        
        try {

            isCSR = ccrz.cc_CallContext.isOnBehalf;
            isGuest = ccrz.cc_CallContext.isGuest;
            
            portalUser = ApexPages.currentPage().getParameters().get('portalUser');
            if(portalUser == '' )
            {
                lenportalUser = 0;  
                isCSR = false;
            }
            else
            {
                lenportalUser = portalUser.length();
                isCSR = true;
                
            }

        } catch (Exception e) 
        {
                lenportalUser = 0;  
                isCSR = false;
        } finally 
        {
            ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'M:X', 'ERG_ctrl_ReviewCart:sendOrderToCustomer');
        }
        
        
        
        
        
        
        theOrderType = 'Undefined';
		thePriceList = 'Undefined';

        if(ccrz.cc_CallContext.currCartId == NULL )
        {
            theOrderType = 'Undefined';
            thePriceList = 'Undefined';
        }
        else
        {   
		List<ccrz__E_Cart__c> listCart = [SELECT priceListOverride__c, Ergotron_Order_Type__c FROM ccrz__E_Cart__c WHERE ccrz__EncryptedId__c =:ccrz.cc_CallContext.currCartId];

       
        
  //     string tmp;
   //     tmp = ccrz.cc_CallContext.currCartId;
    // /   ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'debug__ CC_ERG_ctrl_PDP: '+tmp);
     //   ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'debug__ CC_ERG_ctrl_PDP: SELECT Ergotron_Order_Type__c FROM ccrz__E_Cart__c WHERE ccrz__EncryptedId__c =:ccrz.cc_CallContext.currCartId');
  
        string theOrderType_id = '';
		string thePriceList_id = '';
        
        if(listCart.size()>0){
            for(ccrz__E_Cart__c theCart : listCart){
                theOrderType_id = theCart.Ergotron_Order_Type__c;
                thePriceList_id = theCart.priceListOverride__c;
            }
        }else{
            theOrderType_id = '';
			thePriceList_id = '';         
        }

        theOrderType = 'Undefined';
		thePriceList = 'Undefined';
        
//        ID anID;
    
//        anID = theOrderType_id;
        
// Ordertype = 2865 Pricelist = a5v4F0000001EDaQAM        
//            List<Oracle_Order_Type__c> orderTypes = [SELECT Name FROM Oracle_Order_Type__c WHERE Order_Type_id__c ='2865' ];

        Oracle_Order_Type__c theOrderTypeDetails = new Oracle_Order_Type__c(); 
 		theOrderTypeDetails = [SELECT Name FROM Oracle_Order_Type__c WHERE Order_Type_id__c =:theOrderType_id];

        //        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'debug__ CC_ERG_ctrl_PDP: SELECT Name FROM Oracle_Order_Type__c WHERE Order_Type_id__c =\''+theOrderType_id+'\'');
//List has no rows for assignment to SObject
// An unexpected error has occurred. Your development organization has been notified.
//                
        
 		  //
  		theOrderType = theOrderTypeDetails.Name;
    
// ccrz__E_PriceList__c        
//            List<ccrz__E_PriceList__c> priceLists = [SELECT Name FROM ccrz__E_PriceList__c WHERE ID ='a5v4F0000001EDaQAM' ];
        
        ccrz__E_PriceList__c thePriceListDetails = new ccrz__E_PriceList__c(); 
        
 		thePriceListDetails = [SELECT Name FROM ccrz__E_PriceList__c WHERE ID =:thePriceList_id];
  		thePriceList = thePriceListDetails.Name;
    }
    
    }     

}