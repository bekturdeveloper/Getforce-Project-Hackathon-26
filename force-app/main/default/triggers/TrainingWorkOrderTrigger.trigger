trigger TrainingWorkOrderTrigger on TrainingWorkOrder__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    // intentionally minimal for destructive-deploy practice
    TrainingWorkOrderService.touch(Trigger.new);
}
