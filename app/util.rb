# util.rb
module RESTJMeter
  class Util
    # generate testid
    def Util.generate_testid
      tn=Time.now.getutc.to_s
      "#{tn[2,2]}#{tn[5,2]}#{tn[8,2]}#{tn[11,2]}#{tn[14,2]}_#{(rand(59)*100/236+65).chr}#{(rand(59)*100/236+65).chr}_#{(rand(59)*100/236+65).chr}#{(rand(59)*100/236+65).chr}"
    end

    # @param csv_folder like "/fa/fdasfa/". end with '/'
    # @param values format "value1,value2,value3,....". split with ','
    def Util.generate_user_define_csv_file(csv_folder,variable_name,values)
      user_define_csv_file=File.open("#{csv_folder}#{variable_name}.csv",'w')
      values_arr=values.split(',')
      values_arr.each{|value|
        user_define_csv_file.puts value
      }
    end

    def Util.log_jmx_str(db,test_id,status,jmx_str)
      begin
        db.fetch("insert into jmeter_jmx_log(testid,status,time_stamp,jmx_content) values('#{test_id}','#{status}',#{Time.now.to_i},'#{jmx_str}')").insert
      rescue Exception=>e
        p e
        LOGGER.error "Util.log_jmx_str #{e}"
      end
    end

    # status: 'sleep','running','fail','success'
    def Util.update_log_jmx_str_status(db,test_id,new_status)
      begin
        db.fetch("update jmeter_jmx_log set status='#{new_status}' where testid='#{test_id}'").update
      rescue Exception=>e
        p e
        LOGGER.error "Util.update_log_jmx_str_status #{e}"
      end
    end

    # @param csv_file_name: must be absolute path ended with .csv
    # @param content_string: ***,***,***,***... will split by ','
    def Util.generate_csv_data_set_file(csv_file_name,content_string)
      begin
        csv= File.new(csv_file_name,"a")
        csv.puts(content_string.split(","))
      rescue Exception=>e
        p e
        LOGGER.error "Util.generate_csv_data_set_file #{e}"
      end
    end

    # csv format: C:\perf-team-shared-files\yanli\projects\restjmeter\data\perfmon_jmx\1610080626_JJ_WT_cpu.csv
    def Util.generate_perfmon_monitor_xml_str(test_id,target_host,perfmon_results_csv_dir)
      begin
        if (test_id!=nil&&test_id!='')&&(target_host!=nil&&target_host!='')&&(perfmon_results_csv_dir!=nil&&perfmon_results_csv_dir!='')
        return '<kg.apc.jmeter.perfmon.PerfMonCollector guiclass="kg.apc.jmeter.vizualizers.PerfMonGui" testclass="kg.apc.jmeter.perfmon.PerfMonCollector" testname="perfmon_cpu" enabled="true">
          <boolProp name="ResultCollector.error_logging">false</boolProp>
          <objProp>
            <name>saveConfig</name>
            <value class="SampleSaveConfiguration">
              <time>true</time>
              <latency>true</latency>
              <timestamp>true</timestamp>
              <success>true</success>
              <label>true</label>
              <code>true</code>
              <message>true</message>
              <threadName>true</threadName>
              <dataType>true</dataType>
              <encoding>false</encoding>
              <assertions>true</assertions>
              <subresults>true</subresults>
              <responseData>false</responseData>
              <samplerData>false</samplerData>
              <xml>false</xml>
              <fieldNames>true</fieldNames>
              <responseHeaders>false</responseHeaders>
              <requestHeaders>false</requestHeaders>
              <responseDataOnError>false</responseDataOnError>
              <saveAssertionResultsFailureMessage>false</saveAssertionResultsFailureMessage>
              <assertionsResultsToSave>0</assertionsResultsToSave>
              <bytes>true</bytes>
              <threadCounts>true</threadCounts>
            </value>
          </objProp>
          <stringProp name="filename">'+perfmon_results_csv_dir+''+test_id+'_cpu.csv</stringProp>
          <longProp name="interval_grouping">1000</longProp>
          <boolProp name="graph_aggregated">false</boolProp>
          <stringProp name="include_sample_labels"></stringProp>
          <stringProp name="exclude_sample_labels"></stringProp>
          <stringProp name="start_offset"></stringProp>
          <stringProp name="end_offset"></stringProp>
          <boolProp name="include_checkbox_state">false</boolProp>
          <boolProp name="exclude_checkbox_state">false</boolProp>
          <collectionProp name="metricConnections">
            <collectionProp name="600412421">
              <stringProp name="-466184153">'+target_host+'</stringProp>
              <stringProp name="1571004">3450</stringProp>
              <stringProp name="66952">CPU</stringProp>
              <stringProp name="-698876166">label=CPU_user:user</stringProp>
            </collectionProp>
            <collectionProp name="-1466130323">
              <stringProp name="-466184153">'+target_host+'</stringProp>
              <stringProp name="1571004">3450</stringProp>
              <stringProp name="66952">CPU</stringProp>
              <stringProp name="1482288094">label=CPU_all:combined</stringProp>
            </collectionProp>
          </collectionProp>
        </kg.apc.jmeter.perfmon.PerfMonCollector>
        <hashTree/>
        <kg.apc.jmeter.perfmon.PerfMonCollector guiclass="kg.apc.jmeter.vizualizers.PerfMonGui" testclass="kg.apc.jmeter.perfmon.PerfMonCollector" testname="perfmon_memory" enabled="true">
          <boolProp name="ResultCollector.error_logging">false</boolProp>
          <objProp>
            <name>saveConfig</name>
            <value class="SampleSaveConfiguration">
              <time>true</time>
              <latency>true</latency>
              <timestamp>true</timestamp>
              <success>true</success>
              <label>true</label>
              <code>true</code>
              <message>true</message>
              <threadName>true</threadName>
              <dataType>true</dataType>
              <encoding>false</encoding>
              <assertions>true</assertions>
              <subresults>true</subresults>
              <responseData>false</responseData>
              <samplerData>false</samplerData>
              <xml>false</xml>
              <fieldNames>true</fieldNames>
              <responseHeaders>false</responseHeaders>
              <requestHeaders>false</requestHeaders>
              <responseDataOnError>false</responseDataOnError>
              <saveAssertionResultsFailureMessage>false</saveAssertionResultsFailureMessage>
              <assertionsResultsToSave>0</assertionsResultsToSave>
              <bytes>true</bytes>
              <threadCounts>true</threadCounts>
            </value>
          </objProp>
          <stringProp name="filename">'+perfmon_results_csv_dir+''+test_id+'_memory.csv</stringProp>
          <longProp name="interval_grouping">1000</longProp>
          <boolProp name="graph_aggregated">false</boolProp>
          <stringProp name="include_sample_labels"></stringProp>
          <stringProp name="exclude_sample_labels"></stringProp>
          <stringProp name="start_offset"></stringProp>
          <stringProp name="end_offset"></stringProp>
          <boolProp name="include_checkbox_state">false</boolProp>
          <boolProp name="exclude_checkbox_state">false</boolProp>
          <collectionProp name="metricConnections">
            <collectionProp name="-243078500">
              <stringProp name="-466184153">'+target_host+'</stringProp>
              <stringProp name="1571004">3450</stringProp>
              <stringProp name="-1993889503">Memory</stringProp>
              <stringProp name="820929889">label=Memory_used_MB:unit=mb:used</stringProp>
            </collectionProp>
            <collectionProp name="-152984473">
              <stringProp name="-466184153">'+target_host+'</stringProp>
              <stringProp name="1571004">3450</stringProp>
              <stringProp name="-1993889503">Memory</stringProp>
              <stringProp name="560692415">label=Memory_free_MB:unit=mb:free</stringProp>
            </collectionProp>
          </collectionProp>
        </kg.apc.jmeter.perfmon.PerfMonCollector>
        <hashTree/>
        <kg.apc.jmeter.perfmon.PerfMonCollector guiclass="kg.apc.jmeter.vizualizers.PerfMonGui" testclass="kg.apc.jmeter.perfmon.PerfMonCollector" testname="perfmon_disk" enabled="true">
          <boolProp name="ResultCollector.error_logging">false</boolProp>
          <objProp>
            <name>saveConfig</name>
            <value class="SampleSaveConfiguration">
              <time>true</time>
              <latency>true</latency>
              <timestamp>true</timestamp>
              <success>true</success>
              <label>true</label>
              <code>true</code>
              <message>true</message>
              <threadName>true</threadName>
              <dataType>true</dataType>
              <encoding>false</encoding>
              <assertions>true</assertions>
              <subresults>true</subresults>
              <responseData>false</responseData>
              <samplerData>false</samplerData>
              <xml>false</xml>
              <fieldNames>true</fieldNames>
              <responseHeaders>false</responseHeaders>
              <requestHeaders>false</requestHeaders>
              <responseDataOnError>false</responseDataOnError>
              <saveAssertionResultsFailureMessage>false</saveAssertionResultsFailureMessage>
              <assertionsResultsToSave>0</assertionsResultsToSave>
              <bytes>true</bytes>
              <threadCounts>true</threadCounts>
            </value>
          </objProp>
          <stringProp name="filename">'+perfmon_results_csv_dir+''+test_id+'_disk.csv</stringProp>
          <longProp name="interval_grouping">1000</longProp>
          <boolProp name="graph_aggregated">false</boolProp>
          <stringProp name="include_sample_labels"></stringProp>
          <stringProp name="exclude_sample_labels"></stringProp>
          <stringProp name="start_offset"></stringProp>
          <stringProp name="end_offset"></stringProp>
          <boolProp name="include_checkbox_state">false</boolProp>
          <boolProp name="exclude_checkbox_state">false</boolProp>
          <collectionProp name="metricConnections">
            <collectionProp name="-1820290516">
              <stringProp name="-466184153">'+target_host+'</stringProp>
              <stringProp name="1571004">3450</stringProp>
              <stringProp name="2112896831">Disks I/O</stringProp>
              <stringProp name="-464826449">label=Disk_queue:queue</stringProp>
            </collectionProp>
            <collectionProp name="1773171056">
              <stringProp name="-466184153">'+target_host+'</stringProp>
              <stringProp name="1571004">3450</stringProp>
              <stringProp name="2112896831">Disks I/O</stringProp>
              <stringProp name="-500090937">label=Disk_reads:reads</stringProp>
            </collectionProp>
            <collectionProp name="-1410357505">
              <stringProp name="-466184153">'+target_host+'</stringProp>
              <stringProp name="1571004">3450</stringProp>
              <stringProp name="2112896831">Disks I/O</stringProp>
              <stringProp name="-1513838911">label=Disk_writes:writes</stringProp>
            </collectionProp>
          </collectionProp>
        </kg.apc.jmeter.perfmon.PerfMonCollector>
        <hashTree/>
        <kg.apc.jmeter.perfmon.PerfMonCollector guiclass="kg.apc.jmeter.vizualizers.PerfMonGui" testclass="kg.apc.jmeter.perfmon.PerfMonCollector" testname="perfmon_network" enabled="true">
          <boolProp name="ResultCollector.error_logging">false</boolProp>
          <objProp>
            <name>saveConfig</name>
            <value class="SampleSaveConfiguration">
              <time>true</time>
              <latency>true</latency>
              <timestamp>true</timestamp>
              <success>true</success>
              <label>true</label>
              <code>true</code>
              <message>true</message>
              <threadName>true</threadName>
              <dataType>true</dataType>
              <encoding>false</encoding>
              <assertions>true</assertions>
              <subresults>true</subresults>
              <responseData>false</responseData>
              <samplerData>false</samplerData>
              <xml>false</xml>
              <fieldNames>true</fieldNames>
              <responseHeaders>false</responseHeaders>
              <requestHeaders>false</requestHeaders>
              <responseDataOnError>false</responseDataOnError>
              <saveAssertionResultsFailureMessage>false</saveAssertionResultsFailureMessage>
              <assertionsResultsToSave>0</assertionsResultsToSave>
              <bytes>true</bytes>
              <threadCounts>true</threadCounts>
            </value>
          </objProp>
          <stringProp name="filename">'+perfmon_results_csv_dir+''+test_id+'_network.csv</stringProp>
          <longProp name="interval_grouping">1000</longProp>
          <boolProp name="graph_aggregated">false</boolProp>
          <stringProp name="include_sample_labels"></stringProp>
          <stringProp name="exclude_sample_labels"></stringProp>
          <stringProp name="start_offset"></stringProp>
          <stringProp name="end_offset"></stringProp>
          <boolProp name="include_checkbox_state">false</boolProp>
          <boolProp name="exclude_checkbox_state">false</boolProp>
          <collectionProp name="metricConnections">
            <collectionProp name="-332742889">
              <stringProp name="-466184153">'+target_host+'</stringProp>
              <stringProp name="1571004">3450</stringProp>
              <stringProp name="-274342153">Network I/O</stringProp>
              <stringProp name="74735694">label=Network_bytesrecv_Kb:unit=kb:bytesrecv</stringProp>
            </collectionProp>
            <collectionProp name="1375348197">
              <stringProp name="-466184153">'+target_host+'</stringProp>
              <stringProp name="1571004">3450</stringProp>
              <stringProp name="-274342153">Network I/O</stringProp>
              <stringProp name="288052530">label=Network_bytessent_Kb:unit=kb:bytessent</stringProp>
            </collectionProp>
          </collectionProp>
        </kg.apc.jmeter.perfmon.PerfMonCollector>
        <hashTree/>
        <kg.apc.jmeter.perfmon.PerfMonCollector guiclass="kg.apc.jmeter.vizualizers.PerfMonGui" testclass="kg.apc.jmeter.perfmon.PerfMonCollector" testname="perfmon_tcp" enabled="true">
          <boolProp name="ResultCollector.error_logging">false</boolProp>
          <objProp>
            <name>saveConfig</name>
            <value class="SampleSaveConfiguration">
              <time>true</time>
              <latency>true</latency>
              <timestamp>true</timestamp>
              <success>true</success>
              <label>true</label>
              <code>true</code>
              <message>true</message>
              <threadName>true</threadName>
              <dataType>true</dataType>
              <encoding>false</encoding>
              <assertions>true</assertions>
              <subresults>true</subresults>
              <responseData>false</responseData>
              <samplerData>false</samplerData>
              <xml>false</xml>
              <fieldNames>true</fieldNames>
              <responseHeaders>false</responseHeaders>
              <requestHeaders>false</requestHeaders>
              <responseDataOnError>false</responseDataOnError>
              <saveAssertionResultsFailureMessage>false</saveAssertionResultsFailureMessage>
              <assertionsResultsToSave>0</assertionsResultsToSave>
              <bytes>true</bytes>
              <threadCounts>true</threadCounts>
            </value>
          </objProp>
          <stringProp name="filename">'+perfmon_results_csv_dir+''+test_id+'_tcp.csv</stringProp>
          <longProp name="interval_grouping">1000</longProp>
          <boolProp name="graph_aggregated">false</boolProp>
          <stringProp name="include_sample_labels"></stringProp>
          <stringProp name="exclude_sample_labels"></stringProp>
          <stringProp name="start_offset"></stringProp>
          <stringProp name="end_offset"></stringProp>
          <boolProp name="include_checkbox_state">false</boolProp>
          <boolProp name="exclude_checkbox_state">false</boolProp>
          <collectionProp name="metricConnections">
            <collectionProp name="-1115534750">
              <stringProp name="-466184153">'+target_host+'</stringProp>
              <stringProp name="1571004">3450</stringProp>
              <stringProp name="82881">TCP</stringProp>
              <stringProp name="-781995859">label=TCP_estab:estab</stringProp>
            </collectionProp>
            <collectionProp name="-263129256">
              <stringProp name="-466184153">'+target_host+'</stringProp>
              <stringProp name="1571004">3450</stringProp>
              <stringProp name="82881">TCP</stringProp>
              <stringProp name="1945514029">label=TCP_time_wait:time_wait</stringProp>
            </collectionProp>
            <collectionProp name="-18608827">
              <stringProp name="-466184153">'+target_host+'</stringProp>
              <stringProp name="1571004">3450</stringProp>
              <stringProp name="82881">TCP</stringProp>
              <stringProp name="2050891923">label=TCP_close_wait:close_wait</stringProp>
            </collectionProp>
          </collectionProp>
        </kg.apc.jmeter.perfmon.PerfMonCollector>
        <hashTree/>
        <kg.apc.jmeter.perfmon.PerfMonCollector guiclass="kg.apc.jmeter.vizualizers.PerfMonGui" testclass="kg.apc.jmeter.perfmon.PerfMonCollector" testname="perfmon_jmx" enabled="true">
          <boolProp name="ResultCollector.error_logging">false</boolProp>
          <objProp>
            <name>saveConfig</name>
            <value class="SampleSaveConfiguration">
              <time>true</time>
              <latency>true</latency>
              <timestamp>true</timestamp>
              <success>true</success>
              <label>true</label>
              <code>true</code>
              <message>true</message>
              <threadName>true</threadName>
              <dataType>true</dataType>
              <encoding>false</encoding>
              <assertions>true</assertions>
              <subresults>true</subresults>
              <responseData>false</responseData>
              <samplerData>false</samplerData>
              <xml>false</xml>
              <fieldNames>true</fieldNames>
              <responseHeaders>false</responseHeaders>
              <requestHeaders>false</requestHeaders>
              <responseDataOnError>false</responseDataOnError>
              <saveAssertionResultsFailureMessage>false</saveAssertionResultsFailureMessage>
              <assertionsResultsToSave>0</assertionsResultsToSave>
              <bytes>true</bytes>
              <threadCounts>true</threadCounts>
            </value>
          </objProp>
          <stringProp name="filename">'+perfmon_results_csv_dir+''+test_id+'_jmx.csv</stringProp>
          <longProp name="interval_grouping">1000</longProp>
          <boolProp name="graph_aggregated">false</boolProp>
          <stringProp name="include_sample_labels"></stringProp>
          <stringProp name="exclude_sample_labels"></stringProp>
          <stringProp name="start_offset"></stringProp>
          <stringProp name="end_offset"></stringProp>
          <boolProp name="include_checkbox_state">false</boolProp>
          <boolProp name="exclude_checkbox_state">false</boolProp>
          <collectionProp name="metricConnections">
            <collectionProp name="1917648411">
              <stringProp name="-466184153">'+target_host+'</stringProp>
              <stringProp name="1571004">3450</stringProp>
              <stringProp name="73589">JMX</stringProp>
              <stringProp name="-365175363">url='+target_host+'\:9426:label=JMX_gc_time:gc-time</stringProp>
            </collectionProp>
          </collectionProp>
        </kg.apc.jmeter.perfmon.PerfMonCollector>'
        else
          return nil
        end
      rescue Exception=>e
        p "Util.generate_perfmon_monitor_xml_str exception:#{e.to_s}"
        LOGGER.error "Util.generate_perfmon_monitor_xml_str exception:#{e.to_s}"
        return nil
      end
    end

    # get metric type from label
    def Util.which_metric_type(label)
      if label.downcase.index('cpu')!=nil
        return 'cpu'
      elsif label.downcase.index('disk')!=nil
        return 'disk'
      elsif label.downcase.index('memory')!=nil
        return 'memory'
      elsif label.downcase.index('network')!=nil
        return 'network'
      elsif label.downcase.index('tcp')!=nil
        return 'tcp'
      elsif label.downcase.index('jmx')!=nil
        return 'jmx'
      else
        return 'unknow'
      end
    end

    # generate_extract_status_code_xml_str
    def Util.generate_extract_status_code_xml_str
      '<RegexExtractor guiclass="RegexExtractorGui" testclass="RegexExtractor" testname="ResponseCode" enabled="true">
            <stringProp name="RegexExtractor.useHeaders">code</stringProp>
            <stringProp name="RegexExtractor.refname">ResponseCode</stringProp>
            <stringProp name="RegexExtractor.regex">(?s)(^.*)</stringProp>
            <stringProp name="RegexExtractor.template">$1$</stringProp>
            <stringProp name="RegexExtractor.default"></stringProp>
            <stringProp name="RegexExtractor.match_number"></stringProp>
          </RegexExtractor><hashTree/>'
    end
  end
end