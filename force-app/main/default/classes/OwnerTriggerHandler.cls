public class OwnerTriggerHandler extends TriggerHandler {

private List<Owner__c> newOwner__cList;
private List<Owner__c> oldOwner__cList;
private Map<Id, Owner__c> newOwner__cMap;
private Map<Id, Owner__c> oldOwner__cMap;

public OwnerTriggerHandler() {
this.newOwner__cList = (List<Owner__c>) Trigger.new;
this.oldOwner__cList = (List<Owner__c>) Trigger.old;
this.newOwner__cMap = (Map<Id, Owner__c>) Trigger.newMap;
this.oldOwner__cMap = (Map<Id, Owner__c>) Trigger.oldMap;
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
