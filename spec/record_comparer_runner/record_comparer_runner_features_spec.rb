$LOAD_PATH.unshift File.dirname(__FILE__)
require 'spec_helper'
require 'shared_examples'

describe RecordComparerRunner do
  before(:each) do
    RecordExtractor.any_instance.stub(:set_up_new_file_handler)
    RecordExtractor.any_instance.stub(:do_for_all_records).and_yield([1, 2])
    RecordComparerRunner.any_instance.stub(:new_list)
    RecordComparerRunner.any_instance.stub(:compare_records) { %w(MRN NAME DOB VISIT# DATE) }   
    HL7CSV.stub(:make_spreadsheet_from_array) do |file, results|
      File.open(file, 'w+') { |f| f.puts results }
    end  
    
    @type = :lab
    @runner = RecordComparerRunner.new(@type)
  end
  
  it_behaves_like TestRunner do
    let(:record_type) { @type }
    let(:runner) { @runner }
  end
  
  it "has a way to pull records out of files" do
    expect(@runner.extractor).to be_a RecordExtractor
  end
  
  it "runs the comparison" do
    expect(@runner).to respond_to(:run)
  end
  
  it "saves the results of the comparison" do
    expect(@runner).to respond_to(:save_results)
  end

  describe "#run" do
    it "compares records" do
      @runner.should_receive(:compare_records)
      @runner.run
    end
    
    it "updates the results" do
      @runner.run
      expect(@runner.results).not_to be_nil
    end
  end
  
  describe "#save_results" do  
    it "saves the results to a file" do
      @runner.save_results
      expect(File.zero?(@runner.csv_file)).to be_false
    end
  
    it "produces a spreadsheet" do
      expect(@runner.csv_file).to match(/\w+\.csv$/)
    end
  end
end