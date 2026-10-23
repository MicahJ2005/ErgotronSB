({
	handleUsernameUpdate : function(component, event) {
        component.set("v.username", event.getSource().get("v.value"));
    },
    handleReset : function(component){
        let username = component.get("v.username");
        if(!$A.util.isEmpty(username)){
            var action = component.get("c.reset");
            action.setParams({ username : username});
            action.setCallback(this, function(response) {
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
                }else{
                    window.location.href = './CheckPasswordResetEmail';
                }
            });
            $A.enqueueAction(action);
        }
    }
})