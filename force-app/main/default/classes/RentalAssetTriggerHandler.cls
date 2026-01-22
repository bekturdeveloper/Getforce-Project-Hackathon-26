public class RentalAssetTriggerHandler extends TriggerHandler {

private List<RentalAsset__c> newRentalAsset__cList;
private List<RentalAsset__c> oldRentalAsset__cList;
private Map<Id, RentalAsset__c> newRentalAsset__cMap;
private Map<Id, RentalAsset__c> oldRentalAsset__cMap;

public RentalAssetTriggerHandler() {
this.newRentalAsset__cList = (List<RentalAsset__c>) Trigger.new;
this.oldRentalAsset__cList = (List<RentalAsset__c>) Trigger.old;
this.newRentalAsset__cMap = (Map<Id, RentalAsset__c>) Trigger.newMap;
this.oldRentalAsset__cMap = (Map<Id, RentalAsset__c>) Trigger.oldMap;
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
