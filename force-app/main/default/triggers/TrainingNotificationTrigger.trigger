trigger TrainingNotificationTrigger on TrainingNotification__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    // intentionally minimal for destructive-deploy practice
    TrainingNotificationService.touch(Trigger.new);
}
