({

    render: function(cmp, helper) {
        var ret = this.superRender();
        console.log("render");
        console.log(ret);
        
        if(ret[3].nodeName.toUpperCase() == "DIV") {
            ret[3].innerHTML = ret[3].innerHTML + "HI";
            ret[3].innerHTML = ret[3].innerHTML + "<br/> goodval" + cmp.get('v.goodval');
            ret[3].innerHTML = ret[3].innerHTML + "<br/> badval1" + cmp.get('v.badval1');   // CWEID 80
        }
        //ret[0].querySelector("#output2").innerHTML = "HI";
        
        return ret;
    },

    rerender: function(cmp, helper) {
        var ret = this.superRerender();
        console.log("rerender");
        console.log(ret);
        if(ret[3].nodeName.toUpperCase() == "DIV") {
            ret[3].innerHTML = ret[3].innerHTML + "HI_rerender";
            ret[3].innerHTML = ret[3].innerHTML + "<br/> goodval" + cmp.get('v.goodval');
            ret[3].innerHTML = ret[3].innerHTML + "<br/> badval1" + cmp.get('v.badval1');   // CWEID 80
            ret[3].innerHTML = ret[3].innerHTML + "<br/> badval1" + helper.passthroughMethod(cmp.get('v.badval1'));   // CWEID 80
            ret[3].innerHTML = ret[3].innerHTML + "<br/> badval1" + helper.helperMethod(cmp.get('v.badval1'));
        }
        return ret;
    },
    afterRender: function (component, helper) {
        this.superAfterRender();
        console.log("afterRender");
        document.getElementById("output3").innerHTML = component.get('v.goodval');
        document.getElementById("output4").innerHTML = component.get('v.badval1');          // CWEID 80
        document.getElementById("output5").innerHTML = component.get('v.badval2');          // CWEID 80
        
    },

    unrender: function(component, helper) {
        this.superUnrender();
        console.log("unrender");
        document.getElementById("output3").innerHTML = component.get('v.goodval');
        document.getElementById("output4").innerHTML = component.get('v.badval1');          // CWEID 80
        document.getElementById("output5").innerHTML = component.get('v.badval2');          // CWEID 80
       
    }
    

})
