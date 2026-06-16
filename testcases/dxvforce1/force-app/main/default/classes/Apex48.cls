public with sharing class Apex48 {
    public string badfield { get; set; }
    public String goodfield { get; private set; }

    public Apex48() {
        this.badfield = 'badfield';
        this.goodfield = 'goodfield';
    }
    public static String badpassthrough(List<String> strings) {
        return strings.toString();
    }

    public void onstart() {
        List<String> badlist1 = new List<String>{ 'bad1', badField };
        List<String> badlist2 = new List<String>(badlist1);
        Set<String> badset1 = new Set<String>();
        badset1.add(this.badfield);
        Set<String> badset2 = new Set<String>(badlist1);
        Map<String, String> badmap1 = new Map<String, String>();
        badmap1.put('foo', this.badfield);
        Map<String, String> badmap2 = new Map<String, String>();
        badmap2.put('foo', badlist1[0]);
        Map<String, String> badmap3 = new Map<String, String>();
        badmap3.put('foo', badlist1.get(0));

        List<sobject> objs;
        objs = Database.quERY('select id, price__c, name from book__c where name like \'%' + badlist1.toString() + '%\'');        // CWEID 943
        objs = Database.quERY('select id, price__c, name from book__c where name like \'%' + badlist2.toString() + '%\'');        // CWEID 943
        objs = Database.quERY('select id, price__c, name from book__c where name like \'%' + badset1.toString() + '%\'');        // CWEID 943
        objs = Database.quERY('select id, price__c, name from book__c where name like \'%' + badset2.toString() + '%\'');        // CWEID 943
        objs = Database.quERY('select id, price__c, name from book__c where name like \'%' + badmap1.toString() + '%\'');        // CWEID 943
        objs = Database.quERY('select id, price__c, name from book__c where name like \'%' + badmap2.toString() + '%\'');        // CWEID 943
        objs = Database.quERY('select id, price__c, name from book__c where name like \'%' + badmap3.toString() + '%\'');        // CWEID 943

        List<String> goodlist1 = new List<String>{'good', goodField };
        List<String> goodlist2 = new List<String>(goodlist1);
        Set<String> goodset1 = new Set<String>();
        goodset1.add(this.goodfield);
        Set<String> goodset2 = new Set<String>(goodlist1);
        Map<String, String> goodmap1 = new Map<String, String>();
        goodmap1.put('foo', this.goodfield);
        Map<String, String> goodmap2 = new Map<String, String>();
        goodmap2.put('foo', goodlist1[0]);
        Map<String, String> goodmap3 = new Map<String, String>();
        goodmap3.put('foo', goodlist1.get(0));

        objs = Database.quERY('select id, price__c, name from book__c where name like \'%' + goodlist1.toString() + '%\'');
        objs = Database.quERY('select id, price__c, name from book__c where name like \'%' + goodlist2.toString() + '%\'');
        objs = Database.quERY('select id, price__c, name from book__c where name like \'%' + goodset1.toString() + '%\'');
        objs = Database.quERY('select id, price__c, name from book__c where name like \'%' + goodset2.toString() + '%\'');
        objs = Database.quERY('select id, price__c, name from book__c where name like \'%' + goodmap1.toString() + '%\'');
        objs = Database.quERY('select id, price__c, name from book__c where name like \'%' + goodmap2.toString() + '%\'');
        objs = Database.quERY('select id, price__c, name from book__c where name like \'%' + goodmap3.toString() + '%\'');



    }
}
