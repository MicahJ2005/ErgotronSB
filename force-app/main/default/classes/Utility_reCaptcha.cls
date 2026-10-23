/**
 * @File Name          : Utility_reCaptcha.cls
 * @Description        : 
 * @Author             : James Loghry (Demand Chain)
 * @Group              : 
 * @Last Modified By   : James Loghry (Demand Chain)
 * @Last Modified On   : 12/27/2019, 11:01:48 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    12/27/2019   James Loghry (Demand Chain)     Initial Version
**/
public with sharing class Utility_reCaptcha {

  private static final reCaptchaGoogle__c recaptchaConfig = reCaptchaGoogle__c.getOrgDefaults();

  //James: Updated this to @AuraEnabled for lightning components in addition to VF pages.
  @AuraEnabled
  public static boolean verifyWithNoHeaders(String response){
      return verify(response, null);
  }

  public static Boolean verify(String response, Map<String, String> hdrs) {
      if(!recaptchaConfig.isEnforced__c) {
          System.Debug('Custom Setting is configured to ignore the reCaptcha verification result');
          return true;
      }

    Boolean verif = false;

    String requestString = 'secret=' + recaptchaConfig.secretKey__c + '&response='  + response;
    if(hdrs != null){
      requestString += '&remoteip=' + Utility_reCaptcha.remoteHost(hdrs);
    }
    final HttpResponse res = makeRequest(requestString);

    //final HttpResponse res = makeRequest(JSON.serialize(clsPost));
    if (res != null) {
      System.Debug('JWL: body: ' + res.getBody());
      if ( res.getStatusCode() == 200 ) {
        final System.JSONParser parser = System.JSON.createParser(res.getBody());
        while (parser.nextToken() != null) {
          if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'success')) {
            parser.nextToken();
            verif = parser.getText() == 'true';
            break;
          }
        }
      }
    }
    return verif;
  }

  public static Boolean verify(final String response) {
    return Utility_reCaptcha.verify(response, ApexPages.currentPage().getHeaders());
  }

  private static HttpResponse makeRequest(final string body)  {
    final HttpRequest req = new HttpRequest();
    req.setEndpoint(recaptchaConfig.endpoint__c);
    req.setMethod('POST');
    req.setBody (body);
    System.Debug(req.getBody());
    try {
      final Http http = new Http();
      return http.send(req);
    } catch(System.Exception e) {
      // Handle error here
    }
    return null;
  }

  @TestVisible
  private static String remoteHost(final Map<String, String> hdrs) {
    String ret = '127.0.0.1';
    if (hdrs.get('x-original-remote-addr')!= null)
      ret =  hdrs.get('x-original-remote-addr');
    else if (hdrs.get('X-Salesforce-SIP')!= null)
      ret =  hdrs.get('X-Salesforce-SIP');
    return ret;
  }

}