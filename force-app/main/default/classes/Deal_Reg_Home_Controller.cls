public with sharing class Deal_Reg_Home_Controller {
	public String sCurrency{get;set;}

	public Deal_Reg_Home_Controller() {
		sCurrency = UserInfo.getDefaultCurrency();
	}
}