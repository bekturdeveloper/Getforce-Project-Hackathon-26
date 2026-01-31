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


}
