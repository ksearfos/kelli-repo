require 'lib/hl7/HL7'
require 'ListOfRecordMaps'

class RecordExtractor
  include HL7  
  
  attr_reader :files
  MAX_RECORDS = 10000
  
  def initialize(files)
    @files = files
    read_in_next_file
  end
  
  def get_records
    return_current_set
  end
  
  private
  
  # ----- File iteration ----- #
  def read_in_next_file
    @file_handler = nil   # reset
    set_up_new_file_handler(@files.shift)
  end
  
  def set_up_new_file_handler(file)
    @file_handler = FileHandler.new(file, MAX_RECORDS) unless file
  end
  
  # ----- Record iteration ----- #
  def get_current_set
    @file_handler ? @file_handler.records : []
  end
  
  def return_current_set
    @records = get_current_set
    prepare_next_set    
    @records
  end
  
  def prepare_next_set
    queue_next
    read_in_next_file if no_more_records_in_file
  end
  
  def queue_next
    @file_handler.next      # get new records
  end

  def no_more_records_in_file
    @file_handler.records.empty?
  end
end