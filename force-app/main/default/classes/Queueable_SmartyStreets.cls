public class Queueable_SmartyStreets implements Queueable, Database.AllowsCallouts {
/**
*   {Purpose}  	- Account Trigger Logic Class
*
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 952.223.5604                
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date    	Name             		Description
*   20180414  	Andy Boettcher DCS		Added Header and Documented Class
*   =============================================================================
*/

	private List<SmartyStreets_Validation_Request> lstRequests;

	/*************************************************
	CONSTRUCTOR
	/*************************************************/	
	public Queueable_SmartyStreets(List<SmartyStreets_Validation_Request> requests){
		this.lstRequests = requests;
	}

	/*************************************************
	EXECUTE
	/*************************************************/	 
	public void execute(QueueableContext context){
		List<SmartyStreets_Validation_Response> lstResponses = new List<SmartyStreets_Validation_Response>();
		List<SmartyStreets_Validation_Request> lstRequests1 = new List<SmartyStreets_Validation_Request>();
		List<SmartyStreets_Validation_Request> lstRequests2 = new List<SmartyStreets_Validation_Request>();
		List<Account> lstUpdateAcct = new List<Account>();

		// SmartyStreets has governor limits on the API - we are going to only send 50 per connection.  
		if(lstRequests.size()>50){
			Integer i = 0;
			for(SmartyStreets_Validation_Request req : lstRequests){
				i += 1;
				if(i>50){
					lstRequests2.add(req);
				}
				else{
					lstRequests1.add(req);
				}
			}

			System.Debug('REQUEST = ' + JSON.serialize(lstRequests1));

			lstResponses = SmartyStreets_Callouts.makeSmartyStreetsCallout(lstRequests1);
		}
		else{
			lstResponses = SmartyStreets_Callouts.makeSmartyStreetsCallout(lstRequests);
		}

		// Iterate through SmartyStreets responses
		if(lstResponses != null) {
			if(!lstResponses.isEmpty()){

				for(SmartyStreets_Validation_Response resp : lstResponses){

					System.Debug('SS RESPONSE = ' + JSON.serialize(resp));

					String sAddress1 = '';

					// Commented out 20180501 AAB - moving to use only "resp.delivery_line_1"
					//if(String.isNotBlank(resp.Components.primary_number)) {
						//sAddress1 = resp.Components.primary_number;
					//}
			        
					//if(String.isNotBlank(resp.Components.street_predirection)) {
						//sAddress1+= ' ' + resp.Components.street_predirection;
					//}

					//if(String.isNotBlank(resp.Components.street_name)) {
						//sAddress1+= ' ' + resp.Components.street_name;
					//}

					//if(String.isNotBlank(resp.Components.street_suffix)) {
						//sAddress1+= ' ' + resp.Components.street_suffix;
					//}

					//if(String.isNotBlank(resp.Components.street_postdirection)) {
						//sAddress1+= ' ' + resp.Components.street_postdirection;
					//}
					sAddress1 = UtilityMethods.sanitizeStringInput(resp.delivery_line_1);

					if(string.isnotblank(resp.delivery_line_2)) {
						sAddress1+= '\r\n' + UtilityMethods.sanitizeStringInput(resp.delivery_line_2);
					}

					System.Debug('Concatenated BillingStreet = ' + sAddress1);

					Account updateAcct = new Account(Id=resp.input_id);
						updateAcct.BillingStreet = sAddress1;
						updateAcct.BillingCity = resp.components.city_name;
						updateAcct.BillingStateCode = resp.components.state_abbreviation;
						updateAcct.BillingPostalCode = resp.components.zipcode;
						updateAcct.County__c = resp.metadata.county_name;
						updateAcct.IsAddressValidated__c = TRUE;

					System.Debug('Scoped Account Updates = ' + JSON.serialize(updateAcct));

					lstUpdateAcct.add(updateAcct);
				}
			}
		}

		// Update Scoped Accounts
		if(lstUpdateAcct.size()>0){
			update lstUpdateAcct;
		}

		// Chain Enqueue additional (50+) scoped accounts to account for SmartyStreets per-transaction governor limits
		if(lstRequests2.size()>0){
			System.debug('lstRequest2' + lstRequests2.size());
			Queueable_SmartyStreets qc = new Queueable_SmartyStreets(lstRequests2);
			Id jobId = System.enqueueJob(qc);
			System.debug('jobId: ' + jobId);
		}
	}
}