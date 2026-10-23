/**
*   {Purpose}  –  A class invocable from a Visual Flow, it calculates business hours between
*					two dates in a given timezone
*                
*   {Function}  – 
*                 
*   {Support}   - For assistance with this code, please contact support@demandchainsystems.com             
*                 www.demandchainsystems.com
*                 (952) 345-4533
*
*
*   CHANGE  HISTORY
*   =============================================================================
*   Date      Name             Description
*   20170505  EBG DCS          Created
*   =============================================================================
*/
public class Invocable_BusinessHoursBetweenDates {

	//Class holding input parameters
	public class BusinessHoursParams {
		@InvocableVariable(label='TimeZoneSidKey' required=true)
		public String timezoneSidKey;

		@InvocableVariable(label='Start Date/Time' required=true)
		public Datetime dttStartDate;

		@InvocableVariable(label='End Date/Time' required=true)
		public Datetime dttEndDate;
	}

	@InvocableMethod(label='Business Hours Between Dates'
                     description='Calculates business hours between two dates in the given timezone.')
	public static List<Decimal> Invocable_BusinessHoursBetweenDates(List<BusinessHoursParams> params) {
		return Invocable_BusinessHoursBetweenDates.BusinessHoursBetweenDates(params[0].timezoneSidKey, params[0].dttStartDate, params[0].dttEndDate);
	}


	//code that calculates business hours between two dates in the given timezone
	public static List<Decimal> BusinessHoursBetweenDates(String timezoneSidKey, Datetime dttStartDate, Datetime dttEndDate) {
		Decimal diffHours = null;

		//find the business hours for the given timezone.  If none exist, the whole routine returns NULL
		system.debug('Timezone: ' + timezoneSidKey + '\ndttStartDate: ' + dttStartDate + '\ndttEndDate: ' + dttEndDate);
		try {
			BusinessHours oBusinessHours = [Select Id
											, Name
											, SundayStartTime
											, MondayStartTime
											, TuesdayStartTime
											, WednesdayStartTime
											, ThursdayStartTime
											, FridayStartTime
											, SaturdayStartTime
											, SundayEndTime
											, MondayEndTime
											, TuesdayEndTime
											, WednesdayEndTime
											, ThursdayEndTime
											, FridayEndTime
											, SaturdayEndTime
											, TimeZoneSidKey
			       						From BusinessHours 
			       						Where TimeZoneSidKey = :timezoneSidKey
			       						LIMIT 1];		
			
			dttStartDate = BusinessHours.nextStartDate(oBusinessHours.id, dttStartDate);
			dttEndDate = BusinessHours.nextStartDate(oBusinessHours.id, dttEndDate);

			Long diffMilliseconds = BusinessHours.diff(oBusinessHours.Id, dttStartDate, dttEndDate);
			Decimal diffSeconds = Decimal.valueOf(diffMilliseconds)/Decimal.valueOf(1000);
			Decimal diffMinutes = diffSeconds/60;
			diffHours = diffMinutes/60;
		} catch(Exception ex) {
			system.debug('Error for timezone *' + timezoneSidKey + ':*\n' + ex);
		}

		List<Decimal> retVal = new List<Decimal>();
		retVal.add(diffHours);
		system.debug('Calculations Complete.\nTimezone: ' + timezoneSidKey + '\ndttStartDate: ' + dttStartDate + '\ndttEndDate: ' + dttEndDate);
		system.debug('Return Value: ' + retVal);
		return retVal;

	}
}