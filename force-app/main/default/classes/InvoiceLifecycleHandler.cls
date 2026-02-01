public class InvoiceLifecycleHandler {

    public static void handleAfter(
        List<Invoice__c> newList,
        Map<Id, Invoice__c> oldMap,
        Boolean isInsert,
        Boolean isUpdate
    ) {

        // ⛔ защита от рекурсии
        if (InvoiceTriggerState.pdfGenerated) {
            return;
        }

        for (Invoice__c inv : newList) {

            if (inv.Status__c == 'Sent') {

                if (isInsert ||
                   (isUpdate && oldMap.get(inv.Id).Status__c != 'Sent')) {

                    // ✅ помечаем, что PDF уже создан
                    InvoiceTriggerState.pdfGenerated = true;

                    InvoicePdfService.generatePdf(inv.Id);
                }
            }
        }
    }
}