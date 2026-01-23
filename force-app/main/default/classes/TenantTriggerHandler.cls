public class TenantTriggerHandler extends TriggerHandler {

private List<Tenant__c> newTenantList;
private List<Tenant__c> oldTenantList;
private Map<Id, Tenant__c> newTenantMap;
private Map<Id, Tenant__c> oldTenantMap;

public TenantTriggerHandler() {
this.newTenantList = (List<Tenant__c>) Trigger.new;
this.oldTenantList = (List<Tenant__c>) Trigger.old;
this.newTenantMap = (Map<Id, Tenant__c>) Trigger.newMap;
this.oldTenantMap = (Map<Id, Tenant__c>) Trigger.oldMap;
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
