global without sharing class CC_ERG_ValidateAddress_ext {
    static List<SmartyStreets_API__c> smartyStreet = SmartyStreets_API__c.getall()
        .values();
    public CC_ERG_ValidateAddress_ext(CC_ERG_ctrl_ReviewCart stdController) {
        
    }
    @RemoteAction
    global static CC_ERG_ValidateAddress_ext.Response verifyAddress(
        String street,
        String city,
        String state,
        String candidates,
        String secondary,
        String country,
        String zipCode,
        String cartID
        
    ) {
        String authId = smartyStreet[0].auth_id__c;
        String token = smartyStreet[0].auth_token__c;
        string match = 'enhanced';
        
        String addString =
            'https://us-street.api.smartystreets.com/street-address?auth-id=' +
            authId +
            '&auth-token=' +
            token;
        if (String.isNotBlank(street)) {
            addString += '&street=' + EncodingUtil.urlEncode(street, 'UTF-8');
        }
        if (String.isNotBlank(city)) {
            addString += '&city=' + EncodingUtil.urlEncode(city, 'UTF-8');
        }
        if (String.isNotBlank(state)) {
            addString += '&state=' + EncodingUtil.urlEncode(state, 'UTF-8');
        }
        if (String.isNotBlank(secondary)) {
            addString += '&secondary=' + EncodingUtil.urlEncode(secondary, 'UTF-8');
        }
        if (String.isNotBlank(country)) {
            addString += '&country=' + EncodingUtil.urlEncode(country, 'UTF-8');
        }
        if (String.isNotBlank(zipCode)) {
            addString += '&zipcode=' + EncodingUtil.urlEncode(zipCode, 'UTF-8');
        }
        if (String.isNotBlank(candidates)) {
            addString += '&candidates=' + EncodingUtil.urlEncode(candidates, 'UTF-8');
        }
        // addString += '&match=' + match;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(addString);
        req.setMethod('GET');
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        ccrz.ccLog.log(LoggingLevel.DEBUG, 'M:X', 'smartyStreet resp' + res.getbody());
        if (res.getstatusCode() == 200 && res.getbody() != null) {
            List<CC_ERG_SmartyStreet_ResParser> smartyStreetRes = (List<CC_ERG_SmartyStreet_ResParser>) System.JSON.deserialize(
                res.getbody(),
                List<CC_ERG_SmartyStreet_ResParser>.class
            );
            Response objResponse = new Response();
            objResponse.isError = false;
            objResponse.data = smartyStreetRes;
            
            if(!smartyStreetRes.isEmpty()){
                if(!String.isBlank(cartID)){
                    List<ccrz__E_Cart__c> listOfCarts= [Select Id, isAddressVerified__c,ccrz__ShipTo__c,ccrz__ShipTo__r.County__c from ccrz__E_Cart__c
                                                        Where ccrz__EncryptedId__c=: cartID LIMIT 1];
                    if(!listOfCarts.isEmpty()){
                        ccrz__E_Cart__c cart= listOfCarts[0];
                        
                        //R1-added the below to populate county on cart and then gradually on ship, as returned from smartystreets
                        if(smartyStreetRes[0].metadata!=null && String.isNotBlank(smartyStreetRes[0].metadata.county_name)){
                            cart.County__c = smartyStreetRes[0].metadata.county_name;
                        }
                        cart.isAddressVerified__c = true;
                        update cart;
                    }
                }          
            }
            return objResponse;
        } else {
            List<CC_ERG_SmartyStreet_ResParser> smartyStreetRes = (List<CC_ERG_SmartyStreet_ResParser>) System.JSON.deserialize(
                res.getbody(),
                List<CC_ERG_SmartyStreet_ResParser>.class
            );
            Response objResponse = new Response();
            objResponse.isError = true;
            objResponse.data = smartyStreetRes;
            objResponse.errorMessage = 'unexpected error';
            return objResponse;
        }
    }
    
    
    @JsonAccess(serializable='always' deserializable='always')
    global class Response {
        Boolean isError { get; set; }
        String errorMessage { get; set; }
        CC_ERG_SmartyStreet_ResParser[] data { get; set; }
    }
}