public class LeaseTriggerHandler extends TriggerHandler {

    private List<Lease__c> newLeaseList;
    private Map<Id, Lease__c> oldLeaseMap;

    public LeaseTriggerHandler() {
        this.newLeaseList = (List<Lease__c>) Trigger.new;
        this.oldLeaseMap  = (Map<Id, Lease__c>) Trigger.oldMap;
    }

    public override void beforeInsert() {
        LeaseService.enforceOnlyOneActivePerAsset(null, newLeaseList);
    }

    public override void beforeUpdate() {
        LeaseService.enforceOnlyOneActivePerAsset(oldLeaseMap, newLeaseList);
    }
}