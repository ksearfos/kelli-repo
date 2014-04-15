$:.unshift(File.dirname(__FILE__))
require 'spec_helper'

describe ListOfMaps do
  before(:each) do
    criteria = double("criteria", :criteria => $criteria)
    duplicate_criteria = double("duplicate_criteria", :criteria => $duplicate_criteria)
    redundant_criteria = double("redundant_criteria", :criteria => $redundant_criteria)
    additional_criteria = double("additional_criteria", :criteria => $additional_criteria)
    @list = ListOfMaps.new(criteria, duplicate_criteria, redundant_criteria, additional_criteria)
  end
  
  it "has a list of all maps" do
    expect(@list.maps).to be_a Array
  end
  
  it "has a list of all matched criteria" do
    expect(@list.criteria).to eq($all_criteria)
  end
  
  describe "#find_redundancies" do
    it "lists all redundant maps" do
      redundancies = @list.find_redundancies
      expect(redundancies.map(&:criteria)).to eq([$redundant_criteria, $duplicate_criteria])
    end
  end
  
  describe "#each" do
    it "does not throw an error" do
      expect { @list.each { |item| } }.not_to raise_error
    end
  end
  
  describe "#select" do
    it "does not throw an error" do
      dummy_method = proc { true }
      expect { @list.select { |item| } }.not_to raise_error
    end
  end
  
  describe "#take" do
    it "does not throw an error" do
      expect { @list.take(1) }.not_to raise_error
    end      
  end
  
  describe "#size" do
    it "does not throw an error" do
      expect { @list.size }.not_to raise_error
    end
  end
end