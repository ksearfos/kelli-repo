$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'spec_helper'

describe RecordCriteriaMap do
  before(:all) do
	  @map = TestRecordCriteriaMap.new($criteria_with_procs)
	end
	
  it "has a record" do
    expect(@map).to respond_to :record
  end
  
  it "knows which criteria are matched" do
    expect(@map.criteria).to eq($criteria.to_set)
  end
  
  it "can be compared to other maps" do
    duplicate_map = TestRecordCriteriaMap.new($criteria_with_procs)
    expect(@map).to eq(duplicate_map)
  end
  
  it "can be selected" do
    @map.choose
    expect(@map.chosen).to be_true
  end
  
  it "can be de-selected" do
    @map.unchoose
    expect(@map.chosen).to be_false
  end
end