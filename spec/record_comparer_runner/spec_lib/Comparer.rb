require 'RecordExtractor'

class Comparer
  attr_reader :records
  
  def initialize(files)
    @extractor = RecordExtractor.new(files)
    @records = get_records
  end
  
  def analyze
    until @records.empty?
      search_records
      @records = get_records
    end
    
    []   #return chosen or some such
  end
  
  private
  
  def search_records
    @records.identify_best_subset
  end
  
  def get_records
    @extractor.get_records
  end

end