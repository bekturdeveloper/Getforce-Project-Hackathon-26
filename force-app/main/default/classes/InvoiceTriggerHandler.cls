public class InvoiceTriggerHandler extends TriggerHandler {

private List<Invoice__c> newInvoice__cList;
private List<Invoice__c> oldInvoice__cList;
private Map<Id, Invoice__c> newInvoice__cMap;
private Map<Id, Invoice__c> oldInvoice__cMap;

public InvoiceTriggerHandler() {
this.newInvoice__cList = (List<Invoice__c>) Trigger.new;
this.oldInvoice__cList = (List<Invoice__c>) Trigger.old;
this.newInvoice__cMap = (Map<Id, Invoice__c>) Trigger.newMap;
this.oldInvoice__cMap = (Map<Id, Invoice__c>) Trigger.oldMap;
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
