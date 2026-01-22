trigger OwnerTrigger on Owner__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
new OwnerTriggerHandler().run();
}
