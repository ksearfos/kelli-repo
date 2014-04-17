$LOAD_PATH.unshift File.dirname(__FILE__)
require 'TestRunner'
require 'Comparer'
require 'RecordExtractor'

class RecordComparerRunner < TestRunner
  attr_reader :results, :csv_file, :files
  
  def initialize(type)
    super(type)
    @results = nil
    @csv_file = "#{@logger.directory}/results.csv"
    files = get_files("#{@record_type}_pre")
    @extractor = RecordExtractor.new(files)
  end
  
  def run
    begin
      records = @extractor.records
      @record_list = ListOfRecordMaps.new(records)
      @results = compare_records
      save_results
    end until @extractor.get_records.empty?
  end
  
  def save_results
    HL7CSV.make_spreadsheet_from_array(@csv_file, [%w(MRN NAME DOB VISIT# DATE)])
  end
  
  private
  
  def compare_records
    comparer = Comparer.new(@record_list)
    comparer.analyze
  end
end