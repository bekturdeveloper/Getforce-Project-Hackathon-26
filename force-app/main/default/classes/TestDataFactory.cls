@isTest
public class TestDataFactory {
	public static Account createAccount(Boolean doInsert) {
		createAccount('testAccount', doInsert);
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
			opp.amount = 1000;
			opp.closeDate = Date.today().addDays(5);
			opp.stageName = 'Prospecting';
			opps.add(opp);
		}
		return opps;
	}
}