import { LightningElement, track, wire } from "lwc";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import LEAD_OBJECT from "@salesforce/schema/Lead";

import verify from "@salesforce/apex/Utility_reCaptcha.verifyWithNoHeaders";
import { validateFields, validateAllFields, copyAddress } from "c/validation";

const STEPS = [
  {
    label: "Reseller Vendor Manager",
    fields: [
      { name: "FirstName", label: "First Name" },
      { name: "LastName", label: "Last Name" },
      { name: "Company", label: "Company" },
      { name: "Title", label: "Title" },
      { name: "Email", label: "Email" },
      { name: "Phone", label: "Phone" },
      {
        name: "Address",
        isCustomAddress: true,
        addressFields: {
          city: "ShippingCity__c",
          province: "ShippingState__c",
          postalCode: "ShippingPostalCode__c",
          street: "ShippingStreet__c",
          country: "ShippingCountry__c",
          provinceLabel: "ShippingState__c"
        }
      }
    ]
  }
];

export default class ResellerVendorForm extends LightningElement {
  @track lead = {};
  @track steps = STEPS;
  @track currentStep = 0;
  @track errors;
  @track brand;
  @track productOptions;
  @track recaptchaUrl;
  @track validated;

  //boolean values for displaying spinners
  @track loadingForm;
  @track loadingProducts;
  @track submitting;
  @track recaptchaMessage = "";

  connectedCallback() {
    this.loadingForm = true;
    Object.assign(this.lead, {
      LeadSource: "ResellerVendorMngrForm"//,
      //WebResellerName__c: this.lead.Firstname + ' ' + this.lead.LastName,
      //WebResellerAddress1__c: this.lead.ShippingStreet__c,
      //WebResellerCity__c: this.lead.ShippingCity__c,
      //WebResellerStateCountry__c: this.lead.ShippingState__c,
      //WebResellerCountry__c: this.lead.ShippingCountry__c,
      //WebResellerPostalCode__c: this.lead.ShippingPostalCode__c,
      //WebResellerTitle__c: Title,
      //WebResellerEmail__c: lead.Email,
      //WebResellerPhone__c: this.lead.Phone
      //Lead_Source_Sales__c: "Partner Authorization Request",
      //Lead_Source_Sub_Type__c: "Reseller"
    });
    window.addEventListener("message", this.handleRecaptchaVerification);
  }

  @wire(getObjectInfo, { objectApiName: LEAD_OBJECT })
  handleGetObjectInfo({ data, error }) {
    if (data) {
      const rtis = data.recordTypeInfos;
      this.lead.RecordTypeId = Object.keys(rtis).find(
        rti => rtis[rti].name === "Reseller Vendor Manager Update"
      );
    }

    if (error) {
      //
    }
  }

  handleRecordChange(event) {
    this.lead = Object.assign(this.lead, event.detail);
  }

  handleOnLoad() {
    this.loadingForm = false;
  }

  handleFieldChange(event) {
    let field = event.currentTarget.dataset.field;
    this.lead[field] = event.detail.value;
  }

  /**copyAddress(event) {
    copyAddress(
      event,
      this.lead,
      this.steps,
      "Partner Address (Corporate Headquarters)",
      "Primary Vendor Management"
    );
  }*/

  handleSuccess() {
    this.submitting = false;
    //window.location.href = "./reseller-confirmation";
    window.location.href = "./reseller-vendor-confirmation";
  }

  handleError(event) {
    debugger;
    console.log(event);
    console.log(event.detail);
    console.log(event.detail.detail);
    this.submitting = false;
    let errors = [];
    errors.push(event.detail.detail);
    this.errors = errors;
  }

  get hasNext() {
    return 0 <= this.currentStep && this.currentStep < this.steps.length - 1;
  }

  get hasPrev() {
    return 1 <= this.currentStep;
  }

  get fields() {
    return this.steps[this.currentStep].fields;
  }

  next(event) {
    event.preventDefault();
    event.stopPropagation();
    this.errors = validateFields(this.lead, this.fields);
    if (!this.errors.length) {
      this.template.querySelector("c-path").handleNext();
    }
  }

  handleSubmit(event) {
    event.preventDefault();
    this.errors = validateAllFields(this.lead, this.steps);

    //update the lead webseller fields
    //this.lead.WebResellerName__c = this.lead.Firstname + ' ' + this.lead.LastName;
    //this.lead.WebResellerAddress1__c = this.lead.ShippingStreet__c;
    //this.lead.WebResellerCity__c = this.lead.ShippingCity__c;
    //this.lead.WebResellerStateCountry__c = this.lead.ShippingState__c;
    //this.lead.WebResellerCountry__c = this.lead.ShippingCountry__c;
    //this.lead.WebResellerPostalCode__c = this.lead.ShippingPostalCode__c;
    //this.lead.WebResellerTitle__c = Title;
    //this.lead.WebResellerEmail__c = lead.Email;
    //this.lead.WebResellerPhone__c = this.lead.Phone;

    if (!this.errors || !this.errors.length) {
      verify({ response: this.recaptchaMessage })
        .then(result => {
          if (result) {
            this.submitting = true;
            this.template
              .querySelector("lightning-record-edit-form")
              .submit(this.lead);
          } else {
            if (!this.errors) {
              this.errors = [];
            }
            this.errors.push(
              "Invalid recaptcha response.  Please validate the recaptcha before continuing."
            );
          }
        })
        .catch(error => {
          // eslint-disable-next-line no-console
          console.log(error);
          this.errors.push(
            "Invalid recaptcha response.  Please validate the recaptcha before continuing."
          );
        });
    }
  }

  prev(event) {
    event.preventDefault();
    event.stopPropagation();
    this.errors = validateFields(this.lead, this.fields);
    if (!this.errors.length) {
      this.template.querySelector("c-path").handlePrev();
    }
  }

  get stepLabel() {
    return this.steps[this.currentStep].label;
  }

  get displaySave() {
    return this.currentStep === this.steps.length - 1;
  }

  get displayPartnerClassificationScreen() {
    return this.currentStep === 2;
  }

  get displayPrimaryVendorMgmt() {
    return this.currentStep === 3;
  }

  handleStepChange(event) {
    this.errors = [];
    this.currentStep = event.detail;
  }

  handleRecaptchaVerification = event => {
    this.recaptchaMessage = event.data;
  };
}