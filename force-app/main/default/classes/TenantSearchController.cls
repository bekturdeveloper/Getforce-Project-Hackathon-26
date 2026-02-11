public with sharing class TenantSearchController {

    @AuraEnabled(cacheable=true)
    public static List<Tenant__c> searchTenants(String keyword) {

        String searchText = '%' + keyword + '%';

        return [
            SELECT Id, Name, Email__c, Phone__c, Status__c
            FROM Tenant__c
            WHERE Name LIKE :searchText
               OR Email__c LIKE :searchText
               OR Phone__c LIKE :searchText
            LIMIT 50
        ];
    }
}
