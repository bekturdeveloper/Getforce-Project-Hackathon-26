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

		public static RentalAsset__c createAsset(Id ownerID, Boolean DoInsert){
		RentalAsset__c asset = new RentalAsset__c(
			Name = 'Test Asset',
			Owner__c = ownerID,
			City__c = 'Osnabruck',
			Street__c = 'Wersener Str 46'
		);
		if(DoInsert) insert asset;
		return asset;
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