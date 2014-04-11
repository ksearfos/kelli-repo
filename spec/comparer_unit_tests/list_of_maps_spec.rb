$:.unshift(File.dirname(__FILE__))
require 'spec_helper'

describe ListOfMaps do
  before(:all) do
    map1 = [:thing1, :thing2, :thing3]
    map2 = [:thing1, :thing2, :thing3]
    map3 = [:thing1, :thing4]
    map4 = [:thing4, :thing5]
    @list = TestListOfMaps.new([map1, map2, map3, map4])
  end
  
  it "exists" do
    expect(@list).not_to be_nil
  end
  
  describe "#delete_if_redundant" do
    it "deletes maps with duplicated criteria" do
      expect(false).to be_true
    end
  end
end