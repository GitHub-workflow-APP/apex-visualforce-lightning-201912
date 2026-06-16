public with sharing class BarExtension {
    public string bargood1 {get; private set; }
    public string barbad1 {get; private set; }

    public BarExtension(BasicController controller) {
        this.bargood1 = 'good1<b>hello</b>';
        this.barbad1 = ApexPages.currentPage().getParameters().get('foo');

    }
}
