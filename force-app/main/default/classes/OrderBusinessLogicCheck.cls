public class OrderBusinessLogicCheck  {

	@AuraEnabled public Boolean bolLogicResult {get;set;}
    @AuraEnabled public String strLogicCode {get;set;}
	@AuraEnabled public String strLogicMessage {get;set;}

	public OrderBusinessLogicCheck(Boolean result, String code, String description) {
		bolLogicResult = result;
		strLogicCode = code;
		strLogicMessage = description;
	}

}