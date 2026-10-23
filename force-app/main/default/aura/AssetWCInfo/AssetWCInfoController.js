({
	init : function(component, event, helper) {
		//debugger;
		var aId = component.get("v.AssetId");
        var woNumber = component.get("v.input_WONumber");
		var rId = component.get("v.recordId");

		if(aId != "" && aId != null){
            console.log('AssetId not null, processing ' + aId);
			helper.ParentData(component, event);
	        // helper.ChildrenData(component, event);
	        component.set("v.AssetId", false);
            component.set("v.display", true);
            component.set("v.displayContract", true);
            component.set("v.displayChild", true);
        } else {
            if((woNumber != "" && woNumber != null) || (rId != "" && rId != null)) {
                // No Asset, go off of Work Order Number
                console.log('No AssetId, going for WO ' + woNumber);
				console.log('Passed RecordId = ' + component.get("v.recordId"));
                component.set("v.display", true);
                component.set("v.displayContract", false);
                component.set("v.displayChild", false);
				helper.WorkOrderData(component, event);
            } else {
				// Nothing passed, do not show anything
            	console.log('No AssetId, CaseId OR WO#!');
            	component.set("v.display", false);
            }
        }
	},
  
 	// this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
	   console.log('FIRING AssetWCInfo.showSpinner');
       component.set("v.Spinner", true); 
   },
    
 	// this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     	// make Spinner attribute to false for hide loading spinner
		console.log('FIRING AssetWCInfo.hideSpinner'); 
    	component.set("v.Spinner", false);
    }
})