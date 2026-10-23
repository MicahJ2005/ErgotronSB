/*
	Utility class to handle operations performed on the Product2 object.

	MOD DATE		Who						Description
	2/10/2014		Chris Noe				Initial Release
	6/30/2014		Chris Noe				Removed add pricebook entries method for customer care pricebook.  Removed update logic for standard pricebook entries.  Updated addStandardPricebookEntries method
											to set unit price to 0 for each currency enabled.
	7/15/2014		Chris Noe				Added method setDefaultSchedules to set the default quantity and revenue schedule on a new product.
*/

public with sharing class Product2_Utility {
	//Utility class for Product2 object.  Methods in this class may be called from triggers on the Product2 object or by other classes.
	
	public static void addStandardPricebookEntries(List<Product2> listProducts) {
		//This method adds a $0 standard pricebook entry record for each enabled currency for each product passed into this method.
		//All Product2 records require an active standard price book entry before they can be added to a custom price book.
		
		//Method variables.
		Pricebook2 oStandardPricebook = new Pricebook2();
		List<CurrencyType> listActiveCurrencies = new List<CurrencyType>();
		List<PricebookEntry> listPricebookEntries = new List<PricebookEntry>();
		
		//Retrieve standard price book.
		try {
			oStandardPricebook = [select Id from Pricebook2 where IsStandard=true limit 1];	
		} 
		
		catch (Exception oException) {
			system.debug('Error retrieving standard pricebook. ' + oException.getMessage());
			return;
		}
		
		//Retrieve active currencies and conversion rates.
		listActiveCurrencies = [select ConversionRate, IsCorporate, IsoCode from CurrencyType where IsActive=true];
		
		//Loop through each product passed into the method and add a $0 standard price book entry for each enabled currency.
		for(Product2 oProduct :listProducts) {
			//Loop through each enabled currency and add a $0 standard price book entry to this product and currency combination.
			for(CurrencyType oCurrencyType :listActiveCurrencies) {
				PricebookEntry oPBENew = new PricebookEntry();
				oPBENew.IsActive=true;
				oPBENew.Pricebook2Id=oStandardPricebook.Id;
				oPBENew.Product2Id=oProduct.Id;
				oPBENew.UnitPrice=0.0;
				oPBENew.UseStandardPrice=false;
				oPBENew.CurrencyIsoCode=oCurrencyType.IsoCode;
				
				listPricebookEntries.add(oPBENew);
			}
		}	
		
		//Insert standard pricebook entries		
		if(!listPricebookEntries.isEmpty()) {
			insert listPricebookEntries;
		}		
	}
	
	public static void setDefaultSchedules(List<Product2> listProducts) {
		//This method sets the default schedule values on new products.
		//Quantity Schedule Type=divide
		//Quantity Installment Period=monthly
		//Number Of Quantity Installments=1
		//CanUseQuantitySchedule = true
		
		//Loop through each new product and set the default schedule values.
		for(Product2 oProduct :listProducts){
			oProduct.CanUseQuantitySchedule=true;
			oProduct.QuantityScheduleType='Divide';
			oProduct.QuantityInstallmentPeriod='Monthly';
			oProduct.NumberOfQuantityInstallments=1;
		}
	}
}