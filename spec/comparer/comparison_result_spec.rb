require 'comparer/spec_helper'
require 'working_folder/comparison_result'

describe ComparisonResult do
  before(:all) do
    @result = ComparisonResult.new(100, 50, [22], [43])
  end
  
  it "has a total number of records" do
    expect(@result.set_size).to eq(100)
  end
  
  it "has a total number of criteria" do
    expect(@result.criteria_size).to eq(50)
  end
  
  it "has the number of matched criteria" do
    expect(@result.matched_criteria_size).to eq(43)
  end
  
  it "has the size of the record subset" do
    expect(@result.subset_size).to eq(22)
  end
  
  context "when there is more than one file" do
    before(:all) do
      @multi_result = ComparisonResult.new(100, 50, [56, 78], [44, 42])
    end
    
    it "has a matched_criteria_size and subset_size for each file" do
      expect(@multi_result.matched_criteria_sizes.size).to eq(2)
      expect(@multi_result.subset_sizes.size).to eq(2)
    end
    
    describe "#subset_size" do
      it "returns the first value in subset_sizes" do
        expect(@multi_result.subset_size).to eq(56)
      end
    end
    
    describe "#matched_criteria_size" do
      it "returns the first value in matched_criteria_sizes" do
        expect(@multi_result.matched_criteria_size).to eq(44)
      end
    end
    
    describe "subset_sizes" do
      it "returns all subset sizes" do
        expect(@multi_result.subset_sizes).to eq([56, 78])
      end
    end
    
    describe "#matched_criteria_sizes" do
      it "returns all matched criteria sizes" do
        expect(@multi_result.matched_criteria_sizes).to eq([44, 42])
      end
    end
  end
end