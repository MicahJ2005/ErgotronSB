/*
	Global variables class used to control execution logic in classes and triggers.

	MOD DATE		Who						Description
	05/15/2015		Chris Noe				Initial Release
*/

public with sharing class GlobalVariables {
	
	//Static boolean variable used to indicate whether or not opportunity line item before triggers should fire
	public static Boolean bFireOpptyLineBeforeTrigger = true;

	//Static boolean variable used to indicate whether or not opportunity line item after triggers should fire
	public static Boolean bFireOpptyLineAfterTrigger = true;

	//Static boolean variable used to indicate to run the Big Deal Reporting trigger logic
	public static Boolean bolFireBigDealReporting = true;
}