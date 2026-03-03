public with sharing class Tenant360Controller {

    public class TenantRow {
        @AuraEnabled public Id tenantId;
        @AuraEnabled public String tenantName;
        @AuraEnabled public String status;
        @AuraEnabled public String firstName;
        @AuraEnabled public String lastName;
        @AuraEnabled public String email;
        @AuraEnabled public String phone;
        @AuraEnabled public Integer activeLeaseCount;
        @AuraEnabled public Decimal outstandingAmountTotal;
        @AuraEnabled public Date lastPaymentDate;
    }

    @AuraEnabled(cacheable=true)
    public static List<TenantRow> searchTenants(String searchKey) {
        // Rule: search starts after at least 2 characters
        if (String.isBlank(searchKey) || searchKey.trim().length() < 2) {
            return new List<TenantRow>();
        }

        String k = '%' + searchKey.trim() + '%';

        // 1) Find tenants
        List<Tenant__c> tenants = [
            SELECT Id, Name, FirstName__c, LastName__c, Email__c, Phone__c, Status__c
            FROM Tenant__c
            WHERE FirstName__c LIKE :k
               OR LastName__c  LIKE :k
               OR Email__c     LIKE :k
            ORDER BY LastName__c, FirstName__c
            LIMIT 50
        ];

        Set<Id> tenantIds = new Set<Id>();
        for (Tenant__c t : tenants) {
            tenantIds.add(t.Id);
        }

        // 2) Active Lease Count per tenant
        Map<Id, Integer> activeLeaseCountByTenant = new Map<Id, Integer>();
        if (!tenantIds.isEmpty()) {
            for (AggregateResult ar : [
                SELECT Tenant__c tenantId, COUNT(Id) cnt
                FROM Lease__c
                WHERE Tenant__c IN :tenantIds
                  AND Status__c = 'Active'
                GROUP BY Tenant__c
            ]) {
                activeLeaseCountByTenant.put((Id) ar.get('tenantId'), (Integer) ar.get('cnt'));
            }
        }

        // 3) Outstanding Amount Total per tenant (from Invoice.OutstandingAmount__c)
        // Invoice__c -> Lease__c -> Tenant__c
        Map<Id, Decimal> outstandingByTenant = new Map<Id, Decimal>();
        if (!tenantIds.isEmpty()) {
            for (AggregateResult ar : [
                SELECT Lease__r.Tenant__c tenantId, SUM(OutstandingAmount__c) total
                FROM Invoice__c
                WHERE Lease__r.Tenant__c IN :tenantIds
                  AND OutstandingAmount__c > 0
                GROUP BY Lease__r.Tenant__c
            ]) {
                outstandingByTenant.put((Id) ar.get('tenantId'), (Decimal) ar.get('total'));
            }
        }

        // 4) Last Payment Date per tenant (from Payment.PaymentDateTime__c)
        // Safe approach: map invoices to tenants, then aggregate payments by invoice, then roll up to tenant.
        Map<Id, Id> invoiceToTenant = new Map<Id, Id>();
        Set<Id> invoiceIds = new Set<Id>();

        if (!tenantIds.isEmpty()) {
            for (Invoice__c inv : [
                SELECT Id, Lease__r.Tenant__c
                FROM Invoice__c
                WHERE Lease__r.Tenant__c IN :tenantIds
                  AND Lease__c != null
            ]) {
                invoiceIds.add(inv.Id);
                invoiceToTenant.put(inv.Id, inv.Lease__r.Tenant__c);
            }
        }

        Map<Id, Datetime> lastPaymentByTenant = new Map<Id, Datetime>();
        if (!invoiceIds.isEmpty()) {
            for (AggregateResult ar : [
                SELECT Invoice__c invoiceId, MAX(PaymentDateTime__c) lastPay
                FROM Payment__c
                WHERE Invoice__c IN :invoiceIds
                GROUP BY Invoice__c
            ]) {
                Id invId = (Id) ar.get('invoiceId');
                Datetime dt = (Datetime) ar.get('lastPay');
                Id tenantId = invoiceToTenant.get(invId);

                if (tenantId == null || dt == null) continue;

                if (!lastPaymentByTenant.containsKey(tenantId) || dt > lastPaymentByTenant.get(tenantId)) {
                    lastPaymentByTenant.put(tenantId, dt);
                }
            }
        }

        // 5) Build response rows
        List<TenantRow> rows = new List<TenantRow>();
        for (Tenant__c t : tenants) {
            TenantRow r = new TenantRow();
            r.tenantId = t.Id;
            r.tenantName = t.Name;
            r.firstName = t.FirstName__c;
            r.lastName  = t.LastName__c;
            r.email     = t.Email__c;
            r.phone     = t.Phone__c;
            r.status    = t.Status__c;

            r.activeLeaseCount = activeLeaseCountByTenant.containsKey(t.Id)
                ? activeLeaseCountByTenant.get(t.Id)
                : 0;

            r.outstandingAmountTotal = outstandingByTenant.containsKey(t.Id)
                ? outstandingByTenant.get(t.Id)
                : 0;

            r.lastPaymentDate = (lastPaymentByTenant.containsKey(t.Id) && lastPaymentByTenant.get(t.Id) != null)
                ? lastPaymentByTenant.get(t.Id).date()
                : null;

            rows.add(r);
        }

        return rows;
    }
}