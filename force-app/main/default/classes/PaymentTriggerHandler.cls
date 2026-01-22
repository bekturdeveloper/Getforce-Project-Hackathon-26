public class PaymentTriggerHandler extends TriggerHandler {

private List<Payment__c> newPayment__cList;
private List<Payment__c> oldPayment__cList;
private Map<Id, Payment__c> newPayment__cMap;
private Map<Id, Payment__c> oldPayment__cMap;

public PaymentTriggerHandler() {
this.newPayment__cList = (List<Payment__c>) Trigger.new;
this.oldPayment__cList = (List<Payment__c>) Trigger.old;
this.newPayment__cMap = (Map<Id, Payment__c>) Trigger.newMap;
this.oldPayment__cMap = (Map<Id, Payment__c>) Trigger.oldMap;
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
