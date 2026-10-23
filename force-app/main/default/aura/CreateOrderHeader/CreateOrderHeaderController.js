({
	init : function(component, event, helper) {
		//debugger;
		var caseId = component.get("v.caseId");
		var action = component.get("c.getOrderSelections");
		action.setParams({caseId : caseId});
		action.setCallback(this, function(response){
			var state = response.getState();
            if(component.isValid() && state === "SUCCESS"){
				var resp = response.getReturnValue();
                component.set("v.lstBillTos", resp.lstAcct);
				component.set("v.lstShipTos", resp.lstAcct);
				component.set("v.lstOrderTypes", resp.lstOrderType);
				component.set("v.defAcct", resp.defAcct);
				component.set("v.billTo", resp.defAcct);
				component.set("v.shipTo", resp.defAcct);
                component.set("v.ponum", resp.strCaseNumber);
                
                helper.getShipToContacts(component);
            }     
		});
		$A.enqueueAction(action);
        
        

	},
	getmoreBillTos : function(component, event, action){
		var acctname = component.get("v.bName");
		var action = component.get("c.getMoreAccounts");

		var spinner = component.find("mySpinner");
	    $A.util.removeClass(spinner,"slds-hide");

		action.setParams({strAcctName : acctname});
		action.setCallback(this, function(response){
			var state = response.getState();
            if(component.isValid() && state === "SUCCESS"){
                component.set("v.lstAddBillTos", response.getReturnValue());
				var billSelect = component.find("selectadditonalbill");
				$A.util.removeClass(billSelect,"slds-hide");
				$A.util.addClass(spinner,"slds-hide");
            }        
		});
		$A.enqueueAction(action);
	},
	getmoreShipTos : function(component, event, action){
		var acctname = component.get("v.sName");
        
        var spinner = component.find("mySpinner");
	    $A.util.removeClass(spinner,"slds-hide");
        
		var action = component.get("c.getMoreAccounts");       
		action.setParams({strAcctName : acctname});
		action.setCallback(this, function(response){
			var state = response.getState();
            if(component.isValid() && state === "SUCCESS"){
                component.set("v.lstAddShipTos", response.getReturnValue());
				var shipSelect = component.find("selectadditonalShip");
				$A.util.removeClass(shipSelect,"slds-hide");
                $A.util.addClass(spinner,"slds-hide");
            }        
		});
		$A.enqueueAction(action);
	},
	allowMoreBillTos : function(component, event, action){
		//debugger;
		var bt = component.get("v.billTo");
		if(bt === "searchBill"){
			var billentry = component.find("enterbill");
			$A.util.removeClass(billentry,"slds-hide");
		}
	},
	allowMoreShipTos : function(component, event, helper){
		var st = component.get("v.shipTo");
		if(st === "searchShip"){
			var shipentry = component.find("entership");
			$A.util.removeClass(shipentry,"slds-hide");
            var inputDD = event.getSource();
            inputDD.set("v.disabled", true);
        } else {
            helper.getShipToContacts(component);
        }
	},
    searchForBTContacts : function(component, event, helper) {
        helper.getShipToContacts(component);
    },
	submitOrder : function(component, event, action){
        
        var spinner = component.find("mySpinner");
	    $A.util.removeClass(spinner,"slds-hide");
		var bId = component.get("v.billTo");
        
		if(bId === "searchBill"){
			bId = component.get("v.addbillTo");
		}
        
		var sId = component.get("v.shipTo");
		if(sId === "searchShip"){
			sId = component.get("v.addshipTo");
		}
        
		var po = component.get("v.ponum");
		var n = component.get("v.notes");
		var ot = component.get("v.oType");
		var cId = component.get("v.caseId");
		var parts = component.get("v.olines");
		var acct = component.get("v.defAcct");
        var sToContactId = component.get("v.shipToContact")
		var jsonParts = JSON.stringify(parts);
        
        // Business Logic
        if(ot == null || ot == '') {
            component.set("v.errorMessage","You *MUST* select a valid Order Type before proceeding!");
            $A.util.addClass(spinner,"slds-hide");
            return;
        } 
        
        if(sToContactId == null || sToContactId == '') {
            component.set("v.errorMessage","You *MUST* select a valid Ship To Contact before proceeding!");
            $A.util.addClass(spinner,"slds-hide");
            return;
        }
        
		if(parts.length>0){
			var action = component.get("c.createOrder");
			action.setParams({
						strParts : jsonParts,
						POnum : po, 
						BillToId : bId, 
						ShipToId : sId, 
						Notes : n, 
						OrderType : ot,
						caseId : cId,
                		shipToContactId : sToContactId
           	});
			action.setCallback(this, function(response){
				var state = response.getState();
                var objCase = component.get("v.objCase");
				if(component.isValid() && state === "SUCCESS"){
					component.set("v.errorMessage", response.getReturnValue());
					component.set("v.olines", []);
					component.set("v.ponum", objCase.CaseNumber);
					component.set("v.notes", "");
					component.set("v.oType", "");
					component.set("v.billTo", acct);
					component.set("v.shipTo", acct);
					$A.util.addClass(spinner,"slds-hide");
				}
				else{
					$A.util.addClass(spinner,"slds-hide");
                }
                
                var shipentry = component.find("entership");
				$A.util.addClass(shipentry,"slds-hide");

				var billentry = component.find("enterbill");
				$A.util.addClass(billentry,"slds-hide");

                var inputDD = component.find("ShipToListPicker");
                inputDD.set("v.disabled", false);

				var reinitComponent = component.get('c.init');
				$A.enqueueAction(reinitComponent);
                
			});
			$A.enqueueAction(action);

		}
		else{
			component.set("v.errorMessage","Please Add Lines to the order before submitting.");
            $A.util.addClass(spinner,"slds-hide");
		}
	}
})