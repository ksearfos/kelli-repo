require 'mixins/TestRunnerMixins'

class AutomatedTestsRunner
  include TestRunnerMixIn
  
  def initialize(type, debugging, minimum_size)
    set_common_instance_variables(type, debugging) 
    @input_file_pattern = @debugging ? /\A#{@message_type}_post_\d/ : /\w+_post_\d+\.dat/   
    @csv_file_suffix = "flagged_#{@message_type}_records.csv"
  end

  def run
    $logger = @logger    # rspec needs to be able to access the same logger
    hl7_files = get_files(@input_directory, @input_file_pattern)  
    hl7_files.each do |filename|   
      set_up_rspec
      test_messages_in_file(filename)
    end 
    @logger.close 
  end

  private
  
  def test_messages_in_file(file)
    file_handler = get_records(file, MAX_RECORDS)          
    do_in_increments(file_handler) do 
      $messages = file_handler.records   # I need a global for rspec, anyway...
      run_rspec                          #+ so I might as well avoid passing messages as an argument
    end
      
    save_flagged_records("#{result_file_prefix}_flagged_records.csv") unless $flagged.empty?
  end
  
  # ----- string formation ----- #
  def result_file_prefix(file)
    "#{@logger.directory}/#{file_date_string(file)}"
  end
    
  def file_date_string(filename)
    file_date = filename.match(/_(\d+)\./)[1]    # date/time from the file
    file_date ||= TIMESTAMP
  end
  
end
