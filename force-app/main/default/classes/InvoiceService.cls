public with sharing class InvoiceService {

    public static void handleInvoicePdfGeneration(
        Map<Id, Invoice__c> oldMap,
        Map<Id, Invoice__c> newMap
    ) {
        List<Invoice__c> invoicesToProcess = new List<Invoice__c>();

        for (Invoice__c inv : newMap.values()) {
            // INSERT
            if (oldMap == null) {
                if (inv.Status__c == 'Sent') {
                    invoicesToProcess.add(inv);
                }
            }
            // UPDATE (transition to Sent)
            else {
                Invoice__c oldInv = oldMap.get(inv.Id);
                if (
                    oldInv.Status__c != 'Sent' &&
                    inv.Status__c == 'Sent'
                ) {
                    invoicesToProcess.add(inv);
                }
            }
        }

        if (invoicesToProcess.isEmpty()) {
            return;
        }

        generateAndAttachPdfs(invoicesToProcess);
    }

    // PDF generation logic

    private static void generateAndAttachPdfs(List<Invoice__c> invoices) {

        // 1. Delete old PDFs if exist
        Set<Id> oldDocIds = new Set<Id>();
        for (Invoice__c inv : invoices) {
            if (inv.InvoicePdfFileId__c != null) {
                oldDocIds.add((Id) inv.InvoicePdfFileId__c);
            }
        }

        if (!oldDocIds.isEmpty()) {
            List<ContentDocument> oldDocs = [
                SELECT Id FROM ContentDocument WHERE Id IN :oldDocIds
            ];
            delete oldDocs;
        }

        // 2. Create new ContentVersions
        List<ContentVersion> versionsToInsert = new List<ContentVersion>();

        for (Invoice__c inv : invoices) {
            String html = buildInvoiceHtml(inv);

            Blob pdfBlob = Test.isRunningTest()
                ? Blob.valueOf('Test PDF')
                : Blob.toPdf(html);

            ContentVersion cv = new ContentVersion();
            cv.Title = 'Invoice_' + inv.Name;
            cv.PathOnClient = 'Invoice.pdf';
            cv.VersionData = pdfBlob;
            cv.IsMajorVersion = true;

            versionsToInsert.add(cv);
        }

        insert versionsToInsert;

        // 3. Fetch ContentDocumentIds
        Map<Integer, Id> indexToDocId = new Map<Integer, Id>();
        List<ContentVersion> insertedVersions = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id IN :versionsToInsert
        ];

        for (Integer i = 0; i < insertedVersions.size(); i++) {
            indexToDocId.put(i, insertedVersions[i].ContentDocumentId);
        }

        // 4. Create links + update Invoice
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        List<Invoice__c> invoicesToUpdate = new List<Invoice__c>();

        for (Integer i = 0; i < invoices.size(); i++) {
            Id docId = indexToDocId.get(i);

            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = docId;
            cdl.LinkedEntityId = invoices[i].Id;
            cdl.ShareType = 'V';

            links.add(cdl);

        Invoice__c invToUpdate = new Invoice__c(
            Id = invoices[i].Id,
            InvoicePdfFileId__c = docId
            );  
        invoicesToUpdate.add(invToUpdate);
        }

        insert links;
        update invoicesToUpdate;
    }

    // HTML template
    private static String buildInvoiceHtml(Invoice__c inv) {
    return ''
    + '<html><body style="font-family:Arial,sans-serif; color:#333;">'

    // Header
    + '<h1 style="text-align:center; color:#2E86C1; margin-bottom:20px;">Invoice</h1>'

    // Invoice Table with visible borders
    + '<table style="width:100%; border-collapse:collapse; margin-bottom:30px;">'
    + '<tr>'
    + '<th style="border:1px solid #000; padding:8px; background-color:#f2f2f2; text-align:left;">Field</th>'
    + '<th style="border:1px solid #000; padding:8px; background-color:#f2f2f2; text-align:left;">Value</th>'
    + '</tr>'
    + '<tr>'
    + '<td style="border:1px solid #000; padding:8px;">Invoice Name</td>'
    + '<td style="border:1px solid #000; padding:8px;">' + inv.Name + '</td>'
    + '</tr>'
    + '<tr>'
    + '<td style="border:1px solid #000; padding:8px;">Status</td>'
    + '<td style="border:1px solid #000; padding:8px;">' + inv.Status__c + '</td>'
    + '</tr>'
    + '<tr>'
    + '<td style="border:1px solid #000; padding:8px;">Due Date</td>'
    + '<td style="border:1px solid #000; padding:8px;">' + (inv.DueDate__c != null ? String.valueOf(inv.DueDate__c) : '-') + '</td>'
    + '</tr>'
    + '<tr>'
    + '<td style="border:1px solid #000; padding:8px;">Amount</td>'
    + '<td style="border:1px solid #000; padding:8px;">$' + (inv.Amount__c != null ? String.valueOf(inv.Amount__c) : '0') + '</td>'
    + '</tr>'
    + '</table>'

    // Footer
    + '<p style="text-align:center; color:#555; font-size:12px;">Thank you for your business!</p>'

    + '</body></html>';
}



}