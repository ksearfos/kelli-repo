require 'mixins/FileHandlingMixin'
require 'mixins/RSpecMixin'
require 'classes/TestRunner'

class AutomatedTestsRunner < TestRunner
  include RSpecMixIn
  
  def initialize(type, debugging)
    super(type, debugging) 
    @input_file_pattern = /manifest_rad\d+/
    # @input_file_pattern = /#{@message_type}_#{POST_FILE_REGEX}/  
    @csv_file_suffix = "flagged_#{@message_type}_records.csv"
  end

  def run
    $logger = @logger    # rspec needs to be able to access the same logger
    get_hl7_files.each do |filename|   
      set_up_rspec(filename)
      test_messages_in_file(filename)
    end 
  end

  private
  
  def test_messages_in_file(file)
    # file_handler = get_records(file, MAX_RECORDS)
    file_handler = make_valid_file_handler(file)
    file_handler.max_records = MAX_RECORDS      
    puts file_handler.records.first * ','    
    file_handler.do_in_increments do |records| 
      $messages = records      # I need a global for rspec, anyway...
      run_rspec                #+ so I might as well avoid passing messages as an argument
    end
      
    save_flagged_records("#{result_file_prefix(file)}_flagged_records.csv") unless $flagged.empty?
  end
  
  # ----- string formation ----- #
  def result_file_prefix(file)
    "#{@logger.directory}/#{file_date_string(file)}"
  end
  
end
