import { LightningElement } from 'lwc';
import RC_BUNDLE_SKU_FINDER from '@salesforce/resourceUrl/RhythmConnectBundleSKUFinder';

export default class RhythmConnectSkuFinder extends LightningElement {
  htmlResourceUrl = RC_BUNDLE_SKU_FINDER;
}