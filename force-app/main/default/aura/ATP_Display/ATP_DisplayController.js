({
	getPartNumberATP : function(component, event, helper) {
		var pnumber = component.get("v.PartNumber");
		if(pnumber != null){
			var spinner = component.find("mySpinner");
	        $A.util.removeClass(spinner,"slds-hide");
			var action = component.get("c.getATPData");
			action.setParams({partNumber: pnumber});
			action.setCallback(this, function(response){
				var state = response.getState();
				if(component.isValid() && state === "SUCCESS"){
					component.set("v.ATPData", response.getReturnValue());
					// debugger;
					$A.util.addClass(spinner,"slds-hide");

					var atpList = component.find("atpList");
					$A.util.removeClass(atpList,"slds-hide");
				}
				if(state === "ERROR"){
	                var errors = response.getError();
	                console.log("Error message: " + errors[0].message);
	                $A.util.addClass(spinner,"slds-hide");
	            }
			});
			$A.enqueueAction(action);
		}
	},
	getPartList : function(component, event, helper) {
		var pName = component.get("v.PartName");
		if(pName != null){
			var spinner = component.find("mySpinner");
	        $A.util.removeClass(spinner,"slds-hide");
			var pName = component.get("v.PartName");
			var action = component.get("c.productNameLookup");
			action.setParams({partName: pName});
			action.setCallback(this, function(response){
				var state = response.getState();
				if(component.isValid() && state === "SUCCESS"){
					component.set("v.lstParts", response.getReturnValue());
					var plist = component.find("partlist");
	        		$A.util.removeClass(plist,"slds-hide");
	        		$A.util.addClass(spinner,"slds-hide");
				}
				if(state === "ERROR"){
	                var errors = response.getError();
	                console.log("Error message: " + errors[0].message);
	                $A.util.addClass(spinner,"slds-hide");
	            }
			});
			$A.enqueueAction(action);
		}
	},
    
    // esanchez 20200129 - Removing functionallity to search from BOM
/*	getBOMPartList : function(component, event, helper) {
		var pName = component.get("v.PartName");
		if(pName != null){
			var rId = component.get("v.recordId");
			var spinner = component.find("mySpinner");
		    $A.util.removeClass(spinner,"slds-hide");
		    var action = component.get("c.productNameLookupInBOM");
		    action.setParams({partName: pName, caseId: rId});
				action.setCallback(this, function(response){
				var state = response.getState();
				if(component.isValid() && state === "SUCCESS"){
					component.set("v.lstParts", response.getReturnValue());
					var plist = component.find("partlist");
	        		$A.util.removeClass(plist,"slds-hide");
	        		$A.util.addClass(spinner,"slds-hide");
				}
				if(state === "ERROR"){
	                var errors = response.getError();
	                console.log("Error message: " + errors[0].message);
	                $A.util.addClass(spinner,"slds-hide");
	            }
			});
			$A.enqueueAction(action);
		}
	}, */
	setPartNumber : function(component, event, helper) {
		component.set("v.PartNumber", component.get("v.selectedPart"));
	},
	partNumberAdded : function(component, event, helper){
		var pnum = component.get("v.PartNumber");
		var divQTYWarehouse = component.find("QTYWarehouse");
	    $A.util.removeClass(divQTYWarehouse,"slds-hide");
	    if(pnum != null){
	    	component.set("v.allowAdd", false);
	    }
	    else{
	    	component.set("v.allowAdd", true);
	    }
	},
	addOrderLine : function(component, event, helper) {
		var pnum = component.get("v.PartNumber");
		var pQty = component.get("v.partQty");
		var pWH = component.get("v.partWarehouse");
		var ret = component.get("v.retReason");
		var bolCancel = false;

		var inputWarehouse = component.find("inputWarehouse");
		var inputQuantity = component.find("inputQuantity");
		var inputReturnReason = component.find("inputReturnReason");
		inputWarehouse.set("v.errors", [{message: null}]);
		inputQuantity.set("v.errors", [{message: null}]);
		inputReturnReason.set("v.errors", [{message: null}]);

		if(pWH == null) {
			console.log("Warehouse not found, exiting");
			inputWarehouse.set("v.errors", [{message: "You must select a warehouse!"}]);
			bolCancel = true;
		}
		if(pQty == null) {
			console.log("Quantity not entered, exiting");
			inputQuantity.set("v.errors", [{message: "You must specify a quantity!"}]);
			bolCancel = true;
		}

		console.log('*****************');
		console.log(parseInt(pQty));
		console.log(ret);

		if(parseInt(pQty) < 0 && (ret == null || ret == '')) {
			console.log("Return Reason not provided, exiting");
			inputReturnReason.set("v.errors", [{message: "If you are returning product, you MUST provide a Return Reason"}]);
			bolCancel = true;
		}

		if(bolCancel) { return; }

		if(pnum != null && pQty != null && pWH != null){
			var spinner = component.find("mySpinner");
	        $A.util.removeClass(spinner,"slds-hide");
	        var action = component.get("c.createhelperClassPartData");
			action.setParams({strPartNum: pnum, strPQty: pQty,strPWarehouse :pWH, retName:ret});
			action.setCallback(this, function(response){
				var state = response.getState();
				if(component.isValid() && state === "SUCCESS"){
					var plist = component.get("v.olines");
					plist.push(response.getReturnValue());
					console.log("plist: " + plist.length);
					component.set("v.olines", plist);
					component.set("v.partQty", null);
					component.set("v.partWarehouse", null);
					component.set("v.selectedPart", "");
					component.set("v.PartName", "");
					component.set("v.PartNumber", "");
					component.set("v.retReason", "");
					component.set("v.ATPData", null);
					component.set("v.allowAdd", true);
	        		$A.util.addClass(spinner,"slds-hide");
	        		var divParList = component.find("partlist");
	        		$A.util.addClass(divParList,"slds-hide");
	        		//var divQTYWarehouse = component.find("QTYWarehouse");
	        		//$A.util.addClass(divQTYWarehouse,"slds-hide");
	        		var retLine = component.find("returnList");
					$A.util.addClass(retLine,"slds-hide");

					var atpList = component.find("atpList");
					$A.util.addClass(atpList,"slds-hide");

					component.set("v.allowAdd", true);

					
				}
				if(state === "ERROR"){
	                var errors = response.getError();
	                console.log("Error message: " + errors[0].message);
	                $A.util.addClass(spinner,"slds-hide");
	            }
			});
			$A.enqueueAction(action);
		}
	},
	displayRetReason : function(component, event, helper) {
		var enteredQty = component.get("v.partQty");
		var retLine = component.find("returnList");

		if(enteredQty < 0){
			$A.util.removeClass(retLine,"slds-hide");
		} else {
			$A.util.addClass(retLine,"slds-hide");
		}
	},
	chooseWarehouse : function(component, event, helper) {
		
		console.log(event.getSource().get("v.name"));

		component.set("v.partWarehouse", event.getSource().get("v.name"));
		var pQty = component.get("v.partQty");

		if(pQty == '') {
			component.set(pQty, "1");
		}

		component.find("inputQuantity").focus();

	}
})