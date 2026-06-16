import { LightningElement, api,track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import getsomethingbad from '@salesforce/apex/BasicController.getsomethingbad';
import intlib from './intlib.js';

export default class Basiclwc extends LightningElement {
    @track
    lappbad2;

    @track rtdata = '<b>bold</b> text';

    @track
    name;
    
    @wire(getsomethingbad, {}) lappbad3;
    @track lappbad4;

    connectedCallback() {
        this.goodval = "<b>hello</b> from connectedCallback";
        this.lappbad1 = "bad: " + unescape(window.location.search);
        
    }
    renderedCallback() {
        console.log("lappbad3");
        console.log(this.lappbad3);
        for(let key in this.lappbad3) {
            console.log("key: " +key);
        }
        var x = this.lappbad3.error;
        console.log("x:" + x);
        console.log("renderedCallback");
        console.log(this.template);
        console.log(this.template.querySelector('[data-id="output1"'));
        this.template.querySelector('[data-id="output1"').innerHTML = this.goodval;
        this.template.querySelector('[data-id="output2"').innerHTML = this.lappbad1;        // CWEID 80
        this.template.querySelector('[data-id="output3"').innerHTML = this.lappbad2;        // CWEID 80
        this.template.querySelector('[data-id="output11"').innerHTML = intlib.pthrough1(this.goodval);
        this.template.querySelector('[data-id="output12"').innerHTML = intlib.pthrough1(this.lappbad1);        // CWEID 80
        this.template.querySelector('[data-id="output13"').innerHTML = intlib.pthrough1(this.lappbad2);        // CWEID 80
        this.template.querySelector('[data-id="output14"').innerHTML = intlib.cleanse1(this.lappbad1);
        this.template.querySelector('[data-id="output15"').innerHTML = intlib.cleanse1(this.lappbad2);
        getsomethingbad().then(result => {
            console.log("got result");
            console.log(result);
            this.template.querySelector('[data-id="output6"').innerHTML = result;        // CWEID 80

        }).catch(error => {
            console.log("got error");
            console.log(error);
        });
        if(this.lappbad3.data) {
            console.log("lappbad3 data is present");
            this.template.querySelector('[data-id="output5"').innerHTML = this.lappbad3.data;        // CWEID 80
        }
        this.template.querySelector('[data-id="output7"').innerHTML = this.lappbad4;        // CWEID 80

        console.log("gotaccount:");
        if(this.gotaccount.fields) {
            console.log(this.gotaccount.fields.Name.value);
        } else {
            console.log("no fields");
        }

        console.log("renderedCallback done");
    }

    @wire(getRecord, { recordId: '0011D00000f0EDXQA2', fields: [NAME_FIELD]})
    wiredRecord({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading contact',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            console.log("wiredRecord got data");
            console.log(data);
            this.contact = data;
            this.name = this.contact.fields.Name.value;
            this.template.querySelector('[data-id="output8"').innerHTML = this.contact.fields.Name.value;        // CWEID 80
            this.template.querySelector('[data-id="output9"').innerHTML = this.name;        // CWEID 80
        }
    }

    @wire(getRecord, {recordId: '0011D00000f0EDXQA2', fields: [NAME_FIELD]})
    gotaccount;

    @wire(getsomethingbad, {})
    retrieveData({error, data}) {
        console.log("retrieveData");
        console.log(error);
        console.log(data);
        this.lappbad4 = data;
        console.log(this.template);
        
    }

    rtchanged(ev) {
        this.rtdata = ev.detail.value;
        this.template.querySelector('[data-id="output4"').innerHTML = ev.detail.value;        // CWEID 80
        this.template.querySelector('[data-id="output10"').innerHTML = ev.target.value;        // CWEID 80
    }

    handleGreetingChange(event) {
        console.log("handleGreetingChange");
        this.lappbad2 = event.target.value;
        this.template.querySelector('[data-id="output4"').innerHTML = event.target.value;        // CWEID 80
        this.template.querySelector('[data-id="output10"').innerHTML = event.detail.value;        // CWEID 80
    }
}
