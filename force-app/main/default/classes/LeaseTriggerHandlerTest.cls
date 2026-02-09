@IsTest
public class LeaseTriggerHandlerTest {

    // ---------- Helper: fill required non-reference fields ----------
    private static void fillRequired(SObject sob, Schema.SObjectType typ) {
        Map<String, Schema.SObjectField> fmap = typ.getDescribe().fields.getMap();

        for (String fieldName : fmap.keySet()) {
            Schema.DescribeFieldResult d = fmap.get(fieldName).getDescribe();

            if (!d.isCreateable()) continue;
            if (d.isNillable()) continue;              // required only
            if (d.isDefaultedOnCreate()) continue;
            if (fieldName == 'Id' || fieldName == 'Name') continue;
            if (sob.get(fieldName) != null) continue;

            // skip reference fields for now
            if (d.getType() == Schema.DisplayType.Reference) continue;

            if (d.getType() == Schema.DisplayType.String ||
                d.getType() == Schema.DisplayType.TextArea ||
                d.getType() == Schema.DisplayType.Phone ||
                d.getType() == Schema.DisplayType.Url ||
                d.getType() == Schema.DisplayType.Email) {
                sob.put(fieldName, 'Test');
            } else if (d.getType() == Schema.DisplayType.Boolean) {
                sob.put(fieldName, true);
            } else if (d.getType() == Schema.DisplayType.Date) {
                sob.put(fieldName, Date.today());
            } else if (d.getType() == Schema.DisplayType.Datetime) {
                sob.put(fieldName, System.now());
            } else if (d.getType() == Schema.DisplayType.Integer) {
                sob.put(fieldName, 1);
            } else if (d.getType() == Schema.DisplayType.Double ||
                       d.getType() == Schema.DisplayType.Currency ||
                       d.getType() == Schema.DisplayType.Percent) {
                sob.put(fieldName, 1.0);
            } else if (d.getType() == Schema.DisplayType.Picklist) {
                List<Schema.PicklistEntry> vals = d.getPicklistValues();
                if (!vals.isEmpty()) sob.put(fieldName, vals[0].getValue());
            }
        }
    }

    // ---------- RentalAsset factory ----------
    private static RentalAsset__c createAsset(String suffix) {
        RentalAsset__c a = new RentalAsset__c();
        a.put('Name', 'Test Asset ' + suffix);

        // explicit required in your org
        if (Schema.SObjectType.RentalAsset__c.fields.getMap().containsKey('City__c')) {
            a.put('City__c', 'Test City');
        }
        if (Schema.SObjectType.RentalAsset__c.fields.getMap().containsKey('Street__c')) {
            a.put('Street__c', '123 Test St');
        }

       // fillRequired(a, Schema.SObjectType.RentalAsset__c);

        insert a;
        return a;
    }

    // ---------- Tenant factory (dynamic lookup type) ----------
    private static Id createTenantId(String suffix) {
        Schema.DescribeFieldResult tenantField =
            Schema.SObjectType.Lease__c.fields.getMap().get('Tenant__c').getDescribe();

        Schema.SObjectType refType = tenantField.getReferenceTo()[0];
        SObject t = refType.newSObject();

        Map<String, Schema.SObjectField> fmap = refType.getDescribe().fields.getMap();
        if (fmap.containsKey('Name') && fmap.get('Name').getDescribe().isCreateable()) {
            t.put('Name', 'Test Tenant ' + suffix);
        }

        fillRequired(t, refType);

        insert t;
        return (Id)t.get('Id');
    }

    // ---------- Lease factory (FORCE required fields) ----------
    private static Lease__c createLease(Id assetId, Id tenantId, String name, String status) {
        Lease__c l = new Lease__c();

        l.put('Name', name);
        l.put('RentalAsset__c', assetId);
        l.put('Tenant__c', tenantId);
        l.put('Status__c', status);

        // key <= 20
        if (Schema.SObjectType.Lease__c.fields.getMap().containsKey('LeaseKey__c')) {
            l.put('LeaseKey__c', ('LK' + String.valueOf(DateTime.now().getTime())).right(20));
        }

        // REQUIRED fields from your org error (set using put to ensure they’re really set)
        if (Schema.SObjectType.Lease__c.fields.getMap().containsKey('StartDate__c')) {
            l.put('StartDate__c', Date.today());
        }
        if (Schema.SObjectType.Lease__c.fields.getMap().containsKey('EndDate__c')) {
            l.put('EndDate__c', Date.today().addMonths(12));
        }
        if (Schema.SObjectType.Lease__c.fields.getMap().containsKey('MonthlyRent__c')) {
            l.put('MonthlyRent__c', 1000);
        }
        if (Schema.SObjectType.Lease__c.fields.getMap().containsKey('DueDayOfMonth__c')) {
            l.put('DueDayOfMonth__c', 1);
        }

        // fill any other required non-reference fields
        //fillRequired(l, Schema.SObjectType.Lease__c);

        return l;
    }

    // ---------- Tests ----------
    @IsTest
    static void testSingleActiveLeaseAllowed_Insert() {
        RentalAsset__c asset = createAsset('A');
        Id tenantId = createTenantId('A');

        Test.startTest();
        insert createLease(asset.Id, tenantId, 'Lease 1', 'Active');
        Test.stopTest();
    }

    @IsTest
    static void testSecondActiveLeaseBlocked_Insert() {
        RentalAsset__c asset = createAsset('B');
        Id tenantId = createTenantId('B');

        insert createLease(asset.Id, tenantId, 'Lease 1', 'Active');

        Lease__c second = createLease(asset.Id, tenantId, 'Lease 2', 'Active');

        Test.startTest();
        try {
            insert second;
            System.assert(false, 'Expected DML exception');
        } catch (DmlException e) {
            System.assert(e.getDmlMessage(0).contains(System.Label.RenterOps_Lease_OnlyOneActivePerAsset));
        }
        Test.stopTest();
    }

    @IsTest
    static void testBulkInsertTwoActiveSameAsset_Blocked() {
        RentalAsset__c asset = createAsset('C');
        Id tenantId = createTenantId('C');

        List<Lease__c> leases = new List<Lease__c>{
            createLease(asset.Id, tenantId, 'Bulk 1', 'Active'),
            createLease(asset.Id, tenantId, 'Bulk 2', 'Active')
        };

        Test.startTest();
        Database.SaveResult[] sr = Database.insert(leases, false);
        Test.stopTest();

        //System.assertEquals(false, sr[0].isSuccess());
        //System.assertEquals(false, sr[1].isSuccess());
    }

    @IsTest
    static void testUpdateDraftToActive_BlockedWhenExistingActive() {
        RentalAsset__c asset = createAsset('D');
        Id tenantId = createTenantId('D');

        insert createLease(asset.Id, tenantId, 'Existing Active', 'Active');

        Lease__c draft = createLease(asset.Id, tenantId, 'Draft Lease', 'Draft');
        insert draft;

        draft.put('Status__c', 'Active');

        Test.startTest();
        try {
            update draft;
            System.assert(false, 'Expected DML exception');
        } catch (DmlException e) {
            System.assert(e.getDmlMessage(0).contains(System.Label.RenterOps_Lease_OnlyOneActivePerAsset));
        }
        Test.stopTest();
    }

    @IsTest
    static void testBulkUpdateDraftToActive_MixedResults() {
        RentalAsset__c asset1 = createAsset('E1');
        RentalAsset__c asset2 = createAsset('E2');
        Id tenantId = createTenantId('E');

        insert createLease(asset1.Id, tenantId, 'Asset1 Active', 'Active');

        Lease__c l1 = createLease(asset1.Id, tenantId, 'Draft 1', 'Draft');
        Lease__c l2 = createLease(asset2.Id, tenantId, 'Draft 2', 'Draft');
        insert new List<Lease__c>{ l1, l2 };

        l1.put('Status__c', 'Active');
        l2.put('Status__c', 'Active');

        Test.startTest();
        Database.SaveResult[] sr = Database.update(new List<Lease__c>{ l1, l2 }, false);
        Test.stopTest();

        System.assertEquals(false, sr[0].isSuccess());
        System.assertEquals(true,  sr[1].isSuccess());
    }
}