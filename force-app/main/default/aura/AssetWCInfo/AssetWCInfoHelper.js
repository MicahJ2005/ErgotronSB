({
    ParentData : function(component, event) {
		var action = component.get("c.getParentAsset");
        action.setParams({assetId: component.get("v.AssetId")});
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS"){
                var assets = response.getReturnValue();
                if($A.util.isEmpty(assets) && component.get("v.input_WONumber") != null && component.get("v.input_WONumber") != '') {
                    console.log('Zero length return from ParentData, running WorkOrderData');
                    this.WorkOrderData(component, event);
                    component.set("v.displayContract", false);
                    component.set("v.displayChild", false);
                } else {
                    console.log('Full response from ParentData, returning.')
                    component.set("v.wcParent", response.getReturnValue());
                }
            }
            if(state === "ERROR"){

            }
        });
        $A.enqueueAction(action);
	},
    ChildrenData : function(component, event){
    	var action = component.get("c.getChildrenAsset");
        action.setParams({assetId: component.get("v.AssetId")});
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS"){
            	component.set("v.wcINFO", response.getReturnValue());
                console.log(component.get("v.wcINFO"));
            }
            if(state === "ERROR"){

            }
        });
        $A.enqueueAction(action);
	},
    WorkOrderData : function(component, event){
        var action = component.get("c.getWorkOrderWarrantyInformation");
        action.setParams({
			workOrderNumber: component.get("v.input_WONumber"),
			caseId: component.get("v.recordId")
		});
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS"){
				var parentInfo = response.getReturnValue();
				console.log(parentInfo);
            	component.set("v.wcParent", parentInfo);

				console.log('CLI = ' + parentInfo.ContractLineItems);
				if(parentInfo.ContractLineItems != null) {
					component.set("v.displayContract", true);
				}

				console.log('BSN = ' + parentInfo.Battery_Serial_Number__c);
				if(parentInfo.Battery_Serial_Number__c != null) {
					component.set("v.displayChild", true);
				}
                console.log(component.get("v.wcParent"));
            }
            if(state === "ERROR"){

            }
        });
        $A.enqueueAction(action);
    }
})