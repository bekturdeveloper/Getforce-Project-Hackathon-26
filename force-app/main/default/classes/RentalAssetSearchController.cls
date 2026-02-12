public with sharing class RentalAssetSearchController {

    @AuraEnabled(cacheable=true)
    public static List<RentalAsset__c> searchAssets(
        String city,
        String availability,
        Integer minBedrooms,
        Integer maxBedrooms,
        Decimal maxRent
    ) {
        String baseQuery =
            'SELECT Id, Name, City__c, AvailabilityStatus__c, Bedrooms__c, MarketRent__c ' +
            'FROM RentalAsset__c WHERE City__c != NULL';

        if (city != null) {
            baseQuery += ' AND City__c = :city';
        }
        if (availability != null) {
            baseQuery += ' AND AvailabilityStatus__c = :availability';
        }
        if (minBedrooms != null) {
            baseQuery += ' AND Bedrooms__c >= :minBedrooms';
        }
        if (maxBedrooms != null) {
            baseQuery += ' AND Bedrooms__c <= :maxBedrooms';
        }
        if (maxRent != null) {
            baseQuery += ' AND MarketRent__c <= :maxRent';
        }

        return Database.query(baseQuery);
    }
}