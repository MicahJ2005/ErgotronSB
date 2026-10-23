/**
*   {Purpose}  –  test class for the Invocable_BusinessHoursBetweenDates class
*
*   {Function}  –
*
*   {Support}   - For assistance with this code, please contact support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 (952) 345-4533
*/
/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date      Name             Description
*   20170508  EBG DCS          Created
*   =============================================================================*/
@isTest
private class Invocable_BusinessHoursBetweenDates_Test {

	@isTest static void testDates() {
        test.startTest();

		Invocable_BusinessHoursBetweenDates.BusinessHoursParams oParams = new Invocable_BusinessHoursBetweenDates.BusinessHoursParams();
		oParams.timezoneSidKey = 'America/Chicago';
		oParams.dttStartDate = Datetime.now();
		oParams.dttEndDate = Datetime.now().addDays(1);

		List<Invocable_BusinessHoursBetweenDates.BusinessHoursParams> lstParams = new List<Invocable_BusinessHoursBetweenDates.BusinessHoursParams>();
		lstParams.add(oParams);
		List<Decimal> lstDecimal = Invocable_BusinessHoursBetweenDates.Invocable_BusinessHoursBetweenDates(lstParams);
		
        test.stopTest();
    }

}