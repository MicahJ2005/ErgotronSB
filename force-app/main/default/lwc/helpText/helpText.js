import { LightningElement, track, api} from 'lwc';

export default class HelpText extends LightningElement {
    @track show;
    @api content;

    handleMouseOver(){
        this.show = true;
    }

    handleMouseOut(){
        this.show = false;
    }

    get css(){
        return 'slds-popover slds-popover_tooltip slds-nubbin_bottom-left helpTextContent' + (this.show ? '' : ' slds-hide');
    }
}