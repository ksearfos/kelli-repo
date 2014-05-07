require 'comparer/spec_helper'
require 'working_folder/comparison_runner'

describe ComparisonRunner do
  before(:all) do
    @infile = 'file1.txt'
    @outfile = 'file2.txt'
    @runner = ComparisonRunner.new(@infile, @outfile)
  end
  
  it "has an input file" do
    expect(@runner.infile).to eq(@infile)
  end
  
  it "has an output file" do
    expect(@runner.outfile).to eq(@outfile)
  end
  
  it "runs the comparison" do
    expect(@runner).to respond_to(:compare)
  end
  
  describe "#compare" do
    it "returns the results of the comparison" do
      @runner.stub(:old_compare)
      expect(@runner.compare).not_to be_nil
    end
  end
  
  it "keeps track of how many records it compared" do
    expect(@runner.record_count).to be_a Integer
  end
end