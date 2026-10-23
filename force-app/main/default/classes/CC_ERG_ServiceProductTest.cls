@isTest
public class CC_ERG_ServiceProductTest {
  @isTest
    static void fieldsMapTest() { 
        Map<String,Object> inputData = new Map<String,Object>();
        CC_ERG_ServiceProduct  ccErgServiceProd = new CC_ERG_ServiceProduct();
        ccErgServiceProd.getFieldsMap(inputData);
        System.assertNotEquals(null, inputData);
    }
}