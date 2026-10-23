import { LightningElement } from 'lwc';
import LOCALE from '@salesforce/i18n/locale';
// import LANG from '@salesforce/i18n/lang';

// if (loc == "en-US") { langIsEN = true };

export default class ErgoFooterEN extends LightningElement {
  // loc = LOCALE;
  langIsEN = true;

  legalurlEN = "https://www.ergotron.com/" + LOCALE + "/company/legal";
  privpolicyurlEN = "https://www.ergotron.com/" + LOCALE + "/company/legal/privacy-policy";
  cookiesurlEN = "https://www.ergotron.com/" + LOCALE + "/company/legal/cookies";
  // termsurlEN = "https://www.ergotron.com/" + LOCALE + "/company/terms-and-conditions";
  termsurlEN = "https://www.ergotron.com/" + LOCALE + "/company/legal/terms-of-use";
  currentYearEN = new Date().getFullYear();
}