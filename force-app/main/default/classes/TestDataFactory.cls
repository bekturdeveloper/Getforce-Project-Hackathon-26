@isTest
public class TestDataFactory {
	public static Account createAccount(Boolean doInsert) {
		return createAccount('testAccount', doInsert);
	}
	
	public static Account createAccount(String name, Boolean doInsert) {
		Account acc = new Account(name = name);
		if(doInsert) {
			insert acc;
		}
		return acc;
	}
	
	public static Contact createContact(Boolean doInsert) {
		Account acc = createAccount(true);
		return createContact(acc.id, true);
	}
	
	public static Contact createContact(Id accountId, Boolean doInsert) {
		Contact c = new Contact(firstName = 'Apex', lastName = 'Hours', accountId = accountId);
		if(doInsert) {
			insert c;
		}
		return c;
	}
	public static List<Opportunity> createOpportunity(Id accountId, Integer numOpps) {
		List<Opportunity> opps = new List<Opportunity>();
		for(Integer i = 1; i <= numOpps; i++) {
			Opportunity opp = new Opportunity();
			opp.name = 'Account ' + i;
			opp.accountId = accountid;
			opp.amount = 100;
			opp.closeDate = Date.today().addDays(5);
			opp.stageName = 'Prospecting';
			opps.add(opp);
		}
		return opps;
	}

  public static User createTestUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User u = new User(
            Alias = 'maint', Email='maint@test.com', 
            LastName='Testing', ProfileId = p.Id, 
            UserName='maintuser' + DateTime.now().getTime() + '@test.com',
            EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles'
        );
        return u;
	}

public static Owner__c createOwner(Boolean doInsert) {
        Owner__c owner = new Owner__c(
            Name = 'Test Owner',
            Email__c = 'owner@test.com',
            Phone__c = '015208832076'
        );
        if(doInsert) insert owner;
        return owner;
    }

public static Tenant__c createTenant(Boolean doInsert) {
        Tenant__c tenant = new Tenant__c(
            Name = 'Test Tenant',
            FirstName__c = 'Test',
            LastName__c = 'Tenant',
            PreferredLanguage__c = 'EN',
            Phone__c = '015208832076'
        );
        if(doInsert) insert tenant;
        return tenant;
}

public static RentalAsset__c createAsset(Id ownerId, Boolean doInsert) {
        RentalAsset__c asset = new RentalAsset__c(
            Name = 'Test Asset',
            Owner__c = ownerId,
            City__c = 'Osnabruck',
            Street__c = 'Wersener Straße 46'
        );
        if(doInsert) insert asset;
        return asset;
}

public static Lease__c createLease(Boolean doInsert) {
        Owner__c owner = createOwner(true);
        Tenant__c tenant = createTenant(true);
        RentalAsset__c asset = createAsset(owner.Id, true);

        Lease__c lease = new Lease__c(
            Name = 'Test Lease',
            Tenant__c = tenant.Id,
            RentalAsset__c = asset.Id,
            StartDate__c = Date.today(),
            EndDate__c = Date.today().addMonths(12),
			DueDayOfMonth__c = 1,    
    		MonthlyRent__c = 1000 
        );
        if(doInsert) insert lease;
        return lease;
}

public static Invoice__c createInvoice(Boolean doInsert) {
        Lease__c lease = createLease(true);

        Invoice__c inv = new Invoice__c(
            Name = 'Test Invoice',
            Amount__c = 1000,
            DueDate__c = Date.today().addDays(30),
            Lease__c = lease.Id,
            PeriodMonth__c = Date.today()
        );
        if(doInsert) insert inv;
        return inv;
}

// Payment
public static Payment__c createPayment(
        Decimal amount,
        String currencyCode,
        Boolean doInsert
    ) {
        Invoice__c inv = createInvoice(true); 

        Payment__c p = new Payment__c(
            Name = 'Test Payment',
            Amount__c = amount,
            CurrencyCode__c = currencyCode,
            FxStatus__c = 'Pending',
            PaymentDateTime__c = System.now(),
            Invoice__c = inv.Id
        );

        if(doInsert) insert p;
        return p;
    }

    public static List<Payment__c> createPayments(
        List<Decimal> amounts,
        List<String> currencyCodes
    ) {
        Invoice__c inv = createInvoice(true); 
        List<Payment__c> listP = new List<Payment__c>();

        for(Integer i=0; i<amounts.size(); i++) {
            listP.add(new Payment__c(
                Name = 'Payment ' + i,
                Amount__c = amounts[i],
                CurrencyCode__c = currencyCodes[i],
                FxStatus__c = 'Pending',
                PaymentDateTime__c = System.now(),
                Invoice__c = inv.Id
            ));
        }
        return listP;
    }
	public static List<MaintenanceRequest__c> createRequests(Integer count, String status, Id assetId) {
        List<MaintenanceRequest__c> reqs = new List<MaintenanceRequest__c>();
        for(Integer i=0; i<count; i++) {
            reqs.add(new MaintenanceRequest__c(
                Name = 'Test Req ' + i,
                Status__c = status,
                RentalAsset__c = assetId, 
                Priority__c = 'Medium',
                RequestedAt__c = System.now(),
                Description__c = 'Test Description ' + i
            ));
        }
        return reqs;
    }
}