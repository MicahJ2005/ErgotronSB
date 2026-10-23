import { LightningElement, wire, track } from 'lwc';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import apexGetObject from "@salesforce/apex/ReturnPublicFormController.getReturnObject";
import apexGetReasons from "@salesforce/apex/ReturnPublicFormController.getReasons";
import apexSave from "@salesforce/apex/ReturnPublicFormController.save";
import labelReturnPolicy from '@salesforce/label/c.Return_Policy';
import labelReturnPolicyLabel from '@salesforce/label/c.Return_Policy_Label';
import labelReturnPolicyLink from '@salesforce/label/c.Return_Policy_Link';
import labelReturnHeader from '@salesforce/label/c.Page_1_Header';
import labelPage1SubHeader from '@salesforce/label/c.Page_1_Sub_Header';
import labelPage1SubSubHeader from '@salesforce/label/c.Page_1_Sub_Sub_Header';
import labelPage2SubHeader from '@salesforce/label/c.Page_2_Sub_Header';
import labelPage2SubSubHeader from '@salesforce/label/c.Page_2_Sub_Sub_Header';
import labelPage2ProdListHeader from '@salesforce/label/c.Page_2_Prod_List_Header';
import labelErrorCantFind from '@salesforce/label/c.Error_Cant_Find';
import labelErrorPastWindow from '@salesforce/label/c.Error_Past_Window';
import labelEmailLabel from '@salesforce/label/c.Email_Label';
import labelOrderNumberLabel from '@salesforce/label/c.Order_Number_Label';
import labelThankYou from '@salesforce/label/c.Thank_you';
import labelThankYouMessage1 from '@salesforce/label/c.Thank_You_Message_1';
import labelThankYouMessage2 from '@salesforce/label/c.Thank_You_Message_2';
import labelThankYouRequestRecieved from '@salesforce/label/c.Thank_You_Request_Recieved';
import labelThankYouConcern from '@salesforce/label/c.Thank_You_Concerns';
import labelForSupport from '@salesforce/label/c.For_Support';
import labelThankYouContactUs from '@salesforce/label/c.Contact_Us';
import labelMissingReason from '@salesforce/label/c.Missing_Reason';
import labelQuantityMax from '@salesforce/label/c.Return_Quantity_Max';
import labelQuantityMin from '@salesforce/label/c.Return_Quantity_Min';
import labelRequired from '@salesforce/label/c.Required';
import labelPackagingLabel from '@salesforce/label/c.Packaging_Label';
import labelQuantityLabel from '@salesforce/label/c.Quantity_Label';
import labelReasionLabel from '@salesforce/label/c.Reason_Label';
import labelQty from '@salesforce/label/c.QTY';
import labelPartNumber from '@salesforce/label/c.Part_Number';

export default class ReturnPublicForm extends LightningElement {
    label = {
        labelReturnPolicy,
        labelReturnPolicyLabel,
        labelReturnPolicyLink,
        labelReturnHeader,
        labelPage1SubHeader,
        labelPage1SubSubHeader,
        labelPage2SubHeader,
        labelPage2SubSubHeader,
        labelPage2ProdListHeader,
        labelErrorCantFind,
        labelErrorPastWindow,
        labelEmailLabel,
        labelOrderNumberLabel,
        labelThankYou,
        labelThankYouMessage1,
        labelThankYouMessage2,
        labelThankYouRequestRecieved,
        labelThankYouConcern,
        labelThankYouContactUs,
        labelForSupport,
        labelMissingReason,
        labelQuantityMax,
        labelQuantityMin,
        labelRequired,
        labelPackagingLabel,
        labelQuantityLabel,
        labelReasionLabel,
        labelQty,
        labelPartNumber


    }
    // emailText = 'eli.hebl@ergotron.com';
    // orderNumberText ='1005470';
    selector_screen = true;
    selector_screen_Error_invalid_Data = false;
    selector_screen_Error_invalid_Date = false;
    item_selector_screen = false;
    thank_you_screen = false;
    thank_you_email = false;
    thank_you_representative = false;
    showSpinner = false;

    options = [];

    returnOptions = [
        { value : "true" , label : "Yes"},
        { value : "false" , label : "No"}
    ];


    @track returnObj = {};

    getOrders() {
        this.showSpinner = true;
        apexGetObject( {orderNumber: this.orderNumberText, email: this.emailText})
        .then(result => {
            this.returnObj = this.proxyToObj(result);
            this.selector_screen_Error_invalid_Date = false;
            this.selector_screen_Error_invalid_Data = false;
            if(!this.returnObj.eligibleReturn){
                this.selector_screen_Error_invalid_Date = true;
            } else if(this.returnObj.success){
               this.showItemSelectorScreen();
            } else {
                this.selector_screen_Error_invalid_Data = true;
            }
            console.log(this.returnObj);
            this.showSpinner = false;
        })
        .catch(error => {
            console.log(JSON.stringify(error, null, 4));
            this.showSpinner = false;
        });
    }

    save() {
        this.showSpinner = true;
        apexSave({ returnobj_string : JSON.stringify(this.returnObj, null, 4)})
        .then(result => {
            if(result.success){
                this.item_selector_screen = false;   
                this.thank_you_screen = true;
                if(result.message == 'option 1'){
                    this.thank_you_email = true;
                    this.thank_you_representative = false;
                    //this.toast(result.success, result.sales_order_id, "success");  
                } else {
                    this.thank_you_representative = true;
                    this.thank_you_email = false;
                }
            } else {
                this.toast(result.success, result.message, "warning");   
            }
            this.showSpinner = false;
        })
        .catch(error => {
            this.toast('Error Occured', 'Please Check the Log.', "warning");   
            console.log(JSON.stringify(error, null, 4));
            this.showSpinner = false;
        });
    }

    @wire(apexGetReasons)
    getReasons(value) {
        const {data, error} = value; // destructure the provisioned value
        if (data) {
            data.forEach((item) => {
                this.options.push(this.buildOption(item));
            });
        } else if (error) {
            console.log(JSON.stringify(error, null, 4));
        }
    }

    handleEmail(event) {
        this.emailText = event.target.value;
    }
    handleOrderNumber(event) {
        this.orderNumberText = event.target.value;
    }

    handleSubmit(event) {
        this.getOrders();
    }

    handlePage2Submit(event) {
        if(this.isInputValid()){
            this.save();
        }
        
    }

    showItemSelectorScreen() {
        this.selector_screen_Error_invalid_Date = false;
        this.selector_screen_Error_invalid_Data = false;
        this.selector_screen = false;
        this.item_selector_screen = true;
    }


    handleReasonChange(event){
        this.returnObj.lines.find(element => element.productId === event.target.dataset.index).reason = event.detail.value;
    }

    handleReturnQuantityChange(event){
        this.returnObj.lines.find(element => element.productId === event.target.dataset.productid).returnquantity = event.detail.value;
    }
    
    handlePackagingChange(event){
        this.returnObj.lines.find(element => element.productId === event.target.dataset.index).haspackaging = (event.detail.value === "true");
    }

    handleReturningChange(event){
        this.returnObj.lines.find(element => element.productId === event.target.dataset.index).returning = event.detail.checked;
        this.template.querySelectorAll(`.itemWrapper[data-index="${event.target.dataset.index}"]`).forEach(element => element.classList.toggle('unchecked'));

        if(this.returnObj.lines.filter((obj) => obj.returning === true).length > 0 ) {
            this.template.querySelector('.submit-button').disabled = false;
        } else {
            this.template.querySelector('.submit-button').disabled = true;
        }


    }

    handleClick(event){
        this.returnObj.lines.find(element => element.productId === event.currentTarget.dataset.index).returning = true;
        this.template.querySelectorAll(`.itemWrapper[data-index="${event.currentTarget.dataset.index}"]`).forEach(element => element.classList.remove('unchecked'));

        if(this.returnObj.lines.filter((obj) => obj.returning === true).length > 0 ) {
            this.template.querySelector('.submit-button').disabled = false;
        } else {
            this.template.querySelector('.submit-button').disabled = true;
        }

    }

    checkElementValid(element) {
        if(!element.checkValidity()) {
            element.reportValidity();
            return false;
        } else {
            return true;
        }
    }

    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            isValid = this.checkElementValid(inputField);
        });
        return isValid;
    }

    buildOption(option){
        var item = {};
        item.label = option.Description__c;
        item.value = option.Lookup_Code__c;
        return item;
    }

    proxyToObj(obj) {
        return JSON.parse(JSON.stringify(obj));
    }

      //variant = warning,
    toast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: "dismissible"
        });
        this.dispatchEvent(evt);
    }

}