<aura:application controller="LightappController">
    <aura:attribute name="lacgoodval" type="String"/>
    <aura:attribute name="lacbadval1" type="String"/>
    <aura:attribute name="lacbadval2" type="String"/>
    <aura:handler name="init" value="{!this}" action="{!c.doInit}" />
    <h1>lightapp</h1>
    <c:basiclwc/>

    <div>
        <h2>lightapp.app stuff</h2>
        goodval:
        <aura:unescapedHtml value="{!v.lacgoodval}"></aura:unescapedHtml>
        badval1:
        <aura:unescapedHtml value="{!v.lacbadval1}"></aura:unescapedHtml>      <!-- CWEID 80 -->
        badval2:
        <aura:unescapedHtml value="{!v.lacbadval2}"></aura:unescapedHtml>      <!-- CWEID 80 -->

        <div>
            <div id="output1">output1</div>
            <div id="output2">output2</div>
            <div id="output3">output3</div>
            <div id="output4">output4</div>
            <div id="output5">output5</div>
            <div id="output6">output6</div>
            <div id="output7">output7</div>
            <div id="output8">output8</div>
            <div id="output9">output9</div>
            <div id="output10">output10</div>
        </div>

    </div>
</aura:application> 
