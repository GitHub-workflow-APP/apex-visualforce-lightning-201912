public with sharing class NewApex {
    public string outstring {get; private set; }
    public string nabad1 {get; set; }
    public string nabad2 { get; private set;}
    public string nabad3 { get; private set;}
    public string nabad4 { get; private set;}
    public string nagood1 {get; private set;}
    public selectoption goodopt { get; private set; }
    public selectoption badopt1 { get; private set; }
    public selectoption badopt2 { get; private set; }

    public NewApex() {
        this.nagood1 = 'q = load "<b>31337</b>";';
        this.goodopt = new selectoption('goodopt', 'GOODOPT');
        this.nabad2 = ApexPages.currentPage().getParameters().get('foo');
        this.nabad3 = ApexPages.currentPage().getParameters().get('foo');
        this.nabad4 = ApexPages.currentPage().getParameters().get('foo');
        this.badopt1 = new selectoption('<b>bad</b>opt1', this.nabad1 == null ? 'na<b>bad</b>1' : this.nabad1);
        this.badopt1.setEscapeItem(true);
        this.badopt2 = new selectoption(this.nabad1 == null ? '<b>nabad</b>1' : this.nabad1, '<b>bad</b>opt2');     // CWEID 80
        this.badopt1.setEscapeItem(false);

        ApexPages.addMessage(new ApexPages.message(apexpages.severity.INFO, '<b>msg summary</b>', '<b>msg detail</b>', 'msgid'));
        ApexPages.addMessage(new ApexPages.message(apexpages.severity.INFO, this.nabad2, '<b>msg detail</b>', 'msgid'));        // CWEID 80
        ApexPages.addMessage(new ApexPages.message(apexpages.severity.INFO, 'summary', this.nabad2, 'msgid'));                  // CWEID 80
    }

    public void setSelectedoptions(string[] values) {
        ConnectApi.literaljson res2 = ConnectApi.wave.executequery(this.nabad1);            // CWEID 943
        this.outstring = res2.json;
    }

    public String[] getSelectedoptions() {
        return new String[] { };
    }

    public void handleclick() {
        ConnectApi.literaljson res = ConnectApi.wave.executequery(this.nagood1);
        this.outstring = res.json;

        ConnectApi.literaljson res2 = ConnectApi.wave.executequery(this.nabad1);            // CWEID 943
        this.outstring = res2.json;
    }

    public pagereference dofinish() {
        return Auth.SessionManagement.finishLoginFlow('/');
    }
    public pagereference dofinish2() {
        return Auth.SessionManagement.finishLoginFlow('/' + this.nagood1);
    }
    public pagereference dofinish3() {
        return Auth.SessionManagement.finishLoginFlow('/' + this.nabad1);           // CWEID 601
    }

    public PageRefeRENCE doverify1() {
        return Auth.sessionmanagement.verifydeviceflow('xyzzy', 'http://www.veracode.com');
    }
    public PageRefeRENCE doverify2() {
        return Auth.sessionmanagement.verifydeviceflow('xyzzy', '/apex' + this.nagood1);
    }
    public PageRefeRENCE doverify3() {
        return Auth.sessionmanagement.verifydeviceflow('xyzzy', '/apex' + this.nabad1); // CWEID 601
    }

    public pagereference dologin1() {
        List<Auth.VerificationMethod> methods = new List<Auth.VerificationMethod>();
        return Site.passwordlessLogin('31337', methods, '/login');
    }
    public pagereference dologin2() {
        List<Auth.VerificationMethod> methods = new List<Auth.VerificationMethod>();
        return Site.passwordlessLogin(this.nagood1, methods, '/login');
    }
    public pagereference dologin3() {
        List<Auth.VerificationMethod> methods = new List<Auth.VerificationMethod>();
        return Site.passwordlessLogin(this.nabad1, methods, '/login');      // CWEID 639
    }
    public pagereference dologin4() {
        List<Auth.VerificationMethod> methods = new List<Auth.VerificationMethod>();
        return Site.passwordlessLogin('31337', methods, this.nabad1);       // CWEID 601
    }

    public void sendasync1() {
        UserManagement.sendAsyncEmailConfirmation('userid', 'emailtemp', 'networkid', '/');
    }
    public void sendasync2() {
        UserManagement.sendAsyncEmailConfirmation('userid', 'emailtemp', 'networkid', '/' + this.nagood1);
    }
    public void sendasync3() {
        UserManagement.sendAsyncEmailConfirmation('userid', 'emailtemp', 'networkid', '/' + this.nabad1);       // CWEID 601
    }

    public void verify1() {
        UserManagement.verifyPasswordlessLogin(ID.valueof('31337'), Auth.VerificationMethod.PASSWORD, 'identifier', 'codes', '/');
    }
    public void verify2() {
        UserManagement.verifyPasswordlessLogin(ID.valueof('31337'), Auth.VerificationMethod.PASSWORD, 'identifier', 'codes', '/' + this.nagood1);
    }
    public void verify3() {
        UserManagement.verifyPasswordlessLogin(ID.valueof('31337'), Auth.VerificationMethod.PASSWORD, 'identifier', 'codes', '/' + this.nabad1);        // CWEID 601
    }

     public void verify4() {
        UserManagement.verifySelfRegistration(Auth.VerificationMethod.PASSWORD, 'identifier', 'codes', '/');
    }
    public void verify5() {
        UserManagement.verifySelfRegistration(Auth.VerificationMethod.PASSWORD, 'identifier', 'codes', '/' + this.nagood1);
    }
    public void verify6() {
        UserManagement.verifySelfRegistration(Auth.VerificationMethod.PASSWORD, 'identifier', 'codes', '/' + this.nabad1);        // CWEID 601
    }

    public List<SelectOption> getOptions() {
        List<SelectOption> options = new List<SelectOption>();
        SelectOption selopt = new SelectOption('foo" a<b>bc</b>', 'foo" A<b>BC</b><script>console.log(3);</script>');
        selopt.setEscapeItem(false);
        SelectOption selopt2 = new SelectOption('value1', this.nagood1);
        selopt2.setEscapeItem(false);
        SelectOption selopt3 = new SelectOption('value2', string.isempty(this.nabad1) ? '<b>nabad</b>1' : this.nabad1);
        selopt3.setEscapeItem(true);
        SelectOption selopt4 = new SelectOption('value3', string.isempty(this.nabad1) ? '<b>nabad</b>1' : this.nabad1);
        SelectOption selopt5 = new SelectOption('value4', string.isempty(this.nabad1) ? '<b>nabad</b>1' : this.nabad1);     // CWEID 80
        selopt5.setEscapeItem(false);
        sELECToPTion selopt6 = new sELEctoption('value4', string.isempty(this.nabad1) ? '<b>nabad</b>1' : this.nabad1);     // CWEID 80
        selopt6.setEscapeItem(false);
        options.add(selopt);
        options.add(selopt2);
        options.add(selopt3);
        options.add(selopt4);
        options.add(selopt5);
        options.add(selopt6);

        selectoption selopt7 = new selectoption('value5', 'xyzv');
        selopt7.setLabel(string.isempty(this.nabad1) ? '<b>nabad</b>1' : this.nabad1);
        selopt7.setEscapeItem(true);
        selectoption selopt8 = new selectoption('value5', 'xyzv');
        selopt8.setLabel(string.isempty(this.nabad1) ? '<b>nabad</b>1' : this.nabad1);              // CWEID 80
        selopt8.setEscapeItem(false);
        options.add(selopt7);
        options.add(selopt8);
        return options;
    }

    public Component.Apex.OutputText getGoodcomp1() {
        component.apex.outputtext goodot = new component.apex.outputtext(value='hi');
        return goodot;
    }
    public Component.Apex.OutputText getGoodcomp2() {
        component.apex.outputtext goodcomp2 = new component.apex.outputtext(value=this.nabad1, escape=true);
        return goodcomp2;
    }
    public Component.Apex.OutputText getGoodcomp3() {
        component.apex.outputtext goodcomp3 = new component.apex.outputtext(value=this.nagood1, escape=false);
        return goodcomp3;
    }
    public Component.Apex.OutputText getBadcomp1() {
        component.apex.outputtext badcomp1 = new component.apex.outputtext(value=this.nabad1, escape=false);       // CWEID 80
        return badcomp1;
    }
    public Component.Apex.OutputText getBadcomp2() {
        component.apex.outputtext badcomp2 = new component.apex.outputtext(value=this.nabad1);       // CWEID 80
        badcomp2.escape = false;
        return badcomp2;
    }
    public Component.Apex.OutputText getBadcomp3() {
        component.apex.outputtext badcomp3 = new component.apex.outputtext();
        badcomp3.escape = false;
        badcomp3.value = this.nabad1;       // CWEID 80
        return badcomp3;
    }

     public Component.Apex.OutputLabel getGoodlblcomp1() {
        component.apex.outputlabel goodot = new component.apex.outputlabel(value='hi');
        return goodot;
    }
    public Component.Apex.OutputLabel getGoodlblcomp2() {
        component.apex.outputlabel goodlblcomp2 = new component.apex.outputlabel(value=this.nabad1, escape=true);
        return goodlblcomp2;
    }
    public Component.Apex.OutputLabel getGoodlblcomp3() {
        component.apex.outputlabel goodlblcomp3 = new component.apex.outputlabel(value=this.nagood1, escape=false);
        return goodlblcomp3;
    }
    public Component.Apex.OutputLabel getBadlblcomp1() {
        component.apex.outputlabel badlblcomp1 = new component.apex.outputlabel(value=this.nabad1, escape=false);       // CWEID 80
        return badlblcomp1;
    }
    public Component.Apex.OutputLabel getBadlblcomp2() {
        component.apex.outputlabel badlblcomp2 = new component.apex.outputlabel(value=this.nabad1);       // CWEID 80
        badlblcomp2.escape = false;
        return badlblcomp2;
    }
    public Component.Apex.OutputLabel getBadlblcomp3() {
        component.apex.outputlabel badlblcomp3 = new component.apex.outputlabel();
        badlblcomp3.escape = false;
        badlblcomp3.value = this.nabad1;       // CWEID 80
        return badlblcomp3;
    }

    public Component.Apex.PageMessage getGoodpmcomp1() {
        Component.apex.pagemessage goodpm = new component.apex.pagemessage(severity='info', escape='false', title='HI <b>TITLE</b>');
        return goodpm;
    }
    public Component.Apex.PageMessage getGoodpmcomp2() {
        Component.apex.pagemessage goodpm = new component.apex.pagemessage(severity='info', summary=this.nabad2, escape='true', title=this.nabad2);
        return goodpm;
    }
    public Component.Apex.PageMessage getGoodpmcomp3() {
        Component.apex.pagemessage goodpm = new component.apex.pagemessage(severity='info', summary=this.nabad2, title=this.nabad2);
        return goodpm;
    }
    public Component.Apex.PageMessage getBadpmcomp1() {
        Component.apex.pagemessage badpmcomp1 = new component.apex.pagemessage(severity='info', summary=this.nabad2, escape='false', title='HI <b>TITLE</b>');      // CWEID 80
        return badpmcomp1;
    }
    public Component.Apex.PageMessage getBadpmcomp2() {
        Component.apex.pagemessage badpmcomp2 = new component.apex.pagemessage(severity='info', escape='false', title=this.nabad2);      // CWEID 80
        return badpmcomp2;
    }
    public Component.Apex.PageMessage getBadpmcomp3() {
        Component.apex.pagemessage badpmcomp3 = new component.apex.pagemessage(severity='info', escape='false', title='title', detail='woops: ' + this.nabad2);      // CWEID 80
        return badpmcomp3;
    }
       
}
