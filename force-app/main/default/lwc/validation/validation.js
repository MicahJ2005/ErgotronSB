import { LightningElement } from "lwc";

export default class Validation extends LightningElement {}

const validateFields = (lead, fields) => {
  //First, check for requiredness of fields.
  let errors = [];
  fields.forEach(field => {
    if (field.requiredLabel) {
      if (field.addressFields) {
        Object.entries(field.addressFields).forEach(([key, val]) => {
          if (key !== "provinceLabel") {
            let countryField = field.addressFields.country;
            if (
              (key !== "province" && key !== "postalCode") ||
              (countryField &&
                ("US" === lead[countryField] || "CA" === lead[countryField]))
            ) {
              if (!lead[val]) {
                let label =
                  field.addressFieldLabels && field.addressFieldLabels[key]
                    ? field.addressFieldLabels[key]
                    : key;
                errors.push(
                  field.requiredLabel + " " + label + " is required."
                );
              }
            }
          }
        });
      } else if (!lead[field.name]) {
        errors.push(field.requiredLabel + " is required.");
      }
    }
  });
  return errors;
};

const validateAllFields = (lead, steps) => {
  //First, check for requiredness of fields.
    console.log("41");
    console.log("lead: " + lead);
    console.log(lead);
    console.log("steps: " + steps);
    console.log(steps);
  let errors = [];
  console.log("45");
  steps.forEach(step => {
    console.log("47");
    step.fields.forEach(field => {
      console.log("49");
      if (field.requiredLabel) {
        if (field.addressFields) {
          console.log("52");
          Object.entries(field.addressFields).forEach(([key, val]) => {
            if (key !== "provinceLabel") {
              console.log("55");
              let countryField = field.addressFields.country;
              if (
                (key !== "province" && key !== "postalCode") ||
                (countryField &&
                  ("US" === lead[countryField] || "CA" === lead[countryField]))
              ) {
                console.log("59");
                if (!lead[val]) {
                  let label =
                    field.addressFieldLabels && field.addressFieldLabels[key]
                      ? field.addressFieldLabels[key]
                      : key;
                  errors.push(
                    field.requiredLabel + " " + label + " is required."
                  );
                }
              }
            }
          });
        } else if (!lead[field.name]) {
          console.log("73");
          errors.push(field.requiredLabel + " is required.");
        }
      }
      console.log("77");
    });
  });
  console.log("80");
  return errors;
};

const copyAddress = (event, lead, steps, copyFromLabel, copyToLabel) => {
  event.preventDefault();
  event.stopPropagation();

  let copyFromFields = steps.find(field => field.label === copyFromLabel)
    .fields[0].addressFields;
  let copyToFields = steps
    .find(field => field.label === copyToLabel)
    .fields.find(field => field.name === "Address").addressFields;

  Object.entries(copyFromFields).forEach(([key, value]) => {
    let copyFromFieldValue = lead[value];
    let copyToField = copyToFields[key];
    lead[copyToField] = copyFromFieldValue;
  });

  let provinceLabelCopy;
  if (copyFromFields.provinceLabel) {
    let copyFromVal = lead[copyFromFields.provinceLabel];
    if (copyFromVal) {
      lead[copyToFields.provinceLabel] = copyFromVal;
      provinceLabelCopy = true;
    }
  }

  if (!provinceLabelCopy) {
    let copyFromVal = lead[copyFromFields.province];
    if (copyFromVal) {
      lead[copyToFields.province] = copyFromVal;
    }
  }
};

export { validateAllFields, validateFields, copyAddress };