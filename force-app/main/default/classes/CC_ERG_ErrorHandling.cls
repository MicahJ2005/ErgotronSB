public class CC_ERG_ErrorHandling {
    
    /* public static String checkRequestParams(CC_ERG_ProductRequest productRequest)
    {
        String Resmsg = 'Success';
        System.debug('ammy'+productRequest.zipCode);
        if(productRequest != null && (productRequest.storefrontName == null || productRequest.storefrontName == ''))
        {
            Resmsg = 'Storefront is missing !!';
        }
        if(productRequest.storefrontName != null && productRequest.storefrontName != '' && productRequest.storefrontName != 'DefaultStore')
        {
            Resmsg = 'Invalid Storefront !!';
        }
        if(productRequest != null && (productRequest.userCurrency == null || productRequest.userCurrency == ''))
        {
            Resmsg = 'User Currency is missing !!';
        }
        if(productRequest.userCurrency != null && productRequest.userCurrency != '' && productRequest.userCurrency != 'USD')
        {
            Resmsg = 'Invalid User Currency !!';
        }
        if(productRequest != null && (productRequest.specType == null || productRequest.specType.isEmpty() || productRequest.specType.size() < 0))
        {
            Resmsg = 'Spec Type is missing !!';
        }
        if(productRequest != null && (productRequest.zipCode == null || productRequest.zipCode == ''))
        {
            Resmsg = 'Zip Code is missing !!';
        }
        if(productRequest != null && (productRequest.features == null || productRequest.features.isEmpty() || productRequest.features.size() < 0))
        {
            Resmsg = 'Features is missing !!';
        }
        
        if(productRequest != null && (productRequest.jurisdictionCode == null || productRequest.jurisdictionCode == ''))
        {
            Resmsg = 'Jurisdiction Code is missing';
        }
        return Resmsg;
    } */

/*     public static String checkRequestParamsProdFeaturesByCat(CC_ERG_ProductRequest productRequest)
    {
        String Resmsg = 'Success';
        if(productRequest != null && (productRequest.storefrontName == null || productRequest.storefrontName == ''))
        {
            Resmsg = 'Storefront is missing !!';
        }
        if(productRequest.storefrontName != null && productRequest.storefrontName != '' && productRequest.storefrontName != 'DefaultStore')
        {
            Resmsg = 'Invalid Storefront !!';
        }
        if(productRequest != null && (productRequest.userCurrency == null || productRequest.userCurrency == ''))
        {
            Resmsg = 'User Currency is missing !!';
        }
        if(productRequest.userCurrency != null && productRequest.userCurrency != '' && productRequest.userCurrency != 'USD')
        {
            Resmsg = 'Invalid User Currency !!';
        }
        if(productRequest != null && (productRequest.specType == null || productRequest.specType.isEmpty()))
        {
            Resmsg = 'Spec Type is missing !!';
        }
        return Resmsg;
    } */
    
    public static String checkRequestParamsFetchAllProdCat(CC_ERG_ProductRequest productRequest)
    {
        String Resmsg = 'Success';
        if(productRequest != null && (productRequest.storefrontName == null || productRequest.storefrontName == ''))
        {
            Resmsg = 'Storefront is missing !!';
        }
        if(productRequest.storefrontName != null && productRequest.storefrontName != '' && productRequest.storefrontName != 'DefaultStore')
        {
            Resmsg = 'Invalid Storefront !!';
        }
        if(productRequest != null && (productRequest.userCurrency == null || productRequest.userCurrency == ''))
        {
            Resmsg = 'User Currency is missing !!';
        }
        if(productRequest.userCurrency != null && productRequest.userCurrency != '' && productRequest.userCurrency != 'USD')
        {
            Resmsg = 'Invalid User Currency !!';
        }
        if(productRequest.sku == null || productRequest.sku == '')
        {
            Resmsg = 'SKU is blank !!';
        }
        if(productRequest.sku != null && productRequest.sku != '')
        {
            List<ccrz__E_Product__c> lstCCProd = [Select id, ccrz__SKU__c from ccrz__E_Product__c where ccrz__SKU__c =:productRequest.sku];
            if(lstCCProd.isEmpty())
            {
                Resmsg = 'Invalid SKU !!';
            }
        }
        return Resmsg;
    }
    public static String checkRequestParamsFetchAllProds(CC_ERG_ProductRequest productRequest)
    {
        String Resmsg = 'Success';
        if(productRequest != null && (productRequest.storefrontName == null || productRequest.storefrontName == ''))
        {
            Resmsg = 'Storefront is missing !!';
        }
        if(productRequest.storefrontName != null && productRequest.storefrontName != '' && productRequest.storefrontName != 'DefaultStore')
        {
            Resmsg = 'Invalid Storefront !!';
        }
        if(productRequest != null && (productRequest.userCurrency == null || productRequest.userCurrency == ''))
        {
            Resmsg = 'User Currency is missing !!';
        }
        if(productRequest.userCurrency != null && productRequest.userCurrency != '' && productRequest.userCurrency != 'USD')
        {
            Resmsg = 'Invalid User Currency !!';
        }
        return Resmsg;
    }
}