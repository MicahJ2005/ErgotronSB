/**
 * @description       : 
 * @author            : Nandika Sharma
 * @group             : Docmation LLC
 * @last modified on  : 06-15-2022
**/
public class ERGB2B_OrderWrapper {

	public class Pricing_Z {
		public Subtotal listPrice {get;set;} 
		public Subtotal listPriceWithQuantity {get;set;} 
		public Subtotal salePriceWithQuantity {get;set;} 
		public String formattedListPrice {get;set;} 
		public String formattedListPriceWithQuantity {get;set;} 
		public String formattedSalePriceWithQuantity {get;set;} 
		public Tax productTax {get;set;} 
		public Subtotal shippingTax {get;set;} 
		public Subtotal feeTax {get;set;} 
		public Double taxRate {get;set;} 
		public Subtotal importTax {get;set;} 
		public String formattedImportTax {get;set;} 
		public Subtotal importDuty {get;set;} 
		public String formattedImportDuty {get;set;} 

		public Pricing_Z(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'listPrice') {
							listPrice = new Subtotal(parser);
						} else if (text == 'listPriceWithQuantity') {
							listPriceWithQuantity = new Subtotal(parser);
						} else if (text == 'salePriceWithQuantity') {
							salePriceWithQuantity = new Subtotal(parser);
						} else if (text == 'formattedListPrice') {
							formattedListPrice = parser.getText();
						} else if (text == 'formattedListPriceWithQuantity') {
							formattedListPriceWithQuantity = parser.getText();
						} else if (text == 'formattedSalePriceWithQuantity') {
							formattedSalePriceWithQuantity = parser.getText();
						} else if (text == 'productTax') {
							productTax = new Tax(parser);
						} else if (text == 'shippingTax') {
							shippingTax = new Subtotal(parser);
						} else if (text == 'feeTax') {
							feeTax = new Subtotal(parser);
						} else if (text == 'taxRate') {
							taxRate = parser.getDoubleValue();
						} else if (text == 'importTax') {
							importTax = new Subtotal(parser);
						} else if (text == 'formattedImportTax') {
							formattedImportTax = parser.getText();
						} else if (text == 'importDuty') {
							importDuty = new Subtotal(parser);
						} else if (text == 'formattedImportDuty') {
							formattedImportDuty = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Pricing_Z consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Order {
		public String uri {get;set;} 
		public Long id {get;set;} 
		public String submissionDate {get;set;} 
		public String displayName {get;set;} 
		public String businessEntityCode {get;set;} 
		public String taxInclusive {get;set;} 
		public String landedCostState {get;set;} 
		public Pricing pricing {get;set;} 
		public PaymentMethod paymentMethod {get;set;} 
		public ShippingMethod shippingMethod {get;set;} 
		public String orderState {get;set;} 
		public BillingAddress billingAddress {get;set;} 
		public BillingAddress shippingAddress {get;set;} 
		public String skipOfferArbitration {get;set;} 
		public List<CustomDescription> customDescription {get;set;} 
		public LineItems lineItems {get;set;} 
		public PaymentSession paymentSession {get;set;} 

		public Order(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'uri') {
							uri = parser.getText();
						} else if (text == 'id') {
							id = parser.getLongValue();
						} else if (text == 'submissionDate') {
							submissionDate = parser.getText();
						} else if (text == 'displayName') {
							displayName = parser.getText();
						} else if (text == 'businessEntityCode') {
							businessEntityCode = parser.getText();
						} else if (text == 'taxInclusive') {
							taxInclusive = parser.getText();
						} else if (text == 'landedCostState') {
							landedCostState = parser.getText();
						} else if (text == 'pricing') {
							pricing = new Pricing(parser);
						} else if (text == 'paymentMethod') {
							paymentMethod = new PaymentMethod(parser);
						} else if (text == 'shippingMethod') {
							shippingMethod = new ShippingMethod(parser);
						} else if (text == 'orderState') {
							orderState = parser.getText();
						} else if (text == 'billingAddress') {
							billingAddress = new BillingAddress(parser);
						} else if (text == 'shippingAddress') {
							shippingAddress = new BillingAddress(parser);
						} else if (text == 'skipOfferArbitration') {
							skipOfferArbitration = parser.getText();
						} else if (text == 'customDescription') {
							customDescription = arrayOfCustomDescription(parser);
						} else if (text == 'lineItems') {
							lineItems = new LineItems(parser);
						} else if (text == 'paymentSession') {
							paymentSession = new PaymentSession(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Order consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class PayPal {
		public String payerId {get;set;} 
		public String clientSecret {get;set;} 
		public String payerStatus {get;set;} 
		public String flow {get;set;} 
		public String reusable {get;set;} 
		public String token {get;set;} 

		public PayPal(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'payerId') {
							payerId = parser.getText();
						} else if (text == 'clientSecret') {
							clientSecret = parser.getText();
						} else if (text == 'payerStatus') {
							payerStatus = parser.getText();
						} else if (text == 'flow') {
							flow = parser.getText();
						} else if (text == 'reusable') {
							reusable = parser.getText();
						} else if (text == 'token') {
							token = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'PayPal consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class ShippingMethod {

		public ShippingMethod(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						{
							System.debug(LoggingLevel.WARN, 'ShippingMethod consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class LineItems {
		public String uri {get;set;} 
		public List<LineItem> lineItem {get;set;} 

		public LineItems(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'uri') {
							uri = parser.getText();
						} else if (text == 'lineItem') {
							lineItem = arrayOfLineItem(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'LineItems consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Subtotal {
		public String currency_Z {get;set;} // in json: currency
		public Integer value {get;set;} 

		public Subtotal(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'currency') {
							currency_Z = parser.getText();
						} else if (text == 'value') {
							value = parser.getIntegerValue();
						} else {
							System.debug(LoggingLevel.WARN, 'Subtotal consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Product {
		public String uri {get;set;} 
		public String displayName {get;set;} 
		public Object thumbnailImage {get;set;} 

		public Product(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'uri') {
							uri = parser.getText();
						} else if (text == 'displayName') {
							displayName = parser.getText();
						} else if (text == 'thumbnailImage') {
							thumbnailImage = parser.readValueAs(Object.class);
						} else {
							System.debug(LoggingLevel.WARN, 'Product consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class LineItem {
		public String uri {get;set;} 
		public Long id {get;set;} 
		public Integer quantity {get;set;} 
		public Product product {get;set;} 
		public String lineItemState {get;set;} 
		public LineItemStateDetails lineItemStateDetails {get;set;} 
		public Pricing_Z pricing {get;set;} 
		public ShippingMethod downloads {get;set;} 
		public ShippingMethod digitalRights {get;set;} 

		public LineItem(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'uri') {
							uri = parser.getText();
						} else if (text == 'id') {
							id = parser.getLongValue();
						} else if (text == 'quantity') {
							quantity = parser.getIntegerValue();
						} else if (text == 'product') {
							product = new Product(parser);
						} else if (text == 'lineItemState') {
							lineItemState = parser.getText();
						} else if (text == 'lineItemStateDetails') {
							lineItemStateDetails = new LineItemStateDetails(parser);
						} else if (text == 'pricing') {
							pricing = new Pricing_Z(parser);
						} else if (text == 'downloads') {
							downloads = new ShippingMethod(parser);
						} else if (text == 'digitalRights') {
							digitalRights = new ShippingMethod(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'LineItem consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Tax {
		public String currency_Z {get;set;} // in json: currency
		public Double value {get;set;} 

		public Tax(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'currency') {
							currency_Z = parser.getText();
						} else if (text == 'value') {
							value = parser.getDoubleValue();
						} else {
							System.debug(LoggingLevel.WARN, 'Tax consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class CustomDescription {
		public Long offerId {get;set;} 
		public Object externalReferenceId {get;set;} 
		public String customDescription {get;set;} 

		public CustomDescription(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'offerId') {
							offerId = parser.getLongValue();
						} else if (text == 'externalReferenceId') {
							externalReferenceId = parser.readValueAs(Object.class);
						} else if (text == 'customDescription') {
							customDescription = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'CustomDescription consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class PaymentSession {
		public String id {get;set;} 
		public String clientSecret {get;set;} 
		public String status {get;set;} 

		public PaymentSession(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getText();
						} else if (text == 'clientSecret') {
							clientSecret = parser.getText();
						} else if (text == 'status') {
							status = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'PaymentSession consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class BillingAddress {
		public String uri {get;set;} 

		public BillingAddress(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'uri') {
							uri = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'BillingAddress consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class LineItemStateDetails {
		public Object description {get;set;} 
		public Integer backOrdered {get;set;} 
		public Integer shipped {get;set;} 
		public Integer returned {get;set;} 
		public Integer pendingReturn {get;set;} 

		public LineItemStateDetails(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'description') {
							description = parser.readValueAs(Object.class);
						} else if (text == 'backOrdered') {
							backOrdered = parser.getIntegerValue();
						} else if (text == 'shipped') {
							shipped = parser.getIntegerValue();
						} else if (text == 'returned') {
							returned = parser.getIntegerValue();
						} else if (text == 'pendingReturn') {
							pendingReturn = parser.getIntegerValue();
						} else {
							System.debug(LoggingLevel.WARN, 'LineItemStateDetails consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public Order order {get;set;} 

	public ERGB2B_OrderWrapper(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'order') {
						order = new Order(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'ERGB2B_OrderWrapper consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class Pricing {
		public Subtotal subtotal {get;set;} 
		public Subtotal subtotalWithDiscount {get;set;} 
		public Subtotal incentive {get;set;} 
		public Subtotal shipping {get;set;} 
		public Tax tax {get;set;} 
		public Subtotal importTaxAndDuty {get;set;} 
		public Tax total {get;set;} 
		public String formattedSubtotal {get;set;} 
		public String formattedSubtotalWithDiscount {get;set;} 
		public String formattedIncentive {get;set;} 
		public String formattedShipping {get;set;} 
		public String formattedTax {get;set;} 
		public String formattedImportTaxAndDuty {get;set;} 
		public String formattedTotal {get;set;} 

		public Pricing(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'subtotal') {
							subtotal = new Subtotal(parser);
						} else if (text == 'subtotalWithDiscount') {
							subtotalWithDiscount = new Subtotal(parser);
						} else if (text == 'incentive') {
							incentive = new Subtotal(parser);
						} else if (text == 'shipping') {
							shipping = new Subtotal(parser);
						} else if (text == 'tax') {
							tax = new Tax(parser);
						} else if (text == 'importTaxAndDuty') {
							importTaxAndDuty = new Subtotal(parser);
						} else if (text == 'total') {
							total = new Tax(parser);
						} else if (text == 'formattedSubtotal') {
							formattedSubtotal = parser.getText();
						} else if (text == 'formattedSubtotalWithDiscount') {
							formattedSubtotalWithDiscount = parser.getText();
						} else if (text == 'formattedIncentive') {
							formattedIncentive = parser.getText();
						} else if (text == 'formattedShipping') {
							formattedShipping = parser.getText();
						} else if (text == 'formattedTax') {
							formattedTax = parser.getText();
						} else if (text == 'formattedImportTaxAndDuty') {
							formattedImportTaxAndDuty = parser.getText();
						} else if (text == 'formattedTotal') {
							formattedTotal = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Pricing consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	public class CreditCard {
		public String expirationYear {get;set;} 
		public String lastFourDigits {get;set;} 
		public String clientSecret {get;set;} 
		public String expirationMonth {get;set;} 
		public String brand {get;set;} 
		public String flow {get;set;} 
		public String reusable {get;set;} 

		public CreditCard(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'expirationYear') {
							expirationYear = parser.getText();
						} else if (text == 'lastFourDigits') {
							lastFourDigits = parser.getText();
						} else if (text == 'clientSecret') {
							clientSecret = parser.getText();
						} else if (text == 'expirationMonth') {
							expirationMonth = parser.getText();
						} else if (text == 'brand') {
							brand = parser.getText();
						} else if (text == 'flow') {
							flow = parser.getText();
						} else if (text == 'reusable') {
							reusable = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'CreditCard consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class PaymentMethod {
		public String type {get;set;} 
		public String sourceId {get;set;} 
		public String sourceClientSecret {get;set;} 
		public PayPal payPal {get;set;} 
		public CreditCard creditCard {get;set;} 

		public PaymentMethod(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'type') {
							type = parser.getText();
						} else if (text == 'sourceId') {
							sourceId = parser.getText();
						} else if (text == 'sourceClientSecret') {
							sourceClientSecret = parser.getText();
						} else if (text == 'payPal') {
							payPal = new PayPal(parser);
						} else if (text == 'creditCard') {
							creditCard = new CreditCard(parser);
						}else {
							System.debug(LoggingLevel.WARN, 'PaymentMethod consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	public static ERGB2B_OrderWrapper parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new ERGB2B_OrderWrapper(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	












    private static List<LineItem> arrayOfLineItem(System.JSONParser p) {
        List<LineItem> res = new List<LineItem>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new LineItem(p));
        }
        return res;
    }











    private static List<CustomDescription> arrayOfCustomDescription(System.JSONParser p) {
        List<CustomDescription> res = new List<CustomDescription>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new CustomDescription(p));
        }
        return res;
    }


}