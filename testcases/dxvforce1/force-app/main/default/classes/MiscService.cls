@RestResource(urlMapping='/miscsvc/*')
global with sharing class MiscService {
    public MiscService() {

    }

    @HttpGet
    global static String getsomething() {
        RestRequest rreq = restcontext.request;
        string goodval1 = 'good value';

        auth.jwt goodjwt = new auth.jwt();
        goodjwt.setSub('user@example.com');
        goodjwt.setAud('https://login.salesforce.com');
        goodjwt.setIss('3MVG99OxTyEMCQ3gNp2PjkqeZKxnmAiG1xV4oHh9AKL_rSK.BoSVPGZHQ​ukXnVjzRgSuQqGn75NL7yfkQcyy7');

        Map<string, object> goodclaims = new map<string, object>();
        goodclaims.put('claim1', 'this is a claim');
        goodclaims.put('goodclaim1', goodval1);
        goodjwt.setAdditionalClaims(goodclaims);
        return goodjwt.toJSONString();
    }

    @HttpPost
    global static String getsomething2() {
        RestRequest rreq = restcontext.request;
        string badval1 = rreq.params.get('foo');

        auth.jwt badjwt = new auth.jwt();
        badjwt.setSub(badval1);         // CWEID 99
        badjwt.setAud('https://login.salesforce.com');
        badjwt.setIss('3MVG99OxTyEMCQ3gNp2PjkqeZKxnmAiG1xV4oHh9AKL_rSK.BoSVPGZHQ​ukXnVjzRgSuQqGn75NL7yfkQcyy7');

        Map<string, object> badclaims = new map<string, object>();
        badclaims.put('claim1', 'this is a claim');
        badclaims.put('goodclaim1', badval1);
        badjwt.setAdditionalClaims(badclaims);          // CWEID 99
        return badjwt.toJSONString();
    }
}
