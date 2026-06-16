global class ProcessAction implements Process.Plugin {
    public ProcessAction() {

    }
    global Process.PluginResult invoke(Process.PluginRequest request) {
        Map<String, Object> emptymap = new Map<String, Object>();
        emptymap.put('foo', 'this is ok');

        List<sObject> objs = DATabase.QUery('select id, price__c, name from book__c where name like \'%' + request.inputParameters.get('foo') + '%\'');    // CWEID 943
        objs = DATabase.QUery('select id, price__c, name from book__c where name like \'%' + request.inputParameters.clone().get('bar') + '%\'');    // CWEID 943
        objs = DATabase.QUery('select id, price__c, name from book__c where name like \'%' + request.inputParameters.toString() + '%\'');    // CWEID 943

        objs = DATabase.QUery('select id, price__c, name from book__c where name like \'%' + emptymap.get('foo') + '%\'');    // CWEID 943
        objs = DATabase.QUery('select id, price__c, name from book__c where name like \'%' + emptymap.clone().get('bar') + '%\'');    // CWEID 943
        objs = DATabase.QUery('select id, price__c, name from book__c where name like \'%' + emptymap.toString() + '%\'');    // CWEID 943

        Map<String,Object> result = new Map<String,Object>();
        return new Process.PluginResult(result);
    }

    global Process.PluginDescribeResult describe() {
        Process.PluginDescribeResult result = new Process.PluginDescribeResult();
        result.Name = 'flowchatplugin';
        result.Tag = 'chat';
        result.inputParameters = new
           List<Process.PluginDescribeResult.InputParameter>{
               new Process.PluginDescribeResult.InputParameter('subject',
               Process.PluginDescribeResult.ParameterType.STRING, true)
            };
        result.outputParameters = new
           List<Process.PluginDescribeResult.OutputParameter>{ };
        return result;
    }
}


