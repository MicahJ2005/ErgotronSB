@isTest
public class CC_ERG_PricingVOTest {
    public static Map<String, Object> testData;
    @TestSetup
    static void makeData(){
        SmartyStreets_API__c ss = new SmartyStreets_API__c();
        ss.Name = 'SeedUnitAddressVerify';
        ss.auth_id__c = 'adsmfqmwepm09daasd';
        ss.auth_token__c = '23240kfir8fj8f8';
        insert ss;           
        ccrz__E_Configuration__c theConfig = new ccrz__E_Configuration__c();
        testData = CC_ERG_TestData.setupAccountContactUser(true,true);
    }
    public static testMethod void test1()
    {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();            
        req.requestURI = '/services/apexrest/v1/searchProduct/';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;

        CC_ERG_PricingVO ob = new CC_ERG_PricingVO();
        ob.recurringPrice= TRUE;
        ob.listPrice= 97.26;
        ob.salePrice=87.34;
        ob.price=65.77;
        ob.tax=98.33;
        ob.totalAmount=44.12;
        ob.taxCalculated=TRUE;
        ob.tieredPricingEnabled=TRUE;
        ob.quantity=76;
        ob.pT='von';
        ob.priceTiers=new List<CC_ERG_PricingVO.PriceTier>();
        CC_ERG_PricingVO.PriceTier ob1 = new CC_ERG_PricingVO.PriceTier();
        ob1.startQuantity= 66;
        ob1.endQuantity=88; 
        ob1.listPrice=45.32;
        ob1.salePrice=77.21;
       
        CC_ERG_PricingVO.Tiers ob2 = new CC_ERG_PricingVO.Tiers();
        ob2.p=34;
        ob2.q=41;
        
        // ccrz__E_PriceList__c priceList = [Select id, name from ccrz__E_PriceList__c where name='Ergotron Employee'];
        // List<ccrz__E_PriceListItem__c> ptier = [Select id];
        // map<String,Object>reqMap=new map<String,Object>();
        // CC_ERG_PricingVO pobj = CC_ERG_PricingVO.parsePricing(ptier,reqMap);
    }
}