@IsTest
public class InvoiceServiceTest {

    // ---------- Helper Methods ----------

    // Create Owner__c (owner of the rental asset)
    private static Owner__c createOwner() {
        Owner__c own = new Owner__c(Name = 'Test Owner');
        insert own; 
        return own;
    }

    // Create Tenant__c 
    private static Tenant__c createTenant() {

        Tenant__c t = new Tenant__c(
            FirstName__c = 'TestName',
            LastName__c = 'TestLastName'
        );
        insert t; 
        return t; 
    }

    // Create RentalAsset__c 
    private static RentalAsset__c createAsset(String name, Id ownerId) {
        RentalAsset__c asset = new RentalAsset__c(
            Name = name,
            City__c = 'Test City',
            Street__c = '123 Test St',
            Owner__c = ownerId
        );
        insert asset; 
        return asset;
    }

    // Create Lease__c 
    private static Lease__c createLease() {
        Owner__c owner = createOwner();
        Tenant__c tenant = createTenant();
        RentalAsset__c asset = createAsset('Test Asset', owner.Id);

        Lease__c lease = new Lease__c(
            Name = 'Test Lease',
            Tenant__c = tenant.Id,        
            RentalAsset__c = asset.Id,   
            StartDate__c = Date.today(),
            EndDate__c = Date.today().addMonths(12),
            MonthlyRent__c = 1000,
            DueDayOfMonth__c = 1
        );
        insert lease;
        return lease;
    }

    // ---------- Tests ----------

    // Test inserting an Invoice with Status = Sent
    @IsTest
    static void testInsertInvoiceSentCreatesPdf() {
        Lease__c lease = createLease();

        Invoice__c inv = new Invoice__c(
            Name = 'INV-001',
            Status__c = 'Sent',
            DueDate__c = Date.today().addDays(7),
            Amount__c = 120,
            Lease__c = lease.Id,
            PeriodMonth__c = Date.newInstance(2026, 2, 1)
        );

        Test.startTest();
        insert inv; 
        Test.stopTest();

        // Verify that PDF file Id was created
        inv = [SELECT Id, InvoicePdfFileId__c FROM Invoice__c WHERE Id = :inv.Id];
        System.assertNotEquals(null, inv.InvoicePdfFileId__c,
            'PDF should be created when inserting an Invoice with Status = Sent');
    }

    // Test updating Invoice from Draft to Sent
    @IsTest
    static void testUpdateInvoiceDraftToSentCreatesPdf() {
        Lease__c lease = createLease();

        Invoice__c inv = new Invoice__c(
            Name = 'INV-002',
            Status__c = 'Draft',
            DueDate__c = Date.today().addDays(10),
            Amount__c = 200,
            Lease__c = lease.Id,
            PeriodMonth__c = Date.newInstance(2026, 2, 1)
        );
        insert inv;

        inv.Status__c = 'Sent';

        Test.startTest();
        update inv; 
        Test.stopTest();

        // Verify PDF was created
        inv = [SELECT Id, InvoicePdfFileId__c FROM Invoice__c WHERE Id = :inv.Id];
        System.assertNotEquals(null, inv.InvoicePdfFileId__c,
            'PDF should be created when the status changes to Sent');
    }

    // Test that re-saving an Invoice does not create a duplicate PDF
    @IsTest
    static void testNoDuplicatePdfOnReSave() {
        Lease__c lease = createLease();

        Invoice__c inv = new Invoice__c(
            Name = 'INV-003',
            Status__c = 'Sent',
            DueDate__c = Date.today().addDays(5),
            Amount__c = 150,
            Lease__c = lease.Id,
            PeriodMonth__c = Date.newInstance(2026, 2, 1)
        );
        insert inv;

        String originalPdfId = [SELECT InvoicePdfFileId__c FROM Invoice__c WHERE Id = :inv.Id].InvoicePdfFileId__c;

        // Re-save without changing the status
        Test.startTest();
        update inv;
        Test.stopTest();

        String afterPdfId = [SELECT InvoicePdfFileId__c FROM Invoice__c WHERE Id = :inv.Id].InvoicePdfFileId__c;
        System.assertEquals(originalPdfId, afterPdfId,
            'PDF should not be duplicated on re-save');
    }

    // Test bulk insertion of 50 Invoices with Status = Sent
    @IsTest
    static void testBulkInsertInvoicesCreatesPdf() {
        Lease__c lease = createLease();

        List<Invoice__c> invoices = new List<Invoice__c>();
        for (Integer i = 0; i < 50; i++) {
            invoices.add(new Invoice__c(
                Name = 'Bulk-' + i,
                Status__c = 'Sent',
                DueDate__c = Date.today().addDays(7),
                Amount__c = 100 + i,
                Lease__c = lease.Id,
                PeriodMonth__c = Date.newInstance(2026, 2, 1)
            ));
        }

        Test.startTest();
        insert invoices; 
        Test.stopTest();

        // Verify all 50 invoices have PDF created
        Integer countWithPdf = [SELECT COUNT() FROM Invoice__c WHERE InvoicePdfFileId__c != null];
        System.assertEquals(50, countWithPdf,
            'All bulk Invoices should have a created PDF');
    }
}