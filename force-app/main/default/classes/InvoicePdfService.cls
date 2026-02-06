public class InvoicePdfService {

    public static void generatePdf(Id invoiceId) {

        Invoice__c inv = [
            SELECT Name, Tenant__c, Asset__c, DueDate__c, Amount__c
            FROM Invoice__c
            WHERE Id = :invoiceId
        ];

        String htmlContent =
            '<html><body>' +
            '<h1>Invoice ' + inv.Name + '</h1>' +

            '<p><b>Tenant:</b> ' + inv.Tenant__c + '</p>' +
            '<p><b>Asset:</b> ' + inv.Asset__c + '</p>' +
            '<p><b>Due Date:</b> ' + inv.DueDate__c + '</p>' +
            '<p><b>Total:</b> ' + inv.Amount__c + '</p>' +

            '</body></html>';

        Blob pdfBlob = Blob.toPdf(htmlContent);

        ContentVersion cv = new ContentVersion();
        cv.Title = 'Invoice_' + inv.Name;
        cv.PathOnClient = 'Invoice_' + inv.Name + '.pdf';
        cv.VersionData = pdfBlob;
        cv.IsMajorVersion = true;
        cv.FirstPublishLocationId = invoiceId;

        insert cv;
    }
}