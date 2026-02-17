@IsTest
private class Tenant360ControllerTest {

    @testSetup
    static void setupData() {
        // Only create tenants (no Lease/Invoice/Payment) to avoid RentalAsset.Owner__c restrictions
        Tenant__c t1 = new Tenant__c(
            Name = 'TENANT-ANN-BAKER',
            FirstName__c = 'Ann',
            LastName__c  = 'Baker',
            Email__c     = 'ann.baker@example.com',
            Phone__c     = '555-0001',
            Status__c    = 'Active'
        );

        Tenant__c t2 = new Tenant__c(
            Name = 'TENANT-BOB-SMITH',
            FirstName__c = 'Bob',
            LastName__c  = 'Smith',
            Email__c     = 'bob.smith@example.com',
            Phone__c     = '555-0002',
            Status__c    = 'Active'
        );

        insert new List<Tenant__c>{ t1, t2 };
    }

    @IsTest
    static void search_returnsEmpty_ifLessThan2Chars() {
        Test.startTest();
        List<Tenant360Controller.TenantRow> rows = Tenant360Controller.searchTenants('A');
        Test.stopTest();
        System.assertEquals(0, rows.size());
    }

    @IsTest
    static void search_byFirstName_returnsTenant_andDefaults() {
        Test.startTest();
        List<Tenant360Controller.TenantRow> rows = Tenant360Controller.searchTenants('An');
        Test.stopTest();

        System.assertEquals(1, rows.size());
        Tenant360Controller.TenantRow r = rows[0];

        System.assertEquals('Ann', r.firstName);
        System.assertEquals('Baker', r.lastName);

        // No leases/invoices/payments created -> controller should safely return defaults
        System.assertEquals(0, r.activeLeaseCount);
        System.assertEquals(0, r.outstandingAmountTotal);
        System.assertEquals(null, r.lastPaymentDate);
    }

    @IsTest
    static void search_byEmail_returnsTenant() {
        Test.startTest();
        List<Tenant360Controller.TenantRow> rows = Tenant360Controller.searchTenants('ann.baker@');
        Test.stopTest();

        System.assertEquals(1, rows.size());
        System.assertEquals('ann.baker@example.com', rows[0].email);
    }
}