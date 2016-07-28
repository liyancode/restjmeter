# restjmeter
## RESTful apis for performance testing by JMeter  

### Design overview Data Flow Diagram  

![Alt text](https://github.com/liyancode/restjmeter/blob/master/DFG.JPG)  

### API
#### POST /rest/jmx  
```  
Request URL:  http://hostname_or_ip:port/rest/jmx  
Request Method:  POST  
Status Code:  202 Accepted  

Request Headers:  
X_RESTJmeter_TOKEN:UkVTVEptZXRlcl9UT0tFTg==  

Request Payload:  
 
{
    "API"=>{
        "ServerName_or_IP"=>"www.google.com",
        "Http_or_Https"=>"https",
        "Method"=>"GET",
        "Path"=>"/testpath",
        "Parameters"=>"username=ll&password=fdafa",
        "BodyData"=>"{fdsadfafaf}"
    },
    "Headers"=>[["h1","01"],["h2","02"]],
    "ThreadProperties"=>{
        "Number_of_Threads"=>"1",
        "LoopCount"=>"1"
    },
    "SchedulerConfiguration"=>{
        "DurationSeconds"=>"300"
    },
    "UserDefinedVariables"=>[
        ["variable_name1","4124324312,43214134,41514554,54352525,542352345,54235"],
        []
    ]
}  

Response:  
{"test_id":"1607190613_NL_OA"}  
```  

#### GET  /rest/result/:testid  
```  
Request URL:  http://hostname_or_ip:port/rest/result/1607190613_NL_OA  
Request Method:  GET  
Status Code:  200 OK  

Request Headers:  
X_RESTJmeter_TOKEN:UkVTVEptZXRlcl9UT0tFTg==  

Response:   
{
    "test_id": "1607190613_NL_OA",
    "status": "success",
    "results": [
        {
            "id": 3,
            "testid": "1607190613_NL_OA",
            "time_stamp": 1468908794,
            "label": "www.google.com",
            "samples": 1,
            "average": 587,
            "median": 587,
            "perc90_line": 587,
            "perc95_line": null,
            "perc99_line": null,
            "min": 587,
            "max": 587,
            "error_rate": 100,
            "throughput": 1.7,
            "kb_per_sec": 3
        }
    ]
}  
```