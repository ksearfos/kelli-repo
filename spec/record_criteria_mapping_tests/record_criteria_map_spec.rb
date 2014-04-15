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
  
  it "can be selected" do
    @map.choose
    expect(@map).to be_chosen
  end
  
  it "can be de-selected" do
    @map.unchoose
    expect(@map).not_to be_chosen
  end
end