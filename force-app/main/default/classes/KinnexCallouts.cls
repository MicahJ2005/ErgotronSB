//03.17.2020	Sophia Murphy (Demand Chain)
//				Update to use Firestore creds.
public class KinnexCallouts {
    
    public static web_Service_Details__c firestoreCredentials = [select endpoint__c, username__c, password__c, Account_ID__c 
                                                                    , Client_Email__c, Name_Audience__c, Private_Key_Id__c, Project_Id__c
                                                                    from web_Service_Details__c where name = 'Firestore'];
        
    //Called from the Asset Trigger whenever the CCU_Board__c is changed.
    @Future(Callout=true)
    public static void doKinnexCallout(Set<Id> setAsset) {
        
        List<Asset> lstAssets = [SELECT Id, Name, CCU_Board__c FROM Asset WHERE Id IN :setAsset];
        
        //Get the JWT token.
        String token = KinnexCallouts.createJWT();

        for(Asset objAsset : lstAssets) {
            KinnexCallouts.updateDevice(token, objAsset.Name, objAsset.CCU_Board__c);
        }
        
    }
    
    public static String createJWT(){
        // The consumer key for a connected app of mine
        String kid = firestoreCredentials.Private_Key_Id__c;
        String iss = firestoreCredentials.Client_Email__c;
        String sub = firestoreCredentials.Client_Email__c;
        String aud = firestoreCredentials.Name_Audience__c;
        Long iat = DateTime.now().getTime();
        iat = iat / 1000;
        Long exp = iat + 352;


        // Start constructing the header and claims
        // The "alg" will pretty much always be "RS256" with Salesforce
        String jwtHeader = '{"alg":"RS256", "typ":"JWT"}';
        String jwtClaims = '{"kid":"' + kid + '", "iss":"' + iss + '","sub":"' + sub + '","aud":"' + aud + '","iat":' + iat + ',"exp":' + exp + '}';

        system.debug('DC: jwtHeader: ' + jwtHeader);
        system.debug('DC: jwtClaims: ' + jwtClaims);

        //Request is the header and the claim together.
        String jwtRequest = System.encodingUtil.base64Encode(Blob.valueOf(jwtHeader)).replace('+', '-').replace('/', '_') + '.' + System.encodingUtil.base64Encode(Blob.valueOf(jwtClaims)).replace('+', '-').replace('/', '_');

        system.debug('DC: jwtRequest: ' + jwtClaims);

        String algorithm = 'RSA-SHA256';
        //String myCert = '-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDIrD06IMuVWfCg\n0QRtm9EjUt+tL+92Wy2AH2EzIgaRxEhwXuLivTgqcx5bz+82F5WBSU5+S0BaOyaF\nXFIJpkIwYubgLximDc0iWCtIeQ0thaCJ/ZbAzmway5w4Hgjg5zk4dZn+W//rHKdu\nv343Gs1VKv1LH13G3p4Fw88TrMsY6kwupIC29pRQauLILks+nM6aV0BwQvIx+HOg\nE6eHONzBshQmApgoDnS0CYcQisLXEyu6RHLCjAnTYD+8G44WCLIUq5nW0vTmo3cR\nsVLqSD19+9ny1pCQWtO7kX2ZDxDdtv28A8VF7LxTDsh+I7YGy5IobGJ8zw5V7HZK\nA+61rNZpAgMBAAECggEAAKZgJ2NKTYBGUXsD0OgPiBYBX/H3DFLUxaS0X6JFU60H\nUAfao8HZn/eR+lmkzG/MnefTH4EWYwRshkOLh3j4n2f+l+zHH2iNiMYw07ICqypS\n4AeIeLTicD7HEX51aGcPTiHBXyvEmyoTV746hiqpzhQO0HK4TsfTSrD853MokDrW\nju5vFbbxJjCgbvMJYdtGkDtuRO4eyQWS4n19fz5eDJbxjViIvI9W1jtiA33YdTpM\nXq/TItcCgXoQep8Gh1YMjsLvdWrHvxga+fB1SMKQDaxtG77BUCwIP5o4T7z62SU3\n0oi5f+htKnAj3yzUrjiwR43NVyXTuqMEba0VRFQnVQKBgQDmiQKEXClN86j9IvlK\nxBg3TmpceSJyMS3TGdXT4TG9wyc+9moIRTHXAejZrIvRCa2R4063NGsV80y9KCFz\nrt2Y5YPj05Y8pxtHoOTUcHvSJksJbizAFbCAKfInROF/qwFiZv3WcJ/v/C6HyxyV\nFyO0OaSioSiWkdtNC6a7cCt0VQKBgQDe1sqsRQ8sRYIgDPhLsE00r70/Mg8NjSxv\nmWOIljXOiY6U6Yli2DeAXIeBN4oC5rfNHjAkShu2E9rgIWPChdSv4Ha/ibvEwy2k\nFE7JmHATAq73gredTobXeiQdY87IOirw9uOEiMzcLrR1Y3sXOWMd3cvL+s64VlBn\nbWOZ5gQNxQKBgG9mY638LwV5Kf7wyJBlg+It5V28N3YA58jr4hUZ7ARr6moVfxVy\nAmyIgrG1HHct+w7VTbNgBCM+R6XcX5XcOT7qIbqVAzNZ+Oe7CvjRRjQ9xuLOt5c2\no+y62EY7ldAwnWGkrSLTl6XLMdzyvGQbI2iytijUQZ3I67UmXTKUOJtlAoGBAKdb\nobNn2lFhkq0HkKMnsZRUOElyCyQeVrUp+jrmtVp8rPzhuDDoOibJV2uQjrJHHNuM\nRJO8pLtGhie2a/n4ERhV+Fk51C+ednS4W8PEHMfqSAXTwpr+Ev9Z2C3Ke86dAQsg\nIRe0tkbXPOi84gE7NFmF7j0wDHkdOh2zZg57VagRAoGAALac2vEtVWYL5go54dvK\nkom3WamJSGbEmex48aEzYogloRYey9DpE5Tbpz0ZDArbBq+YpR/uSSERKp2UANxb\nzO8vQIimPHIEgAQ44Nt0y4zhwns55onbfxNLpC88ZN8+3JOAtqFShZHFSVuQhxVw\nQMO8fDCn5Ar3N1yU8osSb+Y=\n-----END PRIVATE KEY-----\n';
        String myCert = getPK();
        system.debug('DC: ' + myCert);

        //For SF - we need to strip out the front/back and the /n
        myCert = myCert.replaceAll('-----END PRIVATE KEY-----', '').replaceAll('-----BEGIN PRIVATE KEY-----', '');

        system.debug('DC: ' + myCert);

        myCert = myCert.replaceAll('\n', '');
        myCert = myCert.replaceAll('\\\\n', '');


        system.debug('DC: ' + myCert);

        Blob pKey = EncodingUtil.base64Decode(myCert); 
        Blob signature = Crypto.sign(algorithm,  Blob.valueOf(jwtRequest), pKey);

        String token = jwtRequest + '.' + EncodingUtil.base64Encode(signature);
        system.debug('DC: token: ' + token);
        return token;

        
    }
    
    /** METHOD NOT USED - but kept here for reference/FUTURE
    public static void getDeviceBySN(String token, String deviceId) {

        system.debug('DC: inside getDeviceBySN');

        String endPtStart = firestoreCredentials.endpoint__c;
        String projectId = firestoreCredentials.Project_Id__c;
        String dbId = '(default)';

        System.debug('DC: token: ' + token);

        String endPt = endPtStart + 'projects/' + projectId + '/databases/' + dbId + '/documents/devices/' + deviceId;
        System.debug('DC: endPt: ' + endPt);

        Httprequest request = new HttpRequest();
        request.setEndpoint(endPt);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('Content-Type','application/json');
        request.setHeader('grant_type', 'urn:ietf:params:oauth:grant-type:jwt-bearer');
        Http h = new Http();

        HttpResponse response = h.send(request);
         system.debug('DC: getBody' + response.getBody());
        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200) {
            system.debug('DC: ' + response.getBody());
        }
    }
    */

    public static void updateDevice(String token, String assetName, String deviceId) {

    system.debug('DC: inside getDeviceBySN');

        String endPtStart = firestoreCredentials.endpoint__c;
        String projectId = firestoreCredentials.Project_Id__c;
        String dbId = '(default)';

        System.debug('DC: token: ' + token);

            //the ? params need to be in the URL
        String endPt = endPtStart + 'projects/' + projectId + '/databases/' + dbId + '/documents/devices/' + deviceId + '?updateMask.fieldPaths=productSerialNumber&currentDocument.exists=true';
        System.debug('DC: endPt: ' + endPt);

        Httprequest request = new HttpRequest();
        request.setEndpoint(endPt);
        request.setMethod('PUT');
        request.setHeader('X-HTTP-Method-Override','PATCH');
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('Content-Type','application/json');
        request.setHeader('grant_type', 'urn:ietf:params:oauth:grant-type:jwt-bearer');
        Http h = new Http();

        //Not the cleanest looking map - but since we're only sending one value... easier than building out a whole class...
        Map<String, String> mapValues = new map<String, String>();
        mapValues.put('stringValue', assetName);
        Map<String, Map<String, String>> mapValues2 = new map<String, Map<String, String>>();
        mapValues2.put('productSerialNumber', mapValues);
        Map<String, Map<String, Map<String, String>>> mapValues3 = new map<String, Map<String, Map<String, String>>>();
        mapValues3.put('fields', mapValues2);

        String serialized = JSON.serialize(mapValues3);
        system.debug('DC: serialized: ' + serialized);

        request.setBody(serialized);

        System.Debug('Body of the PUT method: ' + request.getBody());
        if(!Test.isRunningTest()) {
            HttpResponse response = h.send(request);
            // If the request is successful, parse the JSON response.
            if (response.getStatusCode() == 200) {
                System.Debug(response.getBody());
            } else {
                System.Debug(response.getBody());
            }
        }
    }

    public static String getPK() {
        //Fetching the resource
        List<StaticResource> resourceList = [SELECT Id, Body
                                               FROM StaticResource
                                              WHERE Name = 'firestore_pk' LIMIT 1];
                           
        //Checking if the result is returned or not
        if(resourceList.size() == 1) {
            System.debug('DC: ' + resourceList[0].Body); //blob
            return resourceList[0].Body.toString();
        } else {
            return '';
        }
    }
}