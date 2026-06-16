public with sharing class FooExtension {
    public string foogood1 {get; private set; }
    public string foobad1 {get; private set; }

    
    public FooExtension(BasicController controller) {
        this.foogood1 = 'good1<b>hello</b>';
        this.foobad1 = ApexPages.currentPage().getParameters().get('foo');
    }
}
