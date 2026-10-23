import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class Navigatetorecord extends NavigationMixin(LightningElement){

    @api recordIDValue;
    @api objectName;

    connectedCallback() {
        console.log('-----------------Navigating to '+this.recordIDValue+'---------------'+this.objectName);
        this.navigateToRecordViewPage();
    }



    navigateToRecordViewPage() {
        // View a custom object record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordIDValue,
                objectApiName: this.objectName, // objectApiName is optional
                actionName: 'view'
            }
        });
    }

}