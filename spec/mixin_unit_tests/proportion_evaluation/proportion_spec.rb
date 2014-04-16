# passed testing 4/15
$LOAD_PATH.unshift File.expand_path('../..',__FILE__)   # mixins directory
require 'spec_helper'

describe ProportionEvaluation::Proportion do
  before(:all) do
    @ratio = 0.25
    @inverse = 1 - @ratio
    @identifying_criteria = proc { |number| number < 3 }
    @proportion = ProportionEvaluation::Proportion.new(@ratio, @identifying_criteria)
    @full_set = [1, 2, 3, 4, 5, 6, 7, 8]
    @qualifying_set = [1, 2]
  end
    
  it "has a ratio (elements meeting criteria : elements not meeting criteria)",
  :detail => "a decimal representing a percent" do
    ratio = @proportion.instance_variable_get(:@ratio)
    expect(ratio).to be < 1
    expect(ratio).to be > 0
  end
    
  it "has criteria to identify specific elements", :detail => "an executable piece of code" do
    expect(@proportion.instance_variable_get(:@identifier)).to be_a Proc
  end

  describe "#inverse" do
    it "returns the inverse of the ratio", :detail => "the percent of elements that shouldn't meet the criteria" do
      expect(@proportion.inverse).to eq(@inverse)
    end
  end
  
  describe "#identify_elements" do
    it "returns the subset of elements that meet the criteria" do
      expect(@proportion.identify_elements(@full_set)).to eq(@qualifying_set)
    end
  end
  
end