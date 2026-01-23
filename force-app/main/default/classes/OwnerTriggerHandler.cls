public class OwnerTriggerHandler extends TriggerHandler {

private List<Owner__c> newOwnerList;
private List<Owner__c> oldOwnerList;
private Map<Id, Owner__c> newOwnerMap;
private Map<Id, Owner__c> oldOwnerMap;

public OwnerTriggerHandler() {
this.newOwnerList = (List<Owner__c>) Trigger.new;
this.oldOwnerList = (List<Owner__c>) Trigger.old;
this.newOwnerMap = (Map<Id, Owner__c>) Trigger.newMap;
this.oldOwnerMap = (Map<Id, Owner__c>) Trigger.oldMap;
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
