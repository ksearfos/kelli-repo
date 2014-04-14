# last tested 4/7
require 'mixins/FileHandlingMixin'
require 'classes/CustomizedLogger'

class TestRunner
  
  def initialize(type)
    @message_type = type       
    @logger = CustomizedLogger.new("#{@hl7_directory}/#{FileHandling::LOGGING_DIRNAME}", self.class.log_file_name) 
    redirect_stdout(@logger.file)
  end
  
  # derives the name of the log file based off of the name of the class
  # returns a string, the class name lowercased and with underscores between words
  def self.log_file_name
    clazz = name
    clazz.gsub!(/([A-Z])/, '_\1' )    # you must use single quotes when using a back-reference to a regex match
    clazz.downcase!
    "#{FileHandling::TIMESTAMP}_#{clazz}.log"
  end

  def shutdown
    @logger.close
  end 
  
  private
  
  # wrappers for FileIO methods, to allow logging       
  def get_files(input_directory, input_file_pattern)
    @logger.parent "Checking #{input_directory} for files..."
    do_and_check_validity("Found #{result.size} file(s)", "No files found") do
      FileIO.get_files(input_directory, input_file_pattern)
    end
  end

  # special case of get_files because we call this a lot
  def get_hl7_files
    raise "Please specify default input directory" if @hl7_directory.nil?
    raise "Please specify hl7 file pattern" if @hl7_file_pattern.nil?
    get_files(@hl7_directory, @hl7_file_pattern)
  end
    
  def remove_file(file)
    @logger.parent "Deleting file: #{file}"
    do_and_check_validity("File successfully deleted", "Failed to delete file") do
      FileIO.delete(file)
    end 
  end
    
  def create_file_handler(file)
    @logger.parent "Extracting records from #{file}..."
    do_and_check_validity("Found #{result.size} records", "File is empty") do
      FileIO.create_file_handler(file)
    end
  end

  def do_and_check_validity(success_message, failure_message, &block)
    result = yield
    result ? @logger.child(success_message) : @logger.warn(failure_message)  
    result
  end
            
end

