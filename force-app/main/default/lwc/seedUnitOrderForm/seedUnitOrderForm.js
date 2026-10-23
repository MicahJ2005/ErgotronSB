import { LightningElement, track, wire } from "lwc";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import getProductOptions from "@salesforce/apex/SeedUnitOrderDraftController.getProductOptions";
import getMarkets from "@salesforce/apex/SeedUnitOrderDraftController.getMarkets";
import LEAD_OBJECT from "@salesforce/schema/Lead";
import ERGOTRON_LOGO from "@salesforce/resourceUrl/ErgotronLogo";
import HAWORTH_LOGO from "@salesforce/resourceUrl/HaworthLogo";

const STEPS = [
  {
    label: "End User Information",
    fields: [
      { name: "FirstName", requiredLabel: "First Name" },
      { name: "LastName", required: true, requiredLabel: "Last Name" },
      { name: "Phone", requiredLabel: "Phone" },
      { name: "MobilePhone" },
      { name: "Email", requiredLabel: "Email" },
      { name: "Title" },
      { name: "Company", requiredLabel: "Company" },
      { name: "Website" }
    ]
  },
  {
    label: "Billing Address",
    fields: [
      {
        name: "Address",
        isCustomAddress: true,
        requiredLabel: "Billing address",
        addressFields: {
          city: "City",
          province: "StateCode",
          postalCode: "PostalCode",
          street: "Street",
          country: "CountryCode"
        },
        addressFieldLabels: {
          province: "state / province",
          postalCode: "postal code"
        }
      }
    ]
  },
  {
    label: "Shipping Address",
    fields: [
      {
        requiredLabel: "Shipping address",
        name: "Address",
        isCustomAddress: true,
        addressFields: {
          city: "ShippingCity__c",
          province: "ShippingState__c",
          postalCode: "ShippingPostalCode__c",
          street: "ShippingStreet__c",
          country: "ShippingCountry__c"
        },
        addressFieldLabels: {
          province: "state / province",
          postalCode: "postal code"
        }
      }
    ]
  },
  {
    label: "Reseller Information",
    fields: [
      {
        name: "WebResellerName__c",
        label: "Name",
        requiredLabel: "Reseller Name"
      },
      { name: "WebResellerTitle__c", label: "Title" },
      {
        name: "WebResellerEmail__c",
        label: "Email",
        requiredLabel: "Reseller Email"
      },
      {
        name: "WebResellerPhone__c",
        label: "Phone",
        requiredLabel: "Reseller Phone"
      },
      {
        name: "Address",
        requiredLabel: "Reseller address",
        isCustomAddress: true,
        addressFields: {
          city: "WebResellerCity__c",
          province: "WebResellerStateCountry__c",
          postalCode: "WebResellerPostalCode__c",
          street: "WebResellerAddress1__c",
          country: "WebResellerCountry__c"
        },
        addressFieldLabels: {
          province: "state / province",
          postalCode: "postal code"
        }
      }
    ]
  },
  {
    label: "Product Requested to Seed",
    warning:
      "Orders are subject to a 7-10 day shipping lead time.  If you need your order expedited, please call Customer Care at 844-429-9678 and provide payment details for expedited shipping.",
    fields: [
      {
        name: "Description",
        label: "Opportunity Details",
        requiredLabel: "Opportunity Details"
      },
      { name: "Company_Size__c", requiredLabel: "Company Size" },
      { name: "Ergotron_Vertical_Market__c" },
      {
        name: "WebSeedProductRequested__c",
        requiredLabel: "Product requested to seed"
      },
      {
        name: "Display_Configuration__c",
        requiredLabel: "Display configuration"
      },
      { name: "Screen_Size__c", requiredLabel: "Screen size" },
      { name: "Display_Make_and_Model__c", requiredLabel: "Make and Model" }
    ]
  }
];

export default class ResellerForm extends LightningElement {
  @track lead = {};
  @track steps = STEPS;
  @track currentStep = 0;
  @track errors;
  @track brand;
  @track market;
  @track markets;
  @track productOptions;

  //boolean values for displaying spinners
  @track loadingForm;
  @track loadingProducts;
  @track submitting;

  connectedCallback() {
    this.loadingForm = true;
    this.brand = this.getBrand();
    this.market = "All";

    if (this.brand === "haworth") {
      this.steps[3].label = "Dealer/Reseller Information";
      this.steps[3].fields.push({});
      this.steps[3].fields.push({ name: "HaworthRepName__c" });
      this.steps[3].fields.push({ name: "HaworthRepEmail__c" });
      this.steps[3].fields.push({ name: "HaworthRepPhone__c" });
    }
  }

  get logoUrl() {
    return this.brand && this.brand.toLowerCase() === "haworth"
      ? HAWORTH_LOGO
      : ERGOTRON_LOGO;
  }

  @wire(getProductOptions, { market: "$market", brand: "$brand" })
  handleGetProducts({ data, error }) {
    this.loadingProducts = false;
    if (error) {
      let errors = [];
      errors.push(error.body.message);
      this.errors = errors;
    }
    this.productOptions = { data: data, error: error };
  }

  @wire(getMarkets)
  handleGetMarkets({ data, error }) {
    this.markets = { data: data, error: error };
  }

  @wire(getObjectInfo, { objectApiName: LEAD_OBJECT })
  handleGetObjectInfo({ data }) {
    if (data) {
      const rtis = data.recordTypeInfos;
      this.lead.RecordTypeId = Object.keys(rtis).find(
        rti => rtis[rti].name === "Seed Unit Order Submission"
      );
    }
  }

  handleRecordChange(event) {
    this.lead = Object.assign(this.lead, event.detail);
  }

  handleOnLoad() {
    this.loadingForm = false;
  }

  handleMarketChange(event) {
    this.loadingProducts = true;
    this.market = event.detail.value;
    let field = event.currentTarget.dataset.field;
    this.lead[field] = event.detail.value;
  }

  handleFieldChange(event) {
    let field = event.currentTarget.dataset.field;
    this.lead[field] = event.detail.value;
  }

  get isHaworth() {
    return this.brand && this.brand.toLowerCase() === "haworth";
  }

  /*handleBillingChange(event) {
        Object.assign(this.billing, event.detail);
    }

    handleShippingChange(event) {
        Object.assign(this.shipping, event.detail);
    }

    handleResellerChange(event) {
        Object.assign(this.resellerAddr, event.detail);
    }*/

  get displayCopyAddress() {
    return this.steps[this.currentStep].label === "Shipping Address";
  }

  get displayProductScreen() {
    return this.currentStep === this.steps.length - 1;
  }

  copyAddress(event) {
    event.preventDefault();
    event.stopPropagation();

    let shippingFields = this.steps.find(
      field => field.label === "Shipping Address"
    ).fields[0].addressFields;
    let billingFields = this.steps.find(
      field => field.label === "Billing Address"
    ).fields[0].addressFields;

    Object.entries(billingFields).forEach(([key, value]) => {
      let billingFieldValue = this.lead[value];
      let shippingField = shippingFields[key];
      this.lead[shippingField] = billingFieldValue;
    });
  }

  handleSuccess() {
    this.submitting = false;
    window.location.href = "./seed-unit-request-confirmation";
  }

  handleError(event) {
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
    this.errors = this.validateFields(this.fields);
    if (!this.errors.length) {
      this.template.querySelector("c-path").handleNext();
    }
  }

  validateFields(fields) {
    //First, check for requiredness of fields.
    let errors = [];
    fields.forEach(field => {
      if (field.requiredLabel) {
        if (field.addressFields) {
          Object.entries(field.addressFields).forEach(([key, val]) => {
            if (!this.lead[val]) {
                let label =
                field.addressFieldLabels && field.addressFieldLabels[key]
                  ? field.addressFieldLabels[key]
                  : key;
              errors.push(
                field.requiredLabel + " " + label + " is required."
              );
            }
          });
        } else if (!this.lead[field.name]) {
          errors.push(field.requiredLabel + " is required.");
        }
      }
    });
    return errors;
  }

  handleSubmit(event) {
    event.preventDefault();
    this.errors = this.validateAllFields(this.steps);
    if (!this.errors.length) {
      this.submitting = true;
      this.template
        .querySelector("lightning-record-edit-form")
        .submit(this.lead);
    }
  }

  validateAllFields(steps) {
    //First, check for requiredness of fields.
    let errors = [];
    steps.forEach(step => {
      step.fields.forEach(field => {
        if (field.requiredLabel) {
          if (field.addressFields) {
            Object.entries(field.addressFields).forEach(([key, val]) => {
              if (!this.lead[val]) {
                let label =
                  field.addressFieldLabels && field.addressFieldLabels[key]
                    ? field.addressFieldLabels[key]
                    : key;
                errors.push(
                  field.requiredLabel + " " + label + " is required."
                );
              }
            });
          } else if (!this.lead[field.name]) {
            errors.push(field.requiredLabel + " is required.");
          }
        }
      });
    });
    return errors;
  }

  prev(event) {
    event.preventDefault();
    event.stopPropagation();
    this.errors = this.validateFields(this.fields);
    if (!this.errors.length) {
      this.template.querySelector("c-path").handlePrev();
    }
  }

  get stepLabel() {
    return this.steps[this.currentStep].label;
  }

  getBrand() {
      try{
        let brand = new URL(window.location.href).searchParams.get("brand");
        return brand ? brand.toLowerCase() : "ergotron";
      }catch(ex){
          return this.getBrandIE();
      }
  }

  getBrandIE() {
    var regex = new RegExp("[\\?&]" + 'brand' + "=([^&#]*)"),
    results = regex.exec(location.search);
    let brand;
    if(results){
        brand = decodeURIComponent(results[1].replace(/\+/g, " "));
    }
    return brand ? brand.toLowerCase() : "ergotron";
  }

  /*get endUserCSS() {
        return this.currentStep === 0 ? '' : 'slds-hide';
    }

    get billingCSS() {
        return this.currentStep === 1 ? '' : 'slds-hide';
    }

    get shippingCSS() {
        return this.currentStep === 2 ? '' : 'slds-hide';
    }

    get resellerCSS() {
        return this.currentStep === 3 ? '' : 'slds-hide';
    }

    get productCSS() {
        return this.currentStep === 4 ? '' : 'slds-hide';
    }*/

  get displaySave() {
    return this.currentStep === this.steps.length - 1;
  }

  handleStepChange(event) {
    this.errors = [];
    this.currentStep = event.detail;
  }

  /*get provinceOptions() {
        return this.countryProvinceMap[this.selectedCountry];
    }

    get shippingProvinceOptions() {
        return this.getProvinceOptions(this.shipping.country);
    }

    get billingProvinceOptions() {
        return this.getProvinceOptions(this.billing.country);
    }

    get resellerProvinceOptions() {
        return this.getProvinceOptions(this.resellerAddr.country);
    }*/
}