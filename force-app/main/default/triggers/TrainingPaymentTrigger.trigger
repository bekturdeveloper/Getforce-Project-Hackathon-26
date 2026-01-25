trigger TrainingPaymentTrigger on TrainingPayment__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    // intentionally minimal for destructive-deploy practice
    TrainingPaymentService.touch(Trigger.new);
}
