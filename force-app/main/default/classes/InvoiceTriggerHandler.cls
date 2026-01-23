public class InvoiceTriggerHandler extends TriggerHandler {

private List<Invoice__c> newInvoiceList;
private List<Invoice__c> oldInvoiceList;
private Map<Id, Invoice__c> newInvoiceMap;
private Map<Id, Invoice__c> oldInvoiceMap;

public InvoiceTriggerHandler() {
this.newInvoiceList = (List<Invoice__c>) Trigger.new;
this.oldInvoiceList = (List<Invoice__c>) Trigger.old;
this.newInvoiceMap = (Map<Id, Invoice__c>) Trigger.newMap;
this.oldInvoiceMap = (Map<Id, Invoice__c>) Trigger.oldMap;
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
