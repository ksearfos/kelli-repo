$LOAD_PATH.unshift File.expand_path("#{__FILE__}/../../../../")
require 'lib/HL7CSV'
require 'classes/CustomizedLogger'
require 'lib/utility_methods'
require 'mixins/FileIO'

class TestRunner
  attr_reader :logger, :record_type
  
  TIMESTAMP = Time.now.strftime("%H%M_%m-%d-%Y")     # HHMM_MM-DD-YYYY
  DIRECTORY = File.dirname(__FILE__)
  
  def initialize(type)
    log_dirname = "#{DIRECTORY}/logs"
    @record_type = type
    @logger = CustomizedLogger.new(log_dirname, log_filename)
  end
  
 # wrapper for FileIO method, to allow logging       
  def get_files(pattern)
    @logger.parent "Checking #{DIRECTORY} for files named '#{pattern}'..."
    FileIO.get_files(DIRECTORY, pattern)
  end

  def shutdown
    @logger.close
  end
  
  private
  
  def log_filename
    name = [TIMESTAMP, classname, @record_type].join('_')
    "#{name}.log"
  end
  
  # returns the class name lowercased and with underscores between words
  def classname
    clazz = self.class.name
    clazz.gsub!(/([A-Z])/, '_\1' )    # you must use single quotes when using a back-reference to a regex match
    clazz.downcase!
  end
  
    # def remove_file(file)
    # @logger.parent "Deleting file: #{file}"
    # do_and_check_validity("File successfully deleted", "Failed to delete file") do
      # FileIO.delete(file)
    # end 
  # end
#     
  # def create_file_handler(file)
    # @logger.parent "Extracting records from #{file}..."
    # do_and_check_validity("Found #{result.size} records", "File is empty") do
      # FileIO.create_file_handler(file)
    # end
  # end
end