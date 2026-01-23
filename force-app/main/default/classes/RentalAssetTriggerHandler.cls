public class RentalAssetTriggerHandler extends TriggerHandler {

private List<RentalAsset__c> newRentalAssetList;
private List<RentalAsset__c> oldRentalAssetList;
private Map<Id, RentalAsset__c> newRentalAssetMap;
private Map<Id, RentalAsset__c> oldRentalAssetMap;

public RentalAssetTriggerHandler() {
this.newRentalAssetList = (List<RentalAsset__c>) Trigger.new;
this.oldRentalAssetList = (List<RentalAsset__c>) Trigger.old;
this.newRentalAssetMap = (Map<Id, RentalAsset__c>) Trigger.newMap;
this.oldRentalAssetMap = (Map<Id, RentalAsset__c>) Trigger.oldMap;
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
