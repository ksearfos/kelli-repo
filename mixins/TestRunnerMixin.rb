require 'mixins/TestRunnerMixin_FileHandling'
require 'classes/CustomizedLogger'
require 'lib/utility_methods'

module TestRunnerMixIn
  include FileHandling
  
  TIMESTAMP = Time.now.strftime("%H%M_%m-%d-%Y")     # HHMM_MM-DD-YYYY
  
  # ----- initialization methods ----- #
  def set_common_instance_variables(type, debugging)
    @debugging = debugging   # just a flag -- affects whether files are deleted and detail of output
    @message_type = type 
    @input_directory = @debugging ? "C:/Users/Owner/Documents/script_input" : "d:/FTP"    
    @logger = CustomizedLogger.new("#{@input_directory}/logs", log_file_name) 
    redirect_stdout(@logger.file) unless @debugging
  end
  
  # ----- utility methods ----- #
  # derives the name of the log file based off of the name of the class
  # returns a string, the class name lowercased and with underscores between words
  def log_file_name
    clazz = self.class.name
    clazz.gsub!(/([A-Z])/, '_\1' )    # you must use single quotes when using a back-reference to a regex match
    clazz.downcase!
    "#{TIMESTAMP}_#{clazz}.log"
  end
        
end

