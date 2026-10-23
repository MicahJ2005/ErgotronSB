public with sharing class Deal_Reg_Drafts_Cntrl {
	public List<Lead> listLeads1 = new List<Lead>();
	public List<Lead> listLeads2 = new List<Lead>();
	public String sSOQL {get;set;}
	public String sSOQLSort {get;set;}
	public String sStatus = 'Registration Saved';
	
	public Deal_Reg_Drafts_Cntrl(ApexPages.StandardController oStandardController) {}

  	public ApexPages.StandardSetController oStandardSetController {
		get {
			if(oStandardSetController==NULL) {
				//Build query string
				sSOQL = 'select Id, ';
				sSOQL += 'Company, ';
				sSOQL += 'City, ';
				sSOQL += 'State, ';
				sSOQL += 'PostalCode, ';
				sSOQL += 'Country, ';
				sSOQL += 'Name, ';
				sSOQL += 'Email, ';
				sSOQL += 'Phone, ';
				sSOQL += 'Expected_Ship_Date__c, ';
				sSOQL += 'CreatedDate ';
				sSOQL += 'from Lead ';
				sSOQL += 'where Status = \'' + sStatus + '\'';

	 			//Query for the list of pending leads
        listLeads1 = Database.query(sSOQL + ' order by ' + sSortField + ' ' + sSortDirection + ' limit 10000');
        
        //Set the values of the list in the StandardSetController.
        oStandardSetController = new ApexPages.StandardSetController(listLeads1);
        
        //Set page size to 20 records
        oStandardSetController.setPageSize(20);
			}
			
			return oStandardSetController;
		}

		set;
	 }

    //Toggle the sort order asc<-->desc
    public void toggleSort() {
      //Check the current sort direction and toggle to the other
      sSortDirection = sSortDirection.equals('asc') ? 'desc' : 'asc';

        //Build query string
        sSOQLSort = 'select Id, ';
        sSOQLSort += 'Company, ';
        sSOQLSort += 'City, ';
        sSOQLSort += 'State, ';
        sSOQLSort += 'PostalCode, ';
        sSOQLSort += 'Country, ';
        sSOQLSort += 'Name, ';
        sSOQLSort += 'Email, ';
        sSOQLSort += 'Phone, ';
        sSOQLSort += 'Expected_Ship_Date__c, ';
        sSOQLSort += 'CreatedDate ';
        sSOQLSort += 'from Lead ';
        sSOQLSort += 'where Status = \'' + sStatus + '\'';

        //Query for the list of pending leads
        listLeads2 = Database.query(sSOQLSort + ' order by ' + sSortField + ' ' + sSortDirection + ' limit 10000');
        
        //Set the values of the list in the StandardSetController.
        oStandardSetController = new ApexPages.StandardSetController(listLeads2);
        
        //Set page size to 20 records
        oStandardSetController.setPageSize(20);    
    }

  	/****************************
  	Getters and Setters
  	****************************/

    //Return the list of Lead records to the Visualforce page from the StandardSetController
    public List<Lead> getlistLeads() {
    	return oStandardSetController.getRecords();  
    }

  	//Get and Set sort direction, defaults to desc
  	public String sSortDirection {
    	get {
      		if(sSortDirection==NULL) {
        		sSortDirection = 'desc';
      		}
      		
      		return sSortDirection;
    	}
    	set;
  	}
  
  	//Get hasNext to control display of Next link on Visualforce page
  	public Boolean bHasNext {
    	get {
      		return oStandardSetController.getHasNext();
    	}
  	}
  
  	//Get hasPrevious to control display of Previous link on Visualforce page
  	public Boolean bHasPrevious {
    	get {
      		return oStandardSetController.getHasPrevious();
    	}
  	}
  
  	//Get DisplayFirst to control display of First link on Visualforce page
  	public Boolean bDisplayFirst {
    	get {
      		return oStandardSetController.getResultSize() > oStandardSetController.getPageSize() && oStandardSetController.getHasPrevious();
    	}
  	}

  	//Get DisplayLast to control display of Last link on Visualforce page
  	public Boolean bDisplayLast {
    	get {
      		return oStandardSetController.getResultSize() > oStandardSetController.getPageSize() && oStandardSetController.getHasNext();
    	}
  	}

	public Boolean bDisplayList {
		get {
			Boolean bDisplay = false;
			bDisplay = bDisplay || oStandardSetController.getResultSize()>0;
			return bDisplay;
		}
	}

  	//Get PageNumber to return current page number
  	public Integer iPageNumber {
    	get {
      		return oStandardSetController.getPageNumber();
    	}
  	}

  	//Get NumberOfPages to return the number of pages available
  	public Integer iNumberOfPages {
		get {
			return Integer.valueof(math.ceil((double)oStandardSetController.getResultSize()/(double)oStandardSetController.getPageSize()));
  		}
  	}

  	//Get and Set sort field, defaults to CreatedDate.
  	public String sSortField {
    	get {
      		if(sSortField==NULL) {
        		sSortField = 'CreatedDate';
      		}
      		return sSortField;
    	}
    	set;
  	}

  	//Set StandardSetController to first page of records
  	public void first() {
    	oStandardSetController.first();
  	}
  
  	//Set StandardSetController to last page of records
  	public void last() {
    	oStandardSetController.last();
  	}

  	//Set StandardSetController to previous page of records
  	public void previous() {
    	oStandardSetController.previous();
  	}

  	//Set StandardSetController to next page of records
  	public void next() {
    	oStandardSetController.next();
  	}
}