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
}
