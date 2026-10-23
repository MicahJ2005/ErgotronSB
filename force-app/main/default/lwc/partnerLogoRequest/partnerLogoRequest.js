import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import submitPartnerLogoRequest from '@salesforce/apex/PublicCommunityRequestsController.submitPartnerLogoRequest';
import { NavigationMixin } from 'lightning/navigation';

export default class PartnerLogoRequest extends NavigationMixin(LightningElement) {
    request = {
        firstname: '',
        lastname: '',
        company: '',
        email: ''
    };

    buttonDisabled = false;
    formDisabled = false;

    firstnameBlank;
    lastnameBlank;
    companyBlank;
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

    handleCompanyIn(event) {
        this.request.company = event.target.value;
        this.companyBlank = false;
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
        if (this.request.company == '') {
            this.companyBlank = true;
            submitRequest = false;
        }
        if (submitRequest) {
            this.formDisabled = true;
            submitPartnerLogoRequest({request: JSON.stringify(this.request)})
            .then(result => {
                if (result) {
                    console.log('result: ' + result);
                    if (result == 'CREATED') {
                        //this.formDisabled = false;
                        this[NavigationMixin.Navigate]({
                            type: 'comm__namedPage',
                            attributes: {
                                pageName: 'partner-logo-request-thank-you'
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