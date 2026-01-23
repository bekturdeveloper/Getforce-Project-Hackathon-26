public class LeaseTriggerHandler extends TriggerHandler {

private List<Lease__c> newLeaseList;
private List<Lease__c> oldLeaseList;
private Map<Id, Lease__c> newLeaseMap;
private Map<Id, Lease__c> oldLeaseMap;

public LeaseTriggerHandler() {
this.newLeaseList = (List<Lease__c>) Trigger.new;
this.oldLeaseList = (List<Lease__c>) Trigger.old;
this.newLeaseMap = (Map<Id, Lease__c>) Trigger.newMap;
this.oldLeaseMap = (Map<Id, Lease__c>) Trigger.oldMap;
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
