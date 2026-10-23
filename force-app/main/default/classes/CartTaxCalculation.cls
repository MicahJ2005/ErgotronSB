/**
 * @description       : Class for tax calculation in Ergotron Store
 * @author            : R1
 * @last modified on  : 08-05-2025
 * @last modified by  : 
 * Modifications Log 
 * Ver   Date         Author                Modification
**/

global without sharing class CartTaxCalculation extends ccrz.cc_hk_TaxCalculation {

    private static final String BASE_QUERY = 'SELECT Combined_Rate__c,County__c FROM Tax_Rate__c';
    private static final String QUERY_LIMIT = ' LIMIT 1';

    /**
     * @description overriden method to get tax amount based on custom tax rate table
     * @param inputData Map<String,Object>
     * @return Decimal
    **/
    global override Decimal getTaxAmount(Map<String, Object> inputData) {
        Decimal finalTax = 0;
        Id cartId;

        try {
            cartId = (Id) inputData.get(ccrz.cc_hk_TaxCalculation.PARAM_CARTID);

            List<ccrz__E_CartItem__c> cartItems = [
                SELECT Id, ccrz__ItemTotal__c,
                	   ccrz__Cart__r.ccrz__ShipTo__r.County__c,
					   ccrz__Cart__r.ccrz__ShipTo__c,
                       ccrz__Cart__r.ccrz__ShipTo__r.ccrz__City__c,
                       ccrz__Cart__r.ccrz__ShipTo__r.ccrz__State__c,
                       ccrz__Cart__r.ccrz__ShipTo__r.ccrz__PostalCode__c,
                       ccrz__Cart__r.County__c
                FROM ccrz__E_CartItem__c
                WHERE ccrz__Cart__c = :cartId
            ];

            if (cartItems.isEmpty()) return finalTax;

            ccrz__E_CartItem__c firstCartItem = cartItems[0];
            String city = firstCartItem.ccrz__Cart__r.ccrz__ShipTo__r.ccrz__City__c;
            String state = firstCartItem.ccrz__Cart__r.ccrz__ShipTo__r.ccrz__State__c;
            String zipRaw = firstCartItem.ccrz__Cart__r.ccrz__ShipTo__r.ccrz__PostalCode__c;
            String county = firstCartItem.ccrz__Cart__r.County__c;
			String countyOnShipTo = firstCartItem.ccrz__Cart__r.ccrz__ShipTo__r.County__c;
            String shipToRecordId = firstCartItem.ccrz__Cart__r.ccrz__ShipTo__c;
            Integer zipCode = Integer.valueOf(zipRaw.split('-')[0]); //to account for hyphen case, need to take left of hyphen

            Nebula.logger.info('Tax Calculation for Cart Id: '+ cartId + '\nCity: '+city+'\nState: '+state+'\nZip: '+zipRaw+'\nCounty: '+county);
            
            List<String> queries = buildTaxRateQueries(zipCode, state, county, city);
            List<Tax_Rate__c> taxRateRecords;
			
            Integer queryRun=0;
            for (String query : queries) {
                queryRun+=1;
                Nebula.logger.info('Query '+String.valueOf(queryRun)+': '+query);
                taxRateRecords = Database.query(query);
                if (!taxRateRecords.isEmpty()) break;
            }
            Nebula.logger.info('Record found - '+JSON.serialize(taxRateRecords));
            if (taxRateRecords.isEmpty()) return finalTax;

            Decimal totalTaxRate = taxRateRecords[0].Combined_Rate__c;
            String countyFinalValue = String.isNotBlank(county) ? county : taxRateRecords[0].County__c;

            if(shipToRecordId!=null && countyFinalValue!=null && countyFinalValue!=countyOnShipTo){
                update new ccrz__E_ContactAddr__c(Id = shipToRecordId, County__c = countyFinalValue);
            }

            if (totalTaxRate != null) {
                for (ccrz__E_CartItem__c item : cartItems) {
                    finalTax += item.ccrz__ItemTotal__c * totalTaxRate;
                }

                update new ccrz__E_Cart__c(Id = cartId, ccrz__TaxAmount__c = finalTax);
            }
        } catch (Exception ex) {
            Nebula.logger.error('ERROR: '+ex.getMessage()+ ' ' +ex.getStackTraceString());
        }
        finally{
            Nebula.logger.saveLog();
        }

        return finalTax;
    }

    /**
     * @description method to form queries for fetching tax rate record
     * @param zipCode Integer
     * @param state String
     * @param county String
     * @param city String
     * @return List<String>
    **/
    private static List<String> buildTaxRateQueries(Integer zipCode, String state, String county, String city) {
        List<String> queries = new List<String>();

        String zipClause = ' WHERE ZIP_Start__c <= ' + zipCode +
                           ' AND ZIP_End__c >= ' + zipCode;

        String stateClause = String.isNotBlank(state) ? ' AND State__c =  \'' + String.escapeSingleQuotes(state) + '\'' : '';
        String countyClause = String.isNotBlank(county) ?  ' AND County__c =  \'' + String.escapeSingleQuotes(county) + '\'' : '';
        String cityClause   = String.isNotBlank (city) ? ' AND City__c = \'' + String.escapeSingleQuotes(city) + '\'' : '';

        queries.add(BASE_QUERY + zipClause + stateClause + countyClause + cityClause + QUERY_LIMIT);
        queries.add(BASE_QUERY + zipClause + stateClause + countyClause + QUERY_LIMIT);
        queries.add(BASE_QUERY + zipClause + stateClause + QUERY_LIMIT);
        queries.add(BASE_QUERY + zipClause + QUERY_LIMIT);

        return queries;
    }
    
    
}