public with sharing class LeaseService {

/**
* Demonstrative method to show where put trigger logic.
*
* @param oldMap old records
* @param newMap new records
*/
public static void enforceOnlyOneActivePerAsset(Map<Id, Lease__c> oldMap, list<Lease__c> newList) {
// your logic is here.

        if (newList == null || newList.isEmpty()) return;

        Set<Id> assetIds = new Set<Id>();
        Set<Id> triggerLeaseIds = new Set<Id>();

        // 1️⃣ Collect assets for leases being activated
        for (Lease__c lease : newList) {
            triggerLeaseIds.add(lease.Id);

            Boolean isBecomingActive =
                lease.Status__c == 'Active' &&
                lease.RentalAsset__c != null &&
                (
                    oldMap == null ||
                    !oldMap.containsKey(lease.Id) ||
                    oldMap.get(lease.Id).Status__c != 'Active'
                );

            if (isBecomingActive) {
                assetIds.add(lease.RentalAsset__c);
            }
        }

        if (assetIds.isEmpty()) return;

        // 2️⃣ Find existing active leases
        Map<Id, Id> assetToActiveLease = new Map<Id, Id>();

        for (Lease__c existing : [
            SELECT Id, RentalAsset__c
            FROM Lease__c
            WHERE Status__c = 'Active'
            AND RentalAsset__c IN :assetIds
        ]) {
            assetToActiveLease.put(
                existing.RentalAsset__c,
                existing.Id
            );
        }

        // 3️⃣ Block duplicates
        for (Lease__c lease : newList) {
            if (
                lease.Status__c == 'Active' &&
                lease.RentalAsset__c != null &&
                assetToActiveLease.containsKey(lease.RentalAsset__c) &&
                assetToActiveLease.get(lease.RentalAsset__c) != lease.Id
            ) {
                lease.addError(
                    System.Label.RenterOps_Lease_OnlyOneActivePerAsset
                );
            }
        }
}
}