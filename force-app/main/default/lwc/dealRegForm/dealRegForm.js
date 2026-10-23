import { LightningElement, track, wire, api } from "lwc";
import getPartners from "@salesforce/apex/Deal_Reg_Cntrl_Copy.getPartners";
import getUserCountry from "@salesforce/apex/Deal_Reg_Cntrl_Copy.getUserCountry";
import getProductsById from "@salesforce/apex/Deal_Reg_Cntrl_Copy.getProductsById";
import getProducts from "@salesforce/apex/Deal_Reg_Cntrl_Copy.getProducts";
import getLead from "@salesforce/apex/Deal_Reg_Cntrl_Copy.getLead";
import updateLead from "@salesforce/apex/Deal_Reg_Cntrl_Copy.updateLead";
import submitLead from "@salesforce/apex/Deal_Reg_Cntrl_Copy.saveAndSubmit";
import getDealRegProducts from "@salesforce/apex/Deal_Reg_Cntrl_Copy.getDealRegProducts";
import { NavigationMixin } from "lightning/navigation";
import { validateFields, validateAllFields } from "c/validation";

const STEPS = [
  {
    label: "End User Information",
    fields: [
      { name: "FirstName", requiredLabel: "First Name" },
      { name: "LastName", requiredLabel: "Last Name" },
      { name: "Phone", requiredLabel: "Phone" },
      { name: "Fax" },
      { name: "Email", requiredLabel: "Email" },
      { name: "Title" },
      { name: "Company", requiredLabel: "Company" },
      { name: "Website" }
    ]
  },
  {
    label: "Address",
    fields: [
      {
        name: "Address",
        requiredLabel: "Address",
        isCustomAddress: true,
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
    label: "Other Information",
    fields: [
      { name: "Department_Division__c", requiredLabel: "Department/Division" },
      {
        name: "Ergotron_Vertical_Market__c",
        requiredLabel: "Ergotron Vertical Market"
      }, /** required ness of these fields is handled via the "required" flag on the inputs and manual checks below */
      /** No longer needed { name: "Program_Type__c" }, 
      { name: "Currency__c" },*/ 
      { name: "Opp_Partner_ID__c" /*requiredLabel: "Distribution Partner"*/ }
    ]
  },
  {
    label: "Products",
    fields: []
  }
];

export default class DealRegForm extends NavigationMixin(LightningElement) {
  @track lead = {};
  @track steps = STEPS;
  @track currentStep = 0;
  @track errors;
  @track partnerOptions = [];
  @track loadingForm;
  @track submitting;

  @track products;
  @track productIds;
  @track queriedProducts;
  @api recordId;

  @track mapToggle;
  @track uppToggle;

  @track leadSubmitted;
  @track leadSaved;

  @track newProduct = { Id: "", Name: "" };

  connectedCallback() {
    this.loadingForm = true;
    this.products = [];
    //Object.assign(this.lead,{LeadSource : 'ResellerAuthForm',Lead_Source_Sales__c : 'Partner Authorization Request',Lead_Source_Sub_Type__c : 'Reseller'});
  }

  handleChange(event) {
    const field = event.target.name;
    if (field === 'mapToggle') {
        this.mapToggle = event.target.checked;
    } else if (field === 'uppToggle') {
        this.uppToggle = event.target.checked;
    }
  }

  @wire(getProducts, { searchKey: "$recordId" })
  handleGetProducts({ data, error }) {
    if (data) {
      let productIds = [];
      let queriedProducts = [];
      data.forEach(product => {
        queriedProducts.push({ ...product.Product__r });
        productIds.push(product.Product__c);
      });
      this.productIds = productIds;
      this.queriedProducts = queriedProducts;
      this.products = [...data];
    }

    if (error) {
      this.error = error;
    }
  }

  @wire(getUserCountry)
  wiredUserCountry({error, data}){
    if (data) {
            this.userCountryCode = data;
        } else if (error) {
            console.error(error);
        }
  }

  @wire(getLead, { leadId: "$recordId" })
  handleGetLead({ data }) {
    if (data) {
      this.lead = { ...data };
    }
  }

  @wire(getDealRegProducts)
  dealRegProducts;

  @wire(getPartners)
  handleGetPartners({ data, error }) {
    if (data) {
      let partnerOptions = [];
      Object.keys(data).forEach(key => {
        partnerOptions.push({ label: data[key], value: key });
      });
      this.partnerOptions = partnerOptions;
    }

    if (error) {
      this.errors.push(error.body.message);
    }
  }

  @wire(getProductsById, { productIds: "$productIds" })
  // eslint-disable-next-line no-unused-vars
  handleGetProductsById({ data, error }) {
    if (data) {
      let queriedProducts = [...data];
      queriedProducts.forEach(productWithName => {
        [...this.products].forEach(leadProduct => {
          if (
            !leadProduct.Product__r &&
            leadProduct.Product__c === productWithName.Id
          ) {
            leadProduct.Product__r = { ...productWithName };
          }
        });
      });
      this.queriedProducts = queriedProducts;
    }
  }

  get displayOtherInformation() {
    return this.currentStep === 2;
  }

  get displayProducts() {
    return this.currentStep === 3;
  }

  handleRecordChange(event) {
    this.lead = Object.assign(this.lead, event.detail);
    this.leadSaved = false;
  }

  handleOnLoad() {
    this.loadingForm = false;
  }

  handleFieldChange(event) {
    let field = event.currentTarget.dataset.field;
    this.lead[field] = event.detail.value;
  }

  handleDistributionPartnerChange(event) {
    this.lead.Opp_Partner_ID__c = event.detail.value;
  }

  handleSuccess() {
    console.log("handleSuccess");
    this.submitting = false;
    //window.location.href='./reseller-confirmation';
  }

  handleError(event) {
    console.log("handleError");
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

  handleAddProduct(event) {
    event.preventDefault();
    event.stopPropagation();
    this.leadSaved = false;

    let fields = event.detail.fields;

    if (this.newProduct) {
      fields.Product__c = this.newProduct.Id;
    }

    this.products.push(fields);

    if (fields) {
      if (!this.productIds || !this.productIds.length) {
        let arr = [];
        arr.push(fields.Product__c);
        this.productIds = arr;
      } else if (this.productIds.indexOf(fields.Product__c) < 0) {
        let prodIds = [...this.productIds];
        prodIds.push(fields.Product__c);
        this.productIds = prodIds;
      } else {
        let lp = this.queriedProducts.filter(
          current => current.Id === fields.Product__c
        );
        if (lp) {
          this.products[this.products.length - 1].Product__r = { ...lp[0] };
        }
      }
    }
  }

  handleRemoveProduct(event) {
    let index = event.currentTarget.dataset.idx;

    if (!index) {
      return;
    }

    this.products.splice(parseInt(index, 10), 1);
  }

  next(event) {
    event.preventDefault();
    event.stopPropagation();
    this.errors = this.validateFields(this.fields);
    this.leadSaved = false;
    if (!this.errors.length) {
      if (this.lead.Status === "Registration Submitted") {
        this.template.querySelector("c-path").handleNext();
        return;
      }

      //Update the lead as we go from page to page.
      updateLead({ oLead: this.lead, products: this.products })
        .then(result => {
          this.leadSaved = true;
          this.template.querySelector("c-path").handleNext();
          if (!this.lead.Id) {
            this.lead.Id = result;
            this.recordId = result;
          }
        })
        .catch(error => {
          let errors = [];
          errors.push(error.body.message);
          this.errors = errors;
        });
    }
  }

  handleSave(event) {
    console.log("handleSave");
    this.leadSaved = false;
    this.leadSubmitted = false;
    event.preventDefault();
    event.stopPropagation();
    //Update the lead as we go from page to page.

    //this.errors = this.validateAllFields(this.fields);

    if(this.mapToggle != true) {
      console.log('DC: 204');
      this.errors.push(
        "Please indicate that you have read and acknowledge to Lead and be exclusive with Ergotron and not promote any competing brand."
      );
    }
    if(this.uppToggle != true) {
      console.log('DC: 204');
      this.errors.push(
        "Please indicate that you have read and acknowledgeto to Notify Ergotron if the purchaser requires more than one quote."
      );
    }
    this.errors = validateAllFields(this.lead, this.steps);
    if (!this.errors.length) {
      updateLead({ oLead: this.lead, products: this.products })
        .then(result => {
          this.leadSaved = true;
          if (!this.lead.Id) {
            this.lead.Id = result;
            this.recordId = result;
          }
        })
        .catch(error => {
          let errors = [];
          errors.push(error.body.message);
          this.errors = errors;
        });
    }
  }

  handleSubmit(event) {
    console.log("handleSubmit231");
    this.leadSaved = false;
    this.leadSubmitted = false;
    event.preventDefault();
    event.stopPropagation();
    //Update the lead as we go from page to page.
    console.log(this.mapToggle);
    console.log(this.uppToggle);

    this.errors = validateAllFields(this.lead, this.steps);
    if(this.mapToggle != true) {
      console.log('DC: 204');
      this.errors.push(
        "Please indicate that you have read and acknowledge to Lead and be exclusive with Ergotron and not promote any competing brand."
      );
    }
    if(this.uppToggle != true) {
      console.log('DC: 205');
      this.errors.push(
        "Please indicate that you have read and acknowledgeto to Notify Ergotron if the purchaser requires more than one quote."
      );
    }
    if (!this.errors.length) {
      console.log('12' + this.leadSubmitted);
      submitLead({ oLead: this.lead, products: this.products })
        .then(result => {
          this.leadSubmitted = true;
          if (!this.lead.Id) {
            this.lead.Id = result;
            this.recordId = result;
          }

          this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
              pageName: "home"
            }
          });
        })
        .catch(error => {
          let errors = [];
          errors.push(error.body.message);
          this.errors = errors;
        });
        console.log('3' + this.leadSaved);
        console.log('4' + this.leadSubmitted);
    }
  


    console.log('1' + this.leadSaved);
    console.log('2' + this.leadSubmitted);
  }

  validateFields(fields) {
    let errors = validateFields(this.lead, fields);
    /** No longer needed
     this.validateDependentField(
      errors,
      (this.showType && this.currentStep == 3),
      this.lead.Program_Type__c,
      "Program Type"
    );
    */
    /** not needed - does not work
    this.validateDependentField(
      errors,
      (this.isEMEA && this.currentStep == 3),
      this.lead.CurrencyISOCode,
      "Currency ISO code"
    );
     */
    this.validateDependentField(
      errors,
      (this.isNA && this.currentStep == 3),
      this.lead.Opp_Partner_ID__c,
      "Distribution Partner"
    );
    return errors;
  }

  validateDependentField(errors, var1, var2, error) {
    if (var1 && !var2) {
      errors.push(error + " is required.");
    }
  }

  prev(event) {
    event.preventDefault();
    event.stopPropagation();
    this.leadSaved = false;
    this.leadSubmitted = false;
    this.errors = this.validateFields(this.fields);
    if (!this.errors.length) {
      if (this.lead.Status === "Registration Submitted") {
        this.template.querySelector("c-path").handlePrev();
        return;
      }

      //Update the lead as we go from page to page.
      updateLead({ oLead: this.lead, products: this.products })
        .then(result => {
          this.leadSaved = true;
          if (!this.lead.Id) {
            this.lead.Id = result;
            this.recordId = result;
          }
          this.template.querySelector("c-path").handlePrev();
        })
        .catch(error => {
          let errors = [];
          errors.push(error.body.message);
          this.errors = errors;
        });
    }
  }

  get displayRecordInputForm() {
    return !this.displayOtherInformation && !this.displayProducts;
  }

  get stepLabel() {
    return this.steps[this.currentStep].label;
  }

  get displaySave() {
    return this.currentStep === this.steps.length - 1;
  }

  get isNA() {
    let country = this.lead.CountryCode;
    return (country && country === "US") || country === "CA";
  }

  get isUS() {
    console.log("::: User country code :::: " + this.userCountryCode);
    return "US" === this.userCountryCode;
  }

  get isEMEA() {
    let country = this.lead.CountryCode;
    return country && country !== "US" && country !== "CA" && country !== "AU";
  }

  get isAU() {
    return "AU" === this.lead.CountryCode;
  }

  get leadSubmitted() {
    return this.lead.Status === "Registration Submitted";
  }

  get showType() {
    return (
      this.countryCode !== "US" &&
      this.countryCode !== "CA" &&
      this.countryCode !== "AU" &&
      this.countryCode !== "BH" &&
      this.countryCode !== "CY" &&
      this.countryCode !== "EG" &&
      this.countryCode !== "IQ" &&
      this.countryCode !== "JO" &&
      this.countryCode !== "KW" &&
      this.countryCode !== "LB" &&
      this.countryCode !== "OM" &&
      this.countryCode !== "QA" &&
      this.countryCode !== "SA" &&
      this.countryCode !== "ZA" &&
      this.countryCode !== "SY" &&
      this.countryCode !== "TR" &&
      this.countryCode !== "AE" &&
      this.countryCode !== "YE"
    );
  }

  handleProductSelection(event) {
    this.newProduct = event.detail;
    console.log("selected product: " + this.newProduct.Id);
  }

  handleStepChange(event) {
    this.errors = [];
    this.currentStep = event.detail;
  }

  get productLayoutSize() {
    return this.leadSubmitted ? 12 : 8;
  }

  get productLayoutCSS() {
    return (
      "slds-col slds-size-12-of-12 slds-small-size_4-of-12 slds-medium-size_" +
      this.productLayoutSize +
      "-of-12 slds-large-size_" +
      this.productLayoutSize +
      "-of-12 slds-p-around_small"
    );
  }

  resetSavedNotification(event) {
    this.leadSaved = false;
    let field = event.currentTarget.dataset.field;
    this.lead[field] = event.currentTarget.value;
  }
}