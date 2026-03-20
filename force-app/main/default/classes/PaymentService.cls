public with sharing class PaymentService {

    // recursion guard
    private static Boolean isRunning = false;

    // Fast path - before trigger

    public static void processFastPathBefore(
        List<Payment__c> newList
    ) {
        processFastPathBefore(newList, null);
    }

    public static void processFastPathBefore(
        List<Payment__c> newList,
        Map<Id, Payment__c> oldMap
    ) {
        if(newList == null || newList.isEmpty()) return;

        RO_CurrencyConfig__mdt cfg =
            RO_CurrencyConfig__mdt.getInstance('Default');

        String baseCurrency = cfg.BaseCurrency__c;

        for(Payment__c p : newList) {

            if(p.Amount__c == null || p.CurrencyCode__c == null)
                continue;

            Boolean amountChanged =
                oldMap == null ||
                p.Amount__c != oldMap.get(p.Id)?.Amount__c;

            Boolean currencyChanged =
                oldMap == null ||
                p.CurrencyCode__c != oldMap.get(p.Id)?.CurrencyCode__c;

            if(String.valueOf(p.CurrencyCode__c) == baseCurrency &&
            (amountChanged || currencyChanged || p.FxRate__c == null)) {

                p.FxRate__c = 1;
                p.AmountInBase__c = p.Amount__c;
                p.FxStatus__c = 'Success';
                p.FxLastUpdatedAt__c = System.now();
                p.FxError__c = null;
            }
        }
    }


// After trigger - enqueue future 

    public static void processFxUpdates(
        Map<Id, Payment__c> oldMap,
        Map<Id, Payment__c> newMap
    ) {
        if(isRunning) return;
        isRunning = true;

        try {

            if(newMap == null || newMap.isEmpty()) return;

            RO_CurrencyConfig__mdt cfg =
                RO_CurrencyConfig__mdt.getInstance('Default');

            String baseCurrency = cfg.BaseCurrency__c;

            Set<Id> toUpdateFuture = new Set<Id>();

            for(Payment__c p : newMap.values()) {

                if(p.Amount__c == null || p.CurrencyCode__c == null)
                    continue;

                Boolean amountChanged =
                    oldMap == null ||
                    p.Amount__c != oldMap.get(p.Id)?.Amount__c;

                Boolean currencyChanged =
                    oldMap == null ||
                    p.CurrencyCode__c != oldMap.get(p.Id)?.CurrencyCode__c;

                Boolean needsFx =
                p.CurrencyCode__c != baseCurrency &&
                (
                p.FxRate__c == null ||
                p.AmountInBase__c == null ||
                amountChanged ||
                currencyChanged
    );

if(needsFx) {
    toUpdateFuture.add(p.Id);
}}

        if(!toUpdateFuture.isEmpty()
            && !System.isFuture()
            && !System.isBatch()
            && !System.isQueueable()) {
        RO_FxFuture.updatePayments(toUpdateFuture);
        }

        }finally {
            isRunning = false;
        }
    }
    }