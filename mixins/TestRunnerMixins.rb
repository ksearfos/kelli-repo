require 'TestRunnerMixins_FileHandling'
require 'TestRunnerMixins_Logging'
require 'TestRunnerMixins_ComparerSetup'

module TestRunnerMixIns
  
  def set_common_instance_variables( type, debugging )
    @debugging = debugging   # just a flag -- affects whether files are deleted and detail of output
    @message_type = type   
  end

  def finish_setup  
    # finish input file setup
    @input_directory = @debugging ? "C:/Users/Owner/Documents/script_input" : "d:/FTP"
    logger_directory = "#{@input_directory}/logs"
    @result_file_prefix = logger_directory + "/#{timestamp}_" 
    
    # finish logging setup   
    @logger_directory = logger_directory
    @logger_file = name_after_class
    create_logger     
  end

  def name_after_class
    clazz = self.class.name
    clazz.downcase!
    clazz.gsub!( '_', ' ' )
    @result_file_prefix + clazz + ".log"
  end
  
  def minimum_number_of_results
    case @message_type
    when :lab then 1024
    when :enc,:adt then 387
    when :rad then 1024
    else 1
    end
  end
       
  def directory_size( directory )
    Dir.entries( directory ).size
  end
  
  def timestamp
    Time.now.strftime "%H%M_%m-%d-%Y"      # HHMM_MM-DD-YYYY
  end

  def save_results_to_csv( csv_file, recs )
    records_to_spreadsheet( csv_file, recs )
    log "See #{csv_file}"
  end
    
end

