({
    init: function(component, event, helper) {
        const flow = component.find("flowData");

        flow.startFlow("Convert_Staged_Notes_to_Enhanced_Notes");
    },

    handleStatusChange: function(component, event, helper) {
        const status = event.getParam("status");

        if (status === "FINISHED" || status === "FINISHED_SCREEN") {
            $A.get("e.force:closeQuickAction").fire();
        }
    }
});