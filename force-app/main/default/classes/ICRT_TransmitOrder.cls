public class ICRT_TransmitOrder {
    /**
     *   {Purpose}  �  TODO:  Provide Purpose
     *
     *   {Contact}   - support@demandchainsystems.com
     *                 www.demandchainsystems.com
     *                 612-424-0032
     */

    /**
     *   CHANGE  HISTORY
     *   =============================================================================
     *   Date        Name                    Description
     *   20180223    Andy Boettcher DCS      Created
     *   20180328    Andy Boettcher DCS      Kelly and Andy updating the JSON structure to send both BILL and SHIP sites
     *	20200220	Esau Sanchez Ergotron	JSON updated to include new fields and updating the BILL-TO if it is a credit card order
     *										All these as part of the B2B Commerce implementation.
     *   20210728    Esau Sanchez Ergotron   Added Price__c and Calculate_Price__c to sales order lines query to be included in JSON
     *   20250707    Esau Sanchez Ergotron   Removed the logic to update the BILL-TO site if it is a credit card order, now it is always updated.
     *   =============================================================================
     */

    ///////////////////////////
    // Action Methods
    ///////////////////////////
    @Future(callout=true)
    public static void singleIdToSubmitOrderToICRT(Id oId) {
        List<Id> lstOrderIds = new List<Id>();
        lstOrderIds.add(oId);
        submitOrderToICRT(lstOrderIds);
    }
    @InvocableMethod(
        label='Submit Sales Order to Oracle'
        description='Submits a Sales Order, Lines, Party/Customer/Site to Oracle via ICRT CreateOrder-JSON-WEB'
    )
    public static void submitOrderToICRT(List<Id> lstOrderIds) {
        ICRT_TransmitOrder.hClsTransmitOrder objTransmitOrder = new ICRT_TransmitOrder.hClsTransmitOrder();
        ICRT_TransmitOrder.hClsOrder objOrderInner = new ICRT_TransmitOrder.hClsOrder();

        // Query for the SALES ORDER to be included in the JSON structure - do not have any relationship fields, only do formula fields if needed.
        Sales_Order__c objOrder = [
            SELECT
                Id,
                Bill_To_Party_Id__c,
                Bill_To_Customer_Account_Id__c,
                Bill_To_Customer__c,
                Ship_To_Party_Id__c,
                Ship_To_Customer_Account_Id__c,
                Ship_To_Customer__c,
                Customer_PO_Number__c,
                Ship_To_Contact__c,
                Order_type__c,
                Order_Type_Id__c,
                Line_Count__c,
                Notes__c,
                Oracle_Salesrep_Id__c,
                Seed_Location_Type__c,
                Seed_Price_List__c,
                Next_Day_Business__c,
                Ship_To_Contact_Role_Id__c,
                Cust_Delivery_Info__c,
                Credit_Card_Approval_Code__c,
                Shipping_Method_Code__c,
                Freight_Carrier_Account_Number__c
            FROM Sales_Order__c
            WHERE Id = :lstOrderIds[0]
            LIMIT 1
        ];

        // Query for the SALES ORDER LINES to be included in the JSON structure - do not have any relationship fields, only do formula fields if needed.
        List<Sales_Order_Line__c> lstLines = [
            SELECT
                Id,
                Inventory_Item_Id__c,
                Product_Code__c,
                Quantity__c,
                Return_Reason_Code__c,
                Sales_Order__c,
                Scheduled_Ship_Date__c,
                Warehouse__c,
                TRF_Reason__c,
                Price__c,
                Calculate_Price__c
            FROM Sales_Order_Line__c
            WHERE Sales_Order__c = :lstOrderIds[0]
        ];

        objOrderInner.orderHeader = objOrder;
        objOrderInner.orderLines = lstLines;

        //Bill to customer

        List<Account> lstBillToParty = [
            SELECT Id, Oracle_Party_Id__c, Oracle_Party_Number__c, Name
            FROM Account
            WHERE Id = :objOrder.Bill_To_Party_Id__c
            LIMIT 1
        ];
        if (!lstBillToParty.isEmpty()) {
            objOrderInner.accountPartyBillTo = lstBillToParty[0];
        }

        List<Account> lstBillToCustomer = [
            SELECT Id, Oracle_Customer_Account_Id__c, Name
            FROM Account
            WHERE Id = :objOrder.Bill_To_Customer_Account_Id__c
            LIMIT 1
        ];
        if (!lstBillToCustomer.isEmpty()) {
            objOrderInner.accountCustomerBillTo = lstBillToCustomer[0];
        }

        List<Account> lstBillToSite = [
            SELECT
                Id,
                Oracle_Site_Id__c,
                Oracle_SiteBillToUseId__c,
                Name,
                Oracle_Address_1__c,
                Oracle_Address_2__c,
                Oracle_Address_3__c,
                Oracle_Address_4__c,
                Oracle_City__c,
                Oracle_State__c,
                Oracle_Postal_Code__c,
                Oracle_Country__c,
                County__c,
                Region__c,
                Payment_Terms__c
            FROM Account
            WHERE Id = :objOrder.Bill_To_Customer__c
            LIMIT 1
        ];

        if (!lstBillToSite.isEmpty()) {
            // Added 20190708 AAB - Adding County check logic against Vertex data
            //
            if (lstBillToSite[0].Oracle_Country__c == 'US' || lstBillToSite[0].Oracle_Country__c == 'CA') {
                List<Postal_Code__c> lstPostalCodeBill = [
                    SELECT Id, County__c, City__c
                    FROM Postal_Code__c
                    WHERE From_Postal_Code__c <= :lstBillToSite[0].Oracle_Postal_Code__c AND To_Postal_Code__c >= :lstBillToSite[0].Oracle_Postal_Code__c
                ];

                if (!lstPostalCodeBill.isEmpty()) {
                    // Rules - loop through the postal code list and look for the county first, if the county is found in the range, keep it.  If not, take the first in the list.

                    Boolean bolFoundCounty = false;
                    for (Postal_Code__c objPC : lstPostalCodeBill) {
                        if (lstBillToSite[0].County__c == objPC.County__c) {
                            bolFoundCounty = true;
                        }
                    }

                    if (!bolFoundCounty) {
                        lstBillToSite[0].County__c = lstPostalCodeBill[0].County__c;
                    }
                }
            }
            objOrderInner.accountSiteBillTo = lstBillToSite[0];
        }

        //Ship to customer
        List<Account> lstShipToParty = [
            SELECT Id, Oracle_Party_Id__c, Oracle_Party_Number__c, Name
            FROM Account
            WHERE Id = :objOrder.Ship_To_Party_Id__c
            LIMIT 1
        ];
        if (!lstShipToParty.isEmpty()) {
            objOrderInner.accountPartyShipTo = lstShipToParty[0];
        }

        List<Account> lstShipToCustomer = [
            SELECT Id, Oracle_Customer_Account_Id__c, Name
            FROM Account
            WHERE Id = :objOrder.Ship_To_Customer_Account_Id__c
            LIMIT 1
        ];
        if (!lstShipToCustomer.isEmpty()) {
            objOrderInner.accountCustomerShipTo = lstShipToCustomer[0];
        }

        // SHIP TO SITE
        List<Account> lstShipToSite = [
            SELECT
                Id,
                Oracle_Site_Id__c,
                Oracle_SiteShipToUseId__c,
                Name,
                Oracle_Address_1__c,
                Oracle_Address_2__c,
                Oracle_Address_3__c,
                Oracle_Address_4__c,
                Oracle_City__c,
                Oracle_State__c,
                Oracle_Postal_Code__c,
                Oracle_Country__c,
                County__c,
                Region__c
            FROM Account
            WHERE Id = :objOrder.Ship_To_Customer__c
            LIMIT 1
        ];

        System.debug('DEBUG - ICRT ORDER SHIP TO - ' + JSON.serialize(lstShipToSite));

        if (!lstShipToSite.isEmpty()) {
            // Added 20190708 AAB - Adding County check logic against Vertex data
            if (
                (lstShipToSite[0].Oracle_Country__c == 'US' || lstShipToSite[0].Oracle_Country__c == 'CA') &&
                objOrder.Order_Type__c != 'ECOMMERCE GENERAL ORDER'
            ) {
                List<Postal_Code__c> lstPostalCodeShip = [
                    SELECT Id, County__c, City__c
                    FROM Postal_Code__c
                    WHERE From_Postal_Code__c <= :lstShipToSite[0].Oracle_Postal_Code__c AND To_Postal_Code__c >= :lstShipToSite[0].Oracle_Postal_Code__c
                ];

                System.debug('DEBUG - ICRT ORDER SHIP TO VERTEX LOOKUP - ' + JSON.serialize(lstPostalCodeShip));

                if (!lstPostalCodeShip.isEmpty()) {
                    // Rules - loop through the postal code list and look for the county first, if the county is found in the range, keep it.  If not, take the first in the list.

                    Boolean bolFoundCounty = false;
                    for (Postal_Code__c objPC : lstPostalCodeShip) {
                        System.debug('DOES ' + lstShipToSite[0].County__c + ' = ' + objPC.County__c + '?');
                        if (lstShipToSite[0].County__c == objPC.County__c) {
                            bolFoundCounty = true;
                        }
                    }

                    if (!bolFoundCounty) {
                        lstShipToSite[0].County__c = lstPostalCodeShip[0].County__c;
                    }
                }
            }
            objOrderInner.accountSiteShipTo = lstShipToSite[0];
        }

        //Contact
        List<Contact> lstSTContact = [
            SELECT Id, Oracle_Contact_Id__c, FirstName, LastName, Email, Phone, MobilePhone
            FROM Contact
            WHERE Id = :objOrder.Ship_To_Contact__c
            LIMIT 1
        ];
        if (!lstSTContact.isEmpty()) {
            //Phone number selection.
            if (lstSTContact[0].Phone == null && lstSTContact[0].MobilePhone != null) {
                lstSTContact[0].Phone = lstSTContact[0].MobilePhone;
            }
            objOrderInner.accountContact = lstSTContact[0];
            // Pushing this through from the Sales Order Header object
            List<AccountContactRelation> lstACR = [
                SELECT Contact_Role_Id__c
                FROM AccountContactRelation
                WHERE AccountId = :objOrder.Ship_To_Customer__c AND ContactId = :lstSTContact[0].Id
            ];

            if (!lstACR.isEmpty()) {
                objOrderInner.accountContact.Oracle_Contact_Role_Id__c = lstACR[0].Contact_Role_Id__c;
            }
        }

        objTransmitOrder.orders.add(objOrderInner);

        System.Debug(JSON.serializePretty(objTransmitOrder));

        // Commented out 20180509 AAB/DCS - replaced with Custom Setting "Web Service Details"
        Informatica_CallOut__mdt ic = [SELECT Id, MasterLabel, Callout_URL__c FROM Informatica_CallOut__mdt WHERE MasterLabel = 'ICRT CreateOrder' LIMIT 1];
        //String strEndpoint = 'https://ps1w2.rt.informaticacloud.com/active-bpel/public/rt/000RPJ/CreateOrder-JSON-WEB';
        //Web_Service_Details__c oWebServiceDetails = [select Endpoint__c, Exception_Email__c from Web_Service_Details__c where Name = 'ICRT_CreateOrder_JSON'];
        String strEndpoint = ic.Callout_URL__c;

        HttpRequest objRequest = new HttpRequest();
        objRequest.setEndpoint(strEndpoint);
        objRequest.setMethod('POST');
        objRequest.setTimeout(60000);
        objRequest.setHeader('Content-Type', 'application/json');
        objRequest.setBody(JSON.serialize(objTransmitOrder));

        Http objHttp = new Http();
        HttpResponse objResponse = objHttp.send(objRequest);

        System.Debug('REQUEST: ' + objRequest);
        System.Debug('RESPONSE BODY: ' + objResponse.getBody());
        System.Debug('RESPONSE STATUS: ' + objResponse.getStatus());
        System.Debug('RESPONSE STATUS_CODE: ' + objResponse.getStatusCode());

        if (objResponse.getStatusCode() == 500) {
            System.debug('ICRT_TransmitOrder.submitOrderToICRT ERROR ON ICRT - ' + objResponse.getBody());

            // UPDATE ORDER FOR SUBMISSION DATE
            Sales_Order__c objSOUpdate = new Sales_Order__c(Id = objOrder.Id, Oracle_Interface_Message__c = objResponse.getBody());

            update objSOUpdate;

            return;
        }

        String strJSONResp = objResponse.getBody();
        HelperOracleOrderReturn hoor = new HelperOracleOrderReturn();
        hoor = HelperOracleOrderReturn.parse(strJSONResp);
        System.debug('hoor.Return_cust_results.BILLTO_ADDRESS_INFO_REF : ' + hoor.Return_cust_results.BILLTO_ADDRESS_INFO_REF);
        System.debug('hoor.BILL_TO_SITE_ID : ' + hoor.Return_cust_results.BILL_TO_SITE_ID);
        System.debug('hoor.BILL_TO_SITE_ID : ' + hoor.Return_cust_results.BILL_TO_SITE_ID);
        System.debug('hoor.SHIP_TO_USE_ID : ' + hoor.Return_cust_results.SHIP_TO_USE_ID);
        System.debug('hoor.SHIPTO_ADDRESS_INFO_REF : ' + hoor.Return_cust_results.SHIPTO_ADDRESS_INFO_REF);
        System.debug('hoor.CONTACT_INFO_REF : ' + hoor.Return_cust_results.CONTACT_INFO_REF);
        System.debug('hoor.CONTACT_ROLE_ID : ' + hoor.Return_cust_results.CONTACT_ROLE_ID);
        System.debug('hoor.CONTACT_ID : ' + hoor.Return_cust_results.CONTACT_ID);

        try {
            Map<Id, boolean> idUpdateMap = new Map<Id, boolean>();
            idUpdateMap.put(hoor.Return_cust_results.SHIPTO_ADDRESS_INFO_REF, false);
            idUpdateMap.put(hoor.Return_cust_results.BILLTO_ADDRESS_INFO_REF, false);
            idUpdateMap.put(hoor.Return_cust_results.BILLTO_PARTY_INFO_REF, false);
            idUpdateMap.put(hoor.Return_cust_results.SHIPTO_PARTY_INFO_REF, false);
            idUpdateMap.put(hoor.Return_cust_results.BILLTO_CUSTOMER_INFO_REF, false);
            idUpdateMap.put(hoor.Return_cust_results.SHIPTO_CUSTOMER_INFO_REF, false);

            Map<Id, Account> accountMap = new Map<Id, Account>(
                [
                    SELECT Id, Oracle_Party_Id__c, Oracle_Customer_Account_Id__c, Oracle_Site_Id__c, Oracle_SiteBillToUseId__c, Oracle_SiteShipToUseId__c
                    FROM Account
                    WHERE Id IN :idUpdateMap.keySet()
                ]
            );

            //shipping account update
            Id shippingAccountId = hoor.Return_cust_results.SHIPTO_ADDRESS_INFO_REF;
            if (accountMap.get(shippingAccountId).Oracle_Site_Id__c == null && hoor.return_cust_results.SHIP_TO_SITE_ID != null) {
                accountMap.get(shippingAccountId).Oracle_Site_Id__c = hoor.return_cust_results.SHIP_TO_SITE_ID;
                idUpdateMap.put(shippingAccountId, true);
            }

            //shipping customer account update
            Id shippingCustomerAccountId = hoor.Return_cust_results.SHIPTO_CUSTOMER_INFO_REF;
            if (accountMap.get(shippingCustomerAccountId).Oracle_Customer_Account_Id__c == null && hoor.return_cust_results.SHIPTO_CUSTOMER_ID != null) {
                accountMap.get(shippingCustomerAccountId).Oracle_Customer_Account_Id__c = hoor.return_cust_results.SHIPTO_CUSTOMER_ID;
                idUpdateMap.put(shippingCustomerAccountId, true);
            }

            //shipping party account update
            Id shippingPartyAccountId = hoor.Return_cust_results.SHIPTO_PARTY_INFO_REF;
            if (accountMap.get(shippingPartyAccountId).Oracle_Party_Id__c == null && hoor.return_cust_results.SHIPTO_PARTY_ID != null) {
                accountMap.get(shippingPartyAccountId).Oracle_Party_Id__c = hoor.return_cust_results.SHIPTO_PARTY_ID;
                idUpdateMap.put(shippingPartyAccountId, true);
            }

            //only if billing is different
            if (hoor.Return_cust_results.SHIPTO_ADDRESS_INFO_REF != hoor.Return_cust_results.BILLTO_ADDRESS_INFO_REF) {
                //billing account update
                Id billingAccountId = hoor.Return_cust_results.BILLTO_ADDRESS_INFO_REF;
                if (accountMap.get(billingAccountId).Oracle_Site_Id__c == null && hoor.return_cust_results.BILL_TO_SITE_ID != null) {
                    accountMap.get(billingAccountId).Oracle_Site_Id__c = hoor.return_cust_results.BILL_TO_SITE_ID;
                    idUpdateMap.put(billingAccountId, true);
                }

                //billing customer account update
                Id billingCustomerAccountId = hoor.Return_cust_results.BILLTO_CUSTOMER_INFO_REF;
                if (accountMap.get(billingCustomerAccountId).Oracle_Customer_Account_Id__c == null && hoor.return_cust_results.BILLTO_CUSTOMER_ID != null) {
                    accountMap.get(billingCustomerAccountId).Oracle_Customer_Account_Id__c = hoor.return_cust_results.BILLTO_CUSTOMER_ID;
                    idUpdateMap.put(billingCustomerAccountId, true);
                }

                //billing party account update
                Id billingPartyAccountId = hoor.Return_cust_results.BILLTO_PARTY_INFO_REF;
                if (accountMap.get(billingPartyAccountId).Oracle_Party_Id__c == null && hoor.return_cust_results.BILLTO_PARTY_ID != null) {
                    accountMap.get(billingPartyAccountId).Oracle_Party_Id__c = hoor.return_cust_results.BILLTO_PARTY_ID;
                    idUpdateMap.put(billingPartyAccountId, true);
                }
            }

            //if an update was made put it in a list so we can perform the dml
            List<Account> lstUpdateAcct = new List<Account>();
            for (id key : idUpdateMap.keySet()) {
                if (idUpdateMap.get(key)) {
                    lstUpdateAcct.add(accountMap.get(key));
                }
            }

            if (!lstUpdateAcct.isEmpty()) {
                update lstUpdateAcct;
            }
        } catch (Exception ex) {
            System.debug('ICRT_TransmitOrder.submitOrderToICRT ERROR:  UPDATING ACCOUNTS ON ICRT RESPONSE - ' + ex.getMessage());
        }

        // Update BILL TO SITE AND BILL TO SITE USE ID
        try {
            Contact c = new Contact();
            c.Id = hoor.Return_cust_results.CONTACT_INFO_REF;
            c.Oracle_Contact_Role_Id__c = hoor.Return_cust_results.CONTACT_ROLE_ID;
            c.Oracle_Contact_Id__c = hoor.Return_cust_results.CONTACT_ID;
            c.Oracle_Party_Id__c = hoor.Return_cust_results.SHIPTO_PARTY_ID;
            c.Oracle_Account_Id__c = hoor.Return_cust_results.SHIPTO_CUSTOMER_ID;
            update c;
        } catch (Exception ex) {
            System.debug('ICRT_TransmitOrder.submitOrderToICRT ERROR:  UPDATING CONTACT ON ICRT RESPONSE - ' + ex.getMessage());
        }

        // UPDATE ORDER FOR SUBMISSION DATE
        Sales_Order__c objSOUpdate = new Sales_Order__c(Id = objOrder.Id, Order_Submitted__c = true, Date_Time_Submitted__c = System.Now());

        update objSOUpdate;
    }

    ///////////////////////////
    // Inner/Helper Classes
    ///////////////////////////
    private class hClsOrder {
        public Sales_Order__c orderHeader { get; set; }
        public List<Sales_Order_Line__c> orderLines { get; set; }
        public Account accountPartyBillTo { get; set; }
        public Account accountCustomerBillTo { get; set; }
        public Account accountSiteBillTo { get; set; }
        public Account accountPartyShipTo { get; set; }
        public Account accountCustomerShipTo { get; set; }
        public Account accountSiteShipTo { get; set; }
        public Contact accountContact { get; set; }

        private hClsOrder() {
            orderLines = new List<Sales_Order_Line__c>();
        }
    }

    private class hClsTransmitOrder {
        public List<hClsOrder> orders { get; set; }

        public hClsTransmitOrder() {
            orders = new List<hClsOrder>();
        }
    }
}