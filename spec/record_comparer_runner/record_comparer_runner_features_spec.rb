$LOAD_PATH.unshift File.dirname(__FILE__)
require 'spec_helper'
require 'shared_examples'

describe RecordComparerRunner do
  before(:all) do
    @type = :lab
    @runner = RecordComparerRunner.new(@type)
  end
  
  it_behaves_like TestRunner do
    let(:record_type) { @type }
    let(:runner) { @runner }
  end
  
  it "has a list of files to compare" do
    expect(@runner.files).to be_a Array
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
      @runner.stub(:compare_records) { [1, 2, 3, 4, 5] }
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