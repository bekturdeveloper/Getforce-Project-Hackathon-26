public class TenantTriggerHandler extends TriggerHandler {

private List<Tenant__c> newTenant__cList;
private List<Tenant__c> oldTenant__cList;
private Map<Id, Tenant__c> newTenant__cMap;
private Map<Id, Tenant__c> oldTenant__cMap;

public TenantTriggerHandler() {
this.newTenant__cList = (List<Tenant__c>) Trigger.new;
this.oldTenant__cList = (List<Tenant__c>) Trigger.old;
this.newTenant__cMap = (Map<Id, Tenant__c>) Trigger.newMap;
this.oldTenant__cMap = (Map<Id, Tenant__c>) Trigger.oldMap;
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
