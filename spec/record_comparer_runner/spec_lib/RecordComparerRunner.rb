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
    @extractor.do_for_all_records do |records|
      @record_list = new_list(records)
      @results = compare_records
      save_results
    end
  end
  
  def save_results
    HL7CSV.make_spreadsheet_from_array(@csv_file, [%w(MRN NAME DOB VISIT# DATE)])
  end
  
  private
  
  def compare_records
    comparer = Comparer.new(@record_list)
    comparer.analyze
  end
  
  def new_list(records)
    record_maps = [] #records.map { |record| RecordCriteriaMap.new(record) }
    ListOfRecordMaps.new(record_maps)
  end
end