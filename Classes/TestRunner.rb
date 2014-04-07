require 'mixins/TestRunnerMixin_FileHandling'
require 'classes/CustomizedLogger'
require 'lib/utility_methods'

class TestRunner
  include TestRunnerFileHandling

  def initialize(type, debugging)
    @debugging = debugging   # just a flag -- affects whether files are deleted and level of detail of output
    @message_type = type   
    @input_directory = @debugging ? TESTING_INPUT_DIRECTORY : INPUT_DIRECTORY    
    @timestamp = Time.now.strftime("%H%M_%m-%d-%Y")     # HHMM_MM-DD-YYYY
    @logger = CustomizedLogger.new("#{@input_directory}/logs", self.class.log_file_name) 
    redirect_stdout(@logger.file) unless @debugging
  end
  
  # derives the name of the log file based off of the name of the class
  # returns a string, the class name lowercased and with underscores between words
  def self.log_file_name
    clazz = name
    clazz.gsub!(/([A-Z])/, '_\1' )    # you must use single quotes when using a back-reference to a regex match
    clazz.downcase!
    "#{@timestamp}_#{clazz}.log"
  end

  def shutdown
    @logger.close
  end       
end

