import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import submitServiceRequest from '@salesforce/apex/PublicCommunityRequestsController.submitServiceRequest';
import { NavigationMixin } from 'lightning/navigation';

export default class ServiceRequest extends NavigationMixin(LightningElement) {
    request = {
        firstname: '',
        lastname: '',
        postalCode: '',
        phone: '',
        email: '',
        partnum: '',
        quantity: '',
        comment: ''
    };

    buttonDisabled = false;
    formDisabled = false;

    firstnameBlank;
    lastnameBlank;
    postalCodeBlank;
    phoneBlank;
    emailBlank;
    emailWrongFormat;

    handleFirstNameIn(event) {
        this.request.firstname = event.target.value;
        this.firstnameBlank = false;
    }
    
    handleLastNameIn(event) {
        this.request.lastname = event.target.value;
        this.lastnameBlank = false;
    }
    
    handlePostalCodeIn(event) {
        this.request.postalCode = event.target.value;
        this.postalCodeBlank = false;
    }
    
    handleEmailIn(event) {
        this.request.email = event.target.value;
        this.emailBlank = false;

        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;  
        if(this.request.email.match(regExpEmailformat)){
            this.emailWrongFormat = false;
        } else {
            this.emailWrongFormat = true;
        }
    }

    handlePhoneIn(event) {
        this.request.phone = event.target.value;
        this.phoneBlank = false;
    }

    handlePartNumIn(event) {
        this.request.partnum = event.target.value;
    }

    handleQuantityIn(event) {
        this.request.quantity = event.target.value;
    }

    handleCommentIn(event) {
        this.request.comment = event.target.value;
    }

    handleSubmit(event) {
        let submitRequest = true;
        this.buttonDisabled = true;
        if (this.request.firstname == '') {
            this.firstnameBlank = true;
            submitRequest = false;
        }
        if (this.request.lastname == '') {
            this.lastnameBlank = true;
            submitRequest = false;
        }
        if (this.request.postalCode == '') {
            this.postalCodeBlank = true;
            submitRequest = false;
        }
        if (this.request.email == '') {
            this.emailBlank = true;
            submitRequest = false;
        } else {
            var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;  
            if(this.request.email.match(regExpEmailformat)){
                this.emailWrongFormat = false;
            } else {
                this.emailWrongFormat = true;
                submitRequest = false;
            }
        }
        if (this.request.phone == '') {
            this.phoneBlank = true;
            submitRequest = false;
        }
        console.log("82");
        if (submitRequest) {
            this.formDisabled = true;
            submitServiceRequest({request: JSON.stringify(this.request)})
            .then(result => {
                if (result) {
                    if (result == 'CREATED') {
                        //this.formDisabled = false;
                        this[NavigationMixin.Navigate]({
                            type: 'comm__namedPage',
                            attributes: {
                                pageName: 'service-request-thank-you'
                            }
                        });
                    } else {
                        console.log('error: ' + result);
                        const toastEvent = new ShowToastEvent({
                            mode: "sticky",
                            title: "Error:",
                            message: "Your submission couldn't be processed. If you have any questions, please contact Ergotron Customer Care at 800-888-8458 or email customerservice@ergotron.com",
                            variant: "error"
                        });
                        this.dispatchEvent(toastEvent);
                        this.buttonDisabled = false;
                        this.formDisabled = false;
                    }
                }
            });
        } else {
            this.buttonDisabled = false;
            this.formDisabled = false;
        }
    }
}