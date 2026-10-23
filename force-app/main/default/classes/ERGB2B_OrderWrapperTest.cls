/**
 * @description       : 
 * @author            : Nandika Sharma
 * @group             : 
 * @last modified on  : 06-21-2022
 * @last modified by  : Nandika Sharma
**/
@IsTest
public class ERGB2B_OrderWrapperTest {

	public static String ORDER_JSON = '{\"order\":{\"uri\":\"http://api-cte-ext.digitalriver.com/v1/shoppers/me/orders/111035620016\",\"id\":111035620016,\"submissionDate\":\"2022-06-07T14:39:18.000Z\",\"displayName\":\"New Order\",\"businessEntityCode\":\"DR_INC-ENTITY\",\"taxInclusive\":\"false\",\"landedCostState\":\"NOT_ELIGIBLE\",\"pricing\":{\"subtotal\":{\"currency\":\"USD\",\"value\":335},\"subtotalWithDiscount\":{\"currency\":\"USD\",\"value\":335},\"incentive\":{\"currency\":\"USD\",\"value\":0},\"shipping\":{\"currency\":\"USD\",\"value\":0},\"tax\":{\"currency\":\"USD\",\"value\":29.31},\"importTaxAndDuty\":{\"currency\":\"USD\",\"value\":0},\"total\":{\"currency\":\"USD\",\"value\":364.31},\"formattedSubtotal\":\"$335.00\",\"formattedSubtotalWithDiscount\":\"$335.00\",\"formattedIncentive\":\"$0.00\",\"formattedShipping\":\"$0.00\",\"formattedTax\":\"$29.31\",\"formattedImportTaxAndDuty\":\"$0.00\",\"formattedTotal\":\"$364.31\"},\"paymentMethod\":{\"type\":\"payPal\",\"sourceId\":\"80b5cf57-6c3a-423a-bd5a-fb8bb599de9e\",\"sourceClientSecret\":\"80b5cf57-6c3a-423a-bd5a-fb8bb599de9e_ed6e68f4-bf2c-40db-a868-ccaabde1d6d3\",\"payPal\":{\"payerId\":\"LERLXNVSS3KY8\",\"clientSecret\":\"80b5cf57-6c3a-423a-bd5a-fb8bb599de9e_ed6e68f4-bf2c-40db-a868-ccaabde1d6d3\",\"payerStatus\":\"verified\",\"flow\":\"redirect\",\"reusable\":\"false\",\"token\":\"EC-12F64045PK716591E\"}},\"shippingMethod\":{},\"orderState\":\"Submitted\",\"billingAddress\":{\"uri\":\"http://api-cte-ext.digitalriver.com/v1/shoppers/me/orders/111035620016/billing-address\"},\"shippingAddress\":{\"uri\":\"http://api-cte-ext.digitalriver.com/v1/shoppers/me/orders/111035620016/shipping-address\"},\"skipOfferArbitration\":\"true\",\"customDescription\":[{\"offerId\":62915936501,\"externalReferenceId\":null,\"customDescription\":\"CloudCraze Discount\"}],\"lineItems\":{\"uri\":\"http://api-cte-ext.digitalriver.com/v1/shoppers/me/orders/111035620016/line-items\",\"lineItem\":[{\"uri\":\"http://api-cte-ext.digitalriver.com/v1/shoppers/me/orders/111035620016/line-items/1106737850016\",\"id\":1106737850016,\"quantity\":1,\"product\":{\"uri\":\"http://api-cte-ext.digitalriver.com/v1/shoppers/me/products/5486078400\",\"displayName\":\"HX Wall Monitor Arm, White\",\"thumbnailImage\":null},\"lineItemState\":\"Electronic Fulfillment Pending\",\"lineItemStateDetails\":{\"description\":null,\"backOrdered\":0,\"shipped\":0,\"returned\":0,\"pendingReturn\":0},\"pricing\":{\"listPrice\":{\"currency\":\"USD\",\"value\":335},\"listPriceWithQuantity\":{\"currency\":\"USD\",\"value\":335},\"salePriceWithQuantity\":{\"currency\":\"USD\",\"value\":335},\"formattedListPrice\":\"$335.00\",\"formattedListPriceWithQuantity\":\"$335.00\",\"formattedSalePriceWithQuantity\":\"$335.00\",\"productTax\":{\"currency\":\"USD\",\"value\":29.31},\"shippingTax\":{\"currency\":\"USD\",\"value\":0},\"feeTax\":{\"currency\":\"USD\",\"value\":0},\"taxRate\":0.0875,\"importTax\":{\"currency\":\"USD\",\"value\":0},\"formattedImportTax\":\"$0.00\",\"importDuty\":{\"currency\":\"USD\",\"value\":0},\"formattedImportDuty\":\"$0.00\"},\"downloads\":{},\"digitalRights\":{}}]},\"paymentSession\":{\"id\":\"7fcf2ae0-7170-485a-9bf1-7d2ea0b3713a\",\"clientSecret\":\"7fcf2ae0-7170-485a-9bf1-7d2ea0b3713a_56419d21-369a-41fb-8e47-5bc1d026104c\",\"status\":\"chargeable\"}}}';
	public static String ORDER_CC_JSON = '{'+
	'  \"order\": {'+
	'    \"uri\": \"http://api-cte-ext.digitalriver.com/v1/shoppers/me/orders/113005090016\",'+
	'    \"id\": 113005090016,'+
	'    \"submissionDate\": \"2022-06-15T09:34:27.000Z\",'+
	'    \"displayName\": \"New Order\",'+
	'    \"businessEntityCode\": \"DR_INC-ENTITY\",'+
	'    \"taxInclusive\": \"false\",'+
	'    \"landedCostState\": \"NOT_ELIGIBLE\",'+
	'    \"pricing\": {'+
	'      \"subtotal\": {'+
	'        \"currency\": \"USD\",'+
	'        \"value\": 205'+
	'      },'+
	'      \"subtotalWithDiscount\": {'+
	'        \"currency\": \"USD\",'+
	'        \"value\": 205'+
	'      },'+
	'      \"incentive\": {'+
	'        \"currency\": \"USD\",'+
	'        \"value\": 0'+
	'      },'+
	'      \"shipping\": {'+
	'        \"currency\": \"USD\",'+
	'        \"value\": 0'+
	'      },'+
	'      \"tax\": {'+
	'        \"currency\": \"USD\",'+
	'        \"value\": 17.94'+
	'      },'+
	'      \"importTaxAndDuty\": {'+
	'        \"currency\": \"USD\",'+
	'        \"value\": 0'+
	'      },'+
	'      \"total\": {'+
	'        \"currency\": \"USD\",'+
	'        \"value\": 222.94'+
	'      },'+
	'      \"formattedSubtotal\": \"$205.00\",'+
	'      \"formattedSubtotalWithDiscount\": \"$205.00\",'+
	'      \"formattedIncentive\": \"$0.00\",'+
	'      \"formattedShipping\": \"$0.00\",'+
	'      \"formattedTax\": \"$17.94\",'+
	'      \"formattedImportTaxAndDuty\": \"$0.00\",'+
	'      \"formattedTotal\": \"$222.94\"'+
	'    },'+
	'    \"paymentMethod\": {'+
	'      \"type\": \"creditCard\",'+
	'      \"sourceId\": \"472165b5-b5c2-4ac4-82b1-8e6368f08d86\",'+
	'      \"sourceClientSecret\": \"472165b5-b5c2-4ac4-82b1-8e6368f08d86_13613ecf-3905-49a3-a8a3-ebe9af4be86d\",'+
	'      \"creditCard\": {'+
	'        \"expirationYear\": \"2027\",'+
	'        \"lastFourDigits\": \"1111\",'+
	'        \"clientSecret\": \"472165b5-b5c2-4ac4-82b1-8e6368f08d86_13613ecf-3905-49a3-a8a3-ebe9af4be86d\",'+
	'        \"expirationMonth\": \"6\",'+
	'        \"brand\": \"Visa\",'+
	'        \"flow\": \"standard\",'+
	'        \"reusable\": \"false\"'+
	'      }'+
	'    },'+
	'    \"shippingMethod\": {},'+
	'    \"orderState\": \"Submitted\",'+
	'    \"billingAddress\": {'+
	'      \"uri\": \"http://api-cte-ext.digitalriver.com/v1/shoppers/me/orders/113005090016/billing-address\"'+
	'    },'+
	'    \"shippingAddress\": {'+
	'      \"uri\": \"http://api-cte-ext.digitalriver.com/v1/shoppers/me/orders/113005090016/shipping-address\"'+
	'    },'+
	'    \"skipOfferArbitration\": \"true\",'+
	'    \"customDescription\": ['+
	'      {'+
	'        \"offerId\": 62915936501,'+
	'        \"externalReferenceId\": null,'+
	'        \"customDescription\": \"CloudCraze Discount\"'+
	'      }'+
	'    ],'+
	'    \"lineItems\": {'+
	'      \"uri\": \"http://api-cte-ext.digitalriver.com/v1/shoppers/me/orders/113005090016/line-items\",'+
	'      \"lineItem\": ['+
	'        {'+
	'          \"uri\": \"http://api-cte-ext.digitalriver.com/v1/shoppers/me/orders/113005090016/line-items/1106883320016\",'+
	'          \"id\": 1106883320016,'+
	'          \"quantity\": 1,'+
	'          \"product\": {'+
	'            \"uri\": \"http://api-cte-ext.digitalriver.com/v1/shoppers/me/products/5487615800\",'+
	'            \"displayName\": \"LX Wall Mount LCD Arm\",'+
	'            \"thumbnailImage\": null'+
	'          },'+
	'          \"lineItemState\": \"Electronic Fulfillment Pending\",'+
	'          \"lineItemStateDetails\": {'+
	'            \"description\": null,'+
	'            \"backOrdered\": 0,'+
	'            \"shipped\": 0,'+
	'            \"returned\": 0,'+
	'            \"pendingReturn\": 0'+
	'          },'+
	'          \"pricing\": {'+
	'            \"listPrice\": {'+
	'              \"currency\": \"USD\",'+
	'              \"value\": 205'+
	'            },'+
	'            \"listPriceWithQuantity\": {'+
	'              \"currency\": \"USD\",'+
	'              \"value\": 205'+
	'            },'+
	'            \"salePriceWithQuantity\": {'+
	'              \"currency\": \"USD\",'+
	'              \"value\": 205'+
	'            },'+
	'            \"formattedListPrice\": \"$205.00\",'+
	'            \"formattedListPriceWithQuantity\": \"$205.00\",'+
	'            \"formattedSalePriceWithQuantity\": \"$205.00\",'+
	'            \"productTax\": {'+
	'              \"currency\": \"USD\",'+
	'              \"value\": 17.94'+
	'            },'+
	'            \"shippingTax\": {'+
	'              \"currency\": \"USD\",'+
	'              \"value\": 0'+
	'            },'+
	'            \"feeTax\": {'+
	'              \"currency\": \"USD\",'+
	'              \"value\": 0'+
	'            },'+
	'            \"taxRate\": 0.0875,'+
	'            \"importTax\": {'+
	'              \"currency\": \"USD\",'+
	'              \"value\": 0'+
	'            },'+
	'            \"formattedImportTax\": \"$0.00\",'+
	'            \"importDuty\": {'+
	'              \"currency\": \"USD\",'+
	'              \"value\": 0'+
	'            },'+
	'            \"formattedImportDuty\": \"$0.00\"'+
	'          },'+
	'          \"downloads\": {},'+
	'          \"digitalRights\": {}'+
	'        }'+
	'      ]'+
	'    },'+
	'    \"paymentSession\": {'+
	'      \"id\": \"b7ee26a1-ba9d-4e4e-9650-45ed70d36d8c\",'+
	'      \"clientSecret\": \"b7ee26a1-ba9d-4e4e-9650-45ed70d36d8c_a503eaad-24de-4e2b-8331-3f1d8a4800ed\",'+
	'      \"status\": \"chargeable\"'+
	'    }'+
	'  }'+
	'}';
	static testMethod void testParse() {
		String json = ORDER_JSON;
		ERGB2B_OrderWrapper r = ERGB2B_OrderWrapper.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ERGB2B_OrderWrapper.Pricing_Z objPricing_Z = new ERGB2B_OrderWrapper.Pricing_Z(System.JSON.createParser(json));
		System.assert(objPricing_Z != null);
		System.assert(objPricing_Z.listPrice == null);
		System.assert(objPricing_Z.listPriceWithQuantity == null);
		System.assert(objPricing_Z.salePriceWithQuantity == null);
		System.assert(objPricing_Z.formattedListPrice == null);
		System.assert(objPricing_Z.formattedListPriceWithQuantity == null);
		System.assert(objPricing_Z.formattedSalePriceWithQuantity == null);
		System.assert(objPricing_Z.productTax == null);
		System.assert(objPricing_Z.shippingTax == null);
		System.assert(objPricing_Z.feeTax == null);
		System.assert(objPricing_Z.taxRate == null);
		System.assert(objPricing_Z.importTax == null);
		System.assert(objPricing_Z.formattedImportTax == null);
		System.assert(objPricing_Z.importDuty == null);
		System.assert(objPricing_Z.formattedImportDuty == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ERGB2B_OrderWrapper.Order objOrder = new ERGB2B_OrderWrapper.Order(System.JSON.createParser(json));
		System.assert(objOrder != null);
		System.assert(objOrder.uri == null);
		System.assert(objOrder.id == null);
		System.assert(objOrder.submissionDate == null);
		System.assert(objOrder.displayName == null);
		System.assert(objOrder.businessEntityCode == null);
		System.assert(objOrder.taxInclusive == null);
		System.assert(objOrder.landedCostState == null);
		System.assert(objOrder.pricing == null);
		System.assert(objOrder.paymentMethod == null);
		System.assert(objOrder.shippingMethod == null);
		System.assert(objOrder.orderState == null);
		System.assert(objOrder.billingAddress == null);
		System.assert(objOrder.shippingAddress == null);
		System.assert(objOrder.skipOfferArbitration == null);
		System.assert(objOrder.customDescription == null);
		System.assert(objOrder.lineItems == null);
		System.assert(objOrder.paymentSession == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ERGB2B_OrderWrapper.PayPal objPayPal = new ERGB2B_OrderWrapper.PayPal(System.JSON.createParser(json));
		System.assert(objPayPal != null);
		System.assert(objPayPal.payerId == null);
		System.assert(objPayPal.clientSecret == null);
		System.assert(objPayPal.payerStatus == null);
		System.assert(objPayPal.flow == null);
		System.assert(objPayPal.reusable == null);
		System.assert(objPayPal.token == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ERGB2B_OrderWrapper.ShippingMethod objShippingMethod = new ERGB2B_OrderWrapper.ShippingMethod(System.JSON.createParser(json));
		System.assert(objShippingMethod != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ERGB2B_OrderWrapper.LineItems objLineItems = new ERGB2B_OrderWrapper.LineItems(System.JSON.createParser(json));
		System.assert(objLineItems != null);
		System.assert(objLineItems.uri == null);
		System.assert(objLineItems.lineItem == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ERGB2B_OrderWrapper.Subtotal objSubtotal = new ERGB2B_OrderWrapper.Subtotal(System.JSON.createParser(json));
		System.assert(objSubtotal != null);
		System.assert(objSubtotal.currency_Z == null);
		System.assert(objSubtotal.value == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ERGB2B_OrderWrapper.Product objProduct = new ERGB2B_OrderWrapper.Product(System.JSON.createParser(json));
		System.assert(objProduct != null);
		System.assert(objProduct.uri == null);
		System.assert(objProduct.displayName == null);
		System.assert(objProduct.thumbnailImage == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ERGB2B_OrderWrapper.LineItem objLineItem = new ERGB2B_OrderWrapper.LineItem(System.JSON.createParser(json));
		System.assert(objLineItem != null);
		System.assert(objLineItem.uri == null);
		System.assert(objLineItem.id == null);
		System.assert(objLineItem.quantity == null);
		System.assert(objLineItem.product == null);
		System.assert(objLineItem.lineItemState == null);
		System.assert(objLineItem.lineItemStateDetails == null);
		System.assert(objLineItem.pricing == null);
		System.assert(objLineItem.downloads == null);
		System.assert(objLineItem.digitalRights == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ERGB2B_OrderWrapper.Tax objTax = new ERGB2B_OrderWrapper.Tax(System.JSON.createParser(json));
		System.assert(objTax != null);
		System.assert(objTax.currency_Z == null);
		System.assert(objTax.value == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ERGB2B_OrderWrapper.CustomDescription objCustomDescription = new ERGB2B_OrderWrapper.CustomDescription(System.JSON.createParser(json));
		System.assert(objCustomDescription != null);
		System.assert(objCustomDescription.offerId == null);
		System.assert(objCustomDescription.externalReferenceId == null);
		System.assert(objCustomDescription.customDescription == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ERGB2B_OrderWrapper.PaymentSession objPaymentSession = new ERGB2B_OrderWrapper.PaymentSession(System.JSON.createParser(json));
		System.assert(objPaymentSession != null);
		System.assert(objPaymentSession.id == null);
		System.assert(objPaymentSession.clientSecret == null);
		System.assert(objPaymentSession.status == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ERGB2B_OrderWrapper.BillingAddress objBillingAddress = new ERGB2B_OrderWrapper.BillingAddress(System.JSON.createParser(json));
		System.assert(objBillingAddress != null);
		System.assert(objBillingAddress.uri == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ERGB2B_OrderWrapper.LineItemStateDetails objLineItemStateDetails = new ERGB2B_OrderWrapper.LineItemStateDetails(System.JSON.createParser(json));
		System.assert(objLineItemStateDetails != null);
		System.assert(objLineItemStateDetails.description == null);
		System.assert(objLineItemStateDetails.backOrdered == null);
		System.assert(objLineItemStateDetails.shipped == null);
		System.assert(objLineItemStateDetails.returned == null);
		System.assert(objLineItemStateDetails.pendingReturn == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ERGB2B_OrderWrapper objERGB2B_OrderWrapper = new ERGB2B_OrderWrapper(System.JSON.createParser(json));
		System.assert(objERGB2B_OrderWrapper != null);
		System.assert(objERGB2B_OrderWrapper.order == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ERGB2B_OrderWrapper.Pricing objPricing = new ERGB2B_OrderWrapper.Pricing(System.JSON.createParser(json));
		System.assert(objPricing != null);
		System.assert(objPricing.subtotal == null);
		System.assert(objPricing.subtotalWithDiscount == null);
		System.assert(objPricing.incentive == null);
		System.assert(objPricing.shipping == null);
		System.assert(objPricing.tax == null);
		System.assert(objPricing.importTaxAndDuty == null);
		System.assert(objPricing.total == null);
		System.assert(objPricing.formattedSubtotal == null);
		System.assert(objPricing.formattedSubtotalWithDiscount == null);
		System.assert(objPricing.formattedIncentive == null);
		System.assert(objPricing.formattedShipping == null);
		System.assert(objPricing.formattedTax == null);
		System.assert(objPricing.formattedImportTaxAndDuty == null);
		System.assert(objPricing.formattedTotal == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ERGB2B_OrderWrapper.PaymentMethod objPaymentMethod = new ERGB2B_OrderWrapper.PaymentMethod(System.JSON.createParser(json));
		System.assert(objPaymentMethod != null);
		System.assert(objPaymentMethod.type == null);
		System.assert(objPaymentMethod.sourceId == null);
		System.assert(objPaymentMethod.sourceClientSecret == null);
		System.assert(objPaymentMethod.payPal == null);
	}
}