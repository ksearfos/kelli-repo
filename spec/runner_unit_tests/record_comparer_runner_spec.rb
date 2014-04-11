# passed testing 4/7
$LOAD_PATH.unshift File.expand_path("../../..", __FILE__)   # project directory
$LOAD_PATH.unshift File.dirname(__FILE__)
require 'spec_helper'

describe "RecordComparerRunner" do
  
  before(:all) do
    @runner = TestRecordComparerRunner.new
  end
  
  describe "#run" do
    before(:all) do
      @runner.run
    end
    
    it "runs comparisons of records in all input files" do
      File.exists?(@runner.results_file).should be_true
      File.zero?(@runner.results_file).should_not be_true
      HL7::FileHandler.new(@results_file).size.should >= 5
    end
    
    it "outputs selected records into a spreadsheet", :detail => "a csv file" do
      
    end
  end
end