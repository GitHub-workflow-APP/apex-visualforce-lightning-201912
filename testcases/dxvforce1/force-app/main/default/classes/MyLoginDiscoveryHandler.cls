global class MyLoginDiscoveryHandler implements Auth.LoginDiscoveryHandler {
    public string goodval { get; private set; }
    public MyLoginDiscoveryHandler() {
        this.goodval = 'hello this is ok';
    }
    global PageReference login(String identifier, String startUrl, Map<String, String> requestAttributes) {
        String query1 = 'select id, price__c, name from book__c where name like \'%' + identifier + '%\'';
        List<sObject> objs = database.query(query1);        // CWEID 943

        String query2 = 'select id, price__c, name from book__c where name like \'%' + startUrl + '%\'';
        objs = database.query(query2);        // CWEID 943

        String query3 = 'select id, price__c, name from book__c where name like \'%' + requestattributes.get('hey') + '%\'';
        objs = database.query(query3);        // CWEID 943

        throw new Auth.LoginDiscoveryException('No method found');
    }
}
