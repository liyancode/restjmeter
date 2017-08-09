require 'bundler/setup'
Bundler.require

# pay attention to the sequence of these requires if there is dependency between each others!!
require './config'
require './app/util'
require './app/controller'
require './app/projector'

# global vars

# init a Queue for cache unhandled request messages
msg_queue=Queue.new

# sync lock for sync operation
mutex=Mutex.new

# ----------------------------------------------------------------------------------------------------------------
# init the daemon thread for handling the request messages ONE by ONE( max 1 testing being ran at one time point)!
Thread.new{
  while true
    temp_size=0
    mutex.synchronize{
      temp_size=msg_queue.size
    }
    if msg_queue.size>0
      begin
        p "==Current MSG Q size: #{temp_size}"
        LOGGER.info("==Current MSG Q size: #{temp_size}, now pop one to test...")
        temp_msg=[]
        mutex.synchronize{
          temp_msg=msg_queue.pop
        }
        test_id=temp_msg[0]
        p "====Testing: #{test_id} started..."
        LOGGER.info("====Testing: #{test_id} started...")
        RESTJMeter::Util.update_log_jmx_str_status(DB,test_id,'running')
        jmx_body=temp_msg[1]
        jmx_file_name="#{CONFIG["JMX_File_DIR"]}#{test_id}.jmx"

        # generate jmx file
        # generate_jmx_file(jmx_body,jmx_file_name,test_id)
        RESTJMeter::Projector.generate_jmx_file_new(jmx_body,jmx_file_name,test_id)

        time_start=Time.now
        # generate daily results dir
        RESTJMeter::Controller.daily_results_dir(time_start)
        # generate results dir for testid
        test_results_dir=RESTJMeter::Controller.test_results_dir(time_start,test_id)

        perfmon_switch=jmx_body["PerfmonSwitch"]
        if perfmon_switch=='true'
          # append perfmon monitor to jmx file
          RESTJMeter::Controller.append_perfmon_to_jmx(jmx_file_name,test_id,jmx_body["TargetHost"],test_results_dir+"/")
        end

        # FunctionTest
        is_func_test=jmx_body["FunctionTest"]
        if is_func_test=='true'||is_func_test==true
          # append Regular Expression Extractor status code xml part to jmx file
          p "append Regular Expression Extractor status code xml part to jmx file"
          RESTJMeter::Controller.append_extract_status_code_to_jmx(jmx_file_name)
        end

        # generate jmeter_jtl_temp_file
        jmeter_jtl_temp_file="#{test_results_dir}/temp_jtl_#{time_start.to_i}.jtl"
        # generate jmeter_csv_file
        jmeter_csv_file="#{test_results_dir}/#{test_id}.csv"

        # run testing
        RESTJMeter::Controller.run_jmeter(jmx_file_name,jmeter_jtl_temp_file,jmeter_csv_file)

        # compute time cost
        time_end=Time.now
        time_cost=time_end-time_start # unit is second
        # save to db
        RESTJMeter::Controller.save_data_to_db(time_start,time_end,time_cost,DB,test_id,jmeter_csv_file)

        error_rate=DB.fetch("select error_rate from jmeter_aggregate_report where testid='#{test_id}'").map(:error_rate)[0]
        if error_rate>CONFIG["Aggregate_Error_Rate_Threshold"]
          RESTJMeter::Util.update_log_jmx_str_status(DB,test_id,'error')
        else
          RESTJMeter::Util.update_log_jmx_str_status(DB,test_id,'success')
        end

        if perfmon_switch=='true'
          # save all perfmon metrics data to db
          RESTJMeter::Controller.save_all_perfmon_data_to_db(DB,test_id,test_results_dir)
        end
        # RESTJMeter::Controller.save_all_perfmon_data_to_db(DB,"1612061001_LB_KI","/Users/yanli6/Desktop/1612061001_LB_KI")
        # delete temp files.
        # RESTJMeter::Controller.delete_temp_jtl(jmeter_jtl_temp_file) # 161206: keep jtl file, not delete
        p "====Testing: #{test_id} end."
        LOGGER.info("====Testing: #{test_id} end.")
      rescue Exception=>e
        p e
        LOGGER.error("====Testing: #{test_id} error:#{e}")
        RESTJMeter::Util.update_log_jmx_str_status(DB,test_id,'fail')
        LOGGER.info("====Testing: #{test_id} end.")
      end
    end
    sleep(1) # 1 sec interval heartbeat
  end
}
# -------------------------------------

# -----------
# REST api

# filter. requests that not begin with '/rest' will be recognized as bad request
pattern = Mustermann.new('/*', except:'/rest')

before pattern do
  LOGGER.info("Access log. Bad request in:#{request}")
  status 400
  '{error:"bad request. your request endpoint should start with /rest."}'
end

# POST. receive testing message to generate jmeter script
# body format:
# {
#     "API"=>{
#         "ServerName_or_IP"=>"slce003.com",
#         "Http_or_Https"=>"https",
#         "Method"=>"GET",
#         "Path"=>"/",
#         "Parameters"=>"username=ll&password=fdafa",
#         "BodyData"=>"{fdsadfafaf}"
#     },
#     "ThreadProperties"=>{
#         "Number_of_Threads"=>"10",
#         "LoopCount"=>"5" # -1 means "forever"
#     },
#     "SchedulerConfiguration"=>{
#         "DurationSeconds"=>"300"
#     },
#     "UserDefinedVariables"=>[
#        ["variable_name1","4124324312,43214134,41514554,54352525,542352345,54235"],
#        []
#     ],
#     "PerfmonSwitch"=>'*',//'true' or 'false'
#     "TargetHost"=>"***.com"
# }
post '/rest/jmx' do
  p "post"
  if request.env["HTTP_X_RESTJMETER_TOKEN"]!=CONFIG["X_RESTJmeter_TOKEN"]
    LOGGER.info("Access log. Request with invalid HTTP_X_RESTJMETER_TOKEN:#{request.env["HTTP_X_RESTJMETER_TOKEN"]}")
    status 403
    '{error:"X_RESTJmeter_TOKEN incorrect"}'
  else
    body_str=request.body.string
    LOGGER.info("Access log. Request body:#{body_str}")
    begin
      body_hash=eval(body_str)
      test_id=RESTJMeter::Util.generate_testid # unique random id
      RESTJMeter::Util.log_jmx_str(DB,test_id,'sleep',body_str)
      Thread.new{
        mutex.synchronize{
          msg_queue.push([test_id,body_hash])
        }
      }
      status 202
      MultiJson.dump({:test_id=>test_id})# return the unique test_id
    rescue Exception=>e
      p e
      p "Incorrect body:#{body_str}"
      LOGGER.error("Access log. Incorrect Request body:#{body_str}")
      LOGGER.error("Access log. Incorrect Request body exception:#{e}")
      status 400
      '{error:"body format incorrect"}'
    end
  end
end

# GET. return testing status and results to client
get '/rest/result/:testid' do
  LOGGER.info("Access log. GET: #{request}")
  if request.env["HTTP_X_RESTJMETER_TOKEN"]!=CONFIG["X_RESTJmeter_TOKEN"]
    LOGGER.info("Access log. Request with invalid HTTP_X_RESTJMETER_TOKEN:#{request.env["HTTP_X_RESTJMETER_TOKEN"]}")
    status 403
    '{error:"X_RESTJmeter_TOKEN incorrect"}'
  else
    result=[]
    test_id= params[:testid]
    log_status='-1'
    DB.fetch("select status from jmeter_jmx_log where testid='#{test_id}'").each{|row|
      log_status=row[:status]
    }
    if log_status=='-1'
      status 404
      return MultiJson.dump({:test_id=>test_id,:status=>"404"})
    end
    if log_status=='success'||log_status=='error'
      DB.fetch("select * from jmeter_aggregate_report where testid='#{test_id}'").each{|row|
        result<<row
      }
    end
    MultiJson.dump({:test_id=>test_id,:status=>log_status,:results=>result})
  end
end

get '/rest/waitingsize' do
  LOGGER.info("Access log. GET: #{request}")
  if request.env["HTTP_X_RESTJMETER_TOKEN"]!=CONFIG["X_RESTJmeter_TOKEN"]
    LOGGER.info("Access log. Request with invalid HTTP_X_RESTJMETER_TOKEN:#{request.env["HTTP_X_RESTJMETER_TOKEN"]}")
    status 403
    '{error:"X_RESTJmeter_TOKEN incorrect"}'
  else
    size=-1
    mutex.synchronize{
      size=msg_queue.size
    }
    status 200
    size
  end
end

get '/rest/hello' do
  status 200
  size=-1
  mutex.synchronize{
    size= msg_queue.size
  }
  p "Q size:#{size}"
  MultiJson.dump({:status=>"good",:queue_size=>size})
end

# function test result
# path params must contains: ?testid=177e8&status_code=200
# body is the response body
post '/rest/result/function' do
  begin
    if params[:testid]!=nil&&params[:status_code]!=nil
      RESTJMeter::Util.insert_function_test_result(DB,params[:testid],params[:status_code].to_i,request.body.read)
      status 200
    else
      status 400
    end
  rescue Exception=>e
    p e
    LOGGER.error(e)
    status 500
  end
end