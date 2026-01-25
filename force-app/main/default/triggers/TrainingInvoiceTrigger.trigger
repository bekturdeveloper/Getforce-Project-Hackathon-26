trigger TrainingInvoiceTrigger on TrainingInvoice__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    // intentionally minimal for destructive-deploy practice
    TrainingInvoiceService.touch(Trigger.new);
}
