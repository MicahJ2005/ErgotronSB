import { LightningElement, track } from 'lwc';
import registerCommunityUser from '@salesforce/apex/DealRegRegistrationCtrl.register';
import login from '@salesforce/apex/DealRegRegistrationCtrl.login';
import { NavigationMixin } from 'lightning/navigation';

const PASSWORD_CRITERIA = [
    {
        name : 'length',
        error : 'Password must have 10 or more characters',
        shortLabel : "10+",
        value : 10
    },
    {
        name : 'upper',
        error : 'Password must contain 1 or more upper case letters.',
        shortLabel : "A-Z",
        value : /[A-Z]/
    },
    {
        name : 'lower',
        error : 'Password must have 1 or more lower case characters',
        shortLabel : "a-z",
        value : /[a-z]/
    },
    {
        name : 'number',
        error : 'Password must contain 1 or more numbers (0-9)',
        shortLabel : "0-9",
        value : /[\d]/
    },
    {
        name : 'special',
        error : 'Passord must contain 1 or more special characters (!, @, #, $, %, ^, &, or *)',
        shortLabel : "!@#$%^&*",
        value : /[!@#$%^&*]/
    }
];

const HELP_TEXT = 'The password must contain 10 or more characters.';//The characters must include an upper case character (A-Z), a lower case character (a-z), a number (0 - 9), and a special character (!, @, #, $, %, ^, &, or *)';

export default class dealRegSelfRegister extends NavigationMixin(LightningElement){

    @track errors = [];
    @track criterias = PASSWORD_CRITERIA;
    @track score;
    @track password;
    @track confirm;
    @track selectedCountry = 'US';
    @track selectedState;
    helpText = HELP_TEXT;
    @track processing;
    @track displayAlreadyExists;

    handleCancel(event){
        debugger;
        event.preventDefault();
        event.stopPropagation();
        window.location.href='../login';
    }

    handlePasswordChange(event){
        this.password = event.target.value;
        this.score = this.getScore();
    }

    handleConfirmChange(event){
        this.confirm = event.target.value
    }

    handleCountryChange(event) {
        this.selectedCountry = event.target.value;
    }

    handleSubmit(event){
        this.errors = [];
        this.displayAlreadyExists = false;
        let errors = [];

        this.processing = true;

        if(!this.password || !this.confirm){
            this.errors.push('Password and confirmation password are required.');
            this.processing = false;
            return;
        }

        if(this.password !== this.confirm){
            this.errors.push('Password and confirmation do not match.');
            this.processing = false;
            return;
        }

        /*if(this.criterias){
            this.criterias.forEach(criteria => {
                if(!criteria.success){
                    errors.push(criteria.error);
                }
            })
            if(errors.length > 0){
                this.errors = errors;
                this.processing = false;
                return;
            }
        }*/

        event.detail.fields.CountryCode = this.selectedCountry;
        event.detail.fields.StateCode = this.selectedState;
        registerCommunityUser({ u : event.detail.fields, password : this.password })
            .then(registrationResult => {
                this.password = '';
                this.confirm = '';
                this.processing = false;
                window.location.href = '../selfregconfirm';
            })
            .catch(error => {
                if(error.body.message === 'ALREADY_EXISTS'){
                    this.displayAlreadyExists = true;
                }else if(error.body.message){
                    this.errors.push(error.body.message);
                }else{
                    this.errors.push(error);
                }
                this.password = '';
                this.confirm = '';
                this.processing = false;
            });
    }

    getScore(){
        return 0;
        /*if(!this.password){
            this.criterias.forEach(criteria => { criteria.success = false; });
            return 0;
        }

        if(!this.criterias){
            this.criterias.forEach(criteria => { criteria.success = true; });
            return 100;
        }

        let score = 0;

        //let criteriaValue = 100 / this.criterias.length;
         this.criterias.forEach(criteria =>{
            criteria.success = false;
            if(criteria.name === 'length'){
                if(this.password.length >= criteria.value){
                    score += 1;
                    criteria.success = true;
                }else{
                    score += (this.password.length / criteria.value);
                }
            }else{
                if(criteria.value.test(this.password)){
                    criteria.success = true;
                    score += 1;
                }
            }
        });

        console.log('Score: ' + score);
        return (score / this.criterias.length) * 100;*/
    }

    getScoreResult(regex){
        return regex.test(this.password) ? 1 : 0;
    }

    get passwordCSS(){
        return this.score >= 100 ? 'check' : 'x';
    }

    get confirmCSS(){
        return this.password && this.password === this.confirm ? 'check' : 'x';
    }

    get progressBarWidth(){
        let score = this.score;
        score = 100 > score ? score : 100;
        return 'width: ' + score + '%';
    }

    get progressBarColor(){
        let score = this.score;
        return score > 50 ? (score >= 100 ? 'green' : 'yellow') : 'red';
    }

    get progressBarCSS(){
        return 'slds-progress-bar__value slds-progress-bar_large ' + this.progressBarColor;
    }

    get provinceOptions(){
        return this.countryProvinceMap[this.selectedCountry];
    }

    get countryOptions(){
        return [
            {'value' : 'AF', 'label' : 'Afghanistan'},
            {'value' : 'AX', 'label' : 'Aland Islands'},
            {'value' : 'AL', 'label' : 'Albania'},
            {'value' : 'DZ', 'label' : 'Algeria'},
            {'value' : 'AD', 'label' : 'Andorra'},
            {'value' : 'AO', 'label' : 'Angola'},
            {'value' : 'AI', 'label' : 'Anguilla'},
            {'value' : 'AQ', 'label' : 'Antarctica'},
            {'value' : 'AG', 'label' : 'Antigua and Barbuda'},
            {'value' : 'AR', 'label' : 'Argentina'},
            {'value' : 'AM', 'label' : 'Armenia'},
            {'value' : 'AW', 'label' : 'Aruba'},
            {'value' : 'AU', 'label' : 'Australia'},
            {'value' : 'AT', 'label' : 'Austria'},
            {'value' : 'AZ', 'label' : 'Azerbaijan'},
            {'value' : 'BS', 'label' : 'Bahamas'},
            {'value' : 'BH', 'label' : 'Bahrain'},
            {'value' : 'BD', 'label' : 'Bangladesh'},
            {'value' : 'BB', 'label' : 'Barbados'},
            {'value' : 'BY', 'label' : 'Belarus'},
            {'value' : 'BE', 'label' : 'Belgium'},
            {'value' : 'BZ', 'label' : 'Belize'},
            {'value' : 'BJ', 'label' : 'Benin'},
            {'value' : 'BM', 'label' : 'Bermuda'},
            {'value' : 'BT', 'label' : 'Bhutan'},
            {'value' : 'BO', 'label' : 'Bolivia, Plurinational State of'},
            {'value' : 'BQ', 'label' : 'Bonaire, Sint Eustatius and Saba'},
            {'value' : 'BA', 'label' : 'Bosnia and Herzegovina'},
            {'value' : 'BW', 'label' : 'Botswana'},
            {'value' : 'BV', 'label' : 'Bouvet Island'},
            {'value' : 'BR', 'label' : 'Brazil'},
            {'value' : 'IO', 'label' : 'British Indian Ocean Territory'},
            {'value' : 'BN', 'label' : 'Brunei Darussalam'},
            {'value' : 'BG', 'label' : 'Bulgaria'},
            {'value' : 'BF', 'label' : 'Burkina Faso'},
            {'value' : 'BI', 'label' : 'Burundi'},
            {'value' : 'KH', 'label' : 'Cambodia'},
            {'value' : 'CM', 'label' : 'Cameroon'},
            {'value' : 'CA', 'label' : 'Canada'},
            {'value' : 'CV', 'label' : 'Cape Verde'},
            {'value' : 'KY', 'label' : 'Cayman Islands'},
            {'value' : 'CF', 'label' : 'Central African Republic'},
            {'value' : 'TD', 'label' : 'Chad'},
            {'value' : 'CL', 'label' : 'Chile'},
            {'value' : 'CN', 'label' : 'China'},
            {'value' : 'TW', 'label' : 'Chinese Taipei'},
            {'value' : 'CX', 'label' : 'Christmas Island'},
            {'value' : 'CC', 'label' : 'Cocos (Keeling) Islands'},
            {'value' : 'CO', 'label' : 'Colombia'},
            {'value' : 'KM', 'label' : 'Comoros'},
            {'value' : 'CG', 'label' : 'Congo'},
            {'value' : 'CD', 'label' : 'Congo, the Democratic Republic of the'},
            {'value' : 'CK', 'label' : 'Cook Islands'},
            {'value' : 'CR', 'label' : 'Costa Rica'},
            {'value' : 'CI', 'label' : 'Cote d\'Ivoire'},
            {'value' : 'HR', 'label' : 'Croatia'},
            {'value' : 'CU', 'label' : 'Cuba'},
            {'value' : 'CW', 'label' : 'Curaçao'},
            {'value' : 'CY', 'label' : 'Cyprus'},
            {'value' : 'CZ', 'label' : 'Czech Republic'},
            {'value' : 'DK', 'label' : 'Denmark'},
            {'value' : 'DJ', 'label' : 'Djibouti'},
            {'value' : 'DM', 'label' : 'Dominica'},
            {'value' : 'DO', 'label' : 'Dominican Republic'},
            {'value' : 'EC', 'label' : 'Ecuador'},
            {'value' : 'EG', 'label' : 'Egypt'},
            {'value' : 'SV', 'label' : 'El Salvador'},
            {'value' : 'GQ', 'label' : 'Equatorial Guinea'},
            {'value' : 'ER', 'label' : 'Eritrea'},
            {'value' : 'EE', 'label' : 'Estonia'},
            {'value' : 'ET', 'label' : 'Ethiopia'},
            {'value' : 'FK', 'label' : 'Falkland Islands (Malvinas)'},
            {'value' : 'FO', 'label' : 'Faroe Islands'},
            {'value' : 'FJ', 'label' : 'Fiji'},
            {'value' : 'FI', 'label' : 'Finland'},
            {'value' : 'FR', 'label' : 'France'},
            {'value' : 'GF', 'label' : 'French Guiana'},
            {'value' : 'PF', 'label' : 'French Polynesia'},
            {'value' : 'TF', 'label' : 'French Southern Territories'},
            {'value' : 'GA', 'label' : 'Gabon'},
            {'value' : 'GM', 'label' : 'Gambia'},
            {'value' : 'GE', 'label' : 'Georgia'},
            {'value' : 'DE', 'label' : 'Germany'},
            {'value' : 'GH', 'label' : 'Ghana'},
            {'value' : 'GI', 'label' : 'Gibraltar'},
            {'value' : 'GR', 'label' : 'Greece'},
            {'value' : 'GL', 'label' : 'Greenland'},
            {'value' : 'GD', 'label' : 'Grenada'},
            {'value' : 'GP', 'label' : 'Guadeloupe'},
            {'value' : 'GU', 'label' : 'Guam'},
            {'value' : 'GT', 'label' : 'Guatemala'},
            {'value' : 'GG', 'label' : 'Guernsey'},
            {'value' : 'GN', 'label' : 'Guinea'},
            {'value' : 'GW', 'label' : 'Guinea-Bissau'},
            {'value' : 'GY', 'label' : 'Guyana'},
            {'value' : 'HT', 'label' : 'Haiti'},
            {'value' : 'HM', 'label' : 'Heard Island and McDonald Islands'},
            {'value' : 'VA', 'label' : 'Holy See (Vatican City State)'},
            {'value' : 'HN', 'label' : 'Honduras'},
            {'value' : 'HK', 'label' : 'Hong Kong'},
            {'value' : 'HU', 'label' : 'Hungary'},
            {'value' : 'IS', 'label' : 'Iceland'},
            {'value' : 'IN', 'label' : 'India'},
            {'value' : 'ID', 'label' : 'Indonesia'},
            {'value' : 'IR', 'label' : 'Iran, Islamic Republic of'},
            {'value' : 'IQ', 'label' : 'Iraq'},
            {'value' : 'IE', 'label' : 'Ireland'},
            {'value' : 'IM', 'label' : 'Isle of Man'},
            {'value' : 'IL', 'label' : 'Israel'},
            {'value' : 'IT', 'label' : 'Italy'},
            {'value' : 'JM', 'label' : 'Jamaica'},
            {'value' : 'JP', 'label' : 'Japan'},
            {'value' : 'JE', 'label' : 'Jersey'},
            {'value' : 'JO', 'label' : 'Jordan'},
            {'value' : 'KZ', 'label' : 'Kazakhstan'},
            {'value' : 'KE', 'label' : 'Kenya'},
            {'value' : 'KI', 'label' : 'Kiribati'},
            {'value' : 'KP', 'label' : 'Korea, Democratic People\'s Republic of'},
            {'value' : 'KR', 'label' : 'Korea, Republic of'},
            {'value' : 'KW', 'label' : 'Kuwait'},
            {'value' : 'KG', 'label' : 'Kyrgyzstan'},
            {'value' : 'LA', 'label' : 'Lao People\'s Democratic Republic'},
            {'value' : 'LV', 'label' : 'Latvia'},
            {'value' : 'LB', 'label' : 'Lebanon'},
            {'value' : 'LS', 'label' : 'Lesotho'},
            {'value' : 'LR', 'label' : 'Liberia'},
            {'value' : 'LY', 'label' : 'Libyan Arab Jamahiriya'},
            {'value' : 'LI', 'label' : 'Liechtenstein'},
            {'value' : 'LT', 'label' : 'Lithuania'},
            {'value' : 'LU', 'label' : 'Luxembourg'},
            {'value' : 'MO', 'label' : 'Macao'},
            {'value' : 'MK', 'label' : 'Macedonia, the former Yugoslav Republic of'},
            {'value' : 'MG', 'label' : 'Madagascar'},
            {'value' : 'MW', 'label' : 'Malawi'},
            {'value' : 'MY', 'label' : 'Malaysia'},
            {'value' : 'MV', 'label' : 'Maldives'},
            {'value' : 'ML', 'label' : 'Mali'},
            {'value' : 'MT', 'label' : 'Malta'},
            {'value' : 'MQ', 'label' : 'Martinique'},
            {'value' : 'MR', 'label' : 'Mauritania'},
            {'value' : 'MU', 'label' : 'Mauritius'},
            {'value' : 'YT', 'label' : 'Mayotte'},
            {'value' : 'MX', 'label' : 'Mexico'},
            {'value' : 'MD', 'label' : 'Moldova, Republic of'},
            {'value' : 'MC', 'label' : 'Monaco'},
            {'value' : 'MN', 'label' : 'Mongolia'},
            {'value' : 'ME', 'label' : 'Montenegro'},
            {'value' : 'MS', 'label' : 'Montserrat'},
            {'value' : 'MA', 'label' : 'Morocco'},
            {'value' : 'MZ', 'label' : 'Mozambique'},
            {'value' : 'MM', 'label' : 'Myanmar'},
            {'value' : 'NA', 'label' : 'Namibia'},
            {'value' : 'NR', 'label' : 'Nauru'},
            {'value' : 'NP', 'label' : 'Nepal'},
            {'value' : 'NL', 'label' : 'Netherlands'},
            {'value' : 'AN', 'label' : 'Netherlands Antilles'},
            {'value' : 'NC', 'label' : 'New Caledonia'},
            {'value' : 'NZ', 'label' : 'New Zealand'},
            {'value' : 'NI', 'label' : 'Nicaragua'},
            {'value' : 'NE', 'label' : 'Niger'},
            {'value' : 'NG', 'label' : 'Nigeria'},
            {'value' : 'NU', 'label' : 'Niue'},
            {'value' : 'NF', 'label' : 'Norfolk Island'},
            {'value' : 'NO', 'label' : 'Norway'},
            {'value' : 'OM', 'label' : 'Oman'},
            {'value' : 'PK', 'label' : 'Pakistan'},
            {'value' : 'PS', 'label' : 'Palestinian Territory, Occupied'},
            {'value' : 'PA', 'label' : 'Panama'},
            {'value' : 'PG', 'label' : 'Papua New Guinea'},
            {'value' : 'PY', 'label' : 'Paraguay'},
            {'value' : 'PE', 'label' : 'Peru'},
            {'value' : 'PH', 'label' : 'Philippines'},
            {'value' : 'PN', 'label' : 'Pitcairn'},
            {'value' : 'PL', 'label' : 'Poland'},
            {'value' : 'PT', 'label' : 'Portugal'},
            {'value' : 'PR', 'label' : 'Puerto Rico'},
            {'value' : 'QA', 'label' : 'Qatar'},
            {'value' : 'RE', 'label' : 'Reunion'},
            {'value' : 'RO', 'label' : 'Romania'},
            {'value' : 'RU', 'label' : 'Russian Federation'},
            {'value' : 'RW', 'label' : 'Rwanda'},
            {'value' : 'BL', 'label' : 'Saint Barthélemy'},
            {'value' : 'SH', 'label' : 'Saint Helena, Ascension and Tristan da Cunha'},
            {'value' : 'KN', 'label' : 'Saint Kitts and Nevis'},
            {'value' : 'LC', 'label' : 'Saint Lucia'},
            {'value' : 'MF', 'label' : 'Saint Martin (French part)'},
            {'value' : 'PM', 'label' : 'Saint Pierre and Miquelon'},
            {'value' : 'VC', 'label' : 'Saint Vincent and the Grenadines'},
            {'value' : 'WS', 'label' : 'Samoa'},
            {'value' : 'SM', 'label' : 'San Marino'},
            {'value' : 'ST', 'label' : 'Sao Tome and Principe'},
            {'value' : 'SA', 'label' : 'Saudi Arabia'},
            {'value' : 'SN', 'label' : 'Senegal'},
            {'value' : 'RS', 'label' : 'Serbia'},
            {'value' : 'CS', 'label' : 'Serbia and Montenegro'},
            {'value' : 'SC', 'label' : 'Seychelles'},
            {'value' : 'SL', 'label' : 'Sierra Leone'},
            {'value' : 'SG', 'label' : 'Singapore'},
            {'value' : 'SX', 'label' : 'Sint Maarten (Dutch part)'},
            {'value' : 'SK', 'label' : 'Slovakia'},
            {'value' : 'SI', 'label' : 'Slovenia'},
            {'value' : 'SB', 'label' : 'Solomon Islands'},
            {'value' : 'SO', 'label' : 'Somalia'},
            {'value' : 'ZA', 'label' : 'South Africa'},
            {'value' : 'GS', 'label' : 'South Georgia and the South Sandwich Islands'},
            {'value' : 'SS', 'label' : 'South Sudan'},
            {'value' : 'ES', 'label' : 'Spain'},
            {'value' : 'LK', 'label' : 'Sri Lanka'},
            {'value' : 'SD', 'label' : 'Sudan'},
            {'value' : 'SR', 'label' : 'Suriname'},
            {'value' : 'SJ', 'label' : 'Svalbard and Jan Mayen'},
            {'value' : 'SZ', 'label' : 'Swaziland'},
            {'value' : 'SE', 'label' : 'Sweden'},
            {'value' : 'CH', 'label' : 'Switzerland'},
            {'value' : 'SY', 'label' : 'Syrian Arab Republic'},
            {'value' : 'TJ', 'label' : 'Tajikistan'},
            {'value' : 'TZ', 'label' : 'Tanzania, United Republic of'},
            {'value' : 'TH', 'label' : 'Thailand'},
            {'value' : 'TL', 'label' : 'Timor-Leste'},
            {'value' : 'TG', 'label' : 'Togo'},
            {'value' : 'TK', 'label' : 'Tokelau'},
            {'value' : 'TO', 'label' : 'Tonga'},
            {'value' : 'TT', 'label' : 'Trinidad and Tobago'},
            {'value' : 'TN', 'label' : 'Tunisia'},
            {'value' : 'TR', 'label' : 'Turkey'},
            {'value' : 'TM', 'label' : 'Turkmenistan'},
            {'value' : 'TC', 'label' : 'Turks and Caicos Islands'},
            {'value' : 'TV', 'label' : 'Tuvalu'},
            {'value' : 'UG', 'label' : 'Uganda'},
            {'value' : 'UA', 'label' : 'Ukraine'},
            {'value' : 'AE', 'label' : 'United Arab Emirates'},
            {'value' : 'GB', 'label' : 'United Kingdom'},
            {'value' : 'US', 'label' : 'United States'},
            {'value' : 'UY', 'label' : 'Uruguay'},
            {'value' : 'UZ', 'label' : 'Uzbekistan'},
            {'value' : 'VU', 'label' : 'Vanuatu'},
            {'value' : 'VE', 'label' : 'Venezuela, Bolivarian Republic of'},
            {'value' : 'VN', 'label' : 'Viet Nam'},
            {'value' : 'VG', 'label' : 'Virgin Islands, British'},
            {'value' : 'VI', 'label' : 'Virgin Islands (U.S.)'},
            {'value' : 'WF', 'label' : 'Wallis and Futuna'},
            {'value' : 'EH', 'label' : 'Western Sahara'},
            {'value' : 'YE', 'label' : 'Yemen'},
            {'value' : 'ZM', 'label' : 'Zambia'},
            {'value' : 'ZW', 'label' : 'Zimbabwe'}
        ];
    }

    countryProvinceMap = {
        "US": [
            {'label': 'Alaska', 'value': 'Alaska'},
            {'label': 'Alabama', 'value': 'Alabama'},
            {'label': 'Arkansas', 'value': 'Arkansas'},
            {'label': 'Arizona', 'value': 'Arizona'},
            {'label': 'California', 'value': 'California'},
            {'label': 'Colorado', 'value': 'Colorado'},
            {'label': 'Connecticut', 'value': 'Connecticut'},
            {'label': 'District of Columbia', 'value': 'District of Columbia'},
            {'label': 'Delaware', 'value': 'Delaware'},
            {'label': 'Florida', 'value': 'Florida'},
            {'label': 'Georgia', 'value': 'Georgia'},
            {'label': 'Hawaii', 'value': 'Hawaii'},
            {'label': 'Iowa', 'value': 'Iowa'},
            {'label': 'Idaho', 'value': 'Idaho'},
            {'label': 'Illinois', 'value': 'Illinois'},
            {'label': 'Indiana', 'value': 'Indiana'},
            {'label': 'Kansas', 'value': 'Kansas'},
            {'label': 'Kentucky', 'value': 'Kentucky'},
            {'label': 'Louisiana', 'value': 'Louisiana'},
            {'label': 'Massachusetts', 'value': 'Massachusetts'},
            {'label': 'Maryland', 'value': 'Maryland'},
            {'label': 'Maine', 'value': 'Maine'},
            {'label': 'Michigan', 'value': 'Michigan'},
            {'label': 'Minnesota', 'value': 'Minnesota'},
            {'label': 'Missouri', 'value': 'Missouri'},
            {'label': 'Mississippi', 'value': 'Mississippi'},
            {'label': 'Montana', 'value': 'Montana'},
            {'label': 'North Carolina', 'value': 'North Carolina'},
            {'label': 'North Dakota', 'value': 'North Dakota'},
            {'label': 'Nebraska', 'value': 'Nebraska'},
            {'label': 'New Hampshire', 'value': 'New Hampshire'},
            {'label': 'New Jersey', 'value': 'New Jersey'},
            {'label': 'New Mexico', 'value': 'New Mexico'},
            {'label': 'Nevada', 'value': 'Nevada'},
            {'label': 'New York', 'value': 'New York'},
            {'label': 'Ohio', 'value': 'Ohio'},
            {'label': 'Oklahoma', 'value': 'Oklahoma'},
            {'label': 'Oregon', 'value': 'Oregon'},
            {'label': 'Pennsylvania', 'value': 'Pennsylvania'},
            {'label': 'Rhode Island', 'value': 'Rhode Island'},
            {'label': 'South Carolina', 'value': 'South Carolina'},
            {'label': 'South Dakota', 'value': 'South Dakota'},
            {'label': 'Tennessee', 'value': 'Tennessee'},
            {'label': 'Texas', 'value': 'Texas'},
            {'label': 'Utah', 'value': 'Utah'},
            {'label': 'Virginia', 'value': 'Virginia'},
            {'label': 'Vermont', 'value': 'Vermont'},
            {'label': 'Washington', 'value': 'Washington'},
            {'label': 'Wisconsin', 'value': 'Wisconsin'},
            {'label': 'West Virginia', 'value': 'West Virginia'},
            {'label': 'Wyoming', 'value': 'Wyoming'}
        ],
        CA: [
            {'label': 'Alberta', 'value': 'Alberta'},
            {'label': 'British Columbia', 'value': 'British Columbia'},
            {'label': 'Manitoba', 'value': 'Manitoba'},
            {'label': 'New Brunswick', 'value': 'New Brunswick'},
            {'label': 'Newfoundland and Labrador', 'value': 'Newfoundland and Labrador'},
            {'label': 'Nova Scotia', 'value': 'Nova Scotia'},
            {'label': 'Northwest Territories', 'value': 'Northwest Territories'},
            {'label': 'Nunavut', 'value': 'Nunavut'},
            {'label': 'Ontario', 'value': 'Ontario'},
            {'label': 'Prince Edward Island', 'value': 'Prince Edward Island'},
            {'label': 'Quebec', 'value': 'Quebec'},
            {'label': 'Saskatchewan', 'value': 'Saskatchewan'},
            {'label': 'Yukon Territories', 'value': 'Yukon Territories'}
        ]
    };
}