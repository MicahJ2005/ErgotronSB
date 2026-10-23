import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import submitRecallInformationRequest from '@salesforce/apex/PublicCommunityRequestsController.submitRecallInformationRequest';
import { NavigationMixin } from 'lightning/navigation';

export default class RecallInformation extends NavigationMixin(LightningElement) {

    request = {
        firstName: '',
        lastName: '',
        company: '',
        address1: '',
        address2: '',
        city: '',
        state: '',
        postalCode: '',
        phone: '',
        email: '',
        product: '',
        purchaseDate: '',
        ugCode: '',
        dateCode: '',
        details: '',
    };

    buttonDisabled = false;
    formDisabled = false;


    //firstNameBlank;
    lastNameBlank;
    address1Blank;
    cityBlank;
    //stateBlank;
    postalCodeBlank;
    phoneBlank;
    emailBlank;
    productBlank;
    purchaseDateBlank;
    emailWrongFormat;
    ugCodeBlank;
    dateCodeBlank;

    handleFirstNameIn(event) {
        this.request.firstName = event.target.value;
        //this.firstNameBlank = false;
    }
    
    handleLastNameIn(event) {
        this.request.lastName = event.target.value;
        this.lastNameBlank = false;
    }

    handleCompanyIn(event) {
        this.request.company = event.target.value;
    }

    handleAddress1In(event) {
        this.request.address1 = event.target.value;
        this.address1Blank = false;
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
        //this.stateBlank = false;
    }

    handlePostalCodeIn(event) {
        this.request.postalCode = event.target.value;
        this.postalCodeBlank = false;
    }

    handlePhoneIn(event) {
        this.request.phone = event.target.value;
        this.phoneBlank = false;
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

    handleProductIn(event) {
        console.log('event: ' + event);
        this.request.product = event.target.value;
        this.productBlank = false;
    }

    handlePurchaseDateIn(event) {
        this.request.purchaseDate = event.target.value;
        this.purchaseDateBlank = false;
    }

    handleUGCodeIn(event) {
        this.request.ugCode = event.target.value;
        this.ugCodeBlank = false;
    }

    handleDateCodeIn(event) {
        this.request.dateCode = event.target.value;
        this.dateCodeBlank = false;
    }

    handleDetailsIn(event) {
        this.request.details = event.target.value;
    }

    @track isModalOpen_Guide = false;
    openModal_Guide() {
        this.isModalOpen_Guide = true;
    }
    closeModal_Guide() {
        this.isModalOpen_Guide = false;
    }
    @track isModalOpen_DateRanges = false;
    openModal_DateRanges() {
        this.isModalOpen_DateRanges = true;
    }
    closeModal_DateRanges() {
        this.isModalOpen_DateRanges = false;
    }

    handleSubmit(event) {
        let submitRequest = true;
        this.buttonDisabled = true;
        /**if (this.request.firstName == '') {
            this.firstNameBlank = true;
            submitRequest = false;
        }*/
        if (this.request.lastName == '') {
            this.lastNameBlank = true;
            submitRequest = false;
        }
        if (this.request.address1 == '') {
            this.address1Blank = true;
            submitRequest = false;
        }
        if (this.request.city == '') {
            this.cityBlank = true;
            submitRequest = false;
        }
        /**if (this.request.state == '') {
            this.stateBlank = true;
            submitRequest = false;
        }*/
        if (this.request.postalCode == '') {
            this.postalCodeBlank = true;
            submitRequest = false;
        }
        if (this.request.phone == '') {
            this.phoneBlank = true;
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
        if (this.request.product == '') {
            this.productBlank = true;
            submitRequest = false;
        }
        if (this.request.purchaseDate == '') {
            this.purchaseDateBlank = true;
            submitRequest = false;
        }
        if (this.request.ugCode == '') {
            this.ugCodeBlank = true;
            submitRequest = false;
        }
        if (this.request.dateCode == '') {
            this.dateCodeBlank = true;
            submitRequest = false;
        }
        if (submitRequest) {
            this.formDisabled = true;
            submitRecallInformationRequest({request: JSON.stringify(this.request)})
            .then(result => {
                if (result) {
                    console.log('result: ' + result);
                    if (result == 'CREATED') {
                        //this.formDisabled = false;
                        this[NavigationMixin.Navigate]({
                            type: 'comm__namedPage',
                            attributes: {
                                pageName: 'recall-information-request-thank-you'
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