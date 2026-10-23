({
	getMoreAccts : function(Component, Event) {
		
	},
    getShipToContacts : function(component){
                
        var sId = component.get("v.shipTo");
		if(sId === "searchShip"){
			sId = component.get("v.addshipTo");
		}
        
        var action = component.get("c.getShipToContacts");
        action.setParams({
            strAccountId : sId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.lstSTContacts", response.getReturnValue());
                //$A.util.addClass(spinner,"slds-hide");
            }
        });
        $A.enqueueAction(action);
        
        
    }
})