import { LightningElement, api, track } from "lwc";

export default class Path extends LightningElement {
  @api defaultSteps;
  @track steps;

  connectedCallback() {
    this.initializeSteps(this.defaultSteps);
  }

  initializeSteps(defaultSteps) {
    let steps = [];
    let index = 0;
    let foundActive = false;
    if (defaultSteps) {
      defaultSteps.forEach(step => {
        let current = { ...step };
        current.index = index;
        index++;
        foundActive |= current.active;

        Object.defineProperty(current, "css", {
          get: function() {
            let css = "slds-path__item ";
            if (this.active) {
              return css + "slds-is-current slds-is-active";
            }

            if (this.completed) {
              return css + "slds-is-complete";
            }

            if (this.error) {
              return css + "slds-is-current slds-is-active + slds-is-lost";
            }

            return css + "slds-is-incomplete";
          }
        });
        steps.push(current);
      });
    }

    if (steps.length > 0 && !foundActive) {
      steps[0].active = true;
    }

    this.steps = steps;

    this.currentStep.active = true;
  }

  @api
  handlePrev() {
    if (this.hasPrev) {
      this.handleStepChange(this.currentStep.index - 1, true);
    }
  }

  @api
  handleNext() {
    if (this.hasNext) {
      this.handleStepChange(this.currentStep.index + 1, true);
    }
  }

  @api
  get currentStep() {
    let step = this.steps.find(current => current.active);
    if (!step) {
      step = this.steps && this.steps.length > 0 ? this.steps[0] : undefined;
    }
    return { ...step };
  }

  @api
  get hasNext() {
    const step = this.currentStep;
    return step && step.index < this.steps.length - 1;
  }

  @api
  get hasPrev() {
    const step = this.currentStep;
    return step && step.index > 0;
  }

  @api
  handleStepClick(event) {
    let index = parseInt(event.currentTarget.dataset.index, 10);
    this.handleStepChange(index);
  }

  @api
  handleStepChange(step, completePreviousSteps) {
    let steps = [...this.steps];
    steps.forEach(current => {
      if (completePreviousSteps) {
        current.completed = current.index < step;
      }

      current.active = current.index === step;
    });
    this.steps = steps;
    this.dispatchEvent(
      new CustomEvent("stepchange", { detail: step ? step : 0 })
    );
  }
}