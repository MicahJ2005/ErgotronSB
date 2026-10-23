Global class CC_ERG_Update_Cart_Item_Location {

    public void updateCartItemLocation(string cartIteamID, string location) {
            ccrz__E_CartItem__c theCartItem  = [select ergo_wh_location__c from ccrz__E_CartItem__c where id =:cartIteamID ];
       
            theCartItem.ergo_wh_location__c=location;
            update theCartItem;    
         
            return;        
    }   

 
}