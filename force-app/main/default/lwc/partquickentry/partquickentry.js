import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';

import getParts from '@salesforce/apex/PartQuickEntryController.getParts';
import getPartShell from '@salesforce/apex/PartQuickEntryController.getPartShell';
import getAllStandardPBE from '@salesforce/apex/PartQuickEntryController.getAllStandardPBE';
import getAllWorkTypes from '@salesforce/apex/PartQuickEntryController.getAllWorkTypes';
import getRequiredPartsFromTemplate from '@salesforce/apex/PartQuickEntryController.getRequiredPartsFromTemplate';
import syncParts from '@salesforce/apex/PartQuickEntryController.syncParts';

import PRODUCTCONSUMED_OBJECT from '@salesforce/schema/ProductConsumed';
import OBSERVATION_FIELD from '@salesforce/schema/ProductConsumed.Observation__c';
import CP_FIELD from '@salesforce/schema/ProductConsumed.Critical_Part__c';
import STATUS_FIELD from '@salesforce/schema/ProductConsumed.Status__c';
import RMA_ITEM_STATUS_FIELD from '@salesforce/schema/ProductConsumed.RMA_Item_Status__c';
import SOURCE_FIELD from '@salesforce/schema/ProductConsumed.Source__c';



export default class Partquickentry extends LightningElement 
{
  

    @api recordId;
    draftValues = [];
    error;
    @track parts=[];
    shell={};
    ismodified = false;
    allpbe = [];
    waiting = false;

    @track pcObjInfo;
    @api pcDefaultRecordTypeId;
    cpOptions;
    obOptions;    
    statusOptions;
    rmaItemStatusOptions;
    sourceOptions;
    templateOptions;

    get haveParts()
    {
        if(this.parts && this.parts.length>0)
            return true;

        return false;
    }

    @wire(getObjectInfo, { objectApiName: PRODUCTCONSUMED_OBJECT })
    pcObjInfoAdaptor(result) {
        if(result.data) {
            this.pcObjInfo = result.data;
            this.pcDefaultRecordTypeId = result.data.defaultRecordTypeId;
        }
    }   
    
    @wire(getPicklistValues, { recordTypeId: '$pcDefaultRecordTypeId', fieldApiName: OBSERVATION_FIELD })
    observationPicklistValues(result){
        if(result.data) {
            this.obOptions = result.data.values;
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$pcDefaultRecordTypeId', fieldApiName: CP_FIELD })
    criticalPartPicklistValues(result){
        if(result.data) {
            this.cpOptions = result.data.values;
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$pcDefaultRecordTypeId', fieldApiName: STATUS_FIELD })
    statusPicklistValues(result){
        if(result.data) {
            this.statusOptions = result.data.values;
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$pcDefaultRecordTypeId', fieldApiName: RMA_ITEM_STATUS_FIELD })
    rmaItemstatusPicklistValues(result){
        if(result.data) {
            this.rmaItemStatusOptions = result.data.values;
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$pcDefaultRecordTypeId', fieldApiName: SOURCE_FIELD })
    sourcePicklistValues(result){
        if(result.data) {
            this.sourceOptions = result.data.values;
        }
    }

    connectedCallback()
    {
        console.log("WorkOrderId:" + this.recordId);
        this.initdata();
    }

    initdata()
    {
        console.log("initdata");
        this.ismodified = false;
        this.waiting = false;

        getParts( { workOrderId: this.recordId } )
        .then(result => 
        {

            console.log('result--->'+result);
            this.parts = [];
            for(let part of result)
            {
                let copy = {};
                copy = Object.assign(copy,  part); 
                this.parts = [...this.parts, copy];
            };
            console.log('this.partsgetParts---->'+JSON.stringify(this.parts));


            getPartShell( { workOrderId: this.recordId } )
                .then(result2 => 
                {
                    //console.log('getPartShell result2---->'+JSON.stringify(result2));
                    this.shell = Object.assign(this.shell, result2); 
                    this.shell.partId = -1;
                    this.shell.deleted=false;
                    this.shell.bgColor = 'background-color:lightblue;';

                    getAllStandardPBE()
                    .then(result3 => 
                    {
                        //console.log('getAllStandardPBE result3---->'+JSON.stringify(result3));
                        this.allpbe = Object.assign(this.allpbe, result3); 
                        this.parts = [...this.parts];

                        getAllWorkTypes()
                        .then(result4 => {
                            let options = [];

                            for(let workType of result4)
                            {
                                options.push({ label: workType.Name, value: workType.Id});
                            }

                            this.templateOptions = options;
                        }) 
                        .catch(error => 
                        {
                            this.error = error;
                            console.error(this.error);
                        });
                    })
                    .catch(error => 
                    {
                        this.error = error;
                        console.error(this.error);
                    });

                })
                .catch(error => 
                {
                    this.error = error;
                    console.error(this.error);
                });                
            //console.log('parts--->'+JSON.stringify(this.parts));
        })
        .catch(error => 
        {
            this.error = error;
            console.error(this.error);
        });        
    }

    get pbeoptions()  
    {
        let options = [];

        for(let pbe of this.allpbe)
        {
            options.push({ label: pbe.Product2.Name, value: pbe.Id, description: pbe.Description__c, cp: pbe.Product2.Critical_Part__c, ob: pbe.Product2.Observation__c, serialized: pbe.Product2.IsSerialized});
        }

        return options;
    }

    get partcount()
    {
        var count = 0;
        for (var i = 0; i < this.parts.length; i++) 
        {
            if(this.parts[i].deleted)
                continue;
            count++;
        }
        return count;
    }

    templateId;
    handleTemplateSelection(event) {
        this.templateId = event.detail.value;
    }

    handleTemplateOnClick(event) {
        getRequiredPartsFromTemplate({ workTypeId: this.templateId })
        .then(result => {
            for(let productRequired of result)
            {
                this.addrowWithPart(productRequired.Product2Id);                           
            }
        }) 
        .catch(error => 
        {
            this.error = error;
            console.error(this.error);
        });
    }

    addrowWithPart(productId)
    {
        let copy = {};
        copy = Object.assign(copy,  this.shell); 

        for(let pbe of this.allpbe)
        {
            if(pbe.Product2Id == productId) {
                copy.priceBookEntryId = pbe.Id;
                copy.productId = pbe.Product2Id
                copy.productName = pbe.Product2.Name;
                if(pbe.Product2.Critical_Part__c)
                    copy.criticalPart = pbe.Product2.Critical_Part__c;
                //else
                    //copy.criticalPart = 'None';

                if(pbe.Product2.Observation__c)                    
                    copy.observation =  pbe.Product2.Observation__c;
                //else 
                    //copy.observation = 'None';
                //copy.source =  'Enovate Stock';
                //copy.status =  'Ordered';
            }            
        }             

        this.parts = [...this.parts, copy];
        this.shell.partId =  this.shell.partId - 1;
        this.shell.bgColor = 'background-color:lightblue;';
        this.ismodified = true;
    }

    addrow()
    {
        let copy = {};
        copy = Object.assign(copy,  this.shell); 

        this.parts = [...this.parts, copy];
        this.shell.partId =  this.shell.partId - 1;
        this.shell.bgColor = 'background-color:lightblue;';
        this.ismodified = true;
    }

    dodelete(event)
    {

        var key = event.target.dataset.partid;
        let partName;
        let partStatus;
        console.log("dodelete " + key);

        var i;
        for (i = 0; i < this.parts.length; i++)
        {
            if(this.parts[i].partId==key)
            {
                //this.parts[i].deleted = true;
                partName = this.parts[i].productName;
                partStatus = this.parts[i].status;
            }
        }

        //let continueDeletion = false;
        let confirmMessage = 'Presss OK to delete part';

        if(partName && !partStatus) {
            confirmMessage = "Presss OK to delete part '" + partName + "'";
        }    

        if(partName && partStatus) {
            confirmMessage = "Presss OK to delete part '" + partName + "' with status '" + partStatus + "'";
        }        
            

        if (confirm(confirmMessage) == false) {
            return;
        } 
        
        //console.log('----->'+continueDeletion);
        for (i = 0; i < this.parts.length; i++) 
        {
            if(this.parts[i].partId==key)
            {
                this.parts[i].deleted = true;
            }
        }

        this.parts = [...this.parts];
        this.ismodified = true;             
    }

    handlePartChange(event)
    {
        var pbeid = event.detail.value;
        var key = event.target.dataset.partid;
        var cp = event.detail.cp;
        var ob = event.detail.ob;
        var serialized = event.detail.serialized;


        console.log("handlePartChange " + pbeid + " " + key + " " + cp);
        console.log("handlePartChange " + pbeid + " " + key + " " + ob);

        var i;
        for (i = 0; i < this.parts.length; i++) 
        {
            if(this.parts[i].partId==key)
            {
                this.parts[i].priceBookEntryId=pbeid;
                this.parts[i].criticalPart=cp;
                this.parts[i].observation=ob;
                this.parts[i].productName=event.detail.label;
                this.parts[i].serialized=serialized;
                console.log('Serialized:' + serialized);
            }
            console.log('OutSerialized:' + serialized);
        }

        this.parts = [...this.parts];
        this.validateFields();               
        this.ismodified = true;
    }   

    handleObservationChange(event)
    {
        var observation = event.detail.value;
        var key = event.target.dataset.partid;

        this.updatePartDetails(key, 'observation', observation);
    }

    handleStatusChange(event)
    {
        var status = event.detail.value;
        var key = event.target.dataset.partid;

        this.updatePartDetails(key, 'status', status);    
    }

    handleRMAItemStatusChange(event)
    {
        var rmaItemstatus = event.detail.value;
        var key = event.target.dataset.partid;

        this.updatePartDetails(key, 'rmaItemStatus', rmaItemstatus);        
    }

    handleSourceChange(event)
    {
        var source = event.detail.value;
        var key = event.target.dataset.partid;

        this.updatePartDetails(key, 'source', source);
    }

    handleCriticalPartChange(event)
    {
        var criticalPart = event.detail.value;
        var key = event.target.dataset.partid;

        var statusElement = this.template.querySelector('.partstatus[data-partid="'+key+'"]');
        statusElement.dataset.cp = criticalPart;
        console.log('---handleCriticalPartChange---'+statusElement.name);
        console.log(statusElement.dataset.cp);

        this.updatePartDetails(key, 'criticalPart', criticalPart);
    }

    handleSROChange(event)
    {
        var sroNumber = event.detail.value;
        var key = event.target.dataset.partid;

        this.updatePartDetails(key, 'sroNumber', sroNumber);
    }

    handleTrackingChange(event)
    {
        var trackingNumber = event.detail.value;
        var key = event.target.dataset.partid;

        this.updatePartDetails(key, 'trackingNumber', trackingNumber);
    }

    handleRMATrackingChange(event)
    {
        var rmaTrackingNumber = event.detail.value;
        var key = event.target.dataset.partid;
        
        this.updatePartDetails(key, 'rmaTrackingNumber', rmaTrackingNumber);
    }

    handleOldSNChange(event)
    {
        var oldSerialNumber = event.detail.value;
        var key = event.target.dataset.partid;        

        this.updatePartDetails(key, 'oldSerialNumber', oldSerialNumber);
    }

    handleNewSNChange(event)
    {
        var newSerialNumber = event.detail.value;
        var key = event.target.dataset.partid;        

        this.updatePartDetails(key, 'newSerialNumber', newSerialNumber);
    }

    updatePartDetails(key, propName, propValue) {
        console.log('this.parts---->'+JSON.stringify(this.parts));
        console.log(propName +" - " + propValue + " - " + key);

        const index = this.parts.findIndex(element => element.partId == key);
        this.parts[index][propName] = propValue;
        this.conditionalyRequiredFields(index);    

        console.log('this.parts---->'+JSON.stringify(this.parts));
        this.parts = [...this.parts];
        this.validateFields();
        this.ismodified = true;
      
    }

    /*
    renderedCallback() {
        this.validateFields();
    }
    */


    /**
     * @description : Used to mimic some requirements from a validation rule
     *
     * @author Matthew J Lennington -- (Demand Chain)
     * @date 2025-07-18
     *
    */
    conditionalyRequiredFields(index) {
        this.parts[index].ArtikReplacement = false;
        const statusSet = ['DOA - Returned', 'Returned to Enovate', 'Used for repair'];
        if(this.parts[index].criticalPart == 'Artik'){
            if(statusSet.includes(this.parts[index].status)){
                this.parts[index].ArtikReplacement = true;
            }
        } 
    }


    dosave()
    {
        console.log("dosave");
        
        if(!this.validateFields())
        {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Please correct all errors indicated below before saving',
                variant: 'error',
            });
            this.dispatchEvent(evt);
            return;
        }

        this.waiting = true;

        let listdelete = [];
        let listupsert = [];
        
        try
        {
            var i;
            for (i = 0; i <this.parts.length; i++) 
            {
            
                if(this.parts[i].deleted && this.parts[i].partId<=0)
                {
                    console.log("skipped - part was not saved to database, so deletion not required");
                    continue;
                }
                else if(this.parts[i].deleted)
                {
                    console.log("delete part");
                    listdelete.push(this.parts[i]);
                }
                else
                {
                    
                    console.log("upsert:" + JSON.stringify(this.parts[i]));
                    listupsert.push(this.parts[i]);
                }
            }

            syncParts({toupsert:listupsert, todelete:listdelete})
                .then(result => 
                {
                    console.log('SUCCESS!');
                    console.log('result--->'+JSON.stringify(result));
                    const evt = new ShowToastEvent({
                        title: 'Save confirmed',
                        message: 'Parts have been saved successfully ',
                        variant: 'Success',
                    });
                    this.dispatchEvent(evt);
                })
                .catch(error => 
                {             
                    console.error(error);
                    if (Array.isArray(error.body)) {
                        this.error = error.body.map(e => e.message).join(', ');
                    } 
                    else if (typeof error.body.message === 'string') {
                        this.error = error.body.message;
                    }
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: 'There was an error, please contact Salesforce admin with following details: '+ this.error,
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);

                })
                .finally(() =>
                {
                    this.initdata();
                });

        }
        catch(e)
        {
            console.error(e);
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'There was an error, please contact Salesforce admin with following details: '+e.message,
                variant: 'error',
            });
        }                
        
    }

    validateFields() 
    {
        console.log("------validateFields----------");
        let ret = true;

        this.template.querySelectorAll('c-combobox-autocomplete').forEach(element => 
        {
            if(!element.reportComboBoxValidity())
            {
                ret=false;                
            }
        });

        this.template.querySelectorAll('lightning-combobox').forEach(element => 
        {
            console.log(JSON.stringify(element, null, 4));
            console.log('validateFields----'+element.name+'----'+element.value);

            if(!element.reportValidity())
            {
                ret=false;                
            }
            
            let status = element.value;
            let partId = element.dataset.partid;            
            let criticalPartValue = element.dataset.cp;  
            let comboElementName = element.name;
            let sr = element.dataset.serialized;

            this.template.querySelectorAll('lightning-input').forEach(element => 
            {
                //console.log('----'+element.name+'----'+element.value +'----'+status);
                console.log('element.dataset.serialized---------------------------' ,sr);
              
                if(comboElementName == 'statuscombo' && element.dataset.partid == partId && (element.name == 'snNew' || element.name == 'snOld')) {
                    console.log('element.dataset.serialized---' ,sr);
 
                    element.setCustomValidity('');                        
                    if(criticalPartValue != '' && criticalPartValue != 'None' && status == 'Used for repair' && sr == "true" && element.value == '') {
                        element.setCustomValidity('Complete this field.');                        
                    }

                    if((criticalPartValue == 'Power System' || criticalPartValue == 'Phosphate Battery') && status == 'Added to Van Stock' && element.value == '' && element.name == 'snNew' && sr == "true") {
                        element.setCustomValidity('Complete this field.');                        
                    }
                }            
                if(comboElementName == 'statuscombo' && element.dataset.partid == partId && element.name == 'rmanumber')  {
                    element.setCustomValidity('');                        
                    if(criticalPartValue != '' && criticalPartValue != 'None' && (status == 'Used for repair' || status == 'Returned to Enovate') && element.value == '' && sr == "true") {
                        element.setCustomValidity('Complete this field.');                        
                    }
                }     
                
                /*
                if(comboElementName == 'sourcecombo' && element.dataset.partid == partId && element.name == 'sronumber')  {
                    element.setCustomValidity('');        
                    if(element.value == '' && status == 'SRO') {                                    
                        element.setCustomValidity('Complete this field when Source is SRO');                           
                    }
                }
                */
                    
            });                  
        });

        this.template.querySelectorAll('lightning-input').forEach(element => 
        {                
            if(!element.reportValidity())
            {
                ret=false;                
            }                
        });
        
        return ret;
    }

    docancel()
    {
        this.parts = [];
        this.initdata();
    }        
}