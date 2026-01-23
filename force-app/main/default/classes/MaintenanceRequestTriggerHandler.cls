public class MaintenanceRequestTriggerHandler extends TriggerHandler {

private List<MaintenanceRequest__c> newMaintenanceRequestList;
private List<MaintenanceRequest__c> oldMaintenanceRequestList;
private Map<Id, MaintenanceRequest__c> newMaintenanceRequestMap;
private Map<Id, MaintenanceRequest__c> oldMaintenanceRequestMap;

public MaintenanceRequestTriggerHandler() {
this.newMaintenanceRequestList = (List<MaintenanceRequest__c>) Trigger.new;
this.oldMaintenanceRequestList = (List<MaintenanceRequest__c>) Trigger.old;
this.newMaintenanceRequestMap = (Map<Id, MaintenanceRequest__c>) Trigger.newMap;
this.oldMaintenanceRequestMap = (Map<Id, MaintenanceRequest__c>) Trigger.oldMap;
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
