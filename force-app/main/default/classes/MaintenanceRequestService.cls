public with sharing class MaintenanceRequestService {
/**
* Demonstrative method to show where put trigger logic.
*
* @param oldMap old records
* @param newMap new records
*/
//public static void demonstrativeMethod(Map<Id, MaintenanceRequest__c> oldMap, Map<Id, MaintenanceRequest__c> newMap) {
// your logic is here.
//}

   public static void AutoCreateMaintenanceCompletionPDFWhenRequestIsClosed(List<MaintenanceRequest__c> MaintenanceRequestList, Map<Id, MaintenanceRequest__c> oldMap) {

    Set<ID> MaintenanceRequestSetID = new Set<ID>();

    for(MaintenanceRequest__c reqFor : MaintenanceRequestList){
        MaintenanceRequest__c oldManReq = oldMap.get(reqFor.Id);

        if(reqFor.Status__c == 'Closed' && oldManReq.Status__c != 'Closed'){
            MaintenanceRequestSetID.add(reqFor.Id);
        }
    }
     if (!MaintenanceRequestSetID.isEmpty()){
            generatePDF(MaintenanceRequestSetID);
        }
}

      @future
    private static void generatePDF(Set<Id> requestIds) {
        
        List<MaintenanceRequest__c> requests = [SELECT Id, Name, Status__c, Tenant__c, RentalAsset__c, 
                                                 VendorName__c, RequestedAt__c, ClosureReportFileId__c 
                                                 FROM MaintenanceRequest__c WHERE Id IN :requestIds];
        
        List<ContentVersion> filesToInsert = new List<ContentVersion>();
        Map<Id, ContentVersion> reqToNewCV = new Map<Id, ContentVersion>();

        Map<Id, Id> cvToDocMap = new Map<Id, Id>();
        Set<Id> existingCVIds = new Set<Id>();
        for(MaintenanceRequest__c r : requests) {
            if(r.ClosureReportFileId__c != null) {
                existingCVIds.add(r.ClosureReportFileId__c);
            }
        }
        
        if(!existingCVIds.isEmpty()) {
            for(ContentVersion cv : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :existingCVIds]) {
                cvToDocMap.put(cv.Id, cv.ContentDocumentId);
            }
        }

        for (MaintenanceRequest__c req : requests) {
            String htmlBody = '<html><body>' +
                              '<h1>Maintenance Completion Report</h1>' +
                              '<p><b>Request:</b> ' + req.Name + '</p>' +
                              '<p><b>Asset:</b> ' + req.RentalAsset__c + '</p>' +
                              '<p><b>Vendor:</b> ' + req.VendorName__c + '</p>' +
                              '<p><b>Date:</b> ' + req.RequestedAt__c + '</p>' +
                              '<p>Generated via Blob.toPdf() in Spring ’26.</p>' +
                              '</body></html>';

            Blob pdfBlob = Blob.toPdf(htmlBody); 

            ContentVersion cv = new ContentVersion();
            cv.Title = 'ClosureReport_' + req.Name;
            cv.PathOnClient = 'ClosureReport.pdf';
            cv.VersionData = pdfBlob;
            cv.IsMajorVersion = true;

           
            if (req.ClosureReportFileId__c != null && cvToDocMap.containsKey(req.ClosureReportFileId__c)) {
                cv.ContentDocumentId = cvToDocMap.get(req.ClosureReportFileId__c);
            } else {
               
                cv.FirstPublishLocationId = req.Id;
            }
            
            reqToNewCV.put(req.Id, cv);
        }

        insert reqToNewCV.values();

  
        List<MaintenanceRequest__c> updates = new List<MaintenanceRequest__c>();
        for (Id reqId : reqToNewCV.keySet()) {
            updates.add(new MaintenanceRequest__c(
                Id = reqId,
                ClosureReportFileId__c = reqToNewCV.get(reqId).Id
            ));
        }
        update updates;
    }
}