@IsTest(SeeAllData=false)
private class MaintenanceRequestServiceTest {

//@IsTest
//static void demonstrativeMethodTest() {

//}
    @TestSetup
    static void setup() {
      
        User u = TestDataFactory.createTestUser();
        insert u;

        System.runAs(u) {
            Owner__c testOwner = TestDataFactory.createOwner(true);

            RentalAsset__c asset = TestDataFactory.createAsset(testOwner.Id, true);

            List<MaintenanceRequest__c> initialReqs = TestDataFactory.createRequests(5, 'New', asset.Id);
            insert initialReqs;
        }
    }

    @isTest
    static void testBulkCloseAndPdfGeneration() {
        User u = [SELECT Id FROM User WHERE Alias='maint' LIMIT 1];
        RentalAsset__c asset = [SELECT Id FROM RentalAsset__c LIMIT 1];
        
        System.runAs(u) {
           
            List<MaintenanceRequest__c> bulkReqs = TestDataFactory.createRequests(200, 'New', asset.Id);
            insert bulkReqs;

            for(MaintenanceRequest__c r : bulkReqs) {
                r.Status__c = 'Closed';
            }

            Test.startTest();
            update bulkReqs;
            Test.stopTest(); 
           
            
            Integer fileCount = [SELECT count() FROM ContentVersion WHERE Title LIKE 'ClosureReport_%'];
            System.assertEquals(200, fileCount, 'Exactly 205 PDF files should have been generated.');
        }
    }

    @isTest
    static void TestNonClosedUpdate(){
        User u = [SELECT Id FROM User WHERE Alias='maint' LIMIT 1];
        
        MaintenanceRequest__c req = [SELECT Id, Status__c, Description__c FROM MaintenanceRequest__c LIMIT 1];

        req.Description__c = 'Just a simple update';
        req.Status__c = 'New';

        Test.startTest();
        update req;
        Test.stopTest();

        Integer fileCount = [SELECT count() FROM ContentVersion WHERE Title LIKE 'ClosureReport_%'];
        System.assertEquals(0, fileCount, 'PDF should not be created for non-closed status');
    }

    @isTest
static void testFullCoverageScenarios() {
    User u = [SELECT Id FROM User WHERE Alias='maint' LIMIT 1];
    RentalAsset__c asset = [SELECT Id FROM RentalAsset__c LIMIT 1];
    
    System.runAs(u) {
        
        MaintenanceRequest__c req = TestDataFactory.createRequests(1, 'New', asset.Id)[0];
        insert req; 

        Test.startTest();
    
        req.Description__c = 'Testing coverage for no status change';
        update req;
       
        req.Status__c = 'Closed';
        update req;

        req.Description__c = 'Updating a closed record';
        update req;
        Test.stopTest();

       
        Integer fileCount = [SELECT count() FROM ContentVersion WHERE Title LIKE 'ClosureReport_%'];
        System.assert(fileCount > 0, 'At least one PDF should be generated');
    }
}
}