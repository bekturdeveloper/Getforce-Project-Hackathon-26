public class LeaseTriggerHandler extends TriggerHandler {

private List<Lease__c> newLease__cList;
private List<Lease__c> oldLease__cList;
private Map<Id, Lease__c> newLease__cMap;
private Map<Id, Lease__c> oldLease__cMap;

public LeaseTriggerHandler() {
this.newLease__cList = (List<Lease__c>) Trigger.new;
this.oldLease__cList = (List<Lease__c>) Trigger.old;
this.newLease__cMap = (Map<Id, Lease__c>) Trigger.newMap;
this.oldLease__cMap = (Map<Id, Lease__c>) Trigger.oldMap;
}

public override void beforeInsert() {

}

public override void afterInsert() {

}

public override void beforeUpdate() {

}

public override void afterUpdate() {

}

public override void beforeDelete() {

}

public override void afterDelete() {

}

public override void afterUndelete() {

}

}
