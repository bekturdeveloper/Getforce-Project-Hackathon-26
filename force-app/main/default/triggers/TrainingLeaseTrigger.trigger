trigger TrainingLeaseTrigger on TrainingLease__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    // intentionally minimal for destructive-deploy practice
    TrainingLeaseService.touch(Trigger.new);
}
