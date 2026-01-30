@IsTest(SeeAllData=false)
private class DeploymentCoverageTest {

    @IsTest
    static void coverCoreApex() {
        // =========================
        // 1) Standard objects (fire triggers + cover TriggerHandler branches)
        // =========================
        TriggerHandler.clearAllBypasses();

        // Cover bypass path (validateRun returns false -> run() returns early)
        TriggerHandler.bypass('AccountTriggerHandler');
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        TriggerHandler.clearBypass('AccountTriggerHandler');

        // Now cover full trigger contexts
        acc.Name = 'Test Account 2';
        update acc;
        delete acc;
        undelete acc;

        Contact con = new Contact(LastName = 'Test Contact');
        runAllDml(con, new Map<String, Object>{ 'LastName' => 'Test Contact 2' });

        Lead lead = new Lead(LastName = 'Test Lead', Company = 'TestCo');
        runAllDml(lead, new Map<String, Object>{ 'Company' => 'TestCo 2' });

        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        runAllDml(opp, new Map<String, Object>{ 'StageName' => 'Qualification' });

        Case cs = new Case(Subject = 'Test Case');
        runAllDml(cs, new Map<String, Object>{ 'Subject' => 'Test Case 2' });

        // =========================
        // 2) Custom objects (create required relationship chain)
        // =========================
        Owner__c owner1 = new Owner__c(Name = 'Owner 1');
        insert owner1;

        RentalAsset__c ra1 = new RentalAsset__c(
            Name = 'RA 1',
            Owner__c = owner1.Id,
            City__c = 'Budapest',
            Street__c = 'Street 1'
        );
        insert ra1;

        Tenant__c t1 = new Tenant__c(
            Name = 'Tenant 1',
            FirstName__c = 'T',
            LastName__c = 'One'
        );
        insert t1;

        Lease__c lease1 = new Lease__c(
            Name = 'Lease 1',
            RentalAsset__c = ra1.Id,
            Tenant__c = t1.Id,
            StartDate__c = Date.today(),
            EndDate__c = Date.today().addDays(30),
            DueDayOfMonth__c = 1,
            MonthlyRent__c = 100
        );
        insert lease1;
        lease1.MonthlyRent__c = 110;
        update lease1;

        Invoice__c inv1 = new Invoice__c(
            Name = 'Inv 1',
            Lease__c = lease1.Id,
            Amount__c = 100,
            DueDate__c = Date.today().addDays(10),
            PeriodMonth__c = Date.today()
        );
        insert inv1;
        inv1.Amount__c = 101;
        update inv1;

        Payment__c pay1 = new Payment__c(
            Name = 'Pay 1',
            Invoice__c = inv1.Id,
            Amount__c = 50,
            PaymentDateTime__c = System.now()
        );
        insert pay1;
        pay1.Amount__c = 55;
        update pay1;

        // Delete/undelete leaf records safely
        delete pay1;
        undelete pay1;

        // Invoice delete/undelete (no payment attached)
        Invoice__c inv2 = new Invoice__c(
            Name = 'Inv 2',
            Lease__c = lease1.Id,
            Amount__c = 200,
            DueDate__c = Date.today().addDays(20),
            PeriodMonth__c = Date.today()
        );
        runAllDml(inv2, new Map<String, Object>{ 'Amount__c' => 201 });

        // Lease delete/undelete (no invoices attached)
        Lease__c lease2 = new Lease__c(
            Name = 'Lease 2',
            RentalAsset__c = ra1.Id,
            Tenant__c = t1.Id,
            StartDate__c = Date.today(),
            EndDate__c = Date.today().addDays(10),
            DueDayOfMonth__c = 5,
            MonthlyRent__c = 10
        );
        runAllDml(lease2, new Map<String, Object>{ 'MonthlyRent__c' => 11 });

        MaintenanceRequest__c mr1 = new MaintenanceRequest__c(
            Name = 'MR 1',
            RentalAsset__c = ra1.Id,
            Description__c = 'test',
            RequestedAt__c = System.now()
        );
        runAllDml(mr1, new Map<String, Object>{ 'RequestedAt__c' => System.now().addMinutes(1) });

        // Standalone parent records for delete/undelete coverage
        Owner__c owner2 = new Owner__c(Name = 'Owner 2');
        runAllDml(owner2, new Map<String, Object>{ 'Name' => 'Owner 2b' });

        Tenant__c t2 = new Tenant__c(Name = 'Tenant 2', FirstName__c = 'T', LastName__c = 'Two');
        runAllDml(t2, new Map<String, Object>{ 'LastName__c' => 'TwoB' });

        RentalAsset__c ra2 = new RentalAsset__c(
            Name = 'RA 2',
            Owner__c = owner1.Id,
            City__c = 'Budapest',
            Street__c = 'Street 2'
        );
        runAllDml(ra2, new Map<String, Object>{ 'Street__c' => 'Street 2b' });

        // =========================
        // 3) Cover service classes (currently not invoked by triggers)
        // =========================
        AccountService.demonstrativeMethod(new Map<Id, Account>(), new Map<Id, Account>());
        CaseService.demonstrativeMethod(new Map<Id, Case>(), new Map<Id, Case>());
        ContactService.demonstrativeMethod(new Map<Id, Contact>(), new Map<Id, Contact>());
        LeadService.demonstrativeMethod(new Map<Id, Lead>(), new Map<Id, Lead>());
        OpportunityService.demonstrativeMethod(new Map<Id, Opportunity>(), new Map<Id, Opportunity>());

        OwnerService.demonstrativeMethod(new Map<Id, Owner__c>(), new Map<Id, Owner__c>());
        RentalAssetService.demonstrativeMethod(new Map<Id, RentalAsset__c>(), new Map<Id, RentalAsset__c>());
        TenantService.demonstrativeMethod(new Map<Id, Tenant__c>(), new Map<Id, Tenant__c>());
        LeaseService.demonstrativeMethod(new Map<Id, Lease__c>(), new Map<Id, Lease__c>());
        InvoiceService.demonstrativeMethod(new Map<Id, Invoice__c>(), new Map<Id, Invoice__c>());
        PaymentService.demonstrativeMethod(new Map<Id, Payment__c>(), new Map<Id, Payment__c>());
        MaintenanceRequestService.demonstrativeMethod(new Map<Id, MaintenanceRequest__c>(), new Map<Id, MaintenanceRequest__c>());

        System.assertEquals('ok', ROBillingService.ping());
        System.assertEquals('ok', RODocsService.ping());
        System.assertEquals('ok', ROLeaseService.ping());
        System.assertEquals('ok', ROQualityService.ping());
        System.assertEquals('ok', ROTenantService.ping());
        System.assertEquals('ok', ROWorkflowService.ping());

        // =========================
        // 4) Cover TriggerHandler error path + loop count
        // =========================
        try {
            new TriggerHandler().run();
            System.assert(false, 'Expected TriggerHandler to throw outside trigger context.');
        } catch (Exception e) {
            System.assert(e.getMessage() != null && e.getMessage().contains('Trigger handler called outside of Trigger execution'));
        }

        TriggerHandler th = new TriggerHandler();
        // setTriggerContext(String, Boolean) is private but @TestVisible in the base class, so tests can call it.
        th.setTriggerContext('before insert', true);
        th.setMaxLoopCount(1);
        th.run();
        Boolean loopThrew = false;
        try {
            th.run(); // should exceed loop count
        } catch (Exception e) {
            loopThrew = true;
        }
        System.assert(loopThrew, 'Expected loop-count exception path.');
        th.clearMaxLoopCount();
    }

    private static void runAllDml(SObject sobj, Map<String, Object> updates) {
        insert sobj;
        for (String f : updates.keySet()) {
            sobj.put(f, updates.get(f));
        }
        update sobj;
        delete sobj;
        undelete sobj;
    }
}
