/*
	Utility class to handle operations performed on the Sales_Order_Line__c object.

	MOD DATE		Who						Description
	07/07/2015		Chris Noe				Initial Release
	20180517		Andy Boettcher DCS		Sunsetted for Lightning Service Cloud
*/

public with sharing class Sales_Order_Line_Utility {
	//public static void checkSubmittedOrderLine(List<Sales_Order_Line__c> listSalesOrderLines){
		////This method checks to see if a Sales Order Line has been submitted to Oracle prior to deleting the record.  If the Order_Line_Submitted__c value
		////is true, the Sales Order Line cannot be deleted.

		//for(Sales_Order_Line__c oSalesOrderLine :listSalesOrderLines) {
			//if(oSalesOrderLine.Order_Line_Submitted__c){
				//oSalesOrderLine.addError('This sales order line cannot be deleted because it has already been submitted to Oracle.');
			//}
		//}
	//}
}