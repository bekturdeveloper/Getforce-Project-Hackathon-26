public with sharing class LeaseService {

/**
* Demonstrative method to show where put trigger logic.
*
* @param oldMap old records
* @param newMap new records
*/
// public static void demonstrativeMethod(Map<Id, Lease__c> oldMap, Map<Id, Lease__c> newMap) {
// your logic is here.
//}

public static void RenterOpsLeaseDeleteBlockedFinancials(List<Lease__c> oldLeases) {
        
        Set<Id> leasesWithInvoices = new Set<Id>();
        
        for (Invoice__c inv : [SELECT Lease__c FROM Invoice__c WHERE Lease__c IN :oldLeases]) {
            leasesWithInvoices.add(inv.Lease__c);
        }

        
        for (Lease__c lease : oldLeases) {
            if (leasesWithInvoices.contains(lease.Id)) {
                lease.addError(System.Label.RenterOps_Lease_DeleteBlocked_Financials);
            }
        }
    } 

    public static void blockAssetChangeWithInvoices(Map<Id, Lease__c> oldMap, Map<Id, Lease__c> newMap) {

        Set<Id> leaseIdsToCheck = new Set<Id>();

        // 1. Collect IDs of leases where RentalAsset has changed
        for (Id leaseId : newMap.keySet()) {
            Lease__c newLease = newMap.get(leaseId);
            Lease__c oldLease = oldMap.get(leaseId);
            if (newLease.RentalAsset__c != oldLease.RentalAsset__c) {
                leaseIdsToCheck.add(leaseId);
            }
        }

        if (leaseIdsToCheck.isEmpty()) return;

        // 2. Check if there are related invoices with Status = 'Paid'
        Set<Id> leasesWithPaidInvoices = new Set<Id>();
        for (Invoice__c inv : [
            SELECT Lease__c
            FROM Invoice__c
            WHERE Lease__c IN :leaseIdsToCheck
            AND Status__c = 'Paid'
        ]) {
            leasesWithPaidInvoices.add(inv.Lease__c);
        }

        // 3. Block the RentalAsset change for leases that have Paid invoices
        for (Id leaseId : leaseIdsToCheck) {
            if (leasesWithPaidInvoices.contains(leaseId)) {
                Lease__c lease = newMap.get(leaseId);
                lease.RentalAsset__c.addError(Label.RenterOps_Lease_AssetChangeBlocked_Invoices);
            }
        }
    }
}
