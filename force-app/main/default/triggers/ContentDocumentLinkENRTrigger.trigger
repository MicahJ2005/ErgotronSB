/**
 * ContentDocumentLinkENRTrigger
 *
 * Fires when a ContentDocumentLink is created or deleted.
 * A ContentDocumentLink represents a note (or file) being linked
 * to a parent record — so insert = note attached, delete = note detached.
 *
 * Supported parent objects: Contact, Lead, Opportunity
 */
trigger ContentDocumentLinkENRTrigger on ContentDocumentLink (after insert, after delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            EnhancedNoteReportingHandler.handleCDLInsert(Trigger.new);
        } else if (Trigger.isDelete) {
            EnhancedNoteReportingHandler.handleCDLDelete(Trigger.old);
        }
    }
}