require 'lib/hl7/HL7'

module TestRunnerMixIns
  
  module FileHandling   # adds @input_directory, @input_file_pattern
    
    @max_records = 10000
      
    attr_accessor :input_directory, :input_file_pattern
            
    def get_files( input_directory, input_file_pattern )
      log "Checking #{@input_directory} for files..."
      file_list = get_list_of_files( input_directory, input_file_pattern )
      message = ( file_list.empty? ? "No new files found." : "Found #{file_list.size} new file(s)" )
      log message, :child_message   
      file_list
    end
  
    create_file_handler( file, size_limit=0 )
      log "Reading #{file}..."
      if File.zero?( file )   # empty file
        log("File is empty",:error)
        @file_handler = nil
      else
        @file_handler = HL7::FileHandler.new( file, size_limit )
      end
    end

    # files expected to be in the same directory
    def remove_file( file )
      directory = File.expand_path( "..", file )
      log "Deleting file: #{file}"
      files.each{ |f| File.delete( f ) }
      verify_remove( file ) 
    end

    private

    # called by get_files
    def get_list_of_files( directory, filename_pattern )
      file_list = [] 
      Dir.entries( directory ).each{ |filename|
        full_filepath = "#{directory}/#{filename}"
        file_list << full_filepath if File.file?(full_filepath) && filename.match( filename_pattern )
      }
    end

    # called by remove_files
    def verify_remove( file )    
      gone = !File.exists?( file )
      if gone then log "File successfully deleted", :child_message
      else log "Failed to delete file", :error
      end
    end
  
  end
  
end

