({
    doInit : function(component, event, helper) {
        component.set("v.lacgoodval", "this is a <b>good</b> value");
        component.set("v.lacbadval1", "b1: " + unescape(window.location.search));
        component.set("v.lacbadval2", "b2 INITIAL");

        var act = component.get("c.lacapex");
        act.setCallback(this, function(resp) {
            console.log("got a response");
            console.log(resp);
            component.set("v.lacbadval2", "b2: " + resp.getReturnValue());

            console.log("Return value: " + resp.getReturnValue());
            console.log(window.document.getElementById("output1").innerHTML);
            window.document.getElementById("output1").innerHTML = resp.getReturnValue();      // CWEID 80
            console.log("after setting");
        });
        $A.enqueueAction(act);
    }

})
