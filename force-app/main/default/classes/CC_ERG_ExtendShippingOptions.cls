/* Class for extending shipping methods*/
global without sharing class CC_ERG_ExtendShippingOptions extends ccrz.cc_api_ShippingAndHandling{
 
    //Method for fetching the shipping options with amount
    global override List<ccrz.cc_ctrl_hlpr_ShippingOption> getShippingOptions(String zipCode, String stateCode, String countryCode, Id cartId, String storeName) {
        return getShippingRatelist(cartId, stateCode);
    }
    
    //Method to get the shipping rate and calculate it as per quantity
    public  List<ccrz.cc_ctrl_hlpr_ShippingOption>  getShippingRatelist(string cartId,String stateCode){
        integer totalQuantity=1;
        integer totalAmount = 0;
        integer nextDtotalAmount = 0;
        integer twoDtotalAmount = 0;
        integer threeDtotalAmount = 0;
        integer groundAmount = 0;
        String groundshipperName = '';
        String nextDayshipperName = '';
        String twoDayshipperName = '';
        String threeDayshipperName = '';
        String groundName = '';
        String nextDayName = '';
        String twoDayName = '';
        String threeDayName = '';
        Boolean noProdWeight = false;
        // get the total quantity of the cart
        for(ccrz__E_Cart__c quantity :[Select id,ccrz__TotalQuantity__c FROM ccrz__E_Cart__c 
                                       WHERE id=: cartId LIMIT 1]){
                                           totalQuantity =  Integer.valueOf(quantity.ccrz__TotalQuantity__c);      
                                       }
        
        List<ccrz.cc_ctrl_hlpr_ShippingOption> shippingOptions = new List<ccrz.cc_ctrl_hlpr_ShippingOption>();
        
        // get the list of shipping rates 
        List<ccrz__E_ShippingRate__c> listOfShippingRates= [SELECT Id, Name, ccrz__MinWeight__c, ccrz__MaxWeight__c, 
                                                            ccrz__Storefront__c, ccrz__ShippingRate__c, ccrz__Shipper__c,
                                                            Erg_StateIsoCode__c
                                                            FROM ccrz__E_ShippingRate__c order by ccrz__sequence__c];
        
        if(stateCode == 'Ak' || stateCode =='HI'){
            for(ccrz__E_ShippingRate__c shippingRate : listOfShippingRates)
            {
                if(shippingRate.Erg_StateIsoCode__c == stateCode){
                    for(ccrz__E_CartItem__c cartItems : [SELECT Id, Name, ccrz__Cart__c, ccrz__Quantity__c, ccrz__Product__c, ccrz__Product__r.ccrz__ShippingWeight__c,
                    ccrz__Cart__r.ccrz__SubtotalAmount__c, ccrz__Product__r.ccrz__ProductWeight__c FROM ccrz__E_CartItem__c where ccrz__Cart__c =: cartId])
                    {
                        if(shippingRate?.ccrz__MaxWeight__c <=  Decimal.ValueOf(Label.B2B_10) && shippingRate?.ccrz__MinWeight__c == Decimal.ValueOf(Label.B2B_0)
                            && cartItems.ccrz__Product__r.ccrz__ShippingWeight__c > Decimal.ValueOf(Label.B2B_0) && cartItems.ccrz__Product__r.ccrz__ShippingWeight__c <= Decimal.ValueOf(Label.B2B_10))
                        {
                            shippingOptions.add(new ccrz.cc_ctrl_hlpr_ShippingOption(shippingRate.ccrz__Shipper__c, shippingRate.Name,shippingRate.ccrz__ShippingRate__c));
                        }
                        else if(shippingRate?.ccrz__MaxWeight__c <=  Decimal.ValueOf(Label.B2B_35) && shippingRate?.ccrz__MinWeight__c ==  Decimal.ValueOf(Label.B2B_10)
                            && cartItems.ccrz__Product__r.ccrz__ShippingWeight__c > Decimal.ValueOf(Label.B2B_10) && cartItems.ccrz__Product__r.ccrz__ShippingWeight__c <= Decimal.ValueOf(Label.B2B_35))
                        {
                            shippingOptions.add(new ccrz.cc_ctrl_hlpr_ShippingOption(shippingRate.ccrz__Shipper__c, shippingRate.Name,shippingRate.ccrz__ShippingRate__c));
                        }
                        else if(shippingRate?.ccrz__MaxWeight__c <=  Decimal.ValueOf(Label.B2B_50) && shippingRate?.ccrz__MinWeight__c ==  Decimal.ValueOf(Label.B2B_35)
                        && cartItems.ccrz__Product__r.ccrz__ShippingWeight__c > Decimal.ValueOf(Label.B2B_35) && cartItems.ccrz__Product__r.ccrz__ShippingWeight__c <= Decimal.ValueOf(Label.B2B_50))
                        {
                            shippingOptions.add(new ccrz.cc_ctrl_hlpr_ShippingOption(shippingRate.ccrz__Shipper__c, shippingRate.Name,shippingRate.ccrz__ShippingRate__c));
                        }
                        else if(shippingRate?.ccrz__MaxWeight__c >  Decimal.ValueOf(Label.B2B_50) && shippingRate?.ccrz__MinWeight__c ==  Decimal.ValueOf(Label.B2B_50)
                        && cartItems.ccrz__Product__r.ccrz__ShippingWeight__c > Decimal.ValueOf(Label.B2B_50) )
                        {
                            shippingOptions.add(new ccrz.cc_ctrl_hlpr_ShippingOption(shippingRate.ccrz__Shipper__c, shippingRate.Name,shippingRate.ccrz__ShippingRate__c));
                        }    
                    }
                }
            }
        }else{
            
                for(ccrz__E_ShippingRate__c shippingRate : listOfShippingRates){
                    if(String.isBlank(shippingRate.Erg_StateIsoCode__c))
                    {
                        if(shippingRate.Name.contains('GROUND')){
                            groundshipperName = shippingRate.ccrz__Shipper__c;
                            groundName = shippingRate.Name;
                        }
                        else if(shippingRate.Name.contains('Next Day Air')){
                            nextDayshipperName= shippingRate.ccrz__Shipper__c;
                            nextDayName = shippingRate.Name;
                        }
                        else if(shippingRate.Name.contains('2 Day Air')){
                            twoDayshipperName = shippingRate.ccrz__Shipper__c;
                            twoDayName = shippingRate.Name;
                        }
                        else if(shippingRate.Name.contains('3 Day Select')){
                            threeDayshipperName = shippingRate.ccrz__Shipper__c;
                            threeDayName = shippingRate.Name;
                        }
                    }
                
                    for(ccrz__E_CartItem__c cartItems : [SELECT Id, Name, ccrz__Cart__c, ccrz__Quantity__c, ccrz__Product__c, ccrz__Product__r.ccrz__ShippingWeight__c,
                    ccrz__Cart__r.ccrz__SubtotalAmount__c, ccrz__Product__r.ccrz__ProductWeight__c FROM ccrz__E_CartItem__c where ccrz__Cart__c =: cartId]){
                            if(cartItems.ccrz__Product__r.ccrz__ShippingWeight__c == Decimal.ValueOf(Label.B2B_0) || 
                            cartItems.ccrz__Product__r.ccrz__ShippingWeight__c == null ){
                                noProdWeight = true;
                                break;
                            }
                            if(shippingRate?.ccrz__MaxWeight__c <=  Decimal.ValueOf(Label.B2B_10) && shippingRate?.ccrz__MinWeight__c == Decimal.ValueOf(Label.B2B_0) && 
                            shippingRate.Name.contains('GROUND') && cartItems.ccrz__Cart__r.ccrz__SubtotalAmount__c < Decimal.valueOf(Label.B2B_Ground_Limit)){
                                groundAmount = Integer.valueOf(shippingRate.ccrz__ShippingRate__c);
                            }
                            if(shippingRate?.ccrz__MaxWeight__c <=  Decimal.ValueOf(Label.B2B_10) && shippingRate?.ccrz__MinWeight__c == Decimal.ValueOf(Label.B2B_0)
                                 && cartItems.ccrz__Product__r.ccrz__ShippingWeight__c > Decimal.ValueOf(Label.B2B_0) && cartItems.ccrz__Product__r.ccrz__ShippingWeight__c <= Decimal.ValueOf(Label.B2B_10)
                            ){
                            system.debug('IN 1 : ');
                            if(shippingRate.Name.contains('Next Day Air')){
                                nextDtotalAmount += Integer.valueOf(cartItems.ccrz__Quantity__c) * Integer.valueOf(shippingRate.ccrz__ShippingRate__c); 
                            }
                            if(shippingRate.Name.contains('2 Day Air')){
                                twoDtotalAmount += Integer.valueOf(cartItems.ccrz__Quantity__c) * Integer.valueOf(shippingRate.ccrz__ShippingRate__c); 
                            }
                            if(shippingRate.Name.contains('3 Day Select')){
                                threeDtotalAmount += Integer.valueOf(cartItems.ccrz__Quantity__c) * Integer.valueOf(shippingRate.ccrz__ShippingRate__c); 
                            }
                            }
                            else if(shippingRate?.ccrz__MaxWeight__c <=  Decimal.ValueOf(Label.B2B_35) && shippingRate?.ccrz__MinWeight__c ==  Decimal.ValueOf(Label.B2B_10)
                                 && cartItems.ccrz__Product__r.ccrz__ShippingWeight__c > Decimal.ValueOf(Label.B2B_10) && cartItems.ccrz__Product__r.ccrz__ShippingWeight__c <= Decimal.ValueOf(Label.B2B_35)
                            ){
                            system.debug('cartItems.ccrz__Product__r.ccrz__ShippingWeight__c '+cartItems.ccrz__Product__r.ccrz__ShippingWeight__c );
                            system.debug('IN 2 : ');
                            if(shippingRate?.ccrz__MaxWeight__c <=  Decimal.ValueOf(Label.B2B_35) && shippingRate?.ccrz__MinWeight__c == Decimal.ValueOf(Label.B2B_10) && 
                            shippingRate.Name.contains('GROUND') && cartItems.ccrz__Cart__r.ccrz__SubtotalAmount__c < Decimal.valueOf(Label.B2B_Ground_Limit)){
                                groundAmount = Integer.valueOf(shippingRate.ccrz__ShippingRate__c);
                            }    
                            if(shippingRate.Name.contains('Next Day Air')){
                                nextDtotalAmount += Integer.valueOf(cartItems.ccrz__Quantity__c) * Integer.valueOf(shippingRate.ccrz__ShippingRate__c); 
                            }
                            if(shippingRate.Name.contains('2 Day Air')){
                                twoDtotalAmount += Integer.valueOf(cartItems.ccrz__Quantity__c) * Integer.valueOf(shippingRate.ccrz__ShippingRate__c); 
                            }
                            if(shippingRate.Name.contains('3 Day Select')){
                                threeDtotalAmount += Integer.valueOf(cartItems.ccrz__Quantity__c) * Integer.valueOf(shippingRate.ccrz__ShippingRate__c); 
                            }
                            }            
                            else if(shippingRate?.ccrz__MaxWeight__c <=  Decimal.ValueOf(Label.B2B_50) && shippingRate?.ccrz__MinWeight__c ==  Decimal.ValueOf(Label.B2B_35)
                                && cartItems.ccrz__Product__r.ccrz__ShippingWeight__c > Decimal.ValueOf(Label.B2B_35) && cartItems.ccrz__Product__r.ccrz__ShippingWeight__c <= Decimal.ValueOf(Label.B2B_50)
                            ){
                            system.debug('IN 3 : ');
                            if(shippingRate?.ccrz__MaxWeight__c <=  Decimal.ValueOf(Label.B2B_50) && shippingRate?.ccrz__MinWeight__c == Decimal.ValueOf(Label.B2B_35) && 
                            shippingRate.Name.contains('GROUND') && cartItems.ccrz__Cart__r.ccrz__SubtotalAmount__c < Decimal.valueOf(Label.B2B_Ground_Limit)){
                                groundAmount = Integer.valueOf(shippingRate.ccrz__ShippingRate__c);
                            }      
                            if(shippingRate.Name.contains('Next Day Air')){
                                nextDtotalAmount += Integer.valueOf(cartItems.ccrz__Quantity__c) * Integer.valueOf(shippingRate.ccrz__ShippingRate__c); 
                            }
                            if(shippingRate.Name.contains('2 Day Air')){
                                twoDtotalAmount += Integer.valueOf(cartItems.ccrz__Quantity__c) * Integer.valueOf(shippingRate.ccrz__ShippingRate__c); 
                            }
                            if(shippingRate.Name.contains('3 Day Select')){
                                threeDtotalAmount += Integer.valueOf(cartItems.ccrz__Quantity__c) * Integer.valueOf(shippingRate.ccrz__ShippingRate__c); 
                            }
    
                            }
                            else if(shippingRate?.ccrz__MaxWeight__c >  Decimal.ValueOf(Label.B2B_50) && shippingRate?.ccrz__MinWeight__c ==  Decimal.ValueOf(Label.B2B_50)
                                && cartItems.ccrz__Product__r.ccrz__ShippingWeight__c > Decimal.ValueOf(Label.B2B_50) 
                            ){
                            system.debug('IN 4 : ');
                            if(shippingRate?.ccrz__MaxWeight__c <=  Decimal.ValueOf(Label.B2B_50) && shippingRate?.ccrz__MinWeight__c == Decimal.ValueOf(Label.B2B_50) && 
                            shippingRate.Name.contains('GROUND') && cartItems.ccrz__Cart__r.ccrz__SubtotalAmount__c < Decimal.valueOf(Label.B2B_Ground_Limit)){
                                groundAmount = Integer.valueOf(shippingRate.ccrz__ShippingRate__c);
                            }      
                            if(shippingRate.Name.contains('Next Day Air')){
                                nextDtotalAmount += Integer.valueOf(cartItems.ccrz__Quantity__c) * Integer.valueOf(shippingRate.ccrz__ShippingRate__c); 
                            }
                            if(shippingRate.Name.contains('2 Day Air')){
                                twoDtotalAmount += Integer.valueOf(cartItems.ccrz__Quantity__c) * Integer.valueOf(shippingRate.ccrz__ShippingRate__c); 
                            }
                            if(shippingRate.Name.contains('3 Day Select')){
                                threeDtotalAmount += Integer.valueOf(cartItems.ccrz__Quantity__c) * Integer.valueOf(shippingRate.ccrz__ShippingRate__c); 
                            }
                            }
                        system.debug('totalAmount:: '+totalAmount);
                        // add the shipping option to the list to return back to the storefront
                    }
                }
                shippingOptions.add(new ccrz.cc_ctrl_hlpr_ShippingOption(groundshipperName, groundName, groundAmount));
                if(!noProdWeight){
                    if(nextDtotalAmount  > 0){
                        shippingOptions.add(new ccrz.cc_ctrl_hlpr_ShippingOption(nextDayshipperName, nextDayName, nextDtotalAmount));
                    }
                    if(twoDtotalAmount  > 0){
                        shippingOptions.add(new ccrz.cc_ctrl_hlpr_ShippingOption(twoDayshipperName, twoDayName, twoDtotalAmount));
                    }
                    if(threeDtotalAmount  > 0){
                        shippingOptions.add(new ccrz.cc_ctrl_hlpr_ShippingOption(threeDayshipperName, threeDayName, threeDtotalAmount));
                    }
                } 
        }
          
        return shippingOptions;
    }
}