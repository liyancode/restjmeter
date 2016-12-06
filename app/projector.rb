# projector.rb
module RESTJMeter
  class Projector
    # must require 'ruby-jmeter' gem
    # body_hash format:
    # {
    #     "API"=>{
    #         "ServerName_or_IP"=>"slce003.com",
    #         "Http_or_Https"=>"https",
    #         "Method"=>"GET",
    #         "Path"=>"/",
    #         "Parameters"=>"username=ll&password=fdafa",
    #         "BodyData"=>"{fdsadfafaf}"
    #     },
    #     "Headers"=>[
    #         ['Header1','Header1Value'],
    #         ['Header2','Header2Value'],
    #         ['Header3','Header3Value']
    #     ],
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
    def Projector.generate_jmx_file_new(body_hash,jmx_file_name,test_id)
      # judge UserDefinedVariables is null or not
      p body_hash
      user_defined_vars=body_hash["UserDefinedVariables"]
      if user_defined_vars.size!=0
        user_defined_vars.each{|var_arr|
          csv= File.new("#{CONFIG["User_Defined_Vars_CSV_Dir"]}#{test_id}_#{var_arr[0]}.csv","a")
          csv.puts(var_arr[1].split(","))
          csv.flush
          # STDOUT.flush
          p "CSV file created:#{var_arr[0]} "
        }
      end
      header_array=[]
      body_hash["Headers"].each{|h|
        header_array<<{name:h[0],value:h[1]}
      }
      method_type=body_hash["API"]["Method"]
      if method_type.upcase=='GET'
        p "#{test_id} GET"
        test name:test_id do
          threads count:body_hash["ThreadProperties"]["Number_of_Threads"].to_i,
                  rampup: CONFIG["ThreadGroup_RampUpPeriod_Default"],
                  loops:body_hash["ThreadProperties"]["LoopCount"].to_i,
                  delayedStart: false,
                  scheduler:false do
            cookies clear_each_iteration: true# HTTP Cookie Manager
            user_defined_vars.each{|var_arr|
                csv_data_set_config name:var_arr[0], filename: "#{CONFIG["User_Defined_Vars_CSV_Dir"]}#{test_id}_#{var_arr[0]}.csv",variableNames:var_arr[0]
            }
            aggregate_report
            visit name:"#{body_hash["API"]["Path"].split("?")[0]}_#{method_type.upcase}",
                  url:"#{body_hash["API"]["ServerName_or_IP"]}",
                  protocol:"#{body_hash["API"]["Http_or_Https"]}",
                  method:"#{method_type}",
                  path: "#{body_hash["API"]["Path"]}#{body_hash["API"]["Parameters"]}",
                  implementation:'HttpClient4',
                  connect_timeout: '30000',
                  response_timeout: '60000' do
              header header_array
            end
          end
        end.jmx(file: jmx_file_name)
      elsif method_type.upcase=='POST'
        p "#{test_id} POST"
        test name:test_id do
          threads count:body_hash["ThreadProperties"]["Number_of_Threads"].to_i,
                  rampup: CONFIG["ThreadGroup_RampUpPeriod_Default"],
                  loops:body_hash["ThreadProperties"]["LoopCount"].to_i,
                  scheduler:false do
            cookies clear_each_iteration: true# HTTP Cookie Manager
            user_defined_vars.each{|var_arr|
              csv_data_set_config name:var_arr[0], filename: "#{CONFIG["User_Defined_Vars_CSV_Dir"]}#{test_id}_#{var_arr[0]}.csv",variableNames:var_arr[0]
            }
            aggregate_report
            post name:"#{body_hash["API"]["Path"].split("?")[0]}_#{method_type.upcase}",
                 url:"#{body_hash["API"]["ServerName_or_IP"]}",
                 protocol:"#{body_hash["API"]["Http_or_Https"]}",
                 method:"#{method_type}",
                 path: "#{body_hash["API"]["Path"]}#{body_hash["API"]["Parameters"]}",
                 implementation:'HttpClient4',
                 connect_timeout: '30000',
                 response_timeout: '60000',
                 raw_body:body_hash["API"]["BodyData"] do
              header header_array
            end
          end
        end.jmx(file: jmx_file_name)
      elsif method_type.upcase=='PUT'
        p "#{test_id} PUT"
        test name:test_id do
          threads count:body_hash["ThreadProperties"]["Number_of_Threads"].to_i,
                  rampup: CONFIG["ThreadGroup_RampUpPeriod_Default"],
                  loops:body_hash["ThreadProperties"]["LoopCount"].to_i,
                  scheduler:false do
            cookies clear_each_iteration: true# HTTP Cookie Manager
            user_defined_vars.each{|var_arr|
              csv_data_set_config name:var_arr[0], filename: "#{CONFIG["User_Defined_Vars_CSV_Dir"]}#{test_id}_#{var_arr[0]}.csv",variableNames:var_arr[0]
            }
            aggregate_report
            post name:"#{body_hash["API"]["Path"].split("?")[0]}_#{method_type.upcase}",
                 url:"#{body_hash["API"]["ServerName_or_IP"]}",
                 protocol:"#{body_hash["API"]["Http_or_Https"]}",
                 method:"#{method_type}",
                 path: "#{body_hash["API"]["Path"]}#{body_hash["API"]["Parameters"]}",
                 implementation:'HttpClient4',
                 connect_timeout: '30000',
                 response_timeout: '60000',
                 raw_body:body_hash["API"]["BodyData"] do
              header header_array
            end
          end
        end.jmx(file: jmx_file_name)
      else
        p "#{method_type} is not supported."
      end
      p "jmx generated!"
    end
  end
end