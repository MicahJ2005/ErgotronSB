({
	init : function (component) {
		var flow = component.find("flowData");
		var rid = component.get("v.recordId");
		var startId = rid.substring(0,3);
		var strFlow = 'Case';
		if(startId === '003'){
			var inputVariables = [
				{
					name : "ContactId",
					type : "String",
					value: component.get("v.recordId")
				}
			];
		}
		else if(startId === '001'){
			var inputVariables = [
				{
					name : "AcctId",
					type : "String",
					value: component.get("v.recordId")
				}
			];
		}
		else if(startId === '02i'){
			var inputVariables = [
				{
					name : "AssetId",
					type : "String",
					value: component.get("v.recordId")
				}
			];
		}
		else if(startId === 'a0G'){
			var inputVariables = [
				{
					name : "OrderId",
					type : "String",
					value: component.get("v.recordId")
				}
			];
		}
		else if(startId === '500'){
			strFlow = 'Order';
			var inputVariables = [
				{
					name : "CaseId",
					type : "String",
					value: component.get("v.recordId")
				}
			];
		}
		if(strFlow === 'Case'){
			component.set("v.flowType", "Case");
			flow.startFlow("Customer_Care_Entry_Flow", inputVariables);
		}
		if(strFlow === 'Order'){
			component.set("v.flowType", "Order");
			flow.startFlow("Customer_Care_Create_New_Order", inputVariables);
		}
	},
	handleStatusChange : function (component, event) {
		var typeFlow = component.get("v.flowType");

		if(event.getParam("status") === "FINISHED" && typeFlow === "Case") {
			var outputVariables = event.getParam("outputVariables");
			var outputVar;
			console.log('outputVariables: ' + outputVariables);
			for(var i = 0; i < outputVariables.length; i++) {
				outputVar = outputVariables[i];
				console.log('outputVar: ' + outputVar);
				if(outputVar.name === "CaseId") {
					var urlEvent = $A.get("e.force:navigateToSObject");
					urlEvent.setParams({
						"recordId": outputVar.value,
						"isredirect": "true",
						"slideDevName": "detail"
					});
					urlEvent.fire();
				}
			}
		}
	}
})