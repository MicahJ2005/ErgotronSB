({
    doInit : function(component, event, helper) {
        var pageReference = component.get("v.pageReference");
        var ccOrderId = pageReference.state.c__orderId;
        component.set("v.ccOrderId", ccOrderId);
        var action = component.get("c.createSalesOrder");
        action.setParams({ ccOrderId : ccOrderId }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue() == 'true'){
                    helper.showToast(component, event, helper, 'Success !!', 'Sales Order Created Sccessfully!', 'success' );
                    window.location.href = '/lightning/r/ccrz__E_Order__c/'+ ccOrderId +'/view';
                }
                else if(response.getReturnValue() == 'false'){
                    helper.showToast(component, event, helper, 'Failure !!', 'Could not create sales order!', 'error' );
                    window.location.href = '/lightning/r/ccrz__E_Order__c/'+ ccOrderId +'/view';
                }
                    else if(response.getReturnValue() == 'NA'){
                         helper.showToast(component, event, helper, 'Information !!', 'Sales order already submitted to Oracle!', 'warning' );
                    window.location.href = '/lightning/r/ccrz__E_Order__c/'+ ccOrderId +'/view';
                    }
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    helper.showToast(component, event, helper, 'Error !!', 'Something went wrong!', 'error' );
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                    window.location.href = '/lightning/r/ccrz__E_Order__c/'+ ccOrderId +'/view';
                }
        });
        
        $A.enqueueAction(action);
    }
    
})