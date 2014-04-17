$LOAD_PATH.unshift File.dirname(__FILE__)
require 'spec_helper'

describe RecordExtractor do
  before(:each) do
    files = %w(file1 file2 file3)
    RecordExtractor.any_instance.stub(:get_current_set).and_return([1, 2, 3], [4, 5, 6]) 
    @extractor = RecordExtractor.new(files)   
  end
  
  it "exists" do
    expect(@extractor).not_to be_nil  
  end
  
  it "has a list of files" do
    expect(@extractor.files).to be_a Array
  end

  it "provides a list of records" do
    expect(@extractor.get_records).to be_a Array
  end
  
  it "has a maximum number of records" do
    expect(RecordExtractor::MAX_RECORDS).to be > 0
  end
    
  it "reads in the records from each file" do
    expect(@extractor.get_records).not_to be_empty unless @extractor.files.empty? 
  end
  
  context "when there are too many records to use at once" do
    before(:all) do
      @first_set = @extractor.get_records
      @second_set = @extractor.get_records
    end
    
    it "parses records in small groups", :details => "to avoid MemoryAllocation errors" do
      expect(@first_set.size).to eq(@second_set.size)
    end
    
    it "controls the sizes of the groups" do
      expect(@first_set.size).to be <= @extractor.class::MAX_RECORDS
    end
    
    it "returns one group at a time" do
      expect(@first_set).not_to eq(@second_set)
    end
  end
end