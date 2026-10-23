/**
 * @description Invocable action to generate a CSV of Salesforce Notes (SNOTE) attached to Opportunities
 *              whose RecordType.DeveloperName = 'Sales_Development', based on the provided SOQL.
 *              The CSV is saved as a ContentVersion in the specified Salesforce Library (ContentWorkspace)
 *              by DeveloperName, or as a private file if the library is not found.
 *
 * Rules implemented:
 * - Invocable Apex for Flow
 * - with sharing to respect org sharing
 * - SOQL with WITH SECURITY_ENFORCED and DB USER_MODE for DML
 * - Database methods with error handling
 * - Return-early pattern
 * - Enums instead of string constants
 * - Bulk-safe (processes one Request per invocation, but the logic avoids per-record DML/SOQL in loops)
 * - No hardcoded IDs
 * - ApexDocs style comments
 */
public with sharing class ContentSnoteCsvExporter {
    /**
     * @description Supported file types for ContentVersion. Using enum instead of string constant.
     */
    public enum FILE_TYPE { SNOTE }

    /**
     * @description Input for the invocable action.
     */
    public class Request {
        @InvocableVariable(required=true)
        public String targetLibraryDeveloperName; // Example: 'SalesDevOpsNotes'

        @InvocableVariable(required=false)
        public String fileNamePrefix; // Default applied if null: 'Sales_Dev_SNotes'
    }

    /**
     * @description Output for the invocable action.
     */
    public class Result {
        @InvocableVariable
        public Id contentVersionId;

        @InvocableVariable
        public Id contentDocumentId;

        @InvocableVariable
        public String fileName;

        @InvocableVariable
        public String statusMessage;
    }

    /**
     * @description Public invocable method to be used by Flow (including scheduled flows).
     */
    @InvocableMethod(label='Generate Sales Dev SNOTE CSV' description='Generates a CSV of SNOTE files linked to Sales_Development Opportunities and stores it in the specified Salesforce Library')
    public static List<Result> export(List<Request> requests) {
        List<Result> results = new List<Result>();
        if (requests == null || requests.isEmpty()) {
            Result r = new Result();
            r.statusMessage = 'No request provided.';
            results.add(r);
            return results;
        }

        // Per-invocation we only act on the first request as a single CSV output is expected
        Request req = requests[0];
        if (req == null) {
            Result r = new Result();
            r.statusMessage = 'Request is null.';
            results.add(r);
            return results;
        }

        String libraryDeveloperName = req.targetLibraryDeveloperName;
        String filePrefix = String.isBlank(req.fileNamePrefix) ? 'Sales_Dev_SNotes' : req.fileNamePrefix;

        Result result = new Result();

        try {
            // Resolve target library (ContentWorkspace) by DeveloperName
            Id workspaceId = resolveWorkspaceId(libraryDeveloperName);

            // Run the SOQL with TYPEOF and security enforced
            List<ContentRow> rows = querySnoteRows();

            // Build CSV
            String fileName = filePrefix + '_' + formatNowUTC('yyyy-MM-dd_HHmmss') + '.csv';
            String csv = buildCsv(rows);

            // Insert ContentVersion in USER_MODE
            Id contentVersionId = insertCsvAsContentVersion(csv, fileName);

            // Resolve ContentDocumentId from inserted ContentVersion
            Id contentDocumentId = fetchContentDocumentId(contentVersionId);

            // If we found a workspace, add the document to the library
            if (workspaceId != null && contentDocumentId != null) {
                linkDocumentToWorkspace(workspaceId, contentDocumentId);
            }

            result.contentVersionId = contentVersionId;
            result.contentDocumentId = contentDocumentId;
            result.fileName = fileName;
            result.statusMessage = 'CSV generated successfully' + (workspaceId == null ? ' (Library not found, saved as private file).' : ' and stored in library.');
        } catch (Exception e) {
            result.statusMessage = 'Error generating CSV: ' + e.getMessage();
        }

        results.add(result);
        return results;
    }

    /**
     * @description Row DTO for CSV creation.
     */
    private class ContentRow {
        // Opportunity fields (from TYPEOF)
        String oppOwnerName;
        String oppAccountName;
        String oppName;
        String oppStageName;
        Date oppCloseDate;
        Datetime oppCreatedDate;

        // Content fields
        Id contentDocumentId;
        String contentTitle;
        Id latestVersionId;
        String textPreview;
        Datetime versionCreatedDate;
        String versionOwnerName;
    }

    /**
     * @description Query ContentDocumentLink with the provided TYPEOF query and security enforced.
     */
    private static List<ContentRow> querySnoteRows() {
        List<ContentRow> rows = new List<ContentRow>();

        // Query using WITH SECURITY_ENFORCED to respect field-level and object-level security.
        // Note: TYPEOF is supported in SOQL. We alias fields by mapping to our DTO.
        for (ContentDocumentLink cdl : [
            SELECT
                TYPEOF LinkedEntity WHEN Opportunity THEN
                    Owner.Name,
                    Account.Name,
                    Name,
                    StageName,
                    CloseDate,
                    CreatedDate
                END,
                ContentDocumentId,
                ContentDocument.Title,
                ContentDocument.LatestPublishedVersion.Id,
                ContentDocument.LatestPublishedVersion.TextPreview,
                ContentDocument.LatestPublishedVersion.CreatedDate,
                ContentDocument.LatestPublishedVersion.Owner.Name
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN (
                SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'Sales_Development'
            )
            AND ContentDocument.LatestPublishedVersion.FileType = :String.valueOf(FILE_TYPE.SNOTE)
            AND ContentDocument.LatestPublishedVersion.Owner.User_Region__c = 'Americas'
            WITH SECURITY_ENFORCED
            ORDER BY ContentDocument.LatestPublishedVersion.Owner.Name ASC,
                     ContentDocument.LatestPublishedVersion.CreatedDate DESC
        ]) {
            ContentRow row = new ContentRow();
            // Map TYPEOF Opportunity fields. When LinkedEntity is not Opportunity, these will be null.
            if (cdl.LinkedEntity instanceof Opportunity) {
                Opportunity opp = (Opportunity) cdl.LinkedEntity;
                row.oppOwnerName = (opp.Owner != null) ? opp.Owner.Name : null;
                row.oppAccountName = (opp.Account != null) ? opp.Account.Name : null;
                row.oppName = opp.Name;
                row.oppStageName = opp.StageName;
                row.oppCloseDate = opp.CloseDate;
                row.oppCreatedDate = opp.CreatedDate;
            }

            row.contentDocumentId = cdl.ContentDocumentId;
            row.contentTitle = (cdl.ContentDocument != null) ? cdl.ContentDocument.Title : null;
            row.latestVersionId = (cdl.ContentDocument != null && cdl.ContentDocument.LatestPublishedVersion != null)
                                  ? cdl.ContentDocument.LatestPublishedVersion.Id : null;
            row.textPreview = (cdl.ContentDocument != null && cdl.ContentDocument.LatestPublishedVersion != null)
                                  ? cdl.ContentDocument.LatestPublishedVersion.TextPreview : null;
            row.versionCreatedDate = (cdl.ContentDocument != null && cdl.ContentDocument.LatestPublishedVersion != null)
                                  ? cdl.ContentDocument.LatestPublishedVersion.CreatedDate : null;
            row.versionOwnerName = (cdl.ContentDocument != null && cdl.ContentDocument.LatestPublishedVersion != null &&
                                    cdl.ContentDocument.LatestPublishedVersion.Owner != null)
                                  ? cdl.ContentDocument.LatestPublishedVersion.Owner.Name : null;

            rows.add(row);
        }

        return rows;
    }

    /**
     * @description Build CSV with headers and rows using CRLF and proper escaping.
     */
    private static String buildCsv(List<ContentRow> rows) {
        List<String> lines = new List<String>();
        // Header
        lines.add(String.join(new List<String>{
            'OwnerName',
            'AccountName',
            'OpportunityName',
            'StageName',
            'CloseDate',
            'OpportunityCreatedDate',
            'ContentDocumentId',
            'Title',
            'LatestVersionId',
            'TextPreview',
            'VersionCreatedDate',
            'VersionOwnerName'
        }, ','));

        // Rows
        for (ContentRow r : rows) {
            lines.add(String.join(new List<String>{
                csvEscape(r.oppOwnerName),
                csvEscape(r.oppAccountName),
                csvEscape(r.oppName),
                csvEscape(r.oppStageName),
                csvEscapeDate(r.oppCloseDate),
                csvEscapeDatetime(r.oppCreatedDate),
                csvEscapeId(r.contentDocumentId),
                csvEscape(r.contentTitle),
                csvEscapeId(r.latestVersionId),
                csvEscape(r.textPreview),
                csvEscapeDatetime(r.versionCreatedDate),
                csvEscape(r.versionOwnerName)
            }, ','));
        }

        return String.join(lines, '\r\n');
    }

    /**
     * @description Insert the CSV string as a ContentVersion using USER_MODE DML.
     */
    private static Id insertCsvAsContentVersion(String csv, String fileName) {
        if (csv == null) {
            throw new AuraHandledException('CSV content is null.');
        }
        // Convert CSV to Blob
        Blob body = Blob.valueOf(csv);

        ContentVersion cv = new ContentVersion();
        cv.PathOnClient = fileName;
        cv.Title = fileName.removeEnd('.csv');
        cv.VersionData = body;

        // USER_MODE per security requirements
        Database.SaveResult sr = Database.insert(cv, AccessLevel.USER_MODE);
        if (!sr.isSuccess()) {
            String msg = 'Failed to insert ContentVersion: ';
            for (Database.Error e : sr.getErrors()) {
                msg += e.getMessage() + ' ';
            }
            throw new AuraHandledException(msg.trim());
        }
        return sr.getId();
    }

    /**
     * @description Fetch ContentDocumentId from ContentVersion.
     */
    private static Id fetchContentDocumentId(Id contentVersionId) {
        if (contentVersionId == null) return null;
        ContentVersion cv = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Id = :contentVersionId
            LIMIT 1
        ];
        return cv.ContentDocumentId;
    }

    /**
     * @description Link a ContentDocument to a Library (ContentWorkspace) via ContentWorkspaceDoc.
     */
    private static void linkDocumentToWorkspace(Id workspaceId, Id contentDocumentId) {
        if (workspaceId == null || contentDocumentId == null) return;

        ContentWorkspaceDoc cwd = new ContentWorkspaceDoc();
        cwd.ContentWorkspaceId = workspaceId;
        cwd.ContentDocumentId = contentDocumentId;

        Database.SaveResult sr = Database.insert(cwd, AccessLevel.USER_MODE);
        if (!sr.isSuccess()) {
            String msg = 'Failed to link document to library: ';
            for (Database.Error e : sr.getErrors()) {
                msg += e.getMessage() + ' ';
            }
            throw new AuraHandledException(msg.trim());
        }
    }

    /**
     * @description Resolve ContentWorkspace Id by DeveloperName. Returns null if not found.
     */
    private static Id resolveWorkspaceId(String developerName) {
        if (String.isBlank(developerName)) return null;
        List<ContentWorkspace> ws = [
            SELECT Id
            FROM ContentWorkspace
            WHERE Name = :developerName
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        return ws.isEmpty() ? null : ws[0].Id;
    }

    // ---------- CSV helpers ----------

    private static String csvEscape(String value) {
        if (value == null) return '';
        // Escape " by "" and wrap in quotes if comma, quote, or newline present
        Boolean mustQuote = value.contains(',') || value.contains('"') || value.contains('\n') || value.contains('\r');
        String out = value.replaceAll('"', '""');
        return mustQuote ? '"' + out + '"' : out;
    }

    private static String csvEscapeId(Id value) {
        return csvEscape(value == null ? null : (String) value);
    }

    private static String csvEscapeDate(Date d) {
        return csvEscape(d == null ? null : d.format());
    }

    private static String csvEscapeDatetime(Datetime dt) {
        return csvEscape(dt == null ? null : dt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
    }

    private static String formatNowUTC(String pattern) {
        return Datetime.now().formatGmt(pattern);
    }
}