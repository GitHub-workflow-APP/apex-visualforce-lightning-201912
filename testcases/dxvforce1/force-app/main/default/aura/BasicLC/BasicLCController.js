({
    myAction : function(component, event, helper) {
        console.log("myAction called");
        component.set("v.goodval", "this is a <b>good</b> value");
        component.set("v.badval1", "b1: " + unescape(window.location.search));
        component.set("v.badval2", "b2 INITIAL");

        var act = component.get("c.doLCIGood1");
        act.setCallback(this, function(resp) {
            console.log("got a response");
            console.log(resp);
            component.set("v.badval2", "b2: " + resp.getReturnValue());

            console.log("Return value: " + resp.getReturnValue());
            console.log(window.document.getElementById("output1").innerHTML);
            window.document.getElementById("output1").innerHTML = resp.getReturnValue();      // CWEID 80
            window.document.getElementById("output9").innerHTML = helper.helperMethod(resp.getReturnValue());
            window.document.getElementById("output8").innerHTML = helper.passthroughMethod(resp.getReturnValue());      // CWEID 80
            console.log("after setting");
        });
        $A.enqueueAction(act);
    }
})
