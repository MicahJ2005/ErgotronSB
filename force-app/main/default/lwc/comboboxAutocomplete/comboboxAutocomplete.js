import { LightningElement, api, track } from 'lwc';

export default class ComboboxAutocomplete extends LightningElement {

    @api classes;
    @api label;
    @api placeholder;
    @api value;
    @api options;
    
    @track isFocussed = false;

    filteredOptions = [];

    @api reportComboBoxValidity() {
        let ret = true;    
        //console.log('Reporting validity in Auto Complete---->');
        this.template.querySelectorAll('lightning-input').forEach(element => 
        {                
            //console.log('Combo Value---->'+element.value);
            if(!element.reportValidity())
            {
                ret=false;                
            }                
        });
        
        return ret;

    }

    connectedCallback() {
        this.filteredOptions = [...this.options];
        //console.log('this.filteredOptions------->'+JSON.stringify(this.filteredOptions));
    }

    filterOptions(event) {
        //console.log('filterOptions---->');
        const filterText = event.detail.value;
        this.value = filterText;
        this.filteredOptions = this.options.filter(option => {
            //console.log('option.label-->'+option.label);
            //console.log('option.description-->'+option.description);
            if(option.description) {
                return (option.label.toLowerCase().includes(filterText.toLowerCase()) || (option.description.toLowerCase().includes(filterText.toLowerCase())));
            } else {
                return option.label.toLowerCase().includes(filterText.toLowerCase());
            }
            
        });
        this.reportComboBoxValidity();
    }

    handleSelectOption(event) {
        console.log('handleSelectOption in Auto complete---->'+event.currentTarget.dataset.label + ' ' + event.currentTarget.dataset.cp); 
        console.log('handleSelectOption in Auto complete---->'+event.currentTarget.dataset.label + ' ' + event.currentTarget.dataset.serialized);        
       
        this.value = event.currentTarget.dataset.label;
        
        this.template.querySelector('lightning-input').value = this.value;

        const custEvent = new CustomEvent(
            'selectoption', {
                detail: {
                    value: event.currentTarget.dataset.value,
                    label: event.currentTarget.dataset.label,
                    cp: event.currentTarget.dataset.cp,
                    ob: event.currentTarget.dataset.ob,
                    pid: event.currentTarget.dataset.pid,
                    serialized: event.currentTarget.dataset.serialized
                }
            }
        );
        this.dispatchEvent(custEvent);

        // Close the picklist options
        this.isFocussed = false;
        this.reportComboBoxValidity();
    }

    get noOptions() {
        return this.filteredOptions.length === 0;
    }

    get dropdownClasses() {
        
        let dropdownClasses = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
        
        // Show dropdown list on focus
        if (this.isFocussed) {
            dropdownClasses += ' slds-is-open';
        }

        return dropdownClasses;
    }

    handleFocus() {
        this.filteredOptions = [...this.options];
        this.isFocussed = true;
    }

    handleBlur() {
        // Timeout to ensure click event is captured before the 
        // options are hidden
        setTimeout(() => { this.isFocussed = false; }, 500);
    }
}