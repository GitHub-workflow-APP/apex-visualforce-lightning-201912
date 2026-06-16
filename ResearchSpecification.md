## Introduction / Scope

This is an update to our SFDC (salesforce.com) static research that includes support for Visualforce pages, Lightning (Aura) Components, Lightning Web Components, and updates to Apex.  This research covers up through Salesforce Spring '20 (SFDC API version 48.0).

The initial Apex static research spec is here: [https://wiki.veracode.local/display/RES/Apex+Static+Research](https://wiki.veracode.local/display/RES/Apex+Static+Research).

This is a notable exception to our SFDC support; previously, we were only scanning the server-side parts of SFDC custom code -- specifically, Apex classes.  This includes support for client-side HTML/JS and templates (server-side and client-side).

The Gitlab repository for this research is [https://gitlab.laputa.veracode.io/research-roadmap/apex-visualforce-lightning-201912](https://gitlab.laputa.veracode.io/research-roadmap/apex-visualforce-lightning-201912).  This includes annotated testcases.

### New File Extensions

We will need to pass these new extensions through to the apex archives.

* `.page` (Visualforce page)
* `.vfp` (Visualforce page -- older extension)
* `.app` (Lightning app page)
* `.cmp` (Lightning (Aura) Component)
* `.component` (alternate for .cmp)
* `.evt` (Lightning events)

## Normalizer Support: Visualforce Pages

* [Visualforce](https://developer.salesforce.com/docs/atlas.en-us.pages.meta/pages/pages_intro_what_is_it.htm) pages are a server-side-rendered template language used by SFDC.  The templates are called _pages_ and are stored in files with the extension `.page` or `.vfp`.  The template language is HTML-like and similar to JSP or JSF/Facelets (though Visualforce is simpler than both of those).  Visualforce is one of the view technologies available to SFDC developers; it fits neatly into a traditional server-side MVC model, with Salesforce objects providing the data models, and Apex code providing the controllers.

Unlike JSP, Visualforce pages cannot run arbitrary Apex code.   However, there is a library of custom tags -- some of which we need to handle.  Additionally, there is an expression language: expressions are of the form

```
{! expression}
```

where `expression` is a [SFDC formula expression](https://trailhead.salesforce.com/en/content/learn/modules/visualforce_fundamentals/visualforce_variables_expressions#Tdxn4tBK-heading2) that can reference global variables, formula functions, and variables in the page's Apex controller.

Our goal with each Visualforce page is: 

#### 1. Identify the set of Apex controllers that belong to the page.  There is usually only one of these: it is specified by the `controller` property of the `apex:page` element:

```
<apex:page controller="BasicController" lightningStylesheets="true">
```

However, `apex:page` has an optional element named `extensions`, which lets users specify a comma/space-delimited set of additional Apex methods that (for our purposes) also act as controllers.  Example:

```
<apex:page controller="BasicController" extensions="FooExtension, BarExtension   ">
```

The above Visualforce page has three classes.

In cases like this, whenever the normalizer emits a statement that requires a scoped variable (`__vc_template_scope`), we should emit one statement for each controller.

#### 2. For each of the idioms described below, transform the described tags/expressions into an Apex version of the [Normalizer Template API](https://wiki.veracode.local/display/RES/Normalizer+Template+API+and+Specs).

Along with the generated code, we should generate captured line-number info in `// VERA-COORDS` comments.  When variables are referenced in expressions, transform the references into unambiguously-scoped ones.  For example, if a Visualforce expression refers to a controller variable `foo` (as in `{! foo}`) in a file where the controller is defined to be `UserIdController`, then the normalizer should generate a reference to `__vc_template_scope('UserIdController').foo`.   

As noted above, if there is more than one controller defined, emit one statement for every controller.

##### Cases to Ignore

If the `<apex:page>` element has a `renderAs` attribute set to `pdf`, then we can ignore the file completely. 

Reference: [https://developer.salesforce.com/docs/atlas.en-us.pages.meta/pages/pages_quick_start_renderas_pdf.htm](https://developer.salesforce.com/docs/atlas.en-us.pages.meta/pages/pages_quick_start_renderas_pdf.htm)


#### 3. Put the output in a file/package that will be scanned by the Apex scanner.

There's no reason for the implementation details to be specified here: it doesn't matter whether the output ends up in a separate file that is bundled in the Apex archive, or whether the controller file itself is modfies.

#### 4. Separately, run the JavaScript normalizer on the Apex page.

Like JSP, Visualforce pages eventually generate HTML, and thus can contain all HTML elements.  This means that it can contain (e.g.) embedded `<script>` blocks, JS code in handlers, etc.  and include the output code for scanning along with other client-side code in the package.


### Apex Normalizer Output API

This is an Apex version of the [output APIs](https://wiki.veracode.local/display/RES/Normalizer+Template+API+and+Specs) for JavaScript in Python defined on the [Normalizer API](https://wiki.veracode.local/display/RES/Normalizer+Template+API+and+Specs) page.  The names and general characteristics of each function are effectively the same.

#### The `__vc_template_scope(CONTROLLERNAME)` function

This is a function we generate to refer to instances of the given Apex controller class. 

In Apex, `__vc_template_scope` should only be passed the name of the controller being referenced, as a string.  SFDC enforces a global namespace for all controllers, so the more complex parameters in Python and JS.


#### The `__vc_output_raw(ARG)` function

This is a function that indicates that the string argument `ARG` is being written out without being HTML-escaped.

#### The `__vc_output_url(ARG)` function

This function indicates that the argument is written out to the response in such a way that would cause the user's browser to retrieve a URL (e.g. an <img src="X"> URL).

### Visualforce Idioms

#### Expression Variables

As noted on the Formulas page, expressions can be complex; we don't need to handle all combinations of these, but we should not generate invalid Apex output.  (In other words: it's okay to ignore complex expressions that may be tricky to parse).  We should endeavor only to parse out variable references.

For each reference in the expression, if the name starts with `$`, then it is a global variable -- we should not scope it with `__vc_template_scope`.  If not, then the output code should prefix it with a `__vc_template_scope(CONTROLLER)` reference, where `CONTROLLER` is the value defined in the `controller` attribute of the enclosing `<apex:page>` tag.

#### The `<apex:outputText>` tag

Find all `<apex:outputText>` elements.  If the element contains an `escape` attribute that is *not* `"true"` (case-insensitive), and the element contains a `value` attribute that contains a Visualforce expression, parse all expressions in it and emit a `__vc_output_raw` statement for every variable reference contained inside.  Ignore the element's body - we only care about the `value` attribute. 

For example:

Source:

```
  1 <apex:page controller="BasicController" lightningStylesheets="true">
// ...
 16 <div>safe output 2: <apex:outputText value="{! bad1}"></apex:outputText></div>
 17 <div>unsafe output: <apex:outputText value="{! bad1}" escape="false">         <!-- CWEID 80 -->
 18 </apex:outputText></div>
// ...
 23 <div>unsafe output3: <apex:outputText value="blah blah blah {! good1 & 'heyhey' & bad1} lksajdflkajsdlfja" escape="false">         <!-- CWEID 80 -->
 24 </apex:outputText></div>
 25 <div>unsafe output4: <apex:outputText value="blah blah blah {! good1 + 'heyhey' + bad1} lksajdflkajsdlfja" escape="false">         <!-- CWEID 80 -->
 26 </apex:outputText></div>
// ...
 52 <div>unsafe output: <apex:outputText value="blah blah blah {!    'hi'+$CuRRENtPaGE.PARAMETeRS.foo  } lksajdflkajsdlfja" escape="false">         <!-- CWEID 80 -->
 53 </apex:outputText></div>
```

Output:

```
// VERA-COORDS: l 17 c 1 f ./force-app/main/default/pages/BasicDemo.page
__vc_output_raw(__vc_template_scope('BasicController').bad1);

// VERA-COORDS: l 23 c 1 f ./force-app/main/default/pages/BasicDemo.page
__vc_output_raw(__vc_template_scope('BasicController').good1);

// VERA-COORDS: l 23 c 1 f ./force-app/main/default/pages/BasicDemo.page
__vc_output_raw(__vc_template_scope('BasicController').bad1);

// VERA-COORDS: l 25 c 1 f ./force-app/main/default/pages/BasicDemo.page
__vc_output_raw(__vc_template_scope('BasicController').good1);

// VERA-COORDS: l 25 c 1 f ./force-app/main/default/pages/BasicDemo.page
__vc_output_raw(__vc_template_scope('BasicController').bad1);

// VERA-COORDS: l 52 c 1 f ./force-app/main/default/pages/BasicDemo.page
__vc_output_raw($CuRRENtPaGE.PARAMETeRS.foo);
```

#### The `<apex:outputLabel>` tag

Find all `<apex:outputLabel>` elements.  If the element contains an `escape` attribute that is *not* `"true"` (case-insensitive), and the element contains a `value` attribute that contains a Visualforce expression, parse all expressions in it and emit a `__vc_output_raw` statement for every variable reference contained inside.  Ignore the element's body - we only care about the `value` attribute. 

For example:

Source:

```
  1 <apex:page controller="BasicController" lightningStylesheets="true">
// ... 
 62 <div> safe label: <apex:outputLabel for="someid" value="{!good1}" /> </div>
 63 <div> safe label: <apex:outputLabel for="someid" value="{!good1}" escape="false" /> </div>
 64 <div> safe label: <apex:outputLabel for="someid" value="{!good1}" escape="true" /> </div>
 65
 66 <div> unsafe label: <apex:outputLabel for="someid" value="{!bad1}" /> </div>
 67 <div> unsafe label: <apex:outputLabel for="someid" value="{!bad1}" escape="false" /> </div>     <!-- CWEID 80 -->
 68 <div> unsafe label: <apex:outputLabel for="someid" value="{!bad1}" escape="true" /> </div>
```

Output:

```
// VERA-COORDS: l 63 c 1 f ./force-app/main/default/pages/BasicDemo.page
__vc_output_raw(__vc_template_scope('BasicController').good1);

// VERA-COORDS: l 67 c 1 f ./force-app/main/default/pages/BasicDemo.page
__vc_output_raw(__vc_template_scope('BasicController').bad1);
```


#### The `<apex:pageMessage>` tag

Find all `<apex:pageMessage>` elements.  If the element contains an `escape` attribute that is *not* set to `"true"` (case-insensitive), parse all Visualforce expressions in the `detail`, `summary`, and `title` attributes and emit a `__vc_output_raw` statement for every variable reference contained inside.  Ignore the element's body.

For example - source:

```
  1 <apex:page controller="NewApex">
  2
  3 <h1>NewApexVF</h1>
  4 <apex:form>
  5     <apex:pageMessage severity="info" detail="<b>detail</b>"  escape="false" summary="<b>summary</b>"  title="<b>title</b>" />
  6     <apex:pageMessage severity="info" detail="{!nabad2}" escape="true" summary="summary {!nabad3}"  title="title {!nabad4}" />
  7     <apex:pageMessage severity="info" detail="{!nabad2}" escape="false" summary="summary {!nabad3}"  title="title {!nabad4}" />
```

Output:

```
// VERA-COORDS: l 7 c 1 f ./force-app/main/default/pages/NewApexVF.page
__vc_output_raw(__vc_template_scope('NewApex').nabad2);

// VERA-COORDS: l 7 c 1 f ./force-app/main/default/pages/NewApexVF.page
__vc_output_raw(__vc_template_scope('NewApex').nabad3);

// VERA-COORDS: l 7 c 1 f ./force-app/main/default/pages/NewApexVF.page
__vc_output_raw(__vc_template_scope('NewApex').nabad4);
```

#### The `<apex:pageMessages>` tag

This is separate from the `<apex:pageMessage>` element noted above.  We need to identify Visualforce pages that have an `<apex:pageMessages>` tag with an `escape` element set to something that's not `"true"`.  If we find one, then we need to signal to the Apex scanner that the {{ApexPages.addMessage(T)}} CWEID 80 taint sink is valid for the controller attached to the page.

One way to do this is to just set a magic property on the controller when this is detected..

So for a Visualforce page like this:

```
  1 <apex:page controller="NewApex">
  2 <apex:pageMessages escape="false"/>
```

we could generate something like:

```
__vc_template_scope('NewApex').__vc_pagemessages_escaped = false
```

and then have the Apex scanner downstream look for the `{{__vc_pagemessages_escaped}} property.

If there's a better or simpler way for this to be implemented, great.



#### The `<apex:selectOption>` tag

Find all `<apex:selectOption>` elements.  If the element contains an `itemEscaped` attribute that is set to a value that is not `"true"` (again, everything is case insensitive), *and* it contains an `itemLabel` attribute that contains at least one Visualforce expression, parse all expressions and emit a `__vc_output_raw` statement for every variable reference contained inside.  Ignore the element's body.

For example:

```
  1 <apex:page controller="NewApex">
// ...
 66                 <apex:selectOption itemLabel="{!nabad1}" itemValue="<b>value</b>" itemEscaped="true" />
 67                 <apex:selectOption itemLabel="{!nabad1}" itemValue="<b>value</b>" itemEscaped="false" />        <!-- CWEID 80 -->
 68                 <apex:selectOption itemLabel="{!nabad1}" itemValue="<b>value</b>" />
```

Output:

```
// VERA-COORDS: l 52 c 1 f ./force-app/main/default/pages/NewApexVF.page
__vc_output_raw(__vc_template_scope('NewApex').nabad1);
```

#### The `<script>` tag

Look for all `<script>` elements.  If the body of the `<script>` element contains any Visualforce expressions, parse the expression(s) and emit a `__vc_output_raw` statement for every variable reference contained inside.

(N.B.  Because of the potential for downstream JS parse failures, we might consider telling the JS normalizer to ignore script blocks that contain Visualforce expressions in Visualforce pages.)

For example:

Source:
```
  1 <apex:page controller="BasicController" lightningStylesheets="true">
// ...
 57     <script>
 58         console.log("{! good1}");
 59     </script>
 60     <script>
 61         console.log("{! bad1}");        <!-- CWEID 80 -->
 62     </script>
 63     <script>
 64         console.log("{! $currentPAGE.parameters.foo}");        <!-- CWEID 80 -->
 65     </script>
```

Output:

```
// VERA-COORDS: l 58 c 1 f ./force-app/main/default/pages/BasicDemo.page
__vc_output_raw(__vc_template_scope('BasicController').good1);

// VERA-COORDS: l 61 c 1 f ./force-app/main/default/pages/BasicDemo.page
__vc_output_raw(__vc_template_scope('BasicController').bad1);

// VERA-COORDS: l 64 c 1 f ./force-app/main/default/pages/BasicDemo.page
__vc_output_raw($currentPAGE.parameters.foo);

```


#### HTML attributes that may include JavaScript

Find all elements that don't have a namespace (e.g. the `apex` in `<apex:outputText>` is a namespace).  For each of these, look for attributes (case-insensitively) that have names starting with `"on"` (e.g. `onload`, `onmouseover`, etc.).  If the value of the attribute contains any Visualforce expressions, parse the expression(s) and emit a `__vc_output_raw` statement for every variable reference contained inside.

For example:

Source:

```
  1 <apex:page controller="BasicController" lightningStylesheets="true">
// ...
 67     <div onmouseover="{!good1}">good1 over div</div>
 68     <div onmouseover="{!bad1}">bad1 over div</div>          <!-- CWEID 80 -->
 69     <div onmouseover="{!good1} {!bad1}">bad1 over div</div>          <!-- CWEID 80 -->
 70     <div onmouseover="{!''+bad1}">bad1 over div</div>           <!-- CWEID 80 -->
 71     <div onmouseover="{!''+$currentpage.parameters.foo}">bad1 over div</div>           <!-- CWEID 80 -->
```

Output:

```
// VERA-COORDS: l 67 c 1 f ./force-app/main/default/pages/BasicDemo.page
__vc_output_raw(__vc_template_scope('BasicController').good1);

// VERA-COORDS: l 68 c 1 f ./force-app/main/default/pages/BasicDemo.page
__vc_output_raw(__vc_template_scope('BasicController').bad1);

// VERA-COORDS: l 69 c 1 f ./force-app/main/default/pages/BasicDemo.page
__vc_output_raw(__vc_template_scope('BasicController').good1);

// VERA-COORDS: l 69 c 1 f ./force-app/main/default/pages/BasicDemo.page
__vc_output_raw(__vc_template_scope('BasicController').bad1);

// VERA-COORDS: l 70 c 1 f ./force-app/main/default/pages/BasicDemo.page
__vc_output_raw(__vc_template_scope('BasicController').bad1);

// VERA-COORDS: l 71 c 1 f ./force-app/main/default/pages/BasicDemo.page
__vc_output_raw($currentpage.parameters.foo);
```

### Apex-side mapping

Inside the Apex scanner, map `__vc_template_scope(FOO)` variables to classes named `FOO`; and treat `__vc_output_raw(T)` as a sink, as noted below.

Remember that nearly every identifier in Apex is case-insensitive.  When working with the SFDC tech stack in general, unless you're using JavaScript directly, it is generally safe to assume that every identifier is case insensitive, even when the documentation prefers a certain capitalization scheme. 


### References and Docs on Visualforce Syntax

* [Visualforce Basics: Use Simple Variables and Formulas](https://trailhead.salesforce.com/en/content/learn/modules/visualforce_fundamentals/visualforce_variables_expressions#Tdxn4tBK-heading2) is a good introduction to Visualforce.
* [Compiling Visualforce Successfully](https://developer.salesforce.com/docs/atlas.en-us.pages.meta/pages/pages_quick_start_compile_requirements.htm) -- describes the general syntax (generally, pages must be XML with some HTML-like exceptions)
* Visualforce Expression references
    * A good starting point is the [Global Variables, Functions, and Expression](https://developer.salesforce.com/docs/atlas.en-us.pages.meta/pages/pages_variables.htm) page; this includes links to global variables and Visualforcefunctions.  
    * As the above page describes, the syntax for Visualforce expressions is the same as SFDC Formulas, which are used elsewhere on the Salesforce platform.  These are documented here: [https://help.salesforce.com/articleView?id=elements_of_a_formula.htm&type=5](https://help.salesforce.com/articleView?id=elements_of_a_formula.htm&type=5).



## Lightning/Aura Components

"Lightning" is an umbrella term used by Salesforce for a wide variety of changes to their platform, including:

* a UI refresh
* rearchitecture of the application away from server-side rendering toward client-centered UI
* additional external and internal APIs to enable the above
* easier integration with Salesforce mobile apps
* other new features

Of those, only a small portion of these have relevance to custom code that can be written (and thus scanned) by SFDC app developers.  The first is Lightning Components, aka Aura Components.  

Lightning Components/Aura are apps written using a JavaScript MVC library with a templating engine.  These run on SFDC, which provides bridges to Apex controllers.  We don't need to attempt to integrate across that boundary; instead our goal is to generate entry points and add injectors/sinks/propagators as needed.

To that end, we need to:
* Add a normalizer pass for Lightning Component template files
* Recognize the structure of Lightning Component JS source files
* Ensure all of this gets passed to saf to be scanned as JS
* In saf, resolve normalizer references and model calls to entry points


### Lightning/Aura Component Normalizer Additions

Each component has an associated template file (`.cmp`, `.component`, or `.app` file extension).

Unlike Visualforce templates, Lightning Component templates do not need to be fed through the HTML normalizer; inline JS (e.g. `<script>` tags, attribute event handlers, etc.) are stripped out by SFDC.  All JS is in `.js` files.  (Note: this is *not* true of Lightning **Web** Components (LWC) described below; those are effectively HTML.  But: these use the `.html` file extension.)

Lightning templates have a similar expression syntax to Visualforce: most expressions are of the form

```
{! expression}
```

and may be used in attribute values and element bodies.  

Lightning templates have [an alternate syntax](https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/expr_data_binding.htm):

```
{# expression}
```

We can treat these two the same; the difference is that one has different data-binding implications, but that difference isn't something we need to capture.

(Unlike in Visualforce, attribute values do not need to be enclosed in double quotes -- they may be enclosed in single quotes or no quotes at all.

This is legal in an Aura component template:

```
    <div>
        <lightning-input label="Name" value={greeting} onchange={handleGreetingChange}></lightning-input>
    </div>
```

#### Scoping

We should populate only the `controller` property in calls to `__vc_template_scope()`.  This should simply be the base filename of the component minus its `.cmp` or `.app` extension.

For example, in JS generated by a file named `force-app/main/default/aura/BasicLC/BasicLC.cmp`, the `controller` property's value should be `BasicLC`.

#### Lightning Component Idioms

##### Expression Variables

Like in the Visualforce section, when handling expressions we mostly want to extract all possible identifier references.  

In Lightning templates, all identifiers we encounter should be compound -- e.g. `v.value` or `v.account.username` or `c.handleclick`.  The first part of such an expression is called a [Value Provider](https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/expr_source.htm) in Aura; [this link](https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/expr_source.htm) provides a list of the built-in ones.  

For the moment, if the value provider (the beginning of the expression) is *not* `v`, we can ignore the identifier.  

##### The `<aura:unescapedHtml>` element

Find all `<aura:unescapedHtml>` elements.  If the `value` attribute contains any expressions (that have the `v` value provider), emit a `__vc_output_raw` statement for every variable reference defined inside.  Strip out the `v.` value provider and prepend a `__vc_template_scope()` call instead.

Example source (in a file named `force-app/main/default/aura/BasicLC/BasicLC.cmp`):

```
 33     goodval:
 34     <aura:unescapedHtml value="{!v.goodval}"></aura:unescapedHtml>
 35     badval1:
 36     <aura:unescapedHtml value="{!v.badval1}"></aura:unescapedHtml>      <!-- CWEID 80 -->
 37     badval2:
 38     <aura:unescapedHtml value="{!v.badval2}"></aura:unescapedHtml>      <!-- CWEID 80 -->
```

Output:

```
// VERA-COORDS: l 34 c 1 f ./force-app/main/default/pages/BasicDemo.page
__vc_output_raw(__vc_template_scope({controller: 'BasicLC`}).goodval);

// VERA-COORDS: l 36 c 1 f ./force-app/main/default/pages/BasicDemo.page
__vc_output_raw(__vc_template_scope({controller: 'BasicLC`}).badval1);

// VERA-COORDS: l 38 c 1 f ./force-app/main/default/pages/BasicDemo.page
__vc_output_raw(__vc_template_scope({controller: 'BasicLC`}).badval2);
```

### JS-side mapping (resolving `__vc_template_scope`) objects

The objects referred to by `__vc_template_scope({controller: FOO})` are not JS properties themselves.  They refer to a component container object that is passed as the first argument (often named `component` by convention) to all (JS) Lightning controllers and renderers (see the "Lightning Component Organization" section).  The properties in the `__vc_template_scope` object are not assigned directly to the component object; they're accessed by the `.get` and `.set` accessors.

To illustrate, here's the part of the controller that populates the `v.goodval`, `v.badval1`, and `v.badval2` values used above:

(from force-app/main/default/aura/BasicLC/BasicLCController.js):

```
  1 ({
  2     myAction : function(component, event, helper) {
  3         console.log("myAction called");
  4         component.set("v.goodval", "this is a <b>good</b> value");
  5         component.set("v.badval1", "b1: " + unescape(window.location.search));
  6         component.set("v.badval2", "b2 INITIAL");
```

(Despite the overused `get` and `set` names, mapping these may be possible if we use heuristics to restrict them to only uses where we might be setting a `v.` variable..)


### Lightning Component Organization

Lightning components generally contain a number of JavaScript files in addition to the template.  These will almost always be packaged in the same directory as the `.cmp` or `.app` file, and have predictable names based off of the `cmp`/`app` basename:

#### JS Controller

This file is named `FOOController.js`, where `FOO.cmp` (or `FOO.app`) is the name of the controller template.

This file is not imperative JS; at the top level it is a JS object literal with properties.  These properties are all callbacks, and we should model calls to all of them.

(Note: This is confusingly *not* related to the `controller` property in the Lightning component template's `aura:component` tag.  That refers to an Apex class, but bridging JS and Apex in a coherent way is out of scope for this document.)

For example, here's the full BasicLCController.js:

```
  1 ({
  2     myAction : function(component, event, helper) {
  3         console.log("myAction called");
  4         component.set("v.goodval", "this is a <b>good</b> value");
  5         component.set("v.badval1", "b1: " + unescape(window.location.search));
  6         component.set("v.badval2", "b2 INITIAL");
  7
  8         var act = component.get("c.doLCIGood1");
  9         act.setCallback(this, function(resp) {
 10             console.log("got a response");
 11             console.log(resp);
 12             component.set("v.badval2", "b2: " + resp.getReturnValue());
 13
 14             console.log("Return value: " + resp.getReturnValue());
 15             console.log(window.document.getElementById("output1").innerHTML);
 16             window.document.getElementById("output1").innerHTML = resp.getReturnValue();      // CWEID 80
 17             window.document.getElementById("output9").innerHTML = helper.helperMethod(resp.getReturnValue());
 18             window.document.getElementById("output8").innerHTML = helper.passthroughMethod(resp.getReturnValue());      // CWEID 80
 19             console.log("after setting");
 20         });
 21         $A.enqueueAction(act);
 22     }
 23 })
```

##### Controller Arguments

The first argument to each callback function in a JS Lightning controller is the `component` object.  The relevant methods we care about on this object are the `get` and `set` objects -- see the section above about resolving `__vc_template_scope` references.

We can ignore the second argument at the moment.

The third argument is a reference to the helper object (if it exists), listed below.

#### JS Helper

This optional file is named `FOOHelper.js`, where `FOO.cmp` (or `FOO.app`) is the name of the controller template.

The structure (top-level object is a JS object literal) is identical to controller methods, except these are not called directly by the framework - they are called by other functions in the controller or renderer.

For example, here are the definitions of the `helperMethod` and `passthroughMethod` functions used above (in force-app/main/default/aura/BasicLC/BasicLCHelper.js):

```
  1 ({
  2     helperMethod : function(xval) {
  3         return "foo";
  4     },
  5
  6     passthroughMethod: function(xval) {
  7         return "PASS: " + xval;
  8     }
  9 })
```


#### JS Renderer

This optional file is named `FOORenderer.js`, where `FOO.cmp` (or `FOO.app`) is the name of the controller template.

The methods in this file are called by the framework, like the controller.

Here's one (from force-app/main/default/aura/BasicLC/BasicLCRenderer.js):

```
  1 ({
  2
  3     render: function(cmp, helper) {
  4         var ret = this.superRender();
  5         console.log("render");
  6         console.log(ret);
  7
  8         if(ret[3].nodeName.toUpperCase() == "DIV") {
  9             ret[3].innerHTML = ret[3].innerHTML + "HI";
 10             ret[3].innerHTML = ret[3].innerHTML + "<br/> goodval" + cmp.get('v.goodval');
 11             ret[3].innerHTML = ret[3].innerHTML + "<br/> badval1" + cmp.get('v.badval1');   // CWEID 80
 12         }
 13         //ret[0].querySelector("#output2").innerHTML = "HI";
 14
 15         return ret;
 16     },
```

#### Renderer Function Arguments

The first argument to each function is the component object - the same object used in the controllers (and connected to properties on `__vc_template_scope`).

The second argument is the helper class, if it exists (see above).


### References

- Salesforce hosts the [Compoennt Library](https://developer.salesforce.com/docs/component-library/bundle/lightning-accordion) for LWC and Aura that describes the SFDC-specific template tags
- The best API reference of Aura is not publicly accessible; it's available at `/auradocs/reference.app` on any valid Salesforce org (even ones created with a free Developer instance).  More details on this here: [https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/ref_doc_app.htm](https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/ref_doc_app.htm)
- [Custom Renderer (component)Renderer.js files) Docs](https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/js_renderers.htm)
- [Some Aura-specific documentation on Lightning template expressions is here](https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/expr_overview.htm)

## Lightning Web Components

Like Lightning (Aura) components, Lightning Web Components (LWC from here on out) are a client-side technology.

Fortunately for us, they build heavily on the semi-standard [Web Components](https://developer.mozilla.org/en-US/docs/Web/Web_Components) spec, which means that most oif their code is in HTML and JS files.

### LWC File Organization

From [the docs](https://developer.salesforce.com/docs/component-library/documentation/lwc/create_components_folder), LWCs must be located in a directory named for the component, and the template file (`.html`) and controller (`.js`) must have the same name:

```
myComponent
   ├──myComponent.html
   ├──myComponent.js
   ├──myComponent.js-meta.xml
   ├──myComponent.css
   └──myComponent.svg
```

LWC templates are parsed and read into a shadow DOM, as in Angular 2.  Inline JS is disallowed.  Unlike Angular 2, the attack surface for XSS is nonexistent (you have to do DOM manipulation with JS located elsewhere), and it's difficult to profile sensitive data sources for exfiltration without knowing more about Apex classes.  As a result, it's not worth doing any new normalizer work for LWC templates.  This may well change in the future as the SFDC platform matures.

### LWC JS Controller Modeling

LWC controllers are easy to identify aside from their filenames: they are ES2015 classes that implement `lwc.LightningElement`:

```
  1 import { LightningElement, api,track, wire } from 'lwc';
  2 import { getRecord } from 'lightning/uiRecordApi';
  3 import getsomethingbad from '@salesforce/apex/BasicController.getsomethingbad';
  4
  5 export default class Basiclwc extends LightningElement {
```

#### Callbacks

These functions are called by the framework directly:

```
    - lwc.LightningElement
        - constructor()
        - connectedCallback()
        - disconnectedCallback()
        - render()
        - renderedCallback()
        - errorCallback(x, x)
```

Additionally: Inside `LightningElement` classes, the value of `Event.target.value` and `Event.detail.value` in handlers that have the `Event` object passed as the first argument are always network-tainted.  (In general HTML, this is usually not the case.)

Example:

```
 58     handleGreetingChange(event) {
 59         console.log("handleGreetingChange");
 60         this.lappbad2 = event.target.value;
 61         this.template.querySelector('[data-id="output4"').innerHTML = event.target.value;        // CWEID 80
 62     }
```

#### Taint Injection via Imports and the `@wire` Annotation

The primary new source of taint is the set of objects imported from namespaces that begin with these names:

* `@salesforce/apex`
* `@salesforce/apexContinuation`
* `@salesforce/messageChannel`
* `lightning/uiRecordApi`


Examples:

```
import startRequest from '@salesforce/apexContinuation/SampleContinuationClass.startRequest';
import getsomethingbad from '@salesforce/apex/BasicController.getsomethingbad';
import SAMPLEMC from '@salesforce/messageChannel/SampleMessageChannel__c';
import { getRecord } from 'lightning/uiRecordApi';
```

These objects are Promises, and the list above represents a set of bridges between the SFDC backend (including database record queries and custom Apex calls).  Data coming back from them (in the resolved object) should be considered tainted.

For example:

```
  4 import getsomethingbad from '@salesforce/apex/BasicController.getsomethingbad';

// ...

 35         getsomethingbad().then(result => {
 36             console.log("got result");
 37             console.log(result);
 38             this.template.querySelector('[data-id="output6"').innerHTML = result;        // CWEID 80
 39
 40         }).catch(error => {
 41             console.log("got error");
 42             console.log(error);
 43         });
```

##### The `@wire` annotation

The `lwc.wire` annotation may be used to map the results of one of these Promises to a class property or to a function.

In the case of a class property, the property is populated with an object containing two properties: `error` and `data`.  The `data` property should be considered tainted.

For example:

```
  1 import { LightningElement, api,track, wire } from 'lwc';
  4 import getsomethingbad from '@salesforce/apex/BasicController.getsomethingbad';

// ... 

 13     @wire(getsomethingbad, {}) lappbad3;

// ...

 44         if(this.lappbad3.data) {
 45             console.log("lappbad3 data is present");
 46             this.template.querySelector('[data-id="output5"').innerHTML = this.lappbad3.data;        // CWEID 80
 47         }
```

When `@wire` is attached to a function, the function takes as its first parameter an object with two properties (again, `error` and `data`).  Again the `data` property is tainted.

For example:

```
  1 import { LightningElement, api,track, wire } from 'lwc';
  2 import { getRecord } from 'lightning/uiRecordApi';
  3 import NAME_FIELD from '@salesforce/schema/Account.Name';

// ... 

 60     @wire(getRecord, { recordId: '0011D00000f0EDXQA2', fields: [NAME_FIELD]})
 61     wiredRecord({ error, data }) {
 62         if (error) {

// ...

 76         } else if (data) {
 77             console.log("wiredRecord got data");
 78             console.log(data);
 79             this.contact = data;
 80             this.name = this.contact.fields.Name.value;
 81             this.template.querySelector('[data-id="output8"').innerHTML = this.contact.fields.Name.value;        // CWEID 80
 82             this.template.querySelector('[data-id="output9"').innerHTML = this.name;        // CWEID 80
 83         }
 84     }
```


#### Type Info

```
- lwc.LightningElement
    - this.template is an Element
```


### References

* LWC is (mostly) open-source, with a [Github repo](https://github.com/salesforce/lwc) and a [separate, but official documentation site](https://lwc.dev/guide/introduction)
* [Lifecycle Hooks for lwc.LightningElement](https://developer.salesforce.com/docs/component-library/documentation/lwc/reference_lifecycle_hooks)
* Salesforce hosts the [Compoennt Library](https://developer.salesforce.com/docs/component-library/bundle/lightning-accordion) for LWC and Aura that describes the SFDC-specific template tags


## New Apex Information

Note: Some of these are references to Visualforce objects and functions; since these are being converted to Apex, it makes sense to list them here.

### New Entry Points/Sources

#### Auth.LoginDiscoveryHandler

In classes that implement the Auth.LoginDiscoveryHandler interface, the function:

```
PageReference login(String identifier, String startUrl, Map<String, String> requestAttributes)
```
is called with all parameters tainted.

#### Process.Plugin

In classes that implement the `Process.Plugin` interface, the function

```
Process.PluginResult invoke(Process.PluginRequest request)
```

is called by the framework with the `request` parameter network-tainted.

### Type Info

- Renderer methods:
    - this.superRender() returns an object (generally an array) whose properties are all Element instances
    - this.superRerender() returns an object (generally an array) whose properties are all Element instances

### Sources

```
* Taint.Network
    * $CurrentPage.parameters
    * $Request
```

### Sinks

```
* CWEID 80 (when T is Taint.Network)
    * __vc_output_raw(T)
    * new SelectOption(x, T)
        * NOTE: This is only a taint sink when there is a call to setEscapeItem(false) on the same SelectOption argument
    * SelectOption.setLabel(T)
        * NOTE: This is only a taint sink when there is a call to setEscapeItem(false) on the same SelectOption argument
    * Component.Apex.OutputText.value = T
        * NOTE 1: This is only when the escape property is also set to false at some point
        * NOTE 2: This can also be triggered in constructors with named parameters
    * Component.Apex.OutputLabel.value = T
        * NOTE 1: This is only when the escape property is also set to false at some point
        * NOTE 2: This can also be triggered in constructors with named parameters
    * Component.Apex.PageMessage.summary = T
        * NOTE 1: This is only when the escape property is also set to false at some point
        * NOTE 2: This can also be triggered in constructors with named parameters
    * Component.Apex.PageMessage.detail = T
        * NOTE 1: This is only when the escape property is also set to false at some point
        * NOTE 2: This can also be triggered in constructors with named parameters
    * Component.Apex.PageMessage.title = T
        * NOTE 1: This is only when the escape property is also set to false at some point
        * NOTE 2: This can also be triggered in constructors with named parameters
    * ApexPages.addMessage(T)
        * NOTE: This is conditional; it's only a sink when the <apex:pageMessages> element in any corresponding Visualforce page has set escape="false".  See the section on <apex:pageMessages> above.


* CWEID 99 (when T is Taint.Network)
    * Auth.JWT.setSub(T)
    * Auth.JWT.setAdditionalClaims(T)


* CWEID 943 (when T is Taint.Network)
    * ConnectApi.Wave.executeQuery(T)

* CWEID 601 (when T is Taint.Network)
    * Auth.SessionManagement.finishLoginFlow(T)
    * Auth.SessionManagement.verifyDeviceFlow(x, T)
    * Site.passwordlessLogin(x, x, T)
    * UserManagement.sendAsyncEmailConfirmation(x, x, x, T)
    * UserManagement.verifyPasswordlessLogin(x, x, x, x, T)
    * UserManagement.verifySelfRegistration(x, x, x, T)

* CWEID 639 (when T is Taint.Network)
    * Site.passwordlessLogin(T, x, x)
```


### Propagators

```
* ApexPages.Message
    * OUT = new Message(x, IN)
    * OUT = new Message(x, IN, IN)
    * OUT = new Message(x, IN, IN, x)

* Process.PluginRequest
    * OUT = Map<String, ANY> IN.inputParameters

* List
    * OUT = IN.toString()

* Map
    * OUT = IN.toString()

* Set
    * OUT = IN.toString()
```


#### Function/Visualforce Expression Propagators

Note: These are all case-insensitive.

```
* OUT = BLANKVALUE(IN, IN)
* OUT = CASE(x, IN, IN, IN, IN, IN, ..., IN)
* OUT = IF(x, IN, IN)
* OUT = LEFT(IN, x)
* OUT = LOWER(IN)
* OUT = LPAD(IN, x)
* OUT = MID(IN, x, x)
* OUT = NULLVALUE(IN, IN)
* OUT = REQUIRESCRIPT(IN)
* OUT = RIGHT(IN, x)
* OUT = RPAD(IN, x)
* OUT = SUBSTITUTE(IN, x, IN)
* OUT = TEXT(IN)
* OUT = TRIM(IN)
* OUT = UPPER(IN)
```

For a list of all builtin function operators, see [https://help.salesforce.com/articleView?id=customize_functions.htm&type=5](https://help.salesforce.com/articleView?id=customize_functions.htm&type=5).  The ones not listed above effectively function as cleansers.

### New CWEID 321 Functions

Like the existing CWE 321 scans, when a `Blob` derived from a string literal is passed as one of the bolded parameters to these functions, flag the function call with a CWE 321.



### References

* [Apex Release Notes](https://releasenotes.docs.salesforce.com/en-us/winter20/release-notes/salesforce_release_notes.htm)
* [SFDC General Release Notes](http://releasenotes.docs.salesforce.com/en-us/winter20/release-notes/rn_included_release_notes.htm)


## Open-Source Testcases

There is a zipfile (2G zipped, ~5.5G unzipped) of various Apex applications found on Github.  This may be useful for smoke/performance testing.

This is available at \\fs01\public\research\bcreighton\SFDC-github-opensource.


## Out Of Scope

- Support for dataflow between Apex and JS.  (We're handling the risk behind this by assuming that most data coming from SFDC records or Apex classes may be potentially user-controlled, albeit indirectly.)
- Lightning Message Server (This feature is still in preview; we'll revisit when it goes GA.  Risk looks low at the moment.)

