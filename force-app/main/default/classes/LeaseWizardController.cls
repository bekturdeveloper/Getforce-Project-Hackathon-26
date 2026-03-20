public with sharing class LeaseWizardController {

    @AuraEnabled
    public static Boolean hasOverlappingLease(
        Id assetId,
        Date startDate,
        Date endDate
    ) {
        if (assetId == null || startDate == null || endDate == null) {
            return false;
        }

        List<Lease__c> leases = [
            SELECT Id
            FROM Lease__c
            WHERE RentalAsset__c = :assetId
            AND Status__c = 'Active'
            AND (
                (StartDate__c <= :endDate AND EndDate__c >= :startDate)
            )
            LIMIT 1
        ];

        return !leases.isEmpty();
    }

    @AuraEnabled
    public static Id createLease(
        Id tenantId,
        Id assetId,
        Date startDate,
        Date endDate,
        Decimal monthlyRent,
        Integer dueDay
    ) {
        try {
            Lease__c lease = new Lease__c(
                Tenant__c = tenantId,
                RentalAsset__c = assetId,
                StartDate__c = startDate,
                EndDate__c = endDate,
                MonthlyRent__c = monthlyRent,
                DueDayOfMonth__c = dueDay,
                Status__c = 'Active'
            );
            insert lease;

            RentalAsset__c asset = new RentalAsset__c(
            Id = assetId,
            AvailabilityStatus__c = 'Occupied'
            );

            update asset;
            return lease.Id;
            
        } catch (DmlException e) {
            throw new AuraHandledException('Failed to create Lease: ' + e.getMessage());
        }

    }
}