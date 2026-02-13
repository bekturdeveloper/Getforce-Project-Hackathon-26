@IsTest
private class AllTriggersDummyDataTest {

    // Add validation-rule required fields here if inserts fail.
    // Example:
    // 'Lease__c' => new Map<String,Object>{ 'Status__c' => 'Active' }
    private static final Map<String, Map<String, Object>> OVERRIDES = new Map<String, Map<String, Object>>{
        // 'RentalAsset__c' => new Map<String,Object>{ 'Status__c' => 'Vacant' }
    };

    // Your trigger list implies these objects.
    private static final List<String> CUSTOM_OBJECTS = new List<String>{
        'RentalAsset__c',
        'Owner__c',
        'MaintenanceRequest__c',
        'Payment__c',
        'Tenant__c',
        'Invoice__c',
        'Lease__c'
    };

    @IsTest
    static void createDummyRecords_fireAllTriggers() {
        Test.startTest();

        // ===== Standard objects =====
        Account acc = new Account(Name = 'TST Account');
        insert acc;

        Contact con = new Contact(LastName = 'TST Contact', AccountId = acc.Id);
        insert con;

        Lead lead = (Lead) RecordFactory.createAndInsert('Lead', new Map<String,Object>{
            'LastName' => 'TST Lead',
            'Company'  => 'TST Company'
            // Status will be auto-filled if required
        });

        Opportunity opp = (Opportunity) RecordFactory.createAndInsert('Opportunity', new Map<String,Object>{
            'Name'      => 'TST Opportunity',
            'AccountId' => acc.Id,
            'CloseDate' => Date.today().addDays(10)
            // StageName will be auto-filled if required
        });

        Case cs = (Case) RecordFactory.createAndInsert('Case', new Map<String,Object>{
            'Subject'   => 'TST Case',
            'AccountId' => acc.Id,
            'ContactId' => con.Id
            // Status/Origin will be auto-filled if required
        });

        // Update standard objects (fire update triggers)
        acc.Name = 'TST Account - U';
        update acc;

        con.LastName = 'TST Contact - U';
        update con;

        lead.Company = 'TST Company - U';
        update lead;

        opp.Name = 'TST Opportunity - U';
        update opp;

        cs.Subject = 'TST Case - U';
        update cs;

        // ===== Custom objects =====
        // Create key records first so we can link later where fields exist
        SObject tenant     = RecordFactory.createAndInsert('Tenant__c', new Map<String,Object>{ 'Name' => 'TST Tenant' });
        SObject asset      = RecordFactory.createAndInsert('RentalAsset__c', new Map<String,Object>{ 'Name' => 'TST Asset' });
        SObject ownerRec   = RecordFactory.createAndInsert('Owner__c', new Map<String,Object>{ 'Name' => 'TST Owner' });

        // Lease often references Tenant + RentalAsset. We set them only if fields exist.
        SObject lease = RecordFactory.createAndInsert('Lease__c', new Map<String,Object>{
            'Name' => 'TST Lease',
            'Tenant__c' => tenant.get('Id'),
            'RentalAsset__c' => asset.get('Id'),
            'Account__c' => acc.Id,
            'Contact__c' => con.Id
        });

        // Invoice often references Lease (and maybe Tenant)
        SObject invoice = RecordFactory.createAndInsert('Invoice__c', new Map<String,Object>{
            'Name' => 'TST Invoice',
            'Lease__c' => lease.get('Id'),
            'Tenant__c' => tenant.get('Id'),
            'Account__c' => acc.Id
        });

        // Payment often references Invoice
        SObject payment = RecordFactory.createAndInsert('Payment__c', new Map<String,Object>{
            'Name' => 'TST Payment',
            'Invoice__c' => invoice.get('Id'),
            'Account__c' => acc.Id
        });

        // Maintenance request often references Asset
        SObject mr = RecordFactory.createAndInsert('MaintenanceRequest__c', new Map<String,Object>{
            'Name' => 'TST Maintenance',
            'RentalAsset__c' => asset.get('Id'),
            'Tenant__c' => tenant.get('Id'),
            'Account__c' => acc.Id
        });

        // Update custom objects (fire update triggers)
        RecordFactory.safeUpdateName(tenant,  'TST Tenant - U');
        RecordFactory.safeUpdateName(asset,   'TST Asset - U');
        RecordFactory.safeUpdateName(ownerRec,'TST Owner - U');
        RecordFactory.safeUpdateName(lease,   'TST Lease - U');
        RecordFactory.safeUpdateName(invoice, 'TST Invoice - U');
        RecordFactory.safeUpdateName(payment, 'TST Payment - U');
        RecordFactory.safeUpdateName(mr,      'TST Maintenance - U');

        Test.stopTest();
    }

    // -----------------------------
    // Helper: creates records by API name, fills schema-required fields, inserts.
    // -----------------------------
    private class RecordFactory {
        private static final Map<String, Id> createdByType = new Map<String, Id>();

        static SObject createAndInsert(String sobjectName, Map<String, Object> preferred) {
            Schema.SObjectType t = Schema.getGlobalDescribe().get(sobjectName);
            System.assertNotEquals(null, t, 'Object not found: ' + sobjectName);

            SObject rec = t.newSObject();

            // Apply preferred values only if field exists
            if (preferred != null) {
                for (String f : preferred.keySet()) {
                    setIfExists(rec, f, preferred.get(f));
                }
            }

            // Apply overrides (validation-rule helpers)
            if (OVERRIDES.containsKey(sobjectName)) {
                for (String f : OVERRIDES.get(sobjectName).keySet()) {
                    setIfExists(rec, f, OVERRIDES.get(sobjectName).get(f));
                }
            }

            // Fill schema-required fields not set yet
            fillSchemaRequired(rec, 0);

            insert rec;

            createdByType.put(sobjectName, (Id)rec.get('Id'));
            return rec;
        }

        static void safeUpdateName(SObject rec, String newName) {
            if (rec == null) return;
            Schema.SObjectType t = rec.getSObjectType();
            Map<String, Schema.SObjectField> fm = t.getDescribe().fields.getMap();
            if (fm.containsKey('Name') && fm.get('Name').getDescribe().isUpdateable()) {
                SObject upd = t.newSObject();
                upd.put('Id', rec.get('Id'));
                upd.put('Name', newName);
                update upd;
            }
        }

        private static void setIfExists(SObject rec, String fieldName, Object value) {
            if (value == null) return;
            Map<String, Schema.SObjectField> fm = rec.getSObjectType().getDescribe().fields.getMap();
            if (!fm.containsKey(fieldName)) return;
            Schema.DescribeFieldResult df = fm.get(fieldName).getDescribe();
            if (!df.isCreateable() && !df.isUpdateable()) return;
            rec.put(fieldName, value);
        }

        private static void fillSchemaRequired(SObject rec, Integer depth) {
            Schema.SObjectType t = rec.getSObjectType();
            String objName = t.getDescribe().getName();
            Map<String, Schema.SObjectField> fm = t.getDescribe().fields.getMap();

            for (String fName : fm.keySet()) {
                Schema.DescribeFieldResult f = fm.get(fName).getDescribe();

                if (!f.isCreateable()) continue;
                if (f.isCalculated() || f.isAutoNumber()) continue;
                if (f.isDefaultedOnCreate()) continue;
                if (f.getName() == 'Id') continue;

                // only fill schema-required (nillable=false) fields that are not already set
                if (!f.isNillable() && rec.get(fName) == null) {
                    Object v = valueForRequiredField(objName, f, depth);
                    if (v != null) rec.put(fName, v);
                }
            }
        }

        private static Object valueForRequiredField(String objName, Schema.DescribeFieldResult f, Integer depth) {
            Schema.DisplayType dt = f.getType();

            if (dt == Schema.DisplayType.Reference) {
                // Best effort to create/attach a referenced record
                List<Schema.SObjectType> refs = f.getReferenceTo();
                if (refs != null && !refs.isEmpty()) {
                    String refName = refs[0].getDescribe().getName();

                    if (refName == 'User') return UserInfo.getUserId();

                    if (refName == 'RecordType') {
                        Id rt = firstRecordTypeId(objName);
                        return rt;
                    }

                    if (createdByType.containsKey(refName)) return createdByType.get(refName);

                    if (depth < 2) {
                        // create referenced record recursively
                        try {
                            SObject refRec = createAndInsert(refName, new Map<String,Object>{ 'Name' => 'TST ' + refName });
                            return refRec.get('Id');
                        } catch (Exception e) {
                            // fallback
                            return UserInfo.getUserId();
                        }
                    }
                }
                return UserInfo.getUserId();
            }

            if (dt == Schema.DisplayType.Boolean) return false;
            if (dt == Schema.DisplayType.Date) return Date.today();
            if (dt == Schema.DisplayType.DateTime) return System.now();
            if (dt == Schema.DisplayType.Time) return Time.newInstance(12, 0, 0, 0);
            if (dt == Schema.DisplayType.Integer) return 1;
            if (dt == Schema.DisplayType.Long) return 1L;
            if (dt == Schema.DisplayType.Double || dt == Schema.DisplayType.Currency || dt == Schema.DisplayType.Percent) return 1;

            if (dt == Schema.DisplayType.Picklist || dt == Schema.DisplayType.MultiPicklist) {
                for (Schema.PicklistEntry pe : f.getPicklistValues()) {
                    if (pe.isActive()) return pe.getValue();
                }
                return null;
            }

            if (dt == Schema.DisplayType.Email) return 'test@example.com';
            if (dt == Schema.DisplayType.Phone) return '+361234567';
            if (dt == Schema.DisplayType.Url) return 'https://example.com';

            if (dt == Schema.DisplayType.TextArea || dt == Schema.DisplayType.LongTextArea || dt == Schema.DisplayType.Html) return 'test';

            if (dt == Schema.DisplayType.String || dt == Schema.DisplayType.EncryptedString) {
                Integer len = f.getLength();
                String v = 'TST_' + objName + '_' + f.getName();
                if (len != null && len > 0 && v.length() > len) v = v.substring(0, len);
                return v;
            }

            return 'X';
        }

        private static Id firstRecordTypeId(String sobjectName) {
            try {
                List<RecordType> rts = [
                    SELECT Id
                    FROM RecordType
                    WHERE SObjectType = :sobjectName AND IsActive = true
                    LIMIT 1
                ];
                return rts.isEmpty() ? null : rts[0].Id;
            } catch (Exception e) {
                return null;
            }
        }
    }
}