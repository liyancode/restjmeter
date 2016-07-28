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
      end
    end

    # status: 'sleep','running','fail','success'
    def Util.update_log_jmx_str_status(db,test_id,new_status)
      begin
        db.fetch("update jmeter_jmx_log set status='#{new_status}' where testid='#{test_id}'").update
      rescue Exception=>e
        p e
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
      end
    end
  end
end