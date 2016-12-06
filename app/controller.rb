# controller.rb
module RESTJMeter
  class Controller
    def Controller.daily_results_dir(time_now)
      p "[start] Controller start..."
      begin
        daily_results_dir="#{CONFIG["Aggregate_Results_Dir"]}/#{time_now.year}-#{time_now.month}-#{time_now.day}"
        if !Dir.exists?(daily_results_dir)
          Dir.mkdir(daily_results_dir)
          p "[step 0] #{daily_results_dir} created..."
        else
          p "[step 0] #{daily_results_dir} already existed..."
        end
        daily_results_dir
      rescue Exception=>e
        p "[step 0] Exception(#{e.to_s}) happened when creating #{daily_results_dir}. exit!"
        exit
      end
    end

    def Controller.test_results_dir(time_now,test_id)
      # p "[start] JMeter Helper start..."
      begin
        test_results_dir="#{CONFIG["Aggregate_Results_Dir"]}/#{time_now.year}-#{time_now.month}-#{time_now.day}/#{test_id}"
        if !Dir.exists?(test_results_dir)
          Dir.mkdir(test_results_dir)
          p "[step 0] #{test_results_dir} created..."
        else
          p "[step 0] #{test_results_dir} already existed..."
        end
        test_results_dir
      rescue Exception=>e
        p "[step 0] Exception(#{e.to_s}) happened when creating #{test_results_dir} exit!"
        exit
      end
    end

    # jmx_file_name: ****.jmx
    # test_results_dir must end with '\' like 'C:\perf-team-shared-files\yanli\projects\restjmeter\data\perfmon_jmx\'
    def Controller.append_perfmon_to_jmx(jmx_file_name,test_id,target_host,test_results_dir)
      p "[step 0.1] append_perfmon_to_jmx..."
      begin
        doc=Nokogiri::XML(File.open("#{jmx_file_name}"))
        perfmon_str=Util.generate_perfmon_monitor_xml_str(test_id,target_host,test_results_dir)
        if perfmon_str!=nil
          doc.xpath("//hashTree//hashTree//hashTree").first<<perfmon_str
          File.open("#{jmx_file_name}", 'w') do |file|
            file.print doc.to_xml
          end
        end
      rescue Exception=>e
        p "[step 0] Exception(#{e.to_s}) happened when append_perfmon_to_jmx!"
        exit
      end
    end
    # ----------------------------------------------------------------
    # 1. run jmeter testing(CMD), generate aggregate report .csv file
    # ----------------------------------------------------------------
    def Controller.run_jmeter(jmeter_jmx_file,jmeter_jtl_temp_file,jmeter_csv_file)
      # jmeter_jmx_file="/Users/yanli6/Personal/DevDir/Code/jmeter/JMeterTest01.jmx"#ARGV[0] # jmx file path
      # jmeter_jtl_temp_file="#{daily_results_dir}/temp_jtl_#{time_now.to_i}.jtl"
      # jmeter_csv_file="#{daily_results_dir}/#{time_now.year}_#{time_now.month}_#{time_now.day}_#{time_now.hour}_#{time_now.min}_#{time_now.sec}.csv"

      begin
        p "[step 1] Start JMeter Testing..."
        case CONFIG["JMeter_Reside_OS"].downcase
          when "win"
            system("#{CONFIG["JMeter_Home"]}/bin/jmeter.bat -n -t #{jmeter_jmx_file} -l #{jmeter_jtl_temp_file}")
          when "osx"
            system("sh #{CONFIG["JMeter_Home"]}/bin/jmeter.sh -n -t #{jmeter_jmx_file} -l #{jmeter_jtl_temp_file}")
          else
            # no
        end
      rescue Exception
        p "[step 1] Exception(#{e.to_s}) happened during JMeter Testing. exit!"
        exit
      end

      p "[step 1] JMeter Testing Finished..."
      begin
        p "[step 1] Generating CSV report(#{jmeter_csv_file})..."
        system("java -jar #{CONFIG["JMeter_Home"]}/lib/ext/CMDRunner.jar --tool Reporter --generate-csv #{jmeter_csv_file} --input-jtl #{jmeter_jtl_temp_file} --plugin-type AggregateReport")
      rescue Exception=>e
        p "[step 1] Exception(#{e.to_s}) happened during Generating CSV report. exit!"
        exit
      end
      p "[step 1] CSV report generated..."
    end

    # --------------------------------
    # 2. save csv content to database
    # --------------------------------
    # line format: Get_JD_Homepage,40,3458,1060,11139,0,22186,5.00%,1.4,234.3,5063.19
    def Controller.convert_line_to_db_format(test_id,time_stamp,line)
      str_r=line.reverse
      index=str_r.index(",")
      line_data=line[0,line.size-index-1]
      line_data=line_data.tr('%','')
      index_0=line_data.index(',')
      return "('#{test_id}',#{time_stamp},'#{line_data[0,index_0]}',#{line_data[index_0+1,line_data.size-index_0]})"
    end

    def Controller.save_data_to_db(time_now,db,test_id,jmeter_csv_file)
      insert_sql_values_str=""
      begin
        p "[step 2] Reading CSV file..."
        time_stamp=time_now.to_i
        i=0
        # header: sampler_label,aggregate_report_count,average,aggregate_report_median,aggregate_report_90%_line,aggregate_report_min,aggregate_report_max,aggregate_report_error%,aggregate_report_rate,aggregate_report_bandwidth,aggregate_report_stddev
        # line format: Get_JD_Homepage,40,3458,1060,11139,0,22186,5.00%,1.4,234.3,5063.19
        File.open(jmeter_csv_file, "r") do |f|
          f.each_line do |line|
            if i==0
              # ignore the first line header
              i=-1
            else
              if(line.index('TOTAL')==0)
                # ignore the last line
              else
                insert_sql_values_str=insert_sql_values_str+"#{convert_line_to_db_format(test_id,time_stamp,line)},"
              end
            end
          end
        end
      rescue Exception=>e
        p "[step 2] Exception(#{e.to_s}) happened during reading CSV file. exit!"
        exit
      end

      insert_sql_values_str=insert_sql_values_str[0,insert_sql_values_str.size-1]
      begin
        # DB = Sequel.connect(PostgreSQL_Connection)
        p "[step 2] Connecting to DB successfully..."
        sql="insert into jmeter_aggregate_report(testid,time_stamp,label,samples,average,median,perc90_line,min,max,error_rate,throughput,kb_per_sec) values #{insert_sql_values_str}"
        p "[step 2] SQL: #{sql}"
        if sql.include?("∞")
          sql.gsub!("∞","0")
        end
        db.fetch(sql).insert
        p "[step 2] Data inserted into DB..."
      rescue Exception=>e
        p "[step 2] Exception(#{e.to_s}) happened during inserting data into DB. exit!"
        exit
      end
    end

    # ---------------------
    # 3. delete temp files
    # ---------------------
    def Controller.delete_temp_jtl(jmeter_jtl_temp_file)
      begin
        p "[step 3] Deleting #{jmeter_jtl_temp_file} ..."
        File.delete(jmeter_jtl_temp_file)
      rescue Exception=>e
        p "[step 3] Exception(#{e.to_s}) happened during deleting temp jtl file. exit!"
        exit
      end
      p "[step 3] #{jmeter_jtl_temp_file} deleted..."
      p "[end] JMeter Helper end."
    end
  end
end