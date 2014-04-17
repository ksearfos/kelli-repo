require 'RecordExtractor'

class Comparer
  attr_reader :records
  
  def initialize(files)
    extractor = RecordExtractor.new(@files)
    @records = extractor.records
  end
  
  def analyze
    search_records
  end
  
  private
  
  def search_records
    @records.identify_best_subset
  end
end