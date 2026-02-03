@IsTest
public class InvoicePdfServiceTest {

    @IsTest
    static void testPdfGeneratedWhenStatusBecomesSent() {

       
        Invoice__c inv = new Invoice__c();
        inv.Name = 'Test Invoice';
        inv.Status__c = 'Draft';
        insert inv;

        
        Integer filesBefore = [
            SELECT COUNT()
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :inv.Id
        ];
        System.assertEquals(0, filesBefore);

        
        inv.Status__c = 'Sent';
        Test.startTest();
        update inv;
        Test.stopTest();

        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :inv.Id
        ];

        System.assertEquals(1,links.size());
    }
}