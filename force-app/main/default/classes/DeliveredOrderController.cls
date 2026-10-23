/**
 * @description       : 
 * Modifications Log 
 * Ver   Date         Author                  Modification
 * 1.0   12.14.2022   sophiam@demandchain.com   Initial Version
**/
public with sharing class DeliveredOrderController {

	public string theID {get;set;}

	public List<Sales_Order__c> getSalesOrder() {
		return 	[SELECT ID, 
						Customer_PO_Number__c, 
						OracleSalesOrderRefNumber__c, 
						Source__c, 
						Shipping_Address__c, 
						Ship_To_Contact_Email__c 
						FROM Sales_Order__c 
						WHERE ID=:theID LIMIT 1];

	} //END: getSalesOrder()

	public List<DeliveredDetail> getDeliveredDetailsList() {
		//First, get all the Shipment records related to this order...
		//store in a map with the Line ID as the key; that is how we will match up the records.
		Map<String, DeliveredDetail> lineIdToDeliveredDetail = new Map<String, DeliveredDetail>();
		Set<Id> orderIds = new Set<Id>();
		
		Set<Id> productIds = new Set<Id>();
		Set<String> productSKUs = new Set<String>();

		Map<Id, String> productIdToImage = new Map<Id, String>();
		Map<String, String> productSKUToImage = new Map<String, String>();
		
		for(zkmulti__MCShipment__c shipment : [SELECT Id, Order__c, Sales_Order__c, Order_Tracking_Number__c
												, zkmulti__Tracking_Stage__c
												//, zkmulti__Tracking_Number__c
												, Sales_Order__r.Oracle_Sales_Order_Number__c //This should be the same as the Order__c
												, Order_Tracking_Number__r.Line_ID__c
												, Order_Tracking_Number__r.Tracking_Number_Link__c
												, Order_Tracking_Number__r.Tracking_Number__c
												, zkmulti__Status_Description__c
											FROM zkmulti__MCShipment__c
											WHERE Sales_Order__c = :theID 
											AND zkmulti__Tracking_Stage__c = 'Delivered']) {

				//Load in all the info that we are able to get from the Shipment record...								
				DeliveredDetail dd = new DeliveredDetail();
				//dd.shipmentStatus = shipment.zkmulti__Tracking_Stage__c;
				dd.shipmentStatus = shipment.zkmulti__Status_Description__c;
				dd.trackingNumber = shipment.Order_Tracking_Number__r.Tracking_Number__c;
				dd.trackingNumberLink = shipment.Order_Tracking_Number__r.Tracking_Number_Link__c;
				dd.orderId = shipment.Order__c;
				dd.salesOrderId = shipment.Sales_Order__c;
				dd.shipmentId = shipment.Id;
				dd.orderLineId = shipment.Order_Tracking_Number__r.Line_ID__c;

				lineIdToDeliveredDetail.put(shipment.Order_Tracking_Number__r.Line_ID__c, dd);
				orderIds.add(shipment.Order__c);

		} //END: for(zkmulti__MCShipment__c shipment

		system.debug('DC: lineIdToDeliveredDetail: ' + lineIdToDeliveredDetail);
		system.debug('DC: orderIds: ' + orderIds);
		system.debug('DC: lineIdToDeliveredDetail.keySet(): ' + lineIdToDeliveredDetail.keySet());

		//Now, query for the other line item details - price, quantity, etc.
		for(Order_Line_Item__c oli : [SELECT Id, 
										CC_Prod_Alternate_Name__c,	
										CC_Product__c,
										Product_Code__c, //This is the SKU
										Unit_Selling_Price__c,
										Shipped_Quantity__c,
										Line_Id__c,
										Order__c,
										Ordered_Item_Lookup__c,
										Ordered_Item_Lookup__r.Name
									FROM Order_Line_Item__c
									WHERE Line_Id__c IN :lineIdToDeliveredDetail.keySet()
									AND Order__c IN :orderIds]) {
			DeliveredDetail dd = lineIdToDeliveredDetail.get(oli.Line_Id__c);
			if(dd != null) {
				//dd.productImage = shipment.
				if(oli.CC_Product__c == null) {
					//Use the Ordered_Item_Lookup__c instead
					dd.productName = oli.Ordered_Item_Lookup__r.Name;
				} else {
					dd.productName = oli.CC_Prod_Alternate_Name__c; 
					dd.productId = oli.CC_Product__c;
				}
				
				dd.productSKU = oli.Product_Code__c;
				dd.quantity = oli.Shipped_Quantity__c;
				dd.price = oli.Unit_Selling_Price__c;
				
				lineIdToDeliveredDetail.put(oli.Line_Id__c, dd);
			}
			productIds.add(oli.CC_Product__c);
			productSKUs.add(oli.Product_Code__c);
		} //END: for(Order_Line_Item__c oli

		system.debug('DC: lineIdToDeliveredDetail: ' + lineIdToDeliveredDetail);
		system.debug('DC: productIds: ' + productIds);
		system.debug('DC: lineIdToDeliveredDetail.keySet(): ' + lineIdToDeliveredDetail.keySet());

		//Now, we need to find the product image
		for(ccrz__E_ProductMedia__c imgs : [SELECT ccrz__URI__c, ccrz__Product__c, ccrz__Product__r.ccrz__SKU__c FROM ccrz__E_ProductMedia__c 
															WHERE (ccrz__Product__c IN :productIds
																OR ccrz__Product__r.ccrz__SKU__c IN :productSKUs)
															AND ccrz__Enabled__c = true
															AND ccrz__StartDate__c <= TODAY
															AND ccrz__EndDate__c >= TODAY]) {
			productIdToImage.put(imgs.ccrz__Product__c, imgs.ccrz__URI__c);					
			productSKUToImage.put(imgs.ccrz__Product__r.ccrz__SKU__c, imgs.ccrz__URI__c);										
		} //END: for(ccrz__E_ProductMedia__c imgs

		//One more loop through the map to set the URL for the image
		for(String lineId : lineIdToDeliveredDetail.keySet()) {
			DeliveredDetail dd = lineIdToDeliveredDetail.get(lineId);
			if(dd != null) {
				String tmpUrl;
				if(dd.productId != null) {
					tmpUrl = productIdToImage.get(dd.productId);
				}
				if(tmpUrl == null && dd.productSKU != null) {
					tmpUrl = productSKUToImage.get(dd.productSKU);
				}
				if(tmpUrl != null) {
					dd.productImage = tmpUrl;	
					lineIdToDeliveredDetail.put(lineId, dd);
				}
			} //END: if(dd != null)
		} //END: for(String lineId : lineIdToDeliveredDetail.keySet())

		return lineIdToDeliveredDetail.values();

	} //END: public List<DeliveredDetail> getDeliveredDetailsList()

	public class DeliveredDetail {
		public String productImage {get; set;}
		public String productName {get; set;}
		public String productSKU { get; set;}
		public Decimal quantity { get; set;}
		public Decimal price  { get; set;}
		public String shipmentStatus  { get; set;}
		public String trackingNumber  { get; set;}
		public String trackingNumberLink  { get; set;}
		public Id orderId  { get; set;}
		public Id salesOrderId  { get; set;}
		public Id shipmentId  { get; set;}
		public Id productId { get; set; }
		public String orderLineId { get; set;}
	}
}