# last tested 4/7
require 'lib/hl7/HL7'
require 'lib/utility_methods'

module FileIO
    
  FILEHANDLER_MAX_RECORDS = 10000
  TIMESTAMP = Time.now.strftime("%H%M_%m-%d-%Y")     # HHMM_MM-DD-YYYY
  PRE_FILE_REGEX = /pre_\d+\.dat/
  POST_FILE_REGEX = /post_\d+\.dat/ 
  HL7_DIRECTORY = "d:/FTP"
  TESTING_HL7_DIRECTORY = "C:/Users/Owner/Documents/script_input"
  LOGGING_DIRNAME = "logs"
  TEMP_FILENAME = "results_temporary.tmp"

  def self.file_date_string(filename)
    file_date = filename.match(/_(\d+)\./)    # date/time from the file
    file_date ? file_date[1] : @timestamp
  end    
  
  # ----- file input ----- #   
  # returns a list of the full filepaths of files in the given directory and with names matching input_file_pattern        
  def self.get_files(input_directory, input_file_pattern)
    get_paths_of_files_in_directory(input_directory, input_file_pattern)
  end
    
  # ----- file removal ----- #
  # deletes the given file and logs its deletion
  def self.remove_file(file)
    File.delete(file)
    !File.exists?(file)    # return success or failure
  end
    
  # ----- FileHandler initialization ----- #
  # makes a new HL7::FileHandler object linked to the given file
  def self.create_file_handler(file)
    File.zero?(file) ? make_nil_file_handler(file) : make_valid_file_handler(file)
  end
  
  # called by create_file_handler
  # returns nil
  def self.make_nil_file_handler(file)
    remove_file(file)
    nil
  end

  # called by create_file_handler
  # returns new FileHandler object
  def self.make_valid_file_handler(file)
    HL7::FileHandler.new(file, FILEHANDLER_MAX_RECORDS)
  end  
 
end

