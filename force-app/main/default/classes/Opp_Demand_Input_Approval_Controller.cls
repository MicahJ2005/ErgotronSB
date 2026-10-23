/*
  Controller class for the Demand Input Approval Process Visualforce Email Template

  MOD DATE   	Who            		Description
  07/14/2017    Kelly Lafferty      Initial Release
*/

public class Opp_Demand_Input_Approval_Controller {
    //declare variables
	public Id oppId {get;set;}
    public Map<String, List<Product_Schedule__c>> mapProductSchedule {get;set;}
        
        //Returns list of product names to be displayed and populates the map of assos product schedules
        public List<String> getLstProductNames() {
            
            //initialize variables
            List<String> lstProductNames = new List<String>();
            mapProductSchedule = new Map<String, List<Product_Schedule__c>>();
            Set<String> setProductNames = new Set<String>();
            
            //loop through schedule data and store in the map
            for (Product_Schedule__c oProdSchedule : [SELECT Name
	                                                      , Opportunity__c
        	                                              , Opportunity_Line_Item_Id__c 
    	                                                  , Scheduled_Date__c
            	                                          , Scheduled_Quantity__c
                                                      FROM Product_Schedule__c
                                                      WHERE Opportunity__c = :oppId
                                                      Order By Opportunity_Line_Item_Id__c, Scheduled_Date__c]) {
                                                          
				//Keeps a List and Set to hold product names. Determines if current product has processed & if not
				//puts the value in the List. Loops through List in the VF page so data is displayed in correct order
				if (setProductNames.contains(oProdSchedule.Name) == false) {
                    lstProductNames.add(oProdSchedule.Name);
                    setProductNames.add(oProdSchedule.Name);
                }
                                                          
				//Creates a list to hold schedules associated to the current product.  If schedule exists pulls existing 
        //list from the map and adds the current value to that collection.
				List<Product_Schedule__c> lstHoldProductSchedule = new List<Product_Schedule__c>();
				if (mapProductSchedule.containsKey(oProdSchedule.Name)) {
					lstHoldProductSchedule = mapProductSchedule.get(oProdSchedule.Name);
				}
				lstHoldProductSchedule.add(oProdSchedule);
				mapProductSchedule.put(oProdSchedule.Name, lstHoldProductSchedule);
			}
                                                              
			return lstProductNames;
		}
}