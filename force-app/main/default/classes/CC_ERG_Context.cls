/**
 * @description       : 
 * @author            : Raziya Gurramkonda
 * @group             : 
 * @last modified on  : 11-11-2020
 * @last modified by  : Raziya Gurramkonda
 * Modifications Log 
 * Ver   Date         Author               Modification
 * 1.0   11-11-2020   Raziya Gurramkonda   Initial Version
**/
global without sharing class CC_ERG_Context {
    
    //move these values to a label or custom settings
    global static final String defaultStorefront = 'DefaultStore';
    global static final String defaultPortalUser = 'Default Store';
    global static String defaultUserLocale = 'en_US';
    global static String defaultUserCurrency = 'USD';

    global String storefront;
    global String portalUserName;
    global String userLocale;
    global String userCurrency;

    /**
     * Default Constructor to set the ECommerce Storefront Context.
     * Needed for all CC APIs
     */
    global CC_ERG_Context() {
        this.storefront = defaultStorefront;
        this.portalUserName = defaultPortalUser;
        this.userLocale = defaultUserLocale;
        this.userCurrency = defaultUserCurrency;
    }

    /**
     * Constructor to set the ECommerce Storefront Context based on the
     * current user logged in. Needed for all CC APIs
     *
     * @param  storefront        Name of the CC Storefront
     * @param  portalUserName    Name of the current user logged in
     * @param  userLocale        Locale associated with the current user
     * @param  userCurrency      Default currency for the current user context
     *
     * @return
     */
    global CC_ERG_Context(String storefront, String portalUserName, String userLocale, String userCurrency) {
        this.storefront = storefront;
        this.portalUserName = portalUserName;
        this.userLocale = userLocale;
        this.userCurrency = userCurrency;
    }


    /**
     * Method to return CC Context for a given Portal user
     *
     * @param  storefront        Name of the CC Storefront
     * @param  portalUserName    Name of the user for retrieving the CC Context
     * @param  userLocale        Locale associated with the current user
     *
     * @return ccContext
     */
    global static ccrz.ccContext getCCContextForUser(Map<String,Object> mapStorefrontContext)  {
        system.debug('**** mapStorefrontContext'+JSON.serialize(mapStorefrontContext));
        String priceGroupId = null;
        ccrz.ccContext ctx = new ccrz.ccContext();
        String portalUserName = '';
        if(mapStorefrontContext!=null &&
                mapStorefrontContext.containsKey(CC_ERG_Constant.STOREFRONT_NAME) &&
                mapStorefrontContext.containsKey(CC_ERG_Constant.STOREFRONT_LOCALE))
        {
           // Map<String, String> mapConstants = ccErg_Utilities.fetchVONConstant(ccErg_Constant.STOREFRONT_MODULE);
            String storefront = (String) mapStorefrontContext.get(CC_ERG_Constant.STOREFRONT_NAME);
            if(mapStorefrontContext.containsKey(CC_ERG_Constant.STOREFRONT_USERNAME) &&
                    mapStorefrontContext.get(CC_ERG_Constant.STOREFRONT_USERNAME)!=null &&
                    String.isNotBlank((String)mapStorefrontContext.get(CC_ERG_Constant.STOREFRONT_USERNAME)))
            {
                portalUserName = (String) mapStorefrontContext.get(CC_ERG_Constant.STOREFRONT_USERNAME);
            }else
            {
              //  portalUserName = mapConstants.get(ccErg_Constant.STOREFRONT_OWNER_USERNAME);
            }
            String userLocale = (String) mapStorefrontContext.get(CC_ERG_Constant.STOREFRONT_LOCALE);

            if(mapStorefrontContext.containsKey(CC_ERG_Constant.PRICE_LIST_NAME))
            {
                String strPricebookName = (String) mapStorefrontContext.get(CC_ERG_Constant.PRICE_LIST_NAME);
                String strCurrency = '';
                if(mapStorefrontContext.containsKey(CC_ERG_Constant.STOREFRONT_CURRENCY))
                {
                    strCurrency = (String)mapStorefrontContext.get(CC_ERG_Constant.STOREFRONT_CURRENCY);
                }else
                {
               //     strCurrency = mapConstants.get(ccErg_Constant.STOREFRONT_DEFAULT_CURRENCY);
                }
                if(String.isNotBlank(strPricebookName) && String.isNotBlank(strCurrency))
                {
                    String strPriceListId = strPricebookName +'_'+strCurrency;
                    List<ccrz__E_PriceGroupPricelist__c> lstPriceGroupPriceLists = CC_ERG_PricingService.fetchCCPriceGroup(strPriceListId);
                    if(lstPriceGroupPriceLists!=null && lstPriceGroupPriceLists.size()>0)
                    {
                        ccrz__E_PriceGroupPricelist__c ccPriceGroupPriceList = lstPriceGroupPriceLists.get(0);
                        ccrz__E_PriceGroup__c ccPriceGroupObject = ccPriceGroupPriceList.ccrz__PriceGroup__r;
                        if(ccPriceGroupObject!=null)
                        {
                            priceGroupId = ccPriceGroupObject.Id;
                        }
                    }
                }
            }
            ctx.storefront = storefront;
            List<User> lstUser = [SELECT Id, Name FROM User WHERE Username =: portalUserName];
            User user = null;
            if(lstUser!=null && lstUser.size()>0)
            {
                user = lstUser[0];
            }
            ctx.portalUserId = user.Id;
            ctx.userLocale = userLocale;
            if(mapStorefrontContext.containsKey(CC_ERG_Constant.STOREFRONT_CURRENCY))
            {
                ccrz.cc_CallContext.userCurrency = (String) mapStorefrontContext.get(CC_ERG_Constant.STOREFRONT_CURRENCY);
            }
            if(String.isNotBlank(priceGroupId))
            {
                ccrz.cc_CallContext.priceGroupId = priceGroupId;
            }
            system.debug('**** ctx'+ctx);
            ccrz.cc_CallContext.initContext(ctx);
        }
        return ctx;
    }

    /**
     * Method to return CC Context for a the current logged in Portal user
     *
     * @param  storefront        Name of the CC Storefront
     * @param  userLocale        Locale associated with the current user
     *
     * @return ccContext
     */
    global static ccrz.ccContext getCCContextForCurrentUser(String storefront, String userLocale)  {
        ccrz.ccContext ctx = new ccrz.ccContext();
        ctx.storefront = storefront;
        ctx.portalUserId = UserInfo.getUserId();
        ctx.userLocale = userLocale;
        ccrz.cc_CallContext.initContext(ctx);
        return ctx;
    }

    /**
     * Method to return the CC API Version. Used in all APIs
     *
     * @return Map   Returns a Map with the API version details
     */
    global Map<String,Object> getCCApiVersion() {
        Map<String,Object> ccMap = new Map<String,Object>();
        ccMap.put(ccrz.ccApi.API_VERSION,ccrz.ccApi.CURRENT_VERSION); //Version to be put in label?
        return ccMap;
    }


}