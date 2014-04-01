require 'run_rspec'
require 'run_record_comparer'
require 'lib/hl7/HL7'

module TestRunnerMixIns
  
  class << self
    attr_accessor :logger
  end
  
  MAX_RECORDS = 10000

  def set_common_instance_variables( type, debugging )
    @debugging = debugging   # just a flag -- affects whether files are deleted and detail of output
    @message_type = type   
    @hl7_files_directory = @debugging ? "C:/Users/Owner/Documents/script_input" : "d:/FTP"
    @logging_directory = "#{@hl7_files_directory}/logs"  
    @outfile_prefix = @logging_directory + "/#{timestamp}_"
  end

  def run_logger_setup
    raise "Cannot run do_setup without first defining @logfile" if @logfile.nil?
    create_log_directory
    make_logger( @logfile )
    format_logger
  end
        
  def get_files( directory, file_pattern )
    log "Checking #{@hl7_files_directory} for files..."
    file_list = get_list_of_files( directory, file_pattern )
    message = ( file_list.empty? ? "No new files found." : "Found #{file_list.size} new file(s)" )
    log message, :child_message
    
    file_list
  end
  
  def set_up_file_handler( file ) 
    log "Reading from #{file}"
    @file_handler = nil    # reset
    File.zero?(file) ? log("File is empty",:error) : @file_handler = HL7::FileHandler.new( file, @@MAX_RECORDS )
  end

  def remove_files( *files )
    directory = File.expand_path( "..", files.first )
    old_size = directory_size( directory )
    number_of_files = files.size
  
    log "Deleting #{number_of_files} files"
    files.each{ |f| File.delete( f ) }
    verify_remove( directory, old_size, number_of_files ) 
  end
  
  def signoff
   log "Exiting..."
   self.logger.close
  end

  # it may seem redundant, but I do just a tiny bit of formatting in here
  def log( message, type = :info )
    case type
    when :error then self.logger.error message.upcase
    when :child_message then self.logger.info "-- " + message
    when :standalone then self.logger.info message
    else self.logger.info "\n" + message
    end
  end

  private

  # called by set_up_logger
  def create_log_directory
    `mkdir "#{@logging_directory}"` unless File.exists?( @logging_directory )
  end

  # called by set_up_logger
  def make_logger( log_file )
    @logger = Logger.new( log_file )
    reroute_stdout( log_file ) unless @debugging
  end

  # called by set_up_logger
  def reroute_stdout( file )
    $stdout = File.new( file, "w" )    
  end

  # called by set_up_logger
  def format_logger 
    @logger.datetime_format = "%H:%M:%S.%L"   # HH:MM:SS
    @logger.formatter = Proc.new{ |severity,datetime,prog,msg|
      str = "#{datetime} #{severity}: #{msg}\n"
      str
    }
  end

  # called by get_files
  def get_list_of_files( directory, filename_pattern )
    file_list = [] 
    Dir.entries( directory ).each{ |filename|
      full_filepath = "#{directory}/#{filename}"
      file_list << full_filepath if File.file?(full_filepath) && filename.match( filename_pattern )
    }
  end

  # called by remove_files
  def verify_remove( directory, old_size, number_of_files )    
    new_size = directory_size( directory )
    difference = new_size - (old_size - number_of_files)    # number of files we have minus number of files we should have
    message = ( difference == 0 ? "#{number_of_files} files successfully deleted" : "Failed to delete #{difference} file(s)" )
    log message, :child_message
  end
   
  def directory_size( directory )
    Dir.entries( directory ).size
  end
  
  def timestamp
    Time.now.strftime "%H%M_%m-%d-%Y"      # HHMM_MM-DD-YYYY
  end

  def reroute_stdout
    $stdout = File.new( @file, "w" )   
  end  
end

