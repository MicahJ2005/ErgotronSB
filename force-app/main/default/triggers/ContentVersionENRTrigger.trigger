/**
 * ContentVersionENRTrigger
 *
 * Fires when a ContentVersion is inserted (i.e. a note body is saved).
 * Salesforce creates a new ContentVersion for every save of a ContentNote,
 * but does NOT reliably fire a ContentDocument after-update trigger for
 * body changes — so this trigger is the authoritative hook for syncing
 * Note_Preview__c on related Enhanced_Note_Reporting__c records.
 */
trigger ContentVersionENRTrigger on ContentVersion (after insert) {
    EnhancedNoteReportingHandler.handleVersionInsert(Trigger.new);
}
