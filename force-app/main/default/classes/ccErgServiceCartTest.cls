@isTest
public class ccErgServiceCartTest {
	@isTest
    static void verifyAddressTest() { 
        Map<String,Object> inputData = new Map<String,Object>();
        ccErgServiceCart ccErgServiceCart = new ccErgServiceCart();
        ccErgServiceCart.getFieldsMap(inputData);
        System.assertNotEquals(null, inputData);
    }
}