public with sharing class BasicController {
    public string good1 {get; private set; }
    public string bad1 {get; private set; }

    public BasicController() {
        this.good1 = 'good1<b>hello</b>';
        this.bad1 = ApexPages.currentPage().getParameters().get('foo');
        ApexPages.addMessage(new ApexPages.message(apexpages.severity.INFO, '<b>msg summary</b>', '<b>msg detail</b>', 'msgid'));
        ApexPages.addMessage(new ApexPages.message(apexpages.severity.INFO, this.bad1, '<b>msg detail</b>', 'msgid'));      // not taint sinks: corresponding apex:pageMessages has escaping enabled
        ApexPages.addMessage(new ApexPages.message(apexpages.severity.INFO, 'summary', this.bad1, 'msgid'));        // not taint sinks: corresponding apex:pageMessages has escaping enabled
    }

    @AuraEnabled
    public static List<Contact> getContacts(Id recordId) {
        return [Select Id, FirstName, LastName, Email, Phone From Contact Where AccountId = :recordId];
    }

    @AuraEnabled(cacheable=true)
    public static String getsomethingbad() {
        return 'here is something<b>boo</b>';
    }
}
