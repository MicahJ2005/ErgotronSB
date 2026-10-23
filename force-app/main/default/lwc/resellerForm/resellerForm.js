import { LightningElement, track, wire } from "lwc";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import LEAD_OBJECT from "@salesforce/schema/Lead";

import verify from "@salesforce/apex/Utility_reCaptcha.verifyWithNoHeaders";
import { validateFields, validateAllFields, copyAddress } from "c/validation";

const STEPS = [
  {
    label: "Partner Information",
    fields: [
      { name: "FirstName", requiredLabel: "First Name" },
      { name: "LastName", requiredLabel: "Last Name" },
      { name: "Phone", requiredLabel: "Phone" },
      { name: "MobilePhone"},
      { name: "Email", requiredLabel: "Email" },
      { name: "Title" },
      { name: "Company", requiredLabel: "Company" },
      { name: "Website", requiredLabel: "yes", label:"Please enter the URL for your primary website. If you plan to sell Ergotron products using other website URLs, please list them all in the description field." },
      { name: "Entity_Type__c", requiredLabel: "yes" },
      { name: "eStore_Sales_Intent__c", requiredLabel: "yes", topLabel:"Do you plan to sell Ergotron products through an eStore (online checkout)?"},
      { name: "Year_Organized__c", requiredLabel: "yes"},
      { name: "State_of_Incorporation_Organization__c", requiredLabel: "yes"},
      { name: "Description", requiredLabel: "Opportunity Description", label: "Please describe your opportunity. Include customer name, product(s) and quantities."},
      { name: "Legal_Matters_Description__c", requiredLabel: "yes", topLabel: "Disclose and provide a full explanation of any current lawsuits, legal disputes, or pending proceedings involving the company."}
    ]
  },
  {
    label: "Partner Address (Corporate Headquarters)",
      fields: [
      {
        name: "Address",
        requiredLabel: "Full Address",
        isCustomAddress: true,
        addressFields: {
          city: "City",
          province: "StateCode",
          postalCode: "PostalCode",
          street: "Street",
          country: "CountryCode",
          provinceLabel: "State"
        },
        addressFieldLabels: {
          province: "state / province",
          postalCode: "postal code"
        }
      }
    ]
  },
  {
    label: "Partner Classification",
    fields: [
      { name: "ResellerType__c", requiredLabel: "Reseller" },
      { name: "ResellerTypeOther__c" },
      { name: "PrimaryFurnitureLine__c" },
      { name: "FurnitureTypeOther__c" },
      { name: "Online_Marketplace__c" },
      { name: "Ecommerce_Sales_Experience__c", topLabel:"How long have you been engaged in ecommerce sales?"},
      { name: "MarketsServed__c", size: "12", requiredLabel: "Markets Served" },
      { name: "NumberofFieldReps__c", requiredLabel: "Number of Field Reps" },
      { name: "NumberofInsideReps__c", requiredLabel: "Number of Inside Reps" },
      {
        name: "BusinessClassification__c",
        size: 12,
        requiredLabel: "Business Classification"
      },
      { name: "BusinessClassificationOther__c" },
      {},
      { name: "OtherSellingNames__c", requiredLabel: "yes", topLabel: "Other Selling Names - Please list all, including any third-party storefront(s) on online marketplace(s) and the storefront(s)' merchant or seller ID(s); if none, enter N/A.\nPlease note this form is not used to authorize third-party sellers on online marketplaces such as Amazon, eBay, Newegg, and Walmart Marketplace, which requires separate written consent from Ergotron."},
      { name: "OtherBuyingNames__c", requiredLabel: "Other Buying Names", topLabel: "Other Buying Names -- If none, enter N/A"},
      { name: "Affiliated_Entities__c", topLabel: "Provide the names of any affiliated organizations such as parent, sister, or subsidiary entities."},
      { name: "LearnAboutUsResellerPrgm__c", requiredLabel: "Where did you learn about us?" },
      { name: "Product_Source_Distributors__c", requiredLabel: "yes", topLabel: 'Enter the distributor(s) you currently use or plan to use. If unknown, enter "unknown."'}
    ]
  },
  {
    label: "Primary Vendor Manager Contact",
    fields: [
      { name: "WebResellerName__c", requiredLabel: "Vendor Manager Name", topLabel: "Vendor Manager Name" },
      { name: "WebResellerTitle__c", requiredLabel: "Vendor Manager Title", topLabel: "Vendor Manager Title"  },
      { name: "WebResellerEmail__c", requiredLabel: "Vendor Manager Email", topLabel: "Vendor Manager Email"  },
      { name: "WebResellerPhone__c", requiredLabel: "Vendor Manager Phone", topLabel: "Vendor Manager Phone"  },
      /* **Removing address per request SR-25448**
      {
        name: "Address",
        requiredLabel: "Vendor Address", 
        isCustomAddress: true,
        addressFields: {
          city: "WebResellerCity__c",
          province: "WebResellerStateCountry__c",
          postalCode: "WebResellerPostalCode__c",
          street: "WebResellerAddress1__c",
          country: "WebResellerCountry__c",
          provinceLabel: "WebResellerStateCountry__c"
        }
      } */
    ]
  }
];

export default class ResellerForm extends LightningElement {
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

  //tracking toggles
  //@track mapToggle;
  @track accurateInfoToggle;
  @track authTermsToggle;
  @track exhibitABToggle;
  @track ecommTogle;
  //@track uppToggle;
  @track toggle3;
  @track toggle4;
  @track toggle5;

  @track displaySave;
  @track displayDisabledSave;

  connectedCallback() {
    this.loadingForm = true;
    Object.assign(this.lead, {
      LeadSource: "ResellerAuthForm",
      Lead_Source_Sales__c: "Partner Authorization Request",
      Lead_Source_Sub_Type__c: "Reseller"
    });
    window.addEventListener("message", this.handleRecaptchaVerification);
  }

  @wire(getObjectInfo, { objectApiName: LEAD_OBJECT })
  handleGetObjectInfo({ data, error }) {
    if (data) {
      const rtis = data.recordTypeInfos;
      this.lead.RecordTypeId = Object.keys(rtis).find(
        rti => rtis[rti].name === "Ergotron Partner Authorization Request"
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
    //this.mapToggle = false;
    this.accurateInfoToggle = false;
    this.authTermsToggle = false;
    this.exhibitABToggle = false;
    this.ecommToggle = false;
    //this.uppToggle = false;
    this.toggle3 = false;
    this.toggle4 = false;
    this.toggle5 = false;
    this.displaySave = false;
    this.displayDisabledSave = true;
  }

  handleFieldChange(event) {
    let field = event.currentTarget.dataset.field;
    this.lead[field] = event.detail.value;
  }

  /* Removing this function per request SR25448 */
/* 
  copyAddress(event) {
    copyAddress(
      event,
      this.lead,
      this.steps,
      "Partner Address (Corporate Headquarters)",
      "Primary Vendor Management"
    );
  }
 */

  handleSuccess() {
    this.submitting = false;
    window.location.href = "./reseller-confirmation";
  }

  handleError(event) {
    this.submitting = false;
    let errors = [];
    errors.push(event.detail.detail);
    this.errors = errors;
  }

  get hasNext() {
    //returnVal = 0 <= this.currentStep && this.currentStep < this.steps.length - 1;
    //if(returnVal == false) {
    //  this.displayDisabledSave = true;
    //}
    //return returnVal;


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

    //Sophia Murphy (Demand Chain)
    //If "Online Retailer" is selected as the Reseller Type, then Online Marketplace is required
    console.log(this.currentStep);
    console.log(this.lead["ResellerType__c"]);
    console.log(this.lead["Online_Marketplace__c"]);
    //If you go straight to the 3rd tab; it says the currentStep is 2?  But if you step through the form - it says currentStep is 3
    if( (this.currentStep == 2 || this.currentStep == 3) && this.lead["ResellerType__c"] == 'Online Retailer') {
      console.log("234");
      if(this.lead["Online_Marketplace__c"] == null || this.lead["Online_Marketplace__c"] == undefined) {
        console.log("236");
        this.errors.push(
          "Online Marketplace is required."
        );
        console.log("240");
      }
    }
			
    if (!this.errors.length) {
      this.template.querySelector("c-path").handleNext();
    }

    if(this.currentStep == this.steps.length - 1) {
      //if(this.mapToggle == true && this.exhibitABToggle == true && this.ecommToggle == true && this.uppToggle == true && this.toggle3 == true && this.toggle4 == true && this.toggle5 == true) {
      // temporary modification of the if statement to allow for the mapToggle and uppToggle to be false
      if(this.accurateInfoToggle == true && this.authTermsToggle == true && this.exhibitABToggle == true && this.ecommToggle == true && this.toggle3 == true && this.toggle4 == true && this.toggle5 == true) {
        this.displaySave = true;
        this.displayDisabledSave = false;
      } else {
        this.displaySave = false;
        this.displayDisabledSave = true;
      }
    } else {
      this.displaySave = false;
      this.displayDisabledSave = false;
    }

  }
/* 
  handleMapToggle(event) {
    this.mapToggle = event.target.checked;
    
    if(this.currentStep == this.steps.length - 1) {
      if(this.mapToggle == true && this.exhibitABToggle == true && this.ecommToggle == true && this.uppToggle == true && this.toggle3 == true && this.toggle4 == true && this.toggle5 == true) {
        this.displaySave = true;
        this.displayDisabledSave = false;
      } else {
        this.displaySave = false;
        this.displayDisabledSave = true;
      }
    } else {
      this.displaySave = false;
      this.displayDisabledSave = false;
    }
  }
 */

  handleAccurateInfoToggle(event) {
    this.accurateInfoToggle = event.target.checked;
    
    if(this.currentStep == this.steps.length - 1) {
      //if(this.mapToggle == true && this.exhibitABToggle == true && this.ecommToggle == true && this.uppToggle == true && this.toggle3 == true && this.toggle4 == true && this.toggle5 == true) {
      // temporary modification of the if statement to allow for the mapToggle and uppToggle to be false
      if(this.accurateInfoToggle == true && this.authTermsToggle == true && this.exhibitABToggle == true && this.ecommToggle == true && this.toggle3 == true && this.toggle4 == true && this.toggle5 == true) {
        this.displaySave = true;
        this.displayDisabledSave = false;
      } else {
        this.displaySave = false;
        this.displayDisabledSave = true;
      }
    } else {
      this.displaySave = false;
      this.displayDisabledSave = false;
    }

  }

  handleAuthTermsToggle(event) {
    this.authTermsToggle = event.target.checked;
    
    if(this.currentStep == this.steps.length - 1) {
      //if(this.mapToggle == true && this.exhibitABToggle == true && this.ecommToggle == true && this.uppToggle == true && this.toggle3 == true && this.toggle4 == true && this.toggle5 == true) {
      // temporary modification of the if statement to allow for the mapToggle and uppToggle to be false
      if(this.accurateInfoToggle == true && this.authTermsToggle == true && this.exhibitABToggle == true && this.ecommToggle == true && this.toggle3 == true && this.toggle4 == true && this.toggle5 == true) {
        this.displaySave = true;
        this.displayDisabledSave = false;
      } else {
        this.displaySave = false;
        this.displayDisabledSave = true;
      }
    } else {
      this.displaySave = false;
      this.displayDisabledSave = false;
    }

  }

  handleExhibitABToggle(event) {
    this.exhibitABToggle = event.target.checked;
    
    if(this.currentStep == this.steps.length - 1) {
      //if(this.mapToggle == true && this.exhibitABToggle == true && this.ecommToggle == true && this.uppToggle == true && this.toggle3 == true && this.toggle4 == true && this.toggle5 == true) {
      // temporary modification of the if statement to allow for the mapToggle and uppToggle to be false
      if(this.accurateInfoToggle == true && this.authTermsToggle == true && this.exhibitABToggle == true && this.ecommToggle == true && this.toggle3 == true && this.toggle4 == true && this.toggle5 == true) {
        this.displaySave = true;
        this.displayDisabledSave = false;
      } else {
        this.displaySave = false;
        this.displayDisabledSave = true;
      }
    } else {
      this.displaySave = false;
      this.displayDisabledSave = false;
    }

    }

  handleEcommToggle(event) {
    this.ecommToggle = event.target.checked;
    
    if(this.currentStep == this.steps.length - 1) {
      //if(this.mapToggle == true && this.exhibitABToggle == true && this.ecommToggle == true && this.uppToggle == true && this.toggle3 == true && this.toggle4 == true && this.toggle5 == true) {
      // temporary modification of the if statement to allow for the mapToggle and uppToggle to be false
      if(this.accurateInfoToggle == true && this.authTermsToggle == true && this.exhibitABToggle == true && this.ecommToggle == true && this.toggle3 == true && this.toggle4 == true && this.toggle5 == true) {
        this.displaySave = true;
        this.displayDisabledSave = false;
      } else {
        this.displaySave = false;
        this.displayDisabledSave = true;
      }
    } else {
      this.displaySave = false;
      this.displayDisabledSave = false;
    }
  }

/* 
  handleUppToggle(event) {
    this.uppToggle = event.target.checked;
    
    if(this.currentStep == this.steps.length - 1) {
      if(this.mapToggle == true && this.exhibitABToggle == true && this.ecommToggle == true && this.uppToggle == true && this.toggle3 == true && this.toggle4 == true && this.toggle5 == true) {
        this.displaySave = true;
        this.displayDisabledSave = false;
      } else {
        this.displaySave = false;
        this.displayDisabledSave = true;
      }
    } else {
      this.displaySave = false;
      this.displayDisabledSave = false;
    }
  }
 */

  handleToggle3(event) {
    this.toggle3 = event.target.checked;
    
    if(this.currentStep == this.steps.length - 1) {
      //if(this.mapToggle == true && this.exhibitABToggle == true && this.ecommToggle == true && this.uppToggle == true && this.toggle3 == true && this.toggle4 == true && this.toggle5 == true) {
      // temporary modification of the if statement to allow for the mapToggle and uppToggle to be false
      if(this.accurateInfoToggle == true && this.authTermsToggle == true && this.exhibitABToggle == true && this.ecommToggle == true && this.toggle3 == true && this.toggle4 == true && this.toggle5 == true) {
        this.displaySave = true;
        this.displayDisabledSave = false;
      } else {
        this.displaySave = false;
        this.displayDisabledSave = true;
      }
    } else {
      this.displaySave = false;
      this.displayDisabledSave = false;
    }
  }

  handleToggle4(event) {
    this.toggle4 = event.target.checked;
    
    if(this.currentStep == this.steps.length - 1) {
      //if(this.mapToggle == true && this.exhibitABToggle == true && this.ecommToggle == true && this.uppToggle == true && this.toggle3 == true && this.toggle4 == true && this.toggle5 == true) {
      // temporary modification of the if statement to allow for the mapToggle and uppToggle to be false
      if(this.accurateInfoToggle == true && this.authTermsToggle == true && this.exhibitABToggle == true && this.ecommToggle == true && this.toggle3 == true && this.toggle4 == true && this.toggle5 == true) {
        this.displaySave = true;
        this.displayDisabledSave = false;
      } else {
        this.displaySave = false;
        this.displayDisabledSave = true;
      }
    } else {
      this.displaySave = false;
      this.displayDisabledSave = false;
    }
  }

  handleToggle5(event) {
    this.toggle5 = event.target.checked;
    
    if(this.currentStep == this.steps.length - 1) {
      //if(this.mapToggle == true && this.exhibitABToggle == true && this.ecommToggle == true && this.uppToggle == true && this.toggle3 == true && this.toggle4 == true && this.toggle5 == true) {
      // temporary modification of the if statement to allow for the mapToggle and uppToggle to be false
      if(this.accurateInfoToggle == true && this.authTermsToggle == true && this.exhibitABToggle == true && this.ecommToggle == true && this.toggle3 == true && this.toggle4 == true && this.toggle5 == true) {
        this.displaySave = true;
        this.displayDisabledSave = false;
      } else {
        this.displaySave = false;
        this.displayDisabledSave = true;
      }
    } else {
      this.displaySave = false;
      this.displayDisabledSave = false;
    }
  }

  handleSubmit(event) {
    event.preventDefault();
    this.errors = validateAllFields(this.lead, this.steps);

    //Temporary modification of the if statement to allow for the mapToggle and uppToggle to be false
    //if(this.mapToggle == false || this.exhibitABToggle == false || this.ecommToggle == false || this.uppToggle == false || this.toggle3 == false || this.toggle4 == false || this.toggle5 == false) {
    if(this.accurateInfoToggle == false || this.authTermsToggle == false || this.exhibitABToggle == false || this.ecommToggle == false || this.toggle3 == false || this.toggle4 == false || this.toggle5 == false) {

      this.errors.push(
        //"Please indicate that you have read and acknowledge the Minimum Advertised Price Policy and Unilateral Price Policy."
        "Please indicate that you have read and acknowledged each of the agreements/policies listed."
      );
    }

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

  /**
  get displaySave() {
    return this.currentStep === this.steps.length - 1;
  }

  get displayDisabledSave() {
    return this.currentStep === this.steps.length - 1;
  }
  */

  get displayPartnerClassificationScreen() {
    return this.currentStep === 2;
  }

  get displayPrimaryVendorMgmt() {
    return this.currentStep === 3;
  }

  handleStepChange(event) {
    this.errors = [];
    this.currentStep = event.detail;
    
    if(this.currentStep == this.steps.length - 1) {
      //console.log("328");
      //if(this.mapToggle == true && this.exhibitABToggle == true && this.ecommToggle == true && this.uppToggle == true && this.toggle3 == true && this.toggle4 == true && this.toggle5 == true) {
      // temporary modification of the if statement to allow for the mapToggle and uppToggle to be false
      if(this.accurateInfoToggle == true && this.authTermsToggle == true && this.exhibitABToggle == true && this.ecommToggle == true && this.toggle3 == true && this.toggle4 == true && this.toggle5 == true) {
        this.displaySave = true;
        this.displayDisabledSave = false;
      } else {
        //console.log("333");
        this.displaySave = false;
        this.displayDisabledSave = true;
      }
    } else {
      //console.log("338");
      this.displaySave = false;
      this.displayDisabledSave = false;
    }


  }

  handleRecaptchaVerification = event => {
    this.recaptchaMessage = event.data;
  };
}