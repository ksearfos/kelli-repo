$:.unshift(File.dirname(__FILE__))
require 'spec_helper'

describe ListOfMaps do
  before(:all) do
    @list = TestListOfMaps.new()
  end
  
  it "exists" do
    expect(@list).not_to be_nil
  end
  
  it "has a list of all maps" do
    expect(@list).to respond_to :maps
  end
  
  it "has a list of matched criteria" do
    exoect(@list).to respond_to :matched_criteria
  end
  
  describe "#find_redundancies"
  describe "#each"
  describe "#select"
  describe "#take"
  describe "#size"
end