/**
 * Test class to run  : TEST_TrackingOrderEmail
 * @description       : 
 * @author            : willh@demandchain.com
 * @group             : 
 * @last modified on  : 05-05-2021
 * @last modified by  : willh@demandchain.com
 * Modifications Log 
 * Ver   Date         Author                  Modification
 * 1.0   04-22-2021   willh@demandchain.com   Initial Version
**/
public with sharing class SalesOrderController {
	public string theID{get;set;}
	public List<Order_Tracking_Number__c> theOrdertrackingNumberList{get;set;}
	public Map<String, Order_Line_Item__c> OrderTrackingNumber2OrderLineNumberMap{get;set;}
	public String OrderTrackingID{get;set;}

	/**
	* @description 
	* @author willh@demandchain.com | 04-28-2021 
	* @return List<Sales_Order__c> 
	**/
	Public List<Sales_Order__c> getSalesOrder() {
		return 	[SELECT ID, 
						Customer_PO_Number__c, 
						OracleSalesOrderRefNumber__c, 
						Source__c, 
						Shipping_Address__c, 
						Ship_To_Contact_Email__c 
						FROM 
							Sales_Order__c 
						WHERE 
							ID=:theID LIMIT 1];

	}
	

	/**
	* @description 
	* @author willh@demandchain.com | 04-28-2021 
	* @return List<Order_Tracking_Number__c> 
	**/
	public List<Order_Tracking_Number__c> getOrderTrackingNumberList() {
        if(theID != null) {
            theOrdertrackingNumberList = [SELECT ID,
												Line_ID__c,
												SF_Sales_Order__r.Oracle_Sales_Order_Number__c,
												Tracking_Number_Link__c,
												Tracking_Number__c,
                                          		Carrier_Code__c
												FROM 
													Order_Tracking_Number__c 
												WHERE 
													SF_Sales_Order__c =: theID];
            Set<ID> OrderIDSet = new Set<ID>();
            Set<String> LineIDSet = new Set<String>();
            for (Order_Tracking_Number__c theOrderTrackingNumber : theOrderTrackingNumberList) {
                LineIDSet.add(theOrderTrackingNumber.Line_ID__c);
                OrderIDSet.add(theOrderTrackingNumber.SF_Sales_Order__r.Oracle_Sales_Order_Number__c);
            }
            OrderTrackingNumber2OrderLineNumberMap = new Map<String, Order_Line_Item__c>();
            List<Order_Line_Item__c> theOrderLineNumberList = [SELECT Id, 
																	CC_Prod_Alternate_Name__c,
																	Unit_Selling_Price__c,
																	Shipped_Quantity__c,
																	Line_Id__c,
																	Order__c
																	FROM 
																		Order_Line_Item__c
																	WHERE 
																		Line_Id__c in: LineIDSet 
																		AND 
																		Order__c in: OrderIDSet];
            for (Order_Tracking_Number__c theOrderTrackingNumber : theOrderTrackingNumberList) {
                for (Order_Line_Item__c theOrderLineNumber : theOrderLineNumberList) {
                    if (theOrderLineNumber.Line_Id__c != null && theOrderTrackingNumber.Line_ID__c != null) {
                        if (theOrderLineNumber.Line_Id__c.equalsIgnoreCase(theOrderTrackingNumber.Line_ID__c) && theOrderLineNumber.Order__c == theOrderTrackingNumber.SF_Sales_Order__r.Oracle_Sales_Order_Number__c) {
                            OrderTrackingNumber2OrderLineNumberMap.put(theOrderTrackingNumber.ID, theOrderLineNumber);
                        }
                    }
    
                }
			}
			OrderTrackingID = String.valueOf(OrderTrackingNumber2OrderLineNumberMap.keySet());
        }
		return theOrdertrackingNumberList;
	}
}