public with sharing class LightappController {

    public LightappController() {
    }

    @AuraEnabled
    public static string lacapex(){
        return 'xxx<b>from lacapex</b>';

    }
}
