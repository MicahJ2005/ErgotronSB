/*
    Class used to store SmartyStreets API response variables

    MOD DATE        Who                     Description
    10/21/2014      Chris Noe               Initial Release
*/

public class SmartyStreets_Validation_Response {
	public class Analysis {
		public String dpv_match_code {set; get;}
		public String dpv_footnotes {set; get;}
		public String dpv_cmra {set; get;}
		public String dpv_vacant {set; get;}
		public String active {set; get;}
		public String ews_match {set; get;}
		public String footnotes {set; get;}
		public String lacslink_code {set; get;}
		public String lacslink_indicator {set; get;}
		public String suitelink_match {set; get;}
	}

	public String input_id {set; get;}
	public Integer input_index {set; get;}
	public Integer candidate_index {set; get;}
	public String addressee {set; get;}
	public String delivery_line_1 {set; get;}
	public String delivery_line_2 {set; get;}
	public String last_line {set; get;}
	public String delivery_point_barcode {set; get;}
	public Components components {set; get;}
	public Metadata metadata {set; get;}
	public Analysis analysis {set; get;}
	public String sFormattedAddress1 {set;get;}
	public String sFormattedAddress2 {set;get;}
	public String sFormattedCityStateZip {set;get;}

	public class Components {
		public String urbanization {set; get;}
		public String primary_number {set; get;}
		public String street_name {set; get;}
		public String street_predirection {set; get;}
		public String street_postdirection {set; get;}
		public String street_suffix {set; get;}
		public String secondary_number {set; get;}
		public String secondary_designator {set; get;}
		public String extra_secondary_number {set; get;}
		public String extra_secondary_designator {set; get;}
		public String pmb_designator {set; get;}
		public String pmb_number {set; get;}
		public String city_name {set; get;}
		public String default_city_name {set; get;}
		public String state_abbreviation {set; get;}
		public String zipcode {set; get;}
		public String plus4_code {set; get;}
		public String delivery_point {set; get;}
		public String delivery_point_check_digit {set; get;}
	}

	public class Metadata {
		public String record_type {set; get;}
		public String zip_type {set; get;}
		public String county_fips {set; get;}
		public String county_name {set; get;}
		public String carrier_route {set; get;}
		public String congressional_district {set; get;}
		public String building_default_indicator {set; get;}
		public String rdi {set; get;}
		public String elot_sequence {set; get;}
		public String elot_sort {set; get;}
		public Double latitude {set; get;}
		public Double longitude {set; get;}
		public String precision {set; get;}
		public String time_zone {set; get;}
		public Double utc_offset {set; get;}
		public String dst {set; get;}
	}
}