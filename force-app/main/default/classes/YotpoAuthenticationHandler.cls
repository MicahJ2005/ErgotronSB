/** {Purpose}  Initialized Yotpo settings from Custom Metadata and
 *  calls out to Yotpo API to get an access token,
 *  uses singleton pattern to ensure we don't authenticate multiple times in a transaction.
 *
 *   */ /** CHANGE  HISTORY =============================================================================
 *   Date    	Name / Description 08.05.2021 Jonathan Flatt (Demand Chain)
 *               Initial creation
 *   =============================================================================
 *
 */

public class YotpoAuthenticationHandler {
  //which metadata record to use is determined by the Custom Label Yotpo_Store_Setting_Name
  public static String storeMetadataName;
  private static YotpoAuthenticationHandler instance = null;
  public String accessToken { get; private set; }
  public String baseUrl { get; private set; }
  public String authEndpoint { get; private set; }
  public String orderEndpoint { get; private set; }
  public String[] errorReportMailAddresses { get; private set; }
  public String[] productCreationAlertMailAddresses { get; private set; }
  public Boolean isEnabled { get; private set; }
  private Yotpo_Api_setting__mdt yotpoSettings { get; private set; }
  private static final Integer[] retryCodes = new List<Integer>{ 429, 502 };
  private static final Integer MAX_RETRIES = 3;
  private static final Integer WAIT_TIME_IN_MILLISECONDS = 1500;

  private YotpoAuthenticationHandler() {
    Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    storeMetadataName = System.Label.Yotpo_Store_Setting_Name;
    yotpoSettings = Yotpo_Api_setting__mdt.getInstance(storeMetadataName);
    isEnabled =
      Test.isRunningTest() ||
      (!yotpoSettings.Disable_Callouts__c &&
      (!isSandbox || (isSandbox && yotpoSettings.Enable_In_Sandbox__c)));

    baseUrl = yotpoSettings.BaseURL__c.replace(
      '[STORE_ID]',
      yotpoSettings.Client_Id__c
    );
    authEndpoint = baseUrl + 'access_tokens';
    orderEndpoint = baseUrl + 'orders';
    errorReportMailAddresses = yotpoSettings.Job_error_alert_emails__c.split(
      ','
    );
    productCreationAlertMailAddresses = yotpoSettings.Product_Creation_Alerts__c.split(
      ','
    );
    if (isEnabled) {
      getAccessToken();
    }
  }

  public static YotpoAuthenticationHandler getInstance() {
    if (instance == null) {
      instance = new YotpoAuthenticationHandler();
    }
    return instance;
  }

  private void getAccessToken() {
    String body = new AuthBody(this.yotpoSettings).getAuthBody();
    String method = 'POST';
    String uri = this.authEndpoint;

    HttpRequest objReq = buildRequest(body, uri, method);
    HttpResponse objRes = calloutHandler(objReq, 0);

    TokenResponse tr = (TokenResponse) JSON.deserialize(
      objRes.getBody(),
      TokenResponse.class
    );
    accessToken = tr.access_token;
  }

  private static HttpRequest buildRequest(
    String body,
    String uri,
    String method
  ) {
    HttpRequest objReq = new HttpRequest();
    objReq.setTimeout(60000);
    if (!(String.isBlank(body))) {
      objReq.setBody(body);
    }
    objReq.setEndpoint(uri);
    objReq.setMethod(method);
    objReq.setHeader('Content-Type', 'application/json');
    return objReq;
  }

  public static HttpResponse callout(String body, String uri, String method) {
    HttpRequest objReq = buildRequest(body, uri, method);
    objReq.setHeader('X-Yotpo-Token', getInstance().accessToken);
    return calloutHandler(objReq, 0);
  }

  private static HttpResponse calloutHandler(
    HttpRequest objReq,
    Integer retryCount
  ) {
    Http h = new Http();
    HttpResponse objRes = h.send(objReq);
    handleRateLimit(objRes);
    Integer statusCode = objRes.getStatusCode();
    if (retryCodes.contains(statusCode) && retryCount < MAX_RETRIES + 1) {
      retryCount++;
      return calloutHandler(objReq, retryCount);
    } else {
      return objRes;
    }
  }

  private static void handleRateLimit(HttpResponse objRes) {
    String[] keys = objRes.getHeaderKeys();
    Integer rateLimitRemaining = keys.contains('RateLimit-Remaining')
      ? Integer.valueOf(objRes.getHeader('RateLimit-Remaining'))
      : null;
    Integer rateLimitResetInMilliseconds = keys.contains('RateLimit-Reset')
      ? Integer.valueOf(objRes.getHeader('RateLimit-Reset')) * 1000
      : WAIT_TIME_IN_MILLISECONDS;

    if (rateLimitRemaining != null && rateLimitRemaining == 0) {
      System.debug(
        'Sleeping for ' +
        rateLimitResetInMilliseconds +
        ' milliseconds.'
      );
      Long startingTime = System.now().getTime(); // Num milliseconds since Jan 1 1970
      while (
        System.now().getTime() - startingTime < WAIT_TIME_IN_MILLISECONDS
      ) {
      }
    }
  }

  private class TokenResponse {
    public String access_token { get; set; }
  }

  private class AuthBody {
    public String secret;

    public AuthBody(Yotpo_Api_setting__mdt yotpoSettings) {
      secret = yotpoSettings.Client_Secret__c;
    }

    public String getAuthBody() {
      return JSON.serialize(this);
    }
  }
}