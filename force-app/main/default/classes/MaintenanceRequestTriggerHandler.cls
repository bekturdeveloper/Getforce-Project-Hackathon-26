public class MaintenanceRequestTriggerHandler extends TriggerHandler {

private List<MaintenanceRequest__c> newMaintenanceRequest__cList;
private List<MaintenanceRequest__c> oldMaintenanceRequest__cList;
private Map<Id, MaintenanceRequest__c> newMaintenanceRequest__cMap;
private Map<Id, MaintenanceRequest__c> oldMaintenanceRequest__cMap;

public MaintenanceRequestTriggerHandler() {
this.newMaintenanceRequest__cList = (List<MaintenanceRequest__c>) Trigger.new;
this.oldMaintenanceRequest__cList = (List<MaintenanceRequest__c>) Trigger.old;
this.newMaintenanceRequest__cMap = (Map<Id, MaintenanceRequest__c>) Trigger.newMap;
this.oldMaintenanceRequest__cMap = (Map<Id, MaintenanceRequest__c>) Trigger.oldMap;
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
