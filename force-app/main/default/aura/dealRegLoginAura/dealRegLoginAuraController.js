({
    init : function(component, event, helper) {
        let startUrl = helper.getQueryVariable('startURL');
		component.set("v.startUrl", startUrl);
        
	},
    handleUsernameUpdate : function(component, event) {
        component.set("v.username", event.getSource().get("v.value"));
    },
    handlePasswordUpdate : function(component, event){
        component.set("v.password", event.getSource().get("v.value"));
    },
    handleLogin : function(component, event){
        event.preventDefault();
        event.stopPropagation();
        let username = component.get("v.username");
        let password = component.get("v.password");
        let startUrl = component.get("v.startUrl");
        if(!$A.util.isEmpty(username) && !$A.util.isEmpty(password)){
            var action = component.get("c.login");
            debugger;
            action.setParams({ username : username, password : password, startUrl : startUrl });
            action.setCallback(this, function(response) {
                debugger;
                var state = response.getState();
                if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            component.set("v.error", errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        }
    }
})