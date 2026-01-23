public class PaymentTriggerHandler extends TriggerHandler {

private List<Payment__c> newPaymentList;
private List<Payment__c> oldPaymentList;
private Map<Id, Payment__c> newPaymentMap;
private Map<Id, Payment__c> oldPaymentMap;

public PaymentTriggerHandler() {
this.newPaymentList = (List<Payment__c>) Trigger.new;
this.oldPaymentList = (List<Payment__c>) Trigger.old;
this.newPaymentMap = (Map<Id, Payment__c>) Trigger.newMap;
this.oldPaymentMap = (Map<Id, Payment__c>) Trigger.oldMap;
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
