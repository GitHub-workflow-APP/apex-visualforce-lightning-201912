public with sharing class LCInfoBean {

    @AuraEnabled
    public static string doLCIGood1(){
        return 'good1<b>hello</b>';
    }

    @AuraEnabled
    public static string getLCIBad1(){
        return ApexPages.currentPage().getParameters().get('foo');
    }
    
}
