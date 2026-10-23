import { LightningElement, api } from "lwc";

export default class PathStep extends LightningElement {
  @api step;

  get css() {
    let css = "slds-path__item ";
    if (this.step) {
      switch (this.step.status) {
        case "complete":
          return css + "slds-is-complete";
        case "active":
          return css + "slds-is-current slds-is-active";
        default:
          return css + "slds-is-incomplete";
      }
    }
    return css;
  }
}