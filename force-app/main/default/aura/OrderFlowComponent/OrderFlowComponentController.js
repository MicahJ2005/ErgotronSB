({
	makeTab1tActive : function(component, event, helper){
        var tab1 = component.find("tab-1");
        var tab2 = component.find("tab-2");
        var tab3 = component.find("tab-3");
        var tabData1 = component.find("tab-data-1");
        var tabData2 = component.find("tab-data-2");
        var tabData3 = component.find("tab-data-3");

        $A.util.addClass(tab1,"slds-is-active");
        $A.util.addClass(tabData1,"slds-show");
        $A.util.removeClass(tabData1,"slds-hide");

        $A.util.removeClass(tab2,"slds-is-active");
        $A.util.addClass(tabData2,"slds-hide");
        $A.util.removeClass(tabData2,"slds-show");

        $A.util.removeClass(tab3,"slds-is-active");
        $A.util.addClass(tabData3,"slds-hide");
        $A.util.removeClass(tabData3,"slds-show");
        
    },
    makeTab2Active : function(component, event, helper){
        var tab1 = component.find("tab-1");
        var tab2 = component.find("tab-2");
        var tab3 = component.find("tab-3");
        var tabData1 = component.find("tab-data-1");
        var tabData2 = component.find("tab-data-2");
        var tabData3 = component.find("tab-data-3");

        $A.util.addClass(tab2,"slds-is-active");
        $A.util.addClass(tabData2,"slds-show");
        $A.util.removeClass(tabData2,"slds-hide");

        $A.util.removeClass(tab1,"slds-is-active");
        $A.util.addClass(tabData1,"slds-hide");
        $A.util.removeClass(tabData1,"slds-show");

        $A.util.removeClass(tab3,"slds-is-active");
        $A.util.addClass(tabData3,"slds-hide");
        $A.util.removeClass(tabData3,"slds-show");
    },
    makeTab3Active : function(component, event, helper){
        var tab1 = component.find("tab-1");
        var tab2 = component.find("tab-2");
        var tab3 = component.find("tab-3");
        var tabData1 = component.find("tab-data-1");
        var tabData2 = component.find("tab-data-2");
        var tabData3 = component.find("tab-data-3");

        $A.util.addClass(tab3,"slds-is-active");
        $A.util.addClass(tabData3,"slds-show");
        $A.util.removeClass(tabData3,"slds-hide");

        $A.util.removeClass(tab2,"slds-is-active");
        $A.util.addClass(tabData2,"slds-hide");
        $A.util.removeClass(tabData2,"slds-show");

        $A.util.removeClass(tab1,"slds-is-active");
        $A.util.addClass(tabData1,"slds-hide");
        $A.util.removeClass(tabData1,"slds-show");
    },
    init : function (component) {

        var action = component.get("c.getOracleReturnReason");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS"){
                component.set("v.lstretReason", response.getReturnValue());
            }
            if(state === "ERROR"){
                var errors = response.getError();
                console.log("Error message: " + errors[0].message);
            }
        });
        $A.enqueueAction(action);
        
        var actionCase = component.get("c.getCaseDetails");
        actionCase.setParams({
            strCaseId : component.get("v.recordId")
        });
        actionCase.setCallback(this, function(response) {
            var stateCase = response.getState();
            if(component.isValid() && stateCase === "SUCCESS") {
                component.set("v.objCase", response.getReturnValue());
                // $A.util.addClass(spinner,"slds-hide");
                console.log(response.getReturnValue());
            }
        });
        $A.enqueueAction(actionCase);

		// Business Logic Tests
		var logicBlockDiv = component.find("blockAccess");
		var ergoOrderDiv = component.find("topDivErgotron");
		var logicCase = component.get("c.getTestCaseBusinessLogic");
		logicCase.setParams({
			strCaseId : component.get("v.recordId")
		});
		logicCase.setCallback(this, function(response) {
			var stateLogic = response.getState();
			if(component.isValid() && stateLogic === "SUCCESS") {

				//debugger;

				var lstLogicReasons = response.getReturnValue();
				component.set("v.lstBusinessLogic", response.getReturnValue());

				if(lstLogicReasons.length > 0) {
					$A.util.removeClass(logicBlockDiv,"slds-hide");
					$A.util.addClass(ergoOrderDiv,"slds-hide");
				} else {
					$A.util.addClass(logicBlockDiv,"slds-hide");
					$A.util.removeClass(ergoOrderDiv,"slds-hide");
				}


				//if(!response.getReturnValue()) {
				//	$A.util.removeClass(logicBlockDiv,"slds-hide");
				//	$A.util.addClass(ergoOrderDiv,"slds-hide");
				//}
			}
		});
		$A.enqueueAction(logicCase);

        
	},
	handleStatusChange : function (component, event) {
		if(event.getParam("status") === "FINISHED") {
			var outputVariables = event.getParam("outputVariables");
			var outputVar;
			console.log('outputVariables: ' + outputVariables);
			for(var i = 0; i < outputVariables.length; i++) {
				outputVar = outputVariables[i];
				console.log('outputVar: ' + outputVar);
				if(outputVar.name === "OrderId") {
                    var oid = outputVar.value;
                    component.set("v.orderId", oid);
				}
			}
		}
	},
    removepart : function (component,event,helper) {
        var prodId = event.currentTarget.getAttribute('data-pid');
        var lstprod = component.get("v.olines");
        for(var i=0; i<lstprod.length; i++){
            if(prodId === lstprod[i].strProdId){
                lstprod.splice(i,1);
            }
        }
        component.set("v.olines", lstprod);
    }
})