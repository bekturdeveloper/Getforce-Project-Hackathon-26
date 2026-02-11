public with sharing class RentalAssetOperationsController {

    @AuraEnabled(cacheable=true)
    public static RentalAsset__c getAsset(Id recordId) {
        return [
            SELECT Id, Name,
                   UnitLabel__c,
                   AssetType__c,
                   AvailabilityStatus__c,
                   City__c,
                   Street__c,
                   Bedrooms__c,
                   SizeSqm__c,
                   MarketRent__c
            FROM RentalAsset__c
            WHERE Id = :recordId
            LIMIT 1
        ];
    }

    @AuraEnabled(cacheable=true)
    public static Lease__c getActiveLease(Id assetId) {

        List<Lease__c> leases = [
            SELECT Id, Name,
                   Tenant__c,
                   Tenant__r.Name,
                   StartDate__c,
                   EndDate__c,
                   MonthlyRent__c,
                   Status__c
            FROM Lease__c
            WHERE RentalAsset__c = :assetId
            AND Status__c = 'Active'
            ORDER BY StartDate__c DESC
            LIMIT 1
        ];

        return leases.isEmpty() ? null : leases[0];
    }

    @AuraEnabled(cacheable=true)
    public static List<MaintenanceRequest__c> getOpenMaintenance(Id assetId) {

        return [
            SELECT Id, Name,
                   Category__c,
                   Priority__c,
                   Status__c,
                   RequestedAt__c,
                   VendorName__c,
                   CostEstimate__c
            FROM MaintenanceRequest__c
            WHERE RentalAsset__c = :assetId
            AND Status__c NOT IN ('Closed','Completed')
            ORDER BY RequestedAt__c DESC
            LIMIT 10
        ];
    }
}