@IsTest
private class TriggerCoverageSmokeTest {
    // Add/remove object API names here.
    // Assumption based on your trigger names:
    // RentalAssetTrigger -> RentalAsset__c, etc.
    private static final List<String> OBJECTS = new List<String>{
        'RentalAsset__c',
        'Owner__c',                 // If your trigger is on a different object, change this name.
        'Lead',
        'MaintenanceRequest__c',
        'Contact',
        'Account',
        'Payment__c',
        'Tenant__c',
        'Opportunity',
        'Invoice__c',
        'Lease__c',
        'Case'
    };

    /**
     * If your org has Validation Rules / required RecordTypes / required lookups not visible in Describe,
     * add them here (object -> field -> value).
     *
     * Example:
     * 'Lease__c' => new Map<String,Object>{
     *   'Status__c' => 'Active',
     *   'RentalAsset__c' => null // don't set null; set an Id if required
     * }
     */
    private static final Map<String, Map<String, Object>> OVERRIDES = new Map<String, Map<String, Object>>{
        // 'RentalAsset__c' => new Map<String,Object>{ 'Status__c' => 'Vacant' }
    };

    @IsTest
    static void smoke_fire_all_triggers() {
        Test.startTest();

        SmokeFactory f = new SmokeFactory();
        for (String objName : OBJECTS) {
            f.exercise(objName);
        }

        Test.stopTest();
    }

    private class SmokeFactory {
        private final Map<String, Id> createdIdsByObject = new Map<String, Id>();

        void exercise(String sobjectName) {
            Schema.SObjectType t = Schema.getGlobalDescribe().get(sobjectName);
            System.assertNotEquals(
                null, t,
                'Object not found: ' + sobjectName + '. Fix OBJECTS list (wrong API name) or metadata not in org.'
            );

            // INSERT (fires before/after insert triggers)
            SObject rec = buildRequired(t, 0);
            insert rec;

            // UPDATE (fires before/after update triggers)
            SObject upd = t.newSObject();
            upd.put('Id', rec.get('Id'));

            String updateField = pickUpdateField(t);
            if (updateField != null) {
                Schema.DescribeFieldResult df = t.getDescribe().fields.getMap().get(updateField).getDescribe();
                upd.put(updateField, nextValueForField(df, rec.get(updateField)));
                update upd;
            }
        }

        private SObject buildRequired(Schema.SObjectType t, Integer depth) {
            String objectName = t.getDescribe().getName();
            SObject sobj = t.newSObject();

            Map<String, Schema.SObjectField> fields = t.getDescribe().fields.getMap();
            for (String fName : fields.keySet()) {
                Schema.DescribeFieldResult f = fields.get(fName).getDescribe();

                if (!f.isCreateable()) continue;
                if (f.isCalculated() || f.isAutoNumber()) continue;
                if (f.getName() == 'Id') continue;
                if (f.isDefaultedOnCreate()) continue;

                // Fill schema-required fields (nillable=false)
                if (!f.isNillable()) {
                    Object v = valueForRequiredField(objectName, f, depth);
                    if (v != null) sobj.put(f.getName(), v);
                }
            }

            // Apply overrides last (they win)
            if (OVERRIDES.containsKey(objectName)) {
                for (String k : OVERRIDES.get(objectName).keySet()) {
                    sobj.put(k, OVERRIDES.get(objectName).get(k));
                }
            }

            return sobj;
        }

        private Object valueForRequiredField(String sobjectName, Schema.DescribeFieldResult f, Integer depth) {
            Schema.DisplayType t = f.getType();

            if (t == Schema.DisplayType.Reference) {
                List<Schema.SObjectType> refs = f.getReferenceTo();
                if (refs != null && !refs.isEmpty()) {
                    String refName = refs[0].getDescribe().getName();

                    if (refName == 'User') return UserInfo.getUserId();

                    if (refName == 'RecordType') {
                        Id rt = firstRecordTypeId(sobjectName);
                        return rt;
                    }

                    if (depth < 2) {
                        return ensure(refName, depth + 1);
                    }
                }
                // Fallback: most required refs accept User
                return UserInfo.getUserId();
            }

            if (t == Schema.DisplayType.Boolean) return false;
            if (t == Schema.DisplayType.Date) return Date.today();
            if (t == Schema.DisplayType.DateTime) return System.now();
            if (t == Schema.DisplayType.Time) return Time.newInstance(12, 0, 0, 0);
            if (t == Schema.DisplayType.Integer) return 1;
            if (t == Schema.DisplayType.Long) return 1L;
            if (t == Schema.DisplayType.Double || t == Schema.DisplayType.Currency || t == Schema.DisplayType.Percent) return 1;

            if (t == Schema.DisplayType.Picklist || t == Schema.DisplayType.MultiPicklist) {
                for (Schema.PicklistEntry pe : f.getPicklistValues()) {
                    if (pe.isActive()) return pe.getValue();
                }
                return null;
            }

            if (t == Schema.DisplayType.Email) return 'test@example.com';
            if (t == Schema.DisplayType.Phone) return '+361234567';
            if (t == Schema.DisplayType.Url) return 'https://example.com';

            if (t == Schema.DisplayType.TextArea || t == Schema.DisplayType.LongTextArea || t == Schema.DisplayType.Html) {
                return 'test';
            }

            if (t == Schema.DisplayType.String || t == Schema.DisplayType.EncryptedString) {
                Integer len = f.getLength();
                String base = 'TEST_' + sobjectName + '_' + f.getName();
                if (len != null && len > 0 && base.length() > len) base = base.substring(0, len);
                return base;
            }

            // Generic fallback
            return 'X';
        }

        private Id ensure(String objectName, Integer depth) {
            if (createdIdsByObject.containsKey(objectName)) return createdIdsByObject.get(objectName);

            Schema.SObjectType t = Schema.getGlobalDescribe().get(objectName);
            if (t == null) return null;

            SObject rec = buildRequired(t, depth);
            insert rec;

            Id idVal = (Id)rec.get('Id');
            createdIdsByObject.put(objectName, idVal);
            return idVal;
        }

        private Id firstRecordTypeId(String sobjectName) {
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

        private String pickUpdateField(Schema.SObjectType t) {
            Map<String, Schema.SObjectField> fields = t.getDescribe().fields.getMap();

            // Prefer common safe fields
            for (String c : new List<String>{ 'Name', 'Subject', 'Description', 'Title', 'Comments' }) {
                if (fields.containsKey(c)) {
                    Schema.DescribeFieldResult f = fields.get(c).getDescribe();
                    if (f.isUpdateable() && !f.isCalculated() && !f.isAutoNumber()) return c;
                }
            }

            // Fallback: first updateable non-required field
            for (String fName : fields.keySet()) {
                Schema.DescribeFieldResult f = fields.get(fName).getDescribe();
                if (f.isUpdateable() && f.isNillable() && !f.isCalculated() && !f.isAutoNumber() && f.getName() != 'Id') {
                    return fName;
                }
            }
            return null;
        }

        private Object nextValueForField(Schema.DescribeFieldResult f, Object oldVal) {
            Schema.DisplayType t = f.getType();

            if (t == Schema.DisplayType.Boolean) return !(oldVal instanceof Boolean ? (Boolean)oldVal : false);
            if (t == Schema.DisplayType.Date) return Date.today().addDays(1);
            if (t == Schema.DisplayType.DateTime) return System.now().addMinutes(1);
            if (t == Schema.DisplayType.Integer) return 2;
            if (t == Schema.DisplayType.Long) return 2L;
            if (t == Schema.DisplayType.Double || t == Schema.DisplayType.Currency || t == Schema.DisplayType.Percent) return 2;

            if (t == Schema.DisplayType.Picklist) {
                List<Schema.PicklistEntry> pls = f.getPicklistValues();
                if (pls.size() > 1) return pls[1].getValue();
                if (pls.size() == 1) return pls[0].getValue();
            }

            return String.valueOf(oldVal) + '_U';
        }
    }
}