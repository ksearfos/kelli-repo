$LOAD_PATH.unshift File.dirname(__FILE__)
require 'TestRunner'
require 'Comparer'

class RecordComparerRunner < TestRunner
  attr_reader :results, :csv_file, :files
  
  def initialize(type)
    super(type)
    @results = nil
    @csv_file = "#{@logger.directory}/results.csv"
    @files = get_files("#{@record_type}_pre")
  end
  
  def run
    @results = compare_records
  end
  
  def save_results
    HL7CSV.make_spreadsheet_from_array(@csv_file, [%w(MRN NAME DOB VISIT# DATE)])
  end
  
  private
  
  def compare_records
    comparer = Comparer.new(@files)
    comparer.analyze
  end
end