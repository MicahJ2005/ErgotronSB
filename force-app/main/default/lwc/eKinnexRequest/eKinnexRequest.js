import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import submitEKinnexRequest from '@salesforce/apex/PublicCommunityRequestsController.submitEKinnexRequest';
import { NavigationMixin } from 'lightning/navigation';

export default class EKinnexRequest extends NavigationMixin(LightningElement) {
    request = {
        firstName: '',
        lastName: '',
        company: '',
        title: '',
        role: '',
        email: '',
        phone: '',
        address1: '',
        address2: '',
        city: '',
        state: '',
        country: '',
        postalCode: '',
        requestType: '',
        platformStr: '',
        drawerValuesStr: '',
        comment:''
    }

    platforms = []

    drawerValues = []

    requestTypes = [
        {label: 'New deployment: I need a cloud organization and user accounts set up.', value: 'New Deployment'},
        {label: 'Already set up: I have a question, need help troubleshooting an issue or want to make a configuration change.', value: 'Already set up'},
        {label: 'Other', value: 'Other'}
    ];

    platformOptions = [
            {label: 'LifeKinnex Add-On Power', value: 'LifeKinexx Add-On Power'},
            {label: 'CareFit Pro Carts', value: 'CareFit Pro Carts'},
            {label: 'StyleView Carts', value: 'StyleView Carts'}
        ];

    drawerOptions = [
        {label: 'With drawers', value: 'With drawers'},
        {label: 'No drawers', value: 'No drawers'}
    ];

    buttonDisabled = false;
    formDisabled = false;

    firstNameBlank;
    lastNameBlank;
    companyBlank;
    roleBlank;
    emailBlank;
    phoneBlank;
    addressBlank;
    cityBlank;
    countryBlank;
    postalCodeBlank;
    emailWrongFormat;
    requestTypeBlank;
    platformsBlank;
    drawersBlank;
    commentBlank;

    handleFirstNameIn(event) {
        this.request.firstName = event.target.value;
        this.firstNameBlank = false;
    }
    
    handleLastNameIn(event) {
        this.request.lastName = event.target.value;
        this.lastNameBlank = false;
    }

    handleCompanyIn(event) {
        this.request.company = event.target.value;
        this.companyBlank = false;
    }

    handleTitleIn(event) {
        this.request.title = event.target.value;
    }

    handleRoleIn(event) {
        this.request.role = event.target.value;
        this.roleBlank = false;
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

    handleAddress1In(event) {
        this.request.address1 = event.target.value;
        this.addressBlank = false;
    }

    handleAddress2In(event) {
        this.request.address2 = event.target.value;
    }

    handleCityIn(event) {
        this.request.city = event.target.value;
        this.cityBlank = false;
    }

    handleStateIn(event) {
        this.request.state = event.target.value;
    }

    handleCountryIn(event) {
        this.request.country = event.target.value;
        this.countryBlank = false;
    }

    handlePostalCodeIn(event) {
        this.request.postalCode = event.target.value;
        this.postalCodeBlank = false;
    }

    handleReqType(event) {
        this.request.requestType = event.detail.value;
        this.requestTypeBlank = false;
    }

    handlePlatform(event) {
        this.platforms = event.detail.value;
        this.request.platformStr = event.detail.value.toString().replaceAll(',', ', ');
        if (this.platforms.length > 0) {
            this.platformsBlank = false;
        } else {
            this.platformsBlank = true;
        }
        console.log('platforms:  ',this.request.platformStr);
        console.log('handlePlatform - platformsBlank', this.platformsBlank);
        
    }

    handleDrawer(event) {
        this.drawerValues = event.detail.value;
        this.request.drawerValuesStr = event.detail.value.toString().replaceAll(',', ', ');
        if (this.drawerValues.length > 0) {
            this.drawersBlank = false;
        } else {
            this.drawersBlank = true;
        }
        console.log('drawerValuesStr:', this.request.drawerValuesStr);
        console.log('drawersBlank', this.drawersBlank);
    }

    handleCommentIn(event) {
        this.request.comment = event.detail.value;
        this.commentBlank = false;        
    }

    handleSubmit(event) {
        let submitRequest = true;
        this.buttonDisabled = true;
        if (this.request.firstName == '') {
            this.firstNameBlank = true;
            submitRequest = false;
        }
        if (this.request.lastName == '') {
            this.lastNameBlank = true;
            submitRequest = false;
        }
        if (this.request.company == '') {
            this.companyBlank = true;
            submitRequest = false;
        }
        if (this.request.role == '') {
            this.roleBlank = true;
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
        if (this.request.address1 == '') {
            this.addressBlank = true;
            submitRequest = false;
        }
        if (this.request.city == '') {
            this.cityBlank = true;
            submitRequest = false;
        }
        if (this.request.country == '') {
            this.countryBlank = true;
            submitRequest = false;
        }
        if (this.request.postalCode == '') {
            this.postalCodeBlank = true;
            submitRequest = false;
        }
        if (this.request.requestType == '') {
            this.requestTypeBlank = true;
            submitRequest = false;
        }
        if (this.request.platformStr == '' ) {
            this.platformsBlank = true;
            submitRequest = false;
            console.log('handleSubmit - platformStr == ""', this.platformStr == '', this.platformStr);
            console.log('handleSubmit - platformsBlank', this.platformsBlank);
        }
        if (this.request.drawerValuesStr == '') {
            this.drawersBlank = true;
            submitRequest = false;
        }
        if (this.request.comment == '') {
            this.commentBlank = true;
            submitRequest = false;
        }

        if (submitRequest) {
            this.formDisabled = true;
            submitEKinnexRequest({request: JSON.stringify(this.request)})
            .then(result => {
                if (result) {
                    console.log('result: ' + result);
                    if (result == 'CREATED') {
                        this[NavigationMixin.Navigate]({
                            type: 'comm__namedPage',
                            attributes: {
                                pageName: 'ekinnex-support-request-thank-you'
                            }
                        });
                        console.log('post navigate');
                    } else {
                        console.log('error: ' + result);
                        const toastEvent = new ShowToastEvent({
                            mode: "sticky",
                            title: "Error:",
                            message: "Your submission couldn't be processed.",
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