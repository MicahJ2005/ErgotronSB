({
    SalesrepData : function(component, event) {
        
        var action = component.get("c.getRepData");
        action.setParams({
            strStateCode: component.get("v.StateCode"),
            strPostalCode: component.get("v.PostalCode"),
            strCountryCode: component.get("v.CountryCode")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS"){
                var objRepData = response.getReturnValue();
                
                component.set("v.RepData", objRepData);
                var strCommentBody = 'WHO IS MY SALES REP = ' + objRepData.x_sales_rep_name + ' PHONE: ' + objRepData.x_sales_rep_phone + ' EMAIL: ' + objRepData.x_sales_rep_email;
                component.set("v.RepCaseComment", strCommentBody);
            }
            if(state === "ERROR"){

            }
        });
        $A.enqueueAction(action);
	}
})