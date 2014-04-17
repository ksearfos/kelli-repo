$LOAD_PATH.unshift File.dirname(__FILE__)
require 'spec_helper'

describe RecordExtractor do
  before(:each) do
    @files = %w(file1 file2 file3)
    @set1 = [1]
    @set2 = [2]
    RecordExtractor.any_instance.stub(:get_current_set).and_return(@set1, @set2, []) 
    RecordExtractor.any_instance.stub(:set_up_new_file_handler)
    RecordExtractor.any_instance.stub(:no_more_records_in_file) { true }
    RecordExtractor.any_instance.stub(:queue_next)
    @extractor = RecordExtractor.new(@files)   
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
    before(:each) do
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
  
  describe "#get_records" do
    it "returns the next group of records" do
      expect(@extractor.get_records).to eq(@set1)  
    end
    
    context "when all records in the file have been returned" do
      it "reads records from the next file" do
        files = @files.clone

        until files.empty?
          expect(@extractor.files.first).to eq(files.shift)
          @extractor.get_records
        end  
      end
    
      context "when all the files have been read" do
        it "returns an empty record list" do
          until @extractor.files.empty?
            @extractor.get_records
          end
          
          expect(@extractor.get_records).to eq([])
        end
      end # context: all files read
    end # context: all records returned
  end # describe: #get_records
end