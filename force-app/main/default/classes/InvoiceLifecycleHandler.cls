public class InvoiceLifecycleHandler {

    public static void handleAfter(
        List<Invoice__c> newList,
        Map<Id, Invoice__c> oldMap,
        Boolean isInsert,
        Boolean isUpdate
    ) {
        for (Invoice__c inv : newList) {

            if (inv.Status__c == 'Sent') {

                if (isInsert) {
                    InvoicePdfService.generatePdf(inv.Id);
                }

                if (isUpdate) {
                    Invoice__c oldInv = oldMap.get(inv.Id);
                    if (oldInv.Status__c != 'Sent') {
                        InvoicePdfService.generatePdf(inv.Id);
                    }
                }
            }
        }
    }
}