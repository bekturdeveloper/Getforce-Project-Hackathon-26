@isTest
public class RO_FxFuture_Test {

// Mock success

    class FxApiMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type','application/json');
            res.setBody('{ "data": { "USD": 1.1 } }');
            return res;
        }
    }

// Mock failure

    class FxApiMockFail implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('error');
            return res;
        }
    }

// Single insert EUR → USD

    @isTest
    static void testSingleInsertFxSuccess() {
        Test.setMock(HttpCalloutMock.class, new FxApiMock());

        Test.startTest();
        Payment__c p = TestDataFactory.createPayment(100, 'EUR', true);
        Test.stopTest();

        p = [SELECT FxRate__c, AmountInBase__c, FxStatus__c
             FROM Payment__c
             WHERE Id = :p.Id];

        System.assertEquals(1.1, p.FxRate__c, 'FxRate should match mock rate');
        System.assertEquals(110, p.AmountInBase__c, 'AmountInBase should be Amount * FxRate');
        System.assertEquals('Success', p.FxStatus__c, 'FxStatus should be Success');
    }

// Bulk insert - GROUPED CALLOUTS

    @isTest
    static void testBulkInsertGrouped() {
        List<Payment__c> payments = TestDataFactory.createPayments(
            new List<Decimal>{100, 200, 300},
            new List<String>{'EUR', 'EUR', 'HUF'}
        );

        Test.setMock(HttpCalloutMock.class, new FxApiMock());

        Test.startTest();
        insert payments;
        Test.stopTest();

        List<Payment__c> res = [SELECT FxRate__c, AmountInBase__c, FxStatus__c
                                FROM Payment__c
                                WHERE Id IN :payments];

        System.assertEquals(3, res.size(), 'All payments should be inserted');

        for(Payment__c p : res){
            System.assertEquals('Success', p.FxStatus__c, 'FxStatus should be Success');
            System.assertNotEquals(null, p.FxRate__c, 'FxRate should not be null');
            System.assertNotEquals(null, p.AmountInBase__c, 'AmountInBase should not be null');
        }
    }

// Base currency fast path 

    @isTest
    static void testBaseCurrencyFastPath() {
        Test.startTest();
        Payment__c p = TestDataFactory.createPayment(50, 'USD', true); 
        Test.stopTest();

        p = [SELECT FxRate__c, AmountInBase__c, FxStatus__c
             FROM Payment__c
             WHERE Id = :p.Id];

        System.assertEquals(1, p.FxRate__c, 'FxRate should be 1 for base currency');
        System.assertEquals(50, p.AmountInBase__c, 'AmountInBase should equal Amount for base currency');
        System.assertEquals('Success', p.FxStatus__c, 'FxStatus should be Success');
    }

// Call out

    @isTest
    static void testCalloutFailure() {
        Test.setMock(HttpCalloutMock.class, new FxApiMockFail());

        Test.startTest();
        Payment__c p = TestDataFactory.createPayment(100, 'EUR', true);
        Test.stopTest();

        p = [SELECT FxStatus__c, FxError__c
             FROM Payment__c
             WHERE Id = :p.Id];

        System.assertEquals('Failed', p.FxStatus__c, 'FxStatus should be Failed on callout error');
        System.assertNotEquals(null, p.FxError__c, 'FxError should be populated');
    }

}