public without sharing class CaseService {
    /* This method creates Service Appointment Bundle, Bundle Members and update WO status */
    public static void createServiceAppointments(List<Case> newList) {
        System.debug('----------CaseService.createServiceAppointments----------');
        System.debug('----newList-----' + newList);

        final String WO_STATUS_TO_EXCLUDE = WorkOrder_Setting__mdt.getInstance('StatusToExclude').textValue__c;
        final String WO_TYPE_TO_INCLUDE = WorkOrder_Setting__mdt.getInstance('WokrOrderTypeToInclude').textValue__c;
        final String WO_STATUS = WorkOrder_Setting__mdt.getInstance('WOStatusToset').textValue__c;
        final Integer DUE_DATE_DAYS = Integer.valueof(WorkOrder_Setting__mdt.getInstance('SADueDatePeriodInDay').textValue__c);
        final Double SA_LATITUDE = Double.valueof(WorkOrder_Setting__mdt.getInstance('SALatitude').textValue__c);
        final Double SA_LONGITUDE = Double.valueof(WorkOrder_Setting__mdt.getInstance('SALongitude').textValue__c);

        List<String> woStatusToExcludeList = WO_STATUS_TO_EXCLUDE.split(',');
        List<String> woTypeToIncludeList = WO_TYPE_TO_INCLUDE.split(',');

        System.debug('WO_STATUS_TO_EXCLUDE--->' + WO_STATUS_TO_EXCLUDE);
        System.debug('WO_TYPE_TO_INCLUDE--->' + WO_TYPE_TO_INCLUDE);

        Map<Id, List<WorkOrder>> caseIdAndWOListMap = new Map<Id, List<WorkOrder>>();
        List<WorkOrder> woList = [
            SELECT Id, AssetId, CaseId
            FROM WorkOrder
            WHERE CaseId IN :newList AND Status NOT IN :woStatusToExcludeList AND Work_Order_Type__c IN :woTypeToIncludeList
        ];

        for (WorkOrder wo : woList) {
            if (caseIdAndWOListMap.get(wo.CaseId) == null) {
                caseIdAndWOListMap.put(wo.CaseId, new List<WorkOrder>());
            }
            caseIdAndWOListMap.get(wo.CaseId).add(wo);
        }

        Map<Id, ServiceAppointment> caseIdAndBundleAppointments = new Map<Id, ServiceAppointment>();
        for (Case caseObj : newList) {
            ServiceAppointment bundleAppointment = new ServiceAppointment();
            bundleAppointment.Case_Number__c = caseObj.Id;
            bundleAppointment.ContactId = caseObj.ContactId;
            bundleAppointment.DueDate = System.now() + DUE_DATE_DAYS;
            bundleAppointment.ETA__c = caseObj.ETA__c;
            bundleAppointment.EarliestStartTime = System.now();
            bundleAppointment.FSL__GanttLabel__c = caseObj.Account_Name__c;
            bundleAppointment.FSL__InternalSLRGeolocation__Latitude__s = SA_LATITUDE;
            bundleAppointment.FSL__InternalSLRGeolocation__Longitude__s = SA_LONGITUDE;
            bundleAppointment.Field_Tech__c = caseObj.Field_Tech__c;
            bundleAppointment.Instructions__c = caseObj.Instructions__c;
            bundleAppointment.Tracking__c = caseobj.Tracking_Number_s__c;
            bundleAppointment.OwnerId = caseObj.Field_Tech__c;
            bundleAppointment.ParentRecordId = caseObj.AccountId;
            //bundleAppointment.Service_Address__c = caseObj.Ship_To_Address__c;
            bundleAppointment.Status = 'None';
            bundleAppointment.IsBundle = true;
            caseIdAndBundleAppointments.put(caseObj.Id, bundleAppointment);
        }

        /* Insert Bundle Appointment */
        //system.Assert(false, caseIdAndBundleAppointments.values());
        if (!caseIdAndBundleAppointments.values().isEmpty()) {
            System.debug('caseIdAndBundleAppointments.values()--->' + caseIdAndBundleAppointments.values().size());
            insert caseIdAndBundleAppointments.values();
        }

        List<ServiceAppointment> bundleMemberAppointments = new List<ServiceAppointment>();
        for (Case caseObj : newList) {
            for (WorkOrder woObj : caseIdAndWOListMap.get(caseObj.Id)) {
                ServiceAppointment memberSA = new ServiceAppointment();
                //memberSA.Case_Number__c = caseObj.Id;
                //memberSA.AccountId = woObj.AccountId;
                memberSA.ContactId = caseObj.ContactId;
                memberSA.DueDate = System.now() + DUE_DATE_DAYS;
                memberSA.ETA__c = caseObj.ETA__c;
                memberSA.EarliestStartTime = System.now();
                memberSA.FSL__GanttLabel__c = caseObj.Account_Name__c;
                memberSA.FSL__InternalSLRGeolocation__Latitude__s = SA_LATITUDE;
                memberSA.FSL__InternalSLRGeolocation__Longitude__s = SA_LONGITUDE;
                memberSA.Field_Tech__c = caseObj.Field_Tech__c;
                memberSA.Instructions__c = caseObj.Instructions__c;
                memberSA.Tracking__c = caseobj.Tracking_Number_s__c;
                memberSA.OwnerId = caseObj.Field_Tech__c;
                memberSA.Status = 'None';
                //memberSA.Service_Address__c = caseObj.Ship_To_Address__c;
                memberSA.IsBundleMember = true;
                memberSA.IsManuallyBundled = true;
                memberSA.RelatedBundleId = caseIdAndBundleAppointments.get(caseObj.Id).Id;
                memberSA.ParentRecordId = woObj.Id;
                memberSA.Asset__c = woObj.AssetId;
                memberSA.Work_Order__c = woObj.Id;

                bundleMemberAppointments.add(memberSA);
                woObj.status = WO_STATUS;
            }
        }

        /* Insert Bundle Members */
        if (!bundleMemberAppointments.isEmpty()) {
            insert bundleMemberAppointments;
        }

        /* Update status of WOs */
        if (!woList.isEmpty()) {
            AsyncWorkOrder asyncWOJob = new AsyncWorkOrder();
            asyncWOJob.woList = woList;
            System.enqueueJob(asyncWOJob);
        }
    }
}