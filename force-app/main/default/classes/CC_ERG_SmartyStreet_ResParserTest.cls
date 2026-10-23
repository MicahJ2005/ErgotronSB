@isTest
public class CC_ERG_SmartyStreet_ResParserTest {
	
    @isTest
    static void validateUserTest() {
    	CC_ERG_SmartyStreet_ResParser smartStreet = new CC_ERG_SmartyStreet_ResParser();
        Integer inputIndex = smartStreet.input_index;
        System.assertNotEquals(smartStreet.input_index, 10);
        System.assertNotEquals(smartStreet.candidate_index, 2); 
        CC_ERG_SmartyStreet_ResParser.Components smartStreetComponent = new CC_ERG_SmartyStreet_ResParser.Components();
        System.assertNotEquals(smartStreetComponent.primary_number, '10'); 
    }
}