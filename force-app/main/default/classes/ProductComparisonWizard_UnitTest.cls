/**
*   {Purpose}  �  TODO:  Provide Purpose
*
*	{Code Covered}	- Note the triggers/classes that this test covers
*
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 612-424-0032                  
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date    	Name             		Description
*   20151001  	Andy Boettcher DCS		Created
*   =============================================================================
*/
@isTest
private class ProductComparisonWizard_UnitTest {
	
	@testSetup static void testSetup() {

		List<Ergotron_Product_Comparison__c> lstInsertEPC = new List<Ergotron_Product_Comparison__c>();
		for(Integer i=0;i<500;i++) {

			Ergotron_Product_Comparison__c objEPC = new Ergotron_Product_Comparison__c(Name='TestRecord'+i);

			for(Schema.FieldSetMember fsm : SObjectType.Ergotron_Product_Comparison__c.FieldSets.CompareWizardSearch.getFields()) {
				objEPC.put(fsm.getFieldPath(), 'test');
			}

			lstInsertEPC.add(objEPC);
		}

		insert lstInsertEPC;

	}

	@isTest static void testUtilityMethodCatches() {

		UtilityMethods.objRecordData(null, null, null, null);

	}

	static testmethod void testWizardConstructor() {

		List<Ergotron_Product_Comparison__c> lstInsertEPC = [SELECT Id, Name FROM Ergotron_Product_Comparison__c];
		System.Assert(lstInsertEPC.size() == 500, 'The EPCs were not inserted correctly!');

		Test.setMock(HttpCalloutMock.class, new LayoutDescribeResultMock());
		PageReference pageRef = Page.ProductComparison;
		pageRef.getParameters().put('id', lstInsertEPC[0].Id);
		Test.setCurrentPage(pageRef);
		//ApexPages.currentPage().getParameters().put('id', lstInsertEPC[0].Id);

		Test.startTest();
		ProductComparisonWizardController ctrl = new ProductComparisonWizardController();
		Test.stopTest();
		System.assertEquals(1,ctrl.mapProducts.size(),'Initial Product was not automatically added.');
		System.assertEquals(0,ctrl.lstResults.size());
	}

	static testmethod void testWizardSearchNoResults() {

		List<Ergotron_Product_Comparison__c> lstInsertEPC = [SELECT Id, Name FROM Ergotron_Product_Comparison__c];
		System.Assert(lstInsertEPC.size() == 500, 'The EPCs were not inserted correctly!');

		Test.setMock(HttpCalloutMock.class, new LayoutDescribeResultMock());
		PageReference pageRef = Page.ProductComparison;
		pageRef.getParameters().put('id', lstInsertEPC[0].Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();
		ProductComparisonWizardController ctrl = new ProductComparisonWizardController();
		ctrl.objSearch.Name = 'completelyinvalidnameyo';
		ctrl.searchListResults();
		Test.stopTest();
		System.assertEquals(0,ctrl.lstResults.size(),'Was an invalid search, but found results.');
		System.assertEquals(1,ctrl.mapProducts.size());
	}

	static testmethod void testWizardSearchWithResults() {

		List<Ergotron_Product_Comparison__c> lstInsertEPC = [SELECT Id, Name FROM Ergotron_Product_Comparison__c];
		System.Assert(lstInsertEPC.size() == 500, 'The EPCs were not inserted correctly!');

		Test.setMock(HttpCalloutMock.class, new LayoutDescribeResultMock());
		PageReference pageRef = Page.ProductComparison;
		pageRef.getParameters().put('id', lstInsertEPC[0].Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();
		ProductComparisonWizardController ctrl = new ProductComparisonWizardController();
		String field = SObjectType.Ergotron_Product_Comparison__c.FieldSets.CompareWizardSearch.getFields().get(0).getFieldPath();
		ctrl.objSearch.put(field,'test');
		ctrl.searchListResults();
		Test.stopTest();
		System.assertEquals(499,ctrl.lstResults.size());
	}

	static testmethod void testWizardCompareProducts() {

		List<Ergotron_Product_Comparison__c> lstInsertEPC = [SELECT Id, Name FROM Ergotron_Product_Comparison__c];
		System.Assert(lstInsertEPC.size() == 500, 'The EPCs were not inserted correctly!');

		Test.setMock(HttpCalloutMock.class, new LayoutDescribeResultMock());
		PageReference pageRef = Page.ProductComparison;
		pageRef.getParameters().put('id', lstInsertEPC[0].Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();
		ProductComparisonWizardController ctrl = new ProductComparisonWizardController();
		String field = SObjectType.Ergotron_Product_Comparison__c.FieldSets.CompareWizardSearch.getFields().get(0).getFieldPath();
		ctrl.objSearch.put(field,'test');
		ctrl.searchListResults();
		ctrl.idTarget = lstInsertEPC.get(1).Id;
		ctrl.addToSelected();
		ctrl.idTarget = lstInsertEPC.get(2).Id;
		ctrl.addToSelected();
		ctrl.idTarget = lstInsertEPC.get(3).Id;
		ctrl.addToSelected();
		ctrl.idTarget = lstInsertEPC.get(3).Id;
		ctrl.removeFromSelected();
		ctrl.displayComparison();
		Test.stopTest();
		System.assertEquals(3,ctrl.mapComparison.size());
	}

	static testmethod void testDisplayComparisonXLS() {
		List<Ergotron_Product_Comparison__c> lstInsertEPC = [SELECT Id, Name FROM Ergotron_Product_Comparison__c];
		System.Assert(lstInsertEPC.size() == 500, 'The EPCs were not inserted correctly!');

		Test.setMock(HttpCalloutMock.class, new LayoutDescribeResultMock());
		PageReference pageRef = Page.ProductComparison;
		pageRef.getParameters().put('id', lstInsertEPC[0].Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();
		ProductComparisonWizardController ctrl = new ProductComparisonWizardController();
		PageReference result = ctrl.displayComparisonXLS();
		Test.stopTest();
		System.assertNotEquals(null,result);
		System.assertEquals(false,result.getRedirect());
	}

	static testmethod void testCancel() {
		List<Ergotron_Product_Comparison__c> lstInsertEPC = [SELECT Id, Name FROM Ergotron_Product_Comparison__c];
		System.Assert(lstInsertEPC.size() == 500, 'The EPCs were not inserted correctly!');

		Test.setMock(HttpCalloutMock.class, new LayoutDescribeResultMock());
		PageReference pageRef = Page.ProductComparison;
		pageRef.getParameters().put('id', lstInsertEPC[0].Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();
		ProductComparisonWizardController ctrl = new ProductComparisonWizardController();
		PageReference result = ctrl.cancel();
		Test.stopTest();
		System.assertNotEquals(null,result);
		System.assertEquals(true,result.getRedirect());
	}
}