import { LightningElement, api, track } from "lwc";

export default class RecordInputForm extends LightningElement {
  @api fieldString = "FirstName,LastName";
  @api objectApiName = "Lead";
  @api largeDeviceSize = "6";
  @api mediumDeviceSize = "6";
  @api smallDeviceSize = "12";
  @api padding = "slds-p-around_small";
  @api record = {};
  @api copyValuesFromSource;
  @api showSpinner;
  @api variant = "label-stacked";
  @track processing;
  @api fields;

  //@track fieldsToDisplay = [];

  connectedCallback() {
    this.processing = true;
  }

  get fieldsToDisplay() {
    let fields = this.fields.map(field => {
      let record = this.record;

      let newField = { ...field };

      newField.variant = field.topLabel ? "label-hidden" : this.variant;
      newField.value = field.valueName
        ? record[field.valueName]
        : record[field.name];
      newField.smallDeviceSize = newField.size
        ? newField.size
        : this.smallDeviceSize;
      newField.mediumDeviceSize = newField.size
        ? newField.size
        : this.mediumDeviceSize;
      newField.largeDeviceSize = newField.size
        ? newField.size
        : this.largeDeviceSize;
      newField.required = !!newField.requiredLabel;
      if (field.addressFields) {
        if (this.fields.length === 1) {
          newField.largeDeviceSize = 12;
          newField.mediumDeviceSize = 12;
        }

        let value = {};
        Object.entries(field.addressFields).forEach(([key, val]) => {
          value[key] = record[val] ? record[val] : "";
        });
        newField.value = value;
      }

      newField.css =
        "slds-col slds-size-" +
        newField.smallDeviceSize +
        "-of-12 slds-medium-size_" +
        newField.mediumDeviceSize +
        "-of-12 slds-large-size_" +
        newField.largeDeviceSize +
        "-of-12 " +
        this.padding;

      return newField;
    });
    return fields;
  }

  handleOnLoad() {
    this.processing = false;
  }

  get displaySpinner() {
    return this.showSpinner && this.processing;
  }

  handleFieldChange(event) {
    let fieldname;
    if (!event.currentTarget || !event.currentTarget.dataset || !event.currentTarget.dataset.field) {
      if (event.detail && event.detail.field) {
        fieldname = event.detail.field;
      }
    }else{
        fieldname = event.currentTarget.dataset.field;
    }


    let fields = [...this.fields];

    let field = fields.find(key => key.name === fieldname);

    let record = { ...this.record };
    if (field.addressFields) {
      if (
        event.detail.street ||
        event.detail.country ||
        event.detail.province ||
        event.detail.city ||
        event.detail.postalCode ||
        event.detail.provinceLabel
      ) {
        Object.keys(field.addressFields).forEach(key => {
          let addressField = field.addressFields[key];
          record[addressField] = event.detail[key];
        });


        if(field.addressFields.provinceLabel){
            if(event.detail.provinceLabel){
                let addressField = field.addressFields.provinceLabel;
                record[addressField] = event.detail.provinceLabel;
            }else if(event.detail.province){
                let addressField = field.addressFields.province;
                record[addressField] = event.detail.province;
            }
        }
      }
    } else {
      record[fieldname] = event.detail.value;
    }

    this.dispatchEvent(new CustomEvent("recordchange", { detail: record }));
  }
}