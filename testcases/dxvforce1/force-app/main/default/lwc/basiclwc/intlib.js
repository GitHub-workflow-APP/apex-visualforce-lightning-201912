export default class intlib {
    static pthrough1(inval) {
        return 'pthrough1: ' + inval + ' ok?';
    }

    static cleanse1(inval) {
        return 'cleansed: ' + encodeURIComponent(inval) + ' ok';
    }
}
