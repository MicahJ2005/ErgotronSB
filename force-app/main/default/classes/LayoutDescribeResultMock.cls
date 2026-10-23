/**
*  Description: Mock callout class for test classes that describe layouts (e.g. ProductComparisonWizardController)
*
*   CHANGE  HISTORY
*   =============================================================================
*   Date    	Name             		Description
*   20151211 	James Loghry			Created
*   =============================================================================
*/global class LayoutDescribeResultMock implements HttpCalloutMock{

	global HTTPResponse respond(HTTPRequest req) {
		//Use the json2apex generated class for deserializng into JSON for the fake response.
		LayoutDescribeResult ldr = new LayoutDescribeResult();
		ldr.detailLayoutSections = new List<LayoutDescribeResult.DetailLayoutSections>();
		LayoutDescribeResult.DetailLayoutSections detailLayoutSection = new LayoutDescribeResult.DetailLayoutSections();
		ldr.detailLayoutSections.add(detailLayoutSection);
		detailLayoutSection.layoutRows = new List<LayoutDescribeResult.LayoutRows>();
		LayoutDescribeResult.LayoutRows layoutRow = new LayoutDescribeResult.LayoutRows();
		detailLayoutSection.layoutRows.add(layoutRow);
		layoutRow.layoutItems = new List<LayoutDescribeResult.LayoutItems>();
		LayoutDescribeResult.LayoutItems layoutItem = new LayoutDescribeResult.LayoutItems();
		layoutRow.layoutItems.add(layoutItem);
		layoutItem.label = 'Name';
		layoutItem.layoutComponents = new List<LayoutDescribeResult.LayoutComponents>();
		LayoutDescribeResult.LayoutComponents layoutComponent = new LayoutDescribeResult.LayoutComponents();
		layoutItem.layoutComponents.add(layoutComponent);
		layoutComponent.value = 'Name';

		// Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(JSON.serialize(ldr));
        res.setStatusCode(200);
        return res;
    }
}