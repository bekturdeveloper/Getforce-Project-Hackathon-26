public with sharing class RO_FxFuture {

    @future(callout=true)
    public static void updatePayments(Set<Id> paymentIds) {

        if(paymentIds.isEmpty()) return;

        RO_CurrencyConfig__mdt cfg =
            RO_CurrencyConfig__mdt.getInstance('Default');

        String baseCurrency = cfg.BaseCurrency__c;

        List<Payment__c> payments = [
            SELECT Id, Amount__c, CurrencyCode__c
            FROM Payment__c
            WHERE Id IN :paymentIds
        ];

        Map<String, List<Payment__c>> byCurrency =
            new Map<String, List<Payment__c>>();

        for(Payment__c p : payments) {
            if(!byCurrency.containsKey(p.CurrencyCode__c))
                byCurrency.put(p.CurrencyCode__c, new List<Payment__c>());

            byCurrency.get(p.CurrencyCode__c).add(p);
        }

        List<Payment__c> updates = new List<Payment__c>();

        Http http = new Http();

        for(String fromCur : byCurrency.keySet()) {

            try {

                String endpoint =
                    'callout:FreeCurrencyAPI/v1/latest'
                    + '?base_currency=' + fromCur
                    + '&currencies=' + baseCurrency;

                HttpRequest req = new HttpRequest();
                req.setEndpoint(endpoint);
                req.setMethod('GET');

                HttpResponse res = http.send(req);

                if(res.getStatusCode() != 200)
                    throw new CalloutException(res.getBody());

                Map<String,Object> parsed =
                    (Map<String,Object>) JSON.deserializeUntyped(res.getBody());

                Map<String,Object> data =
                    (Map<String,Object>) parsed.get('data');

                Decimal rate =
                    Decimal.valueOf(String.valueOf(data.get(baseCurrency)));

                for(Payment__c p : byCurrency.get(fromCur)) {

                    updates.add(new Payment__c(
                        Id = p.Id,
                        FxRate__c = rate,
                        AmountInBase__c =
                            (p.Amount__c * rate).setScale(2),
                        FxStatus__c = 'Success',
                        FxLastUpdatedAt__c = System.now(),
                        FxError__c = null
                    ));
                }

            } catch(Exception e) {

                for(Payment__c p : byCurrency.get(fromCur)) {
                    updates.add(new Payment__c(
                        Id = p.Id,
                        FxStatus__c = 'Failed',
                        FxError__c = e.getMessage(),
                        FxLastUpdatedAt__c = System.now()
                    ));
                }
            }
        }

        if(!updates.isEmpty())
            update updates;
    }
}
