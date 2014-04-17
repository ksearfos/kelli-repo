$LOAD_PATH.unshift File.dirname(__FILE__)
require 'spec_helper'

describe RecordExtractor do
  before(:each) do
    @files = %w(file1 file2 file3 file4)
    @set1 = [1]
    @set2 = [2]
    @set3 = [3]
    RecordExtractor.any_instance.stub(:get_current_set).and_return(@set1, @set2, @set3, []) 
    RecordExtractor.any_instance.stub(:set_up_new_file_handler)
    RecordExtractor.any_instance.stub(:no_more_records_in_file) { true }
    RecordExtractor.any_instance.stub(:queue_next)
    @extractor = RecordExtractor.new(@files.clone)   
  end
  
  it "exists" do
    expect(@extractor).not_to be_nil  
  end
  
  it "has a list of files" do
    expect(@extractor.files).to be_a Array
  end
  
  it "has a list of records" do
    expect(@extractor.records).to be_a Array
  end
  
  it "has a maximum number of records" do
    expect(RecordExtractor::MAX_RECORDS).to be > 0
  end
    
  it "reads in the records from each file" do
    expect(@extractor.records).not_to be_empty unless @extractor.files.empty? 
  end
  
  context "when there are too many records to use at once" do
    before(:each) do
      @sets = []
      @extractor.do_for_all_records do |records|
        @sets << records
      end
    end
    
    it "parses records in small groups", :details => "to avoid MemoryAllocation errors" do
      expect(@sets[0].size).to eq(@sets[1].size)
    end
    
    it "controls the sizes of the groups" do
      expect(@sets[0].size).to be <= @extractor.class::MAX_RECORDS
    end
    
    it "returns one group at a time" do
      expect(@sets[0]).not_to eq(@sets[1])
    end
  end
  
  describe "#do_for_all_records" do
    it "performs an action on the records" do
      records_list = []     
      @extractor.do_for_all_records { |records| records_list << records}
      expect(records_list).to eq([@set1, @set2, @set3])
    end
    
    it "retrieves the next group of records" do
      last_records = []     
      @extractor.do_for_all_records do |records|
        current_records = records
        expect(current_records).not_to eq(last_records)
      end
    end

    it "leaves @records empty" do
      @extractor.do_for_all_records { }        
      expect(@extractor.records).to eq([])
    end
  end
end