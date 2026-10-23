/*
    Controller class for the DealRegApproved.page.

    MOD DATE        Who                     Description
    11/11/2014      Chris Noe               Initial Release 
*/

public with sharing class Deal_Reg_Approved_Cntrl {
	//Class variables - Approved/Priced Deal Registrations
	public List<Lead> listLeadsApprovedPriced1 = new List<Lead>();
	public List<Lead> listLeadsApprovedPriced2 = new List<Lead>();
	public String sApprovedPricedSOQL {get;set;}
	public String sApprovedPricedSOQLSort {get;set;}
	public String sApprovedPricedStatus = 'Registration Approved - Priced';

	//Class variables - Approved/Pending Pricing Deal Registrations
	public List<Lead> listLeadsApprovedPendingPricing1 = new List<Lead>();
	public List<Lead> listLeadsApprovedPendingPricing2 = new List<Lead>();
	public String sApprovedPendingPricingSOQL {get;set;}
	public String sApprovedPendingPricingSOQLSort {get;set;}
	public String sApprovedPendingPricingStatus = 'Registration Approved - Pending Pricing';

	public Deal_Reg_Approved_Cntrl(ApexPages.StandardController oStandardController) {}

/*BEGIN-STANDARDSETCONTROLLER LOGIC FOR APPROVED-PRICED*/	
  	public ApexPages.StandardSetController oApprovedPricedStdSetCntrl {
		get {
			if(oApprovedPricedStdSetCntrl==NULL) {
				//Build query string
				sApprovedPricedSOQL = 'select Id, ';
				sApprovedPricedSOQL += 'Company, ';
				sApprovedPricedSOQL += 'City, ';
				sApprovedPricedSOQL += 'State, ';
				sApprovedPricedSOQL += 'PostalCode, ';
				sApprovedPricedSOQL += 'Country, ';
				sApprovedPricedSOQL += 'Name, ';
				sApprovedPricedSOQL += 'Email, ';
				sApprovedPricedSOQL += 'Phone, ';
				sApprovedPricedSOQL += 'Expected_Ship_Date__c, ';
        sApprovedPricedSOQL += 'Territory_Account_Manager__r.Name, ';
        sApprovedPricedSOQL += 'Rebate__c, ';
        sApprovedPricedSOQL += 'Expiration_Date__c, ';
        sApprovedPricedSOQL += 'CreatedDate ';
				sApprovedPricedSOQL += 'from Lead ';
				sApprovedPricedSOQL += 'where Status = \'' + sApprovedPricedStatus + '\'';

	 			//Query for the list of pending leads
    		listLeadsApprovedPriced1 = Database.query(sApprovedPricedSOQL + ' order by ' + sSortFieldApprovedPriced + ' ' + sSortDirectionApprovedPriced + ' limit 10000');
    
    		//Set the values of the list in the StandardSetController.
    		oApprovedPricedStdSetCntrl = new ApexPages.StandardSetController(listLeadsApprovedPriced1);
    
    		//Set page size to 20 records
    		oApprovedPricedStdSetCntrl.setPageSize(10);
			}
			
			return oApprovedPricedStdSetCntrl;
		}

		set;
	}

    //Toggle the sort order asc<-->desc
    public void toggleSortApprovedPriced() {
      	//Check the current sort direction and toggle to the other
      	sSortDirectionApprovedPriced = sSortDirectionApprovedPriced.equals('asc') ? 'desc' : 'asc';

        //Build query string
        sApprovedPricedSOQLSort = 'select Id, ';
		    sApprovedPricedSOQLSort += 'Company, ';
    		sApprovedPricedSOQLSort += 'City, ';
    		sApprovedPricedSOQLSort += 'State, ';
    		sApprovedPricedSOQLSort += 'PostalCode, ';
    		sApprovedPricedSOQLSort += 'Country, ';
    		sApprovedPricedSOQLSort += 'Name, ';
    		sApprovedPricedSOQLSort += 'Email, ';
    		sApprovedPricedSOQLSort += 'Phone, ';
    		sApprovedPricedSOQLSort += 'Expected_Ship_Date__c, ';
    		sApprovedPricedSOQLSort += 'Territory_Account_Manager__r.Name, ';
    		sApprovedPricedSOQLSort += 'Rebate__c, ';
    		sApprovedPricedSOQLSort += 'Expiration_Date__c, ';
    		sApprovedPricedSOQLSort += 'CreatedDate ';
    		sApprovedPricedSOQLSort += 'from Lead ';
    		sApprovedPricedSOQLSort += 'where Status = \'' + sApprovedPricedStatus + '\'';

        //Query for the list of pending leads
        listLeadsApprovedPriced2 = Database.query(sApprovedPricedSOQLSort + ' order by ' + sSortFieldApprovedPriced + ' ' + sSortDirectionApprovedPriced + ' limit 10000');
        
        //Set the values of the list in the StandardSetController.
        oApprovedPricedStdSetCntrl = new ApexPages.StandardSetController(listLeadsApprovedPriced2);
        
        //Set page size to 20 records
        oApprovedPricedStdSetCntrl.setPageSize(10);    
    }

  	/****************************
  	Getters and Setters
  	****************************/

    //Return the list of Lead records to the Visualforce page from the StandardSetController
    public List<Lead> getlistLeadsApprovedPriced() {
    	return oApprovedPricedStdSetCntrl.getRecords();  
    }

  	//Get and Set sort direction, defaults to asc
  	public String sSortDirectionApprovedPriced {
    	get {
      		if(sSortDirectionApprovedPriced==NULL) {
        		sSortDirectionApprovedPriced = 'asc';
      		}
      		
      		return sSortDirectionApprovedPriced;
    	}
    	set;
  	}
  
  	//Get hasNext to control display of Next link on Visualforce page
  	public Boolean bHasNextApprovedPriced {
    	get {
      		return oApprovedPricedStdSetCntrl.getHasNext();
    	}
  	}
  
  	//Get hasPrevious to control display of Previous link on Visualforce page
  	public Boolean bHasPreviousApprovedPriced {
    	get {
      		return oApprovedPricedStdSetCntrl.getHasPrevious();
    	}
  	}
  
  	//Get DisplayFirst to control display of First link on Visualforce page
  	public Boolean bDisplayFirstApprovedPriced {
    	get {
      		return oApprovedPricedStdSetCntrl.getResultSize() > oApprovedPricedStdSetCntrl.getPageSize() && oApprovedPricedStdSetCntrl.getHasPrevious();
    	}
  	}

  	//Get DisplayLast to control display of Last link on Visualforce page
  	public Boolean bDisplayLastApprovedPriced {
    	get {
      		return oApprovedPricedStdSetCntrl.getResultSize() > oApprovedPricedStdSetCntrl.getPageSize() && oApprovedPricedStdSetCntrl.getHasNext();
    	}
  	}

	public Boolean bDisplayListApprovedPriced {
		get {
			Boolean bDisplay = false;
			bDisplay = bDisplay || oApprovedPricedStdSetCntrl.getResultSize()>0;
			return bDisplay;
		}
	}

  	//Get PageNumber to return current page number
  	public Integer iPageNumberApprovedPriced {
    	get {
      		return oApprovedPricedStdSetCntrl.getPageNumber();
    	}
  	}

  	//Get NumberOfPages to return the number of pages available
  	public Integer iNumberOfPagesApprovedPriced {
		get {
			return Integer.valueof(math.ceil((double)oApprovedPricedStdSetCntrl.getResultSize()/(double)oApprovedPricedStdSetCntrl.getPageSize()));
  		}
  	}

  	//Get and Set sort field, defaults to Expiration_Date__c.
  	public String sSortFieldApprovedPriced {
    	get {
      		if(sSortFieldApprovedPriced==NULL) {
        		sSortFieldApprovedPriced = 'Expiration_Date__c';
      		}
      		return sSortFieldApprovedPriced;
    	}
    	set;
  	}

  	//Set StandardSetController to first page of records
  	public void firstApprovedPriced() {
    	oApprovedPricedStdSetCntrl.first();
  	}
  
  	//Set StandardSetController to last page of records
  	public void lastApprovedPriced() {
    	oApprovedPricedStdSetCntrl.last();
  	}

  	//Set StandardSetController to previous page of records
  	public void previousApprovedPriced() {
    	oApprovedPricedStdSetCntrl.previous();
  	}

  	//Set StandardSetController to next page of records
  	public void nextApprovedPriced() {
    	oApprovedPricedStdSetCntrl.next();
  	}	
/*END-STANDARDSETCONTROLLER LOGIC FOR APPROVED-PRICED*/

/*BEGIN-STANDARDSETCONTROLLER LOGIC FOR APPROVED-PENDING PRICING*/
  	public ApexPages.StandardSetController oApprovedPendingPricingStdSetCntrl {
		get {
			if(oApprovedPendingPricingStdSetCntrl==NULL) {
				//Build query string
				sApprovedPendingPricingSOQL = 'select Id, ';
				sApprovedPendingPricingSOQL += 'Company, ';
				sApprovedPendingPricingSOQL += 'City, ';
				sApprovedPendingPricingSOQL += 'State, ';
				sApprovedPendingPricingSOQL += 'PostalCode, ';
				sApprovedPendingPricingSOQL += 'Country, ';
				sApprovedPendingPricingSOQL += 'Name, ';
				sApprovedPendingPricingSOQL += 'Email, ';
				sApprovedPendingPricingSOQL += 'Phone, ';
				sApprovedPendingPricingSOQL += 'Expected_Ship_Date__c, ';
        sApprovedPendingPricingSOQL += 'Territory_Account_Manager__r.Name, ';
        sApprovedPendingPricingSOQL += 'Expiration_Date__c, ';
        sApprovedPendingPricingSOQL += 'CreatedDate ';
				sApprovedPendingPricingSOQL += 'from Lead ';
				sApprovedPendingPricingSOQL += 'where Status = \'' + sApprovedPendingPricingStatus + '\'';

	 			//Query for the list of pending leads
    		listLeadsApprovedPendingPricing1 = Database.query(sApprovedPendingPricingSOQL + ' order by ' + sSortFieldApprovedPendingPricing + ' ' + sSortDirectionApprovedPendingPricing + ' limit 10000');
    
    		//Set the values of the list in the StandardSetController.
    		oApprovedPendingPricingStdSetCntrl = new ApexPages.StandardSetController(listLeadsApprovedPendingPricing1);
    
    		//Set page size to 20 records
    		oApprovedPendingPricingStdSetCntrl.setPageSize(10);
			}
			
			return oApprovedPendingPricingStdSetCntrl;
		}

		set;
	}

    //Toggle the sort order asc<-->desc
    public void toggleSortApprovedPendingPricing() {
      	//Check the current sort direction and toggle to the other
      	sSortDirectionApprovedPendingPricing = sSortDirectionApprovedPendingPricing.equals('asc') ? 'desc' : 'asc';

        //Build query string
        sApprovedPendingPricingSOQLSort = 'select Id, ';
    		sApprovedPendingPricingSOQLSort += 'Company, ';
    		sApprovedPendingPricingSOQLSort += 'City, ';
    		sApprovedPendingPricingSOQLSort += 'State, ';
    		sApprovedPendingPricingSOQLSort += 'PostalCode, ';
    		sApprovedPendingPricingSOQLSort += 'Country, ';
    		sApprovedPendingPricingSOQLSort += 'Name, ';
    		sApprovedPendingPricingSOQLSort += 'Email, ';
    		sApprovedPendingPricingSOQLSort += 'Phone, ';
    		sApprovedPendingPricingSOQLSort += 'Expected_Ship_Date__c, ';
    		sApprovedPendingPricingSOQLSort += 'Territory_Account_Manager__r.Name, ';
    		sApprovedPendingPricingSOQLSort += 'Expiration_Date__c, ';
    		sApprovedPendingPricingSOQLSort += 'CreatedDate ';
    		sApprovedPendingPricingSOQLSort += 'from Lead ';
    		sApprovedPendingPricingSOQLSort += 'where Status = \'' + sApprovedPendingPricingStatus + '\'';

        //Query for the list of pending leads
        listLeadsApprovedPendingPricing2 = Database.query(sApprovedPendingPricingSOQLSort + ' order by ' + sSortFieldApprovedPendingPricing + ' ' + sSortDirectionApprovedPendingPricing + ' limit 10000');
        
        //Set the values of the list in the StandardSetController.
        oApprovedPendingPricingStdSetCntrl = new ApexPages.StandardSetController(listLeadsApprovedPendingPricing2);
        
        //Set page size to 20 records
        oApprovedPendingPricingStdSetCntrl.setPageSize(10);    
    }

  	/****************************
  	Getters and Setters
  	****************************/

    //Return the list of Lead records to the Visualforce page from the StandardSetController
    public List<Lead> getlistLeadsApprovedPendingPricing() {
    	return oApprovedPendingPricingStdSetCntrl.getRecords();  
    }

  	//Get and Set sort direction, defaults to asc
  	public String sSortDirectionApprovedPendingPricing {
    	get {
      		if(sSortDirectionApprovedPendingPricing==NULL) {
        		sSortDirectionApprovedPendingPricing = 'asc';
      		}
      		
      		return sSortDirectionApprovedPendingPricing;
    	}
    	set;
  	}
  
  	//Get hasNext to control display of Next link on Visualforce page
  	public Boolean bHasNextApprovedPendingPricing {
    	get {
      		return oApprovedPendingPricingStdSetCntrl.getHasNext();
    	}
  	}
  
  	//Get hasPrevious to control display of Previous link on Visualforce page
  	public Boolean bHasPreviousApprovedPendingPricing {
    	get {
      		return oApprovedPendingPricingStdSetCntrl.getHasPrevious();
    	}
  	}
  
  	//Get DisplayFirst to control display of First link on Visualforce page
  	public Boolean bDisplayFirstApprovedPendingPricing {
    	get {
      		return oApprovedPendingPricingStdSetCntrl.getResultSize() > oApprovedPendingPricingStdSetCntrl.getPageSize() && oApprovedPendingPricingStdSetCntrl.getHasPrevious();
    	}
  	}

  	//Get DisplayLast to control display of Last link on Visualforce page
  	public Boolean bDisplayLastApprovedPendingPricing {
    	get {
      		return oApprovedPendingPricingStdSetCntrl.getResultSize() > oApprovedPendingPricingStdSetCntrl.getPageSize() && oApprovedPendingPricingStdSetCntrl.getHasNext();
    	}
  	}

	public Boolean bDisplayListApprovedPendingPricing {
		get {
			Boolean bDisplay = false;
			bDisplay = bDisplay || oApprovedPendingPricingStdSetCntrl.getResultSize()>0;
			return bDisplay;
		}
	}

  	//Get PageNumber to return current page number
  	public Integer iPageNumberApprovedPendingPricing {
    	get {
      		return oApprovedPendingPricingStdSetCntrl.getPageNumber();
    	}
  	}

  	//Get NumberOfPages to return the number of pages available
  	public Integer iNumberOfPagesApprovedPendingPricing {
		get {
			return Integer.valueof(math.ceil((double)oApprovedPendingPricingStdSetCntrl.getResultSize()/(double)oApprovedPendingPricingStdSetCntrl.getPageSize()));
  		}
  	}

  	//Get and Set sort field, defaults to Expiration_Date__c.
  	public String sSortFieldApprovedPendingPricing {
    	get {
      		if(sSortFieldApprovedPendingPricing==NULL) {
        		sSortFieldApprovedPendingPricing = 'Expiration_Date__c';
      		}
      		return sSortFieldApprovedPendingPricing;
    	}
    	set;
  	}

  	//Set StandardSetController to first page of records
  	public void firstApprovedPendingPricing() {
    	oApprovedPendingPricingStdSetCntrl.first();
  	}
  
  	//Set StandardSetController to last page of records
  	public void lastApprovedPendingPricing() {
    	oApprovedPendingPricingStdSetCntrl.last();
  	}

  	//Set StandardSetController to previous page of records
  	public void previousApprovedPendingPricing() {
    	oApprovedPendingPricingStdSetCntrl.previous();
  	}

  	//Set StandardSetController to next page of records
  	public void nextApprovedPendingPricing() {
    	oApprovedPendingPricingStdSetCntrl.next();
  	}
/*END-STANDARDSETCONTROLLER LOGIC FOR APPROVED-PENDING PRICING*/  	
}