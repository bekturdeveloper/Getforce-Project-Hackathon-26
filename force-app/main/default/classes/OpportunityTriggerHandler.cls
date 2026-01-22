public class OpportunityTriggerHandler extends TriggerHandler {

private List<Opportunity> newOpportunityList;
private List<Opportunity> oldOpportunityList;
private Map<Id, Opportunity> newOpportunityMap;
private Map<Id, Opportunity> oldOpportunityMap;

public OpportunityTriggerHandler() {
this.newOpportunityList = (List<Opportunity>) Trigger.new;
this.oldOpportunityList = (List<Opportunity>) Trigger.old;
this.newOpportunityMap = (Map<Id, Opportunity>) Trigger.newMap;
this.oldOpportunityMap = (Map<Id, Opportunity>) Trigger.oldMap;
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
