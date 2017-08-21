Asynchronous HTTP Client (Script has been tested successfully under Python 3.6.1)


1. Introduction 

AsynHttpClient is a module to realize the Get funtion regarding to provided URLs
URLs is enhanced to support the parameters such as:

```
http://www.foo.com/{bar}/{baz}/bam
```

where {bar} and {baz} are the parameters to be found in the query dictionary.

For example the query dictionary {'bar': 'mybar', 'baz': 'ubaz', 'foo': 'onefoo'}
gives the following url for a GET request:

```
http://www.foo.com/mybar/ubaz/bam?foo=onefoo
```

The script can be run under batch mode as well as manual retry mode
Command line as below:

```
python AsynHttpClient.py <Filename.json>
python AsynHttpClient.py <manualRetry.json> <Line No.> 
```




2. IO

Input:

2.1 Config File:
    
```
<module>/config.ini
```
Configuration of Throttling No of each domain and Times of AutoRetry 
is available in this configuration file. The configuration file will 
be read by the script each time the script is initialized.


2.2 Batch URLs Files in Json format

This filename need to be passed as the first arguments when running script.
A dictionary is used for each URL in this batch file and it has below structure: 

```
{"ext_url": "", "ext_dict": ""}
```

Refer to the unittest.json for an example


OUTPUT:

2.3 Output Folder

Output folders will be automatically created after each execution
and 3 output files will also be generated
```
<module>/output/<timestamp_initial>
<module>/output/<timestamp_initial>/out
<module>/output/<timestamp_initial>/err
<module>/output/<timestamp_initial>/log
```

out file writes the request result/data from the successfully connections
err file writes the (extended) URLs for failed connections
log file writes the log during excution, same as screen display


2.4 ManualRetry Entries

```
<Module>/manualRetry.json
```

After each executing, the manual retry entry file will be updated with the assemble 
of the failure cases during last execution. If AutoRetry was enabled in the last run
the entry will refer to the result of last time of AutoRetry


3. Tests

Testcases for unit test is included in below path:

```
<module>/unittest.json
```

To trigger the unittest, can use below command line:

```
python AsynHttpClient.py unittest.json
```