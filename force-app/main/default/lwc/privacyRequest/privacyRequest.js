import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import submitPrivacyRequest from '@salesforce/apex/PublicCommunityRequestsController.submitPrivacyRequest';
import { NavigationMixin } from 'lightning/navigation';

export default class PrivacyRequest extends NavigationMixin(LightningElement) {
    request = {
        contactEmail: '',
        firstName: '',
        lastName: '',
        middleInitial: '',
        phone: '',
        //address: '',
        street: '',
        city: '',
        state: '',
        postal: '',
        subject: '',
        relationship: [],
        type: '',
        subType: [],
        contactMethod: [],
        members: '',
        residentInfo: '',
        infoToCorrect: '',
        //residentEmail: '',
        //residentFirstName: '',
        //residentLastName: '',
    };

    buttonDisabled = false;
    formDisabled = false;

    ownBehalfTrue;
    householdTrue;
    authorizedTrue;
    reqToKnowTrue;
    reqToDeleteTrue;
    reqToCorrectTrue;

    personalInfoTrue;
    sourcesTrue;
    disclosedTrue;
    soldTrue;
    purposeTrue;
    specificsTrue;

    customerBehalfTrue;
    customerTrue;
    employeeTrue;
    vendorTrue;
    otherTrue;

    businessCustomerTrue;
    individualCustomerTrue;
    formerEmployeeTrue;
    vendorTrue;
    otherTrue;

    phoneTrue;
    postalMailTrue;
    emailTrue;

    contactEmailBlank;
    firstNameBlank;
    lastNameBlank;
    phoneBlank;
    //addressBlank;
    streetBlank;
    cityBlank;
    stateBlank;
    postalBlank;
    subjectBlank;
    contactMethodBlank;
    relationshipBlank;
    typeBlank;
    emailWrongFormat;


    handleEmailIn(event) {
        this.request.contactEmail = event.target.value;
        this.contactEmailBlank = false;

        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;  
        if(this.request.contactEmail.match(regExpEmailformat)){
            this.emailWrongFormat = false;
        } else {
            this.emailWrongFormat = true;
        }
    }

    handleFirstNameIn(event) {
        this.request.firstName = event.target.value;
        this.firstNameBlank = false;
    }

    handleLastNameIn(event) {
        this.request.lastName = event.target.value;
        this.lastNameBlank = false;
    }

    handleMiddleInitialIn(event) {
        this.request.middleInitial = event.target.value;
    }

    handlePhoneIn(event) {
        this.request.phone = event.target.value;
        this.phoneBlank = false;
    }
    /**
    handleAddressIn(event) {
        this.request.address = event.target.value;
        this.addressBlank = false;
    }
    */
    handleStreetIn(event) {
        this.request.street = event.target.value;
        this.streetBlank = false;
    }

    handleCityIn(event) {
        this.request.city = event.target.value;
        this.cityBlank = false;
    }

    handleStateIn(event) {
        this.request.state = event.target.value;
        this.stateBlank = false;
    }

    handlePostalIn(event) {
        this.request.postal = event.target.value;
        this.postalBlank = false;
    }

    handleSubjectIn(event) {
        this.request.subject = event.target.value;
        //console.log('this.request.subject: ' + this.request.subject);
        if (this.request.subject == 'I am a California resident and am submitting this request on my own behalf.') {
            this.ownBehalfTrue = true;
            this.householdTrue = false;
            this.authorizedTrue = false;
        //} else if (this.request.subject == 'I am a California resident and am submitting this request on behalf of my household, which is located in California.') {
        //    this.householdTrue = true;
        //    this.ownBehalfTrue = false;
        //    this.authorizedTrue = false;
        } else if (this.request.subject == 'I am authorized to submit this request on behalf of another individual who is a California resident.') {
            this.authorizedTrue = true;
            this.ownBehalfTrue = false;
            this.householdTrue = false;
        }
    }
    handleRelationshipIn(event) {
        //console.log(event.target.value);
        if (this.request.relationship.includes(event.target.value)) {
            this.request.relationship.splice(this.request.relationship.indexOf(event.target.value), 1);
            if (event.target.value == 'Customer or prospective customer on behalf of a business') {
                this.businessCustomerTrue = false;
            } else if (event.target.value == 'Customer or prospective customer in an individual capacity') {
                this.individualCustomerTrue = false;
            } else if (event.target.value == 'Current or former employee, job applicant, or contractor') {
                this.formerEmployeeTrue = false;
            } else if (event.target.value == 'Vendor') {
                this.vendorTrue = false;
            } else if (event.target.value == 'Other') {
                this.otherTrue = false;
            }
        } else {
            this.request.relationship.push(event.target.value);
            if (event.target.value == 'Customer or prospective customer on behalf of a business') {
                this.businessCustomerTrue = true;
            } else if (event.target.value == 'Customer or prospective customer in an individual capacity') {
                this.individualCustomerTrue = true;
            } else if (event.target.value == 'Current or former employee, job applicant, or contractor') {
                this.formerEmployeeTrue = true;
            } else if (event.target.value == 'Vendor') {
                this.vendorTrue = true;
            } else if (event.target.value == 'Other') {
                this.otherTrue = true;
            }
        }
    }

    handleTypeIn(event) {
        this.request.type = event.target.value;
        this.reqToKnowTrue = false;
        if(this.request.type == 'Request to know') {
            this.reqToKnowTrue = true;
        }
        this.reqToDeleteTrue = false;
        if(this.request.type == 'Request to delete') {
            this.reqToDeleteTrue = true;
        }
        this.reqToCorrectTrue = false;
        if(this.request.type == 'Request to correct') {
            this.reqToCorrectTrue = true;
        }

        if(this.reqToKnowTrue == false && this.reqToDeleteTrue == false && this.reqToCorrectTrue == false) {
            this.typeBlank = true;
        }

    }

    handleSubtypeIn(event) {
        /**
        <input id="personalInfo" value="Categories of personal information that we collected and maintain.
        <input id="sources" value="Categories of sources from which we collected personal information.
        <input id="disclosed" value="Categories of personal information that we sold, shared, or disclosed for a business purpose, to a third party.
        <input id="sold" value="Categories of third parties to whom we sold, shared, or disclosed for a business purpose, personal information.
        <input id="purpose" value="Our business or commercial purpose for collecting, selling, or sharing the personal information.
        <input id="specifics" value="Access to specific pieces of personal information that we collected and maintain.
        */

        //console.log(event.target.value);
        if (this.request.subType.includes(event.target.value)) {
            this.request.subType.splice(this.request.subType.indexOf(event.target.value), 1);
            if (event.target.value == 'Categories of personal information that we collected and maintain.') {
                this.personalInfoTrue = false;
            } else if (event.target.value == 'Categories of sources from which we collected personal information.') {
                this.sourcesTrue = false;
            } else if (event.target.value == 'Categories of personal information that we sold, shared, or disclosed for a business purpose, to a third party.') {
                this.disclosedTrue = false;
            } else if (event.target.value == 'Categories of third parties to whom we sold, shared, or disclosed for a business purpose, personal information.') {
                this.soldTrue = false;
            } else if (event.target.value == 'Our business or commercial purpose for collecting, selling, or sharing the personal information.') {
                this.purposeTrue = false;
            } else if (event.target.value == 'Access to specific pieces of personal information that we collected and maintain.') {
                this.specificsTrue = false;
            }
        } else {
            this.request.subType.push(event.target.value);
            if (event.target.value == 'Categories of personal information that we collected and maintain.') {
                this.personalInfoTrue = true;
            } else if (event.target.value == 'Categories of sources from which we collected personal information.') {
                this.sourcesTrue = true;
            } else if (event.target.value == 'Categories of personal information that we sold, shared, or disclosed for a business purpose, to a third party.') {
                this.disclosedTrue = true;
            } else if (event.target.value == 'Categories of third parties to whom we sold, shared, or disclosed for a business purpose, personal information.') {
                this.soldTrue = true;
            } else if (event.target.value == 'Our business or commercial purpose for collecting, selling, or sharing the personal information.') {
                this.purposeTrue = true;
            } else if (event.target.value == 'Access to specific pieces of personal information that we collected and maintain.') {
                this.specificsTrue = true;
            }
        }
    }

    handleContactMethodIn(event) {
        if (this.request.contactMethod.includes(event.target.value)) {
            //console.log(this.request.contactMethod.indexOf(event.target.value));
            this.request.contactMethod.splice(this.request.contactMethod.indexOf(event.target.value), 1);
            if (event.target.value == 'Postal Mail') {
                this.postalMailTrue = false;
            } else if (event.target.value == 'Email') {
                this.emailTrue = false;
            }
        } else {
            this.request.contactMethod.push(event.target.value);
            if (event.target.value == 'Postal Mail') {
                this.postalMailTrue = true;
            } else if (event.target.value == 'Email') {
                this.emailTrue = true;
            }
        }
        //console.log(this.request.contactMethod);
    }

    handleMembersIn(event) {
        this.request.members = event.target.value;
    }

    handleInfoToCorrectIn(event) {
        this.request.infoToCorrect = event.target.value;
    }

    handleResidentInfoIn(event) {
        this.request.residentInfo = event.target.value;
    }

    //handleResidentEmailIn(event) {
    //    this.residentEmail = event.target.value;
    //}

    //handleResidentFirstNameIn(event) {
    //    this.residentFirstName = event.target.value;
    //}

    //handleResidentLastNameIn(event) {
    //    this.residentLastName = event.target.value;
    //}

    // handleNavigate(event) {
    //     console.log('inside handleNavigate');
    //     this[NavigationMixin.Navigate]({
    //         type: 'comm__namedPage',
    //         attributes: {
    //             pageName: 'privacy-request-thank-you'
    //         }
    //     });
    // }

    handleSubmit(event) {
        //NOTE - no auto generated email to the form filler-outer with this form
        let submitRequest = true;
        this.buttonDisabled = true;
        if (this.request.contactEmail == '') {
            this.contactEmailBlank = true;
            submitRequest = false;
        } else {
            var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;  
            if(this.request.contactEmail.match(regExpEmailformat)){
                this.emailWrongFormat = false;
            } else {
                this.emailWrongFormat = true;
                submitRequest = false;
            }
        }
        if (this.request.firstName == '') {
            this.firstNameBlank = true;
            submitRequest = false;
        }
        if (this.request.lastName == '') {
            this.lastNameBlank = true;
            submitRequest = false;
        }
        /**
        if (this.request.phone == '') {
            this.phoneBlank = true;
            submitRequest = false;
        }
        if (this.request.address == '') {
            this.addressBlank = true;
            submitRequest = false;
        }
        */
        if (this.request.street == '') {
            this.streetBlank = true;
            submitRequest = false;
        }
        if (this.request.city == '') {
            this.cityBlank = true;
            submitRequest = false;
        }
        if (this.request.state == '') {
            this.stateBlank = true;
            submitRequest = false;
        }
        if (this.request.postal == '') {
            this.postalBlank = true;
            submitRequest = false;
        }
        if (this.request.subject == '') {
            this.subjectBlank = true;
            submitRequest = false;
        }
        //if (this.request.contactMethod.length == 0) {
        //    this.contactMethodBlank = true;
        //    submitRequest = false;
        //}
        if(this.request.relationship.length == 0) {
            this.relationshipBlank = true;
           submitRequest = false;
        }
        if(this.request.type == '') {
            this.typeBlank = true;
            submitRequest = false;
        }
        if(this.reqToKnowTrue == true && this.request.subType.length == 0) {
                this.subTypeBlank = true;
                this.contactMethodBlank = true;
                submitRequest = false;
        }
        if (submitRequest) {
            this.formDisabled = true;
            submitPrivacyRequest({request: JSON.stringify(this.request)})
            .then(result => {
                if (result) {
                    console.log('result: ' + result);
                    if (result == 'CREATED') {
                        //this.formDisabled = false;
                        this[NavigationMixin.Navigate]({
                            type: 'comm__namedPage',
                            attributes: {
                                pageName: 'privacy-request-thank-you'
                            }
                        });
                    } else {
                        //new lines aren't working?!
                        //var sMsg = 'Your submission couldn\'t be processed. Please email Ergotron Customer Care at customerservice@ergotron.com \n';
                        var sMsg = 'Your submission couldn\'t be processed. ';
                        sMsg += this.cleanError(result);

                        const toastEvent = new ShowToastEvent({
                            mode: "sticky",
                            title: "Error:",
                            message: sMsg,
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

    cleanError(strErrorMsg) {
        strErrorMsg = strErrorMsg.replace("Error: Insert failed. First exception on row 0;", "");
        strErrorMsg = strErrorMsg.replace("INVALID_EMAIL_ADDRESS, ", " ");
        strErrorMsg = strErrorMsg.replace(": [SuppliedEmail]", " ");
        strErrorMsg = strErrorMsg.replace("first error: ", " ");
        strErrorMsg = strErrorMsg.replace("  ", " ");
        return strErrorMsg;
    }
}