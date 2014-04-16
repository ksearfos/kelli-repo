# passed testing 4/15
$LOAD_PATH.unshift File.expand_path('../..',__FILE__)   # mixins directory
require 'spec_helper'

describe ProportionEvaluable::Proportion do
  before(:all) do
    @ratio = 0.25
    @identifying_criteria = proc { |number| number < 3 }
    @proportion = ProportionEvaluable::Proportion.new(@ratio, @identifying_criteria)
    @full_set = [1, 2, 3, 4, 5, 6, 7, 8]
    @qualifying_set = [1, 2]
  end
    
  it "represents a desired ratio (elements meeting criteria : elements not meeting criteria)",
  :detail => "a decimal representing a percent" do
    ratio = @proportion.instance_variable_get(:@ratio)
    expect(ratio).to be < 1
    expect(ratio).to be > 0
  end
    
  it "represents the criteria", :detail => "an executable piece of code" do
    expect(@proportion.instance_variable_get(:@identifier)).to be_a Proc
  end
    
  describe "#exemplified_by?" do
    context "when given a collection with the correct ratio" do
      it "is true" do
        expect(@proportion).to be_exemplified_by(@full_set)
      end
    end
      
    context "when given a collection with an incorrect ratio" do
      it "is false" do
        expect(@proportion).not_to be_exemplified_by(@qualifying_set)
      end
    end
  end
    
  describe "#number_of_elements_in_set" do
    it "finds the number of qualifying elements in a collection" do
      expect(@proportion.number_of_elements_in_set(@full_set)).to eq(2)
    end
  end
    
  describe "#elements_in_set" do   
    it "finds the qualifying elements in a collection" do
      expect(@proportion.elements_in_set(@full_set)).to eq(@qualifying_set)
    end
  end
    
  describe "#apply" do
    it "applies the ratio to a number" do
      expect(@proportion.apply(100)).to eq(25)
    end
  end
    
  def inverse_ratio
    it "calculates the inverse of the Proportion's ratio", :detail => "1 minus ratio; also
    the target ratio of non-qualifying elements" do
      expect(@proportion.inverse_ratio).to eq(0.75)
    end  
  end
end