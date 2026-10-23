global without sharing class CC_ERG_CartReviewModel {
     global String refId{set;get;}
    global String token { set; get; }
    global String signature { set; get; }
    global Integer tenantId { set; get; }

    global Boolean contractAccepted {set;get;}
    global Boolean termsAccepted {set;get;}
    global Boolean e911Accepted {set;get;}

    global String userIPAddress {set;get;}
    global String userAcceptedDateTime {set;get;}

}