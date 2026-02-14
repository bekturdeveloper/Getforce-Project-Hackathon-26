public with sharing class MaintenanceConsoleController {
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getMaintenanceData(String status, String priority, String category, String searchKey) {
        String query = 'SELECT Id, Name, MaintKey__c,  Status__c, Priority__c, Category__c, RequestedAt__c, RentalAsset__r.Name, Tenant__r.Name, VendorName__c, CostEstimate__c FROM MaintenanceRequest__c';
        String countQuery = 'SELECT Status__c, COUNT(Id) total FROM MaintenanceRequest__c';
        
        List<String> filters = new List<String>();
        if (String.isNotBlank(status) && status != 'All') filters.add('Status__c = :status');
        if (String.isNotBlank(priority) && priority != 'All') filters.add('Priority__c = :priority');
        if (String.isNotBlank(category) && category != 'All') filters.add('Category__c = :category');
        if (String.isNotBlank(searchKey)) {
            String key = '%' + searchKey + '%';
            filters.add('(Name LIKE :key OR MaintKey__c LIKE :key OR VendorName__c LIKE :key)');
        }

        String whereClause = filters.isEmpty() ? '' : ' WHERE ' + String.join(filters, ' AND ');
        
       
        List<MaintenanceRequest__c> requests = Database.query(query + whereClause + ' ORDER BY RequestedAt__c DESC LIMIT 25');
        
    
        List<String> kpiFilters = new List<String>();
        if (String.isNotBlank(priority) && priority != 'All') kpiFilters.add('Priority__c = :priority');
        if (String.isNotBlank(category) && category != 'All') kpiFilters.add('Category__c = :category');
        if (String.isNotBlank(searchKey)) {
            String key = '%' + searchKey + '%';
            kpiFilters.add('(Name LIKE :key OR MaintKey__c LIKE :key OR VendorName__c LIKE :key)');
        }
        String kpiWhere = kpiFilters.isEmpty() ? '' : ' WHERE ' + String.join(kpiFilters, ' AND ');
        
        Map<String, Integer> counts = new Map<String, Integer>{'New'=>0, 'InProgress'=>0, 'Closed'=>0};
        for (AggregateResult ar : Database.query(countQuery + kpiWhere + ' GROUP BY Status__c')) {
            counts.put((String)ar.get('Status__c'), (Integer)ar.get('total'));
        }

        return new Map<String, Object>{
            'requests' => requests,
            'counts' => counts
        };
    }

    @AuraEnabled
    public static void updateStatus(Id recordId, String newStatus) {
        update new MaintenanceRequest__c(Id = recordId, Status__c = newStatus);
    }
}