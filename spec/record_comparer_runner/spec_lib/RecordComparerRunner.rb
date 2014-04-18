$LOAD_PATH.unshift File.dirname(__FILE__)
require 'TestRunner'
require 'Comparer'
require 'RecordExtractor'

class RecordComparerRunner < TestRunner
  attr_reader :results, :csv_file, :extractor
  
  def initialize(type)
    super(type)
    @results = nil
    @csv_file = "#{@logger.directory}/results.csv"
    files = get_files("#{@record_type}_pre")
    @extractor = RecordExtractor.new(files)
  end
  
  def run
    compare_all_files
  end
  
  def save_results
    HL7CSV.make_spreadsheet_from_array(@csv_file, [@results])
  end
  
  private
  
  def compare_all_files
    @extractor.do_for_all_records do |records|
      @record_list = new_list(records)
      @results = compare_records
      save_results
    end
  end
  
  def compare_records
    comparer = Comparer.new(@record_list)
    comparer.analyze
  end
  
  def new_list(records)
    ListOfRecordMaps.new(records_as_maps(records))
  end
  
  def records_as_maps(records)
    records.map { |record| RecordCriteriaMap.new(record) }
  end
end