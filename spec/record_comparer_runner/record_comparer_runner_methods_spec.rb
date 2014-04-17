$LOAD_PATH.unshift File.dirname(__FILE__)
require 'spec_helper'

describe RecordComparerRunner do
  before(:all) do
    @runner = RecordComparerRunner.new(:some_type)
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