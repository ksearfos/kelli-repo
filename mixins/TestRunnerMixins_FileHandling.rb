require 'lib/hl7/HL7'

module TestRunnerMixIns
  
  module FileHandling
    
    MAX_RECORDS = 10000

    # ----- file input ----- #            
    def get_files(input_directory, input_file_pattern)
      @logger.section "Checking #{@input_directory} for files..."
      file_list = get_list_of_files(input_directory, input_file_pattern)
      file_list.empty? ? @logger.warn("No files found") : @logger.add("#{file_list.size} file(s) found") 
      file_list
    end

    # called by get_files
    def get_list_of_files(directory, filename_pattern)
      file_list = [] 
      Dir.entries(directory).each do |filename|
        full_filepath = "#{directory}/#{filename}"
        file_list << full_filepath if File.file?(full_filepath) && filename.match(filename_pattern)
      end
    end

    # ----- file removal ----- #
    def remove_file( file )
      directory = File.expand_path("..", file)
      @logger.section "Deleting file: #{file}"
      File.delete(file)
      verify_remove(file) 
    end

    # called by remove_file
    def verify_remove(file)    
      gone = !File.exists?(file)
      gone ? @logger.add("File successfully deleted") : @logger.warn("Failed to delete file")
    end
    
    # ----- FileHandler initialization ----- #
    def create_file_handler(file)
      @logger.section "Extracting records from #{input_file}..."
      File.zero?(file) ? make_nil_file_handler(file) : make_valid_file_handler(file)
    end
  
    # called by create_file_handler
    def make_nil_file_handler(file)
      @logger.warn "File is empty"
      remove_file(file)
      nil
    end

    # called by create_file_handler
    def make_valid_file_handler(file)
      handler = HL7::FileHandler.new(file, MAX_RECORDS)
      @logger.add "#{handler.records.size} records found"
      handler
    end
    
  end
  
end

