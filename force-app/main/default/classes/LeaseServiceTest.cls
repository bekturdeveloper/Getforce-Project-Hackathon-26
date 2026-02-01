@IsTest(SeeAllData=false)
private class LeaseServiceTest {

//@IsTest
//static void demonstrativeMethodTest() {

//}

@IsTest
static void testLeaseDeleteBlockedWhenInvoiceExists() {

    Owner__c owner = new Owner__c(
        Name = 'Test Owner',
        Email__c = 'owner@test.com',
        Phone__c = '015208832076'
    );
    insert owner;

    Tenant__c tenant = new Tenant__c(
        Name = 'Test Tenant',
        FirstName__c = 'Test',
        LastName__c = 'Tenant',
        PreferredLanguage__c = 'EN',
        Phone__c = '015208832076'
    );
    insert tenant;

    RentalAsset__c asset = new RentalAsset__c(
        Name = 'Test Asset',
        Owner__c = owner.Id,
        City__c = 'Osnabruck',
        Street__c = 'Wersener Straße 46'
    );
    insert asset;

    Lease__c leaseWithInvoice = new Lease__c(
        Name = 'Lease With Invoice',
        RentalAsset__c = asset.Id,
        Tenant__c = tenant.Id,
        StartDate__c = Date.today(),
        EndDate__c = Date.today().addDays(30),
        MonthlyRent__c = 500,
        DueDayOfMonth__c = 5
    );

    Lease__c leaseClean = new Lease__c(
        Name = 'Lease Clean',
        RentalAsset__c = asset.Id,
        Tenant__c = tenant.Id,
        StartDate__c = Date.today(),
        EndDate__c = Date.today().addDays(30),
        MonthlyRent__c = 500,
        DueDayOfMonth__c = 5
    );

    insert new List<Lease__c>{ leaseWithInvoice, leaseClean };

    Invoice__c inv = new Invoice__c(
        Name = 'LeaseInvoice',
        Lease__c = leaseWithInvoice.Id,
        Amount__c = 500,
        DueDate__c = Date.today().addDays(7),
        PeriodMonth__c = Date.today().toStartOfMonth()
    );
    insert inv;

    Test.startTest();
    Database.DeleteResult[] results = Database.delete(
        new List<Lease__c>{ leaseWithInvoice, leaseClean },
        false
    );
    Test.stopTest();

    Map<Id, Database.DeleteResult> byId = new Map<Id, Database.DeleteResult>();
    for (Database.DeleteResult dr : results) {
        byId.put(dr.getId(), dr);
    }

    System.assertEquals(
        false,
        byId.get(leaseWithInvoice.Id).isSuccess(),
        'Lease with an invoice should not be deletable.'
    );

    System.assertEquals(
        System.Label.RenterOps_Lease_DeleteBlocked_Financials,
        byId.get(leaseWithInvoice.Id).getErrors()[0].getMessage(),
        'Expected delete-block message when invoice exists.'
    );

    System.assertEquals(
        true,
        byId.get(leaseClean.Id).isSuccess(),
        'Lease without invoice should be deletable.'
    );
}






    // ---------- Helper methods ----------
   @IsTest
   private static Owner__c createOwner() {
    Owner__c own = new Owner__c(
        Name = 'Test Owner'
    );
    insert own;
    return own;
	}
 
	private static Tenant__c createTenant(){
    	Tenant__c t = new Tenant__c(
        Name = 'tenantName',
        FirstName__c = 'Test First Name',
        LastName__c = 'Test Last Name'
    	);
    insert t;
    return t;
		}
    
    // Create a RentalAsset__c with all required fields, including a valid Owner__c
    private static RentalAsset__c createAsset(String name, Id ownerId) {
        
        RentalAsset__c asset = new RentalAsset__c(
            Name = name,
            City__c = 'Test City',
            Street__c = '123 Test St',
            Owner__c = ownerId // must match the lookup type
        );
        insert asset;
        return asset;
    }

    // Create a Lease__c and assign it a real Asset Id
    private static Lease__c createLease(String name, String assetName, Id ownerId) {
        RentalAsset__c asset = createAsset(assetName, ownerId);
		Tenant__c tenant = createTenant();
        
        Lease__c lease = new Lease__c(
            Name = name,
            RentalAsset__c = asset.Id,
            DueDayOfMonth__c = 30,
            EndDate__c = Date.newInstance(2027, 1, 29),
            MonthlyRent__c = 200,
            StartDate__c = Date.newInstance(2026, 1, 28),
            Tenant__c = tenant.Id
        );
        insert lease;
        return lease;
    }

    // Create a sample Invoice with Status__c
    private static void createInvoice(Id leaseId, String status) {
        insert new Invoice__c(
            Lease__c = leaseId,
            Amount__c = 100,
            DueDate__c = Date.newInstance(2026,01,31),
            PeriodMonth__c = Date.newInstance(2026,01,29),
            Status__c = status
        );
    }

    // ---------- Tests ----------

    // Block asset change when there is a Paid invoice
    @IsTest
    static void testBlockAssetChangeWhenPaidInvoiceExists() {
        Owner__c owner = createOwner();
        Lease__c lease = createLease('Lease with Paid Invoice', 'Asset 1', owner.Id);
        createInvoice(lease.Id, 'Paid'); // Paid invoice triggers block

        RentalAsset__c newAsset = createAsset('Asset 2', owner.Id);
        lease.RentalAsset__c = newAsset.Id;

        Test.startTest();
        try {
            update lease;
            System.assert(false, 'Expected DML exception due to Paid invoice');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Cannot change the rental asset'),
                'Expected validation error for Paid invoice');
        }
        Test.stopTest();
    }

    // Allow asset change if invoice exists but is not Paid
    @IsTest
    static void testAllowAssetChangeWhenInvoiceNotPaid() {
        Owner__c owner = createOwner();
        Lease__c lease = createLease('Lease with Pending Invoice', 'Asset 3', owner.Id);
        createInvoice(lease.Id, 'Sent'); // Not Paid

        RentalAsset__c newAsset = createAsset('Asset 4', owner.Id);
        lease.RentalAsset__c = newAsset.Id;

        Test.startTest();
        update lease;
        Test.stopTest();

        Lease__c updatedLease = [
            SELECT RentalAsset__c
            FROM Lease__c
            WHERE Id = :lease.Id
        ];
        System.assertEquals(newAsset.Id, updatedLease.RentalAsset__c,
            'RentalAsset should update when invoice is not Paid');
    }
    
	// Allow asset change if no invoices exist
    @IsTest
    static void testAllowAssetChangeWhenNoInvoicesExist() {
        Owner__c owner = createOwner();
        Lease__c lease = createLease('Lease without Invoice', 'Asset 5', owner.Id);

        RentalAsset__c newAsset = createAsset('Asset 6', owner.Id);
        lease.RentalAsset__c = newAsset.Id;

        Test.startTest();
        update lease;
        Test.stopTest();

        Lease__c updatedLease = [
            SELECT RentalAsset__c
            FROM Lease__c
            WHERE Id = :lease.Id
        ];
        System.assertEquals(newAsset.Id, updatedLease.RentalAsset__c);
    }
    
    // Bulk update: mix of Paid and non-Paid invoices
    @IsTest
    static void testBulkAssetChangeMixedLeases() {
        Owner__c owner = createOwner();

        Lease__c leasePaid = createLease('Bulk Lease 1', 'Asset 7', owner.Id);
        Lease__c leasePending = createLease('Bulk Lease 2', 'Asset 8', owner.Id);

        createInvoice(leasePaid.Id, 'Paid');
        createInvoice(leasePending.Id, 'Sent');

        RentalAsset__c newAsset1 = createAsset('Asset 9', owner.Id);
        RentalAsset__c newAsset2 = createAsset('Asset 10', owner.Id);

        leasePaid.RentalAsset__c = newAsset1.Id;
        leasePending.RentalAsset__c = newAsset2.Id;

        Test.startTest();
        Database.SaveResult[] results = Database.update(
            new List<Lease__c>{ leasePaid, leasePending }, false
        );
        Test.stopTest();
        
         // Paid invoice lease should fail
        System.assertEquals(false, results[0].isSuccess(),
            'Lease with Paid invoice should be blocked');

        // Pending invoice lease should succeed
        System.assertEquals(true, results[1].isSuccess(),
            'Lease with non-Paid invoice should update');

        Lease__c updatedLease = [
            SELECT RentalAsset__c
            FROM Lease__c
            WHERE Id = :leasePending.Id
        ];
        System.assertEquals(newAsset2.Id, updatedLease.RentalAsset__c,
            'RentalAsset for non-Paid invoice lease updated incorrectly');
    }

   private static Owner__c createOwner() {
    Owner__c own = new Owner__c(
        Name = 'Test Owner'
    );
    insert own;
    return own;
	}
 
	private static Tenant__c createTenant(){
    	Tenant__c t = new Tenant__c(
        Name = 'tenantName',
        FirstName__c = 'Test First Name',
        LastName__c = 'Test Last Name'
    	);
    insert t;
    return t;
		}
    
    // Create a RentalAsset__c with all required fields, including a valid Owner__c
    private static RentalAsset__c createAsset(String name, Id ownerId) {
        
        RentalAsset__c asset = new RentalAsset__c(
            Name = name,
            City__c = 'Test City',
            Street__c = '123 Test St',
            Owner__c = ownerId // must match the lookup type
        );
        insert asset;
        return asset;
    }

    // Create a Lease__c and assign it a real Asset Id
    private static Lease__c createLease(String name, String assetName, Id ownerId) {
        RentalAsset__c asset = createAsset(assetName, ownerId);
		Tenant__c tenant = createTenant();
        
        Lease__c lease = new Lease__c(
            Name = name,
            RentalAsset__c = asset.Id,
            DueDayOfMonth__c = 30,
            EndDate__c = Date.newInstance(2027, 1, 29),
            MonthlyRent__c = 200,
            StartDate__c = Date.newInstance(2026, 1, 28),
            Tenant__c = tenant.Id
        );
        insert lease;
        return lease;
    }

    // Create a sample Invoice with Status__c
    private static void createInvoice(Id leaseId, String status) {
        insert new Invoice__c(
            Lease__c = leaseId,
            Amount__c = 100,
            DueDate__c = Date.newInstance(2026,01,31),
            PeriodMonth__c = Date.newInstance(2026,01,29),
            Status__c = status
        );
    }

    // ---------- Tests ----------

    // Block asset change when there is a Paid invoice
    @IsTest
    static void testBlockAssetChangeWhenPaidInvoiceExists() {
        Owner__c owner = createOwner();
        Lease__c lease = createLease('Lease with Paid Invoice', 'Asset 1', owner.Id);
        createInvoice(lease.Id, 'Paid'); // Paid invoice triggers block

        RentalAsset__c newAsset = createAsset('Asset 2', owner.Id);
        lease.RentalAsset__c = newAsset.Id;

        Test.startTest();
        try {
            update lease;
            System.assert(false, 'Expected DML exception due to Paid invoice');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Cannot change the rental asset'),
                'Expected validation error for Paid invoice');
        }
        Test.stopTest();
    }

    // Allow asset change if invoice exists but is not Paid
    @IsTest
    static void testAllowAssetChangeWhenInvoiceNotPaid() {
        Owner__c owner = createOwner();
        Lease__c lease = createLease('Lease with Pending Invoice', 'Asset 3', owner.Id);
        createInvoice(lease.Id, 'Sent'); // Not Paid

        RentalAsset__c newAsset = createAsset('Asset 4', owner.Id);
        lease.RentalAsset__c = newAsset.Id;

        Test.startTest();
        update lease;
        Test.stopTest();

        Lease__c updatedLease = [
            SELECT RentalAsset__c
            FROM Lease__c
            WHERE Id = :lease.Id
        ];
        System.assertEquals(newAsset.Id, updatedLease.RentalAsset__c,
            'RentalAsset should update when invoice is not Paid');
    }
    
	// Allow asset change if no invoices exist
    @IsTest
    static void testAllowAssetChangeWhenNoInvoicesExist() {
        Owner__c owner = createOwner();
        Lease__c lease = createLease('Lease without Invoice', 'Asset 5', owner.Id);

        RentalAsset__c newAsset = createAsset('Asset 6', owner.Id);
        lease.RentalAsset__c = newAsset.Id;

        Test.startTest();
        update lease;
        Test.stopTest();

        Lease__c updatedLease = [
            SELECT RentalAsset__c
            FROM Lease__c
            WHERE Id = :lease.Id
        ];
        System.assertEquals(newAsset.Id, updatedLease.RentalAsset__c);
    }
    
    // Bulk update: mix of Paid and non-Paid invoices
    @IsTest
    static void testBulkAssetChangeMixedLeases() {
        Owner__c owner = createOwner();

        Lease__c leasePaid = createLease('Bulk Lease 1', 'Asset 7', owner.Id);
        Lease__c leasePending = createLease('Bulk Lease 2', 'Asset 8', owner.Id);

        createInvoice(leasePaid.Id, 'Paid');
        createInvoice(leasePending.Id, 'Sent');

        RentalAsset__c newAsset1 = createAsset('Asset 9', owner.Id);
        RentalAsset__c newAsset2 = createAsset('Asset 10', owner.Id);

        leasePaid.RentalAsset__c = newAsset1.Id;
        leasePending.RentalAsset__c = newAsset2.Id;

        Test.startTest();
        Database.SaveResult[] results = Database.update(
            new List<Lease__c>{ leasePaid, leasePending }, false
        );
        Test.stopTest();
        
         // Paid invoice lease should fail
        System.assertEquals(false, results[0].isSuccess(),
            'Lease with Paid invoice should be blocked');

        // Pending invoice lease should succeed
        System.assertEquals(true, results[1].isSuccess(),
            'Lease with non-Paid invoice should update');

        Lease__c updatedLease = [
            SELECT RentalAsset__c
            FROM Lease__c
            WHERE Id = :leasePending.Id
        ];
        System.assertEquals(newAsset2.Id, updatedLease.RentalAsset__c,
            'RentalAsset for non-Paid invoice lease updated incorrectly');
    }
}
