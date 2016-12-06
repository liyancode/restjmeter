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
    mutex.synchronize{
      if msg_queue.size>0
        begin
          temp_msg=msg_queue.pop
          test_id=temp_msg[0]
          RESTJMeter::Util.update_log_jmx_str_status(DB,test_id,'running')
          jmx_body=temp_msg[1]
          jmx_file_name="#{CONFIG["JMX_File_DIR"]}#{test_id}.jmx"

          # generate jmx file
          # generate_jmx_file(jmx_body,jmx_file_name,test_id)
          RESTJMeter::Projector.generate_jmx_file_new(jmx_body,jmx_file_name,test_id)

          time_now=Time.now
          # generate daily results dir
          # daily_results_dir=RESTJMeter::Controller.daily_results_dir(time_now)
          # generate results dir for testid
          test_results_dir=RESTJMeter::Controller.test_results_dir(time_now,test_id)

          # append perfmon monitor to jmx file
          RESTJMeter::Controller.append_perfmon_to_jmx(jmx_file_name,test_id,jmx_body["TargetHost"],test_results_dir+"/")

          # generate jmeter_jtl_temp_file
          jmeter_jtl_temp_file="#{test_results_dir}/temp_jtl_#{time_now.to_i}.jtl"
          # generate jmeter_csv_file
          jmeter_csv_file="#{test_results_dir}/#{test_id}.csv"

          # run testing
          RESTJMeter::Controller.run_jmeter(jmx_file_name,jmeter_jtl_temp_file,jmeter_csv_file)

          # save to db
          RESTJMeter::Controller.save_data_to_db(time_now,DB,test_id,jmeter_csv_file)

          RESTJMeter::Util.update_log_jmx_str_status(DB,test_id,'success')

          # delete temp files.
          # RESTJMeter::Controller.delete_temp_jtl(jmeter_jtl_temp_file) # 161206: keep jtl file, not delete
        rescue Exception=>e
          p e
          RESTJMeter::Util.update_log_jmx_str_status(DB,test_id,'fail')
        end
      end
    }
    sleep(1) # 1 sec interval heartbeat
  end
}
# -------------------------------------

# -----------
# REST api

# filter. requests that not begin with '/rest' will be recognized as bad request
before /^(?!\/(rest).*)/ do
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
#     "TargetHost"=>"***.com"
# }
post '/rest/jmx' do
  if request.env["HTTP_X_RESTJMETER_TOKEN"]!=CONFIG["X_RESTJmeter_TOKEN"]
    status 403
    '{error:"X_RESTJmeter_TOKEN incorrect"}'
  else
    body_str=request.body.string
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
      {:test_id=>test_id}.to_json # return the unique test_id
    rescue Exception=>e
      p e
      p "Incorrect body:#{body_str}"
      status 400
      '{error:"body format incorrect"}'
    end
  end
end

# GET. return testing status and results to client
get '/rest/result/:testid' do
  if request.env["HTTP_X_RESTJMETER_TOKEN"]!=CONFIG["X_RESTJmeter_TOKEN"]
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
      return {:test_id=>test_id,:status=>"404"}.to_json
    end
    if log_status=='success'
      DB.fetch("select * from jmeter_aggregate_report where testid='#{test_id}'").each{|row|
        result<<row
      }
    end
    {:test_id=>test_id,:status=>log_status,:results=>result}.to_json
  end
end