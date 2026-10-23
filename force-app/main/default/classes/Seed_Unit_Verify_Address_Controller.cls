/*
    Controller class for the SeedUnitVerifyAddress.page on the Seed_Unit_Order__c object.  Handles logic for displaying and selecting verified US address.

    MOD DATE        Who                     Description
    10/21/2014      Chris Noe               Initial Release
*/
public without sharing class Seed_Unit_Verify_Address_Controller {
    //Class variables
    public final Seed_Unit_Order__c oSeedUnitOrder;	
    public List<SmartyStreets_Validation_Response> listAddressResponses {get;set;}
    public Boolean bDisplayVerifiedAddress {get;set;}
    public String sSelectedAddress {get;set;}
    public Map<Integer,SmartyStreets_Validation_Response> mapVerifiedAddresses {get;set;}

	public Seed_Unit_Verify_Address_Controller(ApexPages.StandardController stdController) {
        //Get the current Seed_Unit_Order__c record
        this.oSeedUnitOrder = (Seed_Unit_Order__c)stdController.getRecord();	

        //Call the SmartyStreets API through the VerifyAddress method.
        VerifyAddress();	
	}

	public void VerifyAddress() {
		//This method is called from the constructor and initiates the web service callout request to the SmartyStreets API using the new address details
		//entered on the seed unit order.

		//Method variables
		List<SmartyStreets_Validation_Request> listAddressValidationRequest = new List<SmartyStreets_Validation_Request>();
		SmartyStreets_Validation_Request oAddressValidationRequest = new SmartyStreets_Validation_Request();
		oAddressValidationRequest.street = oSeedUnitOrder.Ship_To_Address1__c;
		oAddressValidationRequest.city = oSeedUnitOrder.Ship_To_City__c;
		oAddressValidationRequest.state = oSeedUnitOrder.Ship_To_State_Province__c.right(2);
		oAddressValidationRequest.zipcode = oSeedUnitOrder.Ship_To_Postal_Code__c;
		oAddressValidationRequest.input_id = oSeedUnitOrder.Id;
		oAddressValidationRequest.urbanization='';
		oAddressValidationRequest.street2=oSeedUnitOrder.Ship_To_Address2__c;
		oAddressValidationRequest.secondary='';
		oAddressValidationRequest.lastline='';
		oAddressValidationRequest.candidates=10;
		oAddressValidationRequest.callback='';
		oAddressValidationRequest.addressee='';
		listAddressValidationRequest.add(oAddressValidationRequest);

		String sJSONRequest = '';
		String sJSONResponse = '';
		SmartyStreets_API__c oAPIDetails = new SmartyStreets_API__c();		
		Http oHTTP = new Http();
		HttpRequest oHTTPRequest = new HttpRequest();
		HTTPResponse oHTTPResponse = new HttpResponse();

		//Retrieve web service details from custom setting
		oAPIDetails = [select auth_id__c, auth_token__c from SmartyStreets_API__c where Name = 'SeedUnitAddressVerify'];

		// Build the REST endpoint URL string
		String sURL = 'https://api.smartystreets.com/street-address/?auth-id=' + EncodingUtil.urlEncode(oAPIDetails.auth_id__c,'UTF-8') + '&auth-token=' + EncodingUtil.urlEncode(oAPIDetails.auth_token__c,'UTF-8');

		//Serialize and list of validation requests
		sJSONRequest = JSON.serialize(listAddressValidationRequest);
		system.debug('JSON REQUEST: ' + sJSONRequest);	
		system.debug('QUERY STRING: ' + sURL);
		oHTTPRequest.setEndpoint(sURL);
		oHTTPRequest.setMethod('POST');
		oHTTPRequest.setTimeout(120000);
		oHTTPRequest.setHeader('Content-Length', String.valueOf(sJSONRequest.length()));
		oHTTPRequest.setBody(sJSONRequest);
		system.debug('REQUEST BODY: ' + oHTTPRequest.getBody());

		try{
			oHTTPResponse = oHTTP.send(oHTTPRequest);
			sJSONResponse = oHTTPResponse.getBody();

			system.debug('JSON RESPONSE: ' + sJSONResponse);

			if(oHTTPResponse.getStatusCode()==200){
				oSeedUnitOrder.SmartyStreets_Response__c = sJSONResponse;
				listAddressResponses = (List<SmartyStreets_Validation_Response>) JSON.deserialize(sJSONResponse, List<SmartyStreets_Validation_Response>.class);
				bDisplayVerifiedAddress=false;
				bDisplayVerifiedAddress = bDisplayVerifiedAddress || this.listAddressResponses.size()>0;
				//Loop through the reponse and add map values with candidate index as key
				mapVerifiedAddresses = new Map<Integer,SmartyStreets_Validation_Response>(); 
				for(SmartyStreets_Validation_Response oResponse :listAddressResponses) {
					//Set formatted Address1, Address2, and City/State/Zip
			        String sAddress1;
			        if(oResponse.Components.primary_number!=NULL && oResponse.Components.primary_number!='') {
			        	sAddress1 = oResponse.Components.primary_number;
			    	}
			        if(oResponse.Components.street_predirection!=NULL && oResponse.Components.street_predirection!='') {
			        	sAddress1 = sAddress1 + ' ' + oResponse.Components.street_predirection;
			        }
			        if(oResponse.Components.street_name!=NULL && oResponse.Components.street_name!='') {
			        	sAddress1 = sAddress1 + ' ' + oResponse.Components.street_name;
			        }
			        if(oResponse.Components.street_suffix!=NULL && oResponse.Components.street_suffix!='') {
			        	sAddress1 = sAddress1 + ' ' + oResponse.Components.street_suffix;
			        }
			        if(oResponse.Components.street_postdirection!=NULL && oResponse.Components.street_postdirection!='') {
			        	sAddress1 = sAddress1 + ' ' + oResponse.Components.street_postdirection;
			        }
			        //Populate Address1 on response object
			        if(sAddress1!=NULL && sAddress1!='') {
			        	oResponse.sFormattedAddress1=sAddress1.toUpperCase();
			        }					

			        //Build Secondary address string
			        String sAddress2;
			        if(oResponse.Components.secondary_designator!=NULL && oResponse.Components.secondary_designator!='' && oResponse.Components.secondary_number!=NULL && oResponse.Components.secondary_number!='') {
			        	sAddress2 = oResponse.Components.secondary_designator + ' ' + oResponse.Components.secondary_number;
			        }

			        //Populate Address2 on Account object
			        if(sAddress2!=NULL && sAddress2!='') {
			        	oResponse.sFormattedAddress2 = sAddress2.toUpperCase();
			        }

			        //Build City,State,PostalCode String
			        String sCityStateZip;

			        //Populate City
			        if(oResponse.Components.city_name!=NULL && oResponse.Components.city_name!='') {
			        	sCityStateZip = oResponse.Components.city_name.toUpperCase();
			    	}

			    	//Populate State
			    	if(oResponse.Components.state_abbreviation!=NULL && oResponse.Components.state_abbreviation!='') {
			        	sCityStateZip = sCityStateZip + ', ' + oResponse.Components.state_abbreviation.toUpperCase();
			        }

			        //Populate Postal Code
			        if(oResponse.Components.zipcode!=NULL && oResponse.Components.zipcode!='') {
			        	if(oResponse.Components.plus4_code!=NULL && oResponse.Components.plus4_code!='') {
			        		sCityStateZip = sCityStateZip + ' ' + oResponse.Components.zipcode + '-' + oResponse.Components.plus4_code;
			        	}
			        	else {
			        		sCityStateZip = sCityStateZip + oResponse.Components.zipcode;	
			        	}
			        }

			        //Set addressee to upper case if not null
			        if(oResponse.addressee!=NULL && oResponse.addressee!='') {
			        	oResponse.addressee = oResponse.addressee.toUpperCase();
			        }

        			oResponse.sFormattedCityStateZip = sCityStateZip;

					mapVerifiedAddresses.put(oResponse.candidate_index,oResponse);
				}
			}

			else {
				//Web service status exception.  Add page message.
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'STATUS EXCEPTION CODE: ' + String.valueOf(oHTTPResponse.getStatusCode())));
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'STATUS EXCEPTION MESSAGE: ' + oHTTPResponse.getStatus()));
			}		
		}

		catch (Exception oException) {
			//Web service callout exception.  Add page message
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'WEB SERVICE CALLOUT EXCEPTION: ' + oException.getMessage()));
		}
	}

	public PageReference editShipTo() {
		PageReference oPageRef = Page.SeedUnitSelectShipTo;
		oPageRef.getParameters().put('id', oSeedUnitOrder.Id);
		oPageRef.setRedirect(true);
		return oPageRef;
	}

	public PageReference updateAddress() {
        //Method variables
        PageReference oPageRef;
        
        //Get selected address from page.
        sSelectedAddress = Apexpages.currentpage().getParameters().get('addressIndex');

        SmartyStreets_Validation_Response oResponse = mapVerifiedAddresses.get(Integer.valueOf(sSelectedAddress));

        //Build Primary Address String
        String sAddress1;
        if(oResponse.Components.primary_number!=NULL && oResponse.Components.primary_number!='') {
        	sAddress1 = oResponse.Components.primary_number;
    	}
        if(oResponse.Components.street_predirection!=NULL && oResponse.Components.street_predirection!='') {
        	sAddress1 = sAddress1 + ' ' + oResponse.Components.street_predirection;
        }
        if(oResponse.Components.street_name!=NULL && oResponse.Components.street_name!='') {
        	sAddress1 = sAddress1 + ' ' + oResponse.Components.street_name;
        }
        if(oResponse.Components.street_suffix!=NULL && oResponse.Components.street_suffix!='') {
        	sAddress1 = sAddress1 + ' ' + oResponse.Components.street_suffix;
        }
        if(oResponse.Components.street_postdirection!=NULL && oResponse.Components.street_postdirection!='') {
        	sAddress1 = sAddress1 + ' ' + oResponse.Components.street_postdirection;
        }
        //Populate Address1 on Account object
        if(sAddress1!=NULL && sAddress1!='') {
        	oSeedUnitOrder.Ship_To_Address1__c=sAddress1.toUpperCase();
        }

        //Build Secondard address string
        String sAddress2;
        if(oResponse.Components.secondary_designator!=NULL && oResponse.Components.secondary_designator!='') {
        	sAddress2 = oResponse.Components.secondary_designator;
        }
        if(oResponse.Components.secondary_number!=NULL && oResponse.Components.secondary_number!='') {
        	sAddress2 = sAddress2 + ' ' + oResponse.Components.secondary_number;
        }
        //Populate Address2 on Account object
        if(sAddress2!=NULL && sAddress2!='') {
        	oSeedUnitOrder.Ship_To_Address2__c = sAddress2.toUpperCase();
        }

        //Populate City
        if(oResponse.Components.city_name!=NULL && oResponse.Components.city_name!='') {
        	oSeedUnitOrder.Ship_To_City__c = oResponse.Components.city_name.toUpperCase();
    	}

    	//Populate State
    	if(oResponse.Components.state_abbreviation!=NULL && oResponse.Components.state_abbreviation!='') {
        	//Get the state display value from custom setting so that pick list field Ship_To_State_Province__c is set correctly
        	try {
        		State_Codes__c oStateCode = State_Codes__c.getInstance(oResponse.Components.state_abbreviation.toUpperCase());
        		oSeedUnitOrder.Ship_To_State_Province__c = oStateCode.State_Name__c + '-' + oResponse.Components.state_abbreviation.toUpperCase();
        	}
        	catch(Exception oException) {
        		//state code not mapped
        	}
        }

        //Populate Postal Code
        if(oResponse.Components.zipcode!=NULL && oResponse.Components.zipcode!='') {
        	if(oResponse.Components.plus4_code!=NULL && oResponse.Components.plus4_code!='') {
        		oSeedUnitOrder.Ship_To_Postal_Code__c = oResponse.Components.zipcode + '-' + oResponse.Components.plus4_code;
        	}
        	else {
        		oSeedUnitOrder.Ship_To_Postal_Code__c = oResponse.Components.zipcode;	
        	}
        }
        
        //Populate County
        if(oResponse.Metadata.county_name!=NULL && oResponse.Metadata.county_name!='') {
        	oSeedUnitOrder.Ship_To_County__c = oResponse.Metadata.county_name.toUpperCase();
    	}

        update oSeedUnitOrder;

        return new PageReference('/' + oSeedUnitOrder.Id);
	}

	public PageReference verifyCancel() {
		//When a user clicks Cancel on the address verification page, clear out the address they entered and redirect to the seed unit order page
        
        //Clear the previous values in new address fields in case they were entered prior to selecting an existing address.
        oSeedUnitOrder.Ship_To_Address1__c=NULL;
        oSeedUnitOrder.Ship_To_Address2__c=NULL;
        oSeedUnitOrder.Ship_To_Address3__c=NULL;
        oSeedUnitOrder.Ship_To_Address4__c=NULL;
        oSeedUnitOrder.Ship_To_City__c=NULL;
        oSeedUnitOrder.Ship_To_State_Province__c=NULL;
        oSeedUnitOrder.Ship_To_Postal_Code__c=NULL;

        //Set SmartyStreets response field to NULL
        oSeedUnitOrder.SmartyStreets_Response__c=NULL;

        update oSeedUnitOrder;

        return new PageReference('/' + oSeedUnitOrder.Id);
	}

	public PageReference useAddressEntered() {
		//When an address is not verified, the user will have the option to use the address they entered.  Update the address validation flag to prevent
		//further address validation attempts for this seed order and redirect the user back to the seed unit order.

		//Update the address validation flag to prevent further address validation attempts for this seed order and redirect the user back to the seed unit order.
		oSeedUnitOrder.Do_Not_Validate_Address__c=true;

        //Set SmartyStreets response field to NULL
        oSeedUnitOrder.SmartyStreets_Response__c=NULL;

        update oSeedUnitOrder;

        return new PageReference('/' + oSeedUnitOrder.Id);		
	}
}