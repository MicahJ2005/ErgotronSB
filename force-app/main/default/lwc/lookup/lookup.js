import { LightningElement, api, track } from 'lwc';

export default class Lookup extends LightningElement {

    @track error;
    @track openMenu;
    @track value;
    @api label;
    @api required;
    @api records;
    @api helpText;
    @api iconName = 'standard:account';
    @track valueLabel;
    @api placeHolder;
    @track filteredRecords;

    handlePillClick() {
        this.value = '';
        this.filteredRecords = [...this.records];
    }

    handleOnChange(event){
        let searchTerm = event.currentTarget.value;
        let records = [...this.records];
        if(searchTerm){
            records = records.filter(record => record.Name.toLowerCase().indexOf(searchTerm.toLowerCase()) !== -1);
        }
        this.filteredRecords = records;
    }

    handleOnFocus(){
        if(this.displayRecordsOnFocus){
           this.filteredRecords = [...this.records];
    	}
    }

    handleRecordClick(event){
        let idx = event.currentTarget.dataset.index;
        let record = this.filteredRecords[idx];
        this.valueLabel = record.Name;
        this.value = record.Id;
        this.dispatchEvent(new CustomEvent('selected', { detail : record }));
    }

    get menuDivCSS(){
        return 'slds-form-element slds-lookup slds-is-open ' + (this.error ? 'slds-has-error ' : '') + (this.openMenu ? 'sl-lookup--open ' : '');
    }

    get recordsIsEmpty(){
        return !this.records || !this.records.length;
    }

    get displayPillContainer(){
        return this.value || this.recordsIsEmpty;
    }
}