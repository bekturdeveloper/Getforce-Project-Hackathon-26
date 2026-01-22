trigger InvoiceTrigger on Invoice__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
new InvoiceTriggerHandler().run();
}
