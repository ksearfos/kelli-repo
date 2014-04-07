# last tested 4/7
require 'lib/hl7/HL7'
require 'lib/utility_methods'

module TestRunnerFileHandling
    
    MAX_RECORDS = 10000
    PRE_FILE_REGEX = /pre_\d+\.dat/
    POST_FILE_REGEX = /post_\d+\.dat/ 
    INPUT_DIRECTORY = "d:/FTP"
    TESTING_INPUT_DIRECTORY = "C:/Users/Owner/Documents/script_input"
    TEMP_FILENAME = "results_temporary"
    RESULTS_FILENAME = "results"
    
    # ----- file input ----- #   
    # returns a list of the full filepaths of files in the given directory and with names matching input_file_pattern
    # takes a String and an optional regex 
    # calls lib/utility_methods.rb#get_paths_of_files_in_directory, and merely adds logging around it         
    def get_files(input_directory, input_file_pattern = /.*/)
      @logger.parent "Checking #{input_directory} for files..."
      file_list = get_paths_of_files_in_directory(input_directory, input_file_pattern)
      file_list.empty? ? @logger.warn("No files found") : @logger.child("#{file_list.size} file(s) found") 
      file_list
    end

    # special case of get_files because we call this a lot
    def get_hl7_files
      raise "Please specify default input directory" if @input_directory.nil?
      raise "Please specify hl7 file pattern" if @input_file_pattern.nil?
      get_files(@input_directory, @input_file_pattern)
    end
    
    # ----- file removal ----- #
    # deletes the given file and logs its deletion
    # takes a String, the full path of the file
    # calls File.delete, and merely adds logging around it  
    def remove_file(file)
      @logger.parent "Deleting file: #{file}"
      File.delete(file)
      File.exists?(file) ? @logger.warn("Failed to delete file") : @logger.child("File successfully deleted") 
    end
    
    # ----- FileHandler initialization ----- #
    # makes a new HL7::FileHandler object linked to the given file
    # takes a String, the full path of the file, and returns either nil or a FileHandler object
    def create_file_handler(file)
      @logger.parent "Extracting records from #{file}..."
      File.zero?(file) ? make_nil_file_handler(file) : make_valid_file_handler(file)
    end
  
    # called by create_file_handler
    # returns nil
    # calles lib/utility_methods.rb#remove_file, and merely adds logging around it
    def make_nil_file_handler(file)
      @logger.warn "File is empty"
      remove_file(file)
      nil
    end

    # called by create_file_handler
    # returns new FileHandler object
    # calls HL7::FileHandler.new, and merely adds logging around it
    def make_valid_file_handler(file)
      handler = HL7::FileHandler.new(file, MAX_RECORDS)
      @logger.child "#{handler.records.size} records found"
      handler
    end

  def file_date_string(filename)
    file_date = filename.match(/_(\d+)\./)    # date/time from the file
    file_date ? file_date[1] : @timestamp
  end    
end

