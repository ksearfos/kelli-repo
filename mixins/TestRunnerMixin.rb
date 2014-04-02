require 'TestRunnerMixins_FileHandling'
require 'classes/CustomizedLogger'

module TestRunnerMixIn
  
  TIMESTAMP = Time.now.strftime("%H%M_%m-%d-%Y")     # HHMM_MM-DD-YYYY
  INFO_FILE_PREFIX = "#{@logger.directory}/#{TIMESTAMP}" 
  
  # ----- initialization methods ----- #
  def set_common_instance_variables(type, debugging)
    @debugging = debugging   # just a flag -- affects whether files are deleted and detail of output
    @message_type = type 
    @input_directory = @debugging ? "C:/Users/Owner/Documents/script_input" : "d:/FTP"
    @tempfile = "#{RESULTS_FILE_PREFIX}_temp_results"
    @logger = CustomizedLogger.new("#{@input_directory}/logs", log_file_name) 
    redirect_stdout(@logger.file) unless @debugging
  end
  
  # ----- utility methods ----- #
  def log_file_name
    clazz = self.class.name
    clazz.downcase!
    clazz.gsub!('_', ' ')
    "#{INFO_FILE_PREFIX}_#{clazz}.log"
  end
       
  def directory_size(directory)
    Dir.entries(directory).size
  end

  def do_in_increments(file_handler, &block)
    begin
      yield
      file_handler.next
    end until file_handler.empty?
  end

  def redirect_stdout(file)
    $stdout.reopen(file)  
  end
        
end

